(** This module contains the main parts of the shift-or variant of the Wu and
    Manber algorithm *)

module BitOps : sig
  (** A collection of bitwise operations used in the Wu and Manber algorithm. *)

  val match_error : pattern_length:int -> Optint.Int63.t array -> int option
  (** [match_error ~pattern_length] takes an array of bitvectors and returns
      [Some n] if theres a match with [n] errors, and [None] if there is no
      match. [pattern_length] must be less than or equal [63]. *)

  val is_match : pattern_length:int -> Optint.Int63.t array -> bool
  (** [is_match ~pattern_length] takes an array of bitvectors and returns [true]
      if theres a match. [pattern_length] must be less than or equal [63]. *)
end

module WuManber : sig
  (** Basic Wu and Manber algorithm. *)

  val initial_bvs : k:int -> Optint.Int63.t array
  (** [initial_bvs ~k] creates a starting array of bitvectors used by the
      algorithm. *)

  val next_bvs : mismatch:Optint.Int63.t -> Optint.Int63.t array -> Optint.Int63.t array
  (** [next_bvs ~mismatch bvs] produces an updated bitvector array based on [~mismatch]. *)

end

module RightLeaningWuManber : sig
  (** Wu and Manber algorithm modified for right leaning matches. *)

  (** The right leaning variant of the algorithm requires the user to feed [k]
      sentinel characters into the algorithm at the end of the text to get
      matches near the end, where [k] is the error limit that the algorithm was
      started with. See the code for the {!FirstMatch} module for an example. *)

  val initial_bvs : k:int -> Optint.Int63.t array
  (** [initial_bvs ~k] creates a starting array of bitvectors used by the
      algorithm. *)

  val next_bvs : mismatch:Optint.Int63.t -> Optint.Int63.t array -> Optint.Int63.t array
  (** [next_bvs ~pattern_length ~mismatch bvs] produces an updated bitvector array based on
      [~mismatch]. [pattern_length] must be less than or equal [63]. *)

  val feed_sentinel : Optint.Int63.t array -> Optint.Int63.t array
  (** [feed_sentinel ~pattern_length bvs] produces an updated bitvector array
      assuming that a sentinel character different from anything in the alphabet
      is being fed into the algorithm. [pattern_length] must be less than or
      equal [63]. *)
end
