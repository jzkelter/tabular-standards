extensions [time table csv]

__includes["time-series.nls"]
;add a fixed cost possibly
globals[
  LABOR-MONEY-POT
  WAGE-RATE
  MARKUP-RULE
  AVERAGE-LABOR-PRODUCTIVITY
  UNEMPLOYMENT-RATE
  COST-OF-NEGOTIATION
  INDICIES
  DATE
  START-DATE
  TOTAL-LABOR-ORDERS
]


breed [input-good-firms input-good-firm]
breed [consumer-good-firms consumer-good-firm]

turtles-own [
  input-information
  current-input-stock
  pending-orders
  liquid-assets
  profits
  current-total-cost
  preferred-index
  framework-agreements
  inputs-received?
  firing?
  done-producing?
]

input-good-firms-own [
  firm-type
  quantity-ordered
  production-capacity
]

consumer-good-firms-own[
  market-share
  estimated-demand
  desired-production
  inventories
  competitiveness
  price
  actual-demand
  quantity-sold
]

links-own [
  quantitative-value
  expiration-date
  index
  purchase-order?
  quantity-of-order
]

to setup
  clear-all
  initiate-globals
  setup-INDICIES
  setup-type-1-firms
  setup-type-2-firms
  setup-type-3-firms
  setup-consumer-good-firms
  initiate-framework-agreements
  run-production-cycle
  calculate-unemployment
  calculate-alp
  ask consumer-good-firms [
    set actual-demand ((LABOR-MONEY-POT * market-share) / price)
  ]
  reset-ticks
end

to initiate-globals
  set DATE time:anchor-to-ticks time:create "2000/01/01" 1 "months"
  set WAGE-RATE 75
  set AVERAGE-LABOR-PRODUCTIVITY 100
  set MARKUP-RULE 0.2
  set LABOR-MONEY-POT 0
  set COST-OF-NEGOTIATION 100
  set START-DATE time:create "1999/12/01"
end

to setup-INDICIES
  set INDICIES table:make
  table:put INDICIES "Index 1" (precision (random-normal 1.2 0.1) 2)
  table:put INDICIES "Index 2" (precision (random-normal 1.2 0.1) 2)
  table:put INDICIES "Index 3" (precision (random-normal 1.2 0.1) 2)
  table:put INDICIES "Index 4" (precision (random-normal 1.2 0.1) 2)
  table:put INDICIES "Index 5" (precision (random-normal 1.2 0.1) 2)
end

to initiate-framework-agreements
  ask consumer-good-firms [
    negotiate-framework-agreements "Input 1"
  ]
  ask input-good-firms with [firm-type = "Input 2" or firm-type = "Input 3"] [
    negotiate-framework-agreements "Input 1"
  ]
  ask input-good-firms with [firm-type = "Input 3"] [
    negotiate-framework-agreements "Input 2"
  ]
  ask consumer-good-firms [
    negotiate-framework-agreements "Input 3"
  ]
end
;calculate unit price based on index
to setup-type-1-firms
  let increment ((world-width * 0.95) / TYPE-1-INPUT-FIRMS)
  let x min-pxcor + (increment / 2)
  create-input-good-firms TYPE-1-INPUT-FIRMS [
    setxy x 0
    set shape "Truck"
    set color blue
    set firm-type "Input 1"
    set liquid-assets 3000
    set input-information table:make
    table:put input-information "Labor" (list 75 WAGE-RATE)
    set current-input-stock table:make
    set pending-orders table:make
    set profits ts-create ["Profits"]
    set production-capacity 1650
    set preferred-index one-of (table:keys INDICIES)
    set x (x + increment)
    set framework-agreements table:make
    set inputs-received? false
  ]
end

to setup-type-2-firms
  create-input-good-firms TYPE-2-INPUT-FIRMS [
    setxy random-xcor random-ycor
    set shape "Truck"
    set color red
    set firm-type "Input 2"
    set liquid-assets 3000
    set input-information table:make
    table:put input-information "Labor" (list 45 WAGE-RATE)
    table:put input-information "Input 1" (list 2)
    set current-input-stock table:make
    set pending-orders table:make
    set production-capacity 500
    set profits ts-create ["Profits"]
    set preferred-index one-of (table:keys INDICIES)
    set framework-agreements table:make
    set inputs-received? false
  ]
end

to setup-type-3-firms
  create-input-good-firms TYPE-3-INPUT-FIRMS [
    setxy random-xcor random-ycor
    set shape "Truck"
    set color yellow
    set firm-type "Input 3"
    set liquid-assets 3000
    set input-information table:make
    table:put input-information "Labor" (list 20 WAGE-RATE)
    table:put input-information "Input 2" (list 1.5)
    table:put input-information "Input 1" (list 3)
    set current-input-stock table:make
    set pending-orders table:make
    set production-capacity 600
    set profits ts-create ["Profits"]
    set preferred-index one-of (table:keys INDICIES)
    set framework-agreements table:make
    set inputs-received? false
  ]
end

to setup-consumer-good-firms
  create-consumer-good-firms NUM-CONSUMER-FIRMS [
    setxy random-xcor random-ycor
    set shape "Circle"
    set color white
    set liquid-assets 3000
    set input-information table:make
    table:put input-information "Labor" (list 10 WAGE-RATE)
    table:put input-information "Input 1" (list 10)
    table:put input-information "Input 3" (list 0.5)
    set inventories 0
    set market-share (1 / NUM-CONSUMER-FIRMS)
    set current-input-stock table:make
    set pending-orders table:make
    set profits ts-create ["Profits"]
    set preferred-index one-of (table:keys INDICIES)
    set framework-agreements table:make
    set inputs-received? false
  ]
end

to negotiate-framework-agreements [seller-type]
  let current-turtle self
  let total-seller-firms count input-good-firms with [firm-type  = seller-type]
  let number-of-agreements 0
  let max-number-of-agreements (ceiling (abs (random-normal (total-seller-firms / 10) 1)))
  let buyer-profits 0
  if length profits > 1 [set buyer-profits current-profit]
  while [number-of-agreements < max-number-of-agreements] [
    let offer 0
    let seller-profits 0
    let price-index 0
    ask one-of input-good-firms with [firm-type = seller-type] [
      let price-floor get-cost-estimate (10)
      let markup (1 + (abs (random-normal MARKUP-RULE 0.05)))
      set offer (list self (price-floor * markup))
      if length profits > 1 [set seller-profits current-profit]
      create-link-to (current-turtle)
    ]
    ;have each firm pick a preferred index in setup for now
    (ifelse
      buyer-profits = seller-profits [
        set price-index one-of (table:keys INDICIES)
      ]
      buyer-profits > seller-profits [
        set price-index preferred-index
      ]
      seller-profits > buyer-profits [
        set price-index [preferred-index] of (first offer)
      ]
    )
    set offer lput price-index offer
    ask link-with (first offer) [
      hide-link
      set color [color] of (first offer)
      set quantitative-value item 1 offer
      set expiration-date time:plus DATE 5 "years"
      set index last offer
    ]
    set liquid-assets (liquid-assets - COST-OF-NEGOTIATION)
    ask (first offer)[
      set liquid-assets (liquid-assets - COST-OF-NEGOTIATION)
    ]
    ;maybe do something for the seller firm as well
    set number-of-agreements (number-of-agreements + 1)
  ]
  rank-frameworks seller-type
end

to-report current-profit
  report last last profits
end

to rank-frameworks [seller-type]
  let frameworks (list)
  ask my-links [
    let unit-cost 0
    if [firm-type] of other-end = seller-type [
      set unit-cost (precision (quantitative-value * (table:get INDICIES index)) 2)
      let entry (list self unit-cost other-end)
      set frameworks fput entry frameworks
    ]
  ]
  set frameworks sort-by [[a b] -> item 1 a < item 1 b] frameworks
  table:put framework-agreements seller-type frameworks
  let current-input-info table:get input-information seller-type
  let first-choice (first first frameworks)
end

to-report get-cost-estimate [quantity]
  let keys table:keys input-information
  let total-cost 0
  foreach keys [ k ->
    let marginal-productivity first (table:get input-information k)
    let unit-cost 0
    ifelse k = "Labor"[
      set unit-cost item 1 (table:get input-information k)
    ][
      let frameworks table:get framework-agreements k
      set unit-cost item 1 (first frameworks)
    ]
    let quantity-needed (quantity / marginal-productivity)
    set total-cost (total-cost + (unit-cost * quantity-needed))
  ]
  report (total-cost / quantity)
end

to-report get-mp [input-type]
  report first table:get input-information input-type
end
;**write this method**
to estimate-consumer-demand
  ask consumer-good-firms [
    ifelse time:is-equal DATE (START-DATE)[
      let aggregate-consumption-estimate ((WAGE-RATE * (random-normal LABOR-FORCE-SIZE 250)) + (0.2 * WAGE-RATE * (random-normal LABOR-FORCE-SIZE 250)))
      let estimated-market-share (random-normal market-share (0.25 * market-share))
      if estimated-market-share = 0 [set estimated-market-share (0.5 * (1 / NUM-CONSUMER-FIRMS))]
      let unit-cost-of-good get-cost-estimate (20)
      let markup (1 + (random-normal MARKUP-RULE 0.05))
      if markup <= 1 [set markup 1.01]
      let price-of-good (unit-cost-of-good * markup)
      set price price-of-good
      let estimated-consumption (aggregate-consumption-estimate * estimated-market-share)
      set estimated-demand ceiling (estimated-consumption / price-of-good)
    ][
      ;do what dosi did - their actual demand from the previous step
      ;one option is to simply increase or decrease demand as they sell out
      ;look into the dosi model to see how demand is adjusted
      ;another option is to just tell consumer good firms what their actual demand was
      ;hypothetical: after selling out more people walk in and so you can more or less figure out what actual demand would've been
    ]
  ]
end

to order-inputs
  let inputs table:to-list input-information
  let production-quantity 0
  ifelse member? self consumer-good-firms [
    set production-quantity (estimated-demand - inventories)
    set desired-production production-quantity
  ][
    set production-quantity quantity-ordered
  ]
  foreach inputs [ i ->
    let input-type first i
    let total-cost 0
    let mp first (item 1 i)
    let input-quantity-desired 0
    ifelse time:is-equal DATE (START-DATE)[
      set input-quantity-desired (production-quantity / mp)
    ][
      let current-inventory first table:get current-input-stock input-type
      let quantity-needed-for-production (production-quantity / mp)
      set input-quantity-desired (quantity-needed-for-production - current-inventory)
    ]
    let quantity-obtained 0
    let order 0
    ifelse input-type = "Labor" [
      ;make some simple reporters for this
      let unit-cost item 1 (item 1 i)
      set TOTAL-LABOR-ORDERS (TOTAL-LABOR-ORDERS + input-quantity-desired)
      set quantity-obtained input-quantity-desired
    ][
      let frameworks table:get framework-agreements input-type
      let counter 0
      while [quantity-obtained < input-quantity-desired and counter < length frameworks] [
        let current-framework item counter frameworks
        ;maybe just get this from the link
        let seller-firm item 2 current-framework
        let current-unit-cost item 1 current-framework
        let quantity-available-for-purchase 0
        ask seller-firm [
          set quantity-available-for-purchase (production-capacity - quantity-ordered)
        ]
        if quantity-available-for-purchase > 0 [
          let order-from-this-firm (min (list (input-quantity-desired - quantity-obtained) quantity-available-for-purchase))
          set quantity-obtained (quantity-obtained + order-from-this-firm)
          set total-cost (total-cost + (order-from-this-firm * current-unit-cost))
          ask seller-firm [
            set quantity-ordered (quantity-ordered + order-from-this-firm)
            set liquid-assets (liquid-assets + (order-from-this-firm * current-unit-cost))
          ]
          ask link-with seller-firm [
            show-link
            set purchase-order? true
            set quantity-of-order order-from-this-firm
          ]
        ]
        set counter (counter + 1)
      ]
    ]
    let unit-cost 0
    if quantity-obtained > 0 [
      set unit-cost total-cost / quantity-obtained
    ]
    set order (list quantity-obtained unit-cost)
    table:put pending-orders input-type order
    ;set liquid-assets (liquid-assets - total-cost)
  ]
end
;don't have firms pay until they receive goods
to produce
  let labor-order first (table:get pending-orders "Labor")
  let amount-of-labor-hired 0 ;going to have to change this in order to add friction
  ifelse TOTAL-LABOR-ORDERS < LABOR-FORCE-SIZE [
    set amount-of-labor-hired labor-order
  ][
    set amount-of-labor-hired ((LABOR-FORCE-SIZE / TOTAL-LABOR-ORDERS) * labor-order)
  ]
  table:put current-input-stock "Labor" (list amount-of-labor-hired (WAGE-RATE * amount-of-labor-hired))
  let production-quantity 10000
  let inputs table:to-list current-input-stock
  foreach inputs [ i ->
    let input-type first i
    let data item 1 i
    let marginal-productivity get-mp input-type
    let input-quantity first data
    let potential-quantity input-quantity * marginal-productivity
    if potential-quantity < production-quantity [set production-quantity potential-quantity]
  ]
  set done-producing? true
  set current-total-cost (current-total-cost + (amount-of-labor-hired * WAGE-RATE))
  set LABOR-MONEY-POT (LABOR-MONEY-POT + (amount-of-labor-hired * WAGE-RATE))
  let original-desired-production 0
  let input-type 0
  ifelse member? self consumer-good-firms [
    set inventories (inventories + production-quantity)
  ][
    set original-desired-production quantity-ordered
    set input-type firm-type
  ]
  let total-revenue 0
  ask my-out-links with [purchase-order? = true][
    set purchase-order? false ;instaead of calling it purchase-order? call it purchase-order?
    ;make a link-breed called framework agreements
    let quantity-to-be-delivered ((quantity-of-order / original-desired-production) * production-quantity) ;maybe call this original-quantity-ordered / maybe rearrange this formula
    let unit-price quantitative-value * (table:get INDICIES index)
    let total-cost-of-order (quantity-to-be-delivered * unit-price)
    ;look at conversations with Joseph for information about the index
    set total-revenue (total-revenue + total-cost-of-order)
    ask other-end [
      set liquid-assets (liquid-assets - total-cost-of-order)
      set current-total-cost (current-total-cost + total-cost-of-order)
      let current-quantity 0
      let current-cost-of-input 0
      if table:has-key? current-input-stock input-type [
        set current-quantity first (table:get current-input-stock input-type)
        set current-cost-of-input item 1 (table:get current-input-stock input-type)
      ]
      table:put current-input-stock input-type (list (current-quantity + quantity-to-be-delivered) (current-cost-of-input + total-cost-of-order))
      if not (any? my-in-links with [purchase-order? = true])[
        set inputs-received? true
      ]
    ]
  ]
  set liquid-assets (liquid-assets - (amount-of-labor-hired * WAGE-RATE))
  foreach inputs [ i ->
    set input-type first i
    let data item 1 i
    let quantity-used (production-quantity / (get-mp input-type))
    let original-quantity first data
    if not (input-type  = "Labor")[
      set data replace-item 0 data (original-quantity - quantity-used)
      table:put current-input-stock input-type data
    ]
  ]
  ;procedure is too long right now
  ;make separate smaller procedures to make this more clear
end
;make labor have friction
;to create the lag on firing pay labor costs up-front
;firms decide how much labor they want, then in the produce
;procuedre firms actually figure out how much labor they have
;they pay that labor
;then demand is estimated again

to run-production-cycle
  estimate-consumer-demand
  ask consumer-good-firms [order-inputs] ;;THIS IS THE PROBLEM PROCEDURE
  ask input-good-firms with [firm-type = "Input 3"] [order-inputs]
  ask input-good-firms with [firm-type = "Input 2"] [order-inputs]
  ask input-good-firms with [firm-type = "Input 1"] [order-inputs]
  ask turtles [set done-producing? false]
  ask turtles with [not (any? my-in-links with [purchase-order? = true])] [
    set inputs-received? true
  ]
  while [any? turtles with [done-producing? = false]] [
    ask turtles with [inputs-received? = true and done-producing? = false] [
      produce
    ]
  ]
end

to calculate-unemployment
  let aggregate-employment 0
  ask turtles [
    let employed-workers first table:get current-input-stock "Labor"
    set aggregate-employment (aggregate-employment + employed-workers)
  ]
  let employment-rate (aggregate-employment / LABOR-FORCE-SIZE)
  set UNEMPLOYMENT-RATE (1 - employment-rate)
end

to calculate-alp
  let total-productivity 0
  ask turtles [
    let employed-workers first table:get current-input-stock "Labor"
    let mp-labor get-mp "Labor"
    set total-productivity (total-productivity + (employed-workers * mp-labor))
  ]
  set AVERAGE-LABOR-PRODUCTIVITY (total-productivity / ((1 - UNEMPLOYMENT-RATE) * LABOR-FORCE-SIZE))
end

to calculate-individual-consumer-competitiveness
  ask consumer-good-firms [
    let unfilled-demand 0
    if inventories = 0 [
      set unfilled-demand (actual-demand - quantity-sold)
    ]
    set competitiveness ((- price) - unfilled-demand)
  ]
end

to-report average-competetiveness
  let running-total 0
  ask consumer-good-firms [
    set running-total (running-total + (competitiveness * market-share))
  ]
  report running-total
end

to go
;probably going to make use of the run-production-cycle procedure
  ;need a procedure to update globals

end
;once the go procedure is working, need to work on generating indices within the model
;look through Joseph's emails
;adding the ERI would require getting locations
;first let's get it working by using indices that are generated within the model
;might have to have input firms keep some amount in stock
;IKON - based on a fraction of total equities
;Look for the paper in which there is some ownership of firms
;do a pull request with what's already here
;try to make the code as general as possible
;make some of the input ordering procedures more general
@#$#@#$#@
GRAPHICS-WINDOW
203
17
1635
604
-1
-1
14.1
1
10
1
1
1
0
1
1
1
-50
50
-20
20
0
0
1
ticks
30.0

SLIDER
10
17
197
50
TYPE-1-INPUT-FIRMS
TYPE-1-INPUT-FIRMS
6
18
12.0
1
1
NIL
HORIZONTAL

SLIDER
10
50
197
83
TYPE-2-INPUT-FIRMS
TYPE-2-INPUT-FIRMS
25
75
50.0
1
1
NIL
HORIZONTAL

SLIDER
10
83
197
116
TYPE-3-INPUT-FIRMS
TYPE-3-INPUT-FIRMS
25
75
50.0
1
1
NIL
HORIZONTAL

SLIDER
10
115
197
148
NUM-CONSUMER-FIRMS
NUM-CONSUMER-FIRMS
100
300
200.0
1
1
NIL
HORIZONTAL

SLIDER
10
148
197
181
LABOR-FORCE-SIZE
LABOR-FORCE-SIZE
2000
4000
3000.0
1
1
NIL
HORIZONTAL

BUTTON
10
181
77
215
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
