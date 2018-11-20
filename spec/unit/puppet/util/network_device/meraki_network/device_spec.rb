require 'spec_helper'
require 'dashboard-api'
require 'puppet/util/network_device/meraki_network/device'

RSpec.describe Puppet::Util::NetworkDevice::Meraki_network::Device do
  subject(:device) { described_class.new(credentials) }

  let(:credentials) { { 'dashboard_network_id' => 'abc1234', 'dashboard_api_key' => 'xyz5678' } }

  describe 'when connecting to a new device' do
    it 'device connects with valid credentials' do
      expect(Puppet).to receive(:debug).with('Trying to connect to Meraki Dashboard with network id abc1234')
      expect(DashboardAPI).to receive(:new).with 'xyz5678'
      device
    end
  end

  describe 'device returns facts' do
    let(:dapi) { instance_double(DashboardAPI) }

    it 'device returns facts' do
      expect(Puppet).to receive(:debug).with('Trying to connect to Meraki Dashboard with network id abc1234')
      expect(DashboardAPI).to receive(:new).with('xyz5678').and_return(dapi)
      expect(dapi).to receive(:get_single_network).with('abc1234').and_return('id' => 'abc1234',
                                                                              'name' => 'Sandbox',
                                                                              'organizationId' => 'abc1234',
                                                                              'tags' => 'Tag1',
                                                                              'timeZone' => 'America/Los_Angeles',
                                                                              'type' => 'combined')
      expect(dapi).to receive(:get_organization).with('abc1234').and_return('name' => 'test')
      expect(dapi).to receive(:get_license_state).with('abc1234').and_return(status: 'OK')
      expect(device.facts)
        .to eq('operatingsystem' => 'meraki_network',
               'meraki_network' => { 'id' => 'abc1234', 'name' => 'Sandbox', 'organizationId' => 'abc1234', 'tags' => 'Tag1', 'timeZone' => 'America/Los_Angeles', 'type' => 'combined' },
               'meraki_network_id' => 'abc1234',
               'meraki_network_name' => 'Sandbox',
               'meraki_network_organizationid' => 'abc1234',
               'meraki_network_tags' => 'Tag1',
               'meraki_network_timezone' => 'America/Los_Angeles',
               'meraki_network_type' => 'combined',
               'meraki_org_id' => 'abc1234',
               'meraki_org_name' => 'test',
               'meraki_license_state' => { status: 'OK' })
    end
  end
end
