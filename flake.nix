{
  description = "Chinook database (SQLite version)";
  inputs = {
    devshell = { url = "github:numtide/devshell/f55e05c";  inputs.nixpkgs.follows = "nixpkgs"; }; # 2022-06-10
    flake-utils.url  = "github:numtide/flake-utils/v1.0.0";
    nixpkgs.url      = "github:NixOS/nixpkgs/22.05";
  };
  outputs = { self, devshell, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let version = "0.0.1";
          datadir = "data/sqlite";
          chindb  = "${datadir}/chinook.db";
          northdb = "${datadir}/northwind.db";
      in
      rec {
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ devshell.overlay ];
        };
        sqlite = pkgs.sqlite;
        packages = rec {
          default = sqlite-chinook;
          sqlite-chinook = pkgs.stdenv.mkDerivation {
            inherit chindb sqlite system version;
            pname = "chinook-sqlite";
          src = builtins.fetchGit {
              url = "https://github.com/lerocha/chinook-database";
              rev = "e7e6d5f008e35d3f89d8b8a4f8d38e3bfa7e34bd";
            };
            installPhase = ''
              data_dir=$out/data/sqlite
              mkdir -p $data_dir
              $sqlite/bin/sqlite3 -init $src/ChinookDatabase/DataSources/Chinook_Sqlite.sql $out/$chindb
            '';
          };
          sqlite-northwind = pkgs.stdenv.mkDerivation {
            inherit northdb sqlite system datadir;
            pname = "northwind-sqlite";
            version = "0.0.1";
            src = builtins.fetchGit {
              url = "https://github.com/jpwhite3/northwind-SQLite3";
              rev = "46d5f8a64f396f87cd374d1600dbf521523980e8";
            };
            installPhase = ''
              mkdir -p $out/$datadir
              $sqlite/bin/sqlite3 -init $src/Northwind.Sqlite3.create.sql $out/$northdb
            '';
          };
        };
        #--------------------------------------------------------------------------------
        # DevShell
        #--------------------------------------------------------------------------------
        devShell = self.devShells.${system}.default;
        devShells.default =
          with pkgs;
          pkgs.devshell.mkShell {
            commands = let
              cat = "Build SQLite databases";
            in [{name = "build-all";
                 help = "Build all available databases";
                 command = "build-chinook; build-northwind";
                 category = cat;}
                {name = "build-chinook";
                 help = "Build Chinook database";
                 command = ''
                   nix build .#sqlite-chinook && \
                   install -m644 result/${chindb} . && \
                   rm -f result
                   echo "Created database: $(basename ${chindb})"
                 '';
                 category = cat;}
                {name = "build-northwind";
                 help = "Build Norhtwind database";
                 command = ''
                   nix build .#sqlite-northwind && \
                   install -m644 result/${northdb} . && \
                   rm -f result
                   echo "Created database: $(basename ${northdb})"
                 '';
                 category = cat;}
                {name = "rm-all";
                 help = "Remove .db files in current directory";
                 command = "rm -f *.db";}];
          };
      });
}
