require 'spec_helper'

# TODO: needs some cleanup/helper to avoid this misery
module Puppet::Util::NetworkDevice::Meraki_organization; end
require 'puppet/util/network_device/meraki_organization/device'

RSpec.describe Puppet::Util::NetworkDevice::Meraki_organization::Device do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
end
