require 'spec_helper'
describe 'the meraki_admin type' do
  it 'loads' do
    expect(Puppet::Type.type(:meraki_admin)).not_to be_nil
  end
end