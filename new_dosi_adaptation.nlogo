;**this model hinges on the table of firms having "good produced" and "inputs" be of the same type
;**in other words, if a firm takes as input "input 1," the firm that produces it must have type "input 1"
extensions[time table csv]
__includes["time-series.nls"]

globals[
  LABOR-MONEY-POT ;a number holding how much consumers have available to spend
  WAGE-RATE ;a number storing the current wage rate
  MARKUP-RULE ;a number representing the profit margin for all firms
  AVG-LABOR-PROD ;a number represeenting the average labor productivity
  UNEMPLOYMENT-RATE ;a number representing the unemployment rate
  COST-OF-NEGOTIATION ;a number representing how much it costs firms to negotiate
  INDICES ;a table holding all of the price indices in the model
  DATE ;a time object holding the current date
  START-DATE ;a time object holding the start date of the model
  TOTAL-LABOR-ORDERS ;a number holding the total amount of labor ordered by all firms
  FIRM-INFO ;a dictionary holding the number of each firm
  GOOD-TYPES ;a dictionary holding the types of goods in the model
  TOTAL-FIRMS
]

breed[input-good-firms input-good-firm]
breed[consumer-good-firms consumer-good-firm]
directed-link-breed[framework-agreements framework-agreement]

turtles-own[
  input-information ;this is now going to hold the mp, current stock and pending orders
  liquid-assets ;like lifetime profits - how much a firm is worth
  profits ;a time-series that will keep track of the profits of a firm per time period
  ;**maybe current total cost, depends on how easy it will be to make it a variable versus a reporter
  preferred-index ;a string that will hold a firm's preferred index
  inputs-received? ;a boolean that keeps track of whether a firm has received all of its inputs
  ;**maybe firing? haven't figured out whether this is necessary yet
  done-producing? ;a boolean that keeps track of whether a firm is finished producing
  firm-type ;a string holding what the firm produces - primarily useful for the first iteration of this model
  done-ordering?
  desired-production ;a number representing how much a firm wants to produce
]

input-good-firms-own[
  quantity-ordered ;could keep or get rid of this
  production-capacity ;a number storing the maximum amount a firm can produce
]

consumer-good-firms-own[
  market-share ;may get rid of in the event of having individual consumers
  estimated-demand ;a number representing how much a firm anticipates selling
  inventories ;how much the firm has in stock
  competitiveness ;a number storing how competitive the firm is
  price ;a number storing how much the firm charges for a good
  actual-demand ;a number storing how much was actually demanded of the firm
  quantity-sold ;a number storing how much the firm actually sold
]
framework-agreements-own[
  quantitative-value ;a number holding the quantitative value of the agreement
  expiration-date ;when the agreement is invalid
  index ;a number holding the index of the agreement
  purchase-order ;a number holding the amount that was ordered of the firm - the most recent order
  delivered? ;a boolean holding whether or not a firm has delivered their goods - for the most recent production cycle
]

patches-own[
  patch-type
]

to setup
  clear-all
  initiate-globals
  setup-indices
  let firm-data csv:from-file "Mock-firm-data spreadsheet-Sheet1.csv"
  set firm-data remove-item 0 firm-data
  foreach butfirst firm-data[d ->
    let input-data-list read-from-string (item 3 d)
    set d replace-item 3 d input-data-list
    setup-firms (item 0 d) (item 1 d) (item 2 d) input-data-list (item 4 d)
  ]
  finalize-global-firm-data
  set firm-data butfirst firm-data
  initiate-framework-agreements
  layout
  reset-ticks
end

to finalize-global-firm-data
  foreach table:keys FIRM-INFO[k ->
    let current-firm-info table:get FIRM-INFO k
    let firm-type-inputs table:get current-firm-info "Inputs"
    foreach firm-type-inputs [i ->
      if i != 0[
        let input-firm-info table:get FIRM-INFO i
        let delivers-to table:get input-firm-info "Delivers to"
        set delivers-to lput k delivers-to
        table:put input-firm-info "Delivers to" delivers-to
        table:put FIRM-INFO i input-firm-info
      ]
    ]
  ]
end

to initiate-globals ;run by the observer, sets all of the global variables
  set DATE time:anchor-to-ticks time:create "2000/01/01" 1 "months" ;all of these numbers are derived from the Dosi model and thus we expect them to work well
  set WAGE-RATE 75 ;should they not work well initially, they will emerge over time to more appropriate values
  set AVG-LABOR-PROD 100
  set MARKUP-RULE 0.2
  set LABOR-MONEY-POT 0
  set COST-OF-NEGOTIATION 100
  set START-DATE time:create "1999/12/01"
  set FIRM-INFO table:make
  set GOOD-TYPES (list 0)
  set TOTAL-FIRMS 0
end

to setup-indices ;run by the observer, sets up the indices, a temporary solution
  set INDICES table:make
  table:put INDICES "Index 1" (precision (random-normal 1.2 0.1) 2)
  table:put INDICES "Index 2" (precision (random-normal 1.2 0.1) 2)
  table:put INDICES "Index 3" (precision (random-normal 1.2 0.1) 2)
  table:put INDICES "Index 4" (precision (random-normal 1.2 0.1) 2)
  table:put INDICES "Index 5" (precision (random-normal 1.2 0.1) 2)
end

to-report get-index [k]
  report table:get INDICES k
end

to setup-firms [firm-breed good-produced num-firms input-data capacity] ;run by the observer, sets up the firms based on info from a csv
  let global-firm-data table:make
  set TOTAL-FIRMS (TOTAL-FIRMS + num-firms)
  table:put global-firm-data "Number" num-firms
  table:put global-firm-data "Inputs" (map first input-data)
  table:put global-firm-data "Delivers to" (list)
  set GOOD-TYPES lput good-produced GOOD-TYPES
  ifelse firm-breed = "Consumer"[
    table:put global-firm-data "Consumer?" True
    create-consumer-good-firms num-firms[
      set shape "circle"
      setxy random-xcor random-ycor
      setup-input-table input-data
      set firm-type good-produced
      setup-common-variables
      setup-consumer-variables num-firms
      ;maybe add capacity for consumer good firms
    ]
  ][
    table:put global-firm-data "Consumer?" False
    create-input-good-firms num-firms[
      set shape "truck"
      setxy random-xcor random-ycor
      setup-input-table input-data
      set firm-type good-produced
      setup-common-variables
      setup-input-variables capacity
    ]
  ]
  table:put FIRM-INFO good-produced global-firm-data
end

to setup-common-variables
  set liquid-assets 0
  set profits ts-create["Profits"]
  set preferred-index one-of (table:keys INDICES)
  set inputs-received? false
  set done-producing? false
  set done-ordering? false
  set desired-production 0
end

to setup-input-table [input-data] ;sets up the input table for a given firm, also based on info from a csv file
  set input-information table:make
  foreach input-data[i ->
    let current-input-data table:make
    table:put current-input-data "Marginal-productivity" (item 1 i)
    table:put current-input-data "Current-stock" 0
    table:put current-input-data "Pending-orders" 0
    let input-type (item 0 i)
    let finished-negotiating false
    let average-unit-cost 0
    if input-type = 0[
      set finished-negotiating true
      set average-unit-cost WAGE-RATE
    ]
    table:put current-input-data "Average unit cost" average-unit-cost
    table:put current-input-data "Agreements-negotiated?" finished-negotiating
    table:put input-information input-type current-input-data
  ]
end

to setup-consumer-variables [num-firms] ;sets up the consumer good firm specific variables
  set market-share (1 / num-firms)
  set estimated-demand 0 ;all of these variables are initialized to 0 because they depend on performance, which doesn't happen until the model starts
  set inventories 0
  set competitiveness 0
  set price 0
  set actual-demand 0
  set quantity-sold 0
end

to setup-input-variables [production-capacity-info] ;sets up the input firms specific variables
  set quantity-ordered 0
  set production-capacity production-capacity-info
end

to-report uses-input? [good] ;run by a turtle, reports true if the turtle uses the given input
  report table:has-key? input-information good
end

to-report agreements-negotiated? [good] ;run by a turtle, returns true if the agreements for a particular good have been negotiated
  let good-information table:get input-information good
  report table:get good-information "Agreements-negotiated?"
end

to-report done-negotiating? ;run by a turtle, reports true if the turtle is done negotiating all agreements
  let total-counter 0
  let negotiated-counter 0
  foreach table:keys input-information [k ->
    if agreements-negotiated? k [
      set negotiated-counter (negotiated-counter + 1)
    ]
    set total-counter (total-counter + 1)
  ]
  report total-counter = negotiated-counter
end

to-report number-firms [f] ;run by the observer, reports the total number of firms for a given firm type
  let information table:get FIRM-INFO f
  report table:get information "Number"
end

to-report current-negotiating-goods [good-table] ;run by the observer, reports a list of all the goods that firms can negotiate for
  let ready-goods (map first (filter [i -> (item 1 i = true)] (table:to-list good-table)))
  let ready-firm-types (list)
  foreach table:keys FIRM-INFO[k ->
    let current-firm-info table:get FIRM-INFO k
    let firm-inputs table:get current-firm-info "Inputs"
    if not (member? false (map [i -> member? i ready-goods] firm-inputs))[
      set ready-firm-types lput k ready-firm-types
    ]
  ]
  report ready-firm-types
end

to initiate-framework-agreements ;run by the observer, initiates all of the framework agreements
  let good-negotiated-for? table:make
  foreach GOOD-TYPES[g ->
    ifelse g = 0[
      table:put good-negotiated-for? g true
    ][
      table:put good-negotiated-for? g false
    ]
  ]
  while [any? turtles with [not done-negotiating?]][
    let ready-firm-types current-negotiating-goods good-negotiated-for?
    foreach ready-firm-types [f ->
      let num-firms number-firms f
      ask turtles with [uses-input? f][
        let num-negotiations (ceiling (abs (random-normal (num-firms / 10) 1)))
        let buyer self
        let buyer-profits current-profits
        let buyer-preferred-index preferred-index
        let sum-costs 0
        ask n-of num-negotiations turtles with [firm-type = f][
          negotiate-agreement buyer buyer-profits buyer-preferred-index
          ask link-with buyer [
            set sum-costs (sum-costs + ((table:get INDICES index) * quantitative-value))
          ]
        ]
        let avg-unit-cost (sum-costs / num-negotiations)
        let current-input-info table:get input-information f
        if time:is-equal DATE START-DATE [
          table:put current-input-info "Average unit cost" avg-unit-cost
        ]
        table:put current-input-info "Agreements-negotiated?" true
        table:put input-information f current-input-info
      ]
      table:put good-negotiated-for? f true
    ]
  ]
  ask links [hide-link]
end

to negotiate-agreement [buyer buyer-profits buyer-preferred-index] ;run by the seller firm, negotiates an individual agreement
  let total-cost get-atc
  let seller-profits current-profits
  let seller-preferred-index preferred-index
  create-framework-agreement-to buyer [
    set quantitative-value (total-cost * MARKUP-RULE)
    (ifelse
      buyer-profits > seller-profits[
        set index buyer-preferred-index
      ]
      seller-profits > buyer-profits[
        set index seller-preferred-index
      ]
      buyer-profits = seller-profits[
        set index one-of (list seller-preferred-index buyer-preferred-index)
      ]
    )
    set expiration-date time:plus DATE 5 "years"
    set purchase-order 0
    set delivered? false
  ]
end

to-report get-atc ;run by a turtle, reports the average total cost
  let running-total 0
  foreach table:keys input-information[k ->
    let unit-cost get-metric "Average unit cost" k
    let marginal-prod get-metric "Marginal-productivity" k
    set running-total (running-total + (unit-cost * marginal-prod))
  ]
  report running-total
end

to-report current-profits ;run by a turtle, reports the current profits
  if length profits < 2[
    report 0
  ]
  report last last profits
end

to layout ;lays out the firms by type
  let number-of-firm-types (length butfirst GOOD-TYPES)
  let colors base-colors
  let counter 1
  foreach butfirst GOOD-TYPES[g ->
    ask turtles with [firm-type = g][
      set color (item counter base-colors)
    ]
    let current-global-firm-data table:get FIRM-INFO g
    table:put current-global-firm-data "Color" (item counter colors)
    set counter (counter + 1)
  ]
  set counter 0
  let current-start-block min-pxcor
  foreach butfirst GOOD-TYPES[g ->
    let width-factor ((number-firms g) / TOTAL-FIRMS)
    let current-end-block current-start-block + (width-factor * world-width)
    ask patches with [pxcor > current-start-block and pxcor < current-end-block][
      set patch-type g
    ]
    ask turtles with [firm-type = g][
      move-to one-of patches with [patch-type = g]
    ]
    set current-start-block (current-end-block + 1)
  ]
end

to-report get-metric [key good] ;run by a firm, key must be a string
  let good-info table:get input-information good
  report (table:get good-info key)
end

to run-order-cycle ;run by a firm, orders all of the inputs
  ;probably going to be necessary to have a reporter to determine whether a firm is done ordering inputs
  ;the boolean value isn't enough
  let firms-done-ordering table:make
  foreach table:keys FIRM-INFO[k ->
    table:put firms-done-ordering k false
  ]
  while [any? turtles with [not done-ordering?]][
    foreach (ordering-firm-types firms-done-ordering)[f ->

    ]
  ]
end

to-report ordering-firm-types [firms-done-ordering] ;reports a list of firm types that are finished ordering **need to talk about this procedure because I don't know if it works
  let finished-firm-types (map first (filter [i -> (item 1 i = true)] (table:to-list firms-done-ordering)))
  ifelse (length finished-firm-types) = 0 [
    report (filter [i -> is-consumer? i] (table:keys FIRM-INFO))
  ][
    let new-ready-firms (map first (filter [i -> not (member? i finished-firm-types)] (table:keys FIRM-INFO)))
    foreach new-ready-firms[n ->
      let current-firm-info table:get FIRM-INFO n
      let delivers-to table:get current-firm-info "Delivers to"
      ifelse (length delivers-to) <= (length finished-firm-types)[
        if (member? false (map [i -> member? i new-ready-firms] delivers-to))[
          set new-ready-firms remove n new-ready-firms
        ]
      ][
        set new-ready-firms remove n new-ready-firms
      ]
    ]
    report new-ready-firms
  ]
end

to order-inputs ;run by a firm - has the firm order all of the inputs it needs
  foreach table:keys input-information[k ->
    let quantity-needed ((desired-production / (get-metric "Marginal-productivity" k)) - (get-metric "Current-stock" k))
    let running-order-quantity 0
    while [(running-order-quantity < quantity-needed) and (any? my-in-links with [purchase-order = 0])][
      ask (min-one-of (my-in-links with [([firm-type] of other-end) = k]) [quantitative-value * (get-index index)])[

      ]
    ]
  ]
end

to-report is-consumer? [type-of-firm]
  let firm-type-info table:get FIRM-INFO type-of-firm
  report (table:get firm-type-info "Consumer")
end

to estimate-demand ;run by the observer
  ask consumer-good-firms[
    ifelse time:is-equal DATE START-DATE [
      let aggregate-consumption-estimate ((WAGE-RATE * (random-normal LABOR-FORCE-SIZE 250)) + (0.1 * WAGE-RATE * (random-normal LABOR-FORCE-SIZE 250)))
      let estimated-market-share (market-share + (random-float (0.5 * market-share)) - (random-float (0.5 * market-share)))
      let unit-cost-of-good get-atc
      let markup (1 + MARKUP-RULE)
      let price-of-good (unit-cost-of-good * markup)
      set price price-of-good
      let estimated-consumption (aggregate-consumption-estimate * estimated-market-share)
      set estimated-demand round (estimated-consumption / price-of-good)
    ][
      set estimated-demand actual-demand
    ]
    set desired-production (estimated-demand - inventories)
    set done-ordering? True
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
1587
577
-1
-1
16.91
1
10
1
1
1
0
1
1
1
-40
40
-16
16
0
0
1
ticks
30.0

BUTTON
32
112
98
145
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

SLIDER
27
64
202
97
LABOR-FORCE-SIZE
LABOR-FORCE-SIZE
2000
4000
3000.0
1
1
NIL
HORIZONTAL

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
