{
  mdbook-nixdoc,
  mdbook-mermaid,
  mdbook,
  nixdoc,
  runCommandNoCCLocal,
}:
runCommandNoCCLocal "docs"
  {
    name = "regula-nix-docs";
    src = ../.;

    nativeBuildInputs = [
      mdbook-nixdoc
      nixdoc
      mdbook-mermaid
      mdbook
    ];
  }
  ''
    mkdir -p $out
    cd $src/docs
    mdbook build --dest-dir $out
  ''
