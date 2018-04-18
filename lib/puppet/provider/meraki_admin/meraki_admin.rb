require 'puppet/resource_api'
require 'puppet/resource_api/simple_provider'

require_relative('../../util/network_device/cisco_meraki/device')

# Implementation for the meraki_admin type using the Resource API.
class Puppet::Provider::MerakiAdmin::MerakiAdmin
  def set(context, changes)
    changes.each do |name, change|

      is = change[:is].nil? ? { name: name, ensure: 'absent' } : change[:is]
      should = change[:should].nil? ? { name: name, ensure: 'absent' } : change[:should]

      if is[:ensure].to_s == 'absent' && should[:ensure].to_s == 'present'
        context.creating(name) do
          create(context, name, should)
        end
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'present'
        context.updating(name) do
          update(context, name, is[:id], should)
        end
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'absent'
        context.deleting(name) do
          delete(context, is[:id])
        end
      end
    end
  end

  def get(context)
    instances = []
    admins = context.device.dapi.list_admins(context.device.orgid)

    return [] if admins.nil?

    admins.each do |admin|
      instances << { fullname: admin['name'],
                     ensure: 'present',
                     email: admin['email'],
                     id: admin['id'],
                     orgaccess: admin['orgAccess'],
                     networks: admin['networks'],
                     tags: admin['tags']
                   }
    end

    instances
  end

  def create(context, name, should)
    # convert puppet attr names to meraki api names
    should[:name] = should.delete(:fullname)
    should[:orgAccess] = should.delete(:orgaccess)

    context.device.dapi.add_admin(context.device.orgid, should)
  end

  def update(context, name, id, should)
    # convert puppet attr names to meraki api names
    should.delete(:ensure)
    should[:name] = should.delete(:fullname)
    should[:orgAccess] = should.delete(:orgaccess)

    context.device.dapi.update_admin(context.device.orgid, id, should)
  end

  def delete(context, id)
    context.device.dapi.revoke_admin(context.device.orgid, id)
  end
end
