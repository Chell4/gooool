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
        overlays = [ 
          (import rust-overlay)
        ];
      };

      rustSrc = pkgs.rust-bin.stable.latest.rust-src;
      rustToolchain = pkgs.rust-bin.stable.latest.default;

      craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchain;

      src = craneLib.cleanCargoSource (craneLib.path ./.);

      buildDeps = with pkgs; [
        cmake
        makeWrapper
      ];

      runtimeDeps = with pkgs; [
        libGL
        xorg.libX11
        xorg.libXinerama
        xorg.libXcursor
        xorg.libXi
        xorg.libXrandr
      ];

      commonArgs = {
        inherit src;
        
        strictDeps = true;

        stdenv = pkgs.clangStdenv;

        cargoVendorDir = craneLib.vendorMultipleCargoDeps {
          inherit (craneLib.findCargoFiles src) cargoConfigs;
          cargoLockList = [
            ./Cargo.lock
            "${rustToolchain.passthru.availableComponents.rust-src}/lib/rustlib/src/rust/Cargo.lock"
          ];
        };

        LIBCLANG_PATH="${pkgs.libclang.lib}/lib";         

        buildInputs = runtimeDeps;
        nativeBuildInputs = buildDeps;
      };

      goooolCrate = craneLib.buildPackage (commonArgs // rec { 

        pname = "gooool";

        cargoArtifacts = craneLib.buildDepsOnly commonArgs; 

        postInstall = ''
          wrapProgram $out/bin/${pname} \
            --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath runtimeDeps}
        '';
      });
    in 
    {
      checks = {
        inherit goooolCrate;
      };

      packages.default = goooolCrate;

      apps.default = flake-utils.lib.mkApp { drv = goooolCrate; };

      devShells.default = pkgs.mkShell.override { stdenv = pkgs.stdenvAdapters.useMoldLinker pkgs.clangStdenv; }
        {
          #checks = self.checks.${system};
          
          inherit (commonArgs) LIBCLANG_PATH;

          RUST_SRC_PATH = rustSrc;

          buildInputs = runtimeDeps;

          nativeBuildInputs = buildDeps
            ++ (with pkgs; [
                pkg-config
                openssl
                rustToolchain
            ]);
        
          shellHook = ''
            mkdir -p .vscode

            if [[ ! -e .vscode/settings.json ]] || [[ $(cat .vscode/settings.json | tr -d '[:space:]') == "" ]]; then
              echo "{}" > .vscode/settings.json
            fi

            ${pkgs.jq}/bin/jq ". + { 
                \"rust-analyzer.cargo.sysrootSrc\": \"${rustSrc}/lib/rustlib/src/rust/library/\"
              }" \
              < .vscode/settings.json \
              | ${pkgs.moreutils}/bin/sponge .vscode/settings.json
          '';
        };
    });
}
