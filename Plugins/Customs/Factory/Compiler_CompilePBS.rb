module Compiler
  module_function
  # ! Frontiers Plus .rb に記載
  # def compile_trainer_lists(path = "PBS/battle_facility_lists.txt")
  #   compile_pbs_file_message_start(path)
  #   btTrainersRequiredTypes = {
  #     "Trainers"   => [0, "s"],
  #     "Pokemon"    => [1, "s"],
  #     "Challenges" => [2, "*s"]
  #   }
  #   if !FileTest.exist?(path)
  #     File.open(path, "wb") do |f|
  #       f.write(0xEF.chr)
  #       f.write(0xBB.chr)
  #       f.write(0xBF.chr)
  #       f.write("[DefaultTrainerList]\r\n")
  #       f.write("Trainers = battle_tower_trainers.txt\r\n")
  #       f.write("Pokemon = battle_tower_pokemon.txt\r\n")
  #     end
  #   end
  #   sections = []
  #   MessageTypes.setMessagesAsHash(MessageTypes::FRONTIER_INTRO_SPEECHES, [])
  #   MessageTypes.setMessagesAsHash(MessageTypes::FRONTIER_END_SPEECHES_WIN, [])
  #   MessageTypes.setMessagesAsHash(MessageTypes::FRONTIER_END_SPEECHES_LOSE, [])
  #   File.open(path, "rb") do |f|
  #     FileLineData.file = path
  #     idx = 0
  #     pbEachFileSection(f) do |section, name|
  #       echo "."
  #       idx += 1
  #       Graphics.update
  #       next if name != "DefaultTrainerList" && name != "TrainerList"
  #       rsection = []
  #       section.each_key do |key|
  #         FileLineData.setSection(name, key, section[key])
  #         schema = btTrainersRequiredTypes[key]
  #         next if key == "Challenges" && name == "DefaultTrainerList"
  #         next if !schema
  #         record = get_csv_record(section[key], schema)
  #         rsection[schema[0]] = record
  #       end
  #       if !rsection[0]
  #         raise _INTL("No trainer data file given in section {1}.\n{2}", name, FileLineData.linereport)
  #       end
  #       if !rsection[1]
  #         raise _INTL("No trainer data file given in section {1}.\n{2}", name, FileLineData.linereport)
  #       end
  #       rsection[3] = rsection[0]
  #       rsection[4] = rsection[1]
  #       rsection[5] = (name == "DefaultTrainerList")
  #       if FileTest.exist?("PBS/" + rsection[0])
  #         rsection[0] = compile_battle_tower_trainers("PBS/" + rsection[0])
  #       else
  #         rsection[0] = []
  #       end
  #       if FileTest.exist?("PBS/" + rsection[1])
  #         filename = "PBS/" + rsection[1]
  #         rsection[1] = []
  #         pbCompilerEachCommentedLine(filename) do |line, _lineno|
  #           rsection[1].push(PBPokemon.fromInspected(line))
  #         end
  #       else
  #         rsection[1] = []
  #       end
  #       rsection[2] = [] if !rsection[2]
  #       while rsection[2].include?("")
  #         rsection[2].delete("")
  #       end
  #       rsection[2].compact!
  #       sections.push(rsection)
  #     end
  #   end
  #   save_data(sections, "Data/trainer_lists.dat")
  #   process_pbs_file_message_end
  # end

  def compile_battle_tower_trainers(filename)
    sections = []
    requiredtypes = {
      "Type"          => [0, "e", :TrainerType],
      "Name"          => [1, "s"],
      "BeginSpeech"   => [2, "s"],
      "EndSpeechWin"  => [3, "s"],
      "EndSpeechLose" => [4, "s"],
      "PokemonNos"    => [5, "*u"],
      "Items"         => [6, "*e",:Item],
    }
    trainernames  = []
    beginspeech   = []
    endspeechwin  = []
    endspeechlose = []
    items         = []
    # ファイルパスの存在確認
    if FileTest.exist?(filename)
      File.open(filename, "rb") do |f|
        FileLineData.file = filename
        pbEachFileSection(f) do |section, name|
          # トレーナー格納
          rsection = []
          # requiredtypesキーの存在するやつだけ処理
          section.each_key do |key|
            FileLineData.setSection(name, key, section[key])
            schema = requiredtypes[key]
            next if !schema
            # CSVレコードを取得
            record = get_csv_record(section[key], schema)
            # 主キーに設定
            rsection[schema[0]] = record
          end
          # データ格納
          trainernames.push(rsection[1])
          beginspeech.push(rsection[2])
          endspeechwin.push(rsection[3])
          endspeechlose.push(rsection[4])
          # items          
          items.push(rsection[6])
          sections.push(rsection)
        end
      end
    end
    MessageTypes.addMessagesAsHash(MessageTypes::TRAINER_NAMES, trainernames)
    MessageTypes.addMessagesAsHash(MessageTypes::FRONTIER_INTRO_SPEECHES, beginspeech)
    MessageTypes.addMessagesAsHash(MessageTypes::FRONTIER_END_SPEECHES_WIN, endspeechwin)
    MessageTypes.addMessagesAsHash(MessageTypes::FRONTIER_END_SPEECHES_LOSE, endspeechlose)
    return sections
  end
end
