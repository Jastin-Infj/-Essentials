#===============================================================================
# Mysterious Force
#===============================================================================
# アンノーンの特性
#-------------------------------------------------------------------------------
Battle::AbilityEffects::OnSwitchIn.add(:MYSTICPOWER,
  proc { |ability, battler, battle, switch_in|
    # 特性が毎回表示が入る
    battle.pbShowAbilitySplash(battler)

    showAnim = true
    battler.pbRaiseStatStage(:ATTACK, 1, battler , showAnim)
    showAnim = false
    battler.pbRaiseStatStage(:SPECIAL_ATTACK, 1, battler , showAnim)
    battler.pbRaiseStatStage(:SPEED, 1, battler , showAnim)
    showAnim = true
    battler.pbLowerStatStage(:DEFENSE, 1, battler , showAnim)
    showAnim = false
    battler.pbLowerStatStage(:SPECIAL_DEFENSE, 1, battler , showAnim)

    # 特性が毎回表示が非表示
    battle.pbHideAbilitySplash(battler)
  }
)


#===============================================================================
# Bonds of Love
#===============================================================================
# ラブカスの特性
#-------------------------------------------------------------------------------
Battle::AbilityEffects::DamageCalcFromTarget.add(:BONDSOFLOVE,
  proc { |ability, user, target, move, mults, power, type|
    mults[:final_damage_multiplier] *= 0.5
  }
)

Battle::AbilityEffects::DamageCalcFromTargetAlly.add(:BONDSOFLOVE,
  proc { |ability, user, target, move, mults, power, type|
    mults[:final_damage_multiplier] *= 0.5
  }
)

#===============================================================================
# SNIPTERON
#===============================================================================
# オニドリルの特性 急所ランク + 2 と いかく
#-------------------------------------------------------------------------------
Battle::AbilityEffects::CriticalCalcFromUser.add(:SNIPTERON,
  proc { |ability, user, target, c|
    next (c + 2)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:SNIPTERON,
  proc { |ability, battler, battle, switch_in|
    next if battler.effects[PBEffects::OneUseAbility] == ability
    battle.pbShowAbilitySplash(battler)
    battle.allOtherSideBattlers(battler.index).each do |b|
      next if !b.near?(battler)
      check_item = true
      if b.hasActiveAbility?([:CONTRARY, :GUARDDOG])
        check_item = false if b.statStageAtMax?(:ATTACK)
      elsif b.statStageAtMin?(:ATTACK)
        check_item = false
      end
      check_ability = b.pbLowerAttackStatStageIntimidate(battler)
      b.pbAbilitiesOnIntimidated if check_ability
      b.pbItemOnIntimidatedCheck if check_item
    end
    battle.pbHideAbilitySplash(battler)
    battler.effects[PBEffects::OneUseAbility] = ability
  }
)