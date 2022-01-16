# wu-manber
An OCaml Implementation of the wu-manber fuzzy search algorithm using `Int63`
from the `optint` package as the underlying bitvectors.

I use the shift-or variant of the algorithm to save some bitwise operations.
This is also called the `bitap` algorithm, and the shift-or version was
originally introduced by Baeza-Yates and Gonnet.

I provide two variants of the algorithm.
1. The original version from Wu and Manber's technical report.
2. A rightmost match variant, where delete edits are skipped at the end of the
   pattern unless at the very end of text. This reports better edit distances.

# Documentation
The documentation for the library can be found
[here](https://ifazk.github.io/wu-manber/).

# Future Work
PRs are welcome, as long as you are understand that you would be releasing your
code under CC0.

Here are extensions that I would like to have in the future.
- Add versions of the algorithm that mutates an array instead of creating new
  arrays all the time.
- Add specialized versions for exact matches and small error limits.
- Supparting multi-match and limited expressions.
- Full Regular Expressions Support.
- Support Demarau Levenshtein distances.

The limited expressions support should not be too difficult, but I haven't
thought about if the rightmost match variant has weird interactions with limited
expressions.
I don't currently have a strong enough understanding the full regular
expressions part of Wu and Manber's report.
