import ./make-test-python.nix ({ pkgs, ...} : {
  name = "sccache";
  meta = with pkgs.lib.maintainers; {
    maintainers = [ ];
  };

  nodes.machine = { ... }: {
    imports = [ ../modules/profiles/minimal.nix ];
    environment.systemPackages = [ pkgs.hello ];
    programs.sccache = {
      enable = true;
      cache.disk.enable = true;
      packageNames = [ "hello" ];
    };
  };

  testScript =
    ''
      start_all()
      machine.wait_for_unit("multi-user.target")
      machine.succeed("nix-sccache --show-stats")
      machine.succeed("hello")
      machine.shutdown()
    '';
})
