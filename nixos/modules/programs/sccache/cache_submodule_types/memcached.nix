{lib}:
with lib;
  types.submodule {
    options = {
      enable = mkEnableOption (mdDoc "sccache memcached cache");

      endpoint = mkOption {
        type = types.str;
        description = mdDoc "sccache memcached endpoint, in format tcp://<hostname>:<port> ...";
      };
      username = mkOption {
        type = types.str;
        description = mdDoc "sccache memcached username (optional)";
        default = null;
      };

      password = mkOption {
        type = types.str;
        description = mdDoc "sccache memcached password (optional)";
        default = null;
      };

      expiration_ttl = mkOption {
        type = types.int;
        description = mdDoc "sccache memcached expiration ttl in seconds, default is 1 day and can up to 259200 (30 days)";
        default = 86400;
      };

      key_prefix = mkOption {
        type = types.str;
        description = mdDoc "sccache memcached key prefix (optional)";
        default = null;
      };
    };
  }
