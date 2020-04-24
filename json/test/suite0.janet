(import build/json :as json)

(defn check-object [x]
  (def y (json/decode (json/encode x)))
  (def y1 (json/decode (json/encode x " " "\n")))
  (if (deep-not= x y) (error (string/format "failed roundtrip 1: %p" x)))
  (if (deep-not= x y1) (error (string/format "failed roundtrip 2: %p" x))))

(check-object 1)
(check-object 100)
(check-object true)
(check-object false)
(check-object (range 1000))
(check-object @{"two" 2 "four" 4 "six" 6})
(check-object @{"hello" "world"})
(check-object @{"john" 1 "billy" "joe" "a" @[1 2 3 4 -1000]})
(check-object @{"john" 1 "∀abcd" "joe" "a" @[1 2 3 4 -1000]})
(check-object
 "ᚠᛇᚻ᛫ᛒᛦᚦ᛫ᚠᚱᚩᚠᚢᚱ᛫ᚠᛁᚱᚪ᛫ᚷᛖᚻᚹᛦᛚᚳᚢᛗ
ᛋᚳᛖᚪᛚ᛫ᚦᛖᚪᚻ᛫ᛗᚪᚾᚾᚪ᛫ᚷᛖᚻᚹᛦᛚᚳ᛫ᛗᛁᚳᛚᚢᚾ᛫ᚻᛦᛏ᛫ᛞᚫᛚᚪᚾ
ᚷᛁᚠ᛫ᚻᛖ᛫ᚹᛁᛚᛖ᛫ᚠᚩᚱ᛫ᛞᚱᛁᚻᛏᚾᛖ᛫ᛞᚩᛗᛖᛋ᛫ᚻᛚᛇᛏᚪᚾ᛬")
(check-object @["šč"])

# Decoding utf-8 strings 
(if (deep-not= "šč" (json/decode `"šč"`)) "did not decode utf-8 string correctly")
