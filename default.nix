{ pkgs ? import <nixpkgs> {}
, stdenv ? pkgs.stdenv
, git ? pkgs.git
, ncurses ? pkgs.ncurses
, which ? pkgs.which
, utillinux ? pkgs.utillinux
, file ? pkgs.file
, makeWrapper ? pkgs.makeWrapper }:

stdenv.mkDerivation {
  name = "git-powercommit";
  src = ./.;

  checkInputs = [ git ncurses which utillinux file ];
  nativeBuildInputs = [ makeWrapper ];

  doCheck = true;
  checkPhase = ''
    export GIT_USER="Test User"
    export GIT_COMMITTER_EMAIL="nobody@nowhere.com"
    export GIT_AUTHOR_EMAIL="nobody@nowhere.com"
    $src/test.sh
  '';

  installPhase = ''
    mkdir -pv $out/bin
    cp $src/git-powercommit $out/bin
    wrapProgram $out/bin/git-powercommit \
      --prefix PATH : "${which}/bin" \
      --prefix PATH : "${git}/bin" \
      --prefix PATH : "${ncurses}/bin" \
      --prefix PATH : "${utillinux}/bin" \
      --prefix PATH : "${file}/bin" \
  '';
}
