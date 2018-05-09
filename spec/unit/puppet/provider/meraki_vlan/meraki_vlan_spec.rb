require 'spec_helper'

# TODO: needs some cleanup/helper to avoid this misery
module Puppet::Provider::MerakiVlan; end
require 'puppet/provider/meraki_vlan/meraki_vlan'

RSpec.describe Puppet::Provider::MerakiVlan::MerakiVlan do
  subject(:provider) { described_class.new }

  # Set up mocks
  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Meraki_network::device', 'device') }
  let(:dapi) { instance_double('DashboardAPI', 'dapi') }

  # Allow mocks to be called
  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:dapi).and_return(dapi)
    allow(device).to receive(:networkid).and_return('5555')
  end

  # Validate that the type loads
  describe 'the meraki_admin type' do
    it 'loads' do
      expect(Puppet::Type.type(:meraki_vlan)).not_to be_nil
    end
  end

  # Test the canonicalize function of the provider
  # canonicalize is called outside of the provider.  After get and before set
  describe '#canonicalize' do
    context 'munges the resources as expected' do
      it 'sorts the arrays by hash key values' do
        expect(provider.canonicalize(context, [{ id: '40',
                                                 fixedipassignments: {
                                                   '52:54:00:e3:5d:3d' => { 'ip' => '10.0.40.54', 'name' => 'test_cliane' },
                                                   '52:54:00:e3:5d:4d' => { 'ip' => '10.0.40.53', 'name' => 'testmoar' },
                                                 },
                                                 reservedipranges: [
                                                   { 'start' => '10.0.40.70', 'end' => '10.0.40.75', 'comment' => 'test 3' },
                                                   { 'start' => '10.0.40.50', 'end' => '10.0.40.59', 'comment' => 'test 1' },
                                                 ] }]))
          .to eq([{ id: '40',
                    fixedipassignments: {
                      '52:54:00:e3:5d:3d' => { 'ip' => '10.0.40.54', 'name' => 'test_cliane' },
                      '52:54:00:e3:5d:4d' => { 'ip' => '10.0.40.53', 'name' => 'testmoar' },
                    },
                    reservedipranges: [
                      { 'start' => '10.0.40.50', 'end' => '10.0.40.59', 'comment' => 'test 1' },
                      { 'start' => '10.0.40.70', 'end' => '10.0.40.75', 'comment' => 'test 3' },
                    ] }])
      end
      it 'handles unset' do
        expect(provider.canonicalize(context, [{ id: '40',
                                                 fixedipassignments: 'unset',
                                                 reservedipranges: 'unset' }]))
          .to eq([{ id: '40',
                    fixedipassignments: {},
                    reservedipranges: [] }])
      end
    end
  end

  # Test the munge_puppet function of the provider
  describe '#munge_puppet' do
    it 'converts puppet key names to meraki' do
      expect(provider.munge_puppet(
               id: '40',
               description: 'test',
               subnet: '10.0.40.0/24',
               applianceip: '10.0.40.1',
               fixedipassignments: { '52:54:00:e3:5d:3d' => { 'ip' => '10.0.40.54', 'name' => 'test_client' } },
               reservedipranges: { 'start' => '10.0.40.50', 'end' => '10.0.40.59', 'comment' => 'test 1' },
               dnsnameservers: 'upstream_dns',
               vpnnatsubnet: '10.0.40.0/24',
      )).to eq(id: '40',
               name: 'test',
               subnet: '10.0.40.0/24',
               applianceIp: '10.0.40.1',
               fixedIpAssignments: { '52:54:00:e3:5d:3d' => { 'ip' => '10.0.40.54', 'name' => 'test_client' } },
               reservedIpRanges: { 'start' => '10.0.40.50', 'end' => '10.0.40.59', 'comment' => 'test 1' },
               dnsNameservers: 'upstream_dns',
               vpnNatSubnet: '10.0.40.0/24')
    end

    it 'handles unset' do
      expect(provider.munge_puppet(
               id: '40',
               description: 'test',
               subnet: '10.0.40.0/24',
               applianceip: '10.0.40.1',
               fixedipassignments: 'unset',
               reservedipranges: 'unset',
               dnsnameservers: 'upstream_dns',
      )).to eq(id: '40',
               name: 'test',
               subnet: '10.0.40.0/24',
               applianceIp: '10.0.40.1',
               fixedIpAssignments: {},
               reservedIpRanges: {},
               dnsNameservers: 'upstream_dns')
    end

    it 'converts reservedipranges empty array to empty hash' do
      expect(provider.munge_puppet(
               id: '40',
               description: 'test',
               subnet: '10.0.40.0/24',
               applianceip: '10.0.40.1',
               fixedipassignments: {},
               reservedipranges: [],
               dnsnameservers: 'upstream_dns',
      )).to eq(id: '40',
               name: 'test',
               subnet: '10.0.40.0/24',
               applianceIp: '10.0.40.1',
               fixedIpAssignments: {},
               reservedIpRanges: {},
               dnsNameservers: 'upstream_dns')
    end
  end

  # Test the get function of the provider
  describe '#get' do
    context 'get resource instance' do
      it 'calls dashboard_api and returns instance with puppet attributes' do
        # Expect dashboard_api will be called with list_vlans and networkId
        expect(dapi).to receive(:list_vlans).with('5555')
          .once.and_return([{ 'id' => 40,
                              'networkId' => '5555',
                              'name' => 'test',
                              'applianceIp' => '10.0.40.1',
                              'subnet' => '10.0.40.0/24',
                              'fixedIpAssignments' => {
                                '52:54:00:e3:5d:3d' => { 'ip' => '10.0.40.54', 'name' => 'test_cliane' },
                                '52:54:00:e3:5d:4d' => { 'ip' => '10.0.40.53', 'name' => 'testmoar' },
                              },
                              'reservedIpRanges' => [
                                { 'start' => '10.0.40.50', 'end' => '10.0.40.59', 'comment' => 'test 1' },
                                { 'start' => '10.0.40.70', 'end' => '10.0.40.75', 'comment' => 'test 3' },
                              ],
                              'dnsNameservers' => 'upstream_dns',
                              'vpnNatSubnet' => '10.0.40.0/24' }])

        # Call get with context
        expect(provider.get(context)).to eq([{
                                              id: '40',
                                              ensure: 'present',
                                              description: 'test',
                                              subnet: '10.0.40.0/24',
                                              applianceip: '10.0.40.1',
                                              fixedipassignments: {
                                                '52:54:00:e3:5d:3d' => { 'ip' => '10.0.40.54', 'name' => 'test_cliane' },
                                                '52:54:00:e3:5d:4d' => { 'ip' => '10.0.40.53', 'name' => 'testmoar' },
                                              },
                                              reservedipranges: [
                                                { 'start' => '10.0.40.50', 'end' => '10.0.40.59', 'comment' => 'test 1' },
                                                { 'start' => '10.0.40.70', 'end' => '10.0.40.75', 'comment' => 'test 3' },
                                              ],
                                              dnsnameservers: 'upstream_dns',
                                              vpnnatsubnet: '10.0.40.0/24',
                                            }])
      end
    end
  end

  # Test the create function of the provider
  describe '#create' do
    context 'when the resource is created' do
      it 'create munges values and calls add_vlan' do
        expect(dapi).to receive(:add_vlan).with('5555',
                                                id: '40',
                                                name: 'test',
                                                subnet: '10.0.40.0/24',
                                                applianceIp: '10.0.40.1',
                                                fixedIpAssignments: {
                                                  '52:54:00:e3:5d:3d' => { 'ip' => '10.0.40.54', 'name' => 'test_cliane' },
                                                  '52:54:00:e3:5d:4d' => { 'ip' => '10.0.40.53', 'name' => 'testmoar' },
                                                },
                                                reservedIpRanges: [
                                                  { 'start' => '10.0.40.50', 'end' => '10.0.40.59', 'comment' => 'test 1' },
                                                  { 'start' => '10.0.40.70', 'end' => '10.0.40.75', 'comment' => 'test 3' },
                                                ],
                                                dnsNameservers: 'upstream_dns',
                                                vpnNatSubnet: '10.0.40.0/24').once

        # Call create with Puppet type values
        provider.create(context, '40',
                        id: '40',
                        ensure: 'present',
                        description: 'test',
                        subnet: '10.0.40.0/24',
                        applianceip: '10.0.40.1',
                        fixedipassignments: {
                          '52:54:00:e3:5d:3d' => { 'ip' => '10.0.40.54', 'name' => 'test_cliane' },
                          '52:54:00:e3:5d:4d' => { 'ip' => '10.0.40.53', 'name' => 'testmoar' },
                        },
                        reservedipranges: [
                          { 'start' => '10.0.40.50', 'end' => '10.0.40.59', 'comment' => 'test 1' },
                          { 'start' => '10.0.40.70', 'end' => '10.0.40.75', 'comment' => 'test 3' },
                        ],
                        dnsnameservers: 'upstream_dns',
                        vpnnatsubnet: '10.0.40.0/24')
      end
    end
  end

  # Test the update function of the provider
  describe '#update' do
    context 'when there are changes to be made' do
      it 'update munges values and calls update_vlan' do
        # Expect dashboard_api will be called with update_vlan and munged values
        expect(dapi).to receive(:update_vlan).with('5555',
                                                   '40',
                                                   id: '40',
                                                   name: 'test',
                                                   subnet: '10.0.40.0/24',
                                                   applianceIp: '10.0.40.1',
                                                   fixedIpAssignments: {
                                                     '52:54:00:e3:5d:3d' => { 'ip' => '10.0.40.54', 'name' => 'test_cliane' },
                                                     '52:54:00:e3:5d:4d' => { 'ip' => '10.0.40.53', 'name' => 'testmoar' },
                                                   },
                                                   reservedIpRanges: [
                                                     { 'start' => '10.0.40.50', 'end' => '10.0.40.59', 'comment' => 'test 1' },
                                                     { 'start' => '10.0.40.70', 'end' => '10.0.40.75', 'comment' => 'test 3' },
                                                   ],
                                                   dnsNameservers: 'upstream_dns',
                                                   vpnNatSubnet: '10.0.40.0/24').once

        # Call update with Puppet type values
        provider.update(context, '40',
                        id: '40',
                        ensure: 'present',
                        description: 'test',
                        subnet: '10.0.40.0/24',
                        applianceip: '10.0.40.1',
                        fixedipassignments: {
                          '52:54:00:e3:5d:3d' => { 'ip' => '10.0.40.54', 'name' => 'test_cliane' },
                          '52:54:00:e3:5d:4d' => { 'ip' => '10.0.40.53', 'name' => 'testmoar' },
                        },
                        reservedipranges: [
                          { 'start' => '10.0.40.50', 'end' => '10.0.40.59', 'comment' => 'test 1' },
                          { 'start' => '10.0.40.70', 'end' => '10.0.40.75', 'comment' => 'test 3' },
                        ],
                        dnsnameservers: 'upstream_dns',
                        vpnnatsubnet: '10.0.40.0/24')
      end
    end
  end

  # Test the delete function of the provider
  describe '#delete' do
    context 'when resource is to be deleted' do
      it 'delete calls delete_vlan with proper attributes' do
        expect(dapi).to receive(:delete_vlan).with('5555', '40').once

        # Call update with Puppet type values
        provider.delete(context, '40')
      end
    end
  end
end
