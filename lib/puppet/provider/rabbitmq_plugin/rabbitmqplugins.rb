require 'puppet/util/package'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'rabbitmq_cli'))
Puppet::Type.type(:rabbitmq_plugin).provide(:rabbitmqplugins, parent: Puppet::Provider::RabbitmqCli) do
  confine feature: :posix

  def self.plugin_list
    list_str = run_with_retries do
      # Pass in -e to list both implicitly and explicitly enabled plugins.
      # If you pass in -E instead, then only explicitly enabled plugins are listed.
      # Implicitly enabled plugins are those that were enabled as a dependency of another plugin/
      # If we do not pass in -e then the order if plugin installation matters within the puppet
      # code. Example, if Plugin A depends on Plugin B and we install Plugin B first it will
      # implicitly enable Plugin A. Then when we go to run Puppet a second time without the
      # -e parameter, we won't see Plugin A as being enabled so we'll try to install it again.
      # To preserve idempotency we should get all enabled plugins regardless of implicitly or
      # explicitly enabled.
      rabbitmqplugins('list', '-e', '-m')
    end
    # Split by newline.
    lines = list_str.split(%r{\n})
    # Return only lines that are single words because sometimes RabbitMQ likes to output
    # information messages. Suppressing those messages via CLI flags is inconsistent between
    # versions, so this this regex removes those message without having to use painful
    # version switches.
    lines.select { |line| line =~ %r{^(\S+)$} }
  end

  def self.instances
    plugin_list.map do |line|
      raise Puppet::Error, "Cannot parse invalid plugins line: #{line}" unless line =~ %r{^(\S+)$}
      new(name: Regexp.last_match(1))
    end
  end

  def create
    cmd = ['enable', resource[:name]]
    # rabbitmq>=3.4.0 - check if node running, if not, ignore this option
    cmd << "--#{resource[:mode]}" if self.class.rabbitmq_running && Puppet::Util::Package.versioncmp(self.class.rabbitmq_version, '3.4') >= 0 && resource[:mode] != :best

    if resource[:umask].nil?
      rabbitmqplugins(*cmd)
    else
      Puppet::Util.withumask(resource[:umask]) { rabbitmqplugins(*cmd) }
    end
  end

  def destroy
    rabbitmqplugins('disable', resource[:name])
  end

  def exists?
    self.class.plugin_list.include? resource[:name]
  end
end
