(** An module for fuzzy searching in strings *)

(** This module is intended to be used for searching as well as an example of
    properly using the mid-level functors in the [FirstMatch] module. *)

(** The search function in this module stop after the first match, and returns
    the error count together with the number of characters of the text read by
    the algorithm. *)

(** The following is a description of how to use the functions in
    {!Wu_Manber.FirstMatch}. *)

(** We first collect all the relevant operations of strings and characters in a
    module called [Pattern]. *)

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

(** Next we create a Matcher using one of the functors in the [Matcher]
    module.

{[
module ArrayMatcher = Matcher.MakeArrayMatcher (Pattern)
]}
*)

module ArrayMatcher = Matcher.MakeArrayMatcher (Pattern)

(** Next, we use the [FirstMatch.Make] functor to create functions that can
    search through sequences of characters.

{[
module FirstMatch = FirstMatch.Make (Pattern) (ArrayMatcher)
]}
*)

module FirstMatch = FirstMatch.Make (Pattern) (ArrayMatcher)

(** Lastly, to search through strings instead of sequences, we wrap the
    functions from the [FirstMatch] module.

{[
let search ~k ~pattern ~text =
  let seq = String.to_seq text in
  FirstMatch.first_match ~pattern ~k seq

let search_right_leaning ~k ~pattern ~text =
  let seq = String.to_seq text in
  FirstMatch.first_right_leaning_match ~pattern ~k seq

let report = FirstMatch.report
]}
*)

let search ~k ~pattern ~text =
  let seq = String.to_seq text in
  FirstMatch.first_match ~pattern ~k seq
(** [search ~k ~pattern ~text] searches for the first match in a string using
    the basic Wu and Manber algorithm, allowing for [~k] errors for a match.
    [~pattern] must have length less than or equal [63]. *)

let search_right_leaning ~k ~pattern ~text =
  let seq = String.to_seq text in
  FirstMatch.first_right_leaning_match ~pattern ~k seq
(** [search_right_leaning ~k ~pattern ~text] searches for the first match in a
    string using the right leaning variant of the Wu and Manber algorithm,
    allowing for [~k] errors for a match. [~pattern] must have length less than
    or equal [63]. *)

let report = FirstMatch.report
(** [report] produces a texual description of the results of the above
    functions. *)
