{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, openssl
, stdenv
, darwin
, makeWrapper
, nix-update-script
}:

let self = rustPlatform.buildRustPackage rec {
  version = "0.7.7";
  pname = "sccache";

  src = fetchFromGitHub {
    owner = "mozilla";
    repo = "sccache";
    rev = "v${version}";
    sha256 = "sha256-nWSMWaz1UvjsA2V7q7WKx44G45VVaoQxteZqrKAlxY8=";
  };

  cargoHash = "sha256-ezub+pOqNjCfH7QgjLBrYtsyYbPM3/SADLpNgPtlG+I=";

  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    openssl
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  # Tests fail because of client server setup which is not possible inside the
  # pure environment, see https://github.com/mozilla/sccache/issues/460
  doCheck = false;


  passthru = {
    # A derivation that provides gcc and g++ commands, but that
    # will end up calling sccache for the given cacheDir
    links = { unwrappedCC, extraConfig }: stdenv.mkDerivation {
      pname = "sccache-links";
      inherit version;
      passthru = {
        isClang = unwrappedCC.isClang or false;
        isGNU = unwrappedCC.isGNU or false;
        isCcache = true;
      };
      inherit (unwrappedCC) lib;
      nativeBuildInputs = [ makeWrapper ];
      # Unwrapped clang does not have a targetPrefix because it is multi-target
      # target is decided with argv0.
      buildCommand = let
        targetPrefix = if unwrappedCC.isClang or false
          then
            ""
          else
            (lib.optionalString (unwrappedCC ? targetConfig && unwrappedCC.targetConfig != null && unwrappedCC.targetConfig != "") "${unwrappedCC.targetConfig}-");
      in ''
        mkdir -p $out/bin

        wrap() {
          local cname="${targetPrefix}$1"
          if [ -x "${unwrappedCC}/bin/$cname" ]; then
            makeWrapper ${self.finalPackage}/bin/sccache $out/bin/$cname \
              --run ${lib.escapeShellArg extraConfig} \
              --add-flags ${unwrappedCC}/bin/$cname
          fi
        }

        wrap cc
        wrap c++
        wrap gcc
        wrap g++
        wrap clang
        wrap clang++

        for executable in $(ls ${unwrappedCC}/bin); do
          if [ ! -x "$out/bin/$executable" ]; then
            ln -s ${unwrappedCC}/bin/$executable $out/bin/$executable
          fi
        done
        for file in $(ls ${unwrappedCC} | grep -vw bin); do
          ln -s ${unwrappedCC}/$file $out/$file
        done
      '';
    };

    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Ccache with Cloud Storage";
    mainProgram = "sccache";
    homepage = "https://github.com/mozilla/sccache";
    changelog = "https://github.com/mozilla/sccache/releases/tag/v${version}";
    maintainers = with maintainers; [ doronbehar figsoda ];
    license = licenses.asl20;
  };
}; in self
