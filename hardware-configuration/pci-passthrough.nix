{ config, lib, pkgs, ... }:

{
  boot.kernelParams = [ "intel_iommu=on" ];

  boot.kernelModules = [ "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" ];

  boot.extraModprobeConfig = "options vfio-pci ids=10de:1b81,10de:10f0";

 
  environment.systemPackages = with pkgs; [
    virtmanager
    qemu
    OVMF
  ];

  virtualisation.libvirtd.enable = true;
  #virtualisation.libvirtd.enableKVM = true;

  #users.groups.libvirtd.members = [ "root" "edanaher" ];

  #virtualisation.libvirtd.qemuVerbatimConfig = ''
  #  nvram = [ "${pkgs.OVMF}/FV/OVMF.fd:${pkgs.OVMF}/FV/OVMF_VARS.fd" ];
  #'';
}
