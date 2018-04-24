
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
[Puppet Resource API](https://github.com/puppetlabs/puppet-resource_api)  
Resource API can be installed with Puppet via the [puppetlabs/resource_api module](https://forge.puppet.com/puppetlabs/resource_api) and `resource_api::agent` class or manually via
```shell
sudo /opt/puppetlabs/puppet/bin/gem install puppet-resource_api
```

[Meraki dashboard-api](https://rubygems.org/gems/dashboard-api)
manually via
```shell
sudo /opt/puppetlabs/puppet/bin/gem install dashboard-api
```

#### Master
[Puppet Resource API](https://github.com/puppetlabs/puppet-resource_api)  
Resource API can be installed with Puppet via the [puppetlabs/resource_api module](https://forge.puppet.com/puppetlabs/resource_api) and `resource_api::server` class or manually via
```shell
sudo /opt/puppetlabs/bin/puppetserver gem install puppet-resource_api
```

### Beginning with ciscomeraki-meraki

Usage of the module requires a Meraki Dashboard API access enabled and an API access key.  https://documentation.meraki.com/zGeneral_Administration/Other_Topics/The_Cisco_Meraki_Dashboard_API

Puppet device is to be configured per Meraki Organization.  A list of organizations the user has access to can be gathered with the Puppet Task `meraki::list_orgs`

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


`vi /etc/puppetlabs/puppet/device.conf`
```INI
[meraki-devnet-org]
  type meraki_organization
  url file:///root/meraki.yaml
```
`vi /root/meraki.yaml`
```

default{
  node {
    dashboard_org_id = 123456
    dashboard_api_key = apikey789
  }
}

```

Puppet Device nodes require a signed certificate from the master (just like an Agent).  Add some notes here about that.

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

## Usage

This section is where you describe how to customize, configure, and do the fancy stuff with your module here. It's especially helpful if you include usage examples and code samples for doing things with your module.

## Reference

Users need a complete list of your module's classes, types, defined types providers, facts, and functions, along with the parameters for each. You can provide this list either via Puppet Strings code comments or as a complete list in the README Reference section.

* If you are using Puppet Strings code comments, this Reference section should include Strings information so that your users know how to access your documentation.

* If you are not using Puppet Strings, include a list of all of your classes, defined types, and so on, along with their parameters. Each element in this listing should include:

  * The data type, if applicable.
  * A description of what the element does.
  * Valid values, if the data type doesn't make it obvious.
  * Default value, if any.

## Limitations

This is where you list OS compatibility, version compatibility, etc. If there are Known Issues, you might want to include them under their own heading here.

## Development

Since your module is awesome, other users will want to play with it. Let them know what the ground rules for contributing are.
