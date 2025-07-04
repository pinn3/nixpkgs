{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  snagboot,
  testers,
  gitUpdater,
  udevCheckHook,
}:

python3Packages.buildPythonApplication rec {
  pname = "snagboot";
  version = "2.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "bootlin";
    repo = "snagboot";
    tag = "v${version}";
    hash = "sha256-JXhh+Ed/ZwytNrMwvGw7jaDBvwDQiUKe+gBDezOCHO4=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  pythonRemoveDeps = [
    "pylibfdt"
    "swig"
  ];

  nativeBuildInputs = [
    udevCheckHook
  ];

  dependencies = with python3Packages; [
    pyyaml
    pyusb
    pyserial
    tftpy
    crccheck
    # pylibfdt
    # swig
    packaging
  ];

  optional-dependencies = with python3Packages; {
    gui = [ kivy ];
  };

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    rules="src/snagrecover/50-snagboot.rules"
    if [ ! -f "$rules" ]; then
        echo "$rules is missing, must update the Nix file."
        exit 1
    fi

    mkdir -p "$out/lib/udev/rules.d"
    cp "$rules" "$out/lib/udev/rules.d/50-snagboot.rules"
  '';

  passthru = {
    updateScript = gitUpdater {
      rev-prefix = "v";
      ignoredVersions = ".(rc|beta).*";
    };

    tests.version = testers.testVersion {
      package = snagboot;
      command = "snagrecover --version";
      version = "v${version}";
    };
  };

  meta = {
    homepage = "https://github.com/bootlin/snagboot";
    description = "Generic recovery and reflashing tool for embedded platforms";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ otavio ];
  };
}
