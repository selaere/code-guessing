with builtins; rec {
  parse = 
    with (import (fetchTarball {
      url = "https://github.com/kanwren/nix-parsec/archive/v0.2.0.tar.gz";
      sha256 = "1v1krqzvpmb39s42m5gg2p7phhp4spd0vkb4wlhfkgbhi20dk5w7";
    })).parsec;
    let {
      spaces = void (many (choice [
        (string " ") (string "\n") (skipThen (string "#") (skipWhile (c: c != "\n")))
      ]));
      symbol = s: thenSkip (string s) spaces;
      br = open: close:
        lift2 (b: c: {inherit b c;}) (symbol open) (thenSkip expr (symbol close));
      expr = many (choice [ (br "(" ")") (br "[" "]") (br "{" "}") (br "<" ">") ]);
      body = runParser (between spaces eof expr);
    };
  eval = s1: s2:
    let
      init   = l: genList (x: elemAt l x) (length l - 1);
      last   = l: elemAt l (length l - 1);
      return = s1: s2: ret: { inherit s1 s2 ret; };
      toRet  = f: v: v//{ ret = f v.ret; };
      eval1  = s1: s2: expr:
        (if length expr.c == 0 then {
          ${"("} = return s1 s2 1;
          ${"["} = return s1 s2 (length s1);
          ${"<"} = return s2 s1 0;
          ${"{"} = if s1 == [] then return s1 s2 0 else return (init s1) s2 (last s1);
        } else {
          ${"("} = (v: v//{ s1=v.s1++[v.ret]; }) (eval s1 s2 expr.c);
          ${"["} = (toRet (x: -x)) (eval s1 s2 expr.c);
          ${"<"} = (toRet (x: 0 )) (eval s1 s2 expr.c);
          ${"{"} = let loop = {s1, s2, ret}@v:
            if s1 == [] || last s1 == 0 then v else (toRet (x: x+ret)) (loop (eval s1 s2 expr.c));
          in loop (return s1 s2 0);
        }).${expr.b};
    in foldl'
      ({s1, s2, ret}: next: (toRet (x: x+ret)) (eval1 s1 s2 next))
      (return s1 s2 0);
  run = stack: code: with parse code;
    if type == "success" then eval stack [] value else throw (toJSON value);
}