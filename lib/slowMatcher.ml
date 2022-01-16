(** Interal Module used for debugging *)

open WuManber

module Make (P : Patterns.PatternWithFoldLeft) = struct
  include Matcher.SimpleMismatch (P)

  include MakeWuManber (P)

  let do_slow_matches ~k ~pattern ~text =
    P.fold_left
      (fun bv c -> next_bvs ~mismatch:(mismatch_bv ~pattern c) bv)
      WuManber.BitOps.(initial_bvs ~k)
      text

  include MakeLeftmostWuManber (P)

  let do_slow_leftmost ~k ~pattern ~sentinels ~text =
    let rec int_fold ~f ~n ~init =
      if n = 0 then
        init
      else
        int_fold ~f ~n:(n-1) ~init:(f init)
    in
    let len = P.length pattern in
    let real_chars =
      P.fold_left
        (fun bv c -> next_bvs ~pattern_length:len ~mismatch:(mismatch_bv ~pattern c) bv)
        WuManber.BitOps.(initial_bvs ~k)
        text
    in
    int_fold ~f:(next_bvs ~pattern_length:len ~mismatch:(Optint.Int63.minus_one)) ~n:sentinels ~init:real_chars
end
