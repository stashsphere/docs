{ lib
, mkdocs
, mkdocs-material
, python
, stdenv
}:

stdenv.mkDerivation {
  name = "mkdocs-html";

  src = lib.sourceByRegex ./. [
    "^docs.*"
    "^templates.*"
    "mkdocs.yml"
  ];

  nativeBuildInputs = [
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
