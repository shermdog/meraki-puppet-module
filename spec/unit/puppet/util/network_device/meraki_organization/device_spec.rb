require 'spec_helper'

require 'puppet/util/network_device/meraki_organization/device'

RSpec.describe Puppet::Util::NetworkDevice::Meraki_organization::Device do
  subject(:device) { described_class }

  describe 'when connecting to a new device' do
    it 'device rejects non file url' do
      expect { device.device('https://puppet.com') }
        .to raise_error(RuntimeError, 'Unexpected url \'https://puppet.com\' found. Only file:/// URLs for configuration supported at the moment.')
    end

    it 'device connects with valid HOCON' do
      allow(File).to receive(:exist?).and_return true
      expect(Hocon).to receive(:load).and_return('default' => { 'node' => { 'dashboard_org_id' => 'abc1234', 'dashboard_api_key' => 'xyz5678' } })
      expect(Puppet).to receive(:debug).with('Trying to connect to Meraki Dashboard with org id abc1234')
      expect(DashboardAPI).to receive(:new).with 'xyz5678'
      device.device('file:///test.conf')
    end
  end

  describe 'device returns facts' do
    let(:dapi) { instance_double(DashboardAPI) }

    it 'device returns facts' do
      allow(File).to receive(:exist?).and_return true
      expect(Hocon).to receive(:load).and_return('default' => { 'node' => { 'dashboard_org_id' => 'abc1234', 'dashboard_api_key' => 'xyz5678' } })
      expect(Puppet).to receive(:debug).with('Trying to connect to Meraki Dashboard with org id abc1234')
      expect(DashboardAPI).to receive(:new).with('xyz5678').and_return(dapi)
      expect(dapi).to receive(:get_organization).with('abc1234').and_return('name' => 'test')
      expect(dapi).to receive(:get_license_state).with('abc1234').and_return(status: 'OK')
      expect(device.device('file:///test.conf').facts)
        .to eq('operatingsystem' => 'meraki_organization', 'meraki_org_id' => 'abc1234', 'meraki_org_name' => 'test', 'meraki_license_state' => { status: 'OK' })
    end
  end
end
