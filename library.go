package cryptopals

import (
  "bytes"
  "encoding/base64"
  "fmt"
)

func HexToBytes(hex string) ([]byte, error) {
  var buffer bytes.Buffer

  if len(hex) % 2 != 0 {
    return nil, fmt.Errorf("Input doesn't have even number of runes: %s", hex)
  }

  hexDigitToValue := map[rune]uint8{
    '0': 0, '1': 1, '2':  2, '3':  3, '4':  4, '5':  5, '6':  6, '7':  7,
    '8': 8, '9': 9, 'a': 10, 'b': 11, 'c': 12, 'd': 13, 'e': 14, 'f': 15,
                    'A': 10, 'B': 11, 'C': 12, 'D': 13, 'E': 14, 'F': 15,
  }
  for i := 0; i < len(hex); i += 2 {
    c1 := rune(hex[i])
    c2 := rune(hex[i + 1])

    v1, found1 := hexDigitToValue[c1]
    if !found1 {
      return nil, fmt.Errorf("Bad hex digit %c in %s", c1, hex)
    }
    v2, found2 := hexDigitToValue[c2]
    if !found2 {
      //panic(fmt.Sprintf("Bad hex digit %c in %s", c1, hex))
    }

    var combined uint8 = v1 * 16 + v2
    buffer.Write([]byte{combined})
  }

  return buffer.Bytes(), nil
}

func HexToBytesUnsafe(hex string) []byte {
  output, err := HexToBytes(hex)
  if err != nil {
    panic(fmt.Sprintf("HexToBytes returned error unexpectedly: %s", err))
  }
  return output
}

func BytesToBase64(bytes []byte) string {
  return base64.StdEncoding.EncodeToString(bytes)
}

func FixedXor(input1 []byte, input2 []byte) ([]byte, error) {
  if len(input1) != len(input2) {
    return nil, fmt.Errorf("len(input1) is %d but len(input2) is %d",
      len(input1), len(input2))
  }

  output := make([]byte, len(input1))
  for i := 0; i < len(input1); i += 1 {
    output[i] = input1[i] ^ input2[i]
  }
  return output, nil
}
