{config, lib, pkgs, ...}:

let root-dir = "/var/www/ceremony-site";
    rsvp-placeholder = pkgs.writeText "ceremony-rsvp-placeholder"
    ''
      <html>
        <body>RSVP page coming soon...</body>
      </html>
    '';
    secret-placeholder = pkgs.writeText "ceremony-rsvp-placeholder"
    ''
      <html>
        <head>
          <title>You found the secret!</title>
        </head>
        <body style="text-align: center">
          <iframe width="560" height="315" src="https://www.youtube.com/embed/-w-58hQ9dLk" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
          <p>Bring a kazoo.</p>
        </body>
      </html>
    '';
    update-script = let 
        git = "${pkgs.git}/bin/git";
        jekyll = "${pkgs.jekyll}/bin/jekyll"; in
      pkgs.writeScriptBin "update-ceremony-website" ''
      branch=''${1:-kelly}
      echo Switching to branch $branch
      mkdir -p ${root-dir}/src ${root-dir}/out
      cd ${root-dir}/src
      if [ ! -f index.html ]; then
        ${git} clone https://github.com/edanaher/ceremony-website.git ${root-dir}/src
      fi
      ${git} pull
      ${git} checkout origin/$branch
      ${jekyll} build -d ${root-dir}/out
      chown -R kduncan ${root-dir}
    '';

    ceremony-site = pkgs.stdenv.mkDerivation rec {
      name = "ceremony-site-${version}";
      version = "9e77304";

      src = pkgs.fetchFromGitHub {
        owner = "edanaher";
        repo = "ceremony-website";
        rev = version;
        sha256 = "0x24fbf5kxsmjxgi4ng9lpflgfdqq3snxwk2qa4x7jb4yv1yg24w";
      };

      buildInputs = [pkgs.jekyll ];

      buildPhase = "
        jekyll build -d $out
      ";

      installPhase = "echo";
    };

in
{
  config = lib.mkIf config.host.kdf-services.enable {
    environment.systemPackages = [ update-script ];
    /*security.wrappers.update-ceremony-site = {
      source = "${update-script}/bin/update-ceremony-website";
    };*/

    services.nginx.virtualHosts = {
      "test.kellyandevan.party" = {
        locations = {
          "/" = {
            root = ceremony-site;
          };
        };
      };
      "www.kellyandevan.party" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            root = "${root-dir}/out";
          };
          "=/rsvp.html" = {
            alias = "${rsvp-placeholder}";
            extraConfig = ''
              default_type text/html;
            '';
          };
          "=/secret" = {
            alias = "${secret-placeholder}";
            extraConfig = ''
              default_type text/html;
            '';
          };
        };
      };
    };
    users.extraUsers.kduncan = {
      isNormalUser = true;
      extraGroups = [ ];
    };
  };
}
