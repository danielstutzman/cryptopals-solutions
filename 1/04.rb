require '../reusable'

MAX_NUM_PLAINTEXTS_TO_REMEMBER = 5

puts 'Building character table...'
character_table = build_character_table()
puts 'Done.'

hexes = File.read('../challenge_data/4.txt').split("\n")
binaries = hexes.map { |hex| hex2binary(hex) }

key2score = {}
binaries.size.times do |binary_num|
  puts "  Binary num #{binary_num}"
  encrypted = binaries[binary_num]

  256.times do |i|
    possible_key = i.chr * encrypted.size
    possible_plaintext = fixed_xor(encrypted, possible_key)
    score = score(possible_plaintext, character_table)
    min_score = key2score.values.min || -1
    if score > min_score
      while key2score.size >= MAX_NUM_PLAINTEXTS_TO_REMEMBER
        any_key_with_min_score = nil
        key2score.each do |plaintext, score|
          if score == min_score
            any_key_with_min_score = plaintext
            break
          end
        end
        if any_key_with_min_score
          key2score.delete any_key_with_min_score
        end
      end

      key = [binary_num, possible_key, possible_plaintext]
      key2score[key] = score
    end
  end
end

key2score.sort_by { |key, score| -score }.each do |key, score|
  puts sprintf('%s %d', key.inspect, score)
end
