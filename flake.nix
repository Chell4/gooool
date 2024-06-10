{
  description = "Game of Life (and maybe more cellular automata)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { self, nixpkgs, flake-utils, crane, rust-overlay }: 
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ (import rust-overlay) ];
      };

      rustToolchain = pkgs.rust-bin.stable.latest.default;

      craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchain;

      src = craneLib.cleanCargoSource (craneLib.path ./.);

      gooool-crate = craneLib.buildPackage {
        inherit src;
        
        strictDeps = true;

        cargoVendorDir = craneLib.vendorMultipleCargoDeps {
          inherit (craneLib.findCargoFiles src) cargoConfigs;
          cargoLockList = [
            ./Cargo.lock
            "${rustToolchain.passthru.availableComponents.rust-src}/lib/rustlib/src/rust/Cargo.lock"
          ];
        };

        buildInputs = [
          
        ];
      };
    in 
    {
      checks = {
        inherit gooool-crate;
      };

      packages.default = gooool-crate;
      
      devShells = {
        default = craneLib.devShell {
          checks = self.checks.${system};
          packages = [
            
          ];
        };
      };
    });
}
