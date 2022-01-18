(** Collection of modules types for patterns with different operations *)

module type Pattern = sig
  (** Basic pattern. *)

  type t
  (** The type of patterns. *)

  val length : t -> int
end

module type Elems = sig
  (** Some notion of characters. *)

  type elem
  (** The type of characters in the patterns. *)
end

(** {1 Useful operators for patterns and elements} *)

module type ElemsWithEquality = sig
  (** Some notion of characters and equality between characters. *)

  include Elems

  val elem_eq : elem -> elem -> bool
  (** Operation to check if two characters are equal. *)
end

module type ElemsIndexable = sig
  (** Characters can be enumerated from [0] to some [n]. *)

  include Elems

  val int_of_elem : elem -> int
  (** Convert elements to [int]. *)

  val elem_of_int : int -> elem
  (** [elem_of_int n] should convert an [n] between [0] and [max_elem_index]
      (inclusive) to an element. *)

  val max_elem_index : int
  (** The maximal index for elements. The maximal index should be the last index
      that an element can be mapped to.

      Note: This is 1 less than the total number of elements. For example, there
      are a total of [256] chars, but [char] can be enumerated from [0] to
      [255], so [max_elem_index] for [char]s should be [255].
  *)
end

module type PatternWithElemEquality = sig
  (** Patterns with a notion of characters and a equality of characters
      operator. *)

  include Pattern

  include ElemsWithEquality
end

module type PatternWithFoldRight = sig
  (** Patterns with a fold right operation. *)

  include PatternWithElemEquality

  val fold_right : (elem -> 'a -> 'a) -> t -> 'a -> 'a
end

module type PatternWithFoldLeft = sig
  (** Patterns with both fold right and fold left operations. *)

  include PatternWithFoldRight

  val fold_left : ('a -> elem -> 'a) -> 'a -> t -> 'a
end

module type PatternWithIndexableElements = sig
  (** Patterns with a fold right operation where the elements can enumerated
      from [0] to some [max_elem_index]. *)

  include PatternWithFoldRight

  include ElemsIndexable with type elem := elem
end
