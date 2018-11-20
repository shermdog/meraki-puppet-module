require 'puppet/util/network_device/simple/device'

module Puppet::Util::NetworkDevice::Meraki_network
  class Device < Puppet::Util::NetworkDevice::Simple::Device
    attr_reader :dapi, :networkid, :orgid

    def initialize(url_or_config, options = {})
      super(url_or_config, options)
      require 'dashboard-api'

      Puppet.debug "Trying to connect to Meraki Dashboard with network id #{config['dashboard_network_id']}"
      @networkid = config['dashboard_network_id']
      @dashboard_api_key = config['dashboard_api_key']
      @dapi = DashboardAPI.new(@dashboard_api_key)
    end

    def facts
      network = dapi.get_single_network(@networkid)
      @orgid = network['organizationId']
      { 'operatingsystem' => 'meraki_network',
        'meraki_network' => network,
        'meraki_network_id' => @networkid,
        'meraki_network_name' => network['name'],
        'meraki_network_organizationid' => network['organizationId'],
        'meraki_network_tags' => network['tags'],
        'meraki_network_timezone' => network['timeZone'],
        'meraki_network_type' => network['type'],
        'meraki_org_id' => @orgid,
        'meraki_org_name' => @dapi.get_organization(@orgid)['name'],
        'meraki_license_state' => @dapi.get_license_state(@orgid) }
    end
  end
end
