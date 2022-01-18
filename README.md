# wu-manber
An OCaml Implementation of the wu-manber fuzzy search algorithm using `Int63`
from the `optint` package as the underlying bitvectors.

The library can be used to search for a keyword/pattern in a body of text while
allowing for spelling errors. We use Levenshtein distances as the notion of
spelling errors, and the functions in the library take some error limit `k` and
searches for substrings in the text with Levenshtein distance less than `k` from
the pattern.

# Wu and Manber variants

I use the shift-or variant of the algorithm to save some bitwise operations.
This is also called the `bitap` algorithm, and the shift-or version was
originally introduced by Baeza-Yates and Gonnet.

Even for the shift-or version, I provide two variants of the algorithm.
1. The original version from Wu and Manber's technical report.
2. A right-leaning variant, where delete edits are skipped at the end of the
   pattern unless at the very end of text. This reports better edit distances is
   some circumstances.

The right-leaning variant is guaranteed to find a match if and only if the
original algorithm finds a match, and the error count reported by the variant is
guaranteed to be no worse than the original.
But the variant is a little harder to use since extra work is needed to check
for matches at the end of the text.

# Documentation
The documentation for the library can be found
[here](https://ifazk.github.io/wu-manber/).

# Examples

```ocaml
# #require "wu-manber";;
# open Wu_Manber;;
# StringSearch.(search ~k:2 ~pattern:"abcd" ~text:"abcd" |> report);;
- : string = "Pattern matched with 2 errors at character 2 of text"
# StringSearch.(search ~k:2 ~pattern:"abcd" ~text:"abd" |> report);;
- : string = "Pattern matched with 2 errors at character 2 of text"
# StringSearch.(search_right_leaning ~k:2 ~pattern:"abcd" ~text:"abcd" |> report);;
- : string = "Pattern matched with 0 errors at character 4 of text"
# StringSearch.(search_right_leaning ~k:2 ~pattern:"abcd" ~text:"abd" |> report);;
- : string = "Pattern matched with 1 errors at character 3 of text"
```

# Limits
The library only supports patterns of length 63. This is unlikely to be extended
any time soon.

# Runtime and Space Requirements
To search with an edit distance `k`, we need to track of an array of `Int63.t`
of size `k+1`. To process a character in the text, we usually need around `6`
bitwise operations for every element of the array.

The high-level apis also use some matcher objects, these store patterns, arrays,
or hashtables which require additional space.

# Reference
The shift-and version of the algorithm is described in S. Wu and U. Manber, Fast
Text Searching With Errors, tech. rep. TR 91-11, University of Arizona, 1991.

The shift-or version is described in the Wikipedia article for [Bitap
Algorithm](https://en.wikipedia.org/wiki/Bitap_algorithm).

# Related packages
[`agrep`](https://github.com/xavierleroy/ocamlagrep) implements the shift-and
version, but much of it is implmented in C.

There's also the main `agrep` unix tool tool itself by Manber and Wu.

# Future Work
PRs are welcome, as long as you are understand that you would be releasing your
code under CC0.

Here are extensions that I would like to have in the future.
- Add versions of the algorithm that mutate an array instead of creating new
  arrays all the time.
- Add specialized versions for exact matches and small error limits.
- Support multi-match and limited expressions.
- Full Regular Expressions Support.
- Support Demarau-Levenshtein distances.
- Support long patterns.

The limited expressions support should not be too difficult, but I haven't
thought about if the right-leaning variant has weird interactions with limited
expressions.
