{
  description = "Modern SDDM theme with multiple variants and virtual keyboard support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          default = pkgs.callPackage ./default.nix { };
          sddm-astronaut-theme = pkgs.callPackage ./default.nix { };
        };
      }
    ) // {
      # NixOS module for easy system configuration
      nixosModules.default = { config, lib, pkgs, ... }:
        with lib;
        let
          cfg = config.services.displayManager.sddm.theme;
          themePkg = self.packages.${pkgs.system}.default;
        in
        {
          options.services.displayManager.sddm.astronaut = {
            enable = mkEnableOption "SDDM Astronaut Theme";
            
            variant = mkOption {
              type = types.enum [
                "astronaut"
                "black_hole"
                "cyberpunk"
                "hyprland_kath"
                "jake_the_dog"
                "japanese_aesthetic"
                "pixel_sakura"
                "pixel_sakura_static"
                "post-apocalyptic_hacker"
                "purple_leaves"
              ];
              default = "astronaut";
              description = "Theme variant to use";
            };
          };

          config = mkIf config.services.displayManager.sddm.astronaut.enable {
            environment.systemPackages = [ themePkg ];
            
            services.displayManager.sddm = {
              enable = true;
              theme = "sddm-astronaut-theme";
              settings = {
                General = {
                  InputMethod = "qtvirtualkeyboard";
                };
              };
            };

            # Update metadata.desktop to select the chosen variant
            environment.etc."sddm/themes/sddm-astronaut-theme/metadata.desktop".text = mkAfter ''
              ConfigFile=Themes/${config.services.displayManager.sddm.astronaut.variant}.conf
            '';
          };
        };
    };
}
