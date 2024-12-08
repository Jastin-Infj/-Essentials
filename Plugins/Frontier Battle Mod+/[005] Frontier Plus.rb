module Frontier_Plus
  CORE = ["species", "moves"]
  LHS_VALID = CORE + [
    "item", "nature", "evs", "ability",
    "evs_core", "tera" , "dynamaxlv" , "gigantamax"
  ]

  def self.compile_pbs(line, hash, id_number)
    hash["new_section"] = line.starts_with?("[")
    return hash if hash["new_section"]
    lhs, rhs = line.unblanked.split("=")
    # downcase the LHS_VALID keys
    lhs = lhs.downcase
    return hash unless LHS_VALID.include?(lhs)
    # Validation (sort of)!
    case lhs
    when "species"
      rhs = GameData::Species.exists?(rhs.to_sym) ? GameData::Species.get(rhs.to_sym).id : nil
    when "item"
      rhs = GameData::Item.exists?(rhs.to_sym) ? GameData::Item.get(rhs.to_sym).id : nil
    when "nature"
      rhs = GameData::Nature.exists?(rhs.to_sym) ? GameData::Nature.get(rhs.to_sym).id : nil
    when "ability"
      rhs = GameData::Ability.exists?(rhs.to_sym) ? GameData::Ability.get(rhs.to_sym).id : nil
    when "dynamaxlv"
      rhs = rhs.to_i
    when "gigantamax"
      if rhs == "TRUE"
        rhs = true
      elsif rhs == "FALSE"
        rhs = false
      end
    when "tera"
      rhs = GameData::Type.exists?(rhs.to_sym) ? GameData::Type.get(rhs.to_sym).id : nil
    when "evs"
      evs = rhs.unblanked.split(",")
      rhs = []
      for ev in evs
        t_ev = evaluate_ev(ev)
        rhs.push(t_ev) if t_ev
      end
    when "evs_core"
      evs = rhs.unblanked.split(",")
      rhs = {}
      for ev_c in evs
        next unless ev_c.include?("_")
        ev, amt = ev_c.split("_")
        ev = evaluate_ev(ev)
        next unless ev
        amt = amt.to_i
        rhs[ev] = amt
      end
    when "moves"
      moves = rhs.unblanked.split(",")
      rhs = []
      for move in moves
        move_data = GameData::Move.try_get(move.to_sym)
        rhs.push(move_data.id) if move_data
      end
      rhs.push(GameData::Move.keys.first) if rhs.length == 0 # Get any one move
    end
    hash[lhs] = rhs
    return hash
  end
end


class PBPokemon

  alias swdfm_init_new initialize
  def initialize(*args)
    unless USE_FRONTIER_PLUS
      return swdfm_init_new(*args)
    end
    hash = args[0]

    # Data
    # { 
    # "new_section"=>true, 
    # "species"=>:SUNKERN, 
    # "item"=>:LAXINCENSE, 
    # "nature"=>:RELAXED, 
    # "ability"=>:EARLYBIRD,
    # "dynamaxlv"=>10,
    # "gigantamax"=>true, 
    # "tera"=>:ROCK, 
    # "evs"=>[:HP, :SPECIAL_ATTACK], 
    # "moves"=>[:MEGADRAIN, :HELPINGHAND, :SUNNYDAY, :LIGHTSCREEN]
    # }

    @species = hash["species"]
    itm = GameData::Item.try_get(hash["item"])
    @item    = itm ? itm.id : nil
    @nature  = hash["nature"]
    @ability = hash["ability"]
    @move1, @move2, @move3, @move4 = hash["moves"]
    @ev = []
    unless hash["evs"] == nil 
      for t_ev in hash["evs"]
        @ev.push(GameData::Stat.get(t_ev))
      end
    end
    @ev_core = hash["evs_core"] || {}
    @tera = hash["tera"]

    # Dynamax
    if Settings::DYNAMAX_PBS_FILE
      @dynamax_lvl = hash["dynamaxlv"] || Settings::DYNAMAX_LEVEL_DEFAULT
      @gmax_factor = hash["gigantamax"] || Settings::GIGANTAMAX_DEFAULT
    else
      @dynamax_lvl = Settings::DYNAMAX_LEVEL_DEFAULT
      @gmax_factor = false
    end
  end

  alias swdfm_create_pokemon createPokemon
  def createPokemon(level, iv, trainer)
    unless USE_FRONTIER_PLUS
      return swdfm_create_pokemon(level, iv, trainer)
    end
    pkmn = Pokemon.new(@species, level, trainer, false)
    pkmn.item = @item if @item
    pkmn.personalID = rand(2**16) | (rand(2**16) << 16)
    pkmn.nature = @nature if @nature
    pkmn.happiness = 0
    pkmn.moves.push(Pokemon::Move.new(self.convertMove(@move1)))
    pkmn.moves.push(Pokemon::Move.new(self.convertMove(@move2))) if @move2
    pkmn.moves.push(Pokemon::Move.new(self.convertMove(@move3))) if @move3
    pkmn.moves.push(Pokemon::Move.new(self.convertMove(@move4))) if @move4
    pkmn.moves.compact!
    if @ev.length > 0
      @ev.each { |stat| pkmn.ev[stat.id] = Pokemon::EV_LIMIT / @ev.length }
    end
    # Ability
    pkmn.ability = @ability if @ability

    # Add
    if pkmn.dynamax_able == true
      pkmn.dynamax_lvl = @dynamax_lvl
      pkmn.gmax_factor = @gmax_factor

      # If the Pokemon is not Gmax-able, then it cannot be Dynamax-able
      unless pkmn.hasGigantamaxForm?
        pkmn.gmax_factor = false
      end
    end

    # EVs specific
    if @ev_core.keys.length > 0
      pkmn.ev = {}
      for stat, amount in @ev_core
        pkmn.ev[stat] = amount
      end
      GameData::Stat.each_main do |s|
	    next if pkmn.ev[s.id]
	    pkmn.ev[s.id] = 0
	    end
    end
    # Tera Type (If Applicable)
    # Shoutout to Ludicious!
    if Pokemon.method_defined?(:tera_type)
      pkmn.tera_type = @tera if @tera
    end
    GameData::Stat.each_main { |s| pkmn.iv[s.id] = iv }
    pkmn.calc_stats
    return pkmn
  end


  class << self
    alias swdfm_from_pokemon fromPokemon
    
#-------------------------------
# Changes made to self.fromPokemon
    def fromPokemon(pkmn)
      unless USE_FRONTIER_PLUS
        return swdfm_from_pokemon(pkmn)
      end
      mov1 = (pkmn.moves[0]) ? pkmn.moves[0].id : nil
      mov2 = (pkmn.moves[1]) ? pkmn.moves[1].id : nil
      mov3 = (pkmn.moves[2]) ? pkmn.moves[2].id : nil
      mov4 = (pkmn.moves[3]) ? pkmn.moves[3].id : nil
      ev_hash = {}
      for stat, amount in pkmn.ev
        next if amount <= 0
        ev_hash[stat] = amount
      end
      hash = {
        "species" => pkmn.species,
        "item" => pkmn.item_id,
        "nature" => pkmn.nature,
        "ability" => pkmn.ability,
        "moves" => [mov1, mov2, mov3, mov4],
        "evs" => [],
        "evs_core" => ev_hash,
        "tera" => nil,
        "dynamaxlv" => nil,
        "gigantamax" => nil
      }
      if Pokemon.method_defined?(:tera_type)
        hash["tera"] = pkmn.tera_type
      end

      if Pokemon.method_defined?(:dynamax_able) && pkmn.dynamax_able == true
        hash["dynamaxlv"] = pkmn.dynamax_lvl
        hash["gigantamax"] = pkmn.gmax_factor
      end

      return new(hash)
    end
    
#-------------------------------
# Ends "self" part
  end

end