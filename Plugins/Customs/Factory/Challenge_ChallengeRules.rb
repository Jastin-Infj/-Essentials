#===============================================================================
#
#===============================================================================
class PokemonChallengeRules
  #===============================================================================
  # Battle Frontier rules
  #===============================================================================

  def pbBattleFactoryRules(double, openlevel)
    ret = PokemonChallengeRules.new
    if openlevel
      ret.setLevelAdjustment(FixedLevelAdjustment.new(100))
      ret.addPokemonRule(MaximumLevelRestriction.new(100))
    else
      ret.setLevelAdjustment(FixedLevelAdjustment.new(50))
      ret.addPokemonRule(MaximumLevelRestriction.new(50))
    end
    ret.addTeamRule(SpeciesClause.new)
    ret.addPokemonRule(BannedSpeciesRestriction.new(:UNOWN))
    ret.addTeamRule(ItemClause.new)
    ret.addBattleRule(SoulDewBattleClause.new)
    ret.setDoubleBattle(double)

    # 対戦内容の設定追加
    ###  setBattleRule("autoBattle")
    setBattleRule("wildZMoves")
    setBattleRule("wildUltraBurst")
    setBattleRule("allowDynamax", :All)
    setBattleRule("wildTerastallize")

    return ret
  end

end