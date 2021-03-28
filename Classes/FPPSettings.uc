class FPPSettings extends Object
  config(FleshpoundParty);


var config bool bForceMDTP;						// force our config MDTP
// var config int MDTP;				// minimal spawn distance

var config bool bUseOriginalFakes;
var config int FakedPlayers;	// all other methods doesnt work, so..

var config bool bForceSpawnrate;					// force our config spawnrate
var config float ForcedSpawnRate;			// change spawnrate
var config float PeakSpawnTime;
var config float BaseSpawnTime;
var config float SineModMultiplier;

// var config int MaxZeds;			// max zeds at spawned at once
var config float Post6ZedsPerPlayer;		// modifier for zed count (>6 player team)

var config int TraderTime;		// set our desired trader time
var config int StartingDosh;		// doshhhh
var config int MinRespawnDosh;	// doshhhh

var config bool bDisableSlomo;					// disables slomo
var config bool bEnablePlayerSlomo;					// enables player death slomo
var config bool bDisableAntiblocker;				// disables player collision during trader

var config string MSG_Trader;					// all traders are open!

var config string MSG_BigZeds;					//war big zeds wave
var config string MSG_Fleshpounds;				// warn FP wave
var config string MSG_Patriarch;				// warn Pat wave

var config color RColour,GColour,BColour,WColour,YColour,PColour;


defaultproperties
{
  // MDTP=500
  bForceMDTP=true

  bUseOriginalFakes=true
  FakedPlayers=0

  bForceSpawnrate=false
  ForcedSpawnRate=1.5
  PeakSpawnTime=0.6
  BaseSpawnTime=0.3
  SineModMultiplier=1

  // MaxZeds=48
  Post6ZedsPerPlayer=0.400000

  TraderTime=45
  StartingDosh=8000
  MinRespawnDosh=8000

  bDisableSlomo=true
  bEnablePlayerSlomo=true
  bDisableAntiblocker=false

  MSG_Trader="%bALL %yTRADERS %bARE OPEN!"
  MSG_BigZeds="%yOnly %rBIG %yzeds will appear on this wave!"
  MSG_Fleshpounds="%yOnly %rFleshpounds %ywill appear on this wave!"
  MSG_Patriarch="%bBehold, the %rPatriarch%w is back! And he's got some new tricks!"

  RColour=(B=1,G=1,R=200,A=255)
  GColour=(B=1,G=200,R=1,A=255)
  BColour=(B=252,G=111,R=62,A=255)
  WColour=(B=200,G=200,R=200,A=255)
  YColour=(B=1,G=200,R=200,A=255)
  PColour=(B=200,G=1,R=200,A=255)
}