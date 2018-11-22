{ nixpkgs ? null }:

let
  nixpkgsSrc =
    if isNull nixpkgs
      then
        builtins.fetchTarball {
          # nixpkgs as of 2018-11-09
          url = "https://github.com/NixOS/nixpkgs/archive/6d7e116d0c164419acc9600e62dd32083324b885.tar.gz";
          sha256 = "1ax9bz4wmwhg7pcd896y8hbnraia7qassvmc53m6a1d40129k954";
        }
      else nixpkgs;
  pkgs = import nixpkgsSrc { config = { allowUnfree = true; }; };
in
with pkgs;

# let
#   pythonEnv = pkgs.python3.buildEnv.override {
#     extraLibs = with pkgs.python3Packages; [
#       pytorch
#     ];
#     # ignoreCollisions = true;
#   };
# in
# pkgs.stdenv.mkDerivation {
#   name = "pytorch-env";
#   buildInputs = [pythonEnv];
#   shellHook = ''
#     export LANG=en_US.UTF-8
#     export PYTHONIOENCODING=UTF-8
#   '';
# }

let
  torchfile = python3.pkgs.buildPythonPackage rec {
    pname = "torchfile";
    version = "0.1.0";

    src = python35.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "0vhklj6krl9r0kdynb4kcpwp8y1ihl2zw96byallay3k9c9zwgd5";
    };
  };

  visdom = python3.pkgs.buildPythonPackage rec {
    pname = "visdom";
    version = "0.1.8.5";

    src = python35.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "0sqkd5c7b43q7n7xz4x0rby28hq222h550skw9q6v1aanvswrbz9";
    };

    propagatedBuildInputs = with python3.pkgs; [
      pillow
      pyzmq
      numpy
      scipy
      requests
      torchfile
      tornado
      websocket_client
    ];
  };

  pyWithPytorch = python3.withPackages (ps: with ps; [
    dominate
    pytorch
    torchvision
    visdom
  ]);
in

pyWithPytorch.env
