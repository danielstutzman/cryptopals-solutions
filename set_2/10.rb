require 'base64'
require 'openssl'
require '../reusable'

ciphertext = Base64.decode64(File.read('../challenge_data/10.txt'))

plaintext = "1 2 3 4 5 6 7 8 9 10 11 12 13 14 15"
ciphertext = encrypt_aes128_cbc(plaintext, 'YELLOW SUBMARINE', "\x00" * 16)

puts decrypt_aes128_cbc(ciphertext, 'YELLOW SUBMARINE', "\x00" * 16)
