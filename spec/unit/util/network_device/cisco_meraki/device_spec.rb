require 'spec_helper'

# TODO: needs some cleanup/helper to avoid this misery
module Puppet::Util::NetworkDevice::Cisco_meraki; end
require 'puppet/util/network_device/cisco_meraki/device'

RSpec.describe Puppet::Util::NetworkDevice::Cisco_meraki::Device do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
end
