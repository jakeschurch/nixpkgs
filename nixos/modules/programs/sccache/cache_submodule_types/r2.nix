# TODO: s3 credentials
{lib}:
with lib;
  types.submodule {
    options = {
      enable = mkEnableOption (mdDoc "sccache r2 cache");
      bucket = mkOption {
        type = types.str;
        description = mdDoc "sccache r2 bucket";
      };
      region = mkOption {
        type = types.str;
        description = mdDoc "sccache r2 region, should be set to auto";
        default = "auto";
      };
      r2_use_ssl = mkOption {
        type = types.bool;
        description = mdDoc "r2 endpoint requires TLS, set this to true";
        default = false;
      };
      r2_key_prefix = mkOption {
        type = types.str;
        description = mdDoc "sccache r2 key prefix (optional)";
        default = null;
      };
    };
  }
