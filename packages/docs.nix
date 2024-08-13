{ mdbook-mermaid, mdbook, stdenv }:
stdenv.mkDerivation {
  name = "regula-nix-docs";
  src = ../docs;
  nativeBuildInputs = [ mdbook-mermaid mdbook ];
  buildPhase = ''
    mdbook build --dest-dir $out
  '';
}
