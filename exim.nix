{ config, lib, pkgs, ... }:

let secrets = import ./secrets.nix;
in
{
  services.exim.config = ''
    domainlist local_domains = @ : localhost
    hostlist relay_from_hosts = <; 127.0.0.1 ; ::1

    untrusted_set_sender = ^''${sender_ident} : *@edanaher.net

    acl_smtp_rcpt = acl_check_rcpt
    acl_smtp_data = acl_check_data

    never_users = root
    host_lookup = 
    rfc1413_hosts = *
    rfc1413_query_timeout = 0s
    prdr_enable = true
    tls_advertise_hosts = 

    begin acl
    acl_check_rcpt:
      accept
      accept hosts = :
      deny   message = Restricted characters in address
      	     domains = +local_domains
             local_parts = ^[.] : ^.*[@%!/|]
      deny   message = Restricted characters in address
             domains = !+local_domains
             local_parts = ^[./|] : ^.*[@%!] : ^.*/\\.\\./o
      accept local_parts = postmaster
             domains = +local_domains
      require verify = sender
      require message = relay not permitted
              domains = +local_domains
      require verify = recipient
      accept

    acl_check_data:
      accept


    begin routers

    gmail_route:
      driver = manualroute
      domains = !+local_domains
      condition = ''${if eq{''${address:$header_from:}}{edanaher@gmail.com}}
      transport = gmail_relay
      route_list = * smtp.gmail.com

    gahlpo_route:
      driver = manualroute
      domains = !+local_domains
      condition = ''${if !eq{''${address:$header_from:}}{edanaher@gmail.com}}
      transport = gahlpo_relay
      route_list = * gahlpo.edanaher.net


    begin transports
    gmail_relay:
      driver = smtp
      port = 587
      hosts_require_auth = <; $host_address
      hosts_require_tls = <; $host_address

    gahlpo_relay:
      driver = smtp
      port = 587
      hosts_require_auth = <; $host_address
      hosts_require_tls = <; $host_address

    test_gmail_relay:
      driver = appendfile
      create_directory
      maildir_format
      directory = /home/edanaher/.exim/gmail

    test_gahlpo_relay:
      driver = appendfile
      create_directory
      maildir_format
      directory = /home/edanaher/.exim/gahlpo

    begin authenticators
    login:
      driver = plaintext
      public_name = LOGIN
      hide client_send = : ''${if eq{$host}{gahlpo.edanaher.net}{${secrets.gahlpo.username}}{${secrets.gmail.username}}} : ''${if eq{$host}{gahlpo.edanaher.net}{${secrets.gahlpo.password}}{${secrets.gmail.password}}}

    begin retry
    * * F,2h,1m; G,16h,1h,1.5; F,4d,6h
  '';
}
