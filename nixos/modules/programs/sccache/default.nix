{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.programs.sccache;
in
  with lib; {
    options.programs.sccache = {
      # host configuration
      enable = mkEnableOption (lib.mdDoc "Sccache");
      cache.disk = mkOption {
        type = types.nullOr (pkgs.callPackage ./cache_submodule_types/disk.nix {
          inherit lib;
        });
        default = {};
      };

      cache.s3 = mkOption {
        type = types.nullOr (pkgs.callPackage ./cache_submodule_types/s3.nix {
          inherit lib;
        });
        default = {};
      };

      cache.r2 = mkOption {
        type = types.nullOr (pkgs.callPackage ./cache_submodule_types/r2.nix {
          inherit lib;
        });
        default = {};
      };

      cache.redis = mkOption {
        type = types.nullOr (pkgs.callPackage ./cache_submodule_types/redis.nix {
          inherit lib;
        });
        default = {};
      };


      cache.memcached = mkOption {
        type = types.nullOr (pkgs.callPackage ./cache_submodule_types/memcached.nix {
          inherit lib;
        });
        default = {};
      };

      # target configuration
      packageNames = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = lib.mdDoc "Nix top-level packages to be compiled using sccache";
        default = [];
        example = ["wxGTK32" "ffmpeg" "libav_all"];
      };
    };

    config = lib.mkMerge [
      # host configuration
      (lib.mkIf cfg.enable {
        assertions = lib.singleton {
          assertion = let
            enabledCacheConfigs = lib.mapAttrsToList (_name: mod: mod.enable) cfg.cache;
            isOnlyOneCacheModuleEnabled = lib.lists.findSingle (v: v) false false;
          in
            isOnlyOneCacheModuleEnabled enabledCacheConfigs;
          message = "only one cache type can be enabled";
        };

        systemd.tmpfiles.rules = with cfg.cache.disk; lib.mkIf enable ["d ${cacheDir} 0770 ${owner} ${group} -"];

        # REVIEW: "nix-sccache --show-stats" and "nix-sccache --clear"
        security.wrappers.nix-sccache = {
          inherit (cfg.cache.disk) owner group;
          setuid = false;
          setgid = true;
          source = pkgs.writeScript "nix-sccache.pl" ''
            #!${pkgs.perl}/bin/perl

            %ENV=( SCCACHE_DIR => '${cfg.cache.disk.cacheDir}' );
            sub untaint {
              my $v = shift;
              return '-C' if $v eq '-C' || $v eq '--clear';
              return '-V' if $v eq '-V' || $v eq '--version';
              return '-s' if $v eq '-s' || $v eq '--show-stats';
              return '-z' if $v eq '-z' || $v eq '--zero-stats';
              exec('${pkgs.sccache}/bin/sccache', '-h');
            }
            exec('${pkgs.sccache}/bin/sccache', map { untaint $_ } @ARGV);
          '';
        };
      })

      # target configuration
      (lib.mkIf (cfg.packageNames != []) {
        nixpkgs.overlays = [
          (self: super: lib.genAttrs cfg.packageNames (pn: super.${pn}.override {stdenv = builtins.trace "with sccache: ${pn}" self.sccacheStdenv;}))

          (self: super: {
            sccacheWrapper = super.sccacheWrapper.override {
              extraConfig = ''
                ${with cfg.cache;
                  lib.optional s3.enable ''
                    export SCCACHE_BUCKET=${s3.bucket}
                    export SCCACHE_REGION=${s3.region}
                    export SCCACHE_S3_USE_SSL=${s3.s3_use_ssl}
                    export SCCACHE_S3_KEY_PREFIX=${s3.s3_key_prefix}
                  ''}

                ${with cfg.cache;
                  lib.optional disk.enable ''
                    export SCCACHE_DIR=${disk.cacheDir}
                    export SCCACHE_CACHE_SIZE=${disk.cacheSize}
                    export SCCACHE_DIRECT=${disk.direct}
                    export SCCACHE_UMASK=007

                    if [ ! -d "$SCCACHE_DIR" ]; then
                      echo "====="
                      echo "Directory '$SCCACHE_DIR' does not exist"
                      echo "Please create it with:"
                      echo "  sudo mkdir -m0770 '$SCCACHE_DIR'"
                      echo "  sudo chown ${disk.owner}:${disk.group} '$SCCACHE_DIR'"
                      echo "====="
                      exit 1
                    fi
                    if [ ! -w "$SCCACHE_DIR" ]; then
                      echo "====="
                      echo "Directory '$SCCACHE_DIR' is not accessible for user $(whoami)"
                      echo "Please verify its access permissions"
                      echo "====="
                      exit 1
                    fi
                  ''}

              '';
            };
          })
        ];
      })
    ];
  }
