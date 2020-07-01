require 'spec_helper_acceptance'

describe 'rabbitmq parameter on a vhost:' do
  context 'create parameter resource' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'erlang': }
      Class['erlang'] -> Class['rabbitmq']
      if $facts['os']['family'] == 'RedHat' {
        class { 'epel': }
        Class['epel'] -> Class['rabbitmq']
      }
      class { 'rabbitmq':
        service_manage    => true,
        port              => 5672,
        delete_guest_user => true,
        admin_enable      => true,
      }

      rabbitmq_plugin { [ 'rabbitmq_federation_management', 'rabbitmq_federation' ]:
        ensure => present
      } ~> Service['rabbitmq-server']

      rabbitmq_vhost { 'fedhost':
        ensure => present,
      } ->

      rabbitmq_parameter { 'documentumFed@fedhost':
        component_name => 'federation-upstream',
        value          => {
          'uri'    => 'amqp://server',
          'expires' => '3600000',
        },
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'has the parameter' do
      shell('rabbitmqctl list_parameters -p fedhost') do |r|
        expect(r.stdout).to match(%r{federation-upstream.*documentumFed.*expires.*3600000})
        expect(r.exit_code).to be_zero
      end
    end
    # rubocop:enable RSpec/MultipleExpectations
  end
end
