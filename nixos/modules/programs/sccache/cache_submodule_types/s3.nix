# TODO: s3 credentials
{lib}:
with lib;
  types.submodule {
    options = {
      enable = mkEnableOption (mdDoc "sccache s3 cache");
      bucket = mkOption {
        type = types.str;
        description = mdDoc "sccache s3 bucket";
      };
      region = mkOption {
        type = types.str;
        description = mdDoc "sccache s3 region, required if using AWS s3, defaults to us-east-1";
        default = "us-east-1";
      };
      s3_use_ssl = mkOption {
        type = types.bool;
        description = mdDoc "s3 endpoint requires TLS, set this to true";
        default = false;
      };
      s3_key_prefix = mkOption {
        type = types.str;
        description = mdDoc "sccache s3 key prefix (optional)";
        default = null;
      };
    };
  }
