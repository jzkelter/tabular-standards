/*******************************************************************************
 * End of the Month event class
 *
 * @copyright Copyright 2018 Brandenburg University of Technology, Germany
 * @license The MIT License (MIT)
 * @author Luis Gustavo Nardin
 * @author Gerd Wagner
 ******************************************************************************/
var EndOfMonth = new cLASS( {
  Name: "EndOfMonth",
  shortLabel: "EM",
  supertypeName: "eVENT",
  properties: {},
  methods: {
    "onEvent": function () {
      var followupEvents = [];
      var iFirms = cLASS[ "Firm" ].instances;
      var iHHs = cLASS[ "Household" ].instances;
      var firm, hh;

      if ( sim.v.verbose ) {
        console.log( "End of Month " + sim.v.month );
      }

      Object.keys( iFirms ).forEach( function ( objId ) {
        firm = iFirms[ objId ];

        // Decide the reserve for bad times
        firm.decideReserve();
        // Distribute the profit
        firm.distributeProfits();
      } );

      Object.keys( iFirms ).forEach( function ( objId ) {
        firm = iFirms[ objId ];

        // Pay wages
        firm.payWages();
      } );

      Object.keys( iHHs ).forEach( function ( objId ) {
        hh = iHHs[ objId ];

        // Adjust reservation wage
        hh.adjustReservationWage();
      } );

      Object.keys( iFirms ).forEach( function ( objId ) {
        firm = iFirms[ objId ];
        // Consider firing a worker
        firm.decideFireWorker();
      } );

      return followupEvents;
    }
  }
} );
EndOfMonth.priority = 0;

EndOfMonth.recurrence = function () {
  return sim.v.daysOfMonth;
};