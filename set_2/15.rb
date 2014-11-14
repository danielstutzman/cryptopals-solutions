require '../reusable'

begin
  unpad_with_pkcs7('not 16')
  raise "Should have raised"
rescue InvalidPadding
end

begin
  unpad_with_pkcs7('exactly-16------')
  raise "Should have raised"
rescue InvalidPadding
end

begin
  unpad_with_pkcs7('exactly-16------' + ("\x10" * 16))
rescue InvalidPadding
  raise "Shouldn't have raised"
end

begin
  unpadded = unpad_with_pkcs7("123456" + ("\x0a" * 10))
  raise "Wrong unpadded" if unpadded != '123456'
rescue InvalidPadding
  raise "Shouldn't have raised"
end

begin
  unpadded = unpad_with_pkcs7('0123456789abcdef123456' + ("\x0a" * 10))
  raise "Wrong unpadded" if unpadded != '0123456789abcdef123456'
rescue InvalidPadding
  raise "Shouldn't have raised"
end

puts "All tests passed"
