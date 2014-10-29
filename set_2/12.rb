require 'base64'
require '../reusable'

UNKNOWN_STRING = Base64.decode64(
  'Um9sbGluJyBpbiBteSA1LjAKV2l0aCBteSByYWctdG9wIGRvd24gc28gbXkg
aGFpciBjYW4gYmxvdwpUaGUgZ2lybGllcyBvbiBzdGFuZGJ5IHdhdmluZyBq
dXN0IHRvIHNheSBoaQpEaWQgeW91IHN0b3A/IE5vLCBJIGp1c3QgZHJvdmUg
YnkK')
UNKNOWN_KEY = random_bytes(16)

def encrypt(my_string)
  encrypt_aes128_ecb(my_string + UNKNOWN_STRING, UNKNOWN_KEY)
end

# Determine block size
def determine_block_size
  last_result = ''
  (1..50).each do |i|
    result = binary2hex(encrypt('A' * i))[0...80]
    if result[0...i] == last_result[0...i]
      return i - 1
    end
  
    last_result = result
  end
end

def guess_ecb_or_cbc()
  encrypted = encrypt("\x00" * 48)
  encrypted[16...32] == encrypted[32...48] ? 'ECB' : 'CBC'
end

block_size = determine_block_size()

raise if guess_ecb_or_cbc() != 'ECB'

def determine_next_byte(known_so_far, block_size)
  prefix = '-' * ((block_size - 1) - (known_so_far.size % block_size))
  which_block = known_so_far.size / block_size
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

known_so_far = ''
loop do
  next_byte = determine_next_byte(known_so_far, block_size)
  break if next_byte.nil?
  known_so_far += next_byte
  puts known_so_far
end

# If block_size were 4 and plaintext were DoubleRain, try cracking:
#   0 ---*
#   1 --D*
#   2 -Do*
#   3 Dou*
#   4 ---D oub*
#   5 --Do ubl*
#   6 -Dou ble*
#   7 Doub leR*
#   8 ---D oubl eRa*
#   9 --Do uble Rai*
#  10 -Dou bleR ain* -> no match
