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
  "_nls_files/stats-reporters.nls"
]


;"lengnick-tests.nls" Jake/Jacob previously used this but I am removing it because I do not use it anymore
@#$#@#$#@
GRAPHICS-WINDOW
225
60
653
489
-1
-1
38.2
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
440
66
473
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
440
205
473
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
440
122
473
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
110
125
143
n-households
n-households
10
1000
1000.0
10
1
NIL
HORIZONTAL

PLOT
665
170
940
318
Unemployment rate
NIL
unemployment
0.0
10.0
0.0
0.5
true
true
"" ""
PENS
"current" 1.0 0 -16777216 true "" "plot 1 - (count employment-links / count households)"
"mean " 1.0 0 -7500403 true "" "plot mean UNEMPLOYMENT-RATES"

PLOT
665
10
988
170
Wage Rate Stats 
NIL
NIL
0.0
10.0
0.0
5.0
true
true
"set-plot-y-range (MIN-WAGE-RATE * 1.1) (MIN-WAGE-RATE * 2)" ""
PENS
"mean cg-wage" 1.0 0 -10899396 true "" "plot mean-cg-wage-rate"
"mean pg-wage" 1.0 0 -6459832 true "" "plot mean-pg-wage-rate"
"mean res-wage" 1.0 0 -13345367 true "" "plot mean [reservation-wage] of households "
"mean wage" 1.0 0 -2674135 true "" "plot mean [wage-rate] of firms"
"MIN-WAGE-RATE" 1.0 0 -2064490 true "" "plot MIN-WAGE-RATE"
"max firm wage" 1.0 0 -7500403 true "" "plot max [wage-rate] of firms"
"min firm wage" 1.0 0 -8630108 true "" "plot min [wage-rate] of firms"
"labor value" 1.0 0 -955883 true "" "plot pg-labor-value"

PLOT
1300
370
1500
490
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

PLOT
190
495
405
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
665
320
950
470
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

PLOT
1300
130
1500
250
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
990
320
1290
470
Mean Demand Not Satisfied
NIL
NIL
0.0
10.0
0.0
0.1
true
true
"" ""
PENS
"households" 1.0 0 -13345367 true "" "plot mean [demand-not-satisfied] of consumer-links"
"cg-firms" 1.0 0 -5509967 true "" "plot mean [demand-not-satisfied] of framework-agreements"

PLOT
990
165
1275
315
Inventory
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
"cg-firms" 1.0 0 -5509967 true "" "plot mean [inventory] of CONSUMER-GOOD-FIRMS"
"pg-firms" 1.0 0 -6459832 true "" "plot mean [inventory] of PRIMARY-GOOD-FIRMS "

SLIDER
670
815
840
848
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
665
475
960
625
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
"cg-output" 1.0 0 -5509967 true "" "plot cg-production"
"pg-output" 1.0 0 -6459832 true "" "plot pg-production ;; to line up, need to multiply by the marginal productivity of one unit of pg for one unit of cg\n"
"demand" 1.0 0 -13345367 true "" "plot consumer-demand"

PLOT
410
495
655
645
Total Liquidity
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
"pg-firms" 1.0 0 -6459832 true "" "plot sum [liquidity] of PRIMARY-GOOD-FIRMS"
"household" 1.0 0 -13345367 true "" "plot sum [liquidity] of households"
"cg-firms" 1.0 0 -5509967 true "" "plot sum [liquidity] of CONSUMER-GOOD-FIRMS"
"total" 1.0 0 -7500403 true "" "plot sum [liquidity] of (turtle-set households firms)"

MONITOR
1415
150
1490
195
This Month
count firms with [color = yellow]
4
1
11

PLOT
1300
10
1499
130
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
220
55
setup-structure
setup-structure
"Single-CG-Firm-TC=3.json" "Single-PG&CG-TC=1.json" "Single-PG&CG-TC=2.json" "Single-PG&CG-TC=3.json" "Two-Layer-.25PG-to-1CG.json" "Two-Layer-.5PG-to-1CG.json" "Two-Layer-1PG-to-1CG.json"
3

MONITOR
225
10
295
55
# pg-firms
count PRIMARY-GOOD-FIRMS
17
1
11

MONITOR
300
10
370
55
# ig-firms
count INTERMEDIATE-GOOD-FIRMS
17
1
11

MONITOR
375
10
445
55
# cg-firms
count CONSUMER-GOOD-FIRMS
17
1
11

SLIDER
125
110
217
143
n-firms
n-firms
10
100
60.0
5
1
NIL
HORIZONTAL

SLIDER
0
1465
170
1498
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
60
132
105
index-in-use
index-in-use
"no index" "coats" "pringle" "ussher" "potvin"
0

PLOT
1300
250
1500
370
lifetime  profits
NIL
NIL
0.0
0.0
-100.0
-100.0
true
false
"" ""
PENS
"Bankrupt " 1.0 0 -2674135 true "" "if BANKRUPT-FIRM-PROFITS != [] [plotxy ticks mean BANKRUPT-FIRM-PROFITS]"
"In Business" 1.0 0 -16777216 true "" "plot mean [lifetime-profits] of firms"

SLIDER
0
1495
215
1528
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
1525
165
1725
315
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
990
10
1275
160
average-previous-sales
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
"cg-firms" 1.0 0 -5509967 true "" "plot mean [average-previous-sales] of CONSUMER-GOOD-FIRMS"
"pg-firms" 1.0 0 -6459832 true "" "plot mean [average-previous-sales] of PRIMARY-GOOD-FIRMS"

PLOT
1525
10
1725
160
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

SLIDER
0
1025
175
1058
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
1530
215
1563
fix-n-framework-agreements?
fix-n-framework-agreements?
1
1
-1000

SLIDER
0
1065
172
1098
layoff-probability
layoff-probability
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
0
180
215
213
firm-competency
firm-competency
-1
1
0.0
0.1
1
NIL
HORIZONTAL

SLIDER
0
210
215
243
max-prod-capacity-per-capita
max-prod-capacity-per-capita
0.1
10
1.0
.1
1
NIL
HORIZONTAL

SLIDER
0
1410
105
1443
alpha
alpha
.1
1
1.0
.1
1
NIL
HORIZONTAL

SLIDER
0
1375
105
1408
s
s
.01
.3
0.1
.01
1
NIL
HORIZONTAL

CHOOSER
0
1330
207
1375
primary-good-prod-function
primary-good-prod-function
"linear" "asymptotic" "Cobb-Douglas"
0

TEXTBOX
115
1375
210
1405
only relevant for asymptotic prod
11
0.0
1

TEXTBOX
115
1410
205
1440
only relevant for Cobb-Douglas
11
0.0
1

TEXTBOX
0
1450
150
1468
framework settings
11
105.0
1

TEXTBOX
0
810
150
828
general firm settings
11
105.0
1

TEXTBOX
0
1310
150
1328
primary good firm settings
11
105.0
1

PLOT
0
495
185
645
gini-coefficient
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
"default" 1.0 0 -16777216 true "" "plot gini-coefficient"

SLIDER
0
265
172
298
MIN-WAGE-RATE
MIN-WAGE-RATE
.1
10
2.5
.1
1
NIL
HORIZONTAL

SLIDER
0
380
225
413
DIMINISHING-UTILITY-CONSTANT
DIMINISHING-UTILITY-CONSTANT
.1
1
0.5
.05
1
NIL
HORIZONTAL

SWITCH
0
300
220
333
min-wage-80%-of-tech-param?
min-wage-80%-of-tech-param?
1
1
-1000

TEXTBOX
0
335
215
361
Overrides minimum-wage slider if true
11
0.0
1

PLOT
665
630
945
780
Indices
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
"pringle " 1.0 0 -16777216 true "" "plot pringle-index-value"
"coats" 1.0 0 -7500403 true "" "plot coats-index-value"
"ussher" 1.0 0 -2674135 true "" "plot ussher-index-value"
"potvin" 1.0 0 -955883 true "" "plot potvin-index-value"

TEXTBOX
0
755
560
775
Constants that I don't really touch, but want to be able to adjust easily if needed
14
0.0
1

INPUTBOX
0
830
140
890
MAX-WAGE-CHANGE
0.2
1
0
Number

TEXTBOX
140
835
270
891
max amount a firm can increase/decrease their wage (default=0.2)
11
0.0
1

PLOT
990
475
1270
625
mean desired vs actual workers
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
"desired" 1.0 0 -2674135 true "" "plot mean [desired-n-workers] of firms"
"actual" 1.0 0 -13345367 true "" "plot mean [n-workers] of firms"

INPUTBOX
0
895
140
955
MAX-PRICE-CHANGE
0.05
1
0
Number

TEXTBOX
145
900
270
956
max amount a firm can increase/decrease prices (default=.05)\n
11
0.0
1

INPUTBOX
0
960
160
1020
BUFFER-LABOR-FRACTION
0.3
1
0
Number

TEXTBOX
165
970
315
1011
the fraction of labor costs firms keep as a buffer before distributing profits
11
0.0
1

PLOT
1300
490
1500
620
desired worker change
NIL
NIL
-10.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [desired-n-workers - n-workers] of firms"
"pen-1" 1.0 0 -7500403 true "" "plotxy 0.5 0 plotxy 0.5 30"

TEXTBOX
0
790
150
808
Firm Constants
12
0.0
1

TEXTBOX
365
790
515
808
Household constants
13
0.0
1

TEXTBOX
0
250
150
268
Firm settings
11
105.0
1

TEXTBOX
5
365
155
383
Household settings
11
105.0
1

TEXTBOX
675
790
825
808
General constants
11
0.0
1

TEXTBOX
0
160
150
178
pg-firm / land settings
11
105.0
1

SLIDER
365
810
542
843
RES-WAGE-CHANGE
RES-WAGE-CHANGE
.1
1
0.9
.1
1
NIL
HORIZONTAL

INPUTBOX
365
845
475
905
SEARCH-N
5.0
1
0
Number

TEXTBOX
480
855
605
911
Number of firms to try when unemployed (β in Lengnick = 5)
11
0.0
1

SLIDER
365
910
580
943
SEARCH-BETTER-JOB-PROB
SEARCH-BETTER-JOB-PROB
0
1
0.1
.1
1
NIL
HORIZONTAL

SLIDER
0
1105
180
1138
MONTHS-TO-LOWER-WAGE
MONTHS-TO-LOWER-WAGE
1
24
12.0
1
1
NIL
HORIZONTAL

TEXTBOX
185
1100
335
1141
after this many months of having all positions filled, a firm will decrease wages  
11
0.0
1

SLIDER
365
945
580
978
PROB-REPLACE-FIRM-PRICE
PROB-REPLACE-FIRM-PRICE
0
1
0.25
.05
1
NIL
HORIZONTAL

TEXTBOX
585
950
810
980
probability of switching trading firms to a new firm with a better price
11
0.0
1

SLIDER
365
980
580
1013
PROB-REPLACE-FIRM-QUANT
PROB-REPLACE-FIRM-QUANT
0
1
0.5
.1
1
NIL
HORIZONTAL

TEXTBOX
585
985
805
1026
probability of switching trading firms based on lack of quantity
11
0.0
1

SLIDER
365
1015
580
1048
N-TRADING-LINKS
N-TRADING-LINKS
1
10
7.0
1
1
NIL
HORIZONTAL

TEXTBOX
585
1015
810
1056
number of firms contacted by consumers trying to buy consumer goods
11
0.0
1

SLIDER
0
1140
180
1173
N-FRAMEWORK-AGREEMENTS
N-FRAMEWORK-AGREEMENTS
1
10
7.0
1
1
NIL
HORIZONTAL

TEXTBOX
185
1145
345
1186
number of firms contacted by non-pg-firms to buy inputs
11
0.0
1

INPUTBOX
365
1055
512
1115
STARTUP-LIQUIDITY
100.0
1
0
Number

TEXTBOX
545
1065
695
1091
Households start with this much liquidity
11
0.0
1

TEXTBOX
360
1270
510
1288
Land Constants
13
0.0
1

INPUTBOX
355
1290
530
1350
BACKGROUND-IMPROVEMENT
10
1
0
String

TEXTBOX
540
1305
750
1345
the background improvement on each land's productive capacity per tick 
11
0.0
1

SLIDER
0
1175
180
1208
DESIRED-BUFFER-FRAC
DESIRED-BUFFER-FRAC
0
1
0.5
.1
1
NIL
HORIZONTAL

TEXTBOX
185
1180
335
1206
the desired buffer as a fraction of expected sales. 
11
0.0
1

BUTTON
445
10
540
43
inspect overpaying firm
inspect min-one-of firms [liquidity - (wage-rate * desired-n-workers)]
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
1215
180
1248
INITIAL-CONSUMER-LINKS
INITIAL-CONSUMER-LINKS
0
20
20.0
1
1
NIL
HORIZONTAL

PLOT
1520
370
1720
490
customers per firm 
NIL
NIL
0.0
400.0
0.0
10.0
true
false
"" ""
PENS
"default" 10.0 1 -16777216 true "" "histogram [count my-consumer-links] of consumer-good-firms"

SWITCH
365
1125
602
1158
delli-gatti-consumer-search?
delli-gatti-consumer-search?
0
1
-1000

SWITCH
365
1165
547
1198
pick-cheapest-firm?
pick-cheapest-firm?
0
1
-1000

SLIDER
0
1255
180
1288
BUFFER%-TO-LOWER-PRICE
BUFFER%-TO-LOWER-PRICE
1
1.5
1.2
.01
1
NIL
HORIZONTAL

TEXTBOX
185
1220
335
1255
# of consumer links new firms are given
11
0.0
1

TEXTBOX
185
1255
345
1280
Buffer fraction excess before a firm will lower prices
11
0.0
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
  <experiment name="vary-prod-capacity" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>stop?</exitCondition>
    <metric>unemployment-rate</metric>
    <metric>mean-consumer-demand-not-satisfied</metric>
    <metric>mean-firm-demand-not-satisfied</metric>
    <metric>total-sales</metric>
    <metric>cg-production</metric>
    <metric>consumer-demand</metric>
    <metric>mean-wage-rate</metric>
    <metric>mean-cg-price</metric>
    <metric>mean-pg-price</metric>
    <metric>mean-current-profit-all-firms</metric>
    <metric>mean-lifetime-profit-all-firms</metric>
    <metric>turnover-rate</metric>
    <metric>bankrupt-firms</metric>
    <metric>mean-age</metric>
    <metric>mean-inventories</metric>
    <metric>pringle-index-value</metric>
    <metric>coats-index-value</metric>
    <metric>ussher-index-value</metric>
    <metric>potvin-index-value</metric>
    <metric>gini-coefficient</metric>
    <enumeratedValueSet variable="setup-structure">
      <value value="&quot;Single-PG&amp;CG-TC=3.json&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-prod-capacity-per-capita">
      <value value="0.5"/>
      <value value="1"/>
      <value value="2"/>
      <value value="2.5"/>
      <value value="3"/>
      <value value="3.5"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="8"/>
      <value value="10"/>
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MIN-WAGE-RATE">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DIMINISHING-UTILITY-CONSTANT">
      <value value="0.5"/>
      <value value="0.7"/>
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pick-cheapest-firm?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="delli-gatti-consumer-search?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N-TRADING-LINKS">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MONTHS-TO-LOWER-WAGE">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="layoff-probability">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-households">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="n-firms">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SEARCH-N">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fix-n-framework-agreements?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PROB-REPLACE-FIRM-PRICE">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="framework-duration">
      <value value="24"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MAX-PRICE-CHANGE">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="index-in-use">
      <value value="&quot;no index&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SEARCH-BETTER-JOB-PROB">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean-new-agreements-per-month">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="firm-memory-constant">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="min-wage-80%-of-tech-param?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="STARTUP-LIQUIDITY">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="primary-good-prod-function">
      <value value="&quot;linear&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="transactions-per-month">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DESIRED-BUFFER-FRAC">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RES-WAGE-CHANGE">
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N-FRAMEWORK-AGREEMENTS">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="s">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="BUFFER-LABOR-FRACTION">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="firm-competency">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MAX-WAGE-CHANGE">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PROB-REPLACE-FIRM-QUANT">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="BACKGROUND-IMPROVEMENT">
      <value value="&quot;10&quot;"/>
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
