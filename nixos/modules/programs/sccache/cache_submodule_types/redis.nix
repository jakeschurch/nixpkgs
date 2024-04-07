{lib}:
with lib;
  types.submodule {
    options = {
      enable = mkEnableOption (mdDoc "sccache redis cache");

      cluster_endpoint = mkOption {
        type = types.listOf types.str;
        description = mdDoc "sccache redis cluster endpoint";
      };

      endpoint = mkOption {
        type = types.str;
        description = mdDoc "sccache redis endpoint";
      };
      db_number = mkOption {
        type = types.int;
        description = mdDoc "sccache redis db number";
        default = 0;
      };
      expiration_ttl = mkOption {
        type = types.int;
        description = mdDoc "sccache redis expiration ttl in seconds";
        default = 3600;
      };
      key_prefix = mkOption {
        type = types.str;
        description = mdDoc "sccache redis key prefix (optional)";
        default = null;
      };
    };
  }
