(** Interal Module used for debugging *)

open Wu_Manber
open WuManber

module Make (P : Patterns.PatternWithFoldLeft) = struct
  module Match = Matcher.SimpleMismatch (P)

  module WM = WuManber

  let slow ~k ~pattern ~text =
    P.fold_left
      (fun bv c -> WM.next_bvs ~mismatch:(Match.mismatch_bv ~pattern c) bv)
      (WM.initial_bvs ~k)
      text

  module WMR = RightLeaningWuManber

  let right_leaning ~k ~pattern ~sentinels ~text =
    let rec int_fold ~f ~n ~init =
      if n = 0 then
        init
      else
        int_fold ~f ~n:(n-1) ~init:(f init)
    in
    let real_chars =
      P.fold_left
        (fun bv c -> WMR.next_bvs ~mismatch:(Match.mismatch_bv ~pattern c) bv)
        (WMR.initial_bvs ~k)
        text
    in
    int_fold ~f:(WMR.next_bvs ~mismatch:(Optint.Int63.minus_one)) ~n:sentinels ~init:real_chars
end
