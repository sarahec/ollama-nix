{
  description = "Workspace for experimenting with ML performance on NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
    nixpkgs-python.url = "github:cachix/nixpkgs-python";
    ml-pkgs = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nixvital/ml-pkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://cuda-maintainers.cachix.org"
      "https://devenv.cachix.org"
      "https://nix-community.cachix.org"
    ];

    extra-trusted-public-keys = [
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  outputs = inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
      ];
      #     flake.overlays.default = nixpkgs.lib.composeManyExtensions [
      #       inputs.ml-pkgs.overlays.torch-family
      #     ];

      systems = [ "x86_64-linux" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: 
      let 
        ollama = inputs.nixpkgs.ollama.override {
          enableCuda = true;
        };
      in {
        # This sets `pkgs` to a nixpkgs with allowUnfree option set.
        _module.args.pkgs = import nixpkgs {
          inherit system;
          #            overlays = [ inputs.self.overlays.default ];
          config = {
            allowUnfree = true;
            allowBroken = false;
            cudaSupport = false;
          };
        };

        devenv.shells.default = {

          # imports = [
          #   # This is just like the imports in devenv.nix.
          #   # See https://devenv.sh/guides/using-with-flake-parts/#import-a-devenv-module
          #   # ./devenv-foo.nix
          # ];

          # https://devenv.sh/reference/options/
          languages.nix.enable = true;


          # languages.python = {
          #   enable = true;
          #   package = (pkgs.python311.withPackages (ps: [
          #     # ps.cupy
          #     ps.cython_3
          #     ps.ijson
          #     ps.jsonlines
          #     ps.orjson
          #     ps.pip
          #     ps.pytest
          #     scalene
          #     ps.setuptools
          #     ps.tqdm
          #     spacy
          #     spacy-en-core-web-sm
          #   ])).override
          #     (args: { ignoreCollisions = true; }); # old cython and new cython_3 collide
          #   venv = {
          #     enable = true;
          #     quiet = true;
          #     requirements = ''
          #       austin-dist
          #     '';
          #   };
          # };

          packages = [
            pkgs.ollama
          ];

          scripts = {
          };


          # NIX_LD_LIBRARY_PATH = pkgs.makeLibraryPath [
          #   pkgs.stdenv.cc.cc
          #   pkgs.zlib
          # ];
          # NIX_LD = pkgs.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
          # buildInputs = [ pkgs.python311 ];

          enterShell = ''
          '';
        };

      };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}
