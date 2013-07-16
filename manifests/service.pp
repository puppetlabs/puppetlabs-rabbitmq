# Class: rabbitmq::service
#
#   This class manages the rabbitmq server service itself.
#
#   Jeff McCune <jeff@puppetlabs.com>
#
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class rabbitmq::service(
  $service_ensure = $rabbitmq::service_ensure,
  $service_manage = $rabbitmq::service_manage,
  $service_name   = $rabbitmq::service_name,
) inherits rabbitmq {

  validate_re($service_ensure, '^(running|stopped)$')
  validate_bool($service_manage)

  if ($service_manage) {
    if $service_ensure == 'running' {
      Class['rabbitmq::service'] -> Rabbitmq_user<| |>
      Class['rabbitmq::service'] -> Rabbitmq_vhost<| |>
      Class['rabbitmq::service'] -> Rabbitmq_user_permissions<| |>
      $ensure_real = 'running'
      $enable_real = true
    } else {
      $ensure_real = 'stopped'
      $enable_real = false
    }

    service { $service_name:
      ensure     => $ensure_real,
      enable     => $enable_real,
      hasstatus  => true,
      hasrestart => true,
    }
  }

}
