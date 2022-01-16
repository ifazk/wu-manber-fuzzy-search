Simplest tests
  $ string_tests 2 "abcd" "abcd"
  k=2, p="abcd", t="abcd"
  Pattern matched with 2 errors at character 2 of text
  Pattern matched with 0 errors at character 4 of text

  $ string_tests 2 "abcd" "ab"
  k=2, p="abcd", t="ab"
  Pattern matched with 2 errors at character 2 of text
  Pattern matched with 2 errors at character 2 of text

  $ string_tests 2 "bbaa" "aa"
  k=2, p="bbaa", t="aa"
  Pattern matched with 2 errors at character 2 of text
  Pattern matched with 2 errors at character 2 of text

  $ string_tests 2 "bbaa" "baa"
  k=2, p="bbaa", t="baa"
  Pattern matched with 2 errors at character 2 of text
  Pattern matched with 1 errors at character 3 of text

  $ string_tests 2 "bbaa" "bb"
  k=2, p="bbaa", t="bb"
  Pattern matched with 2 errors at character 2 of text
  Pattern matched with 2 errors at character 2 of text

  $ string_tests 2 "bbaa" "ba"
  k=2, p="bbaa", t="ba"
  Pattern matched with 2 errors at character 2 of text
  Pattern matched with 2 errors at character 2 of text
