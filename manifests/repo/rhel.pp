# Class: rabbitmq::repo::rhel
# Imports the gpg key if it doesn't already exist.
class rabbitmq::repo::rhel {

  $package_gpg_key = $rabbitmq::package_gpg_key

  Class['rabbitmq::repo::rhel'] -> Package<| title == 'rabbitmq-server' |>

  exec { 'fetch_rabbitmq_gpg_key':
    command => "rpm --import ${package_gpg_key}",
    path   => ['/bin','/usr/bin','/sbin','/usr/sbin'],
    unless => 'rpm -q gpg-pubkey-056e8e56-468e43f2 2>/dev/null',
  }

}
