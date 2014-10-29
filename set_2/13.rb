require 'base64'
require '../reusable'

UNKNOWN_KEY = random_bytes(16)

def parse_get_params_string(string)
  hash = {}
  string.split('&').each do |between_ampersands|
    key, value = between_ampersands.split('=')
    hash[key] = value
  end
  hash
end

def encode_get_params(hash)
  hash.keys.map { |key| "#{key}=#{hash[key]}" }.join('&')
end

def profile_for(username)
  raise "Username can't contain & or =" if username.match(/[&=]/)
  hash = {
    email: username,
    uid:   10, # for simplicity, don't increment this
    role: 'user'
  }
  encode_get_params(hash)
end

def encrypted_profile_for(username)
  encrypt_aes128_ecb(profile_for(username), UNKNOWN_KEY)
end

def decrypt_and_parse_get_params_string(encrypted)
  parse_get_params_string(decrypt_aes128_ecb(encrypted, UNKNOWN_KEY))
end

def fudged_encrypted_profile_for(email)
  if email.size != 13
    raise "Attacker email must be size 13 so blocks line up"
  end

  # Goal: replace encrypted &role=user with encrypted &role=admin,
  #       even though we don't know the encryption key.
  # email=abcd@mail. com&uid=10&role= user444444444444
  # block1           block2           old block3
  encrypted1 = encrypted_profile_for(email)

  # email=zzzzzzzzzz admin44444444444 &uid=10&role=use r444444444444444
  #                  new block3
  injected_email = 'z' * (16 - 'email='.size) + pad_with_pkcs7('admin', 16)
  encrypted2 = encrypted_profile_for(injected_email)

  block1     = encrypted1[0...16]
  block2     = encrypted1[16...32]
  old_block3 = encrypted1[16...32]
  new_block3 = encrypted2[16...32]
  constructed = block1 + block2 + new_block3
  constructed
end

attacker_email = 'abcd@mail.com'
innocent  = encrypted_profile_for(attacker_email)
malicious = fudged_encrypted_profile_for(attacker_email)

p ['Innocent', decrypt_and_parse_get_params_string(innocent)]
p ['Malicious', decrypt_and_parse_get_params_string(malicious)]
