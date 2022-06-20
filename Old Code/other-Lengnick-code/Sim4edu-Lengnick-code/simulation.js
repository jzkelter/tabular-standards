/*******************************************************************************
 * Baseline Economy simulation based on Lengnick, M. (2013). Agent-based
 * macroeconomics: A baseline model. Journal of Economic Behavior &
 * Organization. 86:102-120. DOI: https://doi.org/10.1016/j.jebo.2012.12.021
 *
 * @copyright Copyright 2018 Brandenburg University of Technology, Germany.
 * @license The MIT License (MIT)
 * @author Luis Gustavo Nardin
 * @author Gerd Wagner
 ******************************************************************************/
/*******************************************************************************
 * Simulation Parameters
 ******************************************************************************/
sim.scenario.simulationEndTime = 10000;
sim.scenario.idCounter = 0; // optional
// sim.scenario.randomSeed = 1234; // optional
/*******************************************************************************
 * Simulation Configuration
 ******************************************************************************/
sim.config.createLog = false;
/*******************************************************************************
 * Simulation Model
 ******************************************************************************/
sim.model.time = "discrete";
sim.model.timeUnit = "D"; // days

sim.model.objectTypes = [ "Firm", "Household" ];
sim.model.eventTypes = [ "StartOfMonth", "EachDay", "EndOfMonth" ];

// Global model variables
sim.model.v.verbose = false; // Enable/Disable console messages
sim.model.v.month = 1; // Current month
sim.model.v.day = 1; // Current day
sim.model.v.daysOfMonth = { // not shown in the UI
  range: "PositiveInteger",
  initialValue: 21, //label:"Number of days per month",
  hint: "The number of (work) days of a month"
};
sim.model.v.nmrOfFirms = {
  range: "PositiveInteger",
  initialValue: 100,
  label: "Number of firms"
};
sim.model.v.nmrOfHouseh = {
  range: "PositiveInteger",
  initialValue: 1000,
  label: "Number of households"
};
sim.model.v.nmrOfPrefSupp = {
  range: "PositiveInteger",
  initialValue: 7,
  label: "Nmr.pref.suppl./ househ.",
  hint: "The number of preferred suppliers per household"
};
sim.model.v.initialAmountPerHousehold = {
  range: "Decimal",
  initialValue: 98.78,
  decimalPlaces: 2,
  label: "Initial amount / househ.",
  hint: "The initial liquidity per household"
};

/*******************************************************************************
 * Define Initial State
 ******************************************************************************/
sim.scenario.setupInitialState = function () {
  var i, j, firms, firm, supplierIDs, prefSuppliers, hh, employerIDs, eFirm;
  sim.scenario.initialState.events = [ {
      typeName: "StartOfMonth",
      occTime: 1
    },
    {
      typeName: "EachDay",
      occTime: 1
    },
    {
      typeName: "EndOfMonth",
      occTime: sim.v.daysOfMonth
    }
  ];
  // Create Firms
  for ( i = 1; i <= sim.v.nmrOfFirms; i += 1 ) {
    firm = new Firm( {
      id: i,
      name: "F" + i,
      money: 0,
      reserve: 0,
      inventoryLevel: 50,
      consumptionGoodPrice: 1 * ( ( rand.uniform( 0, 1 ) - 0.5 ) / 50 + 1 ),
      demand: 0,
      workers: [],
      wageRate: 52 * ( ( rand.uniform( 0, 1 ) - 0.5 ) / 50 + 1 ),
      openPosition: false,
      filledPosition: false,
      lastOpenPosition: 0,
      closePosition: false,
      startPlanning: 24 + rand.uniformInt( 0, 84 )
    } );
    sim.addObject( firm );
  }
  firms = cLASS[ "Firm" ].instances;
  supplierIDs = Object.keys( firms );
  employerIDs = Object.keys( firms );
  for ( i = 1; i <= sim.v.nmrOfHouseh; i += 1 ) {
    // Randomly select n Firms the Household will be able to buy products from
    prefSuppliers = [];
    rand.shuffleArray( supplierIDs );
    j = 0;
    do {
      firm = firms[ supplierIDs[ j ] ];
      if ( !prefSuppliers.includes( firm ) ) {
        prefSuppliers.push( firm );
        j += 1;
      }
    } while ( j < Math.min( sim.v.nmrOfPrefSupp, supplierIDs.length ) );

    // Select employer guaranteeing one worker per firm
    if ( i <= sim.v.nmrOfFirms ) {
      eFirm =
        firms[ employerIDs.splice(
          rand.uniformInt( 0, employerIDs.length - 1 ), 1 )[ 0 ] ];
    } else {
      eFirm = firms[ supplierIDs[
        rand.uniformInt( 0, supplierIDs.length - 1 ) ] ];
    }

    // Create Households
    hh = new Household( {
      id: sim.v.nmrOfFirms + i,
      name: "HH" + i,
      employed: true,
      employer: eFirm,
      reservationWage: 0,
      receivedWage: 52,
      money: sim.v.initialAmountPerHousehold,
      dailyDemand: 0,
      preferredSuppliers: prefSuppliers.clone(),
      blacklistedSuppliers: {}
    } );

    sim.addObject( hh );

    // Add household into the employer's working list
    eFirm.workers.push( hh );
  }
};

/*******************************************************************************
 * Define Experiment
 ******************************************************************************/
// sim.experiment.parameters = [{
// name: "n",
// values: [4, 5, 6, 7]
// }, {
// name: "money",
// values: [98.78, 1.00, 1000.00]
// }];
// sim.experiment.replications = 5;
// sim.experiment.seeds = [7836, 2893, 6235, 3827, 1432]
/*******************************************************************************
 * Define Output Statistics Variables
 ******************************************************************************/
sim.model.statistics = {
  // "money": {
  // range: "PositiveDecimal",
  // label: "Average Firms liquidity",
  // initialValue: 0,
  // showTimeSeries: true,
  // computeOnlyAtEnd: false,
  // expression: function () {
  // var total = 0;
  // var firms = cLASS["Firm"].instances;
  // Object.keys( firms ).forEach( function ( objId ) {
  // total += firms[objId].money;
  // } );
  //
  // return total / Object.keys( firms ).length;
  // }
  // },
  // "inventoryLevel": {
  // range: "PositiveDecimal",
  // label: "Average Inventory",
  // initialValue: 0,
  // showTimeSeries: true,
  // computeOnlyAtEnd: false,
  // expression: function () {
  // var total = 0;
  // var firms = cLASS["Firm"].instances;
  // Object.keys( firms ).forEach( function ( objId ) {
  // total += firms[objId].inventoryLevel;
  // } );
  //
  // return total / Object.keys( firms ).length;
  // }
  // },
  // "workers": {
  // range: "PositiveDecimal",
  // label: "Average number of workers",
  // initialValue: 0,
  // showTimeSeries: true,
  // computeOnlyAtEnd: false,
  // expression: function () {
  // var total = 0;
  // var firms = cLASS["Firm"].instances;
  // Object.keys( firms ).forEach( function ( objId ) {
  // total += firms[objId].workers.length;
  // } );
  //
  // return total / Object.keys( firms ).length;
  // }
  // },
  "consumptionGoodPrice": {
    range: "PositiveDecimal",
    label: "Average Price",
    initialValue: 0,
    showTimeSeries: true,
    computeOnlyAtEnd: false,
    expression: function () {
      var total = 0;
      var firms = cLASS[ "Firm" ].instances;
      Object.keys( firms ).forEach( function ( objId ) {
        total += firms[ objId ].consumptionGoodPrice;
      } );
      return total / Object.keys( firms ).length;
    }
  },
  "wage": {
    range: "PositiveDecimal",
    label: "Average Wage (normalized)",
    initialValue: 0,
    showTimeSeries: true,
    computeOnlyAtEnd: false,
    expression: function () {
      var total = 0,
        i = 0;
      var houseHolds = cLASS[ "Household" ].instances,
        hhIDs = Object.keys( houseHolds ),
        N = hhIDs.length;
      for ( i = 0; i < N; i += 1 ) {
        total += houseHolds[ hhIDs[ i ] ].receivedWage;
      }
      return total / N / 52; // normalize by dividing by 52
    }
  },
  "employment": {
    range: "PositiveDecimal",
    label: "% Employment",
    initialValue: 0,
    showTimeSeries: true,
    computeOnlyAtEnd: false,
    expression: function () {
      var total = 0;
      var hhs = cLASS[ "Household" ].instances;
      Object.keys( hhs ).forEach( function ( objId ) {
        if ( hhs[ objId ].employed ) {
          total += 1;
        }
      } );
      return total / Object.keys( hhs ).length;
    }
  }
};