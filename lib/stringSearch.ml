module Pattern = struct
  type t = string

  type elem = char

  let length = Stdlib.String.length

  let elem_eq = Char.equal

  let fold_left = Stdlib.String.fold_left

  let fold_right = Stdlib.String.fold_right

  let int_of_elem = int_of_char

  let elem_of_int = char_of_int

  let max_elem_index = 255
end

module ArrayMatcher = Matcher.MakeArrayMatcher (Pattern)

include FirstMatch.Make (Pattern) (ArrayMatcher)

let search ~k ~pattern ~text =
  let seq = String.to_seq text in
  first_match ~pattern ~k seq


let search_leftmost ~k ~pattern ~text =
  let seq = String.to_seq text in
  first_leftmost_match ~pattern ~k seq
