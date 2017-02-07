{ lib }:

{
  select = v: set: let all = lib.mapAttrs (name: data: lib.mkIf (name == v) data) set;
                   in lib.mkMerge (builtins.attrValues all);
}
