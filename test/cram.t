Simplest tests
  $ string_tests 2 "abcd" "abcd"
  k=2, p="abcd", t="abcd"
  Pattern matched with 2 errors at character 2 of text
  Pattern matched with 0 errors at character 4 of text

  $ string_tests 2 "abcd" "ab"
  k=2, p="abcd", t="ab"
  Pattern matched with 2 errors at character 2 of text
  Pattern matched with 2 errors at character 2 of text

  $ string_tests 2 "abcd" "abd"
  k=2, p="abcd", t="abd"
  Pattern matched with 2 errors at character 2 of text
  Pattern matched with 1 errors at character 3 of text

  $ string_tests 2 "bbaa" "aa"
  k=2, p="bbaa", t="aa"
  Pattern matched with 2 errors at character 2 of text
  Pattern matched with 2 errors at character 2 of text

  $ string_tests 2 "bbaa" "baa"
  k=2, p="bbaa", t="baa"
  Pattern matched with 2 errors at character 2 of text
  Pattern matched with 2 errors at character 2 of text

  $ string_tests 2 "bbaa" "bb"
  k=2, p="bbaa", t="bb"
  Pattern matched with 2 errors at character 2 of text
  Pattern matched with 2 errors at character 2 of text

  $ string_tests 2 "bbaa" "ba"
  k=2, p="bbaa", t="ba"
  Pattern matched with 2 errors at character 2 of text
  Pattern matched with 2 errors at character 2 of text

  $ string_tests 2 "abcd" "aeb"
  k=2, p="abcd", t="aeb"
  Could not find pattern in text
  Could not find pattern in text

  $ string_tests 2 "abcd" "aebd"
  k=2, p="abcd", t="aebd"
  Pattern matched with 2 errors at character 4 of text
  Pattern matched with 2 errors at character 4 of text

  $ string_tests 3 "abcd" "aebd"
  k=3, p="abcd", t="aebd"
  Pattern matched with 3 errors at character 1 of text
  Pattern matched with 2 errors at character 4 of text

Start with deletes

  $ string_tests 4 "abcdefgh" "efgh"
  k=4, p="abcdefgh", t="efgh"
  Pattern matched with 4 errors at character 4 of text
  Pattern matched with 4 errors at character 4 of text

Start with subs

  $ string_tests 4 "abcdefgh" "iiiiefgh"
  k=4, p="abcdefgh", t="iiiiefgh"
  Pattern matched with 4 errors at character 8 of text
  Pattern matched with 4 errors at character 8 of text

Start with inserts

  $ string_tests 4 "abcdefgh" "iiiiabcdefgh"
  k=4, p="abcdefgh", t="iiiiabcdefgh"
  Pattern matched with 4 errors at character 8 of text
  Pattern matched with 0 errors at character 12 of text

Large tests
  $ string_tests 2 "123456789012345678901234567890123456789012345678901234567890123" "123456789012345678901234567890123456789012345678901234567890123"
  k=2, p="123456789012345678901234567890123456789012345678901234567890123", t="123456789012345678901234567890123456789012345678901234567890123"
  Pattern matched with 2 errors at character 61 of text
  Pattern matched with 0 errors at character 63 of text

  $ string_tests 2 "123456789012345678901234567890123456789012345678901234567890123" "1234567890123456789012345678901234567890123456789012345678901"
  k=2, p="123456789012345678901234567890123456789012345678901234567890123", t="1234567890123456789012345678901234567890123456789012345678901"
  Pattern matched with 2 errors at character 61 of text
  Pattern matched with 2 errors at character 61 of text

  $ string_tests 2 "123456789012345678901234567890123456789012345678901234567890123" "12345678901234567890123456789012345678901234567890123456789abcd"
  k=2, p="123456789012345678901234567890123456789012345678901234567890123", t="12345678901234567890123456789012345678901234567890123456789abcd"
  Could not find pattern in text
  Could not find pattern in text

  $ string_tests 2 "123456789012345678901234567890123456789012345678901234567890123" "12345678901234567890123456789012345678901234567890123456789abc"
  k=2, p="123456789012345678901234567890123456789012345678901234567890123", t="12345678901234567890123456789012345678901234567890123456789abc"
  Could not find pattern in text
  Could not find pattern in text

  $ string_tests 2 "123456789012345678901234567890123456789012345678901234567890123" "123456789012345678901234567890123456789012345678901234567890a"
  k=2, p="123456789012345678901234567890123456789012345678901234567890123", t="123456789012345678901234567890123456789012345678901234567890a"
  Could not find pattern in text
  Could not find pattern in text

  $ string_tests 2 "123456789012345678901234567890123456789012345678901234567890123" "1234567890123456789012345678901234567890123456789012345678901a"
  k=2, p="123456789012345678901234567890123456789012345678901234567890123", t="1234567890123456789012345678901234567890123456789012345678901a"
  Pattern matched with 2 errors at character 61 of text
  Pattern matched with 2 errors at character 62 of text

  $ string_tests 2 "123456789012345678901234567890123456789012345678901234567890123" "12345678901234567890123456789012345678901234567890123456789012a"
  k=2, p="123456789012345678901234567890123456789012345678901234567890123", t="12345678901234567890123456789012345678901234567890123456789012a"
  Pattern matched with 2 errors at character 61 of text
  Pattern matched with 1 errors at character 63 of text

  $ string_tests 4 "123456789012345678901234567890123456789012345678901234567890123" "12345678901234567890123456789012345678901234567890123456789012a"
  k=4, p="123456789012345678901234567890123456789012345678901234567890123", t="12345678901234567890123456789012345678901234567890123456789012a"
  Pattern matched with 4 errors at character 59 of text
  Pattern matched with 1 errors at character 63 of text

# Large begin text tests
## Subs
  $ string_tests 4 "123456789012345678901234567890123456789012345678901234567890123" "abcd56789012345678901234567890123456789012345678901234567890123"
  k=4, p="123456789012345678901234567890123456789012345678901234567890123", t="abcd56789012345678901234567890123456789012345678901234567890123"
  Pattern matched with 4 errors at character 63 of text
  Pattern matched with 4 errors at character 63 of text

## Inserts
  $ string_tests 4 "123456789012345678901234567890123456789012345678901234567890123" "abcd123456789012345678901234567890123456789012345678901234567890123"
  k=4, p="123456789012345678901234567890123456789012345678901234567890123", t="abcd123456789012345678901234567890123456789012345678901234567890123"
  Pattern matched with 4 errors at character 63 of text
  Pattern matched with 0 errors at character 67 of text

## Delete
  $ string_tests 4 "123456789012345678901234567890123456789012345678901234567890123" "56789012345678901234567890123456789012345678901234567890123"
  k=4, p="123456789012345678901234567890123456789012345678901234567890123", t="56789012345678901234567890123456789012345678901234567890123"
  Pattern matched with 4 errors at character 59 of text
  Pattern matched with 4 errors at character 59 of text

# Small middle tests
## Inserts
  $ string_tests 3 "abcd" "aibicid"
  k=3, p="abcd", t="aibicid"
  Pattern matched with 3 errors at character 1 of text
  Pattern matched with 3 errors at character 4 of text

  $ string_tests 3 "abcde" "aibicide"
  k=3, p="abcde", t="aibicide"
  Pattern matched with 3 errors at character 8 of text
  Pattern matched with 3 errors at character 8 of text

  $ string_tests 3 "abcdef" "aibicidef"
  k=3, p="abcdef", t="aibicidef"
  Pattern matched with 3 errors at character 9 of text
  Pattern matched with 3 errors at character 9 of text

## Subs
  $ string_tests 3 "abcde" "afffe"
  k=3, p="abcde", t="afffe"
  Pattern matched with 3 errors at character 5 of text
  Pattern matched with 3 errors at character 5 of text

  $ string_tests 3 "abcdef" "agcgef"
  k=3, p="abcdef", t="agcgef"
  Pattern matched with 3 errors at character 5 of text
  Pattern matched with 2 errors at character 6 of text

  $ string_tests 3 "abcdefg" "ascsesg"
  k=3, p="abcdefg", t="ascsesg"
  Pattern matched with 3 errors at character 7 of text
  Pattern matched with 3 errors at character 7 of text

  $ string_tests 3 "abcdefgh" "ascsesgh"
  k=3, p="abcdefgh", t="ascsesgh"
  Pattern matched with 3 errors at character 8 of text
  Pattern matched with 3 errors at character 8 of text

  $ string_tests 3 "_abcdefgh" "_ascsesgh"
  k=3, p="_abcdefgh", t="_ascsesgh"
  Pattern matched with 3 errors at character 9 of text
  Pattern matched with 3 errors at character 9 of text

  $ string_tests 3 "_abcdeeefgh" "_ascseeesgh"
  k=3, p="_abcdeeefgh", t="_ascseeesgh"
  Pattern matched with 3 errors at character 11 of text
  Pattern matched with 3 errors at character 11 of text
