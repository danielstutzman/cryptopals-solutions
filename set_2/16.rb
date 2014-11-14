require 'base64'
require '../reusable'

UNKNOWN_KEY = "\x65" * 16 #random_bytes(16)
UNKNOWN_IV  = "\x01" * 16 #random_bytes(16)

def encrypt(data)
  prefix = "comment1=cooking%20MCs;userdata="
  suffix = ";comment2=%20like%20a%20pound%20of%20bacon"
  plaintext = prefix + data.gsub(';', '%3B').gsub('=', '%3D') + suffix
  encrypt_aes128_cbc(pad_with_pkcs7(plaintext, 16), UNKNOWN_KEY, UNKNOWN_IV)
end

def decrypt(encrypted)
  padded = decrypt_aes128_cbc(encrypted, UNKNOWN_KEY, UNKNOWN_IV)
  plaintext = unpad_with_pkcs7(padded)
end

def decrypt_and_lookup_admin(encrypted)
  plaintext = decrypt(encrypted)
  pairs = plaintext.split(';').map { |part| part.split('=') }
  admin_value = (pairs.find { |pair| pair[0] == 'admin' } || [])[1]
  admin_value == 'true'
end

encrypted = encrypt('abcdefghijklmnop')
current_block3 = decrypt(encrypted)[32...48]
desired_block3 = ';admin=true;' + current_block3[12...16]
16.times do |i|
  8.times do |j|
    if current_block3[i].ord & (1 << j) !=
       desired_block3[i].ord & (1 << j)
      encrypted[16 + i] = (encrypted[16 + i].ord ^ (1 << j)).chr
    end
  end
end

p decrypt(encrypted)
p decrypt_and_lookup_admin(encrypted)
