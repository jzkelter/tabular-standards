/*******************************************************************************
 * Firm object class
 *
 * @copyright Copyright 2018 Brandenburg University of Technology, Germany
 * @license The MIT License (MIT)
 * @author Luis Gustavo Nardin
 * @author Gerd Wagner
 ******************************************************************************/
var Firm = new cLASS( {
  Name: "Firm",
  supertypeName: "oBJECT",

  // Properties
  properties: {
    "money": {
      range: "PositiveDecimal",
      label: "Liquidity"
      // shortLabel: "mF"
    },
    "reserve": {
      range: "PositiveDecimal",
      label: "Reserve amount"
      // shortLabel: "mBuffer"
    },
    "inventoryLevel": {
      range: "PositiveDecimal",
      label: "Goods inventory level"
      // shortLabel: "iF"
    },
    "consumptionGoodPrice": {
      range: "PositiveDecimal",
      label: "Price of the consumption goods"
      // shortLabel: "pF"
    },
    "demand": {
      range: "PositiveDecimal",
      label: "Monthly demanded goods",
      // shortLabel: "demand"
    },
    "workers": {
      range: "Household",
      label: "Workers",
      minCard: 0,
      maxCard: Infinity
      // shortLabel: "workers"
    },
    "wageRate": {
      range: "PositiveDecimal",
      label: "Wage rate"
      // shortLabel: "wF"
    },
    "openPosition": {
      range: "Boolean",
      label: "Open for hiring"
      // shortLabel: "op"
    },
    "filledPosition": {
      range: "Boolean",
      label: "Filled position"
      // shortLabel: "fp"
    },
    "lastOpenPosition": {
      range: "NonNegativeInteger",
      label: "Month a position was opened"
      // shortLabel: "lop"
    },
    "closePosition": {
      range: "Boolean",
      label: "Close a position"
      // shortLabel: "cp"
    },
    "startPlanning": {
      range: "NonNegativeInteger",
      label: "Month to start planning"
      // shortLabel: "sp"
    }
  },

  // Methods
  methods: {
    /**
     * @description Adjust the wage depending on hiring perspective
     *              (increase wage) or full employment capacity (decrease
     *              wage)
     * @param month
     *          Current month
     */
    "adjustWageRate": function ( month ) {
      if ( ( this.lastOpenPosition === ( month - 1 ) ) &&
        !this.filledPosition ) {
        this.wageRate *= ( 1 + rand.uniform( 0, Firm.delta ) );
      } else if ( ( month - this.lastOpenPosition ) > Firm.gamma ) {
        this.wageRate *= ( 1 - rand.uniform( 0, Firm.delta ) );
      }

      // Reset filled open position
      this.filledPosition = false;
    },

    /**
     * @description Adjust the job positions
     * @param month
     *          Current month
     */
    "adjustJobPositions": function ( month ) {
      // Calculate the upper and lower bar for inventories
      var uIF = Firm.uPhi * this.demand;
      var lIF = Firm.lPhi * this.demand;

      // If inventory level less than the lower bar inventory value,
      // open job position
      if ( this.inventoryLevel < lIF ) {
        this.openPosition = true;
        this.lastOpenPosition = month;
        this.closePosition = false;

        // If the inventory level is greater than the upper bar
        // inventory value, close a job position
      } else if ( this.inventoryLevel > uIF ) {
        this.openPosition = false;
        this.closePosition = true;
      }
    },

    /**
     * @description Adjust the consumption good price
     * @param month
     *          Current month
     * @param daysMonth
     *          Number of days in a month
     */
    "adjustConsumptionGoodPrice": function ( daysMonth ) {
      // Calculate the upper and lower bar for inventories
      var uIF = Firm.uPhi * this.demand;
      var lIF = Firm.lPhi * this.demand;

      // Calculate the upper and lower bar for prices
      var marginalCost = this.wageRate / daysMonth / Firm.lambda;
      var uPF = Firm.uphi * marginalCost;
      var lPF = Firm.lphi * marginalCost;

      // If inventory level is below the lower bar inventory value,
      // the product price is less than the upper bar price value, and
      // with certain probability, increase the goods price
      if ( ( this.inventoryLevel < lIF ) &&
        ( this.consumptionGoodPrice < uPF ) &&
        ( rand.uniform( 0, 1 ) < Firm.theta ) ) {
        this.consumptionGoodPrice *= ( 1 + ( Firm.upsilon *
          rand.uniform( 0, 1 ) ) );

        // If inventory level is above the upper bar inventory level,
        // the product price is greater than the lower bar price
        // value, and with certain probability, decrease the goods
        // price
      } else if ( ( this.inventoryLevel > uIF ) &&
        ( this.consumptionGoodPrice > lPF ) &&
        ( rand.uniform( 0, 1 ) < Firm.theta ) ) {

        this.consumptionGoodPrice *= ( 1 - ( Firm.upsilon *
          rand.uniform( 0, 1 ) ) );
      }
    },

    /**
     * @description Hire a worker
     * @param worker
     *          Household worker to hire
     */
    "hire": function ( worker ) {
      this.workers.push( worker );
      this.openPosition = false;
      this.filledPosition = true;
      this.closePosition = false;
    },

    /**
     * @description Remove a worker from the workforce
     * @param worker
     *          Household worker quitting
     */
    "quit": function ( worker ) {
      this.workers.splice( this.workers.indexOf( worker ), 1 );
      this.closePosition = false;
    },

    /**
     * @description Remove a worker from the workforce
     * @param worker
     *          Household worker being fired
     */
    "fire": function ( worker ) {
      this.workers.splice( this.workers.indexOf( worker ), 1 );
      worker.fired();
      this.closePosition = false;
    },

    /**
     * @description Consider firing a worker
     */
    "decideFireWorker": function () {
      var worker;

      if ( this.closePosition && ( this.workers.length > 1 ) ) {
        worker = this.workers[ rand.uniformInt( 0, this.workers.length - 1 ) ];
        this.fire( worker );
      }
      this.closePosition = false;
    },

    /**
     * @description Produce products
     */
    "produceConsumptionGoods": function () {
      // Increase the inventory
      this.inventoryLevel += ( Firm.lambda * this.workers.length );
    },

    /**
     * @description Sell products
     * @param demand
     *          Demanded amount of products demanded
     * @return Actual amount of products sold
     */
    "sellConsumptionGoods": function ( demand ) {
      var soldGoods = Math.min( demand, this.inventoryLevel );

      // Increase demand, and reduce inventory and liquidity
      this.demand += demand;
      this.inventoryLevel -= soldGoods;
      this.money += soldGoods * this.consumptionGoodPrice;

      return ( soldGoods );
    },

    /**
     * @description Pay wage to the workers and adjust wage if there is
     *              not enough liquidity to pay total amount
     */
    "payWages": function () {
      var i;

      // Calculate the actual wage
      if ( ( this.wageRate * this.workers.length ) > this.money ) {
        this.wageRate = this.money / this.workers.length;
      }

      // Pay wage to workers
      for ( i = 0; i < this.workers.length; i += 1 ) {
        this.workers[ i ].receiveWage( this.wageRate );
      }

      // Reduce liquidity
      this.money -= this.wageRate * this.workers.length;
    },

    /**
     * @description Calculate the reserve for bad times
     */
    "decideReserve": function () {
      this.reserve = Math.max( 0, Math.min( Firm.chi * this.wageRate *
        this.workers.length, this.money ) );
    },

    /**
     * @description Distribute profit among all Households proportional to
     *              their liquidity
     */
    "distributeProfits": function () {
      var profit, total, iHHs, hh;

      // Money available to distribute, profit
      profit = this.money - this.reserve - ( this.wageRate *
        this.workers.length );

      if ( profit > 0 ) {
        // Calculate the total amount of money of all Households
        total = 0;
        iHHs = cLASS[ "Household" ].instances;
        Object.keys( iHHs ).forEach( function ( objId ) {
          hh = iHHs[ objId ];
          if ( hh.money > 0 ) {
            total += hh.money;
          }
        } );

        // Pay proportional profit to all Households
        if ( total > 0 ) {
          Object.keys( iHHs ).forEach( function ( objId ) {
            hh = iHHs[ objId ];
            if ( hh.money > 0 ) {
              hh.money += profit * ( hh.money / total );
            }
          } );
        }

        this.money -= profit;
      }
    },

    /**
     * @description Set monthly demand to zero
     */
    "resetMonthDemand": function () {
      this.demand = 0;
    }
  },
} );

// All positions filled last gamma months
Firm.gamma = 1;

// Upper bound range of the wage growth rate
Firm.delta = 0.019;

// Upper bar value inventory
Firm.uPhi = 1;

// Lower bar value inventory
Firm.lPhi = 0.25;

// Upper bound range value of the price growth rate
Firm.upsilon = 0.02;

// Critical upper bar value for prices
Firm.uphi = 1.15;

// Critical lower bar value for prices
Firm.lphi = 1.025;

// Probability to increase or decrease the product price
Firm.theta = 0.75;

// Technology parameter
Firm.lambda = 3;

// Percentage defining the amount to reserve for bad times
Firm.chi = 0.1;