require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'meraki_vlan',
  docs: <<-EOS,
      This type provides Puppet with the capabilities to manage VLANs on the Meraki Dashboard
    EOS
  attributes: {
    id: {
      # type:     'Integer[1, 4094]',
      type:     'String',
      desc:     'The VLAN ID (must be between 1 and 4094)',
      behaviour: :namevar,
    },
    ensure: {
      type:     'Enum[present, absent]',
      desc:     'Resource is ensurable (present, absent).',
      default:    'present',
    },
    description: {
      type:     'String',
      desc:     'The name of the VLAN',
    },
    subnet: {
      type:     'String',
      desc:     'The subnet of the VLAN',
    },
    applianceip: {
      type:     'String',
      desc:     'The local IP of the appliance on the VLAN',
    },
    fixedipassignments: {
      type:     'Optional[Variant[Enum[unset], Hash]]',
      desc:     'The DHCP fixed IP assignments on the VLAN. Can be removed via \'unset\' or empty Hash',
    },
    reservedipranges: {
      type:     'Optional[Variant[Enum[unset], Array[Hash]]]',
      desc:     'The DHCP reserved IP ranges on the VLAN.  Can be removed via \'unset\' or empty Array',
    },
    vpnnatsubnet: {
      type:     'Optional[String]',
      desc:     'The translated VPN subnet if VPN and VPN subnet translation are enabled on the VLAN.',
    },
    dnsnameservers: {
      type:     'String',
      desc:     'The DN nameservers used for DHCP responses, either "upstream_dns", "google_dns", "opendns", or a newline seperated string of IP addresses or domain names.',
      default:  'upstream_dns',
    },
  },
  features: ['canonicalize', 'remote_resource'],
)
