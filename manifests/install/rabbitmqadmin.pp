#
class rabbitmq::install::rabbitmqadmin {

  $real_management_port = $rabbitmq::ssl ? { true => $rabbitmq::ssl_management_port, default => $rabbitmq::management_port }
  $protocol = $rabbitmq::ssl ? { true => 'https', default => 'http' }

  staging::file { 'rabbitmqadmin':
    target  => '/var/lib/rabbitmq/rabbitmqadmin',
    source  => "${protocol}://localhost:${real_management_port}/cli/rabbitmqadmin",
    require => [
      Class['rabbitmq::service'],
      Rabbitmq_plugin['rabbitmq_management']
    ],
  }

  file { '/usr/local/bin/rabbitmqadmin':
    owner   => 'root',
    group   => 'root',
    source  => '/var/lib/rabbitmq/rabbitmqadmin',
    mode    => '0755',
    require => Staging::File['rabbitmqadmin'],
  }

}
