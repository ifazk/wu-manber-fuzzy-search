(lang dune 2.8)
(name wu-manber)

(generate_opam_files true)
(license CC0-1.0)
(authors "Ifaz Kabir")
(maintainers "Ifaz Kabir")
(source (github ifazk/wu-manber))
(documentation https://ifazk.github.io/wu-manber/)
(version unreleased)

(package
 (name wu-manber)
 (synopsis "Wu-Manber approximate string matching")
 (description
   "\| A Pure OCaml implementation of the Wu Manber approximate string matching
   "\| algorithm for short patterns.
 )
 (tags ("wu-manber" "baeza-yates-gonnet" "bitap" "algorithm" "levenshtein" "demarau-levenshtein" "edit" "distance" "approximate" "fuzzy" "string" "search" "matching"))
 (depends (ocaml (>= 4.10.0)) (optint (>= 0.1.0)) (ppx_inline_test :with-test)))
