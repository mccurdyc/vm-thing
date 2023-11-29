# https://nixos.wiki/wiki/Flakes#Super_fast_nix-shell
{ pkgs, system }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    google-cloud-sdk
    nixpkgs-fmt
    nixd
    shfmt
    statix
  ];
}
