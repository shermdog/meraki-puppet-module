require 'spec_helper'

# TODO: needs some cleanup/helper to avoid this misery
module Puppet::Provider::MerakiAdmin; end
require 'puppet/provider/meraki_admin/meraki_admin'

RSpec.describe Puppet::Provider::MerakiAdmin::MerakiAdmin do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Meraki_organization::device', 'device') }
  let(:dapi) { instance_double('DashboardAPI', 'dapi') }

  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:dapi).and_return(dapi)
    allow(device).to receive(:orgid).and_return('1234')
  end

  describe '#set' do
    context 'set determines create/update/delete' do
      it 'creates when currently absent and desired state is present' do
        expect(context).to receive(:creating).with('shermdog@puppet.com').once { |&block| block.call }
        expect(provider).to receive(:create).with(context, 'shermdog@puppet.com',
                                                  email: 'shermdog@puppet.com',
                                                  ensure: 'present',
                                                  fullname: 'Rick Sherman',
                                                  orgaccess: 'full',
                                                  networks: [],
                                                  tags: []).once

        provider.set(context, 'shermdog@puppet.com' => {  is: nil,
                                                          should: {
                                                            email: 'shermdog@puppet.com',
                                                            ensure: 'present',
                                                            fullname: 'Rick Sherman',
                                                            orgaccess: 'full',
                                                            networks: [],
                                                            tags: [],
                                                          } })
      end
    end
  end

  describe '#get' do
  end

  describe '#create' do
  end

  describe '#update' do
    context 'when there are changes to be made' do
      it 'update munges values and calls update_admin' do
        expect(dapi).to receive(:update_admin).with('1234', '78910',
                                                    email: 'shermdog@puppet.com',
                                                    id: '78910',
                                                    name: 'Rick Sherman',
                                                    orgAccess: 'read-only').once

        provider.update(context, 'shermdog@puppet.com', '78910',
                        email: 'shermdog@puppet.com',
                        ensure: 'present',
                        fullname: 'Rick Sherman',
                        id: '78910',
                        orgaccess: 'read-only')
      end
    end
  end

  describe '#delete' do
  end

end
