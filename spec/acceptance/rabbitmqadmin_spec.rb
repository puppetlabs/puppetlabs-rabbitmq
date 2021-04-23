require 'spec_helper_acceptance'

describe 'rabbitmq::install::rabbitmqadmin class' do
  context 'downloads the cli tools' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'erlang': }
      Class['erlang'] -> Class['rabbitmq']
      if $facts['os']['family'] == 'RedHat' {
        class { 'epel': }
        Class['epel'] -> Class['rabbitmq']
      }
      class { 'rabbitmq':
        admin_enable   => true,
        service_manage => true,
      }
      EOS

      apply_manifest(pp, catch_failures: true)
    end

    describe file('/var/lib/rabbitmq/rabbitmqadmin') do
      it { is_expected.to be_file }
    end
  end

  context 'does nothing if service is unmanaged' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'erlang': }
      Class['erlang'] -> Class['rabbitmq']
      if $facts['os']['family'] == 'RedHat' {
        class { 'epel': }
        Class['epel'] -> Class['rabbitmq']
      }
      class { 'rabbitmq':
        admin_enable   => true,
        service_manage => false,
      }
      EOS

      shell('rm -f /var/lib/rabbitmq/rabbitmqadmin')
      apply_manifest(pp, catch_failures: true)
    end

    describe file('/var/lib/rabbitmq/rabbitmqadmin') do
      it { is_expected.not_to be_file }
    end
  end

  context 'works with specified default credentials' do
    it 'runs successfully' do
      # make sure credential change takes effect before admin_enable
      pp_pre = <<-EOS
      class { 'erlang': }
      Class['erlang'] -> Class['rabbitmq']
      if $facts['os']['family'] == 'RedHat' {
        class { 'epel': }
        Class['epel'] -> Class['rabbitmq']
      }
      class { 'rabbitmq':
        service_manage => true,
        default_user   => 'foobar',
        default_pass   => 'bazblam',
      }
      EOS

      pp = <<-EOS
      class { 'erlang': }
      Class['erlang'] -> Class['rabbitmq']
      if $facts['os']['family'] == 'RedHat' {
        class { 'epel': }
        Class['epel'] -> Class['rabbitmq']
      }
      class { 'rabbitmq':
        admin_enable   => true,
        service_manage => true,
        default_user   => 'foobar',
        default_pass   => 'bazblam',
      }
      EOS

      shell('rm -f /var/lib/rabbitmq/rabbitmqadmin')
      apply_manifest(pp_pre, catch_failures: true)
      apply_manifest(pp, catch_failures: true)
    end

    describe file('/var/lib/rabbitmq/rabbitmqadmin') do
      it { is_expected.to be_file }
    end
  end
end
