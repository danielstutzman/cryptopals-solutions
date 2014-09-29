require '../reusable'

MAX_NUM_PLAINTEXTS_TO_REMEMBER = 5

encrypted = hex2binary('1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736')

puts 'Building character table...'
character_table = build_character_table()
puts 'Done.'

plaintext2score = {}
256.times do |i|
  possible_key = i.chr * encrypted.size
  possible_plaintext = fixed_xor(encrypted, possible_key)
  score = score(possible_plaintext, character_table)
  min_score = plaintext2score.values.min || -1
  if score > min_score
    while plaintext2score.size >= MAX_NUM_PLAINTEXTS_TO_REMEMBER
      any_plaintext_with_min_score = nil
      plaintext2score.each do |plaintext, score|
        if score == min_score
          any_plaintext_with_min_score = plaintext
          break
        end
      end
      if any_plaintext_with_min_score
        plaintext2score.delete any_plaintext_with_min_score
      end
    end
    plaintext2score[possible_plaintext] = score
  end
end

plaintext2score.sort_by { |plaintext, score| -score }.each do |plaintext, score|
  puts sprintf('%s %d', plaintext.inspect, score)
end
