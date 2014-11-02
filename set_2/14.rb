require 'base64'
require '../reusable'

UNKNOWN_KEY    = random_bytes(16)
UNKNOWN_PREFIX = random_bytes(rand(80))
TARGET_BYTES   = Base64.decode64(
  'Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkg
  aGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBq
  dXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUg
  YnkK')

def encrypt(my_string)
  encrypt_aes128_ecb(UNKNOWN_PREFIX +
    my_string.force_encoding('ASCII-8BIT') + TARGET_BYTES, UNKNOWN_KEY)
end

def guess_ecb_or_cbc()
  encrypted1 = encrypt("\x00" * 48)
  encrypted2 = encrypt("\xFF" * 48)
  i = 0
  while i < encrypted1.size
    break if encrypted1[i] != encrypted2[i]
    i += 1
  end
  encrypted1[(i + 16)...(i + 32)] == encrypted1[(i + 32)...(i + 48)] ?
    'ECB' : 'CBC'
end

block_size = 16 # assume this

raise 'Detected CBC' if guess_ecb_or_cbc() != 'ECB'

def determine_num_mystery_prefix_chars()
  i = 1
  while i <= 16
    encrypted1 = encrypt("\x00" * i)
    encrypted2 = encrypt("\xFF" * i)
    j = 0
    while j < encrypted1.size
      break if encrypted1[j] != encrypted2[j]
      j += 1
    end
    break if encrypted1[j + 16] != encrypted2[j + 16]
    i += 1
  end
  j + (16 - i) + 1
end

def determine_next_byte(num_mystery_prefix_chars, known_so_far, block_size)
  # 0 -> 0, 1..15 -> 15..1, 16 -> 0, 17..31 -> 15..1, etc.
  prefix_padding = 16 - (num_mystery_prefix_chars % 16)
  prefix_padding = 0 if prefix_padding == 16

  prefix = '-' * (
    prefix_padding + (block_size - 1) - (known_so_far.size % block_size))
  which_block = ((num_mystery_prefix_chars + 15) / 16) + # round up
    (known_so_far.size / block_size)
  range = (which_block * block_size)...((which_block + 1) * block_size)
  goal_encrypted_block = encrypt(prefix)[range]
  synthesized_encrypted_block_to_last_char = {}
  256.times do |i|
    synthesized_encrypted_block =
      encrypt(prefix + known_so_far + i.chr)[range]
    synthesized_encrypted_block_to_last_char[synthesized_encrypted_block] =
      i.chr
  end
  synthesized_encrypted_block_to_last_char[goal_encrypted_block]
end

num_mystery_prefix_chars = determine_num_mystery_prefix_chars()

known_so_far = ''
loop do
  next_byte = determine_next_byte(
    num_mystery_prefix_chars, known_so_far, block_size)
  break if next_byte.nil?
  known_so_far += next_byte
  puts known_so_far
end
