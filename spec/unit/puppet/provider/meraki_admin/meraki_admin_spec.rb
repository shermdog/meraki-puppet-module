require 'spec_helper'

# TODO: needs some cleanup/helper to avoid this misery
module Puppet::Provider::MerakiAdmin; end
require 'puppet/provider/meraki_admin/meraki_admin'

RSpec.describe Puppet::Provider::MerakiAdmin::MerakiAdmin do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:cisco_meraki) { instance_double('Puppet::Util::NetworkDevice::Cisco_meraki::device', 'cisco_meraki') }

  describe '#set' do
  end

  describe '#get' do
  end

  describe '#create' do
  end

  describe '#update' do
  end

  describe '#delete' do
  end

end
