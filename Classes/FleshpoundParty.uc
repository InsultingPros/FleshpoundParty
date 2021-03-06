class FleshpoundParty extends KFGameType;

// #exec AUDIO IMPORT FILE="Sounds\lastmanstanding.wav" NAME="lastmanstanding" GROUP="FX"

const VERSION = 2.19;    // mod version

var FPPSettings FPPSettings;
var FPPMapInfo FPPMapInfo;

var transient float OriginalSpawnrate;
var transient float DebugCurrentSR;
var transient int iTemp;
var transient int WavePlayerCount;

var bool bBossView;             // determine boss camera
var float BossViewBackTime;

var bool bForceMDTP;            // force our config MDTP
// var int MDTP;                // minimal spawn distance

var bool bUseOriginalFakes;
var int FakedPlayers;           // all other methods doesnt work, so..

var float PeakSpawnTime;
var float BaseSpawnTime;  
var float SineModMultiplier;

//var int MaxZeds;              // max zeds at spawned at once
var float Post6ZedsPerPlayer;   // modifier for zed count (>6 player team)

var int TraderTime;             // set our desired trader time
var float TraderSpeedBoost;     // trader speedup
var int StartingDosh;           // doshhhh
var int MinRespawnDosh;         // doshhhh

var bool bDisableSlomo;         // disables slomo
var bool bEnablePlayerSlomo;    // enables slomo trigger on player death
var bool bDisableAntiblocker;   // disables player collision during trader

//============================== DISABLED / REMOVED ==============================
function UpdateGameLength();                          // not used anymore
function CheckHarchierAchievement();                  // fuck Harchier
function ShowPathTo(PlayerController P, int TeamNum);  // all traders are open, no need for a whisp
function NotifyGameEvent(int EventNumIn);              // TWI just removed it..

function WaveController();                            // stub function
// removed steamdata uploading
function Timer()
{
  super(GameInfo).Timer();
}
// TO_DO: no more annoying "No Late Joiner Accepted" lines.

//=========================================================================
// changed max players and added gamelenth support for cmdline
event InitGame( string Options, out string Error )
{
  local KFLevelRules KFLRit;
  local ShopVolume SH;
  local ZombieVolume ZV;
  local string InOpt;

  super(GameInfo).InitGame(Options, Error);

  MaxPlayers = Clamp(GetIntOption( Options, "MaxPlayers", MaxPlayers ),0,6);
  default.MaxPlayers = Clamp( default.MaxPlayers, 0, 6 );

  // we can change gamelenght with mapvote.
  KFGameLength = GetIntOption(Options, "GameLength", KFGameLength);
  switch(KFGameLength)
  {
    case 0:
    case 1:
    case 3:
      KFGameLength = 1;
      break;
    default:
      KFGameLength = 2;
  }

  foreach DynamicActors(class'KFLevelRules',KFLRit)
  {
    if(KFLRules == none)
      KFLRules = KFLRit;
    else Warn("MULTIPLE KFLEVELRULES FOUND!!!!!");
  }

  // objective mode check removed
  foreach AllActors(class'ShopVolume',SH)
  {
    ShopList[ShopList.Length] = SH;
  }

  foreach DynamicActors(class'ZombieVolume',ZV)
  {
    ZedSpawnList[ZedSpawnList.Length] = ZV;
  }

  // provide default rules if mapper did not need custom one
  if(KFLRules == none)
    KFLRules = spawn(class'KFLevelRules');

  log("KFLRules = "$KFLRules);

  InOpt = ParseOption(Options, "UseBots");
  if ( InOpt != "" )
  {
    bNoBots = bool(InOpt);
  }

  log("Game length = "$KFGameLength);

  // removed UpdateGameLength(), bCustomGameLength and custom gamelenght check
  MonsterCollection = class'FPMonstersCollection';
  ReadConfig();

  // Set up the default game type settings
  bUseEndGameBoss = true;
  bRespawnOnBoss = false;
  if( StandardMonsterClasses.Length > 0 )
  {
    MonsterClasses = StandardMonsterClasses;
  }

  MonsterSquad = StandardMonsterSquads;
  TimeBetweenWaves = TraderTime;          // removed difficulty based values
  StartingCash = StartingDosh;            // apply dosh value from config
  MinRespawnCash = MinRespawnDosh;        // apply dosh value from config
  InitialWave = 0;

  PrepareSpecialSquads();
  LoadUpMonsterList();
}

function ReadConfig()
{
  local int i, value;
  local float f;
  local string mapName;
  local KFLevelRules KFLR;

  OriginalSpawnrate = KFLRules.WaveSpawnPeriod;

  if(FPPSettings == none)
    FPPSettings = spawn(class'FPPSettings');

  //MDTP = FPPSettings.MDTP;
  //MaxZeds = FPPSettings.MaxZeds;
  StartingDosh = FPPSettings.StartingDosh;
  MinRespawnDosh = FPPSettings.MinRespawnDosh;
  FakedPlayers = FPPSettings.FakedPlayers;
  TraderTime = FPPSettings.TraderTime;
  TraderSpeedBoost = FPPSettings.TraderSpeedBoost;
  PeakSpawnTime = FPPSettings.PeakSpawnTime;
  BaseSpawnTime = FPPSettings.BaseSpawnTime;
  SineModMultiplier = FPPSettings.SineModMultiplier;
  Post6ZedsPerPlayer = FPPSettings.Post6ZedsPerPlayer;
  bUseOriginalFakes = FPPSettings.bUseOriginalFakes;
  bDisableSlomo = FPPSettings.bDisableSlomo;
  bEnablePlayerSlomo = FPPSettings.bEnablePlayerSlomo;
  bDisableAntiblocker = FPPSettings.bDisableAntiblocker;
  bForceMDTP = FPPSettings.bForceMDTP;

  if(FPPMapInfo == none)
    FPPMapInfo = spawn(class'FPPMapInfo');

  mapName =  class'KFGameType'.static.GetCurrentMapName(Level);
  for(i=0; i<FPPMapInfo.MapInfo.Length; i++)
  {
    if(FPPMapInfo.MapInfo[i].MapName == mapName)
    {
      value = FPPMapInfo.MapInfo[i].MaxZombiesOnce;
      f = FPPMapInfo.MapInfo[i].Difficulty;
      break;
    }
  }

  value = clamp(value, 32, 96);
  StandardMaxZombiesOnce = value;
  MaxZombiesOnce = value;
  iTemp = value;
  MaxMonsters = Clamp(TotalMaxMonsters,5,value);

  foreach AllActors(Class'KFLevelRules',KFLR)
  {
    if(KFLR == none)
      continue;
    if(KFLR != none)
      break;
  }
  // if we have 0 Difficulty in MapInfo
  if(f == 0)
   {
    // do not touch fast maps
    if(KFLR.WaveSpawnPeriod < 3 && KFLR.WaveSpawnPeriod > 0.5)
      return;
    else
    {
      // speed up slow maps
      KFLR.WaveSpawnPeriod = 1.5;
      log("Fleshpound Party: Map spawnrate is forced to - "$1.5);
    }
  }
  else  // use our config value
  {
    f = fclamp(f,0.5,3.0);
    KFLR.WaveSpawnPeriod = f;
    log("Fleshpound Party: Map spawnrate is forced to - "$f);
  }
}

static event class<GameInfo> SetGameType(string MapName)
{
  if(Caps(Left(MapName, InStr(MapName, "-"))) ~= "KFO")
    return default.Class;
  return super.SetGameType(MapName);
}

// Apply MDTP
//=========================================================================
event PreBeginPlay()
{
  local ZombieVolume ZV;

  super.PreBeginPlay();
  //MDTP = Clamp(MDTP, 300, 800);

  if(!bForceMDTP)
    return;
  foreach AllActors(Class'ZombieVolume', ZV)
  {
    if(Level.Title == "KF-Biohazard" || Level.Title == "KF-Waterworks" || Level.Title == "KF-Departed")
      ZV.MinDistanceToPlayer = 800;
    else if(Level.Title == "Siren's Belch Brewery")
    {
      if(ZV.MinDistanceToPlayer < 200)
        ZV.MinDistanceToPlayer = 2000;
      if(ZV.MinDistanceToPlayer == 400)
        ZV.MinDistanceToPlayer = 600;
    }
  }
}

//put on a timer to automatically adds to or removes 4 zeds from MaxZeds depending on alive players
//with the 28 MaxZeds being the base value for 1 player
//however there is a limitation which doesn't apply the MaxZeds changes mid-wave and only on wave change
function AdjustMaxZeds()
{
  MaxZombiesOnce = iTemp + (((AlivePlayersAmount() - 2) * 4)); //MaxZombiesOnce
}

//=========================================================================
// removed all steamstats checks
function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType)
{
  local KFPlayerReplicationInfo KFPRI;

  // Triggers zed time whenever a player dies
  if(Killed.bIsPlayer)
    PlayerDramaticEvent(1.0);

  if(!bDisableSlomo && PlayerController(Killer) != none)
  {
    KFPRI = KFPlayerReplicationInfo(Killer.PlayerReplicationInfo);

    // dont go further if we have disabled slomo
    if(KFMonster(KilledPawn) != none && Killed != Killer)
    {
      if(bZEDTimeActive && KFPRI != none && KFPRI.ClientVeteranSkill != none && KFPRI.ClientVeteranSkill.static.ZedTimeExtensions(KFPRI) > ZedTimeExtensionsUsed)
      {
        // Force Zed Time extension for every kill as long as the Player's Perk has Extensions left
        if(Level.TimeSeconds - LastZedTimeEvent > 0.05)
        {
          DramaticEvent(1.0);
          ZedTimeExtensionsUsed++;
        }
      }
      else if(Level.TimeSeconds - LastZedTimeEvent > 0.1)
      {
        if(Killer.Pawn != none && VSizeSquared(Killer.Pawn.Location - KilledPawn.Location) < 22500)
          DramaticEvent(0.05);
        else
          DramaticEvent(0.025);
      }
    }
  }
  if((MonsterController(Killed) != none) || (Monster(KilledPawn) != none))
  {
    ZombiesKilled++;
    KFGameReplicationInfo(GameReplicationInfo).MaxMonsters = Max(TotalMaxMonsters + NumMonsters - 1,0);
  }
  super(Invasion).Killed(Killer,Killed,KilledPawn,DamageType);
}

//=========================================================================
State MatchInProgress
{
  function TraderController()
  {
    // close Trader doors
    if(bTradingDoorsOpen)
    {
      CloseShops();
      TraderProblemLevel = 0;
    }
    if(TraderProblemLevel<4)
    {
      if(BootShopPlayers())
        TraderProblemLevel = 0;
      else
        TraderProblemLevel++;
    }
  }

  function Timer()
  {
    local Controller c;
    local KFMonster Monster;
    local bool bOneMessage;
    local Bot B;

    global.Timer();
    
    AdjustMaxZeds();
    if(bWaveBossInProgress || bWaveInProgress)
      TraderController();

    if ( Level.TimeSeconds > HintTime_1 && bTradingDoorsOpen && bShowHint_2 )
    {
      for ( c = Level.ControllerList; c != none; c = c.NextController )
      {
        if( c.Pawn != none && KFPlayerController(c) != none && c.Pawn.Health > 0 ) // added KFPlayerController check
        {
          KFPlayerController(c).CheckForHint(32);
          HintTime_2 = Level.TimeSeconds + 11;
        }
      }
      bShowHint_2 = false;
    }

    if ( Level.TimeSeconds > HintTime_2 && bTradingDoorsOpen && bShowHint_3 )
    {
      for ( c = Level.ControllerList; c != none; c = c.NextController )
      {
        if( c.Pawn != none && KFPlayerController(c) != none && c.Pawn.Health > 0 ) // added KFPlayerController check
        {
          KFPlayerController(c).CheckForHint(33);
        }
      }
      bShowHint_3 = false;
    }

    if ( !bFinalStartup )
    {
      bFinalStartup = true;
      PlayStartupMessage();
    }

    if ( NeedPlayers() && AddBot() && (RemainingBots > 0) )
      RemainingBots--;

    ElapsedTime++;
    GameReplicationInfo.ElapsedTime = ElapsedTime;

    if( !UpdateMonsterCount() )
    {
      EndGame(none,"TimeLimit");
      Return;
    }

    if(bUpdateViewTargs)
      UpdateViews();

    if (!bNoBots && !bBotsAdded)
    {
      if(KFGameReplicationInfo(GameReplicationInfo) != none)

      if((NumPlayers + NumBots) < MaxPlayers && KFGameReplicationInfo(GameReplicationInfo).PendingBots > 0 )
      {
        AddBots(1);
        KFGameReplicationInfo(GameReplicationInfo).PendingBots --;
      }

      if (KFGameReplicationInfo(GameReplicationInfo).PendingBots == 0)
      {
        bBotsAdded = true;
        return;
      }
    }

    // remove view camera from Pats who are killed not in final wave, look into DoBossDeath()
    if(bBossView && !bWaveBossInProgress && BossViewBackTime < Level.TimeSeconds)
    {
      bBossView = false;
      for ( c = Level.ControllerList; c != none; c = c.NextController )
        if( PlayerController(c) != none )
        {
          if( c.Pawn == none && !c.PlayerReplicationInfo.bOnlySpectator && bRespawnOnBoss )
            c.ServerReStartPlayer();

          if( c.Pawn != none )
          {
            PlayerController(c).SetViewTarget(c.Pawn);
            PlayerController(c).ClientSetViewTarget(c.Pawn);
          }

          else
          {
            PlayerController(c).SetViewTarget(c);
            PlayerController(c).ClientSetViewTarget(c);
          }

          PlayerController(c).bBehindView = false;
          PlayerController(c).ClientSetBehindView(false);
        }
    }

    // Pat wave.
    if( bWaveBossInProgress )
    {
      // set view camera on Pat when he spawns.
      if( !bHasSetViewYet && NumMonsters>0 )
      {
        bHasSetViewYet = true;
        for ( c = Level.ControllerList; c != none; c = c.NextController )
          if ( KFMonster(c.Pawn) != none && KFMonster(c.Pawn).MakeGrandEntry() )
          {
            ViewingBoss = KFMonster(c.Pawn);
            break;
          }

        if( ViewingBoss != none )
        {
          bBossView = true;
          ViewingBoss.bAlwaysRelevant = true;

          for ( c=Level.ControllerList; c != none; c=c.NextController )
          {
            if( PlayerController(c) != none )
            {
              PlayerController(c).SetViewTarget(ViewingBoss);
              PlayerController(c).ClientSetViewTarget(ViewingBoss);
              PlayerController(c).bBehindView = true;
              PlayerController(c).ClientSetBehindView(true);
              PlayerController(c).ClientSetMusic(BossBattleSong,MTRAN_FastFade);
            }

            if ( c.PlayerReplicationInfo != none && bRespawnOnBoss )
            {
              c.PlayerReplicationInfo.bOutOfLives = false;
              c.PlayerReplicationInfo.NumLives = 0;
              if ( (c.Pawn == none) && !c.PlayerReplicationInfo.bOnlySpectator && PlayerController(c)!=none )
                c.GotoState('PlayerWaiting');
            }
          }
        }
      }

      // remove view camera from pat.
      else if( bBossView && (ViewingBoss == none || (ViewingBoss != none && !ViewingBoss.bShotAnim) ) )
      {
        bBossView = false;
        ViewingBoss = none;
        for ( c = Level.ControllerList; c != none; c = c.NextController )
          if( PlayerController(c) != none )
          {
            if( c.Pawn == none && !c.PlayerReplicationInfo.bOnlySpectator && bRespawnOnBoss )
              c.ServerReStartPlayer();

            if( c.Pawn != none )
            {
              PlayerController(c).SetViewTarget(c.Pawn);
              PlayerController(c).ClientSetViewTarget(c.Pawn);
            }

            else
            {
              PlayerController(c).SetViewTarget(c);
              PlayerController(c).ClientSetViewTarget(c);
            }

            PlayerController(c).bBehindView = false;
            PlayerController(c).ClientSetBehindView(false);
          }
      }

      // all dead
      if(TotalMaxMonsters <= 0 || (Level.TimeSeconds > WaveEndTime))
      {
        if(NumMonsters <= 0)
          DoWaveEnd();
      }

      else AddBoss();//if (MaxMonsters - NumMonsters > 0) //if we can spawn more  
    }

    // normal wave
    else if(bWaveInProgress)
    {
      WaveTimeElapsed += 1.0;
      if(!MusicPlaying)
        StartGameMusic(true);
      if(TotalMaxMonsters <= 0 )
      {
        // added check for zed HP
        if(WaveNum > InitialWave && WaveNum < FinalWave-1)
        {
          if(NumMonsters <= 18)
          {
            foreach DynamicActors(class'KFMonster',Monster)
            {
              if(Monster == none)
                continue;
              if(!HasPathToAnyPlayer(Monster) || (Monster.Health > 0 && !Monster.bDeleteMe && Level.TimeSeconds - Monster.LastSeenOrRelevantTime > 8 && Monster.default.health <= 900))
              {
                Log("FleshpoundParty: Stuck zed to kill "$Monster.MenuName);
                Monster.Suicide();
              }
            }
          }
        }
        if(NumMonsters <= 0)
          DoWaveEnd();
      }

      // all monsters spawned
      else if ( NextMonsterTime < Level.TimeSeconds && (MaxMonsters<10 || (NumMonsters + NextSpawnSquad.Length <= MaxMonsters) ) )
      {
        WaveEndTime = Level.TimeSeconds + 160;
        if(!bDisableZedSpawning)
          AddSquad(); // Comment this out to prevent zed spawning

        if(nextSpawnSquad.length > 0)
          NextMonsterTime = Level.TimeSeconds; // + 0.2;
        else
        NextMonsterTime = Level.TimeSeconds + CalcNextSquadSpawnTime();
      }
    }

    else if ( NumMonsters <= 0 )
    {
      if ( WaveNum == FinalWave && !bUseEndGameBoss )
      {
        EndGame(none,"TimeLimit");
        return;
      }

      else if( WaveNum == (FinalWave + 1) && bUseEndGameBoss )
      {
        EndGame(none,"TimeLimit");
        return;
      }

      WaveCountDown--;
      if ( !CalmMusicPlaying )
      {
        InitMapWaveCfg();
        StartGameMusic(false);
      }

      // Open Trader doors
      if(!bTradingDoorsOpen) // && WaveNum != InitialWave )
      {
        bTradingDoorsOpen = true;
        OpenShops();
      }

      KFGameReplicationInfo(GameReplicationInfo).TimeToNextWave = WaveCountDown;
      // Have Trader tell players that they've got 30 seconds
      if ( WaveCountDown == 30 )
      {
        for ( c = Level.ControllerList; c != none; c = c.NextController )
          if ( KFPlayerController(c) != none )
            KFPlayerController(c).ClientLocationalVoiceMessage(c.PlayerReplicationInfo, none, 'TRADER', 4);
      }

      // Have Trader tell players that they've got 10 seconds
      else if ( WaveCountDown == 10 )
      {
        for ( c = Level.ControllerList; c != none; c = c.NextController )
          if ( KFPlayerController(c) != none )
            KFPlayerController(c).ClientLocationalVoiceMessage(c.PlayerReplicationInfo, none, 'TRADER', 5);
      }

      else if ( WaveCountDown == 5 )
      {
        KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonstersOn = false;
        InvasionGameReplicationInfo(GameReplicationInfo).WaveNumber = WaveNum;
      }

      else if ( (WaveCountDown > 0) && (WaveCountDown < 5) )
      {
        if( WaveNum == FinalWave && bUseEndGameBoss )
          BroadcastLocalizedMessage(class'KFMod.WaitingMessage', 3);
        else
          BroadcastLocalizedMessage(class'KFMod.WaitingMessage', 1);
      }

      else if ( WaveCountDown <= 1 )
      {
        bWaveInProgress = true;
        KFGameReplicationInfo(GameReplicationInfo).bWaveInProgress = true;
        // Randomize the ammo pickups again
        if( WaveNum > 0 )
          SetupPickups();

        if( WaveNum == FinalWave && bUseEndGameBoss )
          StartWaveBoss();
        else
        {
          SetupWave();

          for ( c = Level.ControllerList; c != none; c = c.NextController )
          {
            if ( PlayerController(c) != none )
            {
              PlayerController(c).LastPlaySpeech = 0;
              if ( KFPlayerController(c) != none )
                KFPlayerController(c).bHasHeardTraderWelcomeMessage = false;
            }
            if ( Bot(c) != none )
            {
              B = Bot(c);
              InvasionBot(B).bDamagedMessage = false;
              B.bInitLifeMessage = false;
              if ( !bOneMessage && (FRand() < 0.65) )
              {
                bOneMessage = true;
                if ( (B.Squad.SquadLeader != none) && B.Squad.CloseToLeader(c.Pawn) )
                {
                  B.SendMessage(B.Squad.SquadLeader.PlayerReplicationInfo, 'OTHER', B.GetMessageIndex('INPOSITION'), 20, 'TEAM');
                  B.bInitLifeMessage = false;
                }
              }
            }
          }
        }
      }
    }
  }

  // highly increased modifiers for all difficulties.
  function float CalcNextSquadSpawnTime()
  {
    local float NextSpawnTime;
    local float SineMod;
    local float PS;
    local float BS;
    local float S;

    SineMod = 1.0 - Abs(sin(WaveTimeElapsed * SineWaveFreq));
    NextSpawnTime = KFLRules.WaveSpawnPeriod;
    // make all difficulties same speed, and remove difficulty multiplier and slowdown for latter waves

    PS = PeakSpawnTime;
    BS = BaseSpawnTime;
    S = SineModMultiplier;

    //Amount of players 1-6 in order, top to bottom.
    Switch( AlivePlayersAmount() )  
    {
      case 1:    
      NextSpawnTime *= PS;
      break;
      case 2:
      NextSpawnTime *= (PS - BS) / 5 * 4 + BS;
      break;
      case 3:
      NextSpawnTime *= (PS - BS) / 5 * 3 + BS;
      break;
      case 4:
      NextSpawnTime *= (PS - BS) / 10 * 2 + BS;
      break;
      case 5:
      NextSpawnTime *= (PS - BS) / 10 * 1 + BS;
      break;
      default:
      NextSpawnTime *= BS;
    }

    //NextSpawnTime *= SpawnCoef;
    NextSpawnTime += SineMod * (NextSpawnTime * S);

    DebugCurrentSR = NextSpawnTime;

    return NextSpawnTime;
  }

  // Open all traders and remove whisp
  function OpenShops()
  {
    local int i;

    bTradingDoorsOpen = true;

    if(waveNum <= FinalWave - 3)
    {
      BroadcastText(class'Helper'.static.TraderMessages("trader"));
    }
    else if( waveNum == FinalWave - 2)
    {
      BroadcastText(class'Helper'.static.TraderMessages("dtf"));
      //Overrides trader time to the specified value for big zed, FP, and Pat wave
      TimeBetweenWaves = 60;
    }
    else if( waveNum == FinalWave - 1)
    {
      BroadcastText(class'Helper'.static.TraderMessages("fp"));
      TimeBetweenWaves = 60;
    }
    else if(waveNum == FinalWave)
    {
      BroadcastText(class'Helper'.static.TraderMessages("pat"));
      TimeBetweenWaves = 60;
    }

    for(i=0; i<ShopList.Length; i++)
    {
      ShopList[i].OpenShop();
    }

    SwitchCollision();
  }

  function CloseShops()
  {
    local int i;
    local Pickup Pickup;
    local CrossbuzzsawBlade CrossbuzzsawBlade;
    
    bTradingDoorsOpen = false;
    for(i=0; i<ShopList.Length; i++)
    {
      if( ShopList[i].bCurrentlyOpen )
        ShopList[i].CloseShop();
    }
    // trigger map cleanup
    foreach DynamicActors(class'Pickup', Pickup)
    {
      if(Pickup == none)
        continue;
      if(!Pickup.IsA('CashPickup') && Pickup.bDropped)
      {
        Pickup.Destroy();
      }
    }
    // remove this annoying shit
    foreach DynamicActors(class'CrossbuzzsawBlade', CrossbuzzsawBlade)
    {
      if(CrossbuzzsawBlade == none)
        continue;
      if(CrossbuzzsawBlade.ImpactActor != none)
        CrossbuzzsawBlade.Destroy();
    }
    // removed client garbage collection, forced pawns collisions once more
    SwitchCollision();
  }

  function SelectShop(); // no use since we open all traders

  function SetupPickups()
  {
    local int NumAmmoPickups, Random, i, j, m;
    local bool bSpawned;

    // same % for all difficulties
    NumAmmoPickups = AmmoPickups.Length * 0.35;

    // reset all the of the pickups
    for ( m = 0; m < AmmoPickups.Length ; m++ )
      AmmoPickups[m].GotoState('Sleeping', 'Begin');

    // Ramdomly select which pickups to spawn
    if (WeaponPickups.Length > 0)
    {
      for ( i = 0; i < WeaponPickups.Length; i++ )
      {
        if ( frand() < 0.25 )
        {
          if ( !WeaponPickups[Random].bIsEnabledNow )
            WeaponPickups[Random].EnableMe();
          bSpawned = true;
        }
        else if ( WeaponPickups[i].bIsEnabledNow )
          WeaponPickups[i].DisableMe();
      }
      if ( !bSpawned )
        WeaponPickups[rand(WeaponPickups.Length)].EnableMe();
    }

    for ( i = 0; i < NumAmmoPickups && j < 10000; i++ )
    {
      Random = Rand(AmmoPickups.Length);

      if ( AmmoPickups[Random].bSleeping )
        AmmoPickups[Random].GotoState('Pickup');
      else
        i--;

      j++;
    }
  }

  function StartWaveBoss()
  {
    // reset spawn volumes
    LastZVol = none;
    LastSpawningVolume = none;
    // moved from AddBoss()
    //FinalSquadNum = 0;
    super.StartWaveBoss();
  }

  function EndState()
  {
    super(Invasion).EndState();
    // Removed trader whisp
    //force player collision one more time
    SwitchCollision();
  }
}

function bool HasPathToAnyPlayer(KFMonster M)
{
  local KFHumanPawn P;

  foreach DynamicActors(class'KFHumanPawn',P)
  {
    if(p == none || M.Controller == none)
      continue;
    if(M.Controller.FindPathToward(P) == none)
      return false;
  }
  return true;
}

function SwitchCollision()
{
  local Controller c;
  local Pawn p;

  for(c = Level.ControllerList; c != none; c = c.NextController)
  {
    if(c.IsA('PlayerController') && c.Pawn != none && c.Pawn.Health > 0)
    {
      p = c.Pawn;
      if(!bWaveInProgress)
      {
        p.bBlockActors = bDisableAntiblocker;
        SpeedController(p,true);
      }
      else
      {
        p.bBlockActors = true;
        SpeedController(p,false);
      }
    }
  }
}

simulated function SpeedController(pawn p, bool bSpeedMe)
{
  local Inventory I;
  local bool bFoundInv;

  if (p == none)
    return;

  if (p.Inventory != none)
  {
    for (I = p.Inventory; I != none; I = I.Inventory)
    {
      if (FPPSpeedInventory(I) != none)
      {
        bFoundInv = true;
        if (!bSpeedMe)
          FPPSpeedInventory(I).Destroy();
        break;
      }
    }
  }

  // spawn new inventory if we want a speed boost
  // and we don't have a copy item
  if (!bFoundInv)
  {
    I = Spawn(class<Inventory>(DynamicLoadObject(string(class'FPPSpeedInventory'), class'Class')));
    FPPSpeedInventory(I).fPenalty = TraderSpeedBoost;
    I.GiveTo(p);
  }
}

//=========================================================================
// fix (possibly?) the log spam "you will become bla bla at the end of this wave" for new joiners
function RestartPlayer(controller c)
{
  local PlayerController pc;

  pc = PlayerController(c);
  if(pc == none || pc.PlayerReplicationInfo.bOutOfLives || pc.Pawn != none)
    return;

  if(!pc.PlayerReplicationInfo.bOnlySpectator && bWaveInProgress)
  {
    pc.PlayerReplicationInfo.bOutOfLives = true;
    pc.PlayerReplicationInfo.NumLives = 1;
    pc.GoToState('Spectating');
    return;
  }

  super(Invasion).RestartPlayer(c);

  if(pc.bIsPlayer && KFHumanPawn(pc.Pawn) != none)
  {
    KFHumanPawn(pc.Pawn).VeterancyChanged();
    if(bTradingDoorsOpen)
    {
      SpeedController(pc.Pawn,true);
      pc.Pawn.bBlockActors = bDisableAntiblocker;
    }
  }
}

// switch for slomo
function DramaticEvent(float BaseZedTimePossibility, optional float DesiredZedTimeDuration)
{
  if(bDisableSlomo)
    return;
  super.DramaticEvent(BaseZedTimePOssibility);
}

// slomo function for player dead. kept the paramaters/vars the same coz lazy :V
function PlayerDramaticEvent(float BaseZedTimePossibility, optional float DesiredZedTimeDuration)
{
  local float RandChance;
  local float TimeSinceLastEvent;
  local Controller C;

  if(!bEnablePlayerSlomo)
    return;

  TimeSinceLastEvent = Level.TimeSeconds - LastZedTimeEvent;

  // Don't go in slomo if we were just IN slomo
  if(TimeSinceLastEvent < 10.0 && BaseZedTimePossibility != 1.0)
  {
    return;
  }

  if(TimeSinceLastEvent > 60)
  {
    BaseZedTimePossibility *= 4.0;
  }
    else if( TimeSinceLastEvent > 30 )
    {
        BaseZedTimePossibility *= 2.0;
    }

    RandChance = FRand();

    //log("TimeSinceLastEvent = "$TimeSinceLastEvent$" RandChance = "$RandChance$" BaseZedTimePossibility = "$BaseZedTimePossibility);

    if( RandChance <= BaseZedTimePossibility )
    {
        bZEDTimeActive =  true;
        bSpeedingBackUp = false;
        LastZedTimeEvent = Level.TimeSeconds;

        if ( DesiredZedTimeDuration != 0.0 )
        {
            CurrentZEDTimeDuration = DesiredZedTimeDuration;
        }
        else
        {
            CurrentZEDTimeDuration = ZEDTimeDuration;
        }

        SetGameSpeed(ZedTimeSlomoScale);

        for ( C = Level.ControllerList; C != none; C = C.NextController )
        {
            if (KFPlayerController(C)!= none)
            {
                KFPlayerController(C).ClientEnterZedTime();
            }
        }
    }
}


//=========================================================================
// removed setting NextSpawnSquad, because it already has been set in StartWaveBoss()
function bool AddBoss()
{
  local int numspawned;
  local class<KFMonster> BossClass;

  BossClass = NextSpawnSquad[0];
  if( LastZVol == none )
  {
    LastZVol = FindSpawningVolume(false, true);
    if( LastZVol == none ) 
    {
      LastZVol = FindSpawningVolume(true, true);
      if( LastZVol == none ) 
      {
        log("Couldn't find a place for the Boss ("$BossClass$")after 2 tries, trying again later!!!", class.name);
        TryToSpawnInAnotherVolume(true);
        return false;
      }
    }
  }

  // How many zombies can we have left to spawn at once
  LastSpawningVolume = LastZVol;

  if(LastZVol.SpawnInHere(NextSpawnSquad,,numspawned,TotalMaxMonsters,32,,true))
  {
    log("Boss spawned: "$BossClass $ " (x"$numspawned$")", class.name);
    NumMonsters+=numspawned;
    WaveMonsters+=numspawned;
    return true;
  }

  else
  {
    log("Failed to spawn the Boss: "$BossClass, class.name);
    TryToSpawnInAnotherVolume(true);
    return false;
  }
}

//=========================================================================
// fix the issue, when dead/not spawned players add more zeds to the wave + zed amount for >6 player team
function SetupWave()
{
  local int i,j;
  local float NewMaxMonsters;
  local float NumPlayersMod;
  local int UsedNumPlayers;

  WavePlayerCount = AlivePlayersAmount();

  if(WaveNum > 15)
  {
    SetupRandomWave();
    return;
  }

  TraderProblemLevel = 0;    // debuging telepoted players from trader
  rewardFlag = false;      // do all players get the dosh?
  ZombiesKilled = 0;      // zeds who died during wave
  WaveMonsters = 0;      // amount of wave zeds
  WaveNumClasses = 0;
  NewMaxMonsters = Waves[WaveNum].WaveMaxMonsters;

  // removed DifficultyMod i.e. scaling from difficulty.
  // added bool to enable vanilla faked system.
  if (!bUseOriginalFakes)
    UsedNumPlayers = WavePlayerCount + NumBots + FakedPlayers;
  else
    UsedNumPlayers = NumPlayers + NumBots;

  // scale the number of zombies by the number of players. Fixed 7+ case
  switch(UsedNumPlayers)
  {
    case 1:
      NumPlayersMod = 1.7;
      break;
    case 2:
      NumPlayersMod = 3.4;
      break;
    case 3:
      NumPlayersMod = 4.675;
      break;
    case 4:
      NumPlayersMod = 5.95;
      break;
    case 5:
      NumPlayersMod = 6.8;
      break;
    case 6:
      NumPlayersMod = 7.65;
      break;
    default:
      NumPlayersMod = 7.65 + (UsedNumPlayers - 6)*Post6ZedsPerPlayer; // 7+ game
  }

  NewMaxMonsters = NewMaxMonsters * NumPlayersMod;
  TotalMaxMonsters = Clamp(NewMaxMonsters,5,800);  // MAX 800, MIN 5
  MaxMonsters = Clamp(TotalMaxMonsters,5,MaxZombiesOnce);

  KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonsters = TotalMaxMonsters;
  KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonstersOn = true;
  WaveEndTime = Level.TimeSeconds + Waves[WaveNum].WaveDuration;
  AdjustedDifficulty = GameDifficulty + Waves[WaveNum].WaveDifficulty;

  j = ZedSpawnList.Length;
  for( i=0; i<j; i++ )
    ZedSpawnList[i].Reset();
  j = 1;
  SquadsToUse.Length = 0;

  for ( i=0; i<InitSquads.Length; i++ )
  {
    if ( (j & Waves[WaveNum].WaveMask) != 0 )
    {
      SquadsToUse.Insert(0,1);
      SquadsToUse[0] = i;
    }
    j *= 2;
  }

  // save this for use elsewhere
  InitialSquadsToUseSize = SquadsToUse.Length;
  bUsedSpecialSquad = false;
  SpecialListCounter = 1;

  // now build the first squad to use
  BuildNextSquad();
}

//=========================================================================
// dont disable zed's AI when pat is spawned not in the final wave
function DoBossDeath()
{
  local Controller c, NextC;

  bZEDTimeActive = true;
  bSpeedingBackUp = false;
  LastZedTimeEvent = Level.TimeSeconds;
  CurrentZEDTimeDuration = 10;
  SetGameSpeed(0.10f);
  bBossView = true;
  BossViewBackTime = Level.Timeseconds + ZEDTimeDuration*1.1;

  if(!bWaveBossInProgress)
    return;

  // disable zeds if they all are ded and its final wave
  for(c = Level.ControllerList; c != none; c = NextC)
  {
    NextC = c.NextController;
    if(KFMonsterController(c) != none)
      c.GotoState('GameEnded');
  }
}

//================================================
// count alive players.
function int AlivePlayersAmount()
{
  local Controller c;
  local int alivePlayersCount;

  for(c = Level.ControllerList;c != none;c = c.NextController)
    if(c.bIsPlayer && c.Pawn != none && c.Pawn.Health > 0)
      alivePlayersCount ++;

  return alivePlayersCount;
}

//================================================
// returns random alive player.
function Controller FindSquadTarget()
{
  local array<Controller> CL;
  local Controller c;

  for(c=Level.ControllerList; c != none; c=c.NextController)
  {
    if(c.bIsPlayer && c.Pawn != none && c.Pawn.Health>0)
      CL[CL.Length] = c;
  }

  if(CL.Length>0)
    return CL[Rand(CL.Length)];

  return none;
}

//================================================
// dead players do not lower distance score.
function float RateZombieVolume(ZombieVolume ZVol, Controller SpawnCloseTo, optional bool bIgnoreFailedSpawnTime, optional bool bBossSpawning)
{
  local Controller c;
  local float Score;
  local float DistSquared, MinDistanceToPlayerSquared;
  local byte i;
  local float PlayerDistScoreZ, PlayerDistScoreXY, TotalPlayerDistScore, UsageScore;
  local vector LocationXY, TestLocationXY;
  local bool bTooCloseToPlayer;

  if ( ZVol == none )
    return -1;

  if( !bIgnoreFailedSpawnTime && Level.TimeSeconds - ZVol.LastFailedSpawnTime < 5.0 )
    return -1;

  // check doors
  for( i=0; i<ZVol.RoomDoorsList.Length; ++i )
  {
    if ( ZVol.RoomDoorsList[i].DoorActor != none && (ZVol.RoomDoorsList[i].DoorActor.bSealed || (!ZVol.RoomDoorsList[i].bOnlyWhenWelded && ZVol.RoomDoorsList[i].DoorActor.KeyNum==0)) )
      return -1;
  }

  // can this volume spawn this squad?
  if( !ZVol.CanSpawnInHere(NextSpawnSquad) )
    return -1;

  // now make sure no player sees the spawn point
  MinDistanceToPlayerSquared = ZVol.MinDistanceToPlayer**2;
  for ( c=Level.ControllerList; c!=none; c=c.NextController )
  {
    if( c.bIsPlayer && c.Pawn!=none && c.Pawn.Health>0 )
    {
      if( ZVol.Encompasses(c.Pawn) )
        return -1; // player inside this volume

      DistSquared = VSizeSquared(ZVol.Location - c.Pawn.Location);
      if( DistSquared < MinDistanceToPlayerSquared )
        return -1;
      // if the zone is too close to a boss character, reduce its desirability
      if( bBossSpawning && DistSquared < 1000000.0 )
        bTooCloseToPlayer = true;
      // do individual checks for spawn locations now, maybe add this back in later as an optimization
      // if fog doesn't hide spawn & lineofsight possible
      if( !ZVol.bAllowPlainSightSpawns
          && (!c.Pawn.Region.Zone.bDistanceFog || (DistSquared < c.Pawn.Region.Zone.DistanceFogEnd**2)) 
          && FastTrace(ZVol.Location, c.Pawn.Location + c.Pawn.EyePosition()) )
          return -1; // can be seen by player
    }
  }

  // start score with Spawn desirability
  Score = ZVol.SpawnDesirability;
  // rate how long its been since this spawn was used
  UsageScore = fmin(Level.TimeSeconds - ZVol.LastSpawnTime, 30.0) / 30.0;

  // rate the Volume on how close it is to the player
  LocationXY = ZVol.Location;
  LocationXY.Z = 0;
  TestLocationXY = SpawnCloseTo.Pawn.Location;
  TestLocationXY.Z = 0;
  // 250 = 5 meters
  // 4000000 = 2000^2 = 40 meters
  PlayerDistScoreZ = fmax(1.0 - abs(SpawnCloseTo.Pawn.Location.Z - ZVol.Location.Z)/250.0, 0.0);
  PlayerDistScoreXY = fmax(1.0 - VSizeSquared(TestLocationXY-LocationXY)/4000000.0, 0.0);
  // weight the XY distance much higher than the Z dist.
  // this gets zombies spawning more on the same level as the player
  if( ZVol.bNoZAxisDistPenalty )
    TotalPlayerDistScore = PlayerDistScoreXY;
  else
    TotalPlayerDistScore = 0.3*PlayerDistScoreZ + 0.7*PlayerDistScoreXY;

  // Tripwire: Spawning score is 30% SpawnDesirability, 30% Distance from players, 30% when the spawn was last used, 10% random
  // PooSH: Distance now is more important than time to prevent far spawns as much as possible
  // PooSH: and somebody should learn basic math...
  Score *= 0.30 + 0.35*TotalPlayerDistScore + 0.25*UsageScore + 0.1*frand();

  if( bTooCloseToPlayer )
    Score*=0.2;

  // try and prevent spawning in the same volume back to back
  if( LastSpawningVolume == ZVol )
    Score*=0.2;

  // if we get here, return at least a 1
  return fmax(Score,1);
}

//================================================
// fix for squads, now they shold spawn properly and not bug out
function ZombieVolume FindSpawningVolume(optional bool bIgnoreFailedSpawnTime, optional bool bBossSpawning)
{
  local ZombieVolume BestZ, CurZ;
  local float BestScore,tScore;
  local int i,j;
  local Controller c;
  local bool bCanSpawnAll;
  local byte ZombieFlag;

  // first pass, pick a random player
  c = FindSquadTarget();
  if( c == none )
  {
    log("FleshpoundParty: Random Player is gone!?");
    return none;
  }

  // second pass, figure out best spawning point.
  for( i=0; i<ZedSpawnList.Length; i++ )
  {
    CurZ = ZedSpawnList[i];
    // check if it can spawn all zeds in the squad
    if ( !CurZ.bNormalZeds || !CurZ.bRangedZeds || !CurZ.bLeapingZeds || !CurZ.bMassiveZeds )
    {
      bCanSpawnAll = true;
      for ( j=0; bCanSpawnAll && j<NextSpawnSquad.length; ++j )
      {
        ZombieFlag = NextSpawnSquad[j].default.ZombieFlag;
        if( (!CurZ.bNormalZeds && ZombieFlag==0) 
          || (!CurZ.bRangedZeds && ZombieFlag==1) 
          || (!CurZ.bLeapingZeds && ZombieFlag==2) 
          || (!CurZ.bMassiveZeds && ZombieFlag==3) )
        {
          bCanSpawnAll = false;
        }
      }

      if ( !bCanSpawnAll )
        continue;
    }

    else
      tScore = CurZ.RateZombieVolume(Self,LastSpawningVolume,c,bIgnoreFailedSpawnTime, bBossSpawning);

    if( tScore > BestScore || (BestZ == none && tScore > 0) )
    {
      BestScore = tScore;
      BestZ = CurZ;
    }
  }

  if ( BestZ == none )
    return super.FindSpawningVolume(bIgnoreFailedSpawnTime, bBossSpawning);

  return BestZ;
}

//============================== ADDITIONAL WAVE ==============================
simulated function PrepareSpecialSquadsFromGameType()
{
  local int i;

  switch(KFGameLength)
  {
    case 0:
    case 1:
    case 3:
      FinalWave = 9;
      for( i=0; i<FinalWave; i++ )
      {
        Waves[i] = NormalWaves[i];
        SpecialSquads[i] = NormalSpecialSquads[i];
      }
      break;
    default:
      FinalWave = 12;
      for( i=0; i<FinalWave; i++ )
      {
        Waves[i] = LongWaves[i];
        SpecialSquads[i] = LongSpecialSquads[i];
      }
  }
}

simulated function PrepareSpecialSquadsFromCollection()
{
  local int i;

  switch(KFGameLength)
  {
    case 0:
    case 1:
    case 3:
      FinalWave = 9;
      for( i=0; i<FinalWave; i++ )
      {
        Waves[i] = NormalWaves[i];
        MonsterCollection.default.SpecialSquads[i] =   MonsterCollection.default.NormalSpecialSquads[i];
      }
      break;
    default:
      FinalWave = 12;
      for( i=0; i<FinalWave; i++ )
      {
        Waves[i] = LongWaves[i];
        MonsterCollection.default.SpecialSquads[i] =   MonsterCollection.default.LongSpecialSquads[i];
      }
  }
}

//============================== SERVER INFO ==============================
// clear garbage, add wave info and version
// function GetServerDetails( out ServerResponseLine ServerState )
// {
//   local int i;
//   local string wave_status;

//   super(GameInfo).GetServerDetails( ServerState );

//   i = ServerState.ServerInfo.Length;
//   ServerState.ServerInfo.insert(i, 2);

//   ServerState.ServerInfo[i].Key = "Fleshpound Party";
//   ServerState.ServerInfo[i++].Value = GetVersionStr();

//   if ( IsInState('PendingMatch') )
//     wave_status = "LOBBY";
//   else if ( IsInState('MatchInProgress') )
//     wave_status = String(WaveNum + 1) $ " / " $ FinalWave;
//   else if ( IsInState('MatchOver') )
//     wave_status = "Game Over";
//   else
//     wave_status = "Unknown";

//   ServerState.ServerInfo[i].Key = "Current Wave";
//   ServerState.ServerInfo[i++].Value = wave_status;

//   AddServerDetail( ServerState, "Max runtime zombies", MaxZombiesOnce );
//   AddServerDetail( ServerState, "Starting cash", StartingCash );
// }

// static final function string GetVersionStr()
// {
//   local string msg;
//   local float v;

//   v = VERSION;
//   msg = String(v);

//   return msg;
// }

//============================== BROADCASTING ==============================
//SendMessage(target pc, message,'false' if used outside of BroadcastText). Nagi <3 dkanus <3
function SendMessage(PlayerController pc, coerce string msg, optional bool bAlreadyColored)
{
  if(pc == none || msg == "")
    return;

  if(!bAlreadyColored)
    msg = class'Helper'.static.ParseTags(msg);

  pc.teamMessage(none,msg,'Fleshpound Party');
}

//BroadcastText("something")
function BroadcastText(string msg)
{
  local PlayerController pc;
  local Controller c;
  local string strTemp;

   // don't go further on blank messages
  if(msg == "")
    return;
  // color messages
  msg = class'Helper'.static.ParseTags(msg);

  for(c = level.controllerList; c != none; c = c.nextController)
  {
    // allow only player controllers
    if(!c.isA('PlayerController'))
      continue;

    pc = PlayerController(c);
    if(pc == none)
      continue;

    // remove colors for server log and WebAdmin, otherwise we will crash
    if(pc.PlayerReplicationInfo.PlayerID == 0)
    {
      strTemp = class'Helper'.static.StripColor(msg);
      SendMessage(pc,strTemp);
      log("Fleshpound Party: "$strTemp);
      continue;
    }
    SendMessage(pc,msg,true);
  }
}

//============================== DEBUG and other stuff ==============================
// add simulated faked. Works like scrn fakes, spawns zeds for set amound of fakes, but doesnt use slots so players can join
exec function Pubs(int numFakes)
{
  if(bUseOriginalFakes)
  {
    NumPlayers = AlivePlayersAmount() + numFakes;
    BroadcastText("%b"$numFakes$"%w fakes were added to game.");
  }

  else if(!bUseOriginalFakes)
  {
    FakedPlayers = numFakes;
    BroadcastText("%b" @ numFakes @ "%wsimulated pubs added to game.");
  }
}

exec function sr(float newRate)
{
  local KFLevelRules KFLR;
  local float PS;
  local float BS;
  local float S;

  if(newRate ~= 0)
  {
    BroadcastText("%wOriginal spawnrate -%r "$OriginalSpawnrate$"%w, current spawnrate -%r "$DebugCurrentSR);
  }

  else //if(newRate <= 3)
  {
    foreach AllActors(Class'KFLevelRules',KFLR)

    PS = PeakSpawnTime;
    BS = BaseSpawnTime;
    S = SineModMultiplier;

    //Amount of players 1-6 in order, top to bottom.
    Switch( AlivePlayersAmount() )  
    {
      case 1:    
      KFLR.WaveSpawnPeriod *= PS;
      break;
      case 2:
      KFLR.WaveSpawnPeriod *= (PS - BS) / 5 * 4 + BS;
      break;
      case 3:
      KFLR.WaveSpawnPeriod *= (PS - BS) / 5 * 3 + BS;
      break;
      case 4:
      KFLR.WaveSpawnPeriod *= (PS - BS) / 10 * 2 + BS;
      break;
      case 5:
      KFLR.WaveSpawnPeriod *= (PS - BS) / 10 * 1 + BS;
      break;
      default:
      KFLR.WaveSpawnPeriod *= BS;
    }

    BroadcastText("%wSpawnrate changed to -%b" @newRate);
  }
}

exec function SetTrader(int time)
{
  if(time == 0)
  {
    TimeBetweenWaves = TraderTime;
    WaveCountDown = TraderTime;
    BroadcastText("%wTrader time set to -%r "$TraderTime);
  }

  else
  {
    time = Clamp(time,15,120);
    TimeBetweenWaves = time;
    WaveCountDown = time;
    BroadcastText("%wTrader time set to -%r "$time);
  }
}

exec function NoDrama(string strState)
{
  switch(strState)
  {
    case "off":
      bDisableSlomo = false;
      break;
    default:
      bDisableSlomo = true;
  }

  BroadcastText("%wSlomo is set to -%r "$bDisableSlomo);
}

exec function NoPlayerDrama(string strState)
{
  switch(strState)
  {
    case "off":
      bEnablePlayerSlomo = false;
      break;
    default:
      bEnablePlayerSlomo = true;
  }
  BroadcastText("%wPlayer Slomo is set to -%r "$bEnablePlayerSlomo);
}

exec function GetVersion()
{
  BroadcastText("%wFleshpound Party v.%r" $ string(VERSION));
}

exec function AntiBlocker(string strState)
{
  switch(strState)
  {
    case "off":
      bDisableAntiblocker = false;
      break;
    default:
      bDisableAntiblocker = true;
  }
  BroadcastText("%wTrader time Player collision is set to -%r "$bDisableAntiblocker);
  SwitchCollision();
}

exec function KillZeds()
{
  local KFMonster Monster;
  local array <KFMonster> Monsters;
  local int i;

  foreach DynamicActors(class 'KFMonster',Monster)
  {
    if(Monster == none)
      continue;
    if(Monster.Health > 0 && !Monster.bDeleteMe)
      Monsters[Monsters.length] = Monster;
  }
  for(i=0; i<Monsters.length; ++i)
    Monsters[i].Suicide();
}

exec function MZ(int num)
{
  num = Clamp(num,32,120);
  MaxZombiesOnce = num;
  iTemp = num;
  BroadcastText("%wMaxZeds changed to -%r "$num);
}

function bool CheckMaxLives(PlayerReplicationInfo Scorer)
{
  local Controller C;
  local PlayerController Living;
  local byte AliveCount;

  if(MaxLives > 0)
  {
    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
      if((C.PlayerReplicationInfo != None) && C.bIsPlayer && !C.PlayerReplicationInfo.bOutOfLives && !C.PlayerReplicationInfo.bOnlySpectator)
      {
        AliveCount++;
        if(Living==none)
          Living = PlayerController(C);
      }
    }
    if(AliveCount==0)
    {
      EndGame(Scorer,"LastMan");
      return true;
    }
    else if(!bNotifiedLastManStanding && AliveCount==1 && Living!=None)
    {
      bNotifiedLastManStanding = true;
      Living.ReceiveLocalizedMessage(Class'FPPLastManStandingMsg');
      //PlayerController(C).ClientPlaySound(Sound'lastmanstanding',true,2.f,SLOT_None);
    }
  }
  return false;
}

//=========================================================================
defaultproperties
{
  GameName="Fleshpound Party"
  Description="The premise is simple: you (and, hopefully, your team) against hordes of fleshpounds and their minion zeds. Have fun!"

  StandardMonsterSquads[15]="1H"
  StandardMonsterSquads[19]="6C"
  StandardMonsterSquads[21]="1H"
  StandardMonsterSquads[22]="2F"
  StandardMonsterSquads[25]="3F"
  StandardMonsterSquads[26]="1I"
  StandardMonsterSquads[27]="1I1F1H1E1G"

  MonsterSquad[15]="1H"
  MonsterSquad[19]="6C"
  MonsterSquad[21]="1H"
  MonsterSquad[22]="2F"
  MonsterSquad[25]="3F"
  MonsterSquad[26]="1I"
  MonsterSquad[27]="1I1F1H1E1G"

  NormalWaves[0]=(WaveMask=14422019,WaveMaxMonsters=10)
  NormalWaves[1]=(WaveMask=100655227,WaveMaxMonsters=40)
  NormalWaves[2]=(WaveMask=100655227,WaveMaxMonsters=45)
  NormalWaves[3]=(WaveMask=100655227,WaveMaxMonsters=55)
  NormalWaves[4]=(WaveMask=92266555,WaveMaxMonsters=65)
  NormalWaves[5]=(WaveMask=92266555,WaveMaxMonsters=75)
  NormalWaves[6]=(WaveMask=92266555,WaveMaxMonsters=80)
  NormalWaves[7]=(WaveMask=134217728,WaveMaxMonsters=11)
  NormalWaves[8]=(WaveMask=8388608,WaveMaxMonsters=9)

  LongWaves[00]=(WaveMask=14422019,WaveMaxMonsters=10)
  LongWaves[01]=(WaveMask=100655227,WaveMaxMonsters=40)
  LongWaves[02]=(WaveMask=100655227,WaveMaxMonsters=45)
  LongWaves[03]=(WaveMask=100655227,WaveMaxMonsters=50)
  LongWaves[04]=(WaveMask=100655227,WaveMaxMonsters=55)
  LongWaves[05]=(WaveMask=100655227,WaveMaxMonsters=60)
  LongWaves[06]=(WaveMask=92266555,WaveMaxMonsters=65)
  LongWaves[07]=(WaveMask=92266555,WaveMaxMonsters=70)
  LongWaves[08]=(WaveMask=92266555,WaveMaxMonsters=75)
  LongWaves[09]=(WaveMask=92266555,WaveMaxMonsters=80)
  LongWaves[10]=(WaveMask=134217728,WaveMaxMonsters=11)
  LongWaves[11]=(WaveMask=8388608,WaveMaxMonsters=9)

  KFHints[00]="We all wipe down here."
  KFHints[01]="If all your perks are level 6 you clearly suck because you have no life."
  KFHints[02]="Not all heroes wear a cape, some just use an AA12."
  KFHints[03]="Such super Sick SeekerSix Skillz!"
  KFHints[04]="Always remember to press Q to win!"
  KFHints[05]="If you can't finish it, don't rage it."
  KFHints[06]="Behind every great Fleshpound there is always a great Siren."
  KFHints[07]="Remember: if you died, it's always someone else's fault."
  KFHints[08]="True professionals can still carry their team while AFK."
  KFHints[09]="The Firebug. Yes, that is a Flamethrower he's carrying. Nothing subtle about him."
  KFHints[10]="The Firebug tends to live up to its name, so watch out for it spamming flames towards you."
  KFHints[11]="The Commando is not that dangerous - but does have a nasty habit of raging bigger zeds and then trying to get away, so keep him at a distance."
  KFHints[12]="Bloats will explode in a shower of candy when they die. Make sure there's a team mate near when taking them down, for a wonderful surprise!"
  KFHints[13]="Demolitionist, not too hard to kill, but its Pipe Bombs stay even after it dies, so make sure you keep out of range when they eventually enrage something."
  KFHints[14]="The Firebug is a real spammer. Very nasty. Its flames are not just annoying - they'll trigger grenades and rockets in mid-air!"
  KFHints[15]="The Fleshpound. Shooting him with small weapons just makes your team mates mad."
  KFHints[16]="The Sharpshooter. This is the big One. M14. LAR. And a 9mm, too!"
  KFHints[17]="Sharpshooter addendum: Did we forget to brief you? Yes, they can take on anything without your help. Just leave them to their short, angry lives."
  KFHints[18]="Never question the LAW, for the LAW is sacred."
}