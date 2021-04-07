class FPPLastManStandingMsg extends KFLastManStandingMsg
  abstract;

// #exec AUDIO IMPORT FILE="Sounds\lastmandstanding.wav" NAME="lastmandstanding" GROUP="FX"
 
var localized string FPPLastManStandStr;

static function string GetString(optional int Switch,optional PlayerReplicationInfo RelatedPRI_1,optional PlayerReplicationInfo RelatedPRI_2,optional Object OptionalObject)
{
  return Default.FPPLastManStandStr;
}

defaultproperties
{
  FPPLastManStandStr="You are the last man standing"
  FontSize=1
  DrawColor=(R=255,G=25,B=25,A=230)
  PosY=0.2
  bIsConsoleMessage=True
  Lifetime=6
}