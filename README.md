My nixos configuration
======================
This is the contents of my /etc/nixos.  A couple interesting notes:

- I'm using this across a couple hosts; after deciding that a branch per host is unmaintainable, I spent some time building what I suspect is a very small subset of NixOps to set this up.  Pretty much the hostname goes in hostname.nix, and then hosts.nix has per-host configuration, as well as some other slightly generic config (e.g., laptop or touchscreen).  This is slight overkill for my current setup, but it was fun to build, and should serve me well in the future.

  Also, hardware-configuration is now a directory with each host's hardware-configuration.nix.  To avoid annoying issues, this default.nix directly looks at hostname.nix instead of config.host.name; that should be fixed at some point.

- I have configuration for sending e-mail in here, which includes passwords.  Those live in secrets.nix, which is filled with dummy values, but .gitignored to avoid committing passwords.  They could probably also be read form files outside nix, but this is what I'm doing for now.
