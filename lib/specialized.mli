(** This module contains the Wu and Manber algorithm, sepecialized for
    implementation in hot loops. *)

module BitOps : sig
  (** A collection of bitwise operations used in the Wu and Manber algorithm. *)

  val match_error : pattern_length:int -> Optint.Int63.t array -> int option
  (** [match_error ~pattern_length] takes an array of bitvectors and returns
      [Some n] if theres a match with [n] errors, and [None] if there is no
      match. [pattern_length] must be less than or equal [63]. *)

  val is_match : pattern_length:int -> Optint.Int63.t array -> bool
  (** [is_match ~pattern_length] takes an array of bitvectors and returns [true]
      if theres a match. [pattern_length] must be less than or equal [63]. *)

  val get_check_mask : pattern_length:int -> Optint.Int63.t
  (** [get_check_mask ~pattern_length] produces a mask [Outint.Int63.t] for use
      with [match_check]. [pattern_length] must be less than or equal [63]. *)

  val match_check : check_mask:Optint.Int63.t -> Optint.Int63.t -> bool
  (** [match_check ~check_mask bv] checks if there is a match in [bv] using
      [check_mask]. *)
end

module WuManber : sig
  (** Speacialized versions of the algorithm for hot loops *)

  module Exact : sig
    (** Low level module for exact matches. *)

    val initial_bv0 : Optint.Int63.t
    (** The initial bitvector for exact matches. *)

    val output0 : mismatch:Optint.Int63.t -> input0:Optint.Int63.t -> Optint.Int63.t
    (** The next match bitvector for exact matches. *)
  end

  module K1 : sig
    (** Low level module for matches with 1 error. *)

    include module type of Exact
    (* [@inlined] *)

    val initial_bv1 : Optint.Int63.t
    (** The initial bitvector for matches with 1 error. *)

    val output1 : mismatch:Optint.Int63.t -> input0:Optint.Int63.t -> input1:Optint.Int63.t -> output0:Optint.Int63.t -> Optint.Int63.t
    (** The next match bitvector for matches with 1 error. *)
  end

  module K2 : sig
    (** Low level module for matches with 2 errors. *)

    include module type of K1
    (* [@inlined] *)

    val initial_bv2 : Optint.Int63.t
    (** The initial bitvector for matches with 2 errors. *)

    val output2 : mismatch:Optint.Int63.t -> input1:Optint.Int63.t -> input2:Optint.Int63.t -> output1:Optint.Int63.t -> Optint.Int63.t
    (** The next match bitvector for matches with 2 errors. *)
  end

  module K3 : sig
    (** Low level module for matches with 2 errors. *)

    include module type of K2
    (* [@inlined] *)

    val initial_bv3 : Optint.Int63.t
    (** The initial bitvector for matches with 3 errors. *)

    val output3 : mismatch:Optint.Int63.t -> input2:Optint.Int63.t -> input3:Optint.Int63.t -> output2:Optint.Int63.t -> Optint.Int63.t
    (** The next match bitvector for matches with 3 errors. *)
  end

  module Functional : sig
    (** The functions in this module are similar to the ones in the
        [WuManber.WuManber] module. *)

    val initial_bvs : k:int -> Optint.Int63.t array
    (** [initial_bvs ~k] creates a starting array of bitvectors used by the
        algorithm. *)

    val next_bvs : k1:int -> mismatch:Optint.Int63.t -> Optint.Int63.t array -> Optint.Int63.t array
    (** [next_bvs ~k1 ~mismatch bvs] produces an updated bitvector array based
        on [~mismatch]. For an initial bitvector array created with
        [WuManber.initial_bvs ~k], [k1] must be [k + 1]. *)
  end

  module Imperative : sig
    (** The functions in this module are similar to the ones in the outer
        module [WuManber.WuManber], but modify arrays instead of creating new
        ones. *)

    val initial_bvs : k:int -> Optint.Int63.t array
    (** [initial_bvs ~k] creates a starting array of bitvectors used by the
        algorithm. *)

    val reset_bvs : Optint.Int63.t array -> unit
    (** [reset_bvs ~k] resets an array to a starting array of bitvectors used by
        the algorithm. *)

    val next_bvs : k1:int -> mismatch:Optint.Int63.t -> Optint.Int63.t array -> unit
    (** [next_bvs ~k1 ~mismatch bvs] updates the array [bvs] based on
        [~mismatch]. For an initial bitvector array created with
        [WuManber.initial_bvs ~k], [k1] must be [k + 1]. *)
  end
end


module RightLeaningWuManber : sig
  (** Speacialized versions of the algorithm for hot loops *)

  module Exact : sig
    (** Low level module for exact matches. *)

    val initial_bv0 : Optint.Int63.t
    (** The initial bitvector for exact matches. *)

    val output0 : mismatch:Optint.Int63.t -> input0:Optint.Int63.t -> Optint.Int63.t
    (** The next match bitvector for exact matches. *)
  end

  module K1 : sig
    (** Low level module for matches with 1 error. *)

    include module type of Exact
    (* [@inlined] *)

    val initial_bv1 : Optint.Int63.t
    (** The initial bitvector for matches with 1 error. *)

    val sentinel_mismatch : Optint.Int63.t

    val del_mask0 : input0:Optint.Int63.t -> Optint.Int63.t
    val shifted1 : input1:Optint.Int63.t -> Optint.Int63.t
    val del_shifted1 : shifted1:Optint.Int63.t -> del_mask0:Optint.Int63.t -> Optint.Int63.t
    val output1 : mismatch:Optint.Int63.t -> del_shifted1:Optint.Int63.t -> input0:Optint.Int63.t -> Optint.Int63.t
    (** The next match bitvector for matches with 1 error. *)
  end

  module K2 : sig
    (** Low level module for matches with 2 errors. *)

    include module type of K1
    (* [@inlined] *)

    val initial_bv2 : Optint.Int63.t
    (** The initial bitvector for matches with 2 errors. *)

    val del_mask1 : del_shifted1:Optint.Int63.t -> Optint.Int63.t
    val shifted2 : input2:Optint.Int63.t -> Optint.Int63.t
    val del_shifted2 : shifted2:Optint.Int63.t -> del_mask1:Optint.Int63.t -> Optint.Int63.t
    val output2 : mismatch:Optint.Int63.t -> del_shifted2:Optint.Int63.t -> input1:Optint.Int63.t -> Optint.Int63.t
    (** The next match bitvector for matches with 2 errors. *)
  end

  module K3 : sig
    (** Low level module for matches with 2 errors. *)

    include module type of K2
    (* [@inlined] *)

    val initial_bv3 : Optint.Int63.t
    (** The initial bitvector for matches with 3 errors. *)

    val del_mask2 : del_shifted2:Optint.Int63.t -> Optint.Int63.t
    val shifted3 : input3:Optint.Int63.t -> Optint.Int63.t
    val del_shifted3 : shifted3:Optint.Int63.t -> del_mask2:Optint.Int63.t -> Optint.Int63.t
    val output3 : mismatch:Optint.Int63.t -> del_shifted3:Optint.Int63.t -> input2:Optint.Int63.t -> Optint.Int63.t
    (** The next match bitvector for matches with 3 errors. *)
  end

  module Functional : sig
    (** The functions in this module are similar to the ones in the outer
        module [WuManber.RightLeaningWuManber]. *)

    val initial_bvs : k:int -> Optint.Int63.t array
    (** [initial_bv ~k] creates a starting array of bitvectors used by the
        algorithm. *)

    val next_bvs : k1:int -> mismatch:Optint.Int63.t -> Optint.Int63.t array -> Optint.Int63.t array
    (** [next_bvs ~k1 ~mismatch bvs] produces an updated bitvector array based
        on [~mismatch]. For an initial bitvector array created with
        [initial_bvs ~k], [k1] must be [k + 1]. *)
  end

  module Imperative : sig
    (** The functions in this module are similar to the ones in the outer
        module [WuManber], but modify arrays instead of creating new ones. *)

    val initial_bvs : k:int -> Optint.Int63.t array
    (** [initial_bvs ~k] creates a starting array of bitvectors used by the
        algorithm. *)

    val reset_bvs : Optint.Int63.t array -> unit
    (** [reset_bvs ~k] resets an array to a starting array of bitvectors used by
        the algorithm. *)

    val next_bvs : k1:int -> mismatch:Optint.Int63.t -> Optint.Int63.t array -> unit
    (** [next_bvs ~k1 ~mismatch bvs] updates the array [bvs] based on
        [~mismatch]. For an initial bitvector array created with
        [initial_bvs ~k], [k1] must be [k + 1]. *)

    val feed_sentinel : k1:int -> Optint.Int63.t array -> unit
    (** [feed_sentinel ~k1 bvs] updates the array [bvs] assuming that a sentinel
        character different from anything in the alphabet is being fed into the
        algorithm.For an initial bitvector array created with [initial_bvs ~k],
        [k1] must be [k + 1]. *)
  end
end
