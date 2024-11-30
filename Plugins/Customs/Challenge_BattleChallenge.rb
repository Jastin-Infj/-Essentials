class BattleChallenge
  BATTLE_FACTORY_RENTALS_SINGLE = 3
  BATTLE_FACTORY_RENTALS_DOUBLE = 4

  def register(id, doublebattle, numPokemon, battletype, mode = 1)
    ensureType(id)
    if battletype == BATTLE_FACTORY_ID
      @bc.setExtraData(BattleFactoryData.new(@bc, doublebattle))
      if doublebattle
        numPokemon = BATTLE_FACTORY_RENTALS_DOUBLE
      else
        numPokemon = BATTLE_FACTORY_RENTALS_SINGLE
      end
      battletype = BATTLE_TOWER_ID
    end
    @rules = modeToRules(doublebattle, numPokemon, battletype, mode) if !@rules
  end

end


class BattleFactoryData
  BATTLE_FACTORY_RENTALS_SINGLE = 3
  BATTLE_FACTORY_RENTALS_DOUBLE = 4

  # 再定義
  def initialize(bcdata , doublebattle)
    @bcdata = bcdata
    @doublebattle = doublebattle
  end

  # 再定義
  def pbPrepareRentals
    @rentals = pbBattleFactoryPokemon(pbBattleChallenge.rules, @bcdata.wins, @bcdata.swaps, [])
    @trainerid = @bcdata.nextTrainer
    bttrainers = pbGetBTTrainers(pbBattleChallenge.currentChallenge)
    trainerdata = bttrainers[@trainerid]
    @opponent = NPCTrainer.new(
      pbGetMessageFromHash(MessageTypes::TRAINER_NAMES, trainerdata[1]),
      trainerdata[0]
    )
    @opponent.lose_text = pbGetMessageFromHash(MessageTypes::FRONTIER_END_SPEECHES_LOSE, trainerdata[4])
    @opponent.win_text = pbGetMessageFromHash(MessageTypes::FRONTIER_END_SPEECHES_WIN, trainerdata[3])
    opponentPkmn = pbBattleFactoryPokemon(pbBattleChallenge.rules, @bcdata.wins, @bcdata.swaps, @rentals)
    
    # Add
    if @doublebattle
      @opponent.party = opponentPkmn.sample(BATTLE_FACTORY_RENTALS_DOUBLE)
    else
      @opponent.party = opponentPkmn.sample(BATTLE_FACTORY_RENTALS_SINGLE)
    end
  end

  # 再定義
  def pbChooseRentals
    pbFadeOutIn do
      scene = BattleSwapScene.new(@doublebattle)
      screen = BattleSwapScreen.new(scene , @doublebattle)
      @rentals = screen.pbStartRent(@rentals)
      @bcdata.pbAddSwap
      @bcdata.setParty(@rentals)
    end
  end

  # 再定義
  def pbPrepareSwaps
    @oldopponent = @opponent.party
    trainerid = @bcdata.nextTrainer
    bttrainers = pbGetBTTrainers(pbBattleChallenge.currentChallenge)
    trainerdata = bttrainers[trainerid]
    @opponent = NPCTrainer.new(
      pbGetMessageFromHash(MessageTypes::TRAINER_NAMES, trainerdata[1]),
      trainerdata[0]
    )
    @opponent.lose_text = pbGetMessageFromHash(MessageTypes::FRONTIER_END_SPEECHES_LOSE, trainerdata[4])
    @opponent.win_text = pbGetMessageFromHash(MessageTypes::FRONTIER_END_SPEECHES_WIN, trainerdata[3])
    opponentPkmn = pbBattleFactoryPokemon(pbBattleChallenge.rules, @bcdata.wins, @bcdata.swaps,
                                          [].concat(@rentals).concat(@oldopponent))
    if @doublebattle
      @opponent.party = opponentPkmn.sample(BATTLE_FACTORY_RENTALS_DOUBLE)
    else
      @opponent.party = opponentPkmn.sample(BATTLE_FACTORY_RENTALS_SINGLE)
    end
  end

  # 再定義
  def pbChooseSwaps
    swapMade = true
    pbFadeOutIn do
      scene = BattleSwapScene.new(@doublebattle)
      screen = BattleSwapScreen.new(scene , @doublebattle)
      swapMade = screen.pbStartSwap(@rentals, @oldopponent)
      @bcdata.pbAddSwap if swapMade
      @bcdata.setParty(@rentals)
    end
    return swapMade
  end

end