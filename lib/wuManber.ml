(** This module contains the main parts of the shift-or variants of the Wu and
    Manber algorithm. *)

open Utils
module I = Int63

module BitOps = struct
  (** A collection of bitwise operations used in the Wu and Manber algorithm. *)

  let shift_or ~mismatch x : I.t =
    I.lshift1 x
    |> I.logor mismatch

  let match_error ~pattern_length (bvs : I.t array) : int option =
    let idx = pattern_length - 1 in
    Array.find_index_opt (I.bit_is_zero ~n:idx) bvs

  let is_match ~pattern_length (bvs : I.t array) : bool =
    match_error ~pattern_length bvs
    |> Option.is_some
end

module WuManber = struct
  open BitOps
  let initial_bvs ~k : I.t array =
    let arr = Array.make (k+1) I.minus_one in
    for i = 1 to k do
      arr.(i) <- I.lshift1 arr.(i-1)
    done;
    arr

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
end

module RightLeaningWuManber = struct
  let initial_bvs ~k : I.t array =
    Array.make (k+1) I.minus_one

  let next_bvs ~mismatch (input : I.t array) : I.t array =
    (* Self Transitions, i.e. R2/D2/S2 *)
    let len = Array.length input in
    let output = Array.map I.lshift1 input in
    (* inserts, shifts, deletes *)
    let rec loop i del_mask =
      if (i = len) then
        output
      else
        let rjd1 = input.(i-1) in
        let shifted = output.(i) in
        let del_and_shifted =
          let open I.Infix in
          (shifted && del_mask)
        in
        let del_mask = I.lshift1 @@ del_and_shifted in
        let new_output_i =
          let open I.Infix in
          (* self-trans && delete & shift (substitution) & insert *)
          (del_and_shifted || mismatch) && (I.lshift1 rjd1) && rjd1
        in
        let () = output.(i) <- new_output_i in
        loop (i + 1) del_mask
    in
    (* delmask is the collection of all the delete epsilon transitions from the
       input. *)
    (* Do index 0 manually *)
    let del_mask = I.lshift1 output.(0) in
    let () = output.(0) <- I.logor output.(0) mismatch in
    loop 1 del_mask

  let feed_sentinel (input : I.t array) : I.t array =
    next_bvs ~mismatch:(I.minus_one) input
end
