{
  description = "LaTeX's article class, reproduced in Typst to within 0.05pt";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      manifest = (builtins.fromTOML (builtins.readFile ./typst.toml)).package;
    in
    {
      packages = forAllSystems (
        pkgs:
        let
          inherit (pkgs) lib;

          # A Typst package is its manifest plus whatever the entrypoint pulls
          # in. Tests, tools and examples are deliberately not shipped.
          latex-article = pkgs.buildTypstPackage {
            pname = manifest.name;
            inherit (manifest) version;
            src = lib.fileset.toSource {
              root = ./.;
              fileset = lib.fileset.unions [
                ./typst.toml
                ./src
                ./LICENSE
                ./README.md
              ];
            };
            meta = {
              inherit (manifest) description;
              homepage = "https://github.com/kmein/typst-tex";
              license = lib.licenses.mit;
              platforms = lib.platforms.all;
            };
          };

          # The template prefers Latin Modern -- the OpenType descendant of
          # Computer Modern -- over the New Computer Modern bundled in the
          # Typst binary. A build sandbox has no system fonts, so say where
          # they are. (`portable: true` avoids needing this, at a small cost in
          # fidelity.)
          fontPaths = [ "${pkgs.lmodern}/share/fonts/opentype" ];

          # typst, with this package importable as @preview/latex-article and
          # Latin Modern already on the font path.
          typst = pkgs.typst.passthru.wrapper {
            packages = _: [ latex-article ];
            fonts = fontPaths;
          };
        in
        {
          default = latex-article;
          inherit latex-article typst;

          # The 23-page worked example, built from source. Doubles as proof
          # that the template compiles without a system font config.
          tea = pkgs.stdenvNoCC.mkDerivation {
            pname = "tea";
            inherit (manifest) version;
            src = lib.fileset.toSource {
              root = ./.;
              fileset = lib.fileset.unions [
                ./typst.toml
                ./src
                ./examples/tea
              ];
            };
            nativeBuildInputs = [ typst ];
            buildPhase = ''
              runHook preBuild
              typst compile --root . examples/tea/tea.typ tea.pdf
              runHook postBuild
            '';
            installPhase = ''
              runHook preInstall
              install -Dm644 tea.pdf $out/share/doc/${manifest.name}/tea.pdf
              runHook postInstall
            '';
            meta = {
              description = "How to Keep a Cup of Tea Warm";
              license = lib.licenses.mit;
              platforms = lib.platforms.all;
            };
          };
        }
      );

      # `nix flake check` runs the real thing: compile the same content through
      # pdflatex and Typst, rasterise both at 300 DPI, and diff per pixel.
      checks = forAllSystems (
        pkgs:
        let
          inherit (pkgs) lib;
        in
        {
          comparison = pkgs.stdenvNoCC.mkDerivation {
            name = "latex-article-comparison-tests";
            src = lib.fileset.toSource {
              root = ./.;
              fileset = lib.fileset.unions [
                ./typst.toml
                ./src
                ./tests
                ./tools
              ];
            };
            nativeBuildInputs = [
              self.packages.${pkgs.stdenv.hostPlatform.system}.typst
              pkgs.texliveSmall
              pkgs.poppler-utils
              pkgs.imagemagick
              pkgs.python3
            ];
            dontInstall = true;
            buildPhase = ''
              runHook preBuild
              export HOME=$TMPDIR
              export COMPARE_OUT=$TMPDIR/build
              patchShebangs tools
              tools/check.sh | tee $TMPDIR/report
              mkdir -p $out
              cp $TMPDIR/report $out/report
              runHook postBuild
            '';
          };
        }
      );

      devShells = forAllSystems (pkgs: {
        # Everything the harness needs: both engines, a rasteriser, a pixel
        # differ and a PDF prober.
        default = pkgs.mkShell {
          packages = [
            self.packages.${pkgs.stdenv.hostPlatform.system}.typst
            pkgs.texliveSmall
            pkgs.poppler-utils
            pkgs.imagemagick
            pkgs.mupdf
            pkgs.python3
          ];
          shellHook = ''
            echo "latex-article: tools/check.sh runs the comparison suite."
          '';
        };
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-tree or pkgs.nixfmt-rfc-style);
    };
}
