class Helper extends Info
  config(FleshpoundParty)
  abstract;

// colors and tags, maybe later I will convert this to a config array
struct ColorRecord
{
  var string ColorName;                   // color name, for comfort
  var string ColorTag;                    // color tag
  var Color Color;                        // RGBA values
};
var config array<ColorRecord> ColorList;  // color list
var array<string> TagsToRemove;           // list of unnesesary tags to remove

var config string MSG_Trader;             // all traders are open!
var config string MSG_BigZeds;            // war big zeds wave
var config string MSG_Fleshpounds;        // warn FP wave
var config string MSG_Patriarch;          // warn Pat wave

// controlls what messages players needs to see during trader time
static function string TraderMessages(string msg)
{
  switch(msg)
  {
    case "trader":
      msg = default.MSG_Trader;
      break;
    case "dtf":
      msg = default.MSG_BigZeds;
      break;
    case "fp":
      msg = default.MSG_Fleshpounds;
      break;
    case "pat":
      msg = default.MSG_Patriarch;
      break;
    default:
      // fallback warning
      msg = "%rFleshpound Party HELPER: We shouldn't get to this so this means you used WRONG modifier!";
  }
  return ParseTags(msg);
}


// help list for zed spawning
static function TellAbout(PlayerController pc, FleshpoundParty FPP, string whatToTell)
{
  local int i;
  local array<string> StrTemp;

  switch(whatToTell)
  {
    default:
      // fallback warning
      StrTemp[0] = "%rFleshpound Party HELPER: We shouldn't get to this so this means you used WRONG modifier!";
  }

  for(i = 0; i < StrTemp.Length; i++)
  {
    FPP.SendMessage(pc,StrTemp[i],false);
  }
}

// converts color tags to colors
static function string ParseTags(string input)
{
  local int i;
  local array<ColorRecord> Temp;
  local string strTemp;

  Temp = default.ColorList;
  for(i=0; i<Temp.Length; i++)
  {
    strTemp = class'GameInfo'.Static.MakeColorCode(Temp[i].Color);
    ReplaceText(input, Temp[i].ColorTag, strTemp);
  }
  return input;
}

// removes color tags
static function string StripTags(string input)
{
  local int i;

  for(i=0; i<default.TagsToRemove.Length; i++)
  {
    ReplaceText(input, default.TagsToRemove[i], "");
  }
  return input;
}

// removes colors from a string
static function string StripColor(string s)
{
  local int p;

  p = InStr(s,chr(27));
  while ( p>=0 )
  {
    s = left(s,p)$mid(S,p+4);
     p = InStr(s,Chr(27));
  }
  return s;
}

static function string ParsePlayerName(PlayerController pc)
{
  if(pc != none || pc.playerReplicationInfo != none)
    return "%b" $ StripTags(pc.playerReplicationInfo.PlayerName) $ "%w";
}

defaultproperties
{
  TagsToRemove=("%r","%o","%y","%g","%b","%v","%w","%t","%p","^0","^1","^2","^3","^4","^5","^6","^7","^8","^9")
}