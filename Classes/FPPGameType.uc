class FPPGameType extends KFGameType;


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


defaultproperties
{
  GameName="Fleshpound Party v2"
  StartingCashHell=3000
  MinRespawnCashHell=1500
  StandardMaxZombiesOnce=48
  MaxZombiesOnce=48
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
  StandardMonsterSquads(25)="2F"
  MonsterSquad(25)="2F"
}