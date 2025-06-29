{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  };

  outputs = { self, nixpkgs }: 
  let
      # Declare the system
    system = "x86_64-linux";
    # Use a system-specific version of Nixpkgs
    pkgs = import nixpkgs { inherit system; };
    in {

    packages.x86_64-linux.default = pkgs.callPackage ./package.nix { };

  };
}
