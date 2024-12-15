#===============================================================================
# Settings.
#===============================================================================
module Settings
  #-----------------------------------------------------------------------------
  # NPC Trainer Settings
  #-----------------------------------------------------------------------------
  BATTLE_FACTORY_RENTALS_SINGLE = 3
  #-----------------------------------------------------------------------------
  # NPC Trainer Settings
  #-----------------------------------------------------------------------------
  BATTLE_FACTORY_RENTALS_DOUBLE = 4
  #-----------------------------------------------------------------------------
  # NPC Held Item  True: Use / False : Not Use
  #-----------------------------------------------------------------------------
  ITEM_PARAM_FLAG = true
  #-----------------------------------------------------------------------------
  # NPC Trainer PBS File Import True: ON / False : OFF
  # [battle_tower_trainers.txt]
  # Items = MEGARING,Z-CRYSTAL,FULLRESTORE
  #-----------------------------------------------------------------------------
  ITEM_TRAINER_PBS_FILE_PARAM = true
  #-----------------------------------------------------------------------------
  # NPC Trainer Item Default Settings / Example : [:MEGARING , :Z-CRYSTAL , :FULLRESTORE]
  #-----------------------------------------------------------------------------
  ITEM_TRAINER_FROINTIER_DEFAULT = [:MEGARING]
  
  
  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  NPC_TRAINER_LENGTH = 300
  #-----------------------------------------------------------------------------
  # トレーナーの出現確率を変更する
  #-----------------------------------------------------------------------------
  # BATTLE_CHALLENGE_TRAINER_TABLE = [  # Each value is [minimum win count, range start point, range length]
  #   [ 0,   0, 100],   # 0-100
  #   [ 6,  80,  40],   # 80-120
  #   [ 7,  80,  40],   # 80-120
  #   [13, 120,  20],   # 120-140
  #   [14, 100,  40],   # 100-140
  #   [20, 140,  20],   # 140-160
  #   [21, 120,  40],   # 120-160
  #   [27, 160,  20],   # 160-180
  #   [28, 140,  40],   # 140-180
  #   [34, 180,  20],   # 180-200
  #   [35, 160,  40],   # 160-200
  #   [41, 200,  20],   # 200-220
  #   [42, 180,  40],   # 180-220
  #   [48, 220,  40],   # 220-260
  #   [49, 200, 100]    # 200-300 - This line is used for all higher win_counts
  # ]
  BATTLE_CHALLENGE_TRAINER_TABLE = [  # Each value is [minimum win count, range start point, range length]
    [0,  0, 0],   # 0-100
    [49, 200, 100]    # 200-300 - This line is used for all higher win_counts
  ]

  #-----------------------------------------------------------------------------
  # 
  #-----------------------------------------------------------------------------
  BATTLE_CHALLENGE_TRAINER_AI_FLAG = true
  BATTLE_CHALLENGE_TRAINER_AI_LEVEL = 255

  #-----------------------------------------------------------------------------
  # ポケモンテーブルの設定
  # Min: 6
  #-----------------------------------------------------------------------------
  BATTLE_CHALLENGE_POKEMON_TABLE_WINCOUNTLOOP = 7
  BATTLE_CHALLENGE_POKEMON_TABLE_NUM_MAX = 7

  BATTLE_CHALLENGE_POKEMON_TABLE_LENGTH = 881
  
  BATTLE_CHALLENGE_POKEMON_TABLE_OPEN = [
    [372, 491],   # Group 3 (first quarter)
    [492, 610],   # Group 3 (second quarter)
    [611, 729],   # Group 3 (third quarter)
    [730, 849],   # Group 3 (fourth quarter)
    [372, 881],   # All of Group 3
    [372, 881],   # All of Group 3
    [372, 881],   # All of Group 3
    [372, 881]    # This line is used for all higher sets (all of Group 3)
  ]

  BATTLE_CHALLENGE_POKEMON_TABLE_DEFAULT = [
    [  0, 173],   # Group 1
    [174, 272],   # Group 2 (first half)
    [273, 371],   # Group 2 (second half)
    [372, 491],   # Group 3 (first quarter)
    [492, 610],   # Group 3 (second quarter)
    [611, 729],   # Group 3 (third quarter)
    [730, 849],   # Group 3 (fourth quarter)
    [372, 881]    # This line is used for all higher sets (all of Group 3)
  ]

  IV_TABLE = [3, 6, 9, 12, 15, 21, 31, 31]

  # Frontiers Plus Requirements
  # [001] Debug.rb , [005] Frontier Plus.rb Required
  # Not Use Frontiers Plus ↑↑↑ 2file Comment Out or Delete
  #-----------------------------------------------------------------------------
  # NPC Trainer Dynamax Level Default  Min:0 Max: 10
  #-----------------------------------------------------------------------------
  DYNAMAX_LEVEL_DEFAULT = 10
  #-----------------------------------------------------------------------------
  # NPC Trainer Gigantamax Default True: ON / False : OFF
  #-----------------------------------------------------------------------------
  GIGANTAMAX_DEFAULT = false
  #-----------------------------------------------------------------------------
  # NPC Trainer Dynamax PBS File Import True: ON / False : OFF
  # Complier Required and USE_FRONTIER_PLUS = true
  # [battle_tower_pokemons.txt]
  # DynamaxLv = 10
  # Gigantamax = TRUE
  #-----------------------------------------------------------------------------
  DYNAMAX_PBS_FILE = true
end