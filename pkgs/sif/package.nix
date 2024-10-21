{
  lib,
  singularity-tools,
  jplag,
}:

singularity-tools.buildImage {
  name = jplag.name;
  contents = [ jplag ];
  runScript = lib.getExe jplag; # FIXME: https://github.com/NixOS/nixpkgs/pull/224636#issuecomment-2427104927
  diskSize = 6 * 1024; # MB, shrunk after build
  memSize = 2048; # MB, has effect on compression
}
