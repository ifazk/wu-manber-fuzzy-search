(** An module for fuzzy searching in strings *)

module Pattern = struct
  (** Module collecting operations for strings. *)

  type t = string

  type elem = char

  let length = Stdlib.String.length

  let elem_eq = Char.equal

  let fold_left f init s =
    let s = Bytes.unsafe_of_string s in
    let n = Bytes.length s in
    let rec loop acc i =
      if i = n then
        acc
      else
        let x = Bytes.unsafe_get s i in
        loop (f acc x) (i + 1)
    in
    loop init 0

  let fold_right f s init =
    let s = Bytes.unsafe_of_string s in
    let n = Bytes.length s in
    let rec loop acc i =
      if i = n then
        acc
      else
        let x = Bytes.unsafe_get s ((n - 1) - i) in
        loop (f x acc) (i + 1)
    in
    loop init 0

  let int_of_elem = int_of_char

  let elem_of_int = char_of_int

  let max_elem_index = 255
end

module ArrayMatcher = Matcher.MakeArrayMatcher (Pattern)

module FirstMatch = FirstMatch.Make (Pattern) (ArrayMatcher)

let search ~k ~pattern ~text =
  let seq = String.to_seq text in
  FirstMatch.first_match ~pattern ~k seq

let search_rightmost ~k ~pattern ~text =
  let seq = String.to_seq text in
  FirstMatch.first_rightmost_match ~pattern ~k seq

let report = FirstMatch.report
