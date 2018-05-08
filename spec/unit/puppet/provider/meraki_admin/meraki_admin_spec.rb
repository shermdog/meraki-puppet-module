require 'spec_helper'

# TODO: needs some cleanup/helper to avoid this misery
module Puppet::Provider::MerakiAdmin; end
require 'puppet/provider/meraki_admin/meraki_admin'

RSpec.describe Puppet::Provider::MerakiAdmin::MerakiAdmin do
  subject(:provider) { described_class.new }

  # Set up mocks
  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Meraki_organization::device', 'device') }
  let(:dapi) { instance_double('DashboardAPI', 'dapi') }

  # Allow mocks to be called
  before(:each) do
    allow(context).to receive(:device).and_return(device)
    allow(device).to receive(:dapi).and_return(dapi)
    allow(device).to receive(:orgid).and_return('1234')
  end

  # Validate that the type loads
  describe 'the meraki_admin type' do
    it 'loads' do
      expect(Puppet::Type.type(:meraki_admin)).not_to be_nil
    end
  end

  # Because this provdier does not use SimpleProvider we have to build our our set
  # We test `set` and c/r/u/d responsibilities separatly: # rubocop:disable RSpec/SubjectStub"
  describe '#set' do
    context 'set determines create/update/delete' do
      it 'creates when currently absent and desired state is present' do
        # Expect that the context is set to creating
        # Puppet resource api does metaprogramming for create/update/delete and does a block.call
        expect(context).to receive(:creating).with('shermdog@puppet.com').once.and_yield
        # Expect that set is calling create
        expect(provider).to receive(:create).with(context, 'shermdog@puppet.com',
                                                  email: 'shermdog@puppet.com',
                                                  ensure: 'present',
                                                  fullname: 'Rick Sherman',
                                                  orgaccess: 'full',
                                                  networks: [],
                                                  tags: []).once

        # Call set with type that should be created
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

      it 'updates when currently present and desired state is present' do
        # Expect that the context is set to updating
        # Puppet resource api does metaprogramming for create/update/delete and does a block.call
        expect(context).to receive(:updating).with('shermdog@puppet.com').once.and_yield
        # Expect that set is calling create
        expect(provider).to receive(:update).with(context, 'shermdog@puppet.com', '78910',
                                                  email: 'shermdog@puppet.com',
                                                  ensure: 'present',
                                                  fullname: 'Rick Sherman',
                                                  orgaccess: 'full',
                                                  networks: [{ 'id' => '123', 'access' => 'full' }],
                                                  tags: [{ 'tag' => 'Sandbox', 'access' => 'full' }]).once

        # Call set with type that should be created
        provider.set(context, 'shermdog@puppet.com' => { is: { email: 'shermdog@puppet.com',
                                                               id: '78910',
                                                               ensure: 'present',
                                                               fullname: 'Other name',
                                                               orgaccess: 'read-only',
                                                               networks: [{ 'id' => '123', 'access' => 'read-only' }],
                                                               tags: [{ 'tag' => 'Sandbox', 'access' => 'read-only' }] },
                                                         should: {
                                                           email: 'shermdog@puppet.com',
                                                           ensure: 'present',
                                                           fullname: 'Rick Sherman',
                                                           orgaccess: 'full',
                                                           networks: [{ 'id' => '123', 'access' => 'full' }],
                                                           tags: [{ 'tag' => 'Sandbox', 'access' => 'full' }],
                                                         } })
      end

      it 'deletes when currently present and desired state is absent' do
        # Expect that the context is set to deleting
        # Puppet resource api does metaprogramming for create/update/delete and does a block.call
        expect(context).to receive(:deleting).with('shermdog@puppet.com').once.and_yield
        # Expect that set is calling create
        expect(provider).to receive(:delete).with(context, '78910').once

        # Call set with type that should be created
        provider.set(context, 'shermdog@puppet.com' => { is: { email: 'shermdog@puppet.com',
                                                               id: '78910',
                                                               ensure: 'present',
                                                               fullname: 'Rick Sherman',
                                                               orgaccess: 'full',
                                                               networks: [{ 'id' => '123', 'access' => 'full' }],
                                                               tags: [{ 'tag' => 'Sandbox', 'access' => 'full' }] },
                                                         should: {
                                                           email: 'shermdog@puppet.com',
                                                           ensure: 'absent',
                                                           fullname: 'Rick Sherman',
                                                           orgaccess: 'full',
                                                           networks: [{ 'id' => '123', 'access' => 'full' }],
                                                           tags: [{ 'tag' => 'Sandbox', 'access' => 'full' }],
                                                         } })
      end
    end
  end

  describe '#get' do
    context 'get resource instance' do
      it 'calls dashboard_api and returns instance with puppet attributes' do
        # Expect dashboard_api will be called with list_admins and orgId
        expect(dapi).to receive(:list_admins).with('1234')
          .once.and_return([{
                             'name' => 'Rick Sherman',
                             'email' => 'shermdog@puppet.com',
                             'id' => '78910',
                             'networks' => [{ 'id' => '123', 'access' => 'full' }],
                             'tags' => [{ 'tag' => 'Sandbox', 'access' => 'full' }],
                             'orgAccess' => 'full',
                           }])

        # Call get with context
        # Ensure that array values are returned sorted
        expect(provider.get(context)).to eq([{
                                              fullname: 'Rick Sherman',
                                              ensure: 'present',
                                              email: 'shermdog@puppet.com',
                                              id: '78910',
                                              orgaccess: 'full',
                                              networks: [{ 'id' => '123', 'access' => 'full' }],
                                              tags: [{ 'tag' => 'Sandbox', 'access' => 'full' }],
                                            }])
      end
    end
  end

  # Test the create function of the provider
  describe '#create' do
    context 'when the resource is created' do
      it 'create munges values and calls add_admin' do
        expect(dapi).to receive(:add_admin).with('1234',
                                                 email: 'shermdog@puppet.com',
                                                 name: 'Rick Sherman',
                                                 orgAccess: 'read-only',
                                                 networks: [{ 'id' => '123', 'access' => 'full' }],
                                                 tags: [{ 'tag' => 'Sandbox', 'access' => 'full' }]).once

        # Call create with Puppet type values
        provider.create(context, 'shermdog@puppet.com',
                        email: 'shermdog@puppet.com',
                        ensure: 'present',
                        fullname: 'Rick Sherman',
                        orgaccess: 'read-only',
                        networks: [{ 'id' => '123', 'access' => 'full' }],
                        tags: [{ 'tag' => 'Sandbox', 'access' => 'full' }])
      end
    end
  end

  # Test the update function of the provider
  describe '#update' do
    context 'when there are changes to be made' do
      it 'update munges values and calls update_admin' do
        expect(dapi).to receive(:update_admin).with('1234', '78910',
                                                    email: 'shermdog@puppet.com',
                                                    id: '78910',
                                                    name: 'Rick Sherman',
                                                    orgAccess: 'read-only',
                                                    networks: [{ 'id' => '123', 'access' => 'full' }, { 'id' => '567', 'access' => 'read-only' }],
                                                    tags: [{ 'tag' => 'Sandbox', 'access' => 'full' }, { 'tag' => 'branch', 'access' => 'full' }]).once

        # Call update with Puppet type values
        provider.update(context, 'shermdog@puppet.com', '78910',
                        email: 'shermdog@puppet.com',
                        ensure: 'present',
                        fullname: 'Rick Sherman',
                        id: '78910',
                        orgaccess: 'read-only',
                        networks: [{ 'id' => '123', 'access' => 'full' }, { 'id' => '567', 'access' => 'read-only' }],
                        tags: [{ 'tag' => 'Sandbox', 'access' => 'full' }, { 'tag' => 'branch', 'access' => 'full' }])
      end
    end
  end

  # Test the delete function of the provider
  describe '#delete' do
    context 'when resource is to be deleted' do
      it 'delete calls revoke_admin with proper attributes' do
        expect(dapi).to receive(:revoke_admin).with('1234', '78910').once

        # Call update with Puppet type values
        provider.delete(context, '78910')
      end
    end
  end

  # Test the canonicalize function of the provider
  # canonicalize is called outside of the provider.  After get and before set
  describe '#canonicalize' do
    context 'munges the resources as expected' do
      it 'sorts the arrays by hash key values' do
        expect(provider.canonicalize(context, [{ fullname: 'Rick Sherman',
                                                 ensure: 'present',
                                                 email: 'shermdog@puppet.com',
                                                 id: '78910',
                                                 orgaccess: 'full',
                                                 networks: [{ 'id' => '567', 'access' => 'read-only' }, { 'id' => '123', 'access' => 'full' }],
                                                 tags: [{ 'tag' => 'branch', 'access' => 'full' }, { 'tag' => 'Sandbox', 'access' => 'full' }] }]))
          .to eq([{ fullname: 'Rick Sherman',
                    ensure: 'present',
                    email: 'shermdog@puppet.com',
                    id: '78910',
                    orgaccess: 'full',
                    networks: [{ 'id' => '123', 'access' => 'full' }, { 'id' => '567', 'access' => 'read-only' }],
                    tags: [{ 'tag' => 'Sandbox', 'access' => 'full' }, { 'tag' => 'branch', 'access' => 'full' }] }])
      end
    end
  end
end
