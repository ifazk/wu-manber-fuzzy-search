(lang dune 2.8)
(name wu-manber-fuzzy-search)

(cram enable)

(generate_opam_files true)
(license CC0-1.0)
(authors "Ifaz Kabir")
(maintainers "Ifaz Kabir")
(source (github ifazk/wu-manber-fuzzy-search))
(documentation https://ifazk.github.io/wu-manber-fuzzy-search/)
(version 0.1.0)

(package
 (name wu-manber-fuzzy-search)
 (synopsis "Wu-Manber approximate string matching / fuzzy search")
 (description
   "\| A Pure OCaml implementation of the Wu Manber approximate string matching
   "\| algorithm for short patterns.
 )
 (tags ("wu-manber" "baeza-yates-gonnet" "bitap" "algorithm" "levenshtein" "demarau-levenshtein" "edit" "distance" "approximate" "fuzzy" "string" "search" "matching"))
 (depends (ocaml (>= 4.10.0)) (optint (>= 0.1.0)) (pp-binary-ints (and (>= 1.0.0) :with-test))))
