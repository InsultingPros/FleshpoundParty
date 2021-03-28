class FPPPlayerController extends KFPlayerController;


function SetPawnClass(string inClass, string inCharacter)
{
  PawnClass = Class'FleshpoundParty.FPPHumanPawn'; // your pawn class here
  inCharacter = Class'FleshpoundParty'.Static.GetValidCharacter(inCharacter);
  PawnSetupRecord = class'xUtil'.static.FindPlayerRecord(inCharacter);
  PlayerReplicationInfo.SetCharacterName(inCharacter);
}