class BattleChallenge
  def start(*args)
    t = ensureType(@id)
    @currentChallenge = @id   # must appear before pbStart
    @bc.pbStart(t, @numRounds)
  end

end

class BattleChallengeData
  def pbStart(t, numRounds)
    @inProgress   = true
    @resting      = false
    @decision     = 0
    @swaps        = t.currentSwaps
    @wins         = t.currentWins
    @battleNumber = 1
    @trainers     = []
    raise _INTL("Number of rounds is 0 or less.") if numRounds <= 0
    @numRounds = numRounds
    # Get all the trainers for the next set of battles
    btTrainers = pbGetBTTrainers(pbBattleChallenge.currentChallenge)
    while @trainers.length < @numRounds
      newtrainer = pbBattleChallengeTrainer(@wins + @trainers.length, btTrainers)
      found = false
      @trainers.each do |tr|
        found = true if tr == newtrainer
      end
      @trainers.push(newtrainer) if !found
    end
    @start = [$game_map.map_id, $game_player.x, $game_player.y]
    @oldParty = $player.party
    $player.party = @party if @party
    Game.save(safe: true)
  end
end

def pbBattleChallengeTrainer(win_count, bttrainers)
  # This table's start points and lengths are based on a bttrainers size of 300.
  # They are scaled based on the actual size of bttrainers later.

  # トレーナーの出現確率を変更する
  table = Settings::BATTLE_CHALLENGE_TRAINER_TABLE
  slot = nil
  table.each { |val| slot = val if val[0] <= win_count && (!slot || slot[0] < val[0]) }
  return 0 if !slot
  # Scale the start point and length based on how many trainers are in bttrainers
  offset = slot[1] * bttrainers.length / Settings::NPC_TRAINER_LENGTH
  length = slot[2] * bttrainers.length / Settings::NPC_TRAINER_LENGTH
  # Return a random trainer index from the chosen range
  random = rand(length)
  result = offset + random
  return result
end

def pbBattleFactoryPokemon(rules, win_count, swap_count, rentals)
  btpokemon = pbGetBTPokemon(pbBattleChallenge.currentChallenge)
  level = rules.ruleset.suggestedLevel
  pokemonNumbers = [0, 0]   # Start and end indices in btpokemon
  ivs = [0, 0]   # Lower and higher IV values for Pokémon to use
  iv_threshold = 6   # Number of Pokémon that use the lower IV
  set = [win_count / Settings::BATTLE_CHALLENGE_POKEMON_TABLE_WINCOUNTLOOP, Settings::BATTLE_CHALLENGE_POKEMON_TABLE_NUM_MAX].min   # The set of 7 battles win_count is part of (minus 1)
  # Choose a range of Pokémon in btpokemon to randomly select from. The higher
  # the set number, the later the range lies within btpokemon (typically).
  # This table's start point and end point values are based on a btpokemon size
  # of 881. They are scaled based on the actual size of btpokemon.
  # Group 1 is 0 - 173. Group 2 is 174 - 371. Group 3 is 372 - 881.
  if level == GameData::GrowthRate.max_level   # Open Level (Level 100)
    table = Settings::BATTLE_CHALLENGE_POKEMON_TABLE_OPEN
  else
    table = Settings::BATTLE_CHALLENGE_POKEMON_TABLE_DEFAULT
  end
  pokemonNumbers[0] = table[set][0] * btpokemon.length / Settings::BATTLE_CHALLENGE_POKEMON_TABLE_LENGTH
  pokemonNumbers[1] = table[set][1] * btpokemon.length / Settings::BATTLE_CHALLENGE_POKEMON_TABLE_LENGTH
  # Choose two IV values for Pokémon to use (the one for the current set, and
  # the one for the next set). The iv_threshold below determines which of these
  # two values a given Pokémon uses. The higher the set number, the higher these
  # values are.
  ivtable = Settings::IV_TABLE  # Last value is used for all higher sets
  ivs = [ivtable[set], ivtable[[set + 1, Settings::BATTLE_CHALLENGE_POKEMON_TABLE_NUM_MAX].min]]
  # Choose a threshold, which is the number of Pokémon with the lower IV out of
  # the two chosen above. The higher the swap_count, the lower this threshold
  # (i.e. the more Pokémon will have the higher IV).
  thresholds = [   # Each value is [minimum swap count, threshold value]
    [ 0, 6],
    [15, 5],
    [22, 4],
    [29, 3],
    [36, 2],
    [43, 1]
  ]
  thresholds.each { |val| iv_threshold = val[1] if swap_count >= val[0] }
  # Randomly choose Pokémon from the range to fill the party with
  old_min = rules.ruleset.minLength
  old_max = rules.ruleset.maxLength
  if rentals.length == 0
    rules.ruleset.setNumber(6)   # Rentals
  else
    rules.ruleset.setNumber(old_max + rentals.length)   # Opponent
  end
  party = []
  loop do
    party.clear
    while party.length < ((rentals.length == 0) ? 6 : old_max)
      rnd = pokemonNumbers[0] + rand(pokemonNumbers[1] - pokemonNumbers[0] + 1)
      rndpoke = btpokemon[rnd]
      indvalue = (party.length < iv_threshold) ? ivs[0] : ivs[1]
      party.push(rndpoke.createPokemon(level, indvalue, nil))
    end
    break if rules.ruleset.isValid?([].concat(party).concat(rentals))
  end
  rules.ruleset.setNumberRange(old_min, old_max)
  return party
end


class Battle::AI
  def initialize(battle)
    @battle = battle
  end
end

class RecordedBattle < Battle
  include RecordedBattleModule

  def pbGetBattleType; return 0; end
end