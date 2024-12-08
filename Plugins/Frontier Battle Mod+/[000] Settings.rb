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