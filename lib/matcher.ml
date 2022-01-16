module I = Utils.Int63

module type Pattern = sig

  type t

  type elem

  val length : t -> int

  val elem_eq : elem -> elem -> bool
end

module type PatternWithFoldRight = sig

  include Pattern

  val fold_right : (elem -> 'a -> 'a) -> t -> 'a -> 'a
end

module type PatternWithFoldLeft = sig

  include PatternWithFoldRight

  val fold_left : ('a -> elem -> 'a) -> 'a -> t -> 'a
end

module type PatternWithIndexableElements = sig

  include PatternWithFoldRight

  val int_of_elem : elem -> int

  val elem_of_int : int -> elem

  val max_elem_index : int
end

module SimpleMismatch (P : PatternWithFoldRight) = struct
  let push_mismatch e1 e2 bv : I.t =
    let shifted = I.lshift1 bv in
    if P.elem_eq e1 e2 then
      shifted
    else
      I.logor I.one shifted

  let mismatch_bv ~pattern char : I.t =
    P.fold_right (push_mismatch char) pattern I.zero
end

module type MisMatcher = sig
  type pattern
  type elem

  class matcher : pattern ->
    object
      method mismatch : elem -> I.t
    end
end

module MakeSlowMatcher (P : PatternWithFoldRight) : MisMatcher with type pattern := P.t and type elem := P.elem = struct
  include SimpleMismatch (P)
  class matcher pattern =
    object (_)
      val pattern = pattern
      method mismatch c =
        mismatch_bv ~pattern c
    end
end

module MakeArrayMatcher (P : PatternWithIndexableElements) : MisMatcher with type pattern := P.t and type elem := P.elem = struct
  include SimpleMismatch (P)
  class matcher pattern =
    object (_)
      val arr =
        let ar = Array.make (P.max_elem_index + 1) I.zero in
        let () = Array.iteri (fun n _ -> ar.(n) <- mismatch_bv ~pattern (P.elem_of_int n)) ar in
        ar
      method mismatch c =
        arr.(P.int_of_elem c)
    end
end

module MakeHashTblMatcher (P : PatternWithFoldRight) : MisMatcher with type pattern := P.t and type elem := P.elem = struct
  include SimpleMismatch (P)
  class matcher pattern =
    object (_)
      val hashtbl =
        let ht = Hashtbl.create ~random:true (P.length pattern) in
        let push_mismatch c () =
          if (Hashtbl.mem ht c) then
            ()
          else
            let mm = mismatch_bv ~pattern c in
            Hashtbl.add ht c mm
        in
        let () = P.fold_right push_mismatch pattern () in
        ht
      method mismatch c =
        match Hashtbl.find_opt hashtbl c with
        | Some (c) -> c
        | None -> I.minus_one
    end
end
