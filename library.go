package cryptopals

import (
  "bytes"
  "encoding/base64"
//  "fmt"
)

func HexToBase64(hex string) string {
  var base64Out bytes.Buffer
  base64Encoder := base64.NewEncoder(base64.StdEncoding, &base64Out)

  hexDigitToValue := map[rune]int{
    '0': 0, '1': 1, '2':  2, '3':  3, '4':  4, '5':  5, '6':  6, '7':  7,
    '8': 8, '9': 9, 'a': 10, 'b': 11, 'c': 12, 'd': 13, 'e': 14, 'f': 15,
  }
  for i := 0; i < len(hex); i += 2 {
    c1 := rune(hex[i])
    c2 := rune(hex[i + 1])
    combined := hexDigitToValue[c1] * 16 + hexDigitToValue[c2]
    base64Encoder.Write([]byte(string(combined)))
  }
  base64Encoder.Close()

  return base64Out.String()
}
