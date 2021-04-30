;;; THINGS THAT MIGHT BE OFF
; - it could be that dividing dividends based off of current wealth leads to an instability eventually

extensions [rnd table]
__includes["lengnick-tests.nls" "unit testing.nls"]

breed [households household]
breed [firms firm]
undirected-link-breed [consumer-links consumer-link]
undirected-link-breed [employment-links employment-link]
directed-link-breed [framework-agreements framework-agreement] ;adjust these procedures too

turtles-own [
  liquidity  ; i.e. money currently available (m_h for households and m_f for firms in Lengnick )
]

households-own [
  reservation-wage  ; minimal claom on labor income, although households will work for less under certain conditions  (w_h in  Lengnick)
  daily-consumption ; c_h^r / 21 in Lengnick
]

firms-own [
  firm-type ; # a label for the firm
  input-data ; the firm types and productivity that firms need to buy from
  inventory  ; # amount of goods stored and ready to be sold (i_f in Lengnick)
  price  ; the price of goods (p_f in Lengnick)
  wage-rate ; w_f in Lengnick
  ; desired-labor-change  ; 1 if the firm wants to hire, -1 if it wants to fire, 0 otherwise
  ;months-with-all-positions-filled  ; keeps track of how many full months the firm has gone without an unfilled position

  last-open-position  ; the month that the firm last had an open position
  filled-position?  ; if the firm had an open position last month, whether or not it was filled

  open-position?  ; trying to hire?
  close-position?  ; firing at the end of the month?

  demand  ; the most recent demand this firm experienced for its goods
  tech-parameter  ; This multiplies the number of workers to determine how much inventory is produced (lambda in Lengnick)
  consumer?
]

consumer-links-own [
  demand-not-satisfied
]

framework-agreements-own[
  input-firm-type
  demand-not-satisfied
]

globals [
  month
  month-length  ; 21 to reflect number of business days
  PROFITS-TO-ALLOCATE
  MIN-WAGE-RATE
  FIRM-STRUCTURE
  δ
  γ
  ν
  θ
  ϕl
  ϕu
  φlb
  φub
  χ
  α
  Ψprice
  Ψquant
  ξ
]

to set-constants
  set δ 0.019  ; δ in Lengnick: max amount wages are increased or decreased by (his code has .02)
  set γ 12  ; γ in Lengnick: after this many months of having all positions filled, a firm will decrease wages
  set ν 0.02 ;  0.02 is ν from Lengnick: the max amount a firm increases/decreases prices by
  set θ 0.75  ; θ in Lengnick: Prob that a firm changes prices, when the price is outside their range
  set ϕl 0.25  ; ϕ_lowerbar in lengnick: if inventory is below this fraction of demand, the firm tries to hire
  set ϕu 1 ; ϕ_upperbar in lengnick: if inventory is above this fraction of demand, the firm fires a worker
  set φlb 1.025  ; φ_lowerbar in lengnick: if price is below this fraction of marginal-costs (along with other conditions) increase price
  set φub 1.15  ; φ_upperbar in Lengnick: if price is above this fraction of marginal-costs (along with other conditions), decrease price
  set χ 0.1  ; χ in Lengnick: the fraction of labor costs to keep as a buffer  (in the future this could be a firm specific parameter depending on the firm's risk/aggression)
  set α .9  ; α in Lengnick: the decay rate of how much wealth is used on consumption by households
  set Ψprice 0.25  ;this is Ψprice in Lengnick, the probability of switching trading firms based on price
  set Ψquant 0.25  ;this is Ψquant in Lengnick, the probability of switching trading firms based on lack of quantity
  set ξ 0.01  ; A firm will switch firms based on price if the new firm is at least this fraction cheaper
  set month-length 21
  set FIRM-STRUCTURE table:get (table:from-json-file "Firm-structure.json") "Firms"
end

to setup
  ca

  set-constants
  set MIN-WAGE-RATE 0
  let n-trading-links 7

  create-households n-households [
    set shape "circle" ; "person"
    set heading 0
    rt (who - n-firms) * (360 / n-households)
    fd 11 + random 5
    set color blue

    set liquidity 98.78  ; arbitrary initial condition taken from Nardin - I tried starting everyone with two months of wages in bank, but didn't work so well
    set-house-size
  ]


  setup-firms
  initialize-framework-agreements
  ask households[
    create-consumer-links-with n-of n-trading-links firms with [consumer?][
      init-consumer-link
    ]
    if count my-employment-links = 0 [create-employment-link-with one-of firms [init-employment-link]]  ; households that didn't get employed when firms were created get employed
    set reservation-wage [wage-rate] of my-employer
    set-consumption  ; this has to be set after households have trading connections to calculate mean price
  ]

  ask firms [  ; these parameters are set after the creation of households and creating of links so they can be estimated from the firm's current size
    set-size
    set liquidity decide-reserve  ; model begins at the beginning of a month, so start with the buffer amount
    ; set months-with-all-positions-filled 2  ; arbitrary. Want it to be > 0 so they don't try to immediately lower wage
    set last-open-position -2 * γ  ; arbitrarily set > γ so firms don't try to immediately lower wage
    set filled-position? false  ; just needs to be set to a boolean
    set open-position?  false  ; not trying to hire immediately by default
    set close-position? false  ; not firing immediately by default
    if consumer? [
      set demand (ideal-consumption wage-rate price) * (count consumer-link-neighbors / n-trading-links)  ; estimate demand from current trading-links (this will get set to 0 on tick 1, but it used to set initially inventory)
      set inventory 50 ; I tried (.5 * demand) to start with inventory such that firms won't want to hire or fire on the first tick, but didn't seem to work
      set-daily-input-demands
    ]
  ]

  ask one-of firms [ask my-links [show-link]]
  reset-ticks
  tick
end


to setup-firms
  foreach FIRM-STRUCTURE[ f ->
    let group table:get f "Firm type"
    let num-firms table:get f "Firm count"
    let firm-input-data generate-input-data table:get f "Input data"
    let firm-tech-parameter table:get f "Tech constant"
    let is-consumer? table:get f "Consumer?"
    create-firms num-firms[
      set shape "building store"
      set heading 0
      rt who * (360 / n-firms)
      fd 2 + random 6
      set color brown
      set tech-parameter firm-tech-parameter ; λ in Lengnick
      set price 1 * small-random-change ; arbitrary, set to 1 for convenience
      set firm-type group
      set input-data firm-input-data
      set wage-rate 52 * small-random-change ; this was taken from https://sim4edu.com/sims/20/ ; start with same wage rate as reservation wage
      create-employment-link-with one-of households with [count my-employment-links = 0] [init-employment-link]
      set consumer? is-consumer?
    ]
  ]
end

to-report generate-input-data [original-data]
  ifelse original-data = "None"[
    report "None"
  ][
    let data-table table:make
    foreach original-data [i ->
      let inputi table:make
      table:put inputi "Marginal productivity" (table:get i "Marginal productivity")
      table:put inputi "Current stock" 0
      table:put inputi "Daily demand" 0
      table:put data-table (table:get i "Input firm type") inputi
    ]
    report data-table
  ]
end

to initialize-framework-agreements
  ask firms with [input-data != "None"][
    foreach table:keys input-data[i ->
      let num-agreements 5
      if any? firms with [firm-type = i and n-out-agreements = 0][
        set num-agreements num-agreements - 1
        create-framework-agreement-from one-of firms with [firm-type = i and n-out-agreements = 0][
          init-framework-agreement i
        ]
      ]
      let current-firm self
      ask n-of num-agreements firms with [firm-type = i and not out-framework-agreement-neighbor? self][
        create-framework-agreement-to current-firm[
          init-framework-agreement i
        ]
      ]
    ]
  ]
end

to initialize-input-firm-demands
  let firm-types (list)
  let firms-done-setting-demand (list)
  let firms-ready-to-set-demand (list)
  foreach FIRM-STRUCTURE[t ->
    set firm-types fput table:get t "Firm type" firm-types
    if table:get t "Consuemr?"[
      set firms-done-setting-demand fput table:get t "Firm type" firms-done-setting-demand
      let input-firms table:get t "Input data"
      foreach input-firms[f ->
        set firms-ready-to-set-demand fput table:get f "Input firm type" firms-ready-to-set-demand
      ]
    ]
  ]
  let finished? false
  while [not finished?][
    let new-ready-firms (list)
    foreach firms-ready-to-set-demand [f ->
      let aggregate-monthly-quantity-demanded 0
      ask firms with [uses-input? f][
        set aggregate-monthly-quantity-demanded (aggregate-monthly-quantity-demanded + (month-length * (daily-input-demand f)))
      ]
      ;******* This next part of the procedure is definitely up for debate on how to implement **********
      let average-demand (aggregate-monthly-quantity-demanded / (count firms with [firm-type = f]))
      ask firms with [firm-type = f][
        set demand (average-demand * (1 + (random-float 0.25)))
        set-daily-input-demands
      ]
      set firms-done-setting-demand fput f firms-done-setting-demand
      set firms-ready-to-set-demand remove f firms-ready-to-set-demand
      let global-firm-data item 0 (filter [i -> table:get "Firm-type" i = f] FIRM-STRUCTURE)
      let firm-input-data table:get global-firm-data "Input data"
      if firm-input-data != "None"[
        foreach firm-input-data[i ->
          set new-ready-firms fput i new-ready-firms
        ]
      ]
    ]
    ifelse (length firms-done-setting-demand = length firm-types) or (length new-ready-firms = 0)[
      set finished? true
    ][
      set firms-ready-to-set-demand new-ready-firms
    ]
  ]
end

to-report small-random-change
  report (1 + (random-float 1 - 0.5) / 50)
end

to init-consumer-link
  hide-link
end


to set-size
  set size (count employment-link-neighbors / 10) ; sqrt (count employment-link-neighbors / 3)
end

to set-house-size
  set size .2 + (sqrt (abs liquidity) / 12)
end

to init-employment-link
  set color blue
  hide-link
end

to init-framework-agreement [input-type]
  set input-firm-type input-type
  set demand-not-satisfied 0
  hide-link
end

to-report n-firms
  report count firms
end
;;***************GO****************************
to go
  go-beginning-of-month-firms
  go-beginning-of-month-households
  go-month
  go-end-of-month
  tick
end

to go-beginning-of-month-firms
  ask firms [
    adjust-wage-rate
    adjust-job-positions
    adjust-price
    set demand 0  ; reset demand for the month
  ]
end

to go-beginning-of-month-households
  ask households [
    if random-float 1 < Ψprice  [search-cheaper-vendor]  ; with probability Ψprice, search for a cheaper vendor
    if random-float 1 < Ψquant [search-delivery-capable-vendor]  ; with probability Ψquant, search for a vendor that has ineventory
    search-for-employement
    set-consumption
  ]
end
to go-month
  ;;; during month
  repeat month-length [
    ask households [buy-consumption-goods]
    ask firms [produce-goods]
  ]
end

to go-end-of-month
  ;;; end of month
  ask firms [
    pay-wages
    allocate-profits
  ]
  distribute-profits
  ask households [
    adjust-reservation-wage
    set-house-size
  ]
  ask firms [decide-fire-worker] ; important for this to happen after wages are paid and households adjust since the model assumes one month between a firing decision and the person actually getting fired

  set month month + 1
end


to-report beginning-of-month?  ; observer procedure
  report ticks mod month-length = 0
end

to-report end-of-month?  ; observer procedure
  report ticks mod month-length = (month-length - 1)
end

to distribute-profits  ; observer procedure - distrubtes all profits allocated by firms to households
  let total-hh-liquidity sum [liquidity] of households

  ;; distribute profits proportionately to current wealth.
  let profits-to-be-allocated PROFITS-TO-ALLOCATE
  ask households [
    let share-of-profits (liquidity / total-hh-liquidity) * profits-to-be-allocated  ; distribute proportionately to wealth
;    let share-of-profits  profits-to-be-allocated / n-households  ; distribute equally to everyone
    set liquidity liquidity + share-of-profits
    set PROFITS-TO-ALLOCATE PROFITS-TO-ALLOCATE - share-of-profits
  ]

  if precision PROFITS-TO-ALLOCATE 1 != 0 [error "profits weren't fully distributed"]
end

to-report n-in-agreements [input]
  report count my-in-framework-agreements with [input-firm-type = input]
end

to-report n-out-agreements
  report count my-out-framework-agreements
end

;*******************Firm Procedures*********************
to adjust-wage-rate  ; firm procedure

  ;; NOTE: this is how Nardin implements it. Lengnick implements it differently
  (ifelse
    last-open-position = (MONTH - 1) and not filled-position? [  ; firm had an open position last month and failed to fill
      set wage-rate (1 + random-float δ) * wage-rate
    ]
    (MONTH - last-open-position) >= γ [ ; If all hires in past γ months have succeded, lower wage rate.
      set wage-rate max list ((1 - random-float δ) * wage-rate) MIN-WAGE-RATE  ; wage rate cannot go below MIN-WAGE-RATE (0 in Lengnick)
    ])

end

;to-report failed-to-hire?  ; firm procedure. Reports if firm failed to hire last month
;  report months-with-all-positions-filled = 0 ;
;end

to adjust-job-positions  ; firm procedure
  ; This was my implementation, changing to match Nardin/Jake
;  (ifelse
;    inventory <  ϕl * demand [
;      set desired-labor-change 1  ; try to hire
;    ]
;    inventory > ϕu * demand [
;      set desired-labor-change -1  ; fire at the end of month
;    ] [  ; else if inventory is within desired range
;      set desired-labor-change 0  ; don't change labor
;    ]
;  )
  set filled-position? false  ; reset this, because none of the firms have filled a position at the beginning of a month
  (ifelse
    inventory <  ϕl * demand [  ; inventory is low
      set open-position? true  ; try to hire
      set close-position? false  ; don't fire anyone
      set last-open-position MONTH  ; this month is the last open position
    ]
    inventory > ϕu * demand [  ; inventory is high
      set open-position? false  ; don't hire
      set close-position? true  ; fire
    ] [  ; else if inventory is within desired range
      ;; Nardin doesn't have anything here
      set open-position? false
      set close-position? false
    ]
  )

end

to adjust-price
;  (ifelse
;    ;;
;    inventory < (ϕl * demand) and random-float 1 < θ [  ; if inventory is low and price is below threshold, with probability θ:
;      set price min list (price * (1 + random-float ν)) (marginal-costs * φub)  ;; increase price by random amount, but don't go above critical upper bound
;    ]
;
;    inventory > (ϕu * demand) and random-float 1 < θ [  ; if inventory is high and price is above threshold, with probability θ:
;      set price max list (price * (1 - random-float ν)) (marginal-costs * φlb)  ;; decrease price by random amount, but don't go below critical lower bound
;    ]
;  )

  (ifelse
    ; if inventory is low and price is below upper threshold, with probability θ increase prce
    (inventory < ϕl * demand) and (price < marginal-costs * φub) and (random-float 1 < θ) [
      set price price * (1 + random-float ν)
    ]
    ; if inventory is high and price is above lower threshold, with probability θ decrease price
    (inventory > ϕu * demand) and (price > marginal-costs * φlb) and random-float 1 < θ [  ;
      set price price * (1 - random-float ν)
    ]
  )
end


to decide-fire-worker

;  (ifelse
;    desired-labor-change < 0 and n-workers > 1 [  ; firms won't fire their last worker
;      ask one-of my-employment-links [die]
;      set months-with-all-positions-filled months-with-all-positions-filled + 1  ; if they fired, this was a month with all positions filled
;      set desired-labor-change 0  ; no longer want to fire
;    ]
;    desired-labor-change = 0 [
;      set months-with-all-positions-filled months-with-all-positions-filled + 1
;    ] [  ; if the firm still wants to hire at the end of the month
;      set months-with-all-positions-filled 0
;    ]
;  )

  if close-position? and n-workers > 1 [  ; firms won't fire their last worker
    ask one-of my-employment-links [die]
    ; set months-with-all-positions-filled months-with-all-positions-filled + 1  ; if they fired, this was a month with all positions filled
    ; set desired-labor-change 0  ; no longer want to fire ( I used this before using close-position?
  ]
  set close-position? false

  set-size
end

to search-cheaper-supplier [input-i]
  let current-framework-agreement one-of my-in-framework-agreements with [input-firm-type = input-i]
  let random-firm pick-random-input-firm input-i
  let current-price [price] of [other-end] of current-framework-agreement
  if ([price] of random-firm) * (1 + ξ) < current-price [  ; Switch if new price is at least ξ% lower
    ask current-framework-agreement [die]
    create-framework-agreement-from random-firm [
      init-framework-agreement input-i
    ]
  ]
end

to search-delivery-capable-seller [input-i]
  let link-failed-to-satisfy rnd:weighted-one-of my-in-framework-agreements with [input-firm-type = input-i][demand-not-satisfied]
  if [demand-not-satisfied] of link-failed-to-satisfy > 0  [
    create-framework-agreement-from pick-random-input-firm input-i [init-framework-agreement input-i]
    ask link-failed-to-satisfy [die]
  ]
end

to-report pick-random-input-firm [input-i]
  report rnd:weighted-one-of firms with [not member? myself out-framework-agreement-neighbors and firm-type = input-i] [count my-employment-links]
end

to-report marginal-costs   ; firm procedure
  report ((wage-rate /  month-length / tech-parameter) + input-cost-estimate)
end

;this procedure takes the average input cost to estimate cost
to-report input-cost-estimate
  let mc 0
  foreach table:keys input-data [i ->
    let sum-cost 0
    ask my-framework-agreements with [input-firm-type = i][
      ask other-end[
        set sum-cost sum-cost + price
      ]
    ]
    let avg-cost (sum-cost / (count my-framework-agreements with [input-firm-type = i]))
    set mc (mc + (avg-cost / month-length / marginal-productivity i))
  ]
  report mc
end

;this procedure will take the maximum cost
;to-report input-cost-estimate
;  let mc 0
;  foreach table:keys input-data[i ->
;    let cost max ([price] of [other-end] of my-framework-agreements)
;    set mc (mc + (cost / month-length / (marginal-productivity i)))
;  ]
;end

;this procedure will take the minimum cost
;to-report input-cost-estimate
;  let mc 0
;  foreach table:keys input-data[i ->
;    let cost min ([price] of [other-end] of my-framework-agreements)
;    set mc (mc + (cost / month-length / (marginal-productivity i)))
;  ]
;end

to-report current-stock [i]
  let input table:get input-data i
  report table:get input "Current stock"
end

to set-stock [input value]
  let current-input table:get input-data input
  table:put current-input "Current-stock" value
end

to-report marginal-productivity [i]
  let input table:get input-data i
  report table:get input "Marginal productivity"
end

to-report n-workers
  report count my-employment-links
end

to produce-goods  ; firm procedure
  ;set inventory inventory + daily-production
  let production-amount production-potential
  set inventory inventory + production-amount
  use-inputs production-amount
end

;to-report daily-production
;  report tech-parameter * n-workers
;end

to pay-wages  ; firm procedure
  if n-workers > 0 [
    if wage-rate * n-workers > liquidity [ ; if there isn't enough to pay workers -> immediate pay cut
      set wage-rate liquidity / n-workers
    ]
    set liquidity precision (liquidity - wage-rate * n-workers) 10
    if liquidity < 0 [error "firms aren't allowed to go into debt"]
    ask employment-link-neighbors [set liquidity liquidity + [wage-rate] of myself]
  ]
end

to allocate-profits  ; firm procedure
  let buffer decide-reserve
  if liquidity > buffer [  ; if there is enough profits, allocate them to share holders
    set PROFITS-TO-ALLOCATE PROFITS-TO-ALLOCATE + liquidity - buffer
    set liquidity buffer
  ]
end

to-report sell-consumption-good [amount-wanted]  ; firm procedure
  set demand demand + amount-wanted
  let goods-sold min list amount-wanted inventory  ; sell the amount wanted, or if the firm doesn't have enough, then all remaining inventory
  set inventory inventory - goods-sold
  if inventory < 0 [error "inventory cannot be negative"]
  set liquidity liquidity + goods-sold * price
  report goods-sold
end


to-report decide-reserve  ; firm procedure
  report χ * wage-rate * n-workers  ; 0.1 is χ in Lengnick
end

to-report production-potential ;reports the potential daily production based on the amount of inputs a firm currently has in stock
  ;try to modify this using a table-to-list primitive
  ;do a map through the keys
  ifelse input-data = "None"[
    report n-workers * tech-parameter
  ][
    let minimum-potential 1000000000
    foreach table:keys input-data[ i ->
      let input-potential ((marginal-productivity i) * (current-stock i))
      if input-potential < minimum-potential[
        set minimum-potential input-potential
      ]
    ]
    report (min (list minimum-potential (n-workers * tech-parameter)))
  ]
end

to use-inputs [production-amount] ;adjusts the input amount after production
  foreach table:keys input-data[ i ->
    let current-amount current-stock i
    set-stock i (current-amount - ((production-amount) / (marginal-productivity i)))
  ]
end

to-report daily-input-demand [i]
  let input table:get input-data i
  report table:get input "Daily demand"
end

to set-daily-demand [i value]
  let input table:get input-data i
  table:put input "Daily demand" value
  table:put input-data i input
end

to set-daily-input-demands
  if input-data != "None"[
    let estimated-demand demand
    let estimated-production (estimated-demand - inventory)
    ;currently there's no buffer for how much of an input a firm orders, they order exactly as much as they think they'll need
    foreach table:keys input-data[i ->
      let current-amount current-stock i
      let amount-needed (estimated-production / (marginal-productivity i))
      ifelse amount-needed < current-amount[
        set-daily-demand i ((amount-needed - current-amount) / month-length)
      ][
        set-daily-demand i 0
      ]
    ]
  ]
end

to-report uses-input? [i]
  report table:has-key? input-data i
end

;*******************Household Procedures*********************
to search-cheaper-vendor  ; household procedure
  let current-trading-link one-of my-consumer-links
  let random-firm pick-random-consumer-firm
  let current-price [price] of [other-end] of current-trading-link
  if ([price] of random-firm) * (1 + ξ) < current-price [  ; Switch if new price is at least ξ% lower
    ask current-trading-link [die]
    create-consumer-link-with random-firm [init-consumer-link]
  ]
end


to search-delivery-capable-vendor
  let link-failed-to-satisfy rnd:weighted-one-of my-consumer-links [demand-not-satisfied]
  if [demand-not-satisfied] of link-failed-to-satisfy > 0  [
    create-consumer-link-with pick-random-consumer-firm [init-consumer-link]
    ask link-failed-to-satisfy [die]
  ]
end

to-report pick-random-consumer-firm ; household procedure
  ; report a random firm that is not a current trading partner of this househould, weighted by # of employees
  report rnd:weighted-one-of firms with [not member? myself consumer-link-neighbors and consumer?] [count my-employment-links]
end


to search-for-employement  ; household procedure
  ifelse unemployed? [
    search-job
  ] [
    search-better-paid-job
  ]

end

to search-job  ; this is when the household is unemployed
  let firms-tried 0
  while [unemployed? and firms-tried < 5] [ ; 5 is  β in Lengnick
    check-random-firm-for-job reservation-wage
    set firms-tried firms-tried + 1
  ]
end

to search-better-paid-job  ; this is when a household is currently employed
  search-better-paid-job-logic random-float 1 < 0.1  ; This is the random probability that a household searches for a better paid job even if they are currently satisfied (pi in Lengnick
end

to search-better-paid-job-logic [search-even-if-satisfied?]
  if [n-workers] of my-employer > 1 and   ; only allowed to search for better paid job if the firm will still have another worker
  (unsatisfied-with-wage? or search-even-if-satisfied?) [ ; if wage-rate fell below reservation wage, then look for a new job or if the person is satisfied with current wage they might still look
    check-random-firm-for-job [wage-rate] of my-employer
  ]
end

to check-random-firm-for-job [min-wage]  ; household procedure
  let the-firm nobody
  ifelse unemployed?
  [set the-firm one-of firms]
  [set the-firm [one-of other firms] of my-employer]

  if [open-position?] of the-firm and [wage-rate] of the-firm >= min-wage [

    if employed? [quit-job]

    create-employment-link-with the-firm [init-employment-link]
    ;ask the-firm [set desired-labor-change desired-labor-change - 1]

    ask the-firm [
      set open-position? false  ;
      set filled-position? true
      set close-position? false  ; this shouldn't need to happen here, but why not
    ]
  ]
end

to quit-job
  ask my-employer [
    set close-position? false
  ]
  ask my-employment-links [die]
end

to set-consumption  ; household procedure
  let mean-price mean [price] of consumer-link-neighbors  ; households only know prices of their trading firms
  let total-consumption min list (liquidity / mean-price) (ideal-consumption liquidity  mean-price)  ; if liquidity/mean-price < 1, then they don't have enough money for ideal consumption
  set daily-consumption total-consumption / month-length
end

to-report ideal-consumption [money mean-price]
  let ic 0
  carefully [
    set ic (money / mean-price) ^ α  ; is α in Lengnick. Consumption increases with wealth at decaying rate
  ] [  ; sometimes with really low money, NetLogo throws an error that (money / mean-price) ^ 0.9 is not a number
    print error-message
  ]
  report ic
end

; This was my original version. I changed to the version below which looks equivalent to me but yields different behavior.
;to buy-consumption-goods  ; household procedure
;  ask my-consumer-links [set demand-not-satisfied 0]
;  let total-bought 0
;  let firms-to-try consumer-link-neighbors with [inventory > 0]  ; in Lengnick, all 7 firms are tried if necesary.
;  while [total-bought < 0.95 * daily-consumption and any? firms-to-try] [
;    ; figure out the transaction
;    let the-firm one-of firms-to-try
;
;    let my-demand min list daily-consumption (liquidity / [price] of the-firm) ; demand was daily-consumption or as much as the buyer could afford. Note, Lengnick doesn't explain exactly how demand is calculated.
;    let relevant-inventory min list daily-consumption ([inventory] of the-firm)
;    let total-cost min list liquidity (relevant-inventory * [price] of the-firm)
;
;    ; set whether demand was met from this firm
;    ask consumer-link-with the-firm [
;      set demand-not-satisfied max list 0 (my-demand - relevant-inventory)  ; must be >= 0 Lengnick uses this to probabilistically determine firms to cut ties with, but doesn't say exactly how he calculates it
;    ]
;
;    ; adjust household variables
;    set liquidity liquidity - total-cost
;    let goods-sold total-cost / [price] of the-firm
;    set total-bought total-bought + goods-sold
;
;    ; adjust firm variables
;    ask the-firm [
;      set demand demand + my-demand
;      set inventory precision (inventory - goods-sold) 10
;      if inventory < 0 [error "inventory cannot be negative"]
;      set liquidity liquidity + total-cost
;      set firms-to-try other firms-to-try  ; remove this firm from the available set
;    ]
;  ]
;end

to buy-consumption-goods  ; household procedure
  ;ask my-consumer-links [set demand-not-satisfied 0]
  let remaining-demand daily-consumption
  let firms-to-try consumer-link-neighbors

  while [remaining-demand >= (0.05 * daily-consumption) and any? firms-to-try] [

    ; figure out the transaction
    let the-firm one-of firms-to-try

    let goods-wanted min list daily-consumption (liquidity / [price] of the-firm)  ; demand is daily-consumption or as much as the buyer could afford. Note, Lengnick doesn't explain exactly how demand is calculated.
    let amount-bought [sell-consumption-good goods-wanted] of the-firm

    ; adjust household variables
    set liquidity liquidity - amount-bought * [price] of the-firm
    set remaining-demand remaining-demand - amount-bought

    if remaining-demand > 1E-10 [  ; if the amount bought does not satisfy demand (either because the firm didn't have inventory or because it was too expensive and the house couldn't afford)
      ask consumer-link-with the-firm [set demand-not-satisfied remaining-demand]
    ]
    ask the-firm [ set firms-to-try other firms-to-try]  ; remove this firm from the available set of firms to try
  ]
end


to adjust-reservation-wage
  (ifelse
    unemployed? [
      set reservation-wage reservation-wage * .9  ; Lengnick says at the end of 2.4, this happens
    ]
    [wage-rate] of my-employer > reservation-wage [
      set reservation-wage [wage-rate] of my-employer
    ]
  )
end

to-report my-employer
  report [other-end] of one-of my-employment-links  ; each household has only 1 b link, so this is the same everytime

end

to-report unemployed?  ; household procedure
  report count my-employment-links = 0
end

to-report employed?
  report count my-employment-links = 1
end

to-report unsatisfied-with-wage?  ; household procedure
  report [wage-rate] of my-employer < reservation-wage
end

to-report year
  report month / 12
end
@#$#@#$#@
GRAPHICS-WINDOW
207
51
644
489
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
1
1
1
months
30.0

BUTTON
1
88
67
121
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
125
88
206
121
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
68
88
123
121
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
6
11
178
44
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
1
125
201
331
Employed Households
years
NIL
0.0
10.0
950.0
1000.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plotxy year count employment-links"

PLOT
652
10
975
147
Wage Rate Stats
NIL
NIL
0.0
10.0
0.0
60.0
true
true
"" ""
PENS
"mean wage" 1.0 0 -16777216 true "" "plot mean [wage-rate] of firms"
"min wage" 1.0 0 -7500403 true "" "plot min [wage-rate] of firms"
"mean res-wage" 1.0 0 -13345367 true "" "plot mean [reservation-wage] of households"
"max wage" 1.0 0 -14439633 true "" "plot max [wage-rate] of firms"
"median wage" 1.0 0 -2674135 true "" "plot median [wage-rate] of firms"

PLOT
653
455
853
605
worker per firm distribution
NIL
NIL
0.0
20.0
0.0
20.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [n-workers] of firms"

PLOT
857
300
1057
450
liquidity of firms and households
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
"firms" 1.0 0 -6459832 true "" "plot mean [liquidity] of firms"
"households" 1.0 0 -13345367 true "" "plot  mean [liquidity] of households"
"pen-2" 1.0 0 -7500403 true "" "plot mean [liquidity] of turtles"

BUTTON
992
103
1086
136
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
987
69
1174
102
show random firm's links
ask one-of firms [ask my-links [show-link]]
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
454
1055
604
customer per firm distribution
NIL
NIL
0.0
100.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [count employment-link-neighbors] of firms"

PLOT
856
147
1056
297
mean price
NIL
NIL
0.0
10.0
0.98
1.02
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [price] of firms"

BUTTON
237
10
310
43
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
391
10
486
43
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
1
333
201
483
mean inventory/demand
NIL
NIL
0.0
10.0
0.0
0.65
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plotxy year mean [inventory / demand] of firms"
"pen-1" 1.0 0 -7500403 true "" "plotxy year ϕl"

PLOT
653
300
853
450
mean demand not satisfied
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
"default" 1.0 0 -16777216 true "" "plot mean [demand-not-satisfied] of consumer-links"

PLOT
653
147
853
297
mean demand
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
"default" 1.0 0 -16777216 true "" "plot mean [demand] of firms"

BUTTON
992
21
1112
54
NIL
lengnick-tests
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
180
10
235
43
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
487
10
631
43
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
312
10
389
43
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

PLOT
0
486
200
636
firms w/ high/low inventory 
NIL
NIL
0.0
10.0
0.0
100.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plotxy year count firms with [inventory <  ϕl * demand]"
"pen-1" 1.0 0 -2674135 true "" "plotxy year count firms with [inventory >  ϕu * demand]"
"pen-2" 1.0 0 -7500403 true "" "plotxy year n-firms"

TEXTBOX
204
514
359
570
inventory < ϕl * demand \n(want to hire)
11
0.0
1

TEXTBOX
204
598
354
626
inventory >  ϕu * demand (want to fire)
11
15.0
1

TEXTBOX
4
370
46
455
above line we expect firing, below hiring
10
5.0
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
NetLogo 6.2.0
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
