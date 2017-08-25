require 'puppet'
require 'puppet/type/rabbitmq_vhost'
describe Puppet::Type.type(:rabbitmq_vhost) do
  before do
    @vhost = Puppet::Type.type(:rabbitmq_vhost).new(name: 'foo')
  end
  it 'accepts a vhost name' do
    @vhost[:name] = 'dan'
    @vhost[:name].should == 'dan'
  end
  it 'requires a name' do
    expect do
      Puppet::Type.type(:rabbitmq_vhost).new({})
    end.to raise_error(Puppet::Error, 'Title or name must be provided')
  end
  it 'does not allow whitespace in the name' do
    expect do
      @vhost[:name] = 'b r'
    end.to raise_error(Puppet::Error, %r{Valid values match})
  end
end
