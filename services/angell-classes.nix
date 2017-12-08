{config, lib, pkgs, ...}:

let utils = import ../utils.nix;
    monitor-script = pkgs.python3Packages.buildPythonApplication rec  {
      name = "angell-class-monitor";
      version = "6094532";

      src = pkgs.fetchFromGitHub {
        owner = "edanaher";
        repo = "angell-class-monitor";
        rev = version;
        sha256 = "0484nac0019vzz58wmil0q9zbrrg2zn00h8krzdhfwgi6mfr08ib";
      };

      propagatedBuildInputs = with pkgs.python3Packages; [ docopt psycopg2 ];

      buildPhase = "";

      installPhase = ''
        mkdir -p $out/bin/
        cp generate.py $out/bin
        cp template.html $out/bin
        substitute setup.sh $out/bin/setup.sh --replace @SUDO ${pkgs.sudo} --replace @POSTGRESQL ${pkgs.postgresql} --replace @OUT $out
        chmod +x $out/bin/setup.sh

        mkdir -p $out/etc
        cp angell.sql $out/etc/
      '';

      doCheck = false;

      meta = {
        homepage = http://github.com/edanaher/angell-class-monitor;
        description = "Service for watching for changes in classes at the MSPCA Angell in Boston";
        license = pkgs.stdenv.lib.licenses.bsd3;
      };
    };

    angell-path = "/var/www/angell-classes";
    update-wrapper = pkgs.writeScriptBin "angell-classes-wrapper" ''
      #!/bin/sh

      now=`date -Iseconds`
      ${monitor-script}/bin/generate.py -o ${angell-path}/new-$now.html -r ${angell-path}/raw/$now -m localhost
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
      wants = [ "network-online.target" "postgresql.service" ];
      environment = { TZ = "America/Los_Angeles"; };
      serviceConfig = {
        User = "angell";
        PermissionsStartOnly = "true";
        ExecStart = "${update-wrapper}/bin/angell-classes-wrapper";
        Restart = "on-failure";
        RestartSec = "4h";
      };

      preStart = ''
        ${monitor-script}/bin/setup.sh ${angell-path}
      '';
    };

    systemd.timers.update-angell-classes = utils.simple-timer "daily" "Scrape updates for Angell classes daily";

    users.users.angell.description = "User to run the angell-class-monitor script";
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
