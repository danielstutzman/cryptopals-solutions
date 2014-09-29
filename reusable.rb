require 'base64'

def hex2binary(hex)
  binary = ''
  (0...(hex.size / 2)).each do |i|
    offset = i * 2
    hex2 = hex[offset...(offset + 2)]
    binary += hex2.hex.chr
  end
  binary
end

def binary2base64(binary)
  Base64.encode64(binary).split("\n").join
end

def binary2hex(binary)
  out = ''
  binary.size.times do |i|
    out += sprintf('%02x', binary[i].ord)
  end
  out
end

def fixed_xor(binary1, binary2)
  if binary1.size != binary2.size
    raise "Binary1 has size #{binary1.size}, " +
      "but binary2 has size #{binary2.size}"
  end

  out = ''
  binary1.size.times do |i|
    out += (binary1[i].ord ^ binary2[i].ord).chr
  end
  out
end

def build_character_table
  character2count = {}
  Dir.glob('../glowbe_corpus_sample/*au*.txt') do |path|
    puts '  ' + path
    contents = File.read(path)
    contents.size.times do |i|
      character2count[contents[i]] ||= 0
      character2count[contents[i]] += 1
    end
  end

  character2score = {}
  character2count.each do |character, count|
    character2score[character] = Math.log(count)
  end
  character2score
end

def score(possible_plaintext, character_table)
  score = 0
  possible_plaintext.size.times do |i|
    score += character_table[possible_plaintext[i]] || -3
  end
  score
end

def encrypt_with_repeating_key_xor(plaintext, key)
  out = ''
  plaintext.size.times do |i|
    out += (plaintext[i].ord ^ key[i % key.size].ord).chr
  end
  out
end

def calculate_num_bits_table
  table = {}
  256.times do |i|
    num_bits = 0
    8.times do |j|
      mask = 1 << j
       if i & mask != 0
         num_bits += 1
       end
    end
    table[i] = num_bits
  end
  table
end

def hamming_distance(binary1, binary2, num_bits_table)
  if binary1.size != binary2.size
    raise "Binary1 has size #{binary1.size}, " +
      "but binary2 has size #{binary2.size}"
  end
  distance = 0
  binary1.size.times do |i|
    difference = binary1[i].ord ^ binary2[i].ord
    distance += num_bits_table[difference]
  end
  distance
end

def add_key_score_pair(key, key2score, score, max_num_pairs_to_keep)
  min_score = key2score.values.min
  if key2score.size < max_num_pairs_to_keep || score > min_score
    if key2score.size >= max_num_pairs_to_keep
      any_key_with_min_score = nil
      key2score.each do |key, score|
        if score == min_score
          any_key_with_min_score = key
          break
        end
      end
      if any_key_with_min_score
        key2score.delete any_key_with_min_score
      end
    end

    key2score[key] = score
  end
end

def break_into_blocks(input, blocksize)
  blocks = []
  (input.size / blocksize).times do |i|
    offset = i * blocksize
    blocks.push input[offset...(offset + blocksize)]
  end
  blocks
end

def transpose_strings(strings)
  out = []
  #p strings
  strings.size.times do |i|
    string = strings[i]
    #p [i, string]
    string.size.times do |j|
      out[j] ||= ''
      #p [j, binary2hex(string[j])]
      out[j] += string[j]
    end
  end
  out
end
