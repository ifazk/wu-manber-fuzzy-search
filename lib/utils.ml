(** Internal Utility Module *)

module Int63 = struct
  include Optint.Int63
  let lshift1 x = shift_left x 1

  let bit_is_zero ~n x : bool =
    let mask = shift_left one n in
    let la = logand mask x in
    equal la zero

  let get ~n x : bool =
    not @@ bit_is_zero ~n x
end

module Array = struct
  include Stdlib.Array
  let find_index_opt p a =
    let n = Array.length a in
    let rec loop i =
      if i = n then None
      else
        let x = Array.unsafe_get a i in
        if p x then Some i
        else loop (succ i)
    in
    loop 0
end
