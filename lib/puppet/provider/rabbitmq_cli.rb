class Puppet::Provider::RabbitmqCli < Puppet::Provider
  initvars

  def self.append_to_path(dir)
    path = get_env 'PATH'
    # Don't append to the PATH if the directory is already in it. Otherwise, if
    # multiple providers run in the same process it may result in the
    # environment being modified multiple times.
    return if path.split(File::PATH_SEPARATOR).include? dir

    set_env 'PATH', [path, dir].join(File::PATH_SEPARATOR)
  end
  private_class_method :append_to_path

  # On most platforms, the RabbitMQ CLI programs are available in the PATH under
  # /usr/sbin. On some older platforms (CentOS 6), they are only available at
  # /usr/lib/rabbitmq/bin. We can't detect which because at the time this file
  # is evaluated, RabbitMQ might not yet be installed. However, if a command is
  # specified by name (instead of absolute path), Puppet searches the PATH
  # before each execution of the command. Append /usr/lib/rabbitmq/bin to the
  # end of the PATH so that Puppet will look there last at the time a command is
  # executed. This is the best I can come up with short of fragile meta-
  # programming with Puppet internals.
  append_to_path '/usr/lib/rabbitmq/bin'

  def self.home_tmp_command(name, path)
    has_command name, path do
      environment HOME: '/tmp', LC_ALL: 'en_US.UTF-8'
    end
  end

  home_tmp_command :rabbitmqctl, 'rabbitmqctl'
  home_tmp_command :rabbitmqplugins, 'rabbitmq-plugins'

  home_tmp_command :rabbitmqadmin, '/usr/local/bin/rabbitmqadmin'

  def self.rabbitmq_version
    return @rabbitmq_version if defined? @rabbitmq_version

    output = rabbitmqctl('-q', 'status')
    version = output.match(%r{(?:\{rabbit,"RabbitMQ","|RabbitMQ version: )([\d\.]+)})
    @rabbitmq_version = version[1] if version
    @rabbitmq_version
  end

  def self.rabbitmqctl_list(resource, *opts)
    version = rabbitmq_version
    list_opts =
      if version && Puppet::Util::Package.versioncmp(version, '3.7.9') >= 0
        ['-q', '--no-table-headers']
      else
        ['-q']
      end
    rabbitmqctl("list_#{resource}", *list_opts, *opts)
  end

  def self.rabbitmq_running
    rabbitmqctl('-q', 'status')
    return true
  rescue Puppet::ExecutionFailure, Timeout::Error
    return false
  end

  # Retry the given code block 'count' retries or until the
  # command succeeds. Use 'step' delay between retries.
  # Limit each query time by 'timeout'.
  # For example:
  #   users = self.class.run_with_retries { rabbitmqctl 'list_users' }
  def self.run_with_retries(count = 30, step = 6, timeout = 10)
    count.times do |_n|
      begin
        output = Timeout.timeout(timeout) do
          yield
        end
      rescue Puppet::ExecutionFailure, Timeout::Error
        Puppet.debug 'Command failed, retrying'
        sleep step
      else
        Puppet.debug 'Command succeeded'
        return output
      end
    end
    raise Puppet::Error, "Command is still failing after #{count * step} seconds expired!"
  end

  def self.define_instance_method(name)
    return if method_defined?(name)
    define_method(name) do |*args, &block|
      self.class.send(name, *args, &block)
    end
  end
  private_class_method :define_instance_method

  define_instance_method :rabbitmqctl_list
  define_instance_method :run_with_retries
end
