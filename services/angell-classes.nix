{config, lib, pkgs, ...}:

let monitor-script = pkgs.python3Packages.buildPythonApplication rec  {
      name = "angell-class-monitor";
      version = "1080f9e";

      src = pkgs.fetchFromGitHub {
        owner = "edanaher";
        repo = "angell-class-monitor";
        rev = version;
        sha256 = "0xgafp3qzg31g34r8x2chw6wk6xvafb1kpxf3mhgd2786hc08dld";
      };

      propagatedBuildInputs = [ pkgs.python3Packages.docopt ];

      buildPhase = "";

      installPhase = ''
        mkdir -p $out/bin/
        cp generate.py $out/bin
        cp template.html $out/bin
      '';

      doCheck = false;

      meta = {
        homepage = http://github.com/edanaher/angell-class-monitor;
        description = "Service for watching for changes in classes at the MSPCA Angell in Boston";
        license = pkgs.stdenv.lib.licenses.bsd3;
      };
    };

    angell-path = "/var/www/angell-classes";
    python = pkgs.python3.withPackages (ps: [ ps.docopt] );
    update-wrapper = pkgs.writeScriptBin "angell-classes-wrapper" ''
      #!/bin/sh
      mkdir -p ${angell-path}/raw
      mkdir -p /var/run/angell-classes

      now=`date -Iseconds`
      cd ${monitor-script}/bin
      ./generate.py -o ${angell-path}/new-$now.html -r ${angell-path}/raw/$now
      ln -sf ${angell-path}/new-$now.html ${angell-path}/index.html
    '';
in
{
  config = lib.mkIf config.host.angell-classes.enable {
    services.nginx.virtualHosts = {
      "angell.kdf.sh" = {
        locations."/" = {
          root = angell-path;
          index = "index.html";
        };
      };
    };

    systemd.services.update-angell-classes = {
      description = "Scrape updates for Angell classes";
      path = with pkgs; [ curl ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        User = "root";
        Group = "root";
        ExecStart = "${update-wrapper}/bin/angell-classes-wrapper";
        Restart = "on-failure";
        RestartSec = "4h";
      };
    };

    systemd.timers.update-angell-classes = utils.simple-timer "daily" "Scrape updates for Angell classes daily";
  };
  options = {
    host.angell-classes.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable angell-classes site and update service.
      '';
    };
  };
}
