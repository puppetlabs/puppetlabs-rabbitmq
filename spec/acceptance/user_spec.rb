require 'spec_helper_acceptance'

describe 'rabbitmq user:' do
  context 'create user resource' do
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
      } ->

      rabbitmq_user { 'dan':
        admin    => true,
        password => 'bar',
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
    it 'has the user' do
      shell('rabbitmqctl list_users -q') do |r|
        expect(r.stdout).to match(%r{dan.*administrator})
        expect(r.exit_code).to be_zero
      end
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  context 'destroy user resource' do
    it 'runs successfully' do
      pp = <<-EOS
      rabbitmq_user { 'dan':
        ensure => absent,
      }
      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    it 'does not have the user' do
      shell('rabbitmqctl list_users -q') do |r|
        expect(r.stdout).not_to match(%r{dan\s+})
      end
    end
  end
end
