{
  pkgs ? import <nixpkgs> { },
  newScope ? pkgs.newScope,
  lib ? pkgs.lib,
}:

lib.makeScope newScope (self: {
  default = self.jplag;
  jplag = self.callPackage ./pkgs/jplag/package.nix { };
  sif = self.callPackage ./pkgs/sif/package.nix { };
})
