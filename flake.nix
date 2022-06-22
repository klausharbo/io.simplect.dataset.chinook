{
  description = "Chinook database (SQLite version)";
  inputs = {
    flake-utils.url  = "github:numtide/flake-utils/v1.0.0";
    nixpkgs.url      = "github:NixOS/nixpkgs/22.05";
  };
  outputs = { self, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      rec {
        pkgs = import nixpkgs { inherit system; };

        packages =  rec {
          sqlite = pkgs.stdenv.mkDerivation {
            inherit system;
            sqlite = pkgs.sqlite;
            pname = "chinook-database-sqlite";
            version = "0.0.1";
            src = builtins.fetchGit {
              url = "https://github.com/lerocha/chinook-database";
              rev = "e7e6d5f008e35d3f89d8b8a4f8d38e3bfa7e34bd";
            };
            installPhase = ''
              data_dir=$out/data/sqlite
              mkdir -p $data_dir
              $sqlite/bin/sqlite3 -init $src/ChinookDatabase/DataSources/Chinook_Sqlite.sql $data_dir/chinook-sqlite3.db
            '';
          };
          default = sqlite;
        };
      });
}
