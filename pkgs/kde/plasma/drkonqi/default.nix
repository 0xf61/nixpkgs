{
  mkKdeDerivation,
  pkg-config,
  systemd,
  gdb,
  python3,
  replaceVars,
}:
let
  gdb' = gdb.override {
    hostCpuOnly = true;
    python3 = python3.withPackages (ps: [
      ps.psutil
      ps.pygdbmi
      ps.sentry-sdk
    ]);
  };
in
mkKdeDerivation {
  pname = "drkonqi";

  patches = [
    (replaceVars ./gdb-path.patch {
      gdb = "${gdb'}/bin/gdb";
    })
  ];

  extraNativeBuildInputs = [ pkg-config ];
  extraBuildInputs = [ systemd ];

  extraCmakeFlags = [
    "-DWITH_GDB12=1"
    "-DWITH_PYTHON_VENDORING=0"
  ];

  # Hardcoded as QString, which is UTF-16 so Nix can't pick it up automatically
  postFixup = ''
    mkdir -p $out/nix-support
    echo "${gdb'}" > $out/nix-support/depends
  '';
}
