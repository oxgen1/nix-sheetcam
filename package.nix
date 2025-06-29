 { stdenv, 
 lib, 
 fetchurl, 
 autoPatchelfHook,
 makeWrapper,
 bubblewrap,
 wxGTK31,
 gtk3,
 librsvg,
 wrapGAppsHook3,
 buildFHSEnv,
 libGLU,
 cairo,
 pango,
}:
let 
  libs = [
    stdenv.cc.cc.lib
    wxGTK31
    gtk3
    libGLU
    cairo
    pango
    librsvg
  ];

  sheetcam-dist = stdenv.mkDerivation rec {
    pname = "sheet-cam";
    version = "7.1.20-1";

    src = fetchurl {
      url = "https://www.sheetcam.com/Downloads/akp3fldwqh/SheetCamTNG_${version}_amd64.deb";
      hash = "sha256-osuinOIP+gPpkHQgka9WwHT4IllwxrqzCH7SO8J5uiY=";
    };
    # nativeBuildInputs = [autoPatchelfHook];
    buildInputs = libs;

    unpackPhase = ''
      ar x ${src}
      tar xf data.tar.xz
     '';

  dontFixup = true;

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/lib
    mkdir -p $out/share
    cp -r usr/lib/ $out
    cp -r usr/bin $out
    cp -r usr/share/ $out

   

    # patchelf \
    #   --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
    #   --set-rpath "${lib.makeLibraryPath libs}:$out/lib/SheetCamTNG-dev" \
    #   $out/bin/SheetCamTNG-dev
  '';

  };

  fhsEnv = buildFHSEnv {
    pname = "${sheetcam-dist.pname}-fhs-env";
    inherit (sheetcam-dist) version;
    runScript = ''
     # export GDK_BACKEND x11; 
      ${sheetcam-dist}/bin/SheetCamTNG-dev
    '';
    targetPkgs = pkgs: with pkgs; [
      glib
      xorg.libXrandr
      xdg-utils
      wxGTK31
      gtk2
      cairo
      pango
      librsvg
      gdk-pixbuf
      xorg.libX11
      xorg.libXxf86vm
      xorg.libSM
      xorg.libXtst
      fontconfig
      sheetcam-dist
      libGL
      gdb
    ];
  };
  

in stdenv.mkDerivation {

  pname = "sheet-cam";
  inherit (sheetcam-dist) version;
  nativeBuildInputs = [ makeWrapper  ];
  buildInputs = [sheetcam-dist];
  phases = [ "installPhase" ];
  installPhase = ''

  makeWrapper ${fhsEnv}/bin/${fhsEnv.pname} $out/bin/SheetCamTNG-dev-r \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libs}:${sheetcam-dist}/lib/SheetCamTNG-dev:/usr/lib/SheetCamTNG-dev" \
        --set GDK_BACKEND x11
  '';
}