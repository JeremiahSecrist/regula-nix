{
  mdbook,
  stdenv
}: stdenv.mkDerivation {
  name = "regula-nix-docs";
  src = ../docs;
  nativeBuildInputs = [ mdbook ];
  buildPhase =
    ''
      mdbook build --dest-dir $out
    '';
}