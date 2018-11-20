require 'spec_helper'
require 'dashboard-api'
require 'puppet/util/network_device/meraki_organization/device'

RSpec.describe Puppet::Util::NetworkDevice::Meraki_organization::Device do
  subject(:device) { described_class.new(credentials) }

  let(:credentials) { { 'dashboard_org_id' => 'abc1234', 'dashboard_api_key' => 'xyz5678' } }

  describe 'when connecting to a new device' do
    it 'device connects with valid credentials' do
      expect(Puppet).to receive(:debug).with('Trying to connect to Meraki Dashboard with org id abc1234')
      expect(DashboardAPI).to receive(:new).with 'xyz5678'
      device
    end
  end

  describe 'device returns facts' do
    let(:dapi) { instance_double(DashboardAPI) }

    it 'device returns facts' do
      expect(Puppet).to receive(:debug).with('Trying to connect to Meraki Dashboard with org id abc1234')
      expect(DashboardAPI).to receive(:new).with('xyz5678').and_return(dapi)
      expect(dapi).to receive(:get_organization).with('abc1234').and_return('name' => 'test')
      expect(dapi).to receive(:get_license_state).with('abc1234').and_return(status: 'OK')
      expect(device.facts)
        .to eq('operatingsystem' => 'meraki_organization', 'meraki_org_id' => 'abc1234', 'meraki_org_name' => 'test', 'meraki_license_state' => { status: 'OK' })
    end
  end
end
