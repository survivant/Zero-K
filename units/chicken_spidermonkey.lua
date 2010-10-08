unitDef = {
  unitname            = [[chicken_spidermonkey]],
  name                = [[Spidermonkey]],
  description         = [[All-Terrain Anti-Air]],
  acceleration        = 0.36,
  bmcode              = [[1]],
  brakeRate           = 0.2,
  buildCostEnergy     = 0,
  buildCostMetal      = 0,
  builder             = false,
  buildPic            = [[chicken_spidermonkey.png]],
  buildTime           = 500,
  canAttack           = true,
  canGuard            = true,
  canMove             = true,
  canPatrol           = true,
  canstop             = [[1]],
  category            = [[LAND]],

  customParams        = {
    description_fr = [[All-Terrain Anti-Air Webslinger]],
    helptext       = [[The Spidermonkey is a very unusual support chicken. As the name suggests, it can climb walls, however it can also spin thick webs to ensnare aircraft like a spider catching insects.]],
    helptext_fr    = [[The Spidermonkey is a very unusual support chicken. As the name suggests, it can climb walls, however it can also spin thick webs to ensnare aircraft like a spider catching insects.]],
  },

  defaultmissiontype  = [[Standby]],
  explodeAs           = [[NOWEAPON]],
  footprintX          = 3,
  footprintZ          = 3,
  iconType            = [[spideraa]],
  idleAutoHeal        = 20,
  idleTime            = 300,
  leaveTracks         = true,
  maneuverleashlength = [[640]],
  mass                = 5000,
  maxDamage           = 1800,
  maxSlope            = 72,
  maxVelocity         = 2.2,
  maxWaterDepth       = 22,
  minCloakDistance    = 75,
  movementClass       = [[ATKBOT3]],
  noAutoFire          = false,
  noChaseCategory     = [[TERRAFORM LAND SINK SHIP SATELLITE SWIM FLOAT SUB HOVER]],
  objectName          = [[chicken_sporeshooter.s3o]],
  power               = 500,
  seismicSignature    = 4,
  selfDestructAs      = [[NOWEAPON]],

  sfxtypes            = {

    explosiongenerators = {
      [[custom:blood_spray]],
      [[custom:blood_explode]],
      [[custom:dirt]],
    },

  },

  side                = [[THUNDERBIRDS]],
  sightDistance       = 700,
  smoothAnim          = true,
  sonarDistance       = 450,
  steeringmode        = [[2]],
  TEDClass            = [[KBOT]],
  trackOffset         = 0.5,
  trackStrength       = 9,
  trackStretch        = 1,
  trackType           = [[ChickenTrackPointy]],
  trackWidth          = 70,
  turnRate            = 1200,
  upright             = false,
  workerTime          = 0,

  weapons             = {

    {
      def                = [[WEB]],
      onlyTargetCategory = [[FIXEDWING]],
    },


    {
      def                = [[SPORES]],
      badTargetCategory  = [[SWIM LAND SHIP HOVER]],
      onlyTargetCategory = [[FIXEDWING LAND SINK SHIP SWIM FLOAT GUNSHIP HOVER]],
    },

  },


  weaponDefs          = {

    SPORES = {
      name                    = [[Spores]],
      areaOfEffect            = 24,
      avoidFriendly           = false,
      burst                   = 5,
      burstrate               = 0.1,
      collideFriendly         = false,
      craterBoost             = 0,
      craterMult              = 0,

      damage                  = {
        default = 75,
        planes  = [[150]],
        subs    = 7.5,
      },

      dance                   = 60,
      explosionGenerator      = [[custom:NONE]],
      fireStarter             = 0,
      fixedlauncher           = 1,
      flightTime              = 5,
      groundbounce            = 1,
      guidance                = true,
      heightmod               = 0.5,
      impactOnly              = true,
      impulseBoost            = 0,
      impulseFactor           = 0.4,
      interceptedByShieldType = 2,
      lineOfSight             = true,
      metalpershot            = 0,
      model                   = [[chickeneggpink.s3o]],
      noSelfDamage            = true,
      range                   = 600,
      reloadtime              = 6,
      renderType              = 1,
      selfprop                = true,
      smokedelay              = [[0.1]],
      smokeTrail              = true,
      soundstart              = [[hiss]],
      startsmoke              = [[1]],
      startVelocity           = 100,
      texture1                = [[]],
      texture2                = [[sporetrail]],
      tolerance               = 10000,
      tracks                  = true,
      turnRate                = 24000,
      turret                  = true,
      waterweapon             = true,
      weaponAcceleration      = 100,
      weaponType              = [[MissileLauncher]],
      weaponVelocity          = 500,
      wobble                  = 32000,
    },


    WEB    = {
      name                    = [[Web Weapon]],
      accuracy                = 800,
      areaOfEffect            = 24,
      avoidFriendly           = false,
      canattackground         = false,
      collideFriendly         = false,
      craterBoost             = 0,
      craterMult              = 0,

      damage                  = {
        default = 0.1,
        subs    = 0.005,
      },

      dance                   = 150,
      explosionGenerator      = [[custom:NONE]],
      fireStarter             = 0,
      fixedlauncher           = true,
      flightTime              = 3,
      impactOnly              = true,
      impulseBoost            = 35,
      impulseFactor           = -200,
      interceptedByShieldType = 2,
      lineOfSight             = true,
      metalpershot            = 0,
      minbarrelangle          = [[0]],
      noSelfDamage            = true,
      range                   = 800,
      reloadtime              = 0.1,
      renderType              = 1,
      selfprop                = true,
      smokeTrail              = true,
      soundstart              = [[missile]],
      startsmoke              = [[1]],
      startVelocity           = 600,
      texture2                = [[smoketrailthin]],
      tolerance               = 63000,
      tracks                  = true,
      turnRate                = 90000,
      turret                  = true,
      weaponAcceleration      = 400,
      weaponTimer             = 1,
      weaponType              = [[MissileLauncher]],
      weaponVelocity          = 2000,
    },

  },

}

return lowerkeys({ chicken_spidermonkey = unitDef })
