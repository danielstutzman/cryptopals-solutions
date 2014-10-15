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
  block_minus_1 = 'A' * (block_size - known_so_far.size - 1) + known_so_far
  encrypted_to_plaintext = {}
  256.times do |i|
    plaintext = block_minus_1 + i.chr
    encrypted = encrypt(plaintext)[0...block_size]
    encrypted_to_plaintext[encrypted] = plaintext
  end
  short_block = 'A' * (block_size - known_so_far.size - 1)
  known_so_far + encrypted_to_plaintext[encrypt(short_block)[0...block_size]][-1]
end

known_so_far = ''
16.times do |i|
  puts known_so_far
  known_so_far = determine_next_byte(known_so_far, block_size)
end
