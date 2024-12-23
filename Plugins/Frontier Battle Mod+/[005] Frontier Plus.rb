module Frontier_Plus
  CORE = ["species", "moves"]
  LHS_VALID = CORE + [
    "item","items_rand","nature", "evs", "ivs_core" ,  "ability","ability_rand","moves_rand","move1_rand","move2_rand", "move3_rand","move4_rand",
    "evs_core", "tera" , "teras_rand" ,  "dynamaxlv" , "gigantamax"
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
    when "items_rand"
      items = rhs.unblanked.split(",")
      rhs = []
      for item in items
        next unless item.include?("_")
        value , rate = item.split("_")
        item_data = GameData::Item.try_get(value.to_sym)
        item_f = {
          "value": item_data.id,
          "rate": rate.to_i
        }
        rhs.push(item_f) if item_data
      end
    when "nature"
      rhs = GameData::Nature.exists?(rhs.to_sym) ? GameData::Nature.get(rhs.to_sym).id : nil
    when "ability"
      rhs = GameData::Ability.exists?(rhs.to_sym) ? GameData::Ability.get(rhs.to_sym).id : nil
    when "ability_rand"
      abilities = rhs.unblanked.split(",")
      rhs = []
      for ability in abilities
        next unless ability.include?("_")
        value , rate = ability.split("_")
        ability_data = GameData::Ability.try_get(value.to_sym)
        ability_f = {
          "value": ability_data.id,
          "rate": rate.to_i
        }
        rhs.push(ability_f) if ability_data
      end
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
    when "teras_rand"
      teras = rhs.unblanked.split(",")
      rhs = []
      for tera in teras
        next unless tera.include?("_")
        value , rate = tera.split("_")
        tera_data = GameData::Type.try_get(value.to_sym)
        tera_f = {
          "value": tera_data.id,
          "rate": rate.to_i
        }
        rhs.push(tera_f) if tera_data
      end
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
    when "ivs_core"
      ivs = rhs.unblanked.split(",")
      rhs = {}
      for iv_c in ivs
        next unless iv_c.include?("_")
        iv, amt = iv_c.split("_")
        iv = evaluate_ev(iv)
        next unless iv
        amt = amt.to_i
        rhs[iv] = amt
      end
    when "moves"
      moves = rhs.unblanked.split(",")
      rhs = []
      for move in moves
        move_data = GameData::Move.try_get(move.to_sym)
        rhs.push(move_data.id) if move_data
      end
      rhs.push(GameData::Move.keys.first) if rhs.length == 0 # Get any one move
    when "moves_rand" , "move1_rand" , "move2_rand" , "move3_rand" , "move4_rand"
      moves = rhs.unblanked.split(",")
      rhs = []
      for move in moves
        next unless move.include?("_")
        value , rate = move.split("_")
        move_data = GameData::Move.try_get(value.to_sym)
        move_f = {
          "value": move_data.id,
          "rate": rate.to_i
        }
        rhs.push(move_f) if move_data
      end
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

    # アイテム
    if hash["items_rand"]
      selected_item = nil
      loop do
         # ここでアイテムデータを rand で取得する
        selected_item = hash["items_rand"].select { |item| rand(100) < item[:rate] }
        break unless selected_item.empty? # 空配列でなければループを抜ける
      end
      # アイテムデータは 1つ固定
      selected_itemindex = selected_item.sample
      itm = GameData::Item.try_get(selected_item[0][:value])
    else
      itm = GameData::Item.try_get(hash["item"])
    end

    @item    = itm ? itm.id : nil
    @nature  = hash["nature"]

    # 特性
    if hash["ability_rand"]
      selected_ability = nil
      loop do
        selected_ability = hash["ability_rand"].select { |ability| rand(100) < ability[:rate] }
        break unless selected_ability.empty?
      end
      selected_abilityindex = selected_ability.sample
      @ability = selected_abilityindex[:value]
    else
      @ability = hash["ability"]
    end

    # 技
    if hash["move1_rand"] && hash["move2_rand"] && hash["move3_rand"] && hash["move4_rand"]
      move_pools = [
        hash["move1_rand"],
        hash["move2_rand"],
        hash["move3_rand"],
        hash["move4_rand"]
      ]
      max_selections = 0
      selected_moves = []

      # 各技のプールから選択
      move_pools.each do |pool|
        select_moves_from_pool(pool, max_selections + 1, selected_moves)
        max_selections += 1
      end
      @move1 , @move2 , @move3 , @move4 = selected_moves

    elsif hash["moves_rand"]
      max_selections = 4
      selected_moves = []

      # 100%の技を取得
      guaranteed_moves = hash["moves_rand"].select { |move| move[:rate] == 100 }
      selected_moves.concat(guaranteed_moves.map { |move| move[:value] }.sample([guaranteed_moves.size, max_selections].min))
      
      available_moves = hash["moves_rand"].dup
      
      # 100%の技を削除
      guaranteed_moves.each { |move| available_moves.delete(move) }

      until selected_moves.length == max_selections
        selected_move = available_moves.select { |move| rand(100) < move[:rate] }
        next if selected_move.empty?

        # 取り出す 配列から要素数を減らす
        choose = selected_move.sample
        selected_moves << choose[:value]
        # 元の配列から正確に要素を削除
        available_moves.delete(choose)
      end
      @move1, @move2, @move3, @move4 = selected_moves
    else
      @move1, @move2, @move3, @move4 = hash["moves"]
    end

    @ev = []
    unless hash["evs"] == nil 
      for t_ev in hash["evs"]
        @ev.push(GameData::Stat.get(t_ev))
      end
    end
    @ev_core = hash["evs_core"] || {}

    # IVs
    @ivs_core = hash["ivs_core"] || {}

    # Dynamax
    if Settings::DYNAMAX_PBS_FILE
      @dynamax_lvl = hash["dynamaxlv"] || Settings::DYNAMAX_LEVEL_DEFAULT
      @gmax_factor = hash["gigantamax"] || Settings::GIGANTAMAX_DEFAULT
    else
      @dynamax_lvl = Settings::DYNAMAX_LEVEL_DEFAULT
      @gmax_factor = false
    end

    # Tera Type
    if hash["teras_rand"]
      selected_tera = nil
      loop do
        selected_tera = hash["teras_rand"].select { |tera| rand(100) < tera[:rate] }
        break unless selected_tera.empty?
      end
      selected_teraindex = selected_tera.sample
      @tera = selected_teraindex[:value]
    else
      @tera = hash["tera"]
    end

  end

  def select_moves_from_pool(pool, max_selections, selected_moves)
    # 100% の技を優先的に選ぶ
    guaranteed_moves = pool.select { |move| move[:rate] == 100 }
    guaranteed_moves.each do |move|
      selected_moves << move[:value] unless selected_moves.include?(move[:value])
      break if selected_moves.size == max_selections
    end
  
    # 100% の技を除いた残りの技
    available_moves = pool - guaranteed_moves
  
    # ランダムに技を追加
    until selected_moves.size == max_selections
      selected_move = available_moves.select { |move| rand(100) < move[:rate] }
      next if selected_move.empty?
  
      chosen_move = selected_move.sample
      unless selected_moves.include?(chosen_move[:value])
        selected_moves << chosen_move[:value]
        available_moves.delete(chosen_move) # 重複防止
      end
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
    # IVs specific
    if @ivs_core.keys.length > 0
      pkmn.iv = {}
      for stat, amount in @ivs_core
        pkmn.iv[stat] = amount
      end
      GameData::Stat.each_main do |s|
      next if pkmn.iv[s.id]
      pkmn.iv[s.id] = 0
      end
    end
    
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
      iv_hash = {}
      for stat, amount in pkmn.iv
        next if amount <= 0
        iv_hash[stat] = amount
      end
      hash = {
        "species" => pkmn.species,
        "item" => pkmn.item_id,
        "nature" => pkmn.nature,
        "ability" => pkmn.ability,
        "moves" => [mov1, mov2, mov3, mov4],
        "evs" => [],
        "evs_core" => ev_hash,
        "ivs_core" => iv_hash,
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