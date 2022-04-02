--[[

Enum:
    EnemyType = [Normal, Boss, Demon, Devil]

Enemy Format [
    Name = {
        EnemyType = BossLevelEnum,
        Level = 1
    },
]

]]

local ENEMY_TYPE = {
    Normal = 0,
    Boss = 1,
    Demon = 2,
    Devil = 3
}

return {
    Default = {
        EnemyType = ENEMY_TYPE.Normal,
        Level = 1
    },
    NormalEnemy = {
        EnemyType = ENEMY_TYPE.Normal,
        Level = 1
    },
    Cataclysm = {
        EnemyType = ENEMY_TYPE.Boss,
        Level = 20
    },

}