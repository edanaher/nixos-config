set -e

mkdir -p /tmp/nixos-builds
cd /tmp/nixos-builds

for host in doyha kroen kdfsh; do
  NIXOS_CONFIG=/etc/nixos/configuration/$host.nix nixos-rebuild build
  if [ -L $host ]; then
    if [ `readlink $host` != `readlink result` ]; then
      echo -e "\033[31;1mDifference on $host; saving to $host.new\033[0m"
      rm $host.new || true 2>&1
      mv result $host.new
    else
      echo -e "\033[32;1mNo difference on $host\033[0m"
      rm result
    fi
  else
    echo -e "\033[33;1mCreating snapshot for $host\033[0m"
    mv result $host
  fi
done
