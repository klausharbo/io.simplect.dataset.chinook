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
          sqlite3 = derivation {
            name = "chinook-sqlite3";
            src = ./.;
            builder = pkgs.runtimeShell;
            args = ["-c" "echo" "Guten Tag!"];
          };
          default = sqlite3;
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
