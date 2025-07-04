{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cairo,
  gdk-pixbuf,
  glib,
  libinput,
  libxml2,
  pango,
  udev,
  udevCheckHook,
}:

rustPlatform.buildRustPackage rec {
  pname = "tiny-dfr";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "WhatAmISupposedToPutHere";
    repo = "tiny-dfr";
    rev = "v${version}";
    hash = "sha256-5u5jyoDEt7aMs8/8QrhrUrUzFJJCNayqbN2WrMhUCV4=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-9UlH2W8wNzdZJxIgOafGylliS2RjaBlpirxSWHJ/SIQ=";

  nativeBuildInputs = [
    pkg-config
    udevCheckHook
  ];
  buildInputs = [
    cairo
    gdk-pixbuf
    glib
    libinput
    libxml2
    pango
    udev
  ];

  postConfigure = ''
    substituteInPlace etc/systemd/system/tiny-dfr.service \
        --replace-fail /usr/bin $out/bin
    substituteInPlace src/*.rs --replace-quiet /usr/share $out/share
  '';

  postInstall = ''
    cp -R etc $out/lib
    cp -R share $out
  '';

  doInstallCheck = true;

  meta = with lib; {
    homepage = "https://github.com/WhatAmISupposedToPutHere/tiny-dfr";
    description = "Most basic dynamic function row daemon possible";
    license = [
      licenses.asl20
      licenses.mit
    ];
    mainProgram = "tiny-dfr";
    maintainers = [ maintainers.qyliss ];
    platforms = platforms.linux;
  };
}
