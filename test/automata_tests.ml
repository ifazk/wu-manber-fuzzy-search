let int64_to_string =
  Pp_binary_ints.Int64.make_to_string ~prefix:false ~suffix:false ~separators:false ~min_width:64 ()

let trim_int64_string_to63 i64 =
  String.sub i64 1 63

let int63_to_string x =
  (Optint.Int63.to_int64 x) |> int64_to_string |> trim_int64_string_to63
let pp_sep fmt () : unit = Format.fprintf fmt ";@ "
let pp_int63 fmt x = Format.fprintf fmt "%s" (int63_to_string x)
let pp_int63_list fmt l = Format.(pp_print_list ~pp_sep pp_int63 fmt l)

let usage_msg = "automata_tests [-k NUM] [-s NUM] <PATTERN> <TEXT>"
let kref = ref 2
let sref = ref (-1)
let fref = ref false
let anon_strings = ref []

let anon_fun str =
  anon_strings := str::!anon_strings

let speclist =
  [("-k", Arg.Set_int kref, "Set error limit")
  ;("-s", Arg.Set_int sref, "Set number of sentinels and set mode to rightleaning")
  ;("-f", Arg.Set fref, "Use the first match module, uses -s, but ignores value")
  ]

module SM = Slow_matcher.SlowMatcher.Make (Wu_Manber.StringSearch.Pattern)
module SS = Wu_Manber.StringSearch

let () =
  Arg.parse speclist anon_fun usage_msg;
  let (pattern,text) =
    match !anon_strings with
    | [t;p] -> p,t
    | _ -> failwith "incorrect number of pattern/text arguments"
  in
  let k = !kref in
  let s = !sref in
  let bvs =
    if s >= 0 then
      begin
        if !fref then
          match
            SS.search_right_leaning ~k ~pattern ~text
          with
          | Some (_,_,x) as y ->
            Printf.printf "%s\n" (SS.report y);
            x
          | None -> [| |]
        else
          SM.right_leaning ~k ~pattern ~sentinels:s ~text
      end
    else
      begin
        if !fref then
          match
            Wu_Manber.StringSearch.search ~k ~pattern ~text
          with
          | Some (_,_,x) as y ->
            Printf.printf "%s\n" (SS.report y);
            x
          | None -> [| |]
        else
          SM.slow ~k ~pattern ~text
      end
  in
  let l = bvs |> Array.to_list in
  Format.printf "@[%a@]\n" pp_int63_list l
