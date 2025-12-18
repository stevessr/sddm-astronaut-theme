{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "sddm-astronaut-theme";
  version = "1.3";

  src = ./.;

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
    cp metadata.desktop $out/share/sddm/themes/sddm-astronaut-theme/

    # Install fonts
    mkdir -p $out/share/fonts
    cp -r Fonts/* $out/share/fonts/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Modern, customizable SDDM theme with virtual keyboard support";
    homepage = "https://github.com/Keyitdev/sddm-astronaut-theme";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
