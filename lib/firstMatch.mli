(** An module for fuzzy searching the first match in a pattern *)

(** This module is intended to be used for searching as well as an example of
    properly using the low-level functions in the [WuManber] module. *)

module Make
    (P : Patterns.Pattern)
    (M : Matcher.Matcher with type pattern := P.t and type elem := P.elem) : sig

  val first_match :
    pattern:P.t ->
    k:int -> P.elem Seq.t -> (int * int) option
  (** Searches for the first match in a module using the basic Wu and Manber
      algorithm. [~pattern] must have length less than or equal [63]. *)

  val first_rightmost_match :
    pattern:P.t -> k:int -> P.elem Seq.t -> (int * int) option
  (** Searches for the first match in a module using the rightmost match version
      of the Wu and Manber algorithm. [~pattern] must have length less than or
      equal [63]. *)

  val report : (int * int) option -> string
  (** [report match] produces a texual description of the results of the above
      functions. *)
end
(** The [Make (P) (M)] creates a set of functions for finding the first match in
    a sequnce and reporting the number of errors and the position at which the
    match ends. See the functor documentation for more details. *)

(** Since this module is supposed to serve as an example of working with the
    low level li, we provide the code for the module as follows.

{[
open WuManber

module Make (P : Patterns.Pattern) (M : Matcher.Matcher with type pattern := P.t and type elem := P.elem) = struct
  include MakeWuManber (P)

  let first_match ~pattern ~k (s : P.elem Seq.t) =
    let pattern_length = P.length pattern in
    let matcher = new M.matcher pattern in
    let rec find count bvs s =
      match BitOps.match_error ~pattern_length bvs with
      | Some n -> Some (count, n, bvs)
      | None ->
        begin match s () with
          | Seq.Cons (c, s) -> find (count + 1) (next_bvs ~mismatch:(matcher#mismatch c) bvs) s
          | Seq.Nil -> None
        end
    in
    find 0 (BitOps.initial_bvs ~k) s

  include MakeRightmostWuManber (P)

  let first_rightmost_match ~pattern ~k (s : P.elem Seq.t) =
    let pattern_length = P.length pattern in
    let matcher = new M.matcher pattern in
    let rec find_sentinel count bvs n =
      if n = 0 then
        None
      else
        let bvs = feed_sentinel ~pattern_length bvs in
        match BitOps.match_error ~pattern_length bvs with
        | Some n -> Some (count, n)
        | None ->
          find_sentinel count bvs (n - 1)
    in
    let rec find count bvs s =
      match BitOps.match_error ~pattern_length bvs with
      | Some n -> Some (count, n)
      | None ->
        begin match s () with
          | Seq.Cons (c, s) -> find (count + 1) (next_bvs ~pattern_length ~mismatch:(matcher#mismatch c) bvs) s
          | Seq.Nil -> find_sentinel count bvs k
        end
    in
    find 0 (BitOps.initial_bvs ~k) s

  let report = function
    | None -> "Could not find pattern in text"
    | Some (c, e) -> Printf.sprintf "Pattern matched with %d errors at character %d of text" e c
end
]}
*)
