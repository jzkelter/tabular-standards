/*******************************************************************************
 * Beginning of the Month event class
 *
 * @copyright Copyright 2018 Brandenburg University of Technology, Germany
 * @license The MIT License (MIT)
 * @author Luis Gustavo Nardin
 * @author Gerd Wagner
 ******************************************************************************/
var StartOfMonth = new cLASS( {
  Name: "StartOfMonth",
  shortLabel: "BM",
  supertypeName: "eVENT",
  properties: {},
  methods: {
    "onEvent": function () {
      var followupEvents = [];
      var iHHs = cLASS[ "Household" ].instances;
      var kHHs = Object.keys( iHHs );
      var iFirms = cLASS[ "Firm" ].instances;
      var hh, firm;

      sim.v.month =
        Math.floor( this.occTime / sim.v.daysOfMonth ) + 1;

      if ( sim.v.verbose ) {
        console.log( "Start of Month " + sim.v.month );
      }

      // Firms
      Object.keys( iFirms ).forEach( function ( objId ) {
        firm = iFirms[ objId ];

        if ( sim.v.month > firm.startPlanning ) {
          // Adjust the wage rate
          firm.adjustWageRate( sim.v.month );

          // Open or close a job position
          firm.adjustJobPositions( sim.v.month );

          // Adjust consumption goods price
          firm.adjustConsumptionGoodPrice( sim.v.daysOfMonth );

          // Reset monthly demand
          firm.resetMonthDemand();
        }
      } );

      // Households
      rand.shuffleArray( kHHs );

      kHHs.forEach( function ( objId ) {
        hh = iHHs[ objId ];

        // Search for a cheaper vendor
        firm = hh.searchCheaperVendor();

        // Replaces a limiting vendor
        hh.searchDeliveryCapableVendor( firm );

        // Search for a (better) job
        if ( !hh.employed ) {
          hh.searchJob();
        } else {
          hh.searchBetterPaidJob();
        }

        // Calculate daily demand
        hh.decideConsumption( sim.v.daysOfMonth );
      } );

      return followupEvents;
    }
  }
} );
StartOfMonth.priority = 2;

StartOfMonth.recurrence = function () {
  return sim.v.daysOfMonth;
};