#===============================================================================
#
#===============================================================================
def pbGenerateBattleTrainer(idxTrainer, rules)
  bttrainers = pbGetBTTrainers(pbBattleChallenge.currentChallenge)
  btpokemon = pbGetBTPokemon(pbBattleChallenge.currentChallenge)
  level = rules.ruleset.suggestedLevel
  # Create the trainer
  trainerdata = bttrainers[idxTrainer]
  ##! Selct Test
  echoln "Trainer Index: #{idxTrainer}"
  trainerdata = bttrainers[0]

  opponent = NPCTrainer.new(
    pbGetMessageFromHash(MessageTypes::TRAINER_NAMES, trainerdata[1]),
    trainerdata[0]
  )

  # Defualt Items
  opponent.items = [:MEGARING,:ZRING,:ZPOWERRING,:DYNAMAXBAND,:TERAORB,:GLIMMERINGCHARM]
  
  # itemData を追加している場合
  if trainerdata[6] != nil
    opponent.items += trainerdata[6]
  end
  echoln "pbGenerateBattleTrainer: #{opponent.items}"

  # Determine how many IVs the trainer's Pokémon will have
  indvalues = 31
  indvalues = 21 if idxTrainer < 220
  indvalues = 18 if idxTrainer < 200
  indvalues = 15 if idxTrainer < 180
  indvalues = 12 if idxTrainer < 160
  indvalues = 9 if idxTrainer < 140
  indvalues = 6 if idxTrainer < 120
  indvalues = 3 if idxTrainer < 100
  # Get the indices within bypokemon of the Pokémon the trainer may have
  pokemonnumbers = trainerdata[5]
  # The number of possible Pokémon is <= the required number; make them
  # all Pokémon and use them
  if pokemonnumbers.length <= rules.ruleset.suggestedNumber
    pokemonnumbers.each do |n|
      rndpoke = btpokemon[n]
      pkmn = rndpoke.createPokemon(level, indvalues, opponent)
      opponent.party.push(pkmn)
    end
    return opponent
  end
  # There are more possible Pokémon than there are spaces available in the
  # trainer's party; randomly choose Pokémon
  loop do
    opponent.party.clear
    while opponent.party.length < rules.ruleset.suggestedNumber
      rnd = pokemonnumbers[rand(pokemonnumbers.length)]
      rndpoke = btpokemon[rnd]
      pkmn = rndpoke.createPokemon(level, indvalues, opponent)
      opponent.party.push(pkmn)
    end
    break if rules.ruleset.isValid?(opponent.party)
  end

  return opponent
end