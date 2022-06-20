;; THINGS THAT MIGHT BE OFF
; - it could be that dividing dividends based off of current wealth leads to an instability eventually

extensions [rnd table]

__includes[
  "_nls_files/multifirm-unit-tests.nls"
  "_nls_files/unit testing.nls"
  "_nls_files/household-procedures.nls"
  "_nls_files/firm-procedures.nls"
  "_nls_files/go-procedures.nls"
  "_nls_files/setup-procedures.nls"
  "_nls_files/misc-observer-procedures.nls"
  "_nls_files/land-procedures.nls"
  "_nls_files/experimental-reporters.nls"
]


;"lengnick-tests.nls" Jake/Jacob previously used this but I am removing it because I do not use it anymore
@#$#@#$#@
GRAPHICS-WINDOW
210
55
643
489
-1
-1
38.64
1
10
1
1
1
0
0
0
1
0
10
0
10
1
1
1
months
30.0

BUTTON
0
545
66
578
setup
stop-inspecting-dead-agents\nsetup
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
124
545
205
578
go-once
go\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
67
545
122
578
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
0

SLIDER
0
100
172
133
n-households
n-households
10
1000
500.0
10
1
NIL
HORIZONTAL

PLOT
220
495
420
643
Unemployment rate
NIL
unemployment
0.0
10.0
0.0
0.5
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot 1 - (count employment-links / count households)"
"mean unemployment" 1.0 0 -1184463 true "" "plot mean UNEMPLOYMENT-RATES"

PLOT
652
10
975
180
Wage Rate Stats 
NIL
NIL
0.0
10.0
0.0
5.0
true
true
"set-plot-y-range (MIN-WAGE-RATE * 0.9) precision (mean [tech-parameter] of firms * 1.1) 1" ""
PENS
"mean firm wage" 1.0 0 -16777216 true "" "plot mean [wage-rate] of firms"
"min wage" 1.0 0 -7500403 true "" "plot min [wage-rate] of firms"
"mean res-wage" 1.0 0 -13345367 true "" "plot mean [reservation-wage] of households"
"max wage" 1.0 0 -14439633 true "" "plot max [wage-rate] of firms"
"med firm wage" 1.0 0 -2674135 true "" "plot median [wage-rate] of firms"
"MIN-WAGE-RATE" 1.0 0 -2064490 true "" "plot MIN-WAGE-RATE"
"Labor Value" 1.0 0 -955883 true "" "plot mean [tech-parameter * price] of PRIMARY-GOOD-FIRMS\n; we only use primary good firms here because they are fully value add\n; that way we don't need to subract the cost of inputs to find value of labor"

PLOT
855
495
1055
645
Worker Per Firm Distribution
NIL
NIL
0.0
40.0
0.0
20.0
true
false
"" "set-plot-x-range 0 max [n-workers] of firms\nset-plot-y-range 0 10"
PENS
"default" 1.0 1 -16777216 true "" "histogram [n-workers] of firms"

BUTTON
983
117
1077
150
hide-links
ask links [hide-link]
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
983
10
1145
43
show random firm's links
ask links [hide-link]\nask one-of firms [ask my-links [show-link]]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
650
495
850
645
Household Liquidity Distribution
NIL
NIL
0.0
100.0
0.0
10.0
true
false
"" "set-plot-x-range 0 max [liquidity] of households\nset-plot-y-range 0 30\n"
PENS
"default" 1.0 1 -16777216 true "" "histogram [liquidity] of households"

PLOT
1060
187
1334
337
Mean Price
NIL
NIL
0.0
10.0
0.98
1.02
true
true
"" ""
PENS
"cg-firms" 1.0 0 -5509967 true "" "plot mean [price] of CONSUMER-GOOD-FIRMS"
"pg-firms" 1.0 0 -5207188 true "" "plot mean [price] of PRIMARY-GOOD-FIRMS"

BUTTON
1040
150
1113
183
bmonth-f
go-beginning-of-month-firms\n
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
1194
150
1289
183
go-month
go-month\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
855
185
1055
335
Monthly Firm Turnover
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
"default" 1.0 0 -16777216 true "" "plot (count firms with [color = yellow] / n-firms)"

PLOT
1340
340
1540
490
Mean Demand Not Satisfied
NIL
NIL
0.0
10.0
0.0
0.1
true
false
"" ""
PENS
"Consumers" 1.0 0 -13345367 true "" "plot mean [demand-not-satisfied] of consumer-links"
"Consumer firms" 1.0 0 -5509967 true "" "plot mean [demand-not-satisfied] of framework-agreements"

PLOT
650
185
850
335
Inventory
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
"consumer firms" 1.0 0 -5509967 true "" "plot mean [inventory] of CONSUMER-GOOD-FIRMS"
"primary firms" 1.0 0 -6459832 true "" "plot mean [inventory] of PRIMARY-GOOD-FIRMS "
"consumer firm stock " 1.0 0 -14333415 true "" "plot mean [FIRM.current-stock 2] of CONSUMER-GOOD-FIRMS"

BUTTON
983
150
1038
183
dsetup
\nrandom-seed 1\nsetup\nstop-inspecting-dead-agents\ninspect firm 1050\nupdate-plots
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
1290
150
1434
183
go-end-of-month
go-end-of-month\ntick\n
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
1115
150
1192
183
bmonth-h
go-beginning-of-month-households\n
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
0
167
170
200
transactions-per-month
transactions-per-month
1
21
1.0
1
1
NIL
HORIZONTAL

PLOT
1061
494
1335
644
Output and Demand
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"demand" 1.0 0 -13791810 true "" "plot sum [demanded-consumption * transactions-per-month] of households "
"cg-output" 1.0 0 -5509967 true "" "plot sum [FIRM.max-production] of CONSUMER-GOOD-FIRMS"
"pg-output" 1.0 0 -6459832 true "" "plot sum [4 * FIRM.max-production] of PRIMARY-GOOD-FIRMS"

PLOT
1061
341
1335
491
Mean Liquidity
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"primary-firm" 1.0 0 -6459832 true "" "plot mean [liquidity] of PRIMARY-GOOD-FIRMS"
"household" 1.0 0 -13345367 true "" "plot mean [liquidity] of households"
"mean-liquidity" 1.0 0 -955883 true "" "plot mean [liquidity] of (turtle-set households firms)"
"consumer-firm" 1.0 0 -5509967 true "" "plot mean [liquidity] of CONSUMER-GOOD-FIRMS"

BUTTON
983
46
1144
79
show largest firm's links
ask links [hide-link]\nask firms with-max [liquidity] [ask my-links [show-link]]
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
983
82
1143
115
show smallest firm's links
ask links [hide-link]\nask firms with-min [liquidity] [ask my-links [show-link]]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
890
205
1033
250
Firms Added This Month
count firms with [color = yellow]
4
1
11

PLOT
855
340
1054
490
Total Bankrupt Firms
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
"default" 1.0 0 -16777216 true "" "plot TOTAL-BANKRUPT-FIRMS"

CHOOSER
0
10
133
55
setup-structure
setup-structure
"single-firm" "two-layer" "three-layer" "diamond" "looped-diamond"
1

MONITOR
1186
10
1333
55
# Primary Good Firms
count PRIMARY-GOOD-FIRMS
17
1
11

MONITOR
1186
57
1332
102
# Intermediate Good Firms
count INTERMEDIATE-GOOD-FIRMS
17
1
11

MONITOR
1185
105
1331
150
# Consumer Good Firms
count CONSUMER-GOOD-FIRMS
17
1
11

SLIDER
0
132
172
165
n-firms
n-firms
10
500
30.0
10
1
NIL
HORIZONTAL

SLIDER
0
202
170
235
framework-duration
framework-duration
1
60
24.0
1
1
NIL
HORIZONTAL

CHOOSER
0
55
132
100
index-in-use
index-in-use
"no index" "coats" "pringle" "ussher" "potvin"
0

PLOT
430
495
635
645
Profitability
NIL
NIL
0.0
0.0
-100.0
-100.0
true
true
"" ""
PENS
"Bankrupt " 1.0 0 -1184463 true "" "if BANKRUPT-FIRM-PROFITS != [] [plotxy ticks mean BANKRUPT-FIRM-PROFITS]"
"In Business" 1.0 0 -16777216 true "" "plot mean [lifetime-profits] of firms"

SLIDER
0
235
205
268
mean-new-agreements-per-month
mean-new-agreements-per-month
0
10
2.0
0.1
1
NIL
HORIZONTAL

PLOT
1340
495
1540
645
Framework Agreements per Firm
NIL
NIL
0.0
20.0
0.0
10.0
true
false
"" "set-plot-x-range 0 count firms with [not consumer-good-firm?]\nset-plot-y-range 0 count firms with [not primary-good-firm?]\n"
PENS
"default" 1.0 1 -16777216 true "" "histogram [count my-in-framework-agreements] of CONSUMER-GOOD-FIRMS"

PLOT
650
340
850
490
average-previous-sales
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
"consumer-good" 1.0 0 -5509967 true "" "plot mean [average-previous-sales] of CONSUMER-GOOD-FIRMS"
"primary-good" 1.0 0 -6459832 true "" "plot mean [average-previous-sales] of PRIMARY-GOOD-FIRMS"

PLOT
1340
185
1540
335
Mean Framework Price
NIL
NIL
0.0
10.0
0.9
1.1
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [FIRM.framework-price] of framework-agreements"

TEXTBOX
210
10
495
31
Economic Petri Dish\n
16
0.0
1

TEXTBOX
210
35
360
53
https://ccl.northwestern.edu/
11
0.0
1

TEXTBOX
510
35
660
53
https://xalgorithms.org/
11
0.0
1

SLIDER
0
272
205
305
firm-memory-constant
firm-memory-constant
0
1
0.8
0.1
1
NIL
HORIZONTAL

SWITCH
0
345
215
378
fix-n-framework-agreements?
fix-n-framework-agreements?
1
1
-1000

SLIDER
0
305
172
338
layoff-probability
layoff-probability
0
1
0.5
0.01
1
NIL
HORIZONTAL

BUTTON
1335
105
1442
138
NIL
setup-crash
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
0
380
172
413
firm-competency
firm-competency
-1
1
0.0
0.1
1
NIL
HORIZONTAL

SWITCH
0
425
117
458
use-land?
use-land?
1
1
-1000

SLIDER
0
455
185
488
max-productive-capacity
max-productive-capacity
0
200
200.0
1
1
NIL
HORIZONTAL

SLIDER
0
495
185
528
primary-labor-elasticity
primary-labor-elasticity
.1
1
1.0
.1
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

- Give firms some knowledge of the prices and wages of other firms.
- Allow firms to go out of business and to be started and include population growth
- create innovation in technology

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

building store
false
0
Rectangle -7500403 true true 30 45 45 240
Rectangle -16777216 false false 30 45 45 165
Rectangle -7500403 true true 15 165 285 255
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 30 180 105 240
Rectangle -16777216 true false 195 180 270 240
Line -16777216 false 0 165 300 165
Polygon -7500403 true true 0 165 45 135 60 90 240 90 255 135 300 165
Rectangle -7500403 true true 0 0 75 45
Rectangle -16777216 false false 0 0 75 45

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

dollar bill
false
0
Rectangle -7500403 true true 15 90 285 210
Rectangle -1 true false 30 105 270 195
Circle -7500403 true true 120 120 60
Circle -7500403 true true 120 135 60
Circle -7500403 true true 254 178 26
Circle -7500403 true true 248 98 26
Circle -7500403 true true 18 97 36
Circle -7500403 true true 21 178 26
Circle -7500403 true true 66 135 28
Circle -1 true false 72 141 16
Circle -7500403 true true 201 138 32
Circle -1 true false 209 146 16
Rectangle -16777216 true false 64 112 86 118
Rectangle -16777216 true false 90 112 124 118
Rectangle -16777216 true false 128 112 188 118
Rectangle -16777216 true false 191 112 237 118
Rectangle -1 true false 106 199 128 205
Rectangle -1 true false 90 96 209 98
Rectangle -7500403 true true 60 168 103 176
Rectangle -7500403 true true 199 127 230 133
Line -7500403 true 59 184 104 184
Line -7500403 true 241 189 196 189
Line -7500403 true 59 189 104 189
Line -16777216 false 116 124 71 124
Polygon -1 true false 127 179 142 167 142 160 130 150 126 148 142 132 158 132 173 152 167 156 164 167 174 176 161 193 135 192
Rectangle -1 true false 134 199 184 205

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
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="single-firm_varying_firm_number" repetitions="1" runMetricsEveryStep="false">
    <setup>setup
repeat 200 [go]
set BANKRUPT-FIRM-PROFITS (list)
set ALL-FIRM-PROFITS (list)
set UNEMPLOYMENT-RATES (list)
set MEAN-PRICES (list)
set TOTAL-REVENUE 0
set TOTAL-BANKRUPT-FIRMS 0</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>TOTAL-BANKRUPT-FIRMS / n-firms</metric>
    <metric>mean UNEMPLOYMENT-RATES</metric>
    <metric>mean MEAN-PRICES</metric>
    <metric>mean ALL-FIRM-PROFITS</metric>
    <metric>mean BANKRUPT-FIRM-PROFITS</metric>
    <metric>TOTAL-REVENUE</metric>
    <steppedValueSet variable="n-firms" first="20" step="10" last="200"/>
    <enumeratedValueSet variable="transactions-per-month">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-households">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setup-structure">
      <value value="&quot;single-firm&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="index-in-use">
      <value value="&quot;no index&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="framework-duration">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-agreements-per-month">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="double-firm_low_firm_number" repetitions="1" runMetricsEveryStep="false">
    <setup>setup
repeat 200 [go]
set BANKRUPT-FIRM-PROFITS (list)
set ALL-FIRM-PROFITS (list)
set UNEMPLOYMENT-RATES (list)
set MEAN-PRICES (list)
set TOTAL-REVENUE 0
set TOTAL-BANKRUPT-FIRMS 0</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>TOTAL-BANKRUPT-FIRMS / n-firms</metric>
    <metric>mean UNEMPLOYMENT-RATES</metric>
    <metric>mean MEAN-PRICES</metric>
    <metric>mean ALL-FIRM-PROFITS</metric>
    <metric>mean BANKRUPT-FIRM-PROFITS</metric>
    <metric>TOTAL-REVENUE</metric>
    <steppedValueSet variable="n-firms" first="10" step="1" last="30"/>
    <enumeratedValueSet variable="transactions-per-month">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-households">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setup-structure">
      <value value="&quot;two-layer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="index-in-use">
      <value value="&quot;no index&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="framework-duration">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-agreements-per-month">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="double-firm_varying_firm_number" repetitions="1" runMetricsEveryStep="false">
    <setup>setup
repeat 200 [go]
set BANKRUPT-FIRM-PROFITS (list)
set ALL-FIRM-PROFITS (list)
set UNEMPLOYMENT-RATES (list)
set MEAN-PRICES (list)
set TOTAL-REVENUE 0
set TOTAL-BANKRUPT-FIRMS 0</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>TOTAL-BANKRUPT-FIRMS / n-firms</metric>
    <metric>mean UNEMPLOYMENT-RATES</metric>
    <metric>mean MEAN-PRICES</metric>
    <metric>mean ALL-FIRM-PROFITS</metric>
    <metric>mean BANKRUPT-FIRM-PROFITS</metric>
    <metric>TOTAL-REVENUE</metric>
    <steppedValueSet variable="n-firms" first="20" step="10" last="200"/>
    <enumeratedValueSet variable="transactions-per-month">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-households">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setup-structure">
      <value value="&quot;two-layer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="index-in-use">
      <value value="&quot;no index&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="framework-duration">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-agreements-per-month">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="single-firm_low_firm_number" repetitions="1" runMetricsEveryStep="false">
    <setup>setup
repeat 200 [go]
set BANKRUPT-FIRM-PROFITS (list)
set ALL-FIRM-PROFITS (list)
set UNEMPLOYMENT-RATES (list)
set MEAN-PRICES (list)
set TOTAL-REVENUE 0
set TOTAL-BANKRUPT-FIRMS 0</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>TOTAL-BANKRUPT-FIRMS / n-firms</metric>
    <metric>mean UNEMPLOYMENT-RATES</metric>
    <metric>mean MEAN-PRICES</metric>
    <metric>mean ALL-FIRM-PROFITS</metric>
    <metric>mean BANKRUPT-FIRM-PROFITS</metric>
    <metric>TOTAL-REVENUE</metric>
    <steppedValueSet variable="n-firms" first="10" step="1" last="30"/>
    <enumeratedValueSet variable="transactions-per-month">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-households">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setup-structure">
      <value value="&quot;single-firm&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="index-in-use">
      <value value="&quot;no index&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="framework-duration">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="new-agreements-per-month">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="single-firm_varying_memory_constant" repetitions="1" runMetricsEveryStep="false">
    <setup>setup
repeat 1000 [go]
set BANKRUPT-FIRM-PROFITS (list)
set ALL-FIRM-PROFITS (list)
set UNEMPLOYMENT-RATES (list)
set MEAN-PRICES (list)
set TOTAL-REVENUE 0
set TOTAL-BANKRUPT-FIRMS 0</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>TOTAL-BANKRUPT-FIRMS / n-firms</metric>
    <metric>mean UNEMPLOYMENT-RATES</metric>
    <metric>mean MEAN-PRICES</metric>
    <metric>mean [lifetime-profits] of firms</metric>
    <metric>mean BANKRUPT-FIRM-PROFITS</metric>
    <metric>TOTAL-REVENUE</metric>
    <enumeratedValueSet variable="n-firms">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transactions-per-month">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-households">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setup-structure">
      <value value="&quot;single-firm&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="index-in-use">
      <value value="&quot;no index&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="framework-duration">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-new-agreements-per-month">
      <value value="1"/>
    </enumeratedValueSet>
    <steppedValueSet variable="firm-memory-constant" first="0" step="0.1" last="0.9"/>
  </experiment>
  <experiment name="double-firm_varying_framework_duration" repetitions="1" runMetricsEveryStep="false">
    <setup>setup
repeat 1000 [go]
set BANKRUPT-FIRM-PROFITS (list)
set UNEMPLOYMENT-RATES (list)
set MEAN-PRICES (list)
set TOTAL-BANKRUPT-FIRMS 0</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>TOTAL-BANKRUPT-FIRMS / n-firms</metric>
    <metric>mean UNEMPLOYMENT-RATES</metric>
    <metric>mean MEAN-PRICES</metric>
    <metric>standard-deviation MEAN-PRICES</metric>
    <metric>mean [lifetime-profits] of firms</metric>
    <metric>mean BANKRUPT-FIRM-PROFITS</metric>
    <enumeratedValueSet variable="n-firms">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transactions-per-month">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-households">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setup-structure">
      <value value="&quot;two-layer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="index-in-use">
      <value value="&quot;no index&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-new-agreements-per-month">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="firm-memory-constant">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-new-agreements-per-month">
      <value value="2"/>
    </enumeratedValueSet>
    <steppedValueSet variable="framework-duration" first="1" step="1" last="10"/>
  </experiment>
  <experiment name="economy-crash-experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2000"/>
    <exitCondition>crashed?</exitCondition>
    <metric>crashed?</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="layoff-probability">
      <value value="0"/>
      <value value="0.1"/>
      <value value="0.2"/>
      <value value="0.3"/>
      <value value="0.4"/>
      <value value="0.5"/>
      <value value="0.6"/>
      <value value="0.7"/>
      <value value="0.8"/>
      <value value="0.9"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="firm-memory-constant">
      <value value="0"/>
      <value value="0.1"/>
      <value value="0.2"/>
      <value value="0.3"/>
      <value value="0.4"/>
      <value value="0.5"/>
      <value value="0.6"/>
      <value value="0.7"/>
      <value value="0.8"/>
      <value value="0.9"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-firms">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="index-in-use">
      <value value="&quot;no index&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-households">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transactions-per-month">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setup-structure">
      <value value="&quot;two-layer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fix-n-framework-agreements?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-new-agreements-per-month">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="framework-duration">
      <value value="24"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="baseline-run-no-land" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3000"/>
    <metric>unemployment-rate</metric>
    <metric>mean-price-all-firms</metric>
    <metric>mean-consumer-demand-not-satisfied</metric>
    <metric>total-sales</metric>
    <metric>mean-current-profit-all-firms</metric>
    <metric>mean-lifetime-profit-all-firms</metric>
    <metric>turnover-rate</metric>
    <metric>bankrupt-firms</metric>
    <metric>household-wealth-concentration</metric>
    <metric>mean-age</metric>
    <metric>mean-inventories</metric>
    <enumeratedValueSet variable="use-land?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-productive-capacity">
      <value value="210"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="layoff-probability">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-firms">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="index-in-use">
      <value value="&quot;no index&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="firm-competency">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transactions-per-month">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-households">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setup-structure">
      <value value="&quot;two-layer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-new-agreements-per-month">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fix-n-framework-agreements?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="firm-memory-constant">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="framework-duration">
      <value value="24"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Varying-productivity" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="3000"/>
    <metric>unemployment-rate</metric>
    <metric>mean-price-all-firms</metric>
    <metric>mean-consumer-demand-not-satisfied</metric>
    <metric>total-sales</metric>
    <metric>mean-current-profit-all-firms</metric>
    <metric>mean-lifetime-profit-all-firms</metric>
    <metric>turnover-rate</metric>
    <metric>bankrupt-firms</metric>
    <metric>household-wealth-concentration</metric>
    <metric>mean-age</metric>
    <metric>mean-inventories</metric>
    <enumeratedValueSet variable="use-land?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-productive-capacity">
      <value value="10"/>
      <value value="20"/>
      <value value="30"/>
      <value value="40"/>
      <value value="50"/>
      <value value="60"/>
      <value value="70"/>
      <value value="80"/>
      <value value="90"/>
      <value value="100"/>
      <value value="110"/>
      <value value="120"/>
      <value value="130"/>
      <value value="140"/>
      <value value="150"/>
      <value value="160"/>
      <value value="170"/>
      <value value="180"/>
      <value value="190"/>
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="layoff-probability">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-firms">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="index-in-use">
      <value value="&quot;no index&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="firm-competency">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transactions-per-month">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-households">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="setup-structure">
      <value value="&quot;two-layer&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-new-agreements-per-month">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fix-n-framework-agreements?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="firm-memory-constant">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="framework-duration">
      <value value="24"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
1
@#$#@#$#@
