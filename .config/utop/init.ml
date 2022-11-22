#require "lambda-term";;

let open LTerm_text in
UTop.prompt :=
  [ S "utop"
  ; B_fg LTerm_style.lgreen
  ; S " # "
  ]
  |> eval
  |> React.S.const
;;
