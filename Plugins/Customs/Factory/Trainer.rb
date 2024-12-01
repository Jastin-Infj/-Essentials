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
    battle = RecordedBattle.new(scene, trainer1.party, trainer2.party, trainer1, trainer2)
    return battle
  end
end