MenuHandlers.add(:debug_menu, :frontier_menu, {
  "name"        => _INTL("Testing..."),
  "parent"      => :main,
  "description" => _INTL("Battle Frontier Pokemon Con"),
  "always_show" => false
})
MenuHandlers.add(:debug_menu, :frontier_test, {
  "name"        => _INTL("Convert Test"),
  "parent"      => :frontier_menu,
  "description" => _INTL("testing..."),
  "effect"      => proc {

    filenames = [
      "PBS/battle_tower_pokemon.txt",
      "PBS/cup_fancy_pkmn_single.txt",
      "PBS/cup_fancy_pkmn.txt",
      "PBS/cup_little_pkmn.txt",
      "PBS/cup_pika_pkmn.txt",
      "PBS/cup_poke_pkmn.txt",
    ]

    filenames.each do |filename|
      if FileTest.exist?(filename)
        Frontier_Plus.convert_file(filename,false)
      end
    end
    USB_FRONTIER_PLUS = true
    Compiler.compile_trainer_lists()

    if USE_FRONTIER_PLUS
      echoln "true"
    else
      echoln "false"
    end
  }
})

MenuHandlers.add(:debug_menu, :frontier_test2, {
  "name"        => _INTL("Plus Mode ON"),
  "parent"      => :frontier_menu,
  "description" => _INTL("USB FRONTIER PLUS Switch ON "),
  "effect"      => proc {
    USE_FRONTIER_PLUS = true
  }
})