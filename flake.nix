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
          cfg = config.services.displayManager.sddm.astronaut;
          
          # Create theme package with custom variant
          themePackage = pkgs.stdenv.mkDerivation {
            name = "sddm-astronaut-theme-${cfg.variant}";
            src = self;
            
            dontBuild = true;
            
            installPhase = ''
              runHook preInstall

              mkdir -p $out/share/sddm/themes/sddm-astronaut-theme

              # Copy all theme files
              cp -r Assets $out/share/sddm/themes/sddm-astronaut-theme/
              cp -r Backgrounds $out/share/sddm/themes/sddm-astronaut-theme/
              cp -r Components $out/share/sddm/themes/sddm-astronaut-theme/
              cp -r Previews $out/share/sddm/themes/sddm-astronaut-theme/
              cp -r Themes $out/share/sddm/themes/sddm-astronaut-theme/
              cp Main.qml $out/share/sddm/themes/sddm-astronaut-theme/

              # Create custom metadata.desktop with selected variant
              cat > $out/share/sddm/themes/sddm-astronaut-theme/metadata.desktop << EOF
[SddmGreeterTheme]
Name=sddm-astronaut-theme
Description=sddm-astronaut-theme
Author=keyitdev
Website=https://github.com/Keyitdev/sddm-astronaut-theme
License=GPL-3.0-or-later
Type=sddm-theme
Version=1.3
ConfigFile=Themes/${cfg.variant}.conf
Screenshot=Previews/${cfg.variant}.png
MainScript=Main.qml
TranslationsDirectory=translations
Theme-Id=sddm-astronaut-theme
Theme-API=2.0
QtVersion=6
EOF

              # Install fonts
              mkdir -p $out/share/fonts
              cp -r Fonts/* $out/share/fonts/

              runHook postInstall
            '';
          };
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

          config = mkIf cfg.enable {
            environment.systemPackages = [ themePackage ];
            
            services.displayManager.sddm = {
              enable = true;
              theme = "sddm-astronaut-theme";
              settings = {
                General = {
                  InputMethod = "qtvirtualkeyboard";
                };
              };
            };
          };
        };
    };
}
