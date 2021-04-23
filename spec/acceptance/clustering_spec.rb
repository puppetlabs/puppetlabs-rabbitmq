require 'spec_helper_acceptance'

describe 'rabbitmq clustering' do
  context 'rabbitmq::wipe_db_on_cookie_change => false' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'erlang': }
      Class['erlang'] -> Class['rabbitmq']
      if $facts['os']['family'] == 'RedHat' {
        class { 'epel': }
        Class['epel'] -> Class['rabbitmq']
      }
      class { 'rabbitmq':
        cluster                  => { 'name' => 'rabbit_cluster', 'init_node' => $facts['fqdn'] },
        config_cluster           => true,
        cluster_nodes            => ['rabbit1', 'rabbit2'],
        cluster_node_type        => 'ram',
        environment_variables    => { 'RABBITMQ_USE_LONGNAME' => true },
        erlang_cookie            => 'TESTCOOKIE',
        wipe_db_on_cookie_change => false,
      }
      EOS

      apply_manifest(pp, expect_failures: true)
    end

    describe file('/var/lib/rabbitmq/.erlang.cookie') do
      it { is_expected.not_to contain 'TESTCOOKIE' }
    end
  end
  context 'rabbitmq::wipe_db_on_cookie_change => true' do
    it 'runs successfully' do
      pp = <<-EOS
      class { 'erlang': }
      Class['erlang'] -> Class['rabbitmq']
      if $facts['os']['family'] == 'RedHat' {
        class { 'epel': }
        Class['epel'] -> Class['rabbitmq']
      }
      class { 'rabbitmq':
        cluster                  => { 'name' => 'rabbit_cluster', 'init_node' => $facts['fqdn'] },
        config_cluster           => true,
        cluster_nodes            => ['rabbit1', 'rabbit2'],
        cluster_node_type        => 'ram',
        environment_variables    => { 'RABBITMQ_USE_LONGNAME' => true },
        erlang_cookie            => 'TESTCOOKIE',
        wipe_db_on_cookie_change => true,
      }
      EOS

      apply_manifest(pp, catch_failures: true)
    end

    describe file('/etc/rabbitmq/rabbitmq.config') do
      it { is_expected.to be_file }
      it { is_expected.to contain 'cluster_nodes' }
      it { is_expected.to contain 'rabbit@rabbit1' }
      it { is_expected.to contain 'rabbit@rabbit2' }
      it { is_expected.to contain 'ram' }
    end

    describe file('/var/lib/rabbitmq/.erlang.cookie') do
      it { is_expected.to be_file }
      it { is_expected.to contain 'TESTCOOKIE' }
    end

    describe 'rabbitmq_cluster' do
      context 'cluster_name => rabbit_cluster' do
        it 'cluster has name' do
          shell('rabbitmqctl -q cluster_status') do |r|
            expect(r.stdout).to match(%r!({cluster_name,<<"rabbit_cluster">>}|^Cluster name: rabbit_cluster$)!)
            expect(r.exit_code).to be_zero
          end
          # rubocop:enable RSpec/MultipleExpectations
        end
      end
    end
  end
end
