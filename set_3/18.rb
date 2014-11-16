require '../reusable'
require 'base64'

ENCRYPTED = Base64.decode64(
  'L77na/nrFsKvynd6HzOoG7GHTLXsTVu9qvY/2syLXzhPweyyMTJULu/6/kXX0KSvoOLSFQ==')

def to_64bit_little_endian(i)
  # for example: 1 becomes "\x01\x00\x00\x00\x00\x00\x00\x00"
  [i & ~(1 >> 32), i >> 32].pack('VV')
end

def generate_aes128_ctr_mode_keystream(key, nonce, num_bytes)
  raise "Key must be 16 bytes" unless key.size == 16 

  out = ''
  # round up to next 16 bytes
  ((num_bytes + 15) / 16).times do |i|
    # take only the first 16 bytes because the second 16 bytes are
    # encrypted \x10 * 16 (padding)
    out += encrypt_aes128_ecb(
      to_64bit_little_endian(nonce) + to_64bit_little_endian(i),
      key)[0...16]
  end
  out[0...num_bytes] # truncate to exact number of bytes needed
end

def decrypt_aes128_ctr(encrypted, key, nonce)
  keystream = generate_aes128_ctr_mode_keystream(key, nonce, encrypted.size)
  fixed_xor(encrypted, keystream)
end

def encrypt_aes128_ctr(plaintext, key, nonce)
  decrypt_aes128_ctr plaintext, key, nonce
end

puts decrypt_aes128_ctr(ENCRYPTED, 'YELLOW SUBMARINE', 0)
