class FPPSettings extends Info
  config(FleshpoundParty);

var config bool bForceMDTP;           // force our config MDTP
// var config int MDTP;               // minimal spawn distance

var config bool bUseOriginalFakes;
var config int FakedPlayers;          // all other methods doesnt work, so..

var config float PeakSpawnTime;        
var config float BaseSpawnTime;        
var config float SineModMultiplier;

//var config int MaxZeds;             // max zeds at spawned at once
var config float Post6ZedsPerPlayer;  // modifier for zed count (>6 player team)

var config int TraderTime;            // set our desired trader time
var config float TraderSpeedBoost;    // how much to speed up
var config int StartingDosh;          // doshhhh
var config int MinRespawnDosh;        // doshhhh

var config bool bDisableSlomo;        // disables slomo
var config bool bEnablePlayerSlomo;   // enables player death slomo
var config bool bDisableAntiblocker;  // disables player collision during trader


defaultproperties
{
  bHidden=true
  // MDTP=500
  bForceMDTP=true

  bUseOriginalFakes=true
  FakedPlayers=0

  PeakSpawnTime=0.6
  BaseSpawnTime=0.3
  SineModMultiplier=1

  Post6ZedsPerPlayer=0.400000

  TraderTime=45
  TraderSpeedBoost=1.75
  StartingDosh=8000
  MinRespawnDosh=8000

  bDisableSlomo=true
  bEnablePlayerSlomo=true
  bDisableAntiblocker=false
}