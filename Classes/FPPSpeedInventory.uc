class FPPSpeedInventory extends Inventory;

var float fPenalty;

replication
{
  reliable if (Role == ROLE_Authority)
    fPenalty;
}


simulated function float GetMovementModifierFor(Pawn InPawn)
{
  return fPenalty;
}