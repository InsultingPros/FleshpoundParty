class FPPSpeedInventory extends Inventory;

simulated function float GetMovementModifierFor(Pawn InPawn)
{
  return class'Helper'.static.GetSpeedMod();
}