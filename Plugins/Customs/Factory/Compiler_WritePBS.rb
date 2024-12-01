module Compiler
  module_function

  def write_battle_tower_trainers(bttrainers, filename)
    return if !bttrainers || !filename
    btTrainersRequiredTypes = {
      "Type"          => [0, "e", nil],   # Specifies a trainer
      "Name"          => [1, "s"],
      "BeginSpeech"   => [2, "s"],
      "EndSpeechWin"  => [3, "s"],
      "EndSpeechLose" => [4, "s"],
      "PokemonNos"    => [5, "*u"],
      "Items"         => [6, "*e", :Item],
    }
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
          f.write("\r\n")
        end
      end
    end
    Graphics.update
  end
end