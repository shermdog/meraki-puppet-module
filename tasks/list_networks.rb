#!/opt/puppetlabs/puppet/bin/ruby

require 'dashboard-api'
require 'json'

# Input
args = JSON.parse(STDIN.read)

dapi = DashboardAPI.new(args['key'])

# Look for networks in specific org or all key has access to
orgs = args['organization'] ? [args['organization']] : dapi.list_all_organizations.map { |org| org['id'] }

begin
  output = { 'networks' => [] }
  for org in orgs do
    dapi.get_networks(org).each {|network| output['networks'] << network}
  end

  output['status'] = 'success'
  puts(output.to_json)
  exit 0

rescue RuntimeError => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
