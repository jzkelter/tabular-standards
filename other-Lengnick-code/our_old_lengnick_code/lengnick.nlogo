extensions [time table csv]

__includes ["time-series.nls" "lengnick_test.nls"]

globals[
  DATE
  START-DATE
]

breed [firms firm]
breed [households household]
undirected-link-breed [employment-links employee]
undirected-link-breed [consumer-links consumer]

turtles-own[
  liquidity
]

firms-own[
  wage-rate
  inventories
  price
  marginal-cost
  demand
  technology-constant
  employment-attempts
  open-position?
  buffer
]

households-own[
  reservation-wage
  income
  employed?
  consumption
  daily-division-factor
]

employment-links-own[
  to-be-fired?
]

consumer-links-own [
  visited?
  demand-satisfied?
]

to setup
  clear-all
  initialize-firms
  initialize-households
  set DATE time:anchor-to-ticks time:create "2000/01/02" 1 "days"
  set START-DATE time:create "2000/01/01"
  initialize-employment-connections
  initialize-consumer-connections
  set-monthly-demand
  produce
  reset-ticks
end

to go
  if time:get "day" DATE = 1[
    set-wage-rate
    adjust-labor-and-prices
    search-for-labor
    search-for-new-sellers
    set-monthly-demand
  ]
  consume
  produce
  if not ((time:get "month" DATE) = (time:get "month" (time:plus DATE 1 "day")))[
    pay-wages
    pay-dividends
    fire-labor
  ]
  tick
end

to initialize-firms
  create-firms NUM-FIRMS[
    set shape "truck"
    set color 45
    setxy random-xcor random-ycor
    set inventories 0
    set wage-rate (random-float 6) + 7
    set demand 0
    set technology-constant 3
    set liquidity 0
    set open-position? true
    set marginal-cost (wage-rate / technology-constant)
    set price (marginal-cost * (1 + ((random-float (0.15 - 0.025)) + 0.025)))
    set employment-attempts ts-create ["open-spots" "quantity-hired"]
  ]
end

to initialize-households
  create-households NUM-HOUSEHOLDS[
    set shape "person"
    set color 55
    setxy random-xcor random-ycor
    set reservation-wage (random-normal 10 0.5)
    set liquidity (random-normal 10 0.5)
    set income 0
    set employed? false
  ]
end

to initialize-employment-connections
  search-for-labor
  ask firms[
    set open-position? false
    ifelse labor-force-size = 0[
      set employment-attempts ts-add-row employment-attempts (list START-DATE 1 0)
    ][
      set employment-attempts ts-add-row employment-attempts (list START-DATE 1 1)
    ]
  ]
end

to search-for-labor
  ask households [
    let minimum-wage reservation-wage
    let current-household self
    let current-income income
    ifelse employed?[
      ifelse income > reservation-wage[
        if ((random-float 1) < 0.1)[
          ask one-of firms[
            if wage-rate > current-income and open-position?[
              let new-wage wage-rate
              ask current-household [
                ask my-employment-links[
                  die
                ]
                set income new-wage
              ]
              set open-position? false
              set employment-attempts remove (last employment-attempts) employment-attempts
              set employment-attempts ts-add-row employment-attempts (list DATE 1 1)
              create-employee-with current-household[
                set color 95
                set to-be-fired? false
              ]
            ]
          ]
        ]
      ][
        ask one-of firms[
          if wage-rate > current-income and open-position?[
            let new-wage wage-rate
            ask current-household [
              ask my-employment-links[
                die
              ]
              set income new-wage
            ]
            create-employee-with current-household[
              set color 95
              set to-be-fired? false
            ]
            set employment-attempts remove (last employment-attempts) employment-attempts
            set employment-attempts ts-add-row employment-attempts (list DATE 1 1)
            set open-position? false
          ]
        ]
      ]
    ][
      let employment-found false
      let counter 0
      ifelse time:is-equal DATE START-DATE[
        set counter (random 4 + 1)
      ][
        set counter 5
      ]
      while [counter > 0 and employment-found = false] [
        ask one-of firms[
          let wage wage-rate
          if wage-rate >= minimum-wage[
            if time:is-equal DATE START-DATE or open-position?[
              create-employee-with current-household[
                set color 95
                set employment-found true
                set to-be-fired? false
                ask current-household[
                  set income wage
                  set employed? true
                ]
                show-link
              ]
              if not (time:is-equal DATE START-DATE) [
                set open-position? false
                set employment-attempts remove (last employment-attempts) employment-attempts
                set employment-attempts ts-add-row employment-attempts (list DATE 1 1)

              ]
            ]
          ]
        ]
        set counter counter - 1
      ]
    ]
  ]
end

to initialize-consumer-connections
  ask households[
    let current-household self
    ask n-of 5 firms [
      create-consumer-with current-household[
        set color 25
        set demand-satisfied? false
        hide-link
      ]
    ]
  ]
end

to produce
  ask firms[
    set inventories (inventories + labor-force-size * technology-constant)
  ]
end

to-report inventories-bounds[old-demand]
  report (list (old-demand) (0.25 * old-demand))
end

to-report price-bounds[mc]
  report (list (1.15 * mc) (1.025 * mc))
end

to-report labor-force-size
  report (count my-employment-links)
end

to set-wage-rate
  ask firms[
    ifelse unfilled-position[
      set wage-rate (wage-rate * (1 + (random-float 0.02)))
      set marginal-cost (wage-rate / technology-constant)
    ][
      if consistent-position-filling[
        set wage-rate (wage-rate * (1 - (random-float 0.02)))
        set marginal-cost (wage-rate / technology-constant)
      ]
    ]
  ]
end

to-report unfilled-position
  let most-recent-data last employment-attempts
  report ((item 1 most-recent-data > item 2 most-recent-data))
end

to-report consistent-position-filling
  let current-date time:plus DATE -1 "months"
  let counter 24
  while [(time:is-after current-date START-DATE or time:is-equal current-date START-DATE) and counter > 0][
    let open-spots ts-get employment-attempts current-date "open-spots"
    let quantity-hired ts-get employment-attempts current-date "quantity-hired"
    if open-spots > quantity-hired[
      report false
    ]
    set current-date time:plus current-date -1 "months"
  ]
  report true
end

to adjust-labor-and-prices
  ask firms[
    let inventory-thresholds inventories-bounds demand
    let price-thresholds price-bounds marginal-cost
    if inventories > (first inventory-thresholds)[
      if labor-force-size > 0 [
        ask one-of my-employment-links[
          set to-be-fired? true
        ]
        set employment-attempts ts-add-row employment-attempts (list DATE 0 0)
      ]
      if price > last price-thresholds [
        if random-float 1 < 0.75 [
          set price (price * (1 - (random-float 0.02)))
        ]
      ]
    ]
    if inventories < (last inventory-thresholds) or demand = 0[
      set open-position? true
      set employment-attempts ts-add-row employment-attempts (list DATE 1 0)
      if price < first price-thresholds [
        if random-float 1 < 0.75 [
          set price (price * (1 + (random-float 0.02)))
        ]
      ]
    ]
  ]
end

to set-monthly-demand
  ask households[
    if liquidity > 0[
      let average-price mean-price
      set consumption min (list ((liquidity / average-price) ^ 0.9) (liquidity / average-price))
      (ifelse
        (not (time:get "month" DATE = (time:get "month" (time:plus DATE 28 "days")))) [
          set daily-division-factor 28
        ]
        (not (time:get "month" DATE = (time:get "month" (time:plus DATE 29 "days"))))[
          set daily-division-factor 28
        ]
        (not (time:get "month" DATE = (time:get "month" (time:plus DATE 30 "days"))))[
          set daily-division-factor 30
        ]
        (not (time:get "month" DATE = (time:get "month" (time:plus DATE 31 "days"))))[
          set daily-division-factor 31
        ]
      )
    ]
  ]
end

to-report mean-price
  let running-total 0
  let counter 0
  ask my-consumer-links[
    ask other-end[
      set running-total (running-total + price)
    ]
    set counter counter + 1
  ]
  report (running-total / counter)
end

to search-for-new-sellers
  ask households[
    let current-household self
    let new-consumer-connection 0
    if random-float 1 < 0.25 [
      let current-connection one-of my-consumer-links
      let current-price 0
      ask [other-end] of current-connection[
        set current-price price
      ]
      let new-firm one-of firms with [not (consumer-neighbor? current-household)]
      if new-firm != NOBODY[
        let new-price [price] of new-firm
        if new-price <= (0.99 * current-price)[
          ask current-connection [
            die
          ]
          create-consumer-with new-firm[
            set color 25
            hide-link
            set demand-satisfied? false
          ]
        ]
      ]
    ]
    if random-float 1 < 0.25 [
      if any? my-consumer-links with [not demand-satisfied?]
      [
        let current-connection one-of my-consumer-links with [not demand-satisfied?]
        let new-firm one-of firms with [not (consumer-neighbor? current-household)]
        if new-firm != NOBODY [
          ask current-connection[
            die
          ]
          create-consumer-with new-firm [
            set color 25
            set demand-satisfied? false
            hide-link
          ]
        ]
      ]
    ]
  ]
end

to consume
  ask households[
    ask my-consumer-links[
      set visited? false
    ]
    let daily-demand (consumption / daily-division-factor)
    let quantity-acquired 0
    while [liquidity > 0 and (quantity-acquired < (0.95 * daily-demand)) and any? my-consumer-links with [not visited?]][
      let current-price 0
      let quantity 0
      let household-liquidity liquidity
      ask one-of my-consumer-links with [not visited?][
        let satisfactory false
        set visited? true
        ask other-end [
          if inventories > 0[
            set current-price price
            let affordable-quantity (household-liquidity / price)
            set quantity min (list inventories (daily-demand - quantity-acquired) affordable-quantity)
            set inventories (inventories - quantity)
            set liquidity (liquidity + (quantity * price))
            set demand (demand + (daily-demand - quantity-acquired))
            if quantity = affordable-quantity or quantity = (daily-demand - quantity-acquired)[
              set satisfactory true
            ]
          ]
        ]
        set demand-satisfied? satisfactory
      ]
      set liquidity (liquidity - (quantity * current-price))
    ]
  ]
end

to pay-wages
  ask firms[
    if labor-force-size > 0[
      let months-wages 0
      set buffer 0
      ifelse liquidity >= (wage-rate * labor-force-size)[
        set months-wages wage-rate
        set buffer (0.1 * wage-rate * labor-force-size)
      ][
        set months-wages (liquidity / labor-force-size)
      ]
      ask my-employment-links[
        ask other-end[
          set liquidity (liquidity + months-wages)
          set income months-wages
          if income > reservation-wage[
            set reservation-wage income
          ]
        ]
      ]
      set liquidity (liquidity - (labor-force-size * months-wages))
      let total-household-liquidity (sum [liquidity] of households)
    ]
  ]
end

to pay-dividends
  ask firms[
    let total-household-liquidity sum [liquidity] of households
    if liquidity > 1 [
      let profits-distribution (liquidity - buffer)
      let original-profits-distribution profits-distribution
      set liquidity liquidity - profits-distribution
      ask households [
        ifelse total-household-liquidity > 0[
          let factor (liquidity / total-household-liquidity)
          set liquidity (liquidity + (factor * original-profits-distribution))
          set profits-distribution (profits-distribution - (original-profits-distribution * factor))
        ][
          set liquidity (liquidity + (original-profits-distribution / num-households))
          set profits-distribution (profits-distribution - (original-profits-distribution / num-households))
        ]
      ]
    ]
  ]
end

to fire-labor
  ask firms[
    ask my-employment-links with [to-be-fired? = true][
      ask other-end [
        set employed? false
      ]
      die
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
515
10
1446
682
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
23
49
195
82
NUM-FIRMS
NUM-FIRMS
5
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
23
81
195
114
NUM-HOUSEHOLDS
NUM-HOUSEHOLDS
0
1000
100.0
1
1
NIL
HORIZONTAL

BUTTON
29
165
95
198
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
94
165
157
198
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
30
231
230
381
Unemployment-rate
Time
Unemployment
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot ((NUM-HOUSEHOLDS - (count employment-links)) / NUM-HOUSEHOLDS)"

PLOT
30
381
230
531
Demand estimation
Time
Demand estimation
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [demand] of firms"

PLOT
230
231
430
381
Wage-rate
Time
Wage-rate
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [wage-rate] of firms"

PLOT
230
381
430
531
Marginal-cost
Time
Marginal-cost
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [marginal-cost] of firms"

PLOT
30
529
230
679
Inventories
Time
Inventories
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [inventories] of firms"

PLOT
230
530
430
680
Household Liquidity
Time
Liquidity
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
299
29
499
179
One household
Time
liquidity
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot [liquidity] of household 8"

BUTTON
157
165
253
198
NIL
setup-test
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
