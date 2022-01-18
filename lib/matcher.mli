(** Collection of functors for creating matchers *)

module type Matcher = sig
  (** Module type for Matchers. *)

  type pattern
  (** Type of patterns for Matcher. *)

  type elem
  (** Type of elements for Matcher. *)

  class matcher : pattern -> object method mismatch : elem -> Optint.Int63.t end
  (** A [class] for creating matcher objects from patterns. A matcher object
      has a [mismatch] method that takes a character and produces a mismatch
      bitvector.

      The pattern must have length less than or equal 63 so that all mismatches
      fit into the 63-bit bitvector.

      A mismatch bitvector is an [Int63.t], with the least significant bit
      represeting the [0]-th bit, and the most significant bit representing the
      [63]-rd bit. It uses a [0] to in indicate a match and a [1] to indicate a
      mismatch. For a pattern [p_0,...,p_n] and a character [c], the mismatch
      bitvector contains a [0] in the i-th bit if [p_i = c] and [1] otherwise.
  *)
end

(** {1 Levenshtein Distance Matchers} *)

(** The following are a collection of matchers for simple patterns. *)

module SimpleMismatch (P : Patterns.PatternWithFoldRight) : sig
  (** A utility functior used for creating matchers. *)

  val push_mismatch : P.elem -> P.elem -> Optint.Int63.t -> Optint.Int63.t
  val mismatch_bv : pattern:P.t -> P.elem -> Optint.Int63.t
end

module MakeSlowMatcher (P : Patterns.PatternWithFoldRight) : sig
  (** A slow matcher which recalculates mismatch bitvectors using [mismatch_bv]
      from the [SimpleMismatch] functior. *)

  class matcher : P.t ->
    object
      method mismatch : P.elem -> Optint.Int63.t
    end
end

module MakeArrayMatcher (P : Patterns.PatternWithIndexableElements) : sig
  (** A fast matcher which precalculates all possible mismatch bitvectors for a
      pattern and stores them in an array. *)

  class matcher : P.t ->
    object
      method mismatch : P.elem -> Optint.Int63.t
    end
end

module MakeHashTblMatcher (P : Patterns.PatternWithFoldRight) : sig
  (** A fast matcher which precalculates mismatch bitvectors for characters in
      the pattern and stores them in an hash table. This uses [Stdlib.Hashtbl]
      for the hash table with [~random] set to true. *)

  class matcher : P.t -> object method mismatch : P.elem -> Optint.Int63.t end
end
