{
  description = "A nix flake for the Yosys synthesis suite";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    yosys = {
      url = "github:RCoeurjoly/yosys";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, yosys }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        customYosys = pkgs.clangStdenv.mkDerivation {
          name = "yosys";
          pname   = "yosys";
          version = "0.35";
          src = ./yosys;
          buildInputs = with pkgs; [ clang bison flex libffi tcl readline python3 llvmPackages.libcxxClang zlib git ];
          checkInputs = with pkgs; [ gtest ];
          propagatedBuildInputs = with pkgs; [ abc-verifier ];
          preConfigure = "make config-clang";
          checkTarget = "test";
          installPhase = ''
            make install PREFIX=$out
          '';
          meta = with pkgs.lib; {
            description = "Yosys Open SYnthesis Suite";
            homepage = "https://yosyshq.net/yosys/";
            license = licenses.isc;
            maintainers = with maintainers; [ ];
          };
        };
      in {
        packages.default = customYosys;
        defaultPackage = customYosys;
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ clang bison flex libffi tcl readline python3 llvmPackages.libcxxClang zlib git gtest abc-verifier nix-update-source ];
        };
      }
    );
}
