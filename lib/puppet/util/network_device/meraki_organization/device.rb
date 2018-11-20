require 'puppet/util/network_device/simple/device'

module Puppet::Util::NetworkDevice::Meraki_organization
  class Device < Puppet::Util::NetworkDevice::Simple::Device
    attr_reader :dapi, :orgid

    def initialize(url_or_config, options = {})
      super(url_or_config, options)
      require 'dashboard-api'

      Puppet.debug "Trying to connect to Meraki Dashboard with org id #{config['dashboard_org_id']}"
      @orgid = config['dashboard_org_id']
      @dashboard_api_key = config['dashboard_api_key']
      @dapi = DashboardAPI.new(@dashboard_api_key)
    end

    def facts
      { 'operatingsystem' => 'meraki_organization',
        'meraki_org_id' => @orgid,
        'meraki_org_name' => @dapi.get_organization(@orgid)['name'],
        'meraki_license_state' => @dapi.get_license_state(@orgid) }
    end
  end
end
