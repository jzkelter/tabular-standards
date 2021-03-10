/*******************************************************************************
 * Household object class
 *
 * @copyright Copyright 2018 Brandenburg University of Technology, Germany
 * @license The MIT License (MIT)
 * @author Luis Gustavo Nardin
 * @author Gerd Wagner
 ******************************************************************************/
var Household = new cLASS( {
  Name: "Household",
  supertypeName: "oBJECT",
  properties: {
    "employed": {
      range: "Boolean",
      label: "Employed"
      // shortLabel: "employed"
    },
    "employer": {
      range: "Firm",
      label: "Employer"
      // shortLabel: "employer"
    },
    "reservationWage": {
      range: "PositiveDecimal",
      label: "Reservation wage"
      // shortLabel: "wH"
    },
    "receivedWage": {
      range: "PositiveDecimal",
      label: "Receive wage"
      // shortLabel: "wR"
    },
    "money": {
      range: "PositiveDecimal",
      label: "Liquidity"
      // shortLabel: "mH"
    },
    "dailyDemand": {
      range: "PositiveDecimal",
      label: "Daily demand",
      // shortLabel: "dd"
    },
    "preferredSuppliers": {
      range: "Firm",
      label: "Preferred suppliers",
      minCard: 0,
      maxCard: Infinity
      // shortLabel: "firms"
    },
    "blacklistedSuppliers": {
      range: Object,
      label: "Blacklisted suppliers"
      // shortLabel: "firmsR"
    }
  },
  methods: {
    /**
     * @description Searches for a Firm that sells products for a
     *              cheaper price or replaces a firm that has not
     *              satisfied the demand requested
     * @return New added firm or null
     */
    "searchCheaperVendor": function () {
      var firms = cLASS[ "Firm" ].instances;
      var kFirms = Object.keys( firms );
      var tFirm, oFirms, cFirms, nFirm = null;
      var i, v, threshold;
      // Search for a cheaper Firm with probability psiPrice assuming
      // there is a Firm that the Household still cannot buy goods from
      if ( rand.uniform( 0, 1 ) < Household.psiPrice ) {
        // Select the Firms that the household cannot buy products from
        oFirms = kFirms.clone();
        for ( i = 0; i < this.preferredSuppliers.length; i += 1 ) {
          oFirms.splice( oFirms.indexOf(
            String( this.preferredSuppliers[ i ].id ) ), 1 );
        }
        if ( oFirms.length > 0 ) {
          // Select a Firm the Household can buy products from
          tFirm = this.preferredSuppliers[ rand.uniformInt( 0,
            this.preferredSuppliers.length - 1 ) ];

          // Randomly select a Firm among those to which the Household
          // may not buy products from weighting their probability by
          // their current number of workers
          cFirms = [];
          cFirms[ 0 ] = firms[ oFirms[ 0 ] ].workers.length;
          for ( i = 1; i < oFirms.length; i += 1 ) {
            cFirms[ i ] = cFirms[ i - 1 ] +
              firms[ oFirms[ i ] ].workers.length;
          }
          threshold = rand.uniform( 0, 1 );
          for ( i = 0, v = 0; v < threshold; i += 1 ) {
            v = cFirms[ i ] / cFirms[ cFirms.length - 1 ];
          }
          nFirm = firms[ oFirms[ i - 1 ] ];

          // Compare prices between the selected Firm the Household can
          // buy products from to another the Household cannot, and
          // replaces the former by the latter if the price of the
          // latter is at least zeta percent lower than the former
          if ( ( tFirm.consumptionGoodPrice *
              ( 1 - Household.zeta ) ) > nFirm.consumptionGoodPrice ) {
            if ( tFirm.id in this.blacklistedSuppliers ) {
              delete this.blacklistedSuppliers[ tFirm.id ];
            }
            this.preferredSuppliers.splice( this.preferredSuppliers
              .indexOf( tFirm ), 1 );
            this.preferredSuppliers.push( nFirm );
          }
        }
      }

      return ( nFirm );
    },

    /**
     * @description Replace a firm that has not satisfied prior demands
     * @param exceptionFirm
     *          A firm that has been included by the searchCheaperVendor
     *          function
     */
    "searchDeliveryCapableVendor": function ( exceptionFirm ) {
      var iFirms = cLASS[ "Firm" ].instances;
      var kFirms = Object.keys( iFirms );
      var rFirms, rFirm, cFirms, nFirm;
      var i, v, threshold;

      // Search for satisfying Firms with probability psiQuant
      if ( rand.uniform( 0, 1 ) < Household.psiQuant ) {

        rFirms = Object.keys( this.blacklistedSuppliers );

        if ( rFirms.length > 0 ) {
          // Randomly select a Firm among those that has failed to
          // fulfill the Household demands weighting their probability
          // by sum of the demand not fulfilled
          cFirms = [];
          cFirms[ 0 ] = this.blacklistedSuppliers[ rFirms[ 0 ] ];
          for ( i = 1; i < rFirms.length; i += 1 ) {
            cFirms[ i ] = cFirms[ i - 1 ] +
              this.blacklistedSuppliers[ rFirms[ i ] ];
          }
          threshold = rand.uniform( 0, 1 );
          for ( i = 0, v = 0; v < threshold; i += 1 ) {
            v = cFirms[ i ] / cFirms[ cFirms.length - 1 ];
          }
          rFirm = iFirms[ rFirms[ i - 1 ] ];

          // Search for a Firm that the Household may not buy products
          // from yet
          do {
            nFirm =
              iFirms[ kFirms[ rand.uniformInt( 0, kFirms.length - 1 ) ] ];
          } while ( ( nFirm.id === rFirm.id ) ||
            ( ( exceptionFirm !== null ) &&
              ( nFirm.id === exceptionFirm.id ) ) );

          // Replace the restricted Firm the new randomly selected Firm
          if ( rFirm.id in this.blacklistedSuppliers ) {
            delete this.blacklistedSuppliers[ rFirm.id ];
          }
          this.preferredSuppliers.splice(
            this.preferredSuppliers.indexOf( rFirm ), 1 );
          this.preferredSuppliers.push( nFirm );
        }
      }
    },

    /**
     * @description Searches for an employer that pays more than the
     *              reservation wage
     */
    "searchJob": function () {
      var iFirms = cLASS[ "Firm" ].instances;
      var kFirms = Object.keys( iFirms );
      var firm, i;

      i = 0;
      do {
        // Select a Firm randomly
        firm = iFirms[ kFirms[ rand.uniformInt( 0, kFirms.length - 1 ) ] ];

        // Check if the Firm is hiring (it has open positions)
        if ( firm.openPosition ) {

          // If the Firm has an open position and the offered wage is
          // greater than the reservation wage, the Household is
          // hired
          if ( firm.wageRate > this.reservationWage ) {
            this.employed = true;
            this.employer = firm;
            this.employer.hire( this );
          }
        }
        i += 1;
      } while ( ( !this.employed ) && ( i < Household.beta ) );
      // The Household searches for a job in beta Firms before giving
      // up

      // If the Household continues unemployed after the search,
      // the Household reduces its own reservation wage to increase
      // its chance of finding an employer
      if ( !this.employed ) {
        this.reservationWage *= Household.wage_change_unemployed;
      }
    },

    /**
     * @description Searches for an employer that pays better than the
     *              current one
     */
    "searchBetterPaidJob": function () {
      var iFirms = cLASS[ "Firm" ].instances;
      var kFirms = Object.keys( iFirms );
      var firm;

      // If the Household is employed, it also may search for a better
      // paid work, but it can search for a new work only if its
      // employer has more than 1 worker. The Household cannot quit
      // if it is the last worker
      if ( this.employer.workers.length > 1 ) {

        // The Household has a probability pi of searching for a new
        // work that pays a better wage, or probability 1 if its
        // current employer wage is less than its reservation wage
        if ( ( this.employer.wageRate < this.reservationWage ) ||
          ( rand.uniform( 0, 1 ) < Household.pi ) ) {

          // Select a Firm randomly, which is different than the
          // Household current employer
          do {
            firm = iFirms[ kFirms[ rand.uniformInt( 0, kFirms.length - 1 ) ] ];
          } while ( this.employer.id === firm.id );

          // The Household replaces employer if the selected new Firm
          // has open positions, has a greater wage than its current
          // employer and has a greater wage than its reservation wage
          if ( ( firm.openPosition ) &&
            ( firm.wageRate > this.employer.wageRate ) &&
            ( firm.wageRate > this.reservationWage ) ) {
            this.employer.quit( this );
            this.employer = firm;
            this.employer.hire( this );
          }
        }
        // The Household increases its reservation wage because it is
        // employed
        this.reservationWage *= Household.wage_change_employed;
      }
    },

    /**
     * @description Calculate the quantity of products to buy daily
     * @param daysMonth
     *          Number of days considered a month
     */
    "decideConsumption": function ( daysMonth ) {
      var i, c, m, pI = 0;

      // Calculate the mean price of the product of the Firms the
      // Household can buy products from
      for ( i = 0; i < this.preferredSuppliers.length; i += 1 ) {
        pI += this.preferredSuppliers[ i ].consumptionGoodPrice;
      }
      pI /= this.preferredSuppliers.length;

      // Calculate the monthly consumption with savings normalized to 0
      // Page 7, Eq. (12)
      m = Math.max( this.money, 0 ) / pI;
      c = Math.min( Math.pow( m, Household.alpha ), m );

      // Equal consumption each day of the month
      this.dailyDemand = c / daysMonth;
    },

    /**
     * @description Buy consumption goods from preferred vendors
     */
    "buyConsumptionGoods": function () {
      var remainingDemand = this.dailyDemand;
      var i, kFirms, firm, wantedGoods, boughtGoods;

      kFirms = [];
      for ( i = 0; i < this.preferredSuppliers.length; i += 1 ) {
        kFirms.push( i );
      }

      do {
        // Select a random Firm to demand products from
        i = rand.uniformInt( 0, kFirms.length - 1 );
        firm = this.preferredSuppliers[ kFirms[ i ] ];
        kFirms.splice( i, 1 );

        // Calculate the number of products to demand considering the
        // price of the product, the amount of money available, and
        // the total daily demand
        wantedGoods =
          Math.min( remainingDemand, this.money /
            firm.consumptionGoodPrice );

        // Buy the maximum number of products to satisfy the demand
        boughtGoods = firm.sellConsumptionGoods( wantedGoods );

        // Reduce the daily demand and the amount of money available
        remainingDemand -= boughtGoods;
        this.money -= boughtGoods * firm.consumptionGoodPrice;

        // If there is need to demand products from another Firm,
        // the Firm could not satisfy the Household demand because of a
        // high price or no product in its inventory, and the Firm is
        // included in the list of Firms that restricted the Household
        // on its demand
        if ( remainingDemand > 0 ) {
          if ( !( firm.id in this.blacklistedSuppliers ) ) {
            this.blacklistedSuppliers[ firm.id ] = remainingDemand;
          } else {
            this.blacklistedSuppliers[ firm.id ] += remainingDemand;
          }
        }
        // Stop demanding products if there is less than phi percent of
        // the daily demand remaining, the Household has no more money
        // or there is no other Firms to demand products from
      } while ( ( remainingDemand > ( ( 1 - Household.phi ) *
          this.dailyDemand ) ) &&
        ( this.money > 0 ) && ( kFirms.length > 0 ) );
    },

    /**
     * @description Receive wage payment for its work and adjust the
     *              reservation wage
     * @param value
     *          Wage received
     */
    "receiveWage": function ( value ) {
      // Increase liquidity
      this.money += value;
      this.receivedWage = value;
    },

    /**
     * @description Adjust the reservation wage based on the received
     *              wage
     * @param value
     *          Wage receive
     */
    "adjustReservationWage": function () {
      if ( ( this.employed ) &&
        ( this.receivedWage > this.reservationWage ) ) {
        this.reservationWage = this.receivedWage;
      }
    },

    /**
     * @description Set the Household unemployed and update its
     *              reservation wage
     */
    "fired": function () {
      this.employed = false;
      this.reservationWage *= Household.wage_change_fire;
    }
  }
} );

// Percentage of the new Firm's price below the current Firm's price to replace
// the old by the new Firm
Household.zeta = 0.01;

// Number of Firms to search for a work
Household.beta = 5;

// Probability of searching for a new work, if employed
Household.pi = 0.1;

// Decay rate for the consumption expenditure increase
Household.alpha = 0.9;

// Probability of replacing a Firm because of its high price
Household.psiPrice = 0.25;

// Probability of replacing a Firm because of it is in the list of restricted
// Firms
Household.psiQuant = 0.25;

// Demand satisfaction
Household.phi = 0.95;

// Percentage of change on the reservation wage if the Household searches, but
// does not find a work
Household.wage_change_unemployed = 0.9;

// Percentage of change on the reservation wage if the Household is employed
Household.wage_change_employed = 1;

// Percentage of change on the reservation wage if the Household is fired
Household.wage_change_fire = 1;
