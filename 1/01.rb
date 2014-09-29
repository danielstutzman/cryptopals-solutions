require 'base64'

def hex2binary(hex)
  binary = ''
  (0...(hex.size / 2)).each do |i|
    offset = i * 2
    hex2 = hex[offset...(offset + 2)]
    binary += hex2.hex.chr
  end
  binary
end

binary = hex2binary('49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d')
base64 = Base64.encode64(binary).split("\n").join
puts base64
