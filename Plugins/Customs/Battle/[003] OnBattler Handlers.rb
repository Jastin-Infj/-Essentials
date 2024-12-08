#===============================================================================
# Critical hit boosting items (Dire Hit)
#===============================================================================											  
Battle::AI::Handlers::BattlerItemEffectScore.add(:DIREHIT,
  proc { |item, score, battler, ai, battle|
    old_score = score
    #-------------------------------------------------------------------------
    # Determines critical hit stages.
    case item
    when :DIREHIT     then increment = 1
    when :DIREHIT2    then increment = 2
    when :DIREHIT3    then increment = 3
    when :LANSATBERRY then increment = 2
    end
    if !increment
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because item doesn't raise critical hit ratio")
      next score
    end
    stages = battler.effects[PBEffects::FocusEnergy]
    if stages >= increment
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because unable to raise #{battler.name}'s critical hit ratio")
      next score
    end
    if battler.rough_end_of_round_damage >= battler.hp
      score = Battle::AI::ITEM_USELESS_SCORE
      PBDebug.log_score_change(score - old_score, "useless because #{battler.name} predicted to faint this round")
      next score
    end
    if battler.item_active?
      if [:RAZORCLAW, :SCOPELENS].include?(battler.item_id) ||
         (battler.item_id == :LUCKYPUNCH && battler.battler.isSpecies?(:CHANSEY)) ||
         ([:LEEK, :STICK].include?(battler.item_id) &&
         (battler.battler.isSpecies?(:FARFETCHD) || battler.battler.isSpecies?(:SIRFETCHD)))
        stages += 1
      end
    end
    stages += 1 if battler.has_active_ability?(:SUPERLUCK)
    stages += 1 if battler.has_active_ability?(:SNIPTERON)
    #---------------------------------------------------------------------------
    # Calculates the crit boosting score.
    desire_mult = (battler.opposes?(ai.trainer)) ? -1 : 1
    if stages < 3 && battler.check_for_move { |m| m.damagingMove? && m.pp > 0 }
      increment = [increment, 3 - stages].min
      score += 3 * increment
      if ai.trainer.has_skill_flag?("HPAware")
        score += increment * desire_mult * ((100 * battler.hp / battler.totalhp) - 50) / 8
      end
      if battler.stages[:ATTACK] < 0 && battler.check_for_move { |m| m.physicalMove? && m.pp > 0 }
        score += 8 * desire_mult
      end
      if battler.stages[:SPECIAL_ATTACK] < 0 && battler.check_for_move { |m| m.specialMove? && m.pp > 0 }
        score += 8 * desire_mult
      end
      score += 10 * desire_mult if battler.has_active_ability?(:SNIPER)
      score += 10 * desire_mult if stages < 2 && battler.check_for_move { |m| m.highCriticalRate? && m.pp > 0 }
      score -= 20 * desire_mult if battler.pbOpposingSide.effects[PBEffects::LuckyChant] > 0
      score -= 10 * desire_mult if battler.opponent_side_has_ability?([:ANGERPOINT, :BATTLEARMOR, :SHELLARMOR])
      if desire_mult > 0
        functions = [
          "FixedDamage",
          "AlwaysCriticalHit",
          "RaiseUserCriticalHitRate1",
          "RaiseUserCriticalHitRate2",
          "RaiseUserCriticalHitRate3"
        ]
        battler.moves.each do |m|
          next if m.pp == 0
          score -= 10 if functions.any? { |f| m.function_code.include?(f) }
        end
      end
      PBDebug.log_score_change(score - old_score, "raising #{battler.name}'s critical hit ratio")
    elsif desire_mul < 0
      score += 5
      PBDebug.log_score_change(score - old_score, "#{battler.name} doesn't benefit from raised critical hit ratio")
    else
      score = Battle::AI::ITEM_USELESS_SCORE
      PBDebug.log_score_change(score - old_score, "useless because #{battler.name} doesn't need raised critical hit ratio")
    end
    next score
  }
)