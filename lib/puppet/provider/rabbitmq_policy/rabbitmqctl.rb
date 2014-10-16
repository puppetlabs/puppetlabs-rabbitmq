Puppet::Type.type(:rabbitmq_policy).provide(:rabbitmqctl) do
  if Puppet::PUPPETVERSION.to_f < 3
    commands :rabbitmqctl => 'rabbitmqctl'
  else
     has_command(:rabbitmqctl, 'rabbitmqctl') do
       environment :HOME => "/tmp"
     end
  end

  mk_resource_methods
  defaultfor :feature => :posix

  def self.instances
    rabbitmqctl('list_vhosts').split(/\n/)[1..-2].collect do |vhost|
      rabbitmqctl('list_policies', '-p', vhost).split(/\n/)[1..-2].collect do |line|
        # /   federate mcollective exchanges  exchanges   ^(mcollective_|amq\\.)  {"federation-upstream-set":"all"}   0
        if line =~ /^(\S+)\s+(.+)\s+(\S+)\s+(\S+)\s(\S+)\s+(\S+)$/
          new(:name => $2, :ensure => :present, :vhost => $1, :apply_to => $3, :pattern => $4, :definition => JSON.parse($5), :priority => $6)
        else
          raise Puppet::Error, "Cannot parse invalid policy line: #{line}"
        end
      end
    end.flatten
  end
  def self.prefetch(resources)
    instances.each do |provider|
      if resource = resources[provider.name] then
        resource.provider = provider
      end
    end
  end

  def fixnumify obj
    if obj.respond_to? :to_i
      if "#{obj.to_i}" == obj
        obj.to_i
      else
        obj
      end
    elsif obj.is_a? Array
      obj.map {|item| fixnumify item }
    elsif obj.is_a? Hash
      obj.merge( obj ) {|k, val| fixnumify val }
    else
      obj
    end
  end

  def create
    rabbitmqctl('set_policy', '-p', resource[:vhost], '--apply-to', resource[:apply_to], resource[:name], resource[:pattern], fixnumify(resource[:definition]).to_json, '--priority', resource[:priority])
  end

  def destroy
    rabbitmqctl('clear_policy', '-p', resource[:vhost], resource[:name])
    @property_hash = {}  # used in conjunction with flush to avoid calling non-indempotent destroy twice
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def flush
    # flush is used purely in an update capacity
    # @property_hash is tested to avoid calling non-indempotent destroy twice
    if @property_hash == {}
      Puppet.debug 'hash empty - instance does not exist on system'
    elsif self.exists?
      self.create
    else
      self.destroy
    end
  end
end
