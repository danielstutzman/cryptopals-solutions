require 'base64'

ciphertexts = File.read('../challenge_data/8.txt').split("\n")
ciphertexts.map! { |ciphertext| Base64.decode64(ciphertext) }
ciphertexts.each_with_index do |ciphertext, i|
  block2count = {}
  (ciphertext.size / 16).times do |j|
    block = ciphertext[(j * 16)...((j + 1) * 16)]
    block2count[block] ||= 0
    block2count[block] += 1
  end
  if block2count.reject { |block, count| count == 1 }.size > 0
    puts "Document #{i} has a repeated 16-byte sequence"
  end
end
