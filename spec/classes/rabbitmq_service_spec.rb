require 'spec_helper'

describe 'rabbitmq::service' do
  let(:facts) {{ :osfamily => 'Debian', :lsbdistcodename => 'precise' }}
  let :default_params do
    {
      :service_ensure => 'running',
      :service_manage => true,
      :service_name   => 'rabbitmq-server'
    }
  end
  let(:params) { default_params }

  describe 'service with default params' do
    it { should contain_service('rabbitmq-server').with(
      'ensure'     => 'running',
      'enable'     => 'true',
      'hasstatus'  => 'true',
      'hasrestart' => 'true'
    )}
  end

  describe 'service with ensure stopped' do
    let(:params) { default_params.merge({ :service_ensure => 'stopped' })}

    it { should contain_service('rabbitmq-server').with(
      'ensure'    => 'stopped',
      'enable'    => false
    ) }
  end

  describe 'service with ensure neither running neither stopped' do
    let(:params) { default_params.merge({ :service_ensure => 'foo' })}

    it 'should raise an error' do
      expect {
        should contain_service('rabbitmq-server').with(
          'ensure' => 'stopped' )
      }.to raise_error(Puppet::Error, /validate_re\(\): "foo" does not match "\^\(running\|stopped\)\$"/)
    end
  end

  describe 'service with manage_service equal to false' do
    let(:params) { default_params.merge({ :service_manage => false })}

    it { should_not contain_service('rabbitmq-server') }
  end

end
