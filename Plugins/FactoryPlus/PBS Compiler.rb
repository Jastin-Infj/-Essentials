#===============================================================================
# PBS Format for Item NPCTrainer
#===============================================================================
module Compiler
  module_function
  #===============================================================================
  # Read Item NPCTrainer
  #===============================================================================
  def compile_battle_tower_trainers(filename)
    sections = []
    requiredtypes = {
      "Type"          => [0, "e", :TrainerType],
      "Name"          => [1, "s"],
      "BeginSpeech"   => [2, "s"],
      "EndSpeechWin"  => [3, "s"],
      "EndSpeechLose" => [4, "s"],
      "PokemonNos"    => [5, "*u"]
    }
    if Settings::ITEM_TRAINER_PBS_FILE_PARAM
      requiredtypes = {
        "Type"          => [0, "e", :TrainerType],
        "Name"          => [1, "s"],
        "BeginSpeech"   => [2, "s"],
        "EndSpeechWin"  => [3, "s"],
        "EndSpeechLose" => [4, "s"],
        "PokemonNos"    => [5, "*u"],
        "Items"         => [6, "*e",:Item],
      }
    end

    trainernames  = []
    beginspeech   = []
    endspeechwin  = []
    endspeechlose = []
    items         = []
    # existence check
    if FileTest.exist?(filename)
      File.open(filename, "rb") do |f|
        FileLineData.file = filename
        pbEachFileSection(f) do |section, name|
          # temp storage
          rsection = []
          # requiredtypes key has to be processed
          section.each_key do |key|
            FileLineData.setSection(name, key, section[key])
            schema = requiredtypes[key]
            next if !schema
            # CSV
            record = get_csv_record(section[key], schema)
            # Type -> ["key"] access
            rsection[schema[0]] = record
          end
          # data storage
          trainernames.push(rsection[1])
          beginspeech.push(rsection[2])
          endspeechwin.push(rsection[3])
          endspeechlose.push(rsection[4])

          if Settings::ITEM_TRAINER_PBS_FILE_PARAM
            # PBS.txt
            # Items = POTION -> :POTION
            # Add items [[:Item1 , :Items2] , [:Items3] , nil , ...]
            items.push(rsection[6])
          end
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

  #===============================================================================
  # Write Item NPCTrainer
  #===============================================================================
  def write_battle_tower_trainers(bttrainers, filename)
    return if !bttrainers || !filename

    btTrainersRequiredTypes = {
      "Type"          => [0, "e", nil],   # Specifies a trainer
      "Name"          => [1, "s"],
      "BeginSpeech"   => [2, "s"],
      "EndSpeechWin"  => [3, "s"],
      "EndSpeechLose" => [4, "s"],
      "PokemonNos"    => [5, "*u"]
    }
    if Settings::ITEM_TRAINER_PBS_FILE_PARAM
      btTrainersRequiredTypes = {
        "Type"          => [0, "e", nil],   # Specifies a trainer
        "Name"          => [1, "s"],
        "BeginSpeech"   => [2, "s"],
        "EndSpeechWin"  => [3, "s"],
        "EndSpeechLose" => [4, "s"],
        "PokemonNos"    => [5, "*u"],
        "Items"         => [6, "*e", :Item],
      }
    end

    File.open(filename, "wb") do |f|
      add_PBS_header_to_file(f)
      bttrainers.length.times do |i|
        next if !bttrainers[i]
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%03d]\r\n", i))
        btTrainersRequiredTypes.each_key do |key|
          schema = btTrainersRequiredTypes[key]
          record = bttrainers[i][schema[0]]
          next if record.nil?
          f.write(sprintf("%s = ", key))

          if Settings::ITEM_TRAINER_PBS_FILE_PARAM
            case key
            when "Type"
              f.write(record.to_s)
            when "PokemonNos"
              f.write(record.join(","))   # pbWriteCsvRecord somehow won't work here
            when "Items"
              f.write(record.join(","))   # pbWriteCsvRecord somehow won't work here
            else
              pbWriteCsvRecord(record, f, schema)
            end
          else
            case key
            when "Type"
              f.write(record.to_s)
            when "PokemonNos"
              f.write(record.join(","))   # pbWriteCsvRecord somehow won't work here
            else
              pbWriteCsvRecord(record, f, schema)
            end
          end
          f.write("\r\n")
        end
      end
    end
    Graphics.update
  end

end