require 'spec_helper'

provider_class = Puppet::Type.type(:rabbitmq_plugin).provider(:rabbitmqplugins)
describe provider_class do
  let(:resource) do
    Puppet::Type::Rabbitmq_plugin.new(
      name: 'foo'
    )
  end
  let(:provider) { provider_class.new(resource) }

  it 'calls rabbitmqplugins to enable when node not running' do
    provider.class.expects(:rabbitmq_running).returns false
    provider.expects(:rabbitmqplugins).with('enable', 'foo')
    provider.create
  end

  describe '#instances' do
    it 'exists' do
      expect(provider_class).to respond_to :instances
    end

    it 'retrieves instances' do
      provider.class.expects(:plugin_list).returns(%w[foo bar])
      instances = provider_class.instances
      instances_cmp = instances.map { |prov| { name: prov.get(:name) } }
      expect(instances_cmp).to eq(
        [
          { name: 'foo' },
          { name: 'bar' }
        ]
      )
    end

    it 'raises error on invalid line' do
      provider_class.expects(:plugin_list).returns(['  '])
      expect { provider_class.instances }.to raise_error Puppet::Error, %r{Cannot parse invalid plugins line}
    end
  end

  describe '#plugin_list' do
    it 'exists' do
      expect(provider_class).to respond_to :instances
    end

    it 'returns a list of plugins' do
      provider.class.expects(:rabbitmqplugins).with('list', '-e', '-m').returns("foo\nbar\nbaz\n")
      expect(provider.class.plugin_list).to eq(%w[foo bar baz])
    end

    it 'handles no training newline properly' do
      provider.class.expects(:rabbitmqplugins).with('list', '-e', '-m').returns("foo\nbar")
      expect(provider.class.plugin_list).to eq(%w[foo bar])
    end

    it 'handles lines that are not plugins ' do
      provider.class.expects(:rabbitmqplugins).with('list', '-e', '-m').returns("Listing plugins with pattern \".*\" ...\nfoo\nbar")
      expect(provider.class.plugin_list).to eq(%w[foo bar])
    end
  end

  describe '#exists?' do
    it 'matches existng plugins' do
      provider_class.expects(:plugin_list).returns(%w[foo])
      expect(provider.exists?).to eq(true)
    end

    it 'returns false for missing plugins' do
      provider_class.expects(:plugin_list).returns(%w[bar])
      expect(provider.exists?).to eq(false)
    end
  end

  context 'with RabbitMQ version >=3.4.0' do
    it 'calls rabbitmqplugins to enable' do
      provider.class.expects(:rabbitmq_version).returns '3.4.0'
      provider.class.expects(:rabbitmq_running).returns true
      provider.expects(:rabbitmqplugins).with('enable', 'foo')
      provider.create
    end
    it 'calls rabbitmqplugins to enable with offline' do
      provider.resource[:mode] = :offline
      provider.class.expects(:rabbitmq_version).returns '3.4.0'
      provider.class.expects(:rabbitmq_running).returns true
      provider.expects(:rabbitmqplugins).with('enable', 'foo', '--offline')
      provider.create
    end
    it 'calls rabbitmqplugins to enable with online' do
      provider.resource[:mode] = :online
      provider.class.expects(:rabbitmq_version).returns '3.4.0'
      provider.class.expects(:rabbitmq_running).returns true
      provider.expects(:rabbitmqplugins).with('enable', 'foo', '--online')
      provider.create
    end
    it 'calls rabbitmqplugins to enable with best' do
      provider.resource[:mode] = :best
      provider.class.expects(:rabbitmq_version).returns '3.4.0'
      provider.class.expects(:rabbitmq_running).returns true
      provider.expects(:rabbitmqplugins).with('enable', 'foo')
      provider.create
    end
  end

  context 'with RabbitMQ version < 3.4.0' do
    it 'calls rabbitmqplugins to enable' do
      provider.class.expects(:rabbitmq_version).returns '3.3.9'
      provider.class.expects(:rabbitmq_running).returns true
      provider.expects(:rabbitmqplugins).with('enable', 'foo')
      provider.create
    end
    it 'calls rabbitmqplugins to enable with offline' do
      provider.resource[:mode] = :offline
      provider.class.expects(:rabbitmq_version).returns '3.3.9'
      provider.class.expects(:rabbitmq_running).returns true
      provider.expects(:rabbitmqplugins).with('enable', 'foo')
      provider.create
    end
    it 'calls rabbitmqplugins to enable with online' do
      provider.resource[:mode] = :online
      provider.class.expects(:rabbitmq_version).returns '3.3.9'
      provider.class.expects(:rabbitmq_running).returns true
      provider.expects(:rabbitmqplugins).with('enable', 'foo')
      provider.create
    end
    it 'calls rabbitmqplugins to enable with best' do
      provider.resource[:mode] = :best
      provider.class.expects(:rabbitmq_version).returns '3.3.9'
      provider.class.expects(:rabbitmq_running).returns true
      provider.expects(:rabbitmqplugins).with('enable', 'foo')
      provider.create
    end
  end

  it 'calls rabbitmqplugins to disable' do
    provider.expects(:rabbitmqplugins).with('disable', 'foo')
    provider.destroy
  end
end
