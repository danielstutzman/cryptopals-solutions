require '../reusable'

plaintext = "Burning 'em, if you ain't quick and nimble
I go crazy when I hear a cymbal"
key = 'ICE'
puts binary2hex(encrypt_with_repeating_key_xor(plaintext, key))
