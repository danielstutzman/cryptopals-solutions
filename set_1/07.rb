require 'base64'
require 'openssl'

ciphertext = Base64.decode64(File.read('../challenge_data/7.txt'))

decipher = OpenSSL::Cipher::AES.new(128, :ECB)
decipher.decrypt
decipher.key = 'YELLOW SUBMARINE'

plain = decipher.update(ciphertext) + decipher.final
puts plain
