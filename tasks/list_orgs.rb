#!/opt/puppetlabs/puppet/bin/ruby

require 'dashboard-api'
require 'json'

# Input
args = JSON.parse(STDIN.read)

dapi = DashboardAPI.new(args['key'])

begin
  output = { 'organizations' => dapi.list_all_organizations }
  output['status'] = 'success'
  puts(output.to_json)
  exit 0
rescue RuntimeError => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end
