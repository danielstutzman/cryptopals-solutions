package cryptopals

import (
  "testing"
  "github.com/stretchr/testify/assert"
)

func TestHexToBytes(t *testing.T) {
  bytes1, err := HexToBytes("40f5")
  assert.Equal(t, nil, err)
  assert.Equal(t, []byte("\x40\xf5"), bytes1)
}

func TestHexToBytesInvalidChar(t *testing.T) {
  _, err := HexToBytes("zz")
  assert.NotEqual(t, nil, err)
}

func TestHexToBytesInvalidLen(t *testing.T) {
  _, err := HexToBytes("123")
  assert.NotEqual(t, nil, err)
}

func TestBytesToBase64(t *testing.T) {
  assert.Equal(t, "c3VyZS4=", BytesToBase64([]byte("sure.")))
}

func TestHexToBase64(t *testing.T) {
  bytes1 := HexToBytesUnsafe("49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d")
  assert.Equal(t,
    "SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t",
    BytesToBase64(bytes1))
}
