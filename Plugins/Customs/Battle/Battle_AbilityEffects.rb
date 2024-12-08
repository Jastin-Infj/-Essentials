#===============================================================================
# きょううん
#===============================================================================
# 急所ランクが1段階上がる
#-------------------------------------------------------------------------------
Battle::AbilityEffects::CriticalCalcFromUser.add(:SUPERLUCK,
  proc { |ability, user, target, c|
    next (c + 1)
  }
)

#===============================================================================
# にげあし
#===============================================================================
# ぎゃくじょう と 同じ条件で 素早さが 3段階上がる
#-------------------------------------------------------------------------------
Battle::AbilityEffects::AfterMoveUseFromTarget.add(:RUNAWAY,
  proc { |ability, target, user, move, switched_battlers, battle|
    next if !move.damagingMove?
    next if !target.droppedBelowHalfHP
    next if !target.pbCanRaiseStatStage?(:SPEED, target)
    target.pbRaiseStatStageByAbility(:SPEED, 3, target)
  }
)

#===============================================================================
# はやてのつばさ
#===============================================================================
# 6世代のとき同じ内容に戻す
#-------------------------------------------------------------------------------
Battle::AbilityEffects::PriorityChange.add(:GALEWINGS,
  proc { |ability, battler, move, pri|
    next pri + 1 if move.type == :FLYING
  }
)