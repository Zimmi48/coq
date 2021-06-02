{ lib, stdenv, hostname, writeText
, ocamlPackages, python3, time, flock, glib, wrapGAppsHook, pkgconfig
, antlr4, ncurses, rsync, which, jq, curl, gitFull, gnupg, graphviz, gnome3
, buildIde ? true
, buildDoc ? true
, doInstallCheck ? true
, shell ? true
, pname ? "coq-full"
, coq-version ? "8.14-git"
, ...
}:

#with pkgs;
with lib;

stdenv.mkDerivation rec {

  inherit pname;
  version = "dev";

  buildInputs = [
    hostname
    python3 time # coq-makefile timing tools
    flock ocamlPackages.dune_2
  ]
  ++ optionals buildIde [
    ocamlPackages.lablgtk3-sourceview3
    glib gnome3.defaultIconTheme wrapGAppsHook
  ]
  ++ optionals buildDoc [
    # Sphinx doc dependencies
    pkgconfig (python3.withPackages
      (ps: [ ps.sphinx ps.sphinx_rtd_theme ps.pexpect ps.beautifulsoup4
             ps.antlr4-python3-runtime ps.sphinxcontrib-bibtex ]))
    antlr4
    ocamlPackages.odoc
  ]
  ++ optionals doInstallCheck (
    # Test-suite dependencies
    # ncurses is required to build an OCaml REPL
    optional (!versionAtLeast ocamlPackages.ocaml.version "4.07") ncurses
    ++ [ ocamlPackages.ounit rsync which ]
  )
  ++ optionals shell (
    [ jq curl gitFull gnupg ] # Dependencies of the merging script
    ++ (with ocamlPackages; [ merlin ocp-indent ocp-index utop ]) # Dev tools
    ++ [ graphviz ] # Useful for STM debugging
  );

  # OCaml and findlib are needed so that native_compute works
  # This follows a similar change in the nixpkgs repo (cf. NixOS/nixpkgs#101058)
  # ocamlfind looks for zarith when building plugins
  # This follows a similar change in the nixpkgs repo (cf. NixOS/nixpkgs#94230)
  propagatedBuildInputs = with ocamlPackages; [ ocaml findlib zarith ];
  ocamlBuildInputs = propagatedBuildInputs;

  propagatedUserEnvPkgs = with ocamlPackages; [ ocaml findlib ];

  src =
    with builtins; filterSource
      (path: _:
        !elem (baseNameOf path) [".git" "result" "bin" "_build" "_build_ci" "_build_vo" ".nix"]) ../../..;

  preConfigure = ''
    patchShebangs dev/tools/ doc/stdlib
  '';

  prefixKey = "-prefix ";

  enableParallelBuilding = true;

  buildFlags = [ "world" "byte" ] ++ optional buildDoc "doc-html";

  preInstall = ''
    mkdir -p "$OCAMLFIND_DESTDIR"
  '';

  installTargets =
    [ "install" "install-byte" ] ++ optional buildDoc "install-doc-html";

  postInstall = "ln -s $out/lib/coq-core $OCAMLFIND_DESTDIR/coq-core";

  inherit doInstallCheck;

  preInstallCheck = ''
    patchShebangs tools/
    patchShebangs test-suite/
    export OCAMLPATH=$OCAMLFIND_DESTDIR:$OCAMLPATH
  '';

  installCheckTarget = [ "check" ];

  passthru = {
    inherit coq-version ocamlPackages;
    dontFilter = true; # Useful to use mkCoqPackages from <nixpkgs>
  };

  setupHook = writeText "setupHook.sh" "
    addCoqPath () {
      if test -d \"$1/lib/coq/${coq-version}/user-contrib\"; then
        export COQPATH=\"\${COQPATH-}\${COQPATH:+:}$1/lib/coq/${coq-version}/user-contrib/\"
      fi
    }

    addEnvHooks \"$targetOffset\" addCoqPath
  ";

  meta = {
    description = "Coq proof assistant";
    longDescription = ''
      Coq is a formal proof management system.  It provides a formal language
      to write mathematical definitions, executable algorithms and theorems
      together with an environment for semi-interactive development of
      machine-checked proofs.
    '';
    homepage = http://coq.inria.fr;
    license = licenses.lgpl21;
    platforms = platforms.unix;
  };

}
