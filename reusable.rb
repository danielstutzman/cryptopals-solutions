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

def binary2base64(binary)
  Base64.encode64(binary).split("\n").join
end

def binary2hex(binary)
  out = ''
  binary.size.times do |i|
    out += sprintf('%02x', binary[i].ord)
  end
  out
end

def fixed_xor(binary1, binary2)
  if binary1.size != binary2.size
    raise "Binary1 has size #{binary1.size}, "
      "but binary2 has size #{binary2.size}"
  end

  out = ''
  binary1.size.times do |i|
    out += (binary1[i].ord ^ binary2[i].ord).chr
  end
  out
end
