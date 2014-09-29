require '../reusable'
require 'base64'

KEEP_TOP_N_KEYSIZES = 1

puts 'Building character table...'
character_table = build_character_table()
puts 'Done.'

ciphertext = Base64.decode64(File.read('../challenge_data/6.txt'))
#ciphertext = encrypt_with_repeating_key_xor('This is a test to see if the decryption works on a short text.', 'ICE')

num_bits_table = calculate_num_bits_table()
if hamming_distance('this is a test', 'wokka wokka!!!', num_bits_table) != 37
  raise 'Broken hamming_distance'
end

key2score = {}
(2..40).each do |keysize|
  blocks = []
  4.times do |i|
    blocks.push ciphertext[(keysize * i)...(keysize * (i + 1))]
  end
  distances = []
  blocks.size.times do |i|
    blocks.size.times do |j|
      block1 = blocks[i]
      block2 = blocks[j]
      distance = hamming_distance(block1, block2, num_bits_table) / keysize.to_f
      distances.push distance
    end
  end
  sum_distance = distances.inject(:+)
  add_key_score_pair keysize, key2score, -sum_distance, KEEP_TOP_N_KEYSIZES
end
keysizes = key2score.sort_by { |key, score| score }.map { |key, score| key }

if break_into_blocks('ABCDEFG', 3) != ['ABC', 'DEF']
  raise 'Broken break_into_blocks'
end

if transpose_strings(['ABC', '123']) != ['A1', 'B2', 'C3']
  raise 'Broken transpose_strings'
end

keysizes.each do |keysize|
  puts "  Considering keysize #{keysize}..."
  blocks = break_into_blocks(ciphertext, keysize)[0...-1] # remove last
  transposed_blocks = transpose_strings(blocks)

  decrypted_blocks = []
  complete_key = ''
  transposed_blocks.each_with_index do |block, i|
    #puts "    Considering block ##{i}: " + binary2hex(block)
    key2score = {}
    256.times do |j|
      plaintext = fixed_xor(block, j.chr * block.size)
      score = score(plaintext, character_table)
      add_key_score_pair j, key2score, score, 1
    end
    key2score.sort_by { |key, score| score }.each do |key, score|
      decrypted_block = fixed_xor(block, key.chr * block.size)
      decrypted_blocks.push decrypted_block
      complete_key += key.chr
    end
  end
  puts "Keysize: #{keysize}"
  puts "Key: #{complete_key}"
  puts "Plaintext: #{transpose_strings(decrypted_blocks).join}"
end
