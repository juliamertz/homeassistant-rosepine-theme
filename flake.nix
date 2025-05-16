{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";

    rose-pine-build = {
      url = "github:juliamertz/rose-pine-build?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    systems,
    rose-pine-build,
    ...
  }: let
    forAllSystems = function:
      nixpkgs.lib.genAttrs (import systems) (system:
        function nixpkgs.legacyPackages.${system});
  in {
    packages = forAllSystems ({
      stdenvNoCC,
      system,
      ...
    }: {
      default = stdenvNoCC.mkDerivation {
        name = "homeassistant-rose-pine";

        src = ./template.yaml;
        dontUnpack = true;

        nativeBuildInputs = [rose-pine-build.packages.${system}.default];

        buildPhase = ''
          rose-pine-build $src --format rgb-function -o .

          sed -i '1,3d' dawn.yaml
          echo "    light:" >> main.yaml
          cat dawn.yaml >> main.yaml
          echo "    light:" >> moon.yaml
          cat dawn.yaml >> moon.yaml
        '';

        installPhase = ''
          mkdir -p $out/rose-pine
          mkdir -p $out/rose-pine-moon
          mv main.yaml $out/rose-pine/rose-pine.yaml
          mv moon.yaml $out/rose-pine-moon/rose-pine-moon.yaml
        '';
      };
    });
  };
}
