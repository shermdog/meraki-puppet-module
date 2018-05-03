require 'puppet/resource_api'
require 'puppet/resource_api/simple_provider'

require_relative('../../util/network_device/meraki_network/device')

# Implementation for the meraki_admin type using the Resource API.
class Puppet::Provider::MerakiVlan::MerakiVlan < Puppet::ResourceApi::SimpleProvider
  def get(context)
    vlans = context.device.dapi.list_vlans(context.device.networkid)
    instances = []
    return [] if vlans.nil?

    vlans.map do |vlan|
      instances << {
        id: vlan['id'].to_s,
        ensure: 'present',
        description: vlan['name'],
        subnet: vlan['subnet'],
        applianceip: vlan['applianceIp'],
        fixedipassignments: !vlan['fixedIpAssignments'].empty? ? vlan['fixedIpAssignments'] : nil,
        reservedipranges: !vlan['reservedIpRanges'].empty? ? vlan['reservedIpRanges'] : nil,
        dnsnameservers: vlan['dnsNameservers'],
        vpnnatsubnet: vlan['vpnNatSubnet'],
      }.delete_if { |_k, v| v.nil? }
    end
    instances
  end

  def munge_puppet(should)
    # convert puppet attr names to meraki api names
    # this can be optimized later
    should.delete(:ensure)
    should[:name] = should.delete(:description)
    should[:applianceIp] = should.delete(:applianceip)
    should[:fixedIpAssignments] = should.delete(:fixedipassignments) if should[:fixedipassignments]
    should[:reservedIpRanges] = should.delete(:reservedipranges) if should[:reservedipranges]
    should[:vpnNatSubnet] = should.delete(:vpnnatsubnet) if should[:vpnnatsubnet]
    should[:dnsNameservers] = should.delete(:dnsnameservers)
    should
  end

  def create(context, _id, should)
    munge_puppet(should)
    context.device.dapi.add_vlan(context.device.networkid, should)
  end

  def update(context, id, should)
    munge_puppet(should)
    context.device.dapi.update_vlan(context.device.networkid, id, should)
  end

  def delete(context, id)
    context.device.dapi.delete_vlan(context.device.networkid, id)
  end
end
