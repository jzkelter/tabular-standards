/*******************************************************************************
 * EachDay event class
 *
 * @copyright Copyright 2018 Brandenburg University of Technology, Germany
 * @license The MIT License (MIT)
 * @author Luis Gustavo Nardin
 * @author Gerd Wagner
 ******************************************************************************/
var EachDay = new cLASS( {
  Name: "EachDay",
  shortLabel: "D",
  supertypeName: "eVENT",
  properties: {},
  methods: {
    "onEvent": function () {
      var followupEvents = [];
      var iHHs = cLASS[ "Household" ].instances;
      var kHHs = Object.keys( iHHs );
      var iFirms = cLASS[ "Firm" ].instances;

      sim.v.day = sim.v.daysOfMonth -
        ( ( sim.v.month * sim.v.daysOfMonth ) - this.occTime );

      if ( sim.v.verbose ) {
        console.log( "Day " + sim.v.day );
      }

      // Households Consume Consumption Goods
      rand.shuffleArray( kHHs );

      kHHs.forEach( function ( objId ) {
        iHHs[ objId ].buyConsumptionGoods();
      } );

      // Firms Produce Consumption Goods
      Object.keys( iFirms ).forEach( function ( objId ) {
        iFirms[ objId ].produceConsumptionGoods();
      } );

      return followupEvents;
    }
  }
} );
EachDay.priority = 1;

EachDay.recurrence = function () {
  return 1;
};