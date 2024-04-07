{
  lib,
}:
with lib;
  types.submodule {
    options = {
      enable = mkEnableOption (mdDoc "sccache disk cache");

      cacheDir = mkOption {
        type = types.path;
        description = mdDoc "local on disk artifact cache directory";
        default = "/var/cache/sccache";
      };
      owner = mkOption {
        type = types.str;
        default = "root";
        description = mdDoc "Owner of sccache directory";
      };
      group = mkOption {
        type = types.str;
        default = "nixbld";
        description = mdDoc "Group owner of sccache directory";
      };
      cacheSize = mkOption {
        type = types.bigint;
        default = 1000;
        description = mdDoc "sccache disk cache size in MiB";
      };
      direct = mkOption {
        type = types.bool;
        default = false;
        description = mdDoc "Use preprocessor caching";
      };
    };
  }
