require 'spec_helper'
describe 'the meraki_vlan type' do
  it 'loads' do
    expect(Puppet::Type.type(:meraki_vlan)).not_to be_nil
  end
end