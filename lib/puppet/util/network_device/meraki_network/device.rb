require 'uri'
require 'hocon'
require 'hocon/config_syntax'
require 'puppet/util/network_device/base'

module Puppet::Util::NetworkDevice::Meraki_network
  # A basic device class, that reads its configuration from the provided URL.
  # The URL has to be a local file URL.
  class Device
    attr_reader :dapi, :networkid, :orgid

    def initialize(url, _options = {})
      require 'dashboard-api'
      @url = URI.parse(url)
      raise "Unexpected url '#{url}' found. Only file:/// URLs for configuration supported at the moment." unless @url.scheme == 'file'

      Puppet.debug "Trying to connect to Meraki Dashboard with network id #{config['default']['node']['dashboard_network_id']}"
      @networkid = config['default']['node']['dashboard_network_id']
      @dashboard_api_key = config['default']['node']['dashboard_api_key']
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

    def config
      raise "Trying to load config from '#{@url.path}, but file does not exist." unless File.exist? @url.path
      @config ||= Hocon.load(@url.path, syntax: Hocon::ConfigSyntax::HOCON)
    end

    def self.device(url)
      Puppet::Util::NetworkDevice::Meraki_network::Device.new(url)
    end

    class << self
      attr_reader :connection
    end
  end
end
