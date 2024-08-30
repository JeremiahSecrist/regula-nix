{
  mdbook-nixdoc,
  mdbook-mermaid,
  mdbook,
  nixdoc,
  stdenvNoCC,
  lib,
}:
stdenvNoCC.mkDerivation {
  name = "regula-nix-docs";

  src = lib.cleanSource ../.;
  sourceRoot = "source/docs";

  preferLocalBuild = true;
  allowSubstitutes = false;
  dontConfigure = true;
  dontFixup = true;
  env.RUST_BACKTRACE = 1;

  nativeBuildInputs = [
    mdbook-mermaid
    mdbook-nixdoc
    nixdoc
    mdbook
  ];
  buildPhase = ''
    runHook preBuild
    mdbook build
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    mv book $out
    runHook postInstall
  '';
}
