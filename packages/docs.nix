{
  mdbook-mermaid,
  mdbook,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  name = "regula-nix-docs";
  src = ../docs;
  nativeBuildInputs = [
    mdbook-mermaid
    mdbook
  ];
  buildPhase = ''
    mdbook build --dest-dir $out
  '';
}
