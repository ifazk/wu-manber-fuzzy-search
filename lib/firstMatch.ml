open WuManber

module Make (P : Patterns.Pattern) (M : Matcher.Matcher with type pattern := P.t and type elem := P.elem) = struct
  include MakeWuManber (P)

  let first_match ~pattern ~k (s : P.elem Seq.t) =
    let pattern_length = P.length pattern in
    let matcher = new M.matcher pattern in
    let rec find count bvs s =
      match BitOps.match_error ~pattern_length bvs with
      | Some n -> Some (count, n)
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
