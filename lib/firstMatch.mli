(** An module for fuzzy searching the first match in a sequence *)

(** This module is intended to be used for searching as well as an example of
    properly using the low-level functions in the [WuManber] module. *)

module Make
    (P : Patterns.Pattern)
    (M : Matcher.Matcher with type pattern := P.t and type elem := P.elem) : sig

  (** The search functions in this module stop after the first match, and returns
      the error count together with the number of characters of the text read by
      the algorithm. *)

  val first_match :
    pattern:P.t ->
    k:int -> P.elem Seq.t -> (int * int * Optint.Int63.t array) option
  (** Searches for the first match in a sequence using the basic Wu and Manber
      algorithm. [~pattern] must have length less than or equal [63]. *)

  val first_right_leaning_match :
    pattern:P.t -> k:int -> P.elem Seq.t -> (int * int * Optint.Int63.t array) option
  (** Searches for the first match in a sequence using the right leaning variant
      of the Wu and Manber algorithm. [~pattern] must have length less than or
      equal [63]. *)

  val report : (int * int * Optint.Int63.t array) option -> string
  (** [report] produces a texual description of the results of the above
      functions. *)
end
(** [Make (P) (M)] creates a set of functions for finding the first match in a
    sequnce and reporting the number of errors and the position at which the
    match ends. See the functor documentation for more details. *)

(** Since this module is supposed to serve as an example of working with the
    low level api, we provide the code for the module as follows.

{1 Annotated Source code for module}

{[
open WuManber

module Make (P : Patterns.Pattern) (M : Matcher.Matcher with type pattern := P.t and type elem := P.elem) = struct
]}

We are creating a functor that ranges over patterns and matchers for those
patterns.

A patterns contains characters, and a matcher takes a character [c] and outputs
a bit-vector indicating which characters of the pattern match [c].

{[
  module WM = WuManber
]}

We will use the low level functions [initial_bvs] and [next_bvs]
from the {!WuManber.WuManber} module.

We think of [initial_bvs] as an initial state of an automaton, and [next_bvs]
makes the automaton take steps to the next state using outputs of matchers as
inputs. The {!WuManber.BitOps.match_error} and {!WuManber.BitOps.is_match}
functions are used to check if the automaton is in a final state, i.e. if there
is a fuzzy match with the pattern.

{[
  let first_match ~pattern ~k (s : P.elem Seq.t) =
    let pattern_length = P.length pattern in
    let matcher = new M.matcher pattern in
    let rec find count bvs s =
      match BitOps.match_error ~pattern_length bvs with
      | Some n -> Some (count, n, bvs)
      | None ->
        begin match s () with
          | Seq.Cons (c, s) -> find (count + 1) (WM.next_bvs ~mismatch:(matcher#mismatch c) bvs) s
          | Seq.Nil -> None
        end
    in
    find 0 (WM.initial_bvs ~k) s
]}

The above function creates a matcher from the [~pattern], and uses it to go
through the sequence [s], one character at a time, until a match in found.

We next implement the right leaning variant of the function.

{[
  module WMR = RightLeaningWuManber
]}

The {!WuManber.RightLeaningWuManber} module contains the low level functions
[initial_bvs], [next_bvs], and [feed_sentinel]. The functions and notions of
automaton are similar to the regular version of the algorithm.

But this version of the algorithm does not match delete edits at the end of the
pattern, and so matches at the end of the text won't be reported.

To recover the deletes edits at the very end of the text, we feed sentinel
characters into the automaton using the [feed_sentinel] function. We need feed a
maximum of [k] sentinel characters into the automaton to check for matches.

{[
  let first_right_leaning_match ~pattern ~k (s : P.elem Seq.t) =
    let pattern_length = P.length pattern in
    let matcher = new M.matcher pattern in
    let rec find_sentinel count bvs n =
      if n = 0 then
        None
      else
        let bvs = WMR.feed_sentinel bvs in
        match BitOps.match_error ~pattern_length bvs with
        | Some n -> Some (count, n, bvs)
        | None ->
          find_sentinel count bvs (n - 1)
    in
    let rec find count bvs s =
      match BitOps.match_error ~pattern_length bvs with
      | Some n -> Some (count, n, bvs)
      | None ->
        begin match s () with
          | Seq.Cons (c, s) -> find (count + 1) (WMR.next_bvs ~mismatch:(matcher#mismatch c) bvs) s
          | Seq.Nil -> find_sentinel count bvs k
        end
    in
    find 0 (WMR.initial_bvs ~k) s
]}

The above function creates a matcher from the [~pattern], and uses it to go
through the sequence [s], one character at a time, until a match in found.
If the end of text is reached, [k] sentinel characters are fed into the
automaton to search for a match at the end of the text.

{[
  let report = function
    | None -> "Could not find pattern in text"
    | Some (c, e, _) -> Printf.sprintf "Pattern matched with %d errors at character %d of text" e c
]}

The above function is a utility function which creates a texual description of
the output of the first match functions.

{[
end
]}

*)
