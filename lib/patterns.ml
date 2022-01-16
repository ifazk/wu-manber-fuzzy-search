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
