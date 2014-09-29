require '../reusable'

input1 = hex2binary('1c0111001f010100061a024b53535009181c')
input2 = hex2binary('686974207468652062756c6c277320657965')
p binary2hex(fixed_xor(input1, input2))
