extensions [rnd]

breed [households household]
breed [firms firm]
undirected-link-breed [consumer-links consumer-link]
undirected-link-breed [employment-links employment-link]

turtles-own[
  liquidity ;essentially the money currently available to a turtle
]

households-own[
  reservation-wage
  received-wage
  daily-demand
  blacklisted-suppliers
]

firms-own[
  buffer
  inventories
  price
  demand
  wage-rate
  open-position?
  close-position?
  last-open-position
  filled-position?
  tech-constant
]

consumer-links-own[
  demand-not-satisfied
  visited?
]

employment-links-own[
  to-be-fired?
]

globals[
  MONTH-LENGTH
  MONTH
  MIN-WAGE-RATE
]

to setup
  clear-all

  set MONTH-LENGTH 21
  set MIN-WAGE-RATE 0
  set MONTH 1

  initialize-households
  initialize-firms

  ask households[
    create-consumer-links-with n-of 7 firms[
      init-consumer-link
    ]
    if not employed?[
      create-employment-link-with one-of firms[
        init-employment-link
      ]
    ]
  ]
  reset-ticks
end

to init-employment-link
  set to-be-fired? false
end

to init-consumer-link
  set demand-not-satisfied 0
  set visited? false
  hide-link
end

to-report employed? ;run by a household
  report not (count my-employment-links = 0)
end

to initialize-households
  create-households NUM-HOUSEHOLDS[
    set reservation-wage 0
    set shape "Person"
    setxy random-xcor random-ycor
    set color blue
    set received-wage 52 ;arbitrary condition; seems to be around a month's wages, I don't know why this starts out with a value
    set liquidity 98.78 ;arbitrary condition - seems to be roughly 2 months wages
    set daily-demand 0 ;consumption not set until firms are chosen to buy from
    set blacklisted-suppliers (list)
  ]
end

to initialize-firms
  create-firms NUM-FIRMS[
    set shape "truck"
    setxy random-xcor random-ycor
    set color green
    set liquidity 0
    set buffer 0
    set inventories 50
    set price 1 * random-small-change
    set demand 0
    set wage-rate 52 * random-small-change
    set open-position? false
    set filled-position? false
    set last-open-position 0
    set close-position? false
    set tech-constant 3
    create-employment-link-with one-of households with [not employed?][
      init-employment-link
    ]
  ]
end

to-report random-small-change
  report (1 + (((random-float 1) - 0.5) / 50))
end

to-report my-employer ;run by a household
  report [other-end] of one-of my-employment-links
end

;;*************************************** go ***********************************************

;to go
;  ask firms[
;    show (word "Wage-rate before go: " wage-rate)
;  ]
;  if ticks mod MONTH-LENGTH = 1[
;    show "Start of month"
;    ask firms [
;      show (word "Start of month wage-rate: " wage-rate)
;    ]
;    ask firms[
;      show (word "Before: " wage-rate)
;      adjust-wage-rate
;      show (word "After: " wage-rate)
;      adjust-job-positions
;      adjust-price
;      reset-demand
;    ]
;    ask households[
;      search-cheaper-vendor
;      search-delivery-capable-vendor
;      ifelse not employed?[
;        search-job
;      ][
;        search-better-paid-job
;      ]
;      set-consumption
;    ]
;  ]
;  ask households[
;    buy-consumption-goods
;  ]
;  ask firms[
;    produce-consumption-goods
;  ]
;  if (ticks mod MONTH-LENGTH) = 0[
;    set MONTH MONTH + 1
;    ask firms[
;      decide-reserve
;      distribute-profits
;      pay-wages
;    ]
;    ask households[
;      adjust-reservation-wage
;    ]
;    ask firms[
;      decide-fire-worker
;    ]
;  ]
;  tick
;end

to go
  ask firms[
    adjust-wage-rate
    adjust-job-positions
    adjust-price
    reset-demand
  ]
  ask households[
    search-cheaper-vendor
    search-delivery-capable-vendor
    ifelse not employed?[
      search-job
    ][
      search-better-paid-job
    ]
    set-consumption
  ]
  let counter 0
  while[counter < 21][
    ask households[
      buy-consumption-goods
    ]
    ask firms[
      produce-consumption-goods
    ]
    set counter counter + 1
  ]
  set MONTH MONTH + 1
  ask firms[
    decide-reserve
  ]
  ask firms [
    distribute-profits
  ]
  ask firms [
    pay-wages
  ]
  ask households[
    adjust-reservation-wage
    set-house-size
  ]
  ask firms[
    decide-fire-worker
  ]
  tick
end


to set-house-size
  set size .2 + (sqrt liquidity / 12)
end

;to go
;  ;ask firms[
;;    show (word "Wage-rate before go: " wage-rate)
;;  ]
;  show (word "mean Wage-rate before go: " mean [wage-rate] of firms)
;  if ticks mod MONTH-LENGTH = 1[
;    show "Start of month"
;;    ask firms [
;;      show (word "Start of month wage-rate: " wage-rate)
;;    ]
;    show (word "mean Start of month wage-rate: " mean [wage-rate] of firms)
;    ask firms[
;;      show (word "Before: " wage-rate)
;      adjust-wage-rate
;;      show (word "After: " wage-rate)
;      adjust-job-positions
;      adjust-price
;      reset-demand
;    ]
;    ask households[
;      search-cheaper-vendor
;      search-delivery-capable-vendor
;      ifelse not employed?[
;        search-job
;      ][
;        search-better-paid-job
;      ]
;      set-consumption
;    ]
;  ]
;  ask households[
;    show (word "Liquidity before purchase: " liquidity)
;    buy-consumption-goods
;    show (word "Liquidity after purchase: " liquidity)
;  ]
;  show (word "mean Wage-rate before firms produce: " mean [wage-rate] of firms)
;  ask firms[
;    produce-consumption-goods
;  ]
;  show (word "mean Wage-rate after firms produce: " mean [wage-rate] of firms)
;  if (ticks mod MONTH-LENGTH) = 0[
;    set MONTH MONTH + 1
;    show (word "mean Wage-rate before firms decide-reserve/distribute-profits/pay-wages: " mean [wage-rate] of firms)
;    ask firms[
;      decide-reserve
;    ]
;    show (word "mean wage-rate after decide-reserve: " mean [wage-rate] of firms)
;    ask firms [
;      distribute-profits
;    ]
;    show (word "mean wage-rate after distribute-profits: " mean [wage-rate] of firms)
;    ask firms[
;      pay-wages
;    ]
;    show (word "mean wage-rate after pay-wages: " mean [wage-rate] of firms)
;    ask households[
;      adjust-reservation-wage
;    ]
;    ask firms[
;      decide-fire-worker
;    ]
;  ]
;  tick
;end


;;**************************************** firm procedures ****************************************************

to adjust-wage-rate ;to be run by firms
  (ifelse
    ((last-open-position = (MONTH - 1)) and not (filled-position?))[
      set wage-rate (wage-rate * (1 + random-float(0.019)))
    ]
    ((MONTH - last-open-position) > 24)[
      set wage-rate (wage-rate * (1 - random-float 0.019))
    ]
  )
  set filled-position? false
end

to adjust-job-positions
  (ifelse
    (inventories < (demand * 0.25))[
      set open-position? true
      set last-open-position MONTH
      set close-position? false
    ]
    (inventories > demand)[
      set open-position? false
      set close-position? true
    ]
  )
end

to adjust-price
  let marginal-cost (wage-rate / MONTH-LENGTH / tech-constant)
  (ifelse
    ((inventories < (demand * 1.025)) and (price < (marginal-cost * 1.15)) and ((random-float 1) < 0.75))[
      set price (price * (1 + (0.02 * (random-float 1))))
    ]
    ((inventories > demand) and (price > (marginal-cost * 1.025)) and ((random-float 1) < 0.75))[
      set price (price * (1 - (0.02 * (random-float 1))))
    ]
  )
end

to-report labor-force-size
  report count my-employment-links
end

to reset-demand
  set demand 0
end

to hire-worker
  set open-position? false
  set filled-position? true
  set close-position? true
end

to quit
  set close-position? false
end

to fire-worker
  ask one-of my-employment-links with [to-be-fired?][
    die
  ]
  set close-position? false
end

to decide-fire-worker
  if close-position? and (labor-force-size > 1)[
    ask one-of my-employment-links[
      set to-be-fired? true
    ]
    fire-worker
  ]
  set close-position? false
end

to produce-consumption-goods
  set inventories (inventories + (tech-constant * labor-force-size))
end

to-report sell-consumption-goods [goods-demanded]
  let sold-goods (min (list goods-demanded inventories))
  set demand (demand + goods-demanded)
  set inventories (inventories - sold-goods)
  set liquidity (liquidity + (sold-goods * price))
  report sold-goods
end

to pay-wages
  if (wage-rate * labor-force-size) > liquidity[
    set wage-rate (liquidity / labor-force-size)
  ]
  let household-wage wage-rate
  ask my-employment-links[
    ask other-end[
      receive-wage household-wage
    ]
  ]
  set liquidity (liquidity - (wage-rate * labor-force-size))
end

to decide-reserve
  set buffer (max (list 0 (min (list liquidity (wage-rate * labor-force-size * 0.1)))))
end

to distribute-profits
  let profit (liquidity - buffer - (wage-rate * labor-force-size))
  if profit > 0[
    let total-money sum [liquidity] of households
    if total-money > 0[
      ask households[
        set liquidity (liquidity + (profit * (liquidity / total-money)))
      ]
    ]
    set liquidity (liquidity - profit)
  ]
end

;;********************************************  household procedures  ********************************************************

to search-cheaper-vendor
  if ((random-float 1) < 0.25)[
    let chopping-block [other-end] of one-of my-consumer-links
    let current-household self
    let other-firms firms with [not consumer-link-neighbor? current-household]
    let new-firm rnd:weighted-one-of other-firms [labor-force-size]
    if ((([price] of chopping-block) * (1 - 0.01)) > ([price] of new-firm))[
      if member? chopping-block blacklisted-suppliers [
        set blacklisted-suppliers remove chopping-block blacklisted-suppliers
      ]
      ask consumer-link-with chopping-block[
        die
      ]
      create-consumer-link-with new-firm[
        init-consumer-link
      ]
    ]
  ]
end

to search-delivery-capable-vendor
  if ((random-float 1) < 0.25)[
    if length blacklisted-suppliers > 0[
      let current-household self
      let other-firms firms with [not consumer-link-neighbor? current-household]
      ;let chopping-block rnd:weighted-one-of-list blacklisted-suppliers [[b] -> [demand-not-satisfied] of consumer-link-with current-household];***problem line right here***
      let chopping-block select-chopping-block
      let new-firm rnd:weighted-one-of other-firms [labor-force-size]
      if (member? chopping-block blacklisted-suppliers)[
        set blacklisted-suppliers remove chopping-block blacklisted-suppliers
      ]
      ask consumer-link-with chopping-block[
        die
      ]
      create-consumer-link-with new-firm[
        init-consumer-link
      ]
    ]
  ]
end

to-report select-chopping-block
  let selected? false
  while [not selected?][
    let potential-link rnd:weighted-one-of my-consumer-links [demand-not-satisfied]
    let potential-chopping-block [other-end] of potential-link
    if member? potential-chopping-block blacklisted-suppliers[
      set selected? true
      report potential-chopping-block
    ]
  ]
end

to search-job
  let counter 0
  while[not employed? and counter < 5][
    let potential-firm one-of firms with [open-position?]
    if potential-firm != Nobody [
      if [wage-rate] of potential-firm > reservation-wage[
        create-employment-link-with potential-firm[
          init-employment-link
        ]
        ask potential-firm[
          hire-worker
        ]
      ]
    ]
    set counter counter + 1
  ]
end

to search-better-paid-job
  let current-employer my-employer
  if [count my-employment-links] of my-employer > 1[
    if([wage-rate] of current-employer < reservation-wage or ((random-float 1) < 0.1))[
      let potential-firm one-of firms with [open-position?]
      if potential-firm != nobody[
        if ([wage-rate] of potential-firm > [wage-rate] of my-employer and [wage-rate] of potential-firm > reservation-wage)[
          ask one-of my-employment-links[
            ask other-end[
              quit
            ]
            die
          ]
          create-employment-link-with potential-firm[
            init-employment-link
          ]
          ask potential-firm[
            hire-worker
          ]
        ]
      ]
    ]
  ]
end

to set-consumption
  let avg-price 0
  let total-price 0
  ask my-consumer-links[
    ask other-end[
      set total-price total-price + price
    ]
  ]
  set avg-price (total-price / (count my-consumer-links))
  let max-consumption ((max (list 0 liquidity)) / avg-price)
  let monthly-consumption (min (list max-consumption (max-consumption ^ 0.9)))
  set daily-demand (monthly-consumption / 21)
end

to buy-consumption-goods
  let remaining-demand daily-demand
  while [(remaining-demand > (0.05 * daily-demand)) and (liquidity > 0) and (any? my-consumer-links with [not visited?])][
    let bought-goods 0
    let good-price 0
    let current-firm nobody
    ask one-of my-consumer-links with [not visited?][
      set visited? true
      show-link
      ask other-end[
        set good-price price
        set current-firm self
      ]
      hide-link
    ]
    let wanted-goods (min (list remaining-demand (liquidity / good-price)))
    ask current-firm[
      set bought-goods (sell-consumption-goods wanted-goods)
    ]
    set remaining-demand (remaining-demand - bought-goods)
    set liquidity (liquidity - (bought-goods * good-price))
    if remaining-demand > 0[
      ask consumer-link-with current-firm[
        set demand-not-satisfied (demand-not-satisfied + remaining-demand)
      ]
      if not member? current-firm blacklisted-suppliers[
        set blacklisted-suppliers fput current-firm blacklisted-suppliers
      ]
    ]
  ]
  ask my-consumer-links[
    set visited? false
  ]
end

to receive-wage [value]
  set liquidity (liquidity + value)
  set received-wage value
end

to adjust-reservation-wage
  if employed? and (received-wage > reservation-wage)[
    set reservation-wage received-wage
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
682
30
1613
702
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-35
35
-25
25
0
0
1
ticks
30.0

SLIDER
41
32
215
65
NUM-HOUSEHOLDS
NUM-HOUSEHOLDS
10
1000
1000.0
1
1
NIL
HORIZONTAL

SLIDER
214
32
386
65
NUM-FIRMS
NUM-FIRMS
7
100
100.0
1
1
NIL
HORIZONTAL

BUTTON
41
64
107
97
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

BUTTON
107
64
170
97
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
41
267
241
417
Unemployment-rate
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot (((count households) - (count employment-links)) / (count households))"

PLOT
241
267
441
417
Avg-wage-rate
NIL
NIL
0.0
10.0
0.0
5.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [wage-rate] of firms"

PLOT
441
267
641
417
Firm liquidity
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [liquidity] of firms"

PLOT
41
416
241
566
Household Liquidity
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [liquidity] of households"

PLOT
243
416
443
566
Total Liquidity
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot sum [liquidity] of turtles"

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
