
# ciscomeraki-meraki

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with ciscomeraki-meraki](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with ciscomeraki-meraki](#beginning-with-ciscomeraki-meraki)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

This Puppet module facilitates the configuration and management of Cisco Meraki via the Meraki Dashboard API and Puppet Resource API + Puppet Device.

Current capabilities of the module are limited in scope, but the desire is to gain functionality via community contribution... hint. hint.

## Setup

### Setup Requirements

Use of this module requires Puppet >= 4.10.x (although  >= 5.3.6 is suggested) and the following 

#### Agent (Puppet Device)
[Puppet Resource API](https://github.com/puppetlabs/puppet-resource_api) >= 1.4.0  
Agent (Puppet Device) dependencies can be install with Puppet via the included `meraki` class or manually via
```shell
sudo /opt/puppetlabs/puppet/bin/gem install puppet-resource_api
```

[Meraki dashboard-api](https://rubygems.org/gems/dashboard-api)
manually via
```shell
sudo /opt/puppetlabs/puppet/bin/gem install dashboard-api
```

#### Master
[Puppet Resource API](https://github.com/puppetlabs/puppet-resource_api) (Included in Puppet 6)  
Resource API can be installed with Puppet via the [puppetlabs/resource_api module](https://forge.puppet.com/puppetlabs/resource_api) and `resource_api::server` class or manually via
```shell
sudo /opt/puppetlabs/bin/puppetserver gem install puppet-resource_api
```

### Beginning with ciscomeraki-meraki

#### API Key

Usage of the module requires a Meraki Dashboard API access enabled and an API access key.  https://documentation.meraki.com/zGeneral_Administration/Other_Topics/The_Cisco_Meraki_Dashboard_API

Puppet device is to be configured per Meraki Organization and/or Network.  A list of organizations or networks the user has access to can be gathered with the Puppet Tasks `meraki::list_orgs` and `meraki::list_networks`

*Note* if using Puppet Enterprise CLI execution of Tasks requires an [access token](https://puppet.com/docs/pe/latest/rbac/rbac_token_auth_intro.html)

```
[root@puppet-device-devel tasks]# puppet task run meraki::list_orgs key=apikey123 -n puppet-device-devel.shermdog.local
Starting job ...
New job ID: 8
Nodes: 1

Started on puppet-device-devel.shermdog.local ...
Finished on node puppet-device-devel.shermdog.local
  status : success
  organizations : [{"id":549236,"name":"Meraki DevNet Sandbox"},{"id":646829496481088929,"name":"SD Test"}]

Job completed. 1/1 nodes succeeded.
Duration: 2 sec
```
```
[root@puppet-device-devel ~]# puppet task run meraki::list_networks key=apikey123 -n puppet-device-devel.shermdog.local
Starting job ...
New job ID: 22
Nodes: 1

Started on puppet-device-devel.shermdog.local ...
Finished on node puppet-device-devel.shermdog.local
  status : success
  networks : [{"id":"L_646829496481097728","name":"Wireless 2","tags":null,"type":"combined","timeZone":"America/Los_Angeles","organizationId":"646829496481088375"},{"id":"N_686235993220589511","name":"jr","tags":null,"type":"wireless","timeZone":"America/Los_Angeles","organizationId":"646829496481088375"},{"id":"L_686235993220583318","name":"branch office","tags":null,"type":"combined","timeZone":"America/Los_Angeles","organizationId":"646829496481088375"},{"id":"L_686235993220583319","name":"DC Branch","tags":null,"type":"combined","timeZone":"America/Los_Angeles","organizationId":"646829496481088375"}]

Job completed. 1/1 nodes succeeded.
Duration: 1 sec

```

#### Puppet Device

To get started, create or edit `/etc/puppetlabs/puppet/device.conf`, add a section for the organization and/or network you want to manage (this will become the device's `certname`), specify a type of `meraki_organization` or `meraki_network`, and specify a `url` to a credentials file. For example:

`vi /etc/puppetlabs/puppet/device.conf`
```INI
[meraki-devnet-org]
  type meraki_organization
  url file:///root/meraki.yaml

[meraki-devnet-net]
  type meraki_network
  url file:///root/mnet.yaml

```
`vi /root/meraki.yaml`
```
{
    dashboard_org_id = 123456
    dashboard_api_key = apikey789
}
```
`vi /root/mnet.yaml`
```
{
    dashboard_network_id = L_5678
    dashboard_api_key = apikey789
}
```

Puppet device configuration can also be managed by Puppet via the [device_manager](https://forge.puppet.com/puppetlabs/device_manager) module:

```Puppet
node puppet {
  device_manager { 'meraki-devnet-org':
    type        => 'meraki_organization',
    credentials => {
      dashboard_org_id  => '123456',
      dashboard_api_key => 'apikey789',
    },
  }
}
```

Puppet Device nodes require a signed certificate from the master (just like an Agent).
[Adding and removing nodes](https://puppet.com/docs/pe/latest/managing_nodes/adding_and_removing_nodes.html)

By default Puppet Device will process all nodes configured in device.conf.  Output by default is suppressed, so include `-v` for interactive runs.
```shell
/opt/puppetlabs/puppet/bin/puppet device -v
```

Individual nodes (organizations) can be specified
```shell
/opt/puppetlabs/puppet/bin/puppet device -v --target meraki-devnet-org
```

Current administrators can be returned interactively as Puppet code
```shell
/opt/puppetlabs/puppet/bin/puppet device -v --target meraki-devnet-org --resource meraki_admin
```

Current administrators can be returned interactively as Puppet code and filtered by email
```shell
[root@puppet-device-devel ~]# /opt/puppetlabs/puppet/bin/puppet device -v --target meraki-devnet-org --resource meraki_admin shermdog@puppet.com
Info: retrieving resource: meraki_admin from meraki-devnet-org at file:///etc/puppetlabs/code/environments/production/meraki.yaml
meraki_admin { "shermdog@puppet.com": 
  fullname => 'Rick Sherman',
  ensure => 'present',
# id => '646829496481137785', # Read Only
  orgaccess => 'full',
  networks => [
  {
    'id' => 'L_646829496481099051',
    'access' => 'full'
  },
  {
    'id' => 'L_646829496481095933',
    'access' => 'full'
  },
  {
    'id' => 'N_646829496481143399',
    'access' => 'full'
  }],
  tags => [
  {
    'tag' => 'Sandbox',
    'access' => 'full'
  },
  {
    'tag' => 'branch',
    'access' => 'full'
  }],
}
```

Current VLANs can be returned interactively as Puppet code and filtered by ID
```shell
[root@puppet-device-devel ~]# puppet device -v -t meraki-devnet-net --resource meraki_vlan 99
Info: retrieving resource: meraki_vlan from meraki-devnet-net at file:///root/mnet.yaml
meraki_vlan { "99": 
  ensure => 'present',
  description => 'Managed by Puppet',
  subnet => '10.0.99.0/24',
  applianceip => '10.0.99.1',
  fixedipassignments => {
  '52:54:00:e3:5d:3d' => {
    'ip' => '10.0.99.202',
    'name' => 'test2'
  }
},
  reservedipranges => [
  {
    'start' => '10.0.99.1',
    'end' => '10.0.99.101',
    'comment' => 'test 1'
  },
  {
    'start' => '10.0.99.200',
    'end' => '10.0.99.225',
    'comment' => 'test 2'
  }],
  dnsnameservers => 'upstream_dns',
}
```

## Reference

[Puppet Strings REFERENCE.md](REFERENCE.md)

## Limitations

### meraki_vlan
The Meraki API currently does not allow for the removal of `fixedIpAssignments` once they have been set.  Puppet will still try to remove them.

## Development

This module leverages [Puppet Resource API](https://github.com/puppetlabs/puppet-specifications/blob/master/language/resource-api/README.md) and is compatible with [Puppet PDK](https://puppet.com/docs/pdk/latest/pdk.html)

Additional information on contributing to the module will be forthcoming.
