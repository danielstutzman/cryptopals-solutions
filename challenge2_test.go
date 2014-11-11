package cryptopals

import (
  "testing"
  "github.com/stretchr/testify/assert"
)

func TestFixedXorWrongLen(t *testing.T) {
  _, err := FixedXor([]byte{1, 2, 3}, []byte{1, 2})
  assert.Equal(t, "len(input1) is 3 but len(input2) is 2", err.Error())
}

func TestFixedXor(t *testing.T) {
  input1 := HexToBytesUnsafe("1c0111001f010100061a024b53535009181c")
  input2 := HexToBytesUnsafe("686974207468652062756c6c277320657965")

  output, err := FixedXor(input1, input2)
  assert.Equal(t, nil, err)
  assert.Equal(t,
    HexToBytesUnsafe("746865206b696420646f6e277420706c6179"), output)
}
