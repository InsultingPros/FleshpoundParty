class FPPHumanPawn extends KFHumanPawn;
// config(FleshpoundParty);

// var FPPSettings FPPSettings;
// var config bool bEnableTraderSpeedBoost;


// function ReadConfig()
// {
//   if(FPPSettings == none)
// 	FPPSettings = new(none) class'FPPSettings';
  
// 	bEnableTraderSpeedBoost = FPPSettings.bEnableTraderSpeedBoost;
// }
// Changed MaxCarryWeight to default.MaxCarryWeight, so support with 15/24 weight will move with same speed as other perk 15/15
// Support with 24/24 weight now will move slower
// Other code strings are just copy-pasted


simulated function ModifyVelocity(float DeltaTime, vector OldVelocity)
{
  local float WeightMod, HealthMod, MovementMod;
  local float EncumbrancePercentage;
  local Inventory Inv;
  local KF_StoryInventoryItem StoryInv;
  local int c;

  super(KFPawn).ModifyVelocity(DeltaTime, OldVelocity);

  if ( Controller != none )
  {
    // Calculate encumbrance, but cap it to the maxcarryweight so when we use dev weapon cheats we don't move mega slow
    EncumbrancePercentage = (FMin(CurrentWeight, MaxCarryWeight) / default.MaxCarryWeight); //changed MaxCarryWeight to default.MaxCarryWeight
    // Calculate the weight modifier to speed
    WeightMod = (1.0 - (EncumbrancePercentage * WeightSpeedModifier));
    // Calculate the health modifier to speed
    HealthMod = ((Health/HealthMax) * HealthSpeedModifier) + (1.0 - HealthSpeedModifier);

    // Apply all the modifiers
    GroundSpeed = default.GroundSpeed * HealthMod;
    GroundSpeed *= WeightMod;
    GroundSpeed += InventorySpeedModifier;

    if (KFPlayerReplicationInfo(PlayerReplicationInfo) != none && KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none)
      MovementMod = KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetMovementSpeedModifier(KFPlayerReplicationInfo(PlayerReplicationInfo), KFGameReplicationInfo(Level.GRI));
    else
      MovementMod = 1.0;
  
    GroundSpeed *= MovementMod;
    AccelRate = default.AccelRate * MovementMod;

    // Give the pawn's inventory items a chance to modify his movement speed
    for (Inv=Inventory; Inv!=None && ++c < 1000; Inv=Inv.Inventory)
    {
      GroundSpeed *= Inv.GetMovementModifierFor(self);
      StoryInv = KF_StoryInventoryItem(Inv);
      if (StoryInv != none && StoryInv.bUseForcedGroundSpeed)
      {
        GroundSpeed = StoryInv.ForcedGroundSpeed;
        return;
      }
    }

    if (!KFGameReplicationInfo(Level.GRI).bWaveInProgress)
      GroundSpeed *= 1.75 * KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetMovementSpeedModifier(KFPlayerReplicationInfo(PlayerReplicationInfo), KFGameReplicationInfo(Level.GRI));
  }
}