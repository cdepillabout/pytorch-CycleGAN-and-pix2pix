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

let
  torchfile = python3.pkgs.buildPythonPackage rec {
    pname = "torchfile";
    version = "0.1.0";

    src = python35.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "0vhklj6krl9r0kdynb4kcpwp8y1ihl2zw96byallay3k9c9zwgd5";
    };
  };

  pyWithPytorch = (python3.withPackages (ps: with ps; [
    dominate
    pip
    pytorch
    torchvision
    virtualenv

    # visdom deps
    pillow
    pyzmq
    numpy
    scipy
    requests
    torchfile
    tornado
    websocket_client
  ]));
in

mkShell {
  name = "my-env";
  inputsFrom = [
    pyWithPytorch.env
    taglib
    openssl
    git
    libxml2
    libxslt
    libzip
    stdenv
    zlib
  ];
  shellHook = ''
    # Need to set the source date epoch to 1980 because python's zip thing is terrible?
    export SOURCE_DATE_EPOCH=315532800

    # If the .env virtualenv does not exist, then create it.
    if [ ! -d ".env" ]; then
      echo "Creating virtualenv..."
      echo
      virtualenv .env
      echo
    fi

    # Make sure to always activate the virtualenv.
    source .env/bin/activate

    # Check to make sure visdom is installed, and if not, then install it.
    # Note that visdom can't be installed through nix easily because the
    # visdom server downloads files and puts them in its path at runtime.
    # This frustrates me to no end.
    if ! pip show visdom >/dev/null ; then
      echo "Installing visdom..."
      echo
      pip install 'visdom>=0.1.8.3'
    fi
  '';
}
