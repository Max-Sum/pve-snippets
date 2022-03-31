#!/usr/bin/perl
# /var/lib/vz/snippets/return-hostpci.pl
# This script returns all PCI passthrough devices back to host after VM shutdown.
# Beware that some devices might have problem reinitializing.
# Set to VM: qm set <vmid> --hookscript local:snippets/return-hostpci.pl

use PVE::QemuServer;
use PVE::SysFSTools;

use strict;
use warnings;

my $vmid = shift;
my $phase = shift;

if ($phase eq 'post-stop') {
  print "$vmid stopped. Return Host PCIs.\n";
  my $conf = PVE::QemuConfig->load_config($vmid);
  for (my $i = 0; $i < $PVE::QemuServer::PCI::MAX_HOSTPCI_DEVICES; $i++) {
    my $dev = $conf->{"hostpci$i"} or next;
    my $pci_devices = PVE::QemuServer::PCI::parse_hostpci($dev);
    foreach (@{$pci_devices->{pciid}}) {
      my $id = $_->{id};
      print "Return $id...";
      PVE::SysFSTools::file_write("/sys/bus/pci/devices/$id/driver/unbind", $id);
      PVE::SysFSTools::file_write("/sys/bus/pci/devices/$id/reset", 1);
      PVE::SysFSTools::file_write("/sys/bus/pci/drivers_probe", $id);
      print "Done.\n";
    }
  }
}
