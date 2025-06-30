let pkgs = import <nixpkgs> {}; in pkgs.mkShell {
  packages = with pkgs; [ curl bc jq unixtools.column clang bfc cbqn gcc sbcl ldc elixir gforth go ghc jdk nodejs ngn-k lua perl php python3 ruby rustc scala zig ];
  LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
}