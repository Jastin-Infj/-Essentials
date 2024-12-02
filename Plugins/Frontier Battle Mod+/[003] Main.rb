#===============================================================================
# Factory NPC Pkmns init Settings
#===============================================================================
class BattleChallenge
  def register(id, doublebattle, numPokemon, battletype, mode = 1)
    ensureType(id)
    if battletype == BATTLE_FACTORY_ID
      @bc.setExtraData(BattleFactoryData.new(@bc, doublebattle))
      if doublebattle
        numPokemon = Settings::BATTLE_FACTORY_RENTALS_DOUBLE
      else
        numPokemon = Settings::BATTLE_FACTORY_RENTALS_SINGLE
      end
      battletype = BATTLE_TOWER_ID
    end
    @rules = modeToRules(doublebattle, numPokemon, battletype, mode) if !@rules
  end
end

#===============================================================================
# Factory NPC Trainer Settings
#===============================================================================
class BattleFactoryData
  def initialize(bcdata , doublebattle)
    @bcdata = bcdata
    # param required
    @doublebattle = doublebattle
  end

  #===============================================================================
  # Initial Setup
  #=============================================================================
  def pbPrepareRentals
    @rentals = pbBattleFactoryPokemon(pbBattleChallenge.rules, @bcdata.wins, @bcdata.swaps, [])
    @trainerid = @bcdata.nextTrainer
    bttrainers = pbGetBTTrainers(pbBattleChallenge.currentChallenge)
    trainerdata = bttrainers[@trainerid]
    @opponent = NPCTrainer.new(
      pbGetMessageFromHash(MessageTypes::TRAINER_NAMES, trainerdata[1]),
      trainerdata[0]
    )
    if Settings::ITEM_PARAM_FLAG
      @opponent.items = Settings::ITEM_TRAINER_FROINTIER_DEFAULT
      # itemNumber PBS
      if Settings::ITEM_TRAINER_PBS_FILE_PARAM && trainerdata[6] != nil
        @opponent.items += trainerdata[6]
      end
    end
    # echoln "pbPrepareRentals: #{@opponent.items}"
    @opponent.lose_text = pbGetMessageFromHash(MessageTypes::FRONTIER_END_SPEECHES_LOSE, trainerdata[4])
    @opponent.win_text = pbGetMessageFromHash(MessageTypes::FRONTIER_END_SPEECHES_WIN, trainerdata[3])
    opponentPkmn = pbBattleFactoryPokemon(pbBattleChallenge.rules, @bcdata.wins, @bcdata.swaps, @rentals)
    
    # Add
    if @doublebattle
      @opponent.party = opponentPkmn.sample(Settings::BATTLE_FACTORY_RENTALS_DOUBLE)
    else
      @opponent.party = opponentPkmn.sample(Settings::BATTLE_FACTORY_RENTALS_SINGLE)
    end
  end

  #===============================================================================
  # Repeat Setup
  #=============================================================================
  def pbPrepareSwaps
    @oldopponent = @opponent.party
    trainerid = @bcdata.nextTrainer
    bttrainers = pbGetBTTrainers(pbBattleChallenge.currentChallenge)
    trainerdata = bttrainers[trainerid]
    @opponent = NPCTrainer.new(
      pbGetMessageFromHash(MessageTypes::TRAINER_NAMES, trainerdata[1]),
      trainerdata[0]
    )
    if Settings::ITEM_PARAM_FLAG
      @opponent.items = Settings::ITEM_TRAINER_FROINTIER_DEFAULT
      # itemNumber PBS
      if Settings::ITEM_TRAINER_PBS_FILE_PARAM && trainerdata[6] != nil
        @opponent.items += trainerdata[6]
      end
    end
    @opponent.lose_text = pbGetMessageFromHash(MessageTypes::FRONTIER_END_SPEECHES_LOSE, trainerdata[4])
    @opponent.win_text = pbGetMessageFromHash(MessageTypes::FRONTIER_END_SPEECHES_WIN, trainerdata[3])
    opponentPkmn = pbBattleFactoryPokemon(pbBattleChallenge.rules, @bcdata.wins, @bcdata.swaps,
                                          [].concat(@rentals).concat(@oldopponent))
    if @doublebattle
      @opponent.party = opponentPkmn.sample(Settings::BATTLE_FACTORY_RENTALS_DOUBLE)
    else
      @opponent.party = opponentPkmn.sample(Settings::BATTLE_FACTORY_RENTALS_SINGLE)
    end
  end
end

#===============================================================================
# Factory Rentals
#===============================================================================
class BattleFactoryData
  #===============================================================================
  # Rentals Choose Setup
  #=============================================================================
  def pbChooseRentals
    pbFadeOutIn do
      scene = BattleSwapScene.new(@doublebattle)
      screen = BattleSwapScreen.new(scene , @doublebattle)
      @rentals = screen.pbStartRent(@rentals)
      @bcdata.pbAddSwap
      @bcdata.setParty(@rentals)
    end
  end

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

#===============================================================================
# Factory Rentals Choose Scene
#===============================================================================
class BattleSwapScene
  def initialize(doublebattle)
    # param required
    @doublebattle = doublebattle
  end
  #===============================================================================
  # Rentals Choose Text Setup
  #=============================================================================
  def pbUpdateChoices(choices)
    commands = pbGetCommands(@rentals, choices)
    @choices = choices

    if @doublebattle
      case choices.length
      when 0
        @sprites["help"].text = _INTL("Choose the first Pokémon.")
      when 1
        @sprites["help"].text = _INTL("Choose the second Pokémon.")
      when 2
        @sprites["help"].text = _INTL("Choose the third Pokémon.")
      else
        @sprites["help"].text = _INTL("Choose the fourth Pokémon.")
      end
    else
      case choices.length
      when 0
        @sprites["help"].text = _INTL("Choose the first Pokémon.")
      when 1
        @sprites["help"].text = _INTL("Choose the second Pokémon.")
      else
        @sprites["help"].text = _INTL("Choose the third Pokémon.")
      end
    end
    @sprites["list"].commands = commands
  end
end

#===============================================================================
# Factory Rentals Choose Screen
#===============================================================================
class BattleSwapScreen
  def initialize(scene , doublebattle)
    @scene = scene
    @doublebattle = doublebattle
  end

  def pbStartRent(rentals)
    @scene.pbStartRentScene(rentals)
    chosen = []
    num = nil
    msgComfirm = nil

    if @doublebattle
      num = Settings::BATTLE_FACTORY_RENTALS_DOUBLE
      msgComfirm = _INTL("Are these fourth Pokémon OK?")
    else
      num = Settings::BATTLE_FACTORY_RENTALS_SINGLE
      msgComfirm = _INTL("Are these three Pokémon OK?")
    end

    loop do
      index = @scene.pbChoosePokemon(false)
      commands = []
      commands.push(_INTL("SUMMARY"))
      if chosen.include?(index)
        commands.push(_INTL("DESELECT"))
      else
        commands.push(_INTL("RENT"))
      end
      commands.push(_INTL("OTHERS"))
      command = @scene.pbShowCommands(commands)
      case command
      when 0
        @scene.pbSummary(rentals, index)
      when 1
        if chosen.include?(index)
          chosen.delete(index)
          @scene.pbUpdateChoices(chosen.clone)
        else
          chosen.push(index)
          @scene.pbUpdateChoices(chosen.clone)
          # choose total number of rentals
          if chosen.length == num
            if @scene.pbConfirm(msgComfirm)
              retval = []
              chosen.each { |i| retval.push(rentals[i]) }
              @scene.pbEndScene
              return retval
            else
              chosen.delete(index)
              @scene.pbUpdateChoices(chosen.clone)
            end
          end
        end
      end
    end
  end
end