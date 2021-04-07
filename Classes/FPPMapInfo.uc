class FPPMapInfo extends Info
  config(FleshpoundParty);

struct MapInfoStruct
{
  var string MapName;
  var float Difficulty; // map difficulty, where 0 is normal difficulty, -1.0 - easiest, 2.0 - twice harder that normal
  var int MaxZombiesOnce;
};
var config array<MapInfoStruct> MapInfo;