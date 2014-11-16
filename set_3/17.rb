require '../reusable'
require 'base64'

#  plan: corrupt 1st block's last byte 256 ways:
#    the one that *doesn't* error out produced a \x01
#    and since I know correct XOR to make a \x01,
#    I know the actual decrypted bytes
#  next, corrupt 1st block's 2nd byte 256 ways
#                       AND last byte however I can get \x02

UNKNOWN_KEY = random_bytes(16)
KNOWN_IV    = random_bytes(16)

PLAINTEXTS = %w[
  MDAwMDAwTm93IHRoYXQgdGhlIHBhcnR5IGlzIGp1bXBpbmc=
  MDAwMDAxV2l0aCB0aGUgYmFzcyBraWNrZWQgaW4gYW5kIHRoZSBWZWdhJ3MgYXJlIHB1bXBpbic=
  MDAwMDAyUXVpY2sgdG8gdGhlIHBvaW50LCB0byB0aGUgcG9pbnQsIG5vIGZha2luZw==
  MDAwMDAzQ29va2luZyBNQydzIGxpa2UgYSBwb3VuZCBvZiBiYWNvbg==
  MDAwMDA0QnVybmluZyAnZW0sIGlmIHlvdSBhaW4ndCBxdWljayBhbmQgbmltYmxl
  MDAwMDA1SSBnbyBjcmF6eSB3aGVuIEkgaGVhciBhIGN5bWJhbA==
  MDAwMDA2QW5kIGEgaGlnaCBoYXQgd2l0aCBhIHNvdXBlZCB1cCB0ZW1wbw==
  MDAwMDA3SSdtIG9uIGEgcm9sbCwgaXQncyB0aW1lIHRvIGdvIHNvbG8=
  MDAwMDA4b2xsaW4nIGluIG15IGZpdmUgcG9pbnQgb2g=
  MDAwMDA5aXRoIG15IHJhZy10b3AgZG93biBzbyBteSBoYWlyIGNhbiBibG93
].map { |base64| Base64.decode64(base64) }

def encrypt(plaintext)
  encrypted = encrypt_aes128_cbc(plaintext, UNKNOWN_KEY, KNOWN_IV)
  [encrypted, KNOWN_IV]
end

def check_padding_is_valid(encrypted)
  begin
    decrypt_aes128_cbc(encrypted, UNKNOWN_KEY, KNOWN_IV)
    true
  rescue InvalidPadding
    false
  end
end

def hack_two_cbc_blocks(two_blocks)
  tampered = two_blocks.clone
  plaintext_reversed = ''
  1.upto(16) do |i|
    needed_padding_char = i.chr
    plaintext_reversed.size.times do |j|
      plaintext_char = plaintext_reversed[j]
      tampered[15 - j] = (two_blocks[15 - j].ord ^
        plaintext_char.ord ^ needed_padding_char.ord).chr
    end

    xor_to_make_valid = nil
    256.times do |j|
      tampered[16 - i] = (two_blocks[16 - i].ord ^ j).chr
      if check_padding_is_valid(tampered)
        xor_to_make_valid = j
      end
    end
    raise "couldn't get valid padding" if xor_to_make_valid.nil?

    plaintext_char = (xor_to_make_valid.ord ^ needed_padding_char.ord).chr
    plaintext_reversed += plaintext_char
  end
  plaintext_reversed.reverse
end

def hack_cbc_encryption(encrypted, iv)
  plaintext = ''
  (encrypted.size / 16).times do |block_num|
    if block_num == 0
      two_blocks = iv + encrypted[0...16]
    else
      two_blocks = encrypted[((block_num - 1) * 16)...((block_num + 1) * 16)]
    end
    plaintext += hack_two_cbc_blocks(two_blocks)
  end
  plaintext
end

plaintext = PLAINTEXTS[rand(PLAINTEXTS.size)]
encrypted, known_iv = encrypt(plaintext)
padded = hack_cbc_encryption(encrypted, known_iv)
puts unpad_with_pkcs7(padded)
