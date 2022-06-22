{
  description = "Remorph";
  inputs = {
    devshell = { url = "github:numtide/devshell/f55e05c";  inputs.nixpkgs.follows = "nixpkgs"; }; # 2022-06-10
    flake-utils.url  = "github:numtide/flake-utils/v1.0.0";
    nixpkgs.url      = "github:NixOS/nixpkgs/22.05";
  };
  outputs = { self, devshell, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      rec {
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ devshell.overlay ];
        };

        #--------------------------------------------------------------------------------
        # Packages
        #--------------------------------------------------------------------------------
        packages =  rec {
          sqlite = pkgs.stdenv.mkDerivation {
            inherit system;
            sqlite = pkgs.sqlite;
            name = "chinook-sqlite";
            src = builtins.fetchGit {
              url = "https://github.com/lerocha/chinook-database";
              ref = "master";
              rev = "e7e6d5f008e35d3f89d8b8a4f8d38e3bfa7e34bd";
            };
            installPhase = ''
              mkdir $out
              $sqlite/bin/sqlite3 -init $src/ChinookDatabase/DataSources/Chinook_Sqlite.sql $out/chinook-sqlite3.db
            '';
          };
          default = sqlite;
        };

        #--------------------------------------------------------------------------------
        # DevShell
        #--------------------------------------------------------------------------------
        devShell = self.devShells.${system}.default;
        devShells.default =
          with pkgs;
          pkgs.devshell.mkShell {
            packages = [
              curl
              git
              ripgrep
              tree
              unixtools.top
              unixtools.watch
              wget
            ];
            commands =
                [];
          };
      });
}
