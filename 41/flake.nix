{

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    wsrc = {
      url = "github:ktye/w";
      flake = false;
    };
  };

  description = "A very basic flake";

  outputs = { self, nixpkgs, wsrc }: {
    devShells.x86_64-linux.default =
      let
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        w = pkgs.buildGoPackage {
          pname = "w";
          version = "0.0.1";
          goPackagePath = "github:ktye/w";
          src = wsrc;
        };
        jstackwasm = pkgs.stdenv.mkDerivation {
          pname = "jstack";
          version = "0.0.1";
          src = wsrc;
          buildInputs = [ w ];
          buildPhase = ''
            w j.w > jstack.wasm
          '';
          installPhase = ''
            mkdir -p $out/bin
            cp jstack.wasm $out/bin
          '';
        };
        jstack = pkgs.rustPlatform.buildRustPackage {
          pname = "jstack";
          version = "1.0.0";
          src = ./.;
          cargoLock = {
            lockFile = ./Cargo.lock;
          };
          preBuild = ''
            cp ${jstackwasm}/bin/jstack.wasm .
          '';
          doCheck = false;
        };
      in pkgs.mkShell { nativeBuildInputs = [ jstack ]; };
  };
}
