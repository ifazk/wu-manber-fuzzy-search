(** This module contains the Wu and Manber algorithm, sepecialized for
    implementation in hot loop. *)

open Utils
module I = Int63

module WM = WuManber

module BitOps = struct

  include WuManber.BitOps

  let[@inline] get_check_mask ~pattern_length : I.t =
    I.(shift_left one pattern_length)

  let[@inline] match_check ~check_mask x : bool =
    I.equal (I.logand check_mask x) I.zero
end

module WuManber = struct
  let[@inline] transition0 ~mismatch ~input0 : I.t =
    I.shift_or ~mismatch input0

  let[@inline] transition1 ~mismatch ~input0 ~input1 ~output0 : I.t =
    let open I.Infix in
    (* input0 = rjd1 *)
    (* output0 = rj1d1 *)
    (* self-trans & shift (substitution and delete) & insert *)
    (I.shift_or ~mismatch input1) && (I.lshift1 (input0 && output0)) && input0

  let[@inline] transition1_so ~shift_or1 ~input0 ~output0 : I.t =
    let open I.Infix in
    shift_or1 && (I.lshift1 (input0 && output0)) && input0


  module Exact = struct
    let initial_bv0 : I.t = I.minus_one

    let[@inline] output0 ~mismatch ~input0 = (transition0[@inlined]) ~mismatch ~input0
  end

  module K1 = struct
    include Exact
    let initial_bv1 : I.t = I.lshift1 initial_bv0

    let[@inline] output1 ~mismatch ~input0 ~input1 ~output0 = (transition1[@inlined]) ~mismatch ~input0 ~input1 ~output0
  end

  module K2 = struct
    include K1
    let initial_bv2 : I.t = I.lshift1 initial_bv1

    let[@inline] output2 ~mismatch ~(input1 : I.t) ~(input2 : I.t) ~(output1 : I.t) : I.t =
      (transition1[@inlined]) ~mismatch ~input0:input1 ~input1:input2 ~output0:output1
  end

  module K3 = struct
    include K2
    let initial_bv3 : I.t = I.lshift1 initial_bv2

    let[@inline] output3 ~mismatch ~(input2 : I.t) ~(input3 : I.t) ~(output2 : I.t) : I.t =
      (transition1[@inlined]) ~mismatch ~input0:input2 ~input1:input3 ~output0:output2
  end

  module Functional = struct
    (** The functions in this module are similar to [WuManber.WuManber]. *)

    let initial_bvs = WM.WuManber.initial_bvs

    let next_bvs ~k1 ~mismatch (input : I.t array) : I.t array =
      let output = Array.map (I.shift_or ~mismatch) input in
      let rec loop input_prev output_prev i output k1 mismatch input =
        if Int.equal i k1 then
          output
        else
          let input_next = Array.unsafe_get input i in
          let shift_or1 = Array.unsafe_get output i in
          let output_next =
            (transition1_so[@inlined]) ~shift_or1 ~input0:input_prev ~output0:output_prev
          in
          let _ : unit = Array.unsafe_set output i output_next in
          loop input_next output_next (i + 1) output k1 mismatch input
      in
      let input0 = Array.unsafe_get input 0 in
      let output0 = Array.unsafe_get output 0 in
      loop input0 output0 1 output k1 mismatch input
  end

  module Imperative = struct
    (** The functions in this module are similar to [WuManber.WuManber], but
        they modify arrays instead of producing new ones. *)

    let initial_bvs = WM.WuManber.initial_bvs

    let reset_bvs bvs =
      for i = 0 to ((Array.length bvs) - 1) do
        bvs.(i) <- I.shift_left I.minus_one i
      done

    let next_bvs ~k1 ~mismatch (arr : I.t array) : unit =
      let rec loop input_prev output_prev i k1 mismatch arr =
        if Int.equal i k1 then
          ()
        else
          let input_this = Array.unsafe_get arr i in
          let output_this =
            (transition1[@inlined]) ~mismatch ~input0:input_prev ~input1:input_this ~output0:output_prev
          in
          let _ : unit = arr.(i) <- output_this in
          loop input_this output_this (i + 1) k1 mismatch arr
      in
      let input_this = Array.unsafe_get arr 0 in
      let output_this = transition0 ~mismatch ~input0:input_this in
      let _ : unit = Array.unsafe_set arr 0  output_this in
      loop input_this output_this 1 k1 mismatch arr
  end

end

module RightLeaningWuManber = struct
  module Exact = struct
    let initial_bv0 : I.t = I.minus_one

    let[@inline] output0 ~mismatch ~input0 = (WuManber.transition0[@inlined]) ~mismatch ~input0
  end

  module K1 = struct
    include Exact
    let initial_bv1 : I.t = initial_bv0

    let sentinel_mismatch = I.minus_one

    let[@inline] del_mask0 ~input0 = I.shift_left input0 2
    let[@inline] shifted1 ~input1 = I.lshift1 input1
    let[@inline] del_shifted1 ~shifted1 ~del_mask0 = I.Infix.(shifted1 && del_mask0)
    let[@inline] output1 ~mismatch ~del_shifted1 ~input0 =
      let open I.Infix in
      (del_shifted1 || mismatch) && (I.lshift1 input0) && input0
  end

  module K2 = struct
    include K1
    let initial_bv2 : I.t = initial_bv1

    let[@inline] del_mask1 ~del_shifted1 = I.lshift1 del_shifted1
    let[@inline] shifted2 ~input2 = (shifted1[@inlined]) ~input1:input2
    let[@inline] del_shifted2 ~shifted2 ~del_mask1 = (del_shifted1[@inlined]) ~shifted1:shifted2 ~del_mask0:del_mask1
    let[@inline] output2 ~mismatch ~del_shifted2 ~input1 =
      (output1[@inlined]) ~mismatch ~del_shifted1:del_shifted2 ~input0:input1
  end

  module K3 = struct
    include K2
    let initial_bv3 : I.t = initial_bv2

    let[@inline] del_mask2 ~del_shifted2 = (del_mask1[@inlined]) ~del_shifted1:del_shifted2
    let[@inline] shifted3 ~input3 = (shifted1[@inlined]) ~input1:input3
    let[@inline] del_shifted3 ~shifted3 ~del_mask2 = (del_shifted1[@inlined]) ~shifted1:shifted3 ~del_mask0:del_mask2
    let[@inline] output3 ~mismatch ~del_shifted3 ~input2 =
      (output1[@inlined]) ~mismatch ~del_shifted1:del_shifted3 ~input0:input2
  end

  module Functional = struct
    (** The functions in this module are similar to
        [WuManber.RightLeaningWuManber]. *)

    let initial_bvs = WM.RightLeaningWuManber.initial_bvs

    let next_bvs ~k1 ~mismatch (input : I.t array) : I.t array =
      (* Self Transitions, i.e. R2/D2/S2 *)
      let output = Array.map I.lshift1 input in
      (* inserts, shifts, deletes *)
      let rec loop del_mask i output k1 mismatch input =
        if (i = k1) then
          output
        else
          let rjd1 = Array.unsafe_get input (i-1) in
          let shifted = Array.unsafe_get output i in
          let del_and_shifted =
            let open I.Infix in
            (shifted && del_mask)
          in
          let del_mask = I.lshift1 del_and_shifted in
          let new_output_i =
            let open I.Infix in
            (* self-trans && delete & shift (substitution) & insert *)
            (del_and_shifted || mismatch) && (I.lshift1 rjd1) && rjd1
          in
          let () = Array.unsafe_set output i new_output_i in
          loop del_mask (i + 1) output k1 mismatch input
      in
      (* delmask is the collection of all the delete epsilon transitions from the
         input. *)
      (* Do index 0 manually *)
      let shifted0 = (Array.unsafe_get output 0) in
      let del_mask = I.lshift1 shifted0 in
      let _ : unit = Array.unsafe_set output 0 (I.logor shifted0 mismatch) in
      loop del_mask 1 output k1 mismatch input
  end

  module Imperative = struct
    (** The functions in this module are similar to
        [WuManber.RightLeaningWuManber], but they modify arrays instead of
        producing new ones. *)

    let initial_bvs = WM.RightLeaningWuManber.initial_bvs

    let reset_bvs bvs =
      for i = 0 to ((Array.length bvs) - 1) do
        bvs.(i) <- I.minus_one
      done

    let next_bvs ~k1 ~mismatch (arr : I.t array) : unit =
      (* inserts, shifts, deletes *)
      let rec loop del_mask_prev input_prev i k1 mismatch arr =
        if (i = k1) then
          ()
        else
          let input_this = arr.(i) in
          let shifted = I.lshift1 input_this in
          let del_and_shifted =
            let open I.Infix in
            (shifted && del_mask_prev)
          in
          let del_mask_this = I.lshift1 del_and_shifted in
          let new_output_i =
            let open I.Infix in
            (* self-trans && delete & shift (substitution) & insert *)
            (del_and_shifted || mismatch) && (I.lshift1 input_prev) && input_prev
          in
          let () = arr.(i) <- new_output_i in
          loop del_mask_this input_this (i + 1) k1 mismatch arr
      in
      (* delmask is the collection of all the delete epsilon transitions from the
         input. *)
      (* Do index 0 manually *)
      let input0 = arr.(0) in
      let _ : unit = arr.(0) <- Exact.output0 ~mismatch ~input0 in
      let del_mask0 = I.shift_left input0 2 in
      loop del_mask0 input0 1 k1 mismatch arr

  let feed_sentinel ~k1 (arr : I.t array) =
    next_bvs ~k1 ~mismatch:(I.minus_one) arr
  end
end
