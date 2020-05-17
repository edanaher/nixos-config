{config, lib, pkgs, ...}:

let urls = [
        https://www.theonion.com/no-way-to-prevent-this-says-only-nation-where-this-r-1819576527
        https://www.theonion.com/no-way-to-prevent-this-says-only-nation-where-this-r-1819577935
        https://www.theonion.com/no-way-to-prevent-this-says-only-nation-where-this-r-1819578474
        https://www.theonion.com/no-way-to-prevent-this-says-only-nation-where-this-r-1819578287
        https://www.theonion.com/no-way-to-prevent-this-says-only-nation-where-this-r-1819580358
        https://www.theonion.com/no-way-to-prevent-this-says-only-nation-where-this-r-1820163660
        https://www.theonion.com/no-way-to-prevent-this-says-only-nation-where-this-r-1823016659
        https://www.theonion.com/no-way-to-prevent-this-says-only-nation-where-this-r-1826142891
        https://www.theonion.com/no-way-to-prevent-this-says-only-nation-where-this-r-1829032821
        https://www.theonion.com/no-way-to-prevent-this-says-only-nation-where-this-r-1830308976
        https://www.theonion.com/no-way-to-prevent-this-says-only-nation-where-this-r-1830073842
        https://www.theonion.com/no-way-to-prevent-this-says-only-nation-where-this-r-1836949715
        https://www.theonion.com/no-way-to-prevent-this-says-only-nation-where-this-r-1836949580
      ];
    header = ''
  <html>
  <head>
    <title>No way to prevent this</title>
    <style type="text/css">
      body {
        margin: 0;
        height: 100%;
      }
      #bar {
        line-height: 40px;
        height: 40px;
        background-color: #EEEEEE;
        width: 100%;
        padding: 0;
        margin: 0;
        text-align: right;
      }
      #bar a {
        text-decoration: none;
        font-size: 120%;
        margin-left: 1em;
        margin-right: 1em;
      }
      #title a {
        position: absolute;
        left: 10px;
        font-size: 120%;
        color: #FF0000 !important;
        font-family: sans-serif;
      }
      #content {
        position: absolute;
        height: auto;
        top: 40px;
        bottom: 0;
        box-sizing: border-box;
        width: 100%;
      }
      #about {
        margin: 10px;
      }
      iframe {
        height: 100%;
        width: 100%;
        box-sizing: border-box
      }
    </style>
  </head>
  <body>
  <div id="bar">
    <span id="title"><a href="/">No way to prevent this...  none at all</a></span>
    <a href="/about" />About</a>
    <a href="/direct" />Random direct link</a>
    <a href="mailto:feedback@nowaytopreventthis.com" />Contact</a>
  </div>
'';
    footer = ''</div></body>'';
    tophtml = ''
  ${header}
  <div id="content">
'';
    about_page = pkgs.writeText "nowaytopreventthis-about" ''
      ${header}
      <div id="about">
      <p>This site randomly shows the following urls, defaulting to showing in an iframe underneath the informative header, with the option to use /direct to redirect to the article.</p>
      <ul>
        ${lib.strings.concatMapStrings (u: ''<li><a href="${u}">${u}</a></li>'') urls}
      </ul>
      <p>Why?  Because domains are cheap and gimmick sites are easy to make, and maybe this will get some press to the Onion's excellent repeated satire.  Also, I wanted to play with a quick site generated entirely using lua in nginx via open-resty's libraries, combined with Nix's "templating".  It's pretty easy.</p>
      <p>Send feedback/comments/complaints to <a href="mailto:feedback@nowaytopreventthis.com">feedback@nowaytopreventthis.com</a></p>
      ${footer}
      </div>
    '';
in
{
  config = lib.mkIf config.host.nowaytopreventthis.enable {

    services.nginx.virtualHosts = {
      "www.nowaytopreventthis.com" = {
        extraConfig = ''
          server_name nowaytopreventthis.com;
        '';
        locations = {
          "/" =  {
            extraConfig = ''
              default_type text/html;
              content_by_lua_block {
                local urls = { ${lib.strings.concatMapStrings (u: ''"${u}", '') urls} }
                local url = urls[math.random(#urls)]
                ngx.say([[${tophtml}]])
                --ngx.say([[<iframe frameBorder="0" src="]] .. url .. [[" />]])
                ngx.say([[Sadly, the onion seems to have disabled iframe embeds, so this page no longer works.  Read a <a href="]] .. urls[math.random(#urls)] .. [[">random article</a>, or pick one from the list below:
                <ul>]] ..
                  ${lib.strings.concatMapStrings (u: ''[[<li><a href="${u}">${u}</a></li>]] ..
'') urls}
                [[</ul>]])
                ngx.say([[${footer}]])
              }
            '';
          };
          "=/about" =  {
            alias = about_page;
            extraConfig = ''
              default_type text/html;
            '';
          };
          "/direct" =  {
            extraConfig = ''
              default_type text/html;
              content_by_lua_block {
                local urls = { ${lib.strings.concatMapStrings (u: ''"${u}", '') urls} }
                local url = urls[math.random(#urls)]
                ngx.redirect(url)
              }
            '';
          };
        };
      };
    };
  };

  options = {
    host.nowaytopreventthis.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable nowaytopreventthis one-note site.
      '';
    };
  };
}

