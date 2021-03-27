class FPPGameType extends KFGameType;


var int MDTP;
var bool bCheck;


event PreBeginPlay()
{
  local ZombieVolume ZV;

  super.PreBeginPlay();

  foreach AllActors(Class'ZombieVolume', ZV)
    ZV.MinDistanceToPlayer = MDTP;

  bCheck = true;
}


event InitGame( string Options, out string Error )
{
  local int ConfigMaxPlayers;
  local ShopVolume SH;

  ConfigMaxPlayers = default.MaxPlayers;
  super.InitGame(Options, Error);
  MaxPlayers = Clamp(GetIntOption( Options, "MaxPlayers", ConfigMaxPlayers ),0,12);
  default.MaxPlayers = Clamp( ConfigMaxPlayers, 0, 12 );

  foreach AllActors(Class'ShopVolume',SH)
  {
    SH.bAlwaysClosed = false;
    SH.bAlwaysEnabled= true;
  }
}


simulated function PrepareSpecialSquadsFromGameType()
{
  local int i;

  if (KFGameLength == GL_Short)
  {
    FinalWave = 5;

    for (i=0; i<FinalWave; i++)
    {
      Waves[i] = ShortWaves[i];
      SpecialSquads[i] = ShortSpecialSquads[i];
    }
  }

  else if (KFGameLength == GL_Normal)
  {
    FinalWave = 8;

    for (i=0; i<FinalWave; i++)
    {
      Waves[i] = NormalWaves[i];
      SpecialSquads[i] = NormalSpecialSquads[i];
    }
  }

  else if (KFGameLength == GL_Long)
  {
    FinalWave = 11;

    for (i=0; i<FinalWave; i++)
    {
      Waves[i] = LongWaves[i];
      SpecialSquads[i] = LongSpecialSquads[i];
    }
  }
}


simulated function PrepareSpecialSquadsFromCollection()
{
  local int i;

  if (KFGameLength == GL_Short)
  {
    FinalWave = 5;

    for (i=0; i<FinalWave; i++)
    {
      Waves[i] = ShortWaves[i];
      MonsterCollection.default.SpecialSquads[i] = MonsterCollection.default.ShortSpecialSquads[i];
    }
  }

  else if (KFGameLength == GL_Normal)
  {
    FinalWave = 8;

    for (i=0; i<FinalWave; i++)
    {
      Waves[i] = NormalWaves[i];
      MonsterCollection.default.SpecialSquads[i] = MonsterCollection.default.NormalSpecialSquads[i];
    }
  }

  else if (KFGameLength == GL_Long)
  {
    FinalWave = 11;

    for (i=0; i<FinalWave; i++)
    {
      Waves[i] = LongWaves[i];
      MonsterCollection.default.SpecialSquads[i] = MonsterCollection.default.LongSpecialSquads[i];
    }
  }
}


function Timer()
{
  local Controller C;

  super.Timer();

  if (!bWaveInProgress && waveNum <= finalWave && bCheck)
  {
    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
      if (C.Pawn != None && C.Pawn.Health > 0)
      {
        C.Pawn.ClientMessage("@шALL TRADERS OPEN, FGTS!");
      }
    }

    bCheck = false;
  }

  if (bWaveInProgress && waveNum <= finalWave)
  {
    bCheck = true;
  }
}


defaultproperties
{
  GameName="Fleshpound Party v2"
  Description="The premise is simple: you (and, hopefully, your team) against hordes of fleshpounds and their minion zeds. Have fun!"
  ShortWaves(0)=(WaveMask=1970179,WaveMaxMonsters=30,WaveDifficulty=7.000000)
  ShortWaves(1)=(WaveMask=201326591,WaveMaxMonsters=35,WaveDifficulty=7.000000)
  ShortWaves(2)=(WaveMask=201326591,WaveMaxMonsters=40,WaveDifficulty=7.000000)
  ShortWaves(3)=(WaveMask=201326591,WaveMaxMonsters=40,WaveDifficulty=7.000000)
  ShortWaves(4)=(WaveMask=8388608,WaveMaxMonsters=6,WaveDuration=255,WaveDifficulty=7.000000)
  NormalWaves(0)=(WaveMask=1970179,WaveMaxMonsters=30,WaveDifficulty=7.000000)
  NormalWaves(1)=(WaveMask=201326591,WaveMaxMonsters=35,WaveDifficulty=7.000000)
  NormalWaves(2)=(WaveMask=201326591,WaveMaxMonsters=40,WaveDifficulty=7.000000)
  NormalWaves(3)=(WaveMask=201326591,WaveMaxMonsters=40,WaveDifficulty=7.000000)
  NormalWaves(4)=(WaveMask=201326591,WaveMaxMonsters=45,WaveDifficulty=7.000000)
  NormalWaves(5)=(WaveMask=201326591,WaveMaxMonsters=45,WaveDifficulty=7.000000)
  NormalWaves(6)=(WaveMask=201326591,WaveMaxMonsters=45,WaveDifficulty=7.000000)
  NormalWaves(7)=(WaveMask=8388608,WaveMaxMonsters=6,WaveDuration=255,WaveDifficulty=7.000000)
  LongWaves(0)=(WaveMask=1970179,WaveMaxMonsters=30,WaveDifficulty=7.000000)
  LongWaves(1)=(WaveMask=201326591,WaveMaxMonsters=35,WaveDifficulty=7.000000)
  LongWaves(2)=(WaveMask=201326591,WaveMaxMonsters=40,WaveDifficulty=7.000000)
  LongWaves(3)=(WaveMask=201326591,WaveMaxMonsters=45,WaveDifficulty=7.000000)
  LongWaves(4)=(WaveMask=201326591,WaveMaxMonsters=50,WaveDifficulty=7.000000)
  LongWaves(5)=(WaveMask=201326591,WaveMaxMonsters=55,WaveDifficulty=7.000000)
  LongWaves(6)=(WaveMask=201326591,WaveMaxMonsters=60,WaveDifficulty=7.000000)
  LongWaves(7)=(WaveMask=201326591,WaveMaxMonsters=65,WaveDifficulty=7.000000)
  LongWaves(8)=(WaveMask=201326591,WaveMaxMonsters=70,WaveDifficulty=7.000000)
  LongWaves(9)=(WaveMask=201326591,WaveMaxMonsters=75,WaveDifficulty=7.000000)
  LongWaves(10)=(WaveMask=8388608,WaveMaxMonsters=6,WaveDuration=255,WaveDifficulty=7.000000)
  StartingCashHell=3000
  MinRespawnCashHell=1500
  StandardMonsterSquads(25)="2F"
  StandardMaxZombiesOnce=48
  MonsterSquad(25)="2F"
  MaxZombiesOnce=48
  MDTP=1200
}