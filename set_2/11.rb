require '../reusable'

def encryption_oracle(input, block_cipher_mode)
  num_bytes_before = rand(5) + 5
  num_bytes_after  = rand(5) + 5
  input = random_bytes(num_bytes_before) + input +
    random_bytes(num_bytes_after)
  key = random_bytes(16)
  case block_cipher_mode
    when 'ECB'
      encrypt_aes128_ecb(input, key)
    when 'CBC'
      iv = random_bytes(16)
      encrypt_aes128_cbc(input, key, iv)
    else raise "Unknown block_cipher_mode"
  end
end

def guess_ecb_or_cbc(encrypted)
  encrypted[16...32] == encrypted[32...48] ? 'ECB' : 'CBC'
end

10.times do
  block_cipher_mode = (rand(2) == 0) ? 'ECB' : 'CBC'
  guess = guess_ecb_or_cbc(encryption_oracle("\x00" * 48, block_cipher_mode))
  p [block_cipher_mode, guess, guess == block_cipher_mode]
end
