# == Define: ufw::deny
#
# Add a "deny" rule user Ubuntu's Uncomplicated Firewall.
#
# === Parameters
#
# [*from*]
#   Source address for firewall rule, or "Anywhere".
#
# [*ip*]
#   Destination address for firewall rule.
#
# [*proto*]
#   Protocol (ah, esp, tcp, udp) for firewall rule.
#
# [*port*]
#   Port number for firewall rule, or "all".
#
# === Examples
#
# ufw::deny { 'deny-ntp-from-host':
#   from  => '198.51.100.37',
#   ip    => '203.0.113.78',
#   port  => 123,
#   proto => 'udp',
# }
#
# === Authors
#
# Original module by Eivind Uggedal <eivind@uggedal.com>
# Modified by Andrew Leonard
#
# === Copyright
#
# Original module Copyright (C) 2011 by Eivind Uggedal <eivind@uggedal.com>
#
define ufw::deny(
  $from='any',
  $ip='',
  $port='all',
  $proto='tcp'
  ) {

  # Path to binaries, to shorten commands below and avoid global search path:
  $grep = '/bin/grep'
  $ufw = '/usr/sbin/ufw'

  if $::ipaddress_eth0 != undef {
    $ipadr = $ip ? {
      ''      => $::ipaddress_eth0,
      default => $ip,
    }
  } else {
    $ipadr = 'any'
  }

  $from_match = $from ? {
    'any'   => 'Anywhere',
    default => "${from}/${proto}",
  }

  $cmd = $port ? {
    'all'   => "${ufw} deny proto ${proto} from ${from} to ${ipadr}",
    default => "${ufw} deny proto ${proto} from ${from} to ${ipadr} port ${port}",
  }

  $unless = $port ? {
    'all'   => "${ufw} status | ${grep} -E \"${ipadr}/${proto} +DENY +${from_match}\"",
    default => "${ufw} status | ${grep} -E \"${ipadr} ${port}/${proto} +DENY +${from_match}\"",
  }

  exec { "ufw-deny-${proto}-from-${from}-to-${ipadr}-port-${port}":
    command => $cmd,
    unless  => $unless,
    require => Exec['ufw-default-deny'],
    before  => Exec['ufw-enable'],
  }
}
