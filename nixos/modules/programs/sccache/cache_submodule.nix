{lib}:
lib.types.attrsOf (lib.types.submodule {
  options = {
    # Configure the following: the nixos option `cache` contains several optional modules: disk, s3, cloudflare_r2, redis, memcached, gcs, azure, gha, webdav.
    s3 = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          enable = lib.mkEnableOption (lib.mdDoc "sccache s3 cache");
          bucket = lib.mkOption {
            type = lib.types.str;
            description = lib.mdDoc "sccache s3 bucket";
          };
          region = lib.mkOption {
            type = lib.types.str;
            description = lib.mdDoc "sccache s3 region, required if using AWS s3, defaults to us-east-1";
            default = "us-east-1";
          };
          s3_use_ssl = lib.mkOption {
            type = lib.types.bool;
            description = lib.mdDoc "s3 endpoint requires TLS, set this to true";
            default = false;
          };
          s3_key_prefix = lib.mkOption {
            type = lib.types.str;
            description = lib.mdDoc "sccache s3 key prefix (optional)";
            default = null;
          };
        };
      });
    };

    disk = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          enable = lib.mkEnableOption (lib.mdDoc "sccache disk cache");
          cacheDir = lib.mkOption {
            type = lib.types.path;
            description = lib.mdDoc "local on disk artifact cache directory";
          };
          owner = lib.mkOption {
            type = lib.types.str;
            default = "root";
            description = lib.mdDoc "Owner of sccache directory";
          };
          group = lib.mkOption {
            type = lib.types.str;
            default = "nixbld";
            description = lib.mdDoc "Group owner of sccache directory";
          };
          cacheSize = lib.mkOption {
            type = lib.types.bigint;
            default = 1000;
            description = lib.mdDoc "sccache disk cache size in MiB";
          };
          direct = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = lib.mdDoc "Use preprocessor caching";
          };
        };
      });
    };
  };
})
