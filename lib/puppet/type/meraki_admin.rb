require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'meraki_admin',
  docs: <<-EOS,
      This type provides Puppet with the capabilities to manage Administators on the Meraki Dashboard
    EOS
  attributes: {
    email:       {
      type:     'String',
      desc:     'The email of the dashboard administrator. This attribute can not be updated.',
      behaviour: :namevar,
    },
    ensure:       {
      type:     'Enum[present, absent]',
      desc:     'Resource is ensurable (present, absent).',
      default:    'present',
    },
    fullname:         {
      type:     'String',
      desc:     'The name of the dashboard administrator',
    },
    id:        {
      type:     'Integer',
      desc:     'ID of administrator',
      behaviour: :read_only,
    },
    orgaccess:        {
      type:     'Enum["full","read-only","none"]',
      desc:     'The privilege of the dashboard administrator on the organization (full, read-only, none)',
    },
    networks:        {
      type:     'Optional[Array[Hash]]',
      desc:     'The list of networks that the dashboard administrator has privileges on.  Contains the network ID, and privilege of the dashboard administrator on the network',
    },
    tags:        {
      type:     'Optional[Array[Hash]]',
      desc:     'The list of tags that the dashboard administrator has privileges on.  Contains the name of the tag and access privilege of the dashboard administrator on the tag',
    },
  },
  features: ['canonicalize', 'remote_resource'],
)
