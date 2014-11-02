class InvalidPadding < RuntimeError
end

def strip_pkcs7_padding(padded)
  if padded.size % 16 != 0
    raise InvalidPadding.new("padded size not multiple of 16")
  end
  if !padded.match(/\x04{0,15}$/)
    raise InvalidPadding.new("padded doesn't end with 0 to 15 \\x04's")
  end
  unpadded = padded.gsub(/\x04{0,15}$/, '')
  if unpadded.match(/\x04$/)
    raise InvalidPadding.new("More than 15 \\x04's")
  end
  unpadded
end

begin
  strip_pkcs7_padding('not 16')
  raise "Should have raised"
rescue InvalidPadding
end

begin
  strip_pkcs7_padding('exactly-16------')
rescue InvalidPadding
  raise "Shouldn't have raised"
end

begin
  unpadded = strip_pkcs7_padding("123456" + ("\x04" * 10))
  raise "Wrong unpadded" if unpadded != '123456'
rescue InvalidPadding
  raise "Shouldn't have raised"
end

begin
  unpadded = strip_pkcs7_padding('0123456789abcdef123456' + ("\x04" * 10))
  raise "Wrong unpadded" if unpadded != '0123456789abcdef123456'
rescue InvalidPadding
  raise "Shouldn't have raised"
end
