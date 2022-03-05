{ pkgs ? import <nixos-unstable> { } }:

pkgs.mkShell { nativeBuildInputs = [ pkgs.elixir_1_13 pkgs.toxiproxy ]; }
