{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    rosepine-build = {
      url = "github:juliamertz/rosepine-buildrs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { nixpkgs, ... }@inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      perSystem =
        {
          config,
          pkgs,
          lib,
          system,
          ...
        }:
        let
          rosePineBuild = inputs.rosepine-build.packages.${system}.default;
        in
        {
          packages.default = pkgs.stdenv.mkDerivation {
            name = "homeassistant-rose-pine";
            src = ./.;
            buildPhase = ''
              ${lib.getExe rosePineBuild} ${./template.yaml} --format rgb-function -o $out

              sed -i '1,3d' $out/dawn.yaml
              append_dawn() {
                echo "    light:" >> $1
                tmp=$(mktemp)
                cat $1 $out/dawn.yaml > $tmp
                cat $tmp > $1
                rm $tmp
              }

              append_dawn $out/main.yaml
              append_dawn $out/moon.yaml
              rm $out/dawn.yaml

              mkdir $out/rose-pine
              mkdir $out/rose-pine-moon
              mv $out/main.yaml $out/rose-pine/rose-pine.yaml
              mv $out/moon.yaml $out/rose-pine-moon/rose-pine-moon.yaml
            '';
          };

          devShells.default = pkgs.mkShell {
            packages = [
              rosePineBuild
            ];
          };
        };
    };
}
