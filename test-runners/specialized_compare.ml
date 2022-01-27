let int64_to_string =
  Pp_binary_ints.Int64.make_to_string ~prefix:false ~suffix:false ~separators:false ~min_width:64 ()

let trim_int64_string_to63 i64 =
  String.sub i64 1 63

let int63_to_string x =
  (Optint.Int63.to_int64 x) |> int64_to_string |> trim_int64_string_to63
let pp_sep fmt () : unit = Format.fprintf fmt ";@ "
let pp_int63 fmt x = Format.fprintf fmt "%s" (int63_to_string x)
let pp_int63_list fmt l = Format.(pp_print_list ~pp_sep pp_int63 fmt l)

let pp_bvs fmt bvs =
  let l = bvs |> Array.to_list in
  Format.fprintf fmt "[|@[<v>%a@]|]" pp_int63_list l

let print_bvs bvs =
  Format.printf "%a\n" pp_bvs bvs

let pp_bv_list fmt l =
  Format.(pp_print_list ~pp_sep pp_bvs fmt l)

let print_bv_lists (l : Optint.Int63.t array list) =
  Format.printf "[|@[<v>%a@]|]\n" pp_bv_list l

let usage_msg = "specialized_compare <PATTERN> <TEXT>"
(* let sref = ref (-1) *)
let anon_strings = ref []

let anon_fun str =
  anon_strings := str::!anon_strings

let speclist =
  [
    (* ("-s", Arg.Set_int sref, "Set number of sentinels and set mode to rightleaning") *)
  ]

module SS = Wu_Manber.StringSearch
module ArrayMatcher = Wu_Manber.Matcher.MakeArrayMatcher (SS.Pattern)
module Good = struct
  module WM = struct
    open Wu_Manber.WuManber.WuManber

    let good ~matcher ~text k =
      let rec loop bvs i =
        if (i = String.length text) then
          bvs
        else
          let mismatch = (matcher#mismatch (String.get text i)) in
          loop (next_bvs ~mismatch bvs) (i+1)
      in
      loop (initial_bvs ~k) 0
  end
end
module SP = struct
  module WM = struct
    module WM = Wu_Manber.Specialized.WuManber
    let k0 ~matcher ~text =
      let rec loop bv i =
        if (i = String.length text) then
          [|bv|]
        else
          loop (WM.Exact.output0 ~mismatch:(matcher#mismatch (String.get text i)) ~input0:bv) (i+1)
      in
      loop (WM.Exact.initial_bv0) 0

    let k1 ~matcher ~text =
      let rec loop input0 input1 i =
        if (i = String.length text) then
          [|input0;input1|]
        else
          let mismatch = (matcher#mismatch (String.get text i)) in
          let open WM in
          let output0 = K1.output0 ~mismatch ~input0 in
          let output1 = K1.output1 ~mismatch ~input0 ~input1 ~output0 in
          loop output0 output1 (i+1)
      in
      loop (WM.K1.initial_bv0) (WM.K1.initial_bv1) 0

    let k2 ~matcher ~text =
      let rec loop input0 input1 input2 i =
        if (i = String.length text) then
          [|input0;input1;input2|]
        else
          let mismatch = (matcher#mismatch (String.get text i)) in
          let open WM in
          let output0 = K2.output0 ~mismatch ~input0 in
          let output1 = K2.output1 ~mismatch ~input0 ~input1 ~output0 in
          let output2 = K2.output2 ~mismatch ~input1 ~input2 ~output1 in
          loop output0 output1 output2 (i+1)
      in
      loop (WM.K2.initial_bv0) (WM.K2.initial_bv1) (WM.K2.initial_bv2) 0

    let k3 ~matcher ~text =
      let rec loop input0 input1 input2 input3 i =
        if (i = String.length text) then
          [|input0;input1;input2;input3|]
        else
          let mismatch = (matcher#mismatch (String.get text i)) in
          let open WM in
          let output0 = K3.output0 ~mismatch ~input0 in
          let output1 = K3.output1 ~mismatch ~input0 ~input1 ~output0 in
          let output2 = K3.output2 ~mismatch ~input1 ~input2 ~output1 in
          let output3 = K3.output3 ~mismatch ~input2 ~input3 ~output2 in
          loop output0 output1 output2 output3 (i+1)
      in
      loop (WM.K3.initial_bv0) (WM.K3.initial_bv1) (WM.K3.initial_bv2) (WM.K3.initial_bv3) 0

    let functional ~matcher ~k ~text =
      let open WM.Functional in
      let rec loop bvs i =
        if (i = String.length text) then
          bvs
        else
          let mismatch = (matcher#mismatch (String.get text i)) in
          loop (next_bvs ~k1:(k + 1) ~mismatch bvs) (i+1)
      in
      loop (initial_bvs ~k) 0

    let imperative ~matcher ~k ~text =
      let open WM.Imperative in
      let rec loop bvs i =
        if (i = String.length text) then
          bvs
        else
          let mismatch = (matcher#mismatch (String.get text i)) in
          let _ : unit = (next_bvs ~k1:(k + 1) ~mismatch bvs) in
          loop bvs (i+1)
      in
      loop (initial_bvs ~k) 0
  end
end

let kArr matcher text = function
  | 0 ->
    [ SP.WM.k0 ~matcher ~text
    ; SP.WM.functional ~matcher ~k:0 ~text
    ; SP.WM.imperative ~matcher ~k:0 ~text
    ]
  | 1 ->
    [ SP.WM.k1 ~matcher ~text
    ; SP.WM.functional ~matcher ~k:1 ~text
    ; SP.WM.imperative ~matcher ~k:1 ~text
    ]
  | 2 ->
    [ SP.WM.k2 ~matcher ~text
    ; SP.WM.functional ~matcher ~k:2 ~text
    ; SP.WM.imperative ~matcher ~k:2 ~text
    ]
  | 3 ->
    [ SP.WM.k3 ~matcher ~text
    ; SP.WM.functional ~matcher ~k:3 ~text
    ; SP.WM.imperative ~matcher ~k:3 ~text
    ]
  | k ->
    [ SP.WM.functional ~matcher ~k ~text
    ; SP.WM.imperative ~matcher ~k ~text
    ]

let test_wm pattern text =
  let iarr = Array.make 7 0 in
  let _ : unit = Array.iteri (fun i _ -> iarr.(i) <- i) iarr in
  let matcher = new ArrayMatcher.matcher pattern in
  let k_map = Array.map (kArr matcher text) iarr in
  let good_map = Array.map (Good.WM.good ~matcher ~text) iarr in
  let b_map =
    let is_eq g klist =
      List.map ((=) g) klist
      |> List.fold_left (&&) true
    in
    Array.map2 (is_eq) good_map k_map
  in
  let pass_fail b k =
    if b then
      ( Format.printf "PASS\n"
      ; print_bvs (List.hd k)
      )
    else
      ( Format.printf "FAIL\n"
      ; print_bv_lists k
      )
  in
  Array.iter2 pass_fail b_map k_map

module RLGood = struct
  module RLWM = struct
    open Wu_Manber.WuManber.RightLeaningWuManber

    let rec loop_sentitels bv s =
      if s = 0 then
        bv
      else
        loop_sentitels (feed_sentinel bv) (s - 1)

    let good ~matcher ~text k =
      let rec loop bvs i =
        if (i = String.length text) then
          bvs
        else
          let mismatch = (matcher#mismatch (String.get text i)) in
          loop (next_bvs ~mismatch bvs) (i+1)
      in
      loop (initial_bvs ~k) 0
  end
end
module RLSP = struct
  module RLWM = struct
    module WM = Wu_Manber.Specialized.RightLeaningWuManber
    let k0 ~matcher ~text =
      let rec loop bv i =
        if (i = String.length text) then
          [|bv|]
        else
          loop (WM.Exact.output0 ~mismatch:(matcher#mismatch (String.get text i)) ~input0:bv) (i+1)
      in
      loop (WM.Exact.initial_bv0) 0

    let k1 ~matcher ~text =
      let rec loop input0 input1 i =
        if (i = String.length text) then
          [|input0;input1|]
        else
          let mismatch = (matcher#mismatch (String.get text i)) in
          let open WM in
          let output0 = K1.output0 ~mismatch ~input0 in
          let del_mask0 = K1.del_mask0 ~input0 in
          let shifted1 = K1.shifted1 ~input1 in
          let del_shifted1 = K1.del_shifted1 ~shifted1 ~del_mask0 in
          let output1 = K1.output1 ~mismatch ~del_shifted1 ~input0 in
          loop output0 output1 (i+1)
      in
      loop (WM.K1.initial_bv0) (WM.K1.initial_bv1) 0

    let k2 ~matcher ~text =
      let rec loop input0 input1 input2 i =
        if (i = String.length text) then
          [|input0;input1;input2|]
        else
          let mismatch = (matcher#mismatch (String.get text i)) in
          let open WM in
          let output0 = K2.output0 ~mismatch ~input0 in
          let del_mask0 = K2.del_mask0 ~input0 in
          let shifted1 = K2.shifted1 ~input1 in
          let del_shifted1 = K2.del_shifted1 ~shifted1 ~del_mask0 in
          let output1 = K2.output1 ~mismatch ~del_shifted1 ~input0 in
          let del_mask1 = K2.del_mask1 ~del_shifted1 in
          let shifted2 = K2.shifted2 ~input2 in
          let del_shifted2 = K2.del_shifted2 ~shifted2 ~del_mask1 in
          let output2 = K2.output2 ~mismatch ~del_shifted2 ~input1 in
          loop output0 output1 output2 (i+1)
      in
      loop (WM.K2.initial_bv0) (WM.K2.initial_bv1) (WM.K2.initial_bv2) 0

    let k3 ~matcher ~text =
      let rec loop input0 input1 input2 input3 i =
        if (i = String.length text) then
          [|input0;input1;input2;input3|]
        else
          let mismatch = (matcher#mismatch (String.get text i)) in
          let open WM in
          let output0 = K3.output0 ~mismatch ~input0 in
          let del_mask0 = K3.del_mask0 ~input0 in
          let shifted1 = K3.shifted1 ~input1 in
          let del_shifted1 = K3.del_shifted1 ~shifted1 ~del_mask0 in
          let output1 = K3.output1 ~mismatch ~del_shifted1 ~input0 in
          let del_mask1 = K3.del_mask1 ~del_shifted1 in
          let shifted2 = K3.shifted2 ~input2 in
          let del_shifted2 = K3.del_shifted2 ~shifted2 ~del_mask1 in
          let output2 = K3.output2 ~mismatch ~del_shifted2 ~input1 in
          let del_mask2 = K3.del_mask2 ~del_shifted2 in
          let shifted3 = K3.shifted3 ~input3 in
          let del_shifted3 = K3.del_shifted3 ~shifted3 ~del_mask2 in
          let output3 = K3.output3 ~mismatch ~del_shifted3 ~input2 in
          loop output0 output1 output2 output3 (i+1)
      in
      loop (WM.K3.initial_bv0) (WM.K3.initial_bv1) (WM.K3.initial_bv2) (WM.K3.initial_bv3) 0

    let functional ~matcher ~k ~text =
      let open WM.Functional in
      let rec loop bvs i =
        if (i = String.length text) then
          bvs
        else
          let mismatch = (matcher#mismatch (String.get text i)) in
          loop (next_bvs ~k1:(k + 1) ~mismatch bvs) (i+1)
      in
      loop (initial_bvs ~k) 0

    let imperative ~matcher ~k ~text =
      let open WM.Imperative in
      let rec loop bvs i =
        if (i = String.length text) then
          bvs
        else
          let mismatch = (matcher#mismatch (String.get text i)) in
          let _ : unit = (next_bvs ~k1:(k + 1) ~mismatch bvs) in
          loop bvs (i+1)
      in
      loop (initial_bvs ~k) 0
  end
end

let kArr matcher text = function
  | 0 ->
    [ RLSP.RLWM.k0 ~matcher ~text
    ; RLSP.RLWM.functional ~matcher ~k:0 ~text
    ; RLSP.RLWM.imperative ~matcher ~k:0 ~text
    ]
  | 1 ->
    [ RLSP.RLWM.k1 ~matcher ~text
    ; RLSP.RLWM.functional ~matcher ~k:1 ~text
    ; RLSP.RLWM.imperative ~matcher ~k:1 ~text
    ]
  | 2 ->
    [ RLSP.RLWM.k2 ~matcher ~text
    ; RLSP.RLWM.functional ~matcher ~k:2 ~text
    ; RLSP.RLWM.imperative ~matcher ~k:2 ~text
    ]
  | 3 ->
    [ RLSP.RLWM.k3 ~matcher ~text
    ; RLSP.RLWM.functional ~matcher ~k:3 ~text
    ; RLSP.RLWM.imperative ~matcher ~k:3 ~text
    ]
  | k ->
    [ RLSP.RLWM.functional ~matcher ~k ~text
    ; RLSP.RLWM.imperative ~matcher ~k ~text
    ]

let test_rl pattern text =
  let iarr = Array.make 7 0 in
  let _ : unit = Array.iteri (fun i _ -> iarr.(i) <- i) iarr in
  let matcher = new ArrayMatcher.matcher pattern in
  let k_map = Array.map (kArr matcher text) iarr in
  let good_map = Array.map (RLGood.RLWM.good ~matcher ~text) iarr in
  let b_map =
    let is_eq g klist =
      List.map ((=) g) klist
      |> List.fold_left (&&) true
    in
    Array.map2 (is_eq) good_map k_map
  in
  let pass_fail b k =
    if b then
      ( Format.printf "PASS\n"
      ; print_bvs (List.hd k)
      )
    else
      ( Format.printf "FAIL\n"
      ; print_bv_lists k
      )
  in
  Array.iter2 pass_fail b_map k_map


let () =
  Arg.parse speclist anon_fun usage_msg;
  let (pattern,text) =
    match !anon_strings with
    | [t;p] -> p,t
    | _ -> failwith "incorrect number of pattern/text arguments"
  in
  test_wm pattern text;
  test_rl pattern text
