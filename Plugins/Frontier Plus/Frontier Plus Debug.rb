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
    filename = "PBS/cup_little_pkmn.txt"
    if FileTest.exist?(filename)
      Frontier_Plus.convert_files(filename)
      USE_FRONTIER_PLUS = true
    end

    if USE_FRONTIER_PLUS
      echoln "true"
    else
      echoln "false"
    end
  }
})
