{ lib
, python3Packages
, stashsphere-openapi
, stdenv
,
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
    mkdocs-swagger-ui-tag
    python
  ];

  buildPhase = ''
    cp ${stashsphere-openapi}/openapi.json docs/assets/.
    mkdocs build --strict -d $out
  '';

  dontConfigure = true;
  doCheck = false;
  dontInstall = true;
}
