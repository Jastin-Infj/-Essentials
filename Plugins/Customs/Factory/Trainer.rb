#===============================================================================
# Trainer class for NPC trainers
#===============================================================================
class PokemonChallengeRules
  def createBattle(scene, trainer1, trainer2)
    # echoln "Creating battle between #{trainer1.name} and #{trainer2.name}"
    battle = @battletype.pbCreateBattle(scene, trainer1, trainer2)
    @battlerules.each do |p|
      p.setRule(battle)
    end
    return battle
  end
end

#===============================================================================
#
#===============================================================================
class BattleTower < BattleType
  def pbCreateBattle(scene, trainer1, trainer2)
    # echoln "BattleTower #{trainer2.items}"
    return RecordedBattle.new(scene, trainer1.party, trainer2.party, trainer1, trainer2)
  end
end

class Battle::AI

  def initialize(battle)
    @battle = battle
    unless Settings::BATTLE_CHALLENGE_TRAINER_AI_FLAG
      create_ai_objects()
    end
  end

  def create_ai_objects
    # Initialize AI trainers
    @trainers = [[], []]
    @battle.player.each_with_index do |trainer, i|
      @trainers[0][i] = AITrainer.new(self, 0, i, trainer)
    end
    if @battle.wildBattle?
      @trainers[1][0] = AITrainer.new(self, 1, 0, nil)
    else
      @battle.opponent.each_with_index do |trainer, i|
        @trainers[1][i] = AITrainer.new(self, 1, i, trainer)
      end
    end
    # Initialize AI battlers
    @battlers = []
    @battle.battlers.each_with_index do |battler, i|
      @battlers[i] = AIBattler.new(self, i) if battler
    end
    # Initialize AI move object
    @move = AIMove.new(self)
  end
end

class Battle::AI::AITrainer

  def initialize(ai, side, index, trainer)
    @ai            = ai
    @side          = side
    @trainer_index = index
    @trainer       = trainer
    @skill         = 0
    unless Settings::BATTLE_CHALLENGE_TRAINER_AI_FLAG
      @trainer.skill_level = Settings::BATTLE_CHALLENGE_TRAINER_AI_LEVEL
    end
    
    @skill_flags   = []
    set_up_skill
    set_up_skill_flags
    sanitize_skill_flags
  end

  def set_up_skill
    if @trainer
      @skill = @trainer.skill_level
    elsif Settings::SMARTER_WILD_LEGENDARY_POKEMON
      # Give wild legendary/mythical Pokémon a higher skill
      wild_battler = @ai.battle.battlers[@side]
      sp_data = wild_battler.pokemon.species_data
      if sp_data.has_flag?("Legendary") ||
         sp_data.has_flag?("Mythical") ||
         sp_data.has_flag?("UltraBeast")
        @skill = 32   # Medium skill
      end
    end
  end
end