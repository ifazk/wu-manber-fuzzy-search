let () =
  let k = int_of_string Sys.argv.(1) in
  let p = Sys.argv.(2) in
  let t = Sys.argv.(3) in
  Printf.printf "k=%d, p=\"%s\", t=\"%s\"\n" k p t;
  Printf.printf "%s\n" Wu_Manber.StringSearch.(search ~k ~pattern:p ~text:t |> report);
  Printf.printf "%s\n" Wu_Manber.StringSearch.(search_rightmost ~k ~pattern:p ~text:t |> report);
