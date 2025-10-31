{ lib
, python3Packages
, stdenv
}:

stdenv.mkDerivation {
  name = "mkdocs-html";

  src = lib.sourceByRegex ../. [
    "^docs.*"
    "^templates.*"
    "mkdocs.yml"
  ];

  nativeBuildInputs = with python3Packages; [
    mkdocs
    mkdocs-material
    python
  ];

  buildPhase = ''
    mkdocs build --strict -d $out
  '';

  dontConfigure = true;
  doCheck = false;
  dontInstall = true;
}
