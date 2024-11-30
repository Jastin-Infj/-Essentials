class BattleSwapScene
  BATTLE_FACTORY_RENTALS_SINGLE = 3
  BATTLE_FACTORY_RENTALS_DOUBLE = 4

  # 再定義
  def initialize(doublebattle)
    @doublebattle = doublebattle
  end

  # 再定義
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




class BattleSwapScreen
  BATTLE_FACTORY_RENTALS_SINGLE = 3
  BATTLE_FACTORY_RENTALS_DOUBLE = 4

  # 再定義
  def initialize(scene , doublebattle)
    @scene = scene
    @doublebattle = doublebattle
  end

  # 再定義
  def pbStartRent(rentals)
    @scene.pbStartRentScene(rentals)
    chosen = []
    num = nil
    msgComfirm = nil

    if @doublebattle
      num = BATTLE_FACTORY_RENTALS_DOUBLE
      msgComfirm = _INTL("Are these fourth Pokémon OK?")
    else
      num = BATTLE_FACTORY_RENTALS_SINGLE
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
          # シングルとダブルで選択数が異なる
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
