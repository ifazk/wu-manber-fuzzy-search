open Utils
module I = Int63

module BitOps = struct
  let shift_or ~mismatch x : I.t =
    I.lshift1 x
    |> I.logor mismatch

  let initial_bv ~k : I.t array =
    let arr = Array.make (k+1) I.minus_one in
    for i = 1 to k do
      arr.(i) <- I.lshift1 arr.(i-1)
    done;
    arr

  let match_error ~pattern_length (bvs : I.t array) : int option =
    let idx = pattern_length - 1 in
    Array.find_index_opt (I.bit_is_zero ~n:idx) bvs

  let is_match ~pattern_length (bvs : I.t array) : bool =
    match_error ~pattern_length bvs
    |> Option.is_some
end

module MakeWuManber (P : Patterns.Pattern) = struct
  open BitOps
  let next_bvs ~mismatch (input : I.t array) : I.t array =
    (* Self Transitions, i.e. R2/D2/S2 *)
    let len = Array.length input in
    let output = Array.map (shift_or ~mismatch) input in
    (* inserts, shifts, deletes *)
    for i = 1 to (len - 1) do
      output.(i) <-
        let rjd1 = input.(i-1) in
        let rj1d1 = output.(i-1) in
        let open I.Infix in
        (* self-trans & shift (substitution and delete) & insert *)
        output.(i) && (I.lshift1 (rjd1 && rj1d1)) && rjd1
    done;
    output

  let next_bvs_leftmost ~pattern_length ~mismatch (input : I.t array) : I.t array =
    (* Self Transitions, i.e. R2/D2/S2 *)
    let len = Array.length input in
    let output = Array.map (shift_or ~mismatch) input in
    (* inserts, shifts, deletes *)
    for i = 1 to (len - 1) do
      output.(i) <-
        let rjd1 = input.(i-1) in
        let rj1d1 = output.(i-1) in
        let end_delete_bv =
          let max_end_deletes = len - i in
          let end_deletes = max max_end_deletes pattern_length in
          I.shift_left I.minus_one (pattern_length - end_deletes)
        in
        let open I.Infix in
        (* self-trans & shift (substitution and delete) & insert *)
        output.(i) && (I.lshift1 (rjd1 && (rj1d1 || end_delete_bv))) && rjd1
    done;
    output

  let feed_sentinel ~pattern_length (input : I.t array) : I.t array =
    next_bvs_leftmost ~pattern_length ~mismatch:(I.minus_one) input
end
