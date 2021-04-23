#
# @summary A module to manage RabbitMQ
#
# @example Basic usage
#   include rabbitmq
#
# @example rabbitmq class
#   class { 'rabbitmq':
#     service_manage    => false,
#     port              => '5672',
#     delete_guest_user => true,
#   }
#
# @example Offline installation from local mirror:
#   class { 'rabbitmq':
#     key_content     => template('openstack/rabbit.pub.key'),
#     package_gpg_key => '/tmp/rabbit.pub.key',
#   }
#
# @example Use external package key source for any (apt/rpm) package provider:
#   class { 'rabbitmq':
#     package_gpg_key => 'http://www.some_site.some_domain/some_key.pub.key',
#   }
#
# @example To use RabbitMQ Environment Variables, use the parameters `environment_variables` e.g.:
#   class { 'rabbitmq':
#     port                  => '5672',
#     environment_variables => {
#       'NODENAME'    => 'node01',
#       'SERVICENAME' => 'RabbitMQ'
#     }
#   }
#
# @example Change RabbitMQ Config Variables in rabbitmq.config:
#   class { 'rabbitmq':
#     port             => '5672',
#     config_variables => {
#       'hipe_compile' => true,
#       'frame_max'    => 131072,
#       'log_levels'   => "[{connection, info}]"
#     }
#   }
#
# @example Change Erlang Kernel Config Variables in rabbitmq.config
#   class { 'rabbitmq':
#     port                    => '5672',
#     config_kernel_variables => {
#       'inet_dist_listen_min' => 9100,
#       'inet_dist_listen_max' => 9105,
#     }
#   }
#
# @example Change Management Plugin Config Variables in rabbitmq.config
#   class { 'rabbitmq':
#     config_management_variables => {
#       'rates_mode' => 'basic',
#     }
#   }
#
# @example Change Additional Config Variables in rabbitmq.config
#   class { 'rabbitmq':
#     config_additional_variables => {
#       'autocluster' => '[{consul_service, "rabbit"},{cluster_name, "rabbit"}]',
#       'foo'         => '[{bar, "baz"}]'
#     }
#   }
#
#   This will result in the following config appended to the config file:
#   {autocluster, [{consul_service, "rabbit"},{cluster_name, "rabbit"}]},
#    {foo, [{bar, "baz"}]}
#   (This is required for the [autocluster plugin](https://github.com/rabbitmq/rabbitmq-autocluster)
#
# @example Use RabbitMQ clustering facilities
#   class { 'rabbitmq':
#     cluster                  => {
#       'name'      => 'test_cluster',
#       'init_node' => 'hostname'
#     },
#     config_cluster           => true,
#     cluster_nodes            => ['rabbit1', 'rabbit2'],
#     cluster_node_type        => 'ram',
#     erlang_cookie            => 'A_SECRET_COOKIE_STRING',
#     wipe_db_on_cookie_change => true,
#   }
#
# @param admin_enable
#   If enabled sets up the management interface/plugin for RabbitMQ.
#   This also install the rabbitmqadmin command line tool.
# @param management_enable
#   If enabled sets up the management interface/plugin for RabbitMQ.
#   NOTE: This does not install the rabbitmqadmin command line tool.
# @param use_config_file_for_plugins
#   If enabled the /etc/rabbitmq/enabled_plugins config file is created,
#   replacing the use of the rabbitmqplugins provider to enable plugins.
# @param auth_backends
#   An array specifying authorization/authentication backend to use. Single quotes should be placed around array entries,
#   ex. `['{foo, baz}', 'baz']` Defaults to [rabbit_auth_backend_internal], and if using LDAP defaults to [rabbit_auth_backend_internal,
#   rabbit_auth_backend_ldap].
# @param cluster Join cluster and change name of cluster.
# @param cluster_node_type
#   Choose between disc and ram nodes.
# @param cluster_nodes
#   An array of nodes for clustering.
# @param cluster_partition_handling
#   Value to set for `cluster_partition_handling` RabbitMQ configuration variable.
# @param collect_statistics_interval
#   Set the collect_statistics_interval in rabbitmq.config
# @param config
#   The file to use as the rabbitmq.config template.
# @param config_additional_variables
#   Additional config variables in rabbitmq.config
# @param config_cluster
#   Enable or disable clustering support.
# @param config_kernel_variables
#   Hash of Erlang kernel configuration variables to set (see [Variables Configurable in rabbitmq.config](#variables-configurable-in-rabbitmq.config)).
# @param config_path
#   The path to write the RabbitMQ configuration file to.
# @param config_ranch
#   When true, suppress config directives needed for older (<3.6) RabbitMQ versions.
# @param config_management_variables
#   Hash of configuration variables for the [Management Plugin](https://www.rabbitmq.com/management.html).
# @param config_stomp
#   Enable or disable stomp.
# @param config_shovel
#   Enable or disable shovel.
# @param config_shovel_statics
#   Hash of static shovel configurations
# @param config_variables
#   To set config variables in rabbitmq.config
# @param default_user
#   Username to set for the `default_user` in rabbitmq.config.
# @param default_pass
#   Password to set for the `default_user` in rabbitmq.config.
# @param delete_guest_user
#   Controls whether default guest user is deleted.
# @param env_config
#   The template file to use for rabbitmq_env.config.
# @param env_config_path
#   The path to write the rabbitmq_env.config file to.
# @param environment_variables
#   RabbitMQ Environment Variables in rabbitmq_env.config
# @param erlang_cookie
#   The erlang cookie to use for clustering - must be the same between all nodes. This value has no default and must be
#   set explicitly if using clustering. If you run Pacemaker and you don't want to use RabbitMQ buildin cluster, you can set config_cluster
#   to 'False' and set 'erlang_cookie'.
# @param file_limit
#   Set rabbitmq file ulimit. Defaults to 16384. Only available on systems with `$::osfamily == 'Debian'` or `$::osfamily == 'RedHat'`.
# @param oom_score_adj
#   Set rabbitmq-server process OOM score. Defaults to 0.
# @param heartbeat
#   Set the heartbeat timeout interval, default is unset which uses the builtin server defaults of 60 seconds. Setting this
# @param inetrc_config
#   Template to use for the inetrc config
# @param inetrc_config_path
#   Path of the file to push the inetrc config to.
# @param ipv6
#   Whether to listen on ipv6
# @param interface
#   Interface to bind to (sets tcp_listeners parameter). By default, bind to all interfaces
#   to `0` will disable heartbeats.
# @param key_content
#   Uses content method for Debian OS family. Should be a template for apt::source class. Overrides `package_gpg_key`
#   behavior, if enabled. Undefined by default.
# @param ldap_auth
#   Set to true to enable LDAP auth.
# @param ldap_server
#   LDAP server or servers to use for auth.
# @param ldap_user_dn_pattern
#   User DN pattern for LDAP auth.
# @param ldap_other_bind
#   How to bind to the LDAP server. Defaults to 'anon'.
# @param ldap_config_variables
#   Hash of other LDAP config variables.
# @param ldap_use_ssl
#   Set to true to use SSL for the LDAP server.
# @param ldap_port
#   Numeric port for LDAP server.
# @param ldap_log
#   Set to true to log LDAP auth.
# @param manage_python
#   If enabled, on platforms that don't provide a Python 2 package by default, ensure that the python package is
#   installed (for rabbitmqadmin). This will only apply if `admin_enable` and `service_manage` are set.
# @param management_hostname
#   The hostname for the RabbitMQ management interface.
# @param management_port
#   The port for the RabbitMQ management interface.
# @param management_ip_address
#   Allows you to set the IP for management interface to bind to separately. Set to 127.0.0.1 to bind to
#   localhost only, or 0.0.0.0 to bind to all interfaces.
# @param management_ssl
#   Enable/Disable SSL for the management port. Has an effect only if ssl => true.
# @param node_ip_address
#   Allows you to set the IP for RabbitMQ service to bind to. Set to 127.0.0.1 to bind to localhost only, or 0.0.0.0
#   to bind to all interfaces.
# @param package_apt_pin
#   Whether to pin the package to a particular source
# @param package_ensure
#   Determines the ensure state of the package.  Set to installed by default, but could be changed to latest.
# @param package_gpg_key
#   RPM package GPG key to import. Uses source method. Should be a URL for Debian/RedHat OS family, or a file name for
#   RedHat OS family. Set to https://www.rabbitmq.com/rabbitmq-release-signing-key.asc for RedHat OS Family and
#   https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey for Debian OS Family by default. Note, that `key_content`, if specified, would
#   override this parameter for Debian OS family.
# @param package_name
#   Name(s) of the package(s) to install
# @param port
#   The RabbitMQ port.
# @param python_package
#   Name of the package required by rabbitmqadmin.
# @param repos_ensure
#   Ensure that a repo with the official (and newer) RabbitMQ package is configured, along with its signing key.
#   Defaults to true (use RabbitMQ repos). This does not ensure that soft dependencies (like EPEL on RHEL systems) are present.
#   It also does not solve the erlang dependency.  See https://www.rabbitmq.com/which-erlang.html for a good breakdown of the
#   different ways of handling the erlang deps.  See also https://github.com/voxpupuli/puppet-rabbitmq/issues/788
# @param service_ensure
#   The state of the service.
# @param service_manage
#   Determines if the service is managed.
# @param service_name
#   The name of the service to manage.
# @param service_restart
#   Default defined in param.pp. Whether to restart the service on config change.
# @param ssl
#   Configures the service for using SSL.
# @param ssl_cacert
#   CA cert path to use for SSL.
# @param ssl_cert
#   Cert to use for SSL.
# @param ssl_cert_password
#   Password used when generating CSR.
# @param ssl_depth
#   SSL verification depth.
# @param ssl_dhfile
#   Use this dhparam file [example: generate with `openssl dhparam -out /etc/rabbitmq/ssl/dhparam.pem 2048`
# @param ssl_erl_dist
#   Whether to use the erlang package's SSL (relies on the ssl_erl_path fact)
# @param ssl_honor_cipher_order
#   Force use of server cipher order
# @param ssl_interface
#   Interface for SSL listener to bind to
# @param ssl_key
#   Key to use for SSL.
# @param ssl_only
#   Configures the service to only use SSL. No cleartext TCP listeners will be created. Requires that ssl => true and
#   port => undef
# @param ssl_management_port
#   SSL management port.
# @param ssl_management_cacert
#   SSL management cacert. If unset set to ssl_cacert for backwards compatibility.
# @param ssl_management_cert
#   SSL management cert. If unset set to ssl_cert for backwards compatibility.
# @param ssl_management_key
#   SSL management key. If unset set to ssl_key for backwards compatibility.
# @param ssl_port
#   SSL port for RabbitMQ
# @param ssl_reuse_sessions
#   Reuse ssl sessions
# @param ssl_secure_renegotiate
#   Use ssl secure renegotiate
# @param ssl_stomp_port
#   SSL stomp port.
# @param ssl_verify
#   rabbitmq.config SSL verify setting.
# @param ssl_fail_if_no_peer_cert
#   rabbitmq.config `fail_if_no_peer_cert` setting.
# @param ssl_management_verify
#   rabbitmq.config SSL verify setting for rabbitmq_management.
# @param ssl_versions
#   Choose which SSL versions to enable. Example: `['tlsv1.2', 'tlsv1.1']` Note
#   that it is recommended to disable `sslv3 and `tlsv1` to prevent against
#   POODLE and BEAST attacks. Please see the
#   [RabbitMQ SSL](https://www.rabbitmq.com/ssl.html) documentation for more information.
# @param ssl_ciphers
#   Support only a given list of SSL ciphers, using either the Erlang or OpenSSL styles.
#   Supported ciphers in your install can be listed with: `rabbitmqctl eval 'ssl:cipher_suites().'`
#   Functionality can be tested with cipherscan or similar tool: https://github.com/mozilla/cipherscan
#   * Erlang style: `['ecdhe_rsa,aes_256_cbc,sha', 'dhe_rsa,aes_256_cbc,sha']`
#   * OpenSSL style: `['ECDHE-RSA-AES256-SHA', 'DHE-RSA-AES256-SHA']`
# @param ssl_crl_check
#   Perform CRL (Certificate Revocation List) verification
#   Please see the [Erlang SSL](https://erlang.org/doc/man/ssl.html#type-crl_check) module documentation for more information.
# @param ssl_crl_cache_hash_dir
#   This setting makes use of a directory where CRLs are stored in files named by the hash of the issuer name.
#   Please see the [Erlang SSL](https://erlang.org/doc/man/ssl.html#type-crl_cache_opts) module documentation for more information.
# @param ssl_crl_cache_http_timeout
#   This setting enables use of internal CRLs cache and sets HTTP timeout interval on fetching CRLs from distributino URLs defined inside certificate.
#   Please see the [Erlang SSL](https://erlang.org/doc/man/ssl.html#type-crl_cache_opts) module documentation for more information.
# @param stomp_port
#   The port to use for Stomp.
# @param stomp_ssl_only
#   Configures STOMP to only use SSL. No cleartext STOMP TCP listeners will be created. Requires setting ssl_stomp_port also.
# @param stomp_ensure
#   Enable to install the stomp plugin.
# @param tcp_backlog
#   The size of the backlog on TCP connections.
# @param tcp_keepalive
#   Enable TCP connection keepalive for RabbitMQ service.
# @param tcp_recbuf
#   Corresponds to recbuf in RabbitMQ `tcp_listen_options`
# @param tcp_sndbuf
#   Integer, corresponds to sndbuf in RabbitMQ `tcp_listen_options`
# @param wipe_db_on_cookie_change
#   Boolean to determine if we should DESTROY AND DELETE the RabbitMQ database.
# @param rabbitmq_user
#   OS dependent The system user the rabbitmq daemon runs as.
# @param rabbitmq_group
#   OS dependent The system group the rabbitmq daemon runs as.
# @param rabbitmq_home
#   OS dependent The home directory of the rabbitmq deamon.
# @param rabbitmqadmin_package
#   OS dependent If undef: install rabbitmqadmin via archive, otherwise via package
# @param archive_options
#   Extra options to Archive resource to download rabbitmqadmin file
# @param loopback_users
#   This option configures a list of users to allow access via the loopback interfaces
#
class rabbitmq (
  Boolean $admin_enable                                                                            = true,
  Boolean $management_enable                                                                       = false,
  Boolean $use_config_file_for_plugins                                                             = false,
  Hash $cluster                                                                                    = $rabbitmq::cluster,
  Enum['ram', 'disc'] $cluster_node_type                                                           = 'disc',
  Array $cluster_nodes                                                                             = [],
  String $config                                                                                   = 'rabbitmq/rabbitmq.config.erb',
  Boolean $config_cluster                                                                          = false,
  Stdlib::Absolutepath $config_path                                                                = '/etc/rabbitmq/rabbitmq.config',
  Boolean $config_ranch                                                                            = true,
  Boolean $config_stomp                                                                            = false,
  Boolean $config_shovel                                                                           = false,
  Hash $config_shovel_statics                                                                      = {},
  String $default_user                                                                             = 'guest',
  String $default_pass                                                                             = 'guest',
  Boolean $delete_guest_user                                                                       = false,
  String $env_config                                                                               = 'rabbitmq/rabbitmq-env.conf.erb',
  Stdlib::Absolutepath $env_config_path                                                            = '/etc/rabbitmq/rabbitmq-env.conf',
  Optional[String] $erlang_cookie                                                                  = undef,
  Optional[String] $interface                                                                      = undef,
  Optional[String] $management_ip_address                                                          = undef,
  Integer[1, 65535] $management_port                                                               = 15672,
  Boolean $management_ssl                                                                          = true,
  Optional[String] $management_hostname                                                            = undef,
  Optional[String] $node_ip_address                                                                = undef,
  Optional[Variant[Numeric, String]] $package_apt_pin                                              = undef,
  String $package_ensure                                                                           = 'installed',
  Optional[String] $package_gpg_key                                                                = undef,
  Variant[String, Array] $package_name                                                             = 'rabbitmq',
  Optional[String] $package_source                                                                 = undef,
  Optional[String] $package_provider                                                               = undef,
  Boolean $repos_ensure                                                                            = true,
  Boolean $manage_python                                                                           = true,
  String $python_package                                                                           = 'python',
  String $rabbitmq_user                                                                            = 'rabbitmq',
  String $rabbitmq_group                                                                           = 'rabbitmq',
  Stdlib::Absolutepath $rabbitmq_home                                                              = '/var/lib/rabbitmq',
  Integer $port                                                                                    = 5672,
  Boolean $tcp_keepalive                                                                           = false,
  Integer $tcp_backlog                                                                             = 128,
  Optional[Integer] $tcp_sndbuf                                                                    = undef,
  Optional[Integer] $tcp_recbuf                                                                    = undef,
  Optional[Integer] $heartbeat                                                                     = undef,
  Enum['running', 'stopped'] $service_ensure                                                       = 'running',
  Boolean $service_manage                                                                          = true,
  String $service_name                                                                             = 'rabbitmq',
  Boolean $ssl                                                                                     = false,
  Boolean $ssl_only                                                                                = false,
  Optional[Stdlib::Absolutepath] $ssl_cacert                                                       = undef,
  Optional[Stdlib::Absolutepath] $ssl_cert                                                         = undef,
  Optional[Stdlib::Absolutepath] $ssl_key                                                          = undef,
  Optional[Integer] $ssl_depth                                                                     = undef,
  Optional[String] $ssl_cert_password                                                              = undef,
  Integer[1, 65535] $ssl_port                                                                      = 5671,
  Optional[String] $ssl_interface                                                                  = undef,
  Integer[1, 65535] $ssl_management_port                                                           = 15671,
  Optional[Stdlib::Absolutepath] $ssl_management_cacert                                            = $ssl_cacert,
  Optional[Stdlib::Absolutepath] $ssl_management_cert                                              = $ssl_cert,
  Optional[Stdlib::Absolutepath] $ssl_management_key                                               = $ssl_key,
  Integer[1, 65535] $ssl_stomp_port                                                                = 6164,
  Enum['verify_none','verify_peer'] $ssl_verify                                                    = 'verify_none',
  Boolean $ssl_fail_if_no_peer_cert                                                                = false,
  Enum['verify_none','verify_peer'] $ssl_management_verify                                         = 'verify_none',
  Boolean $ssl_management_fail_if_no_peer_cert                                                     = false,
  Optional[Array] $ssl_versions                                                                    = undef,
  Boolean $ssl_secure_renegotiate                                                                  = true,
  Boolean $ssl_reuse_sessions                                                                      = true,
  Boolean $ssl_honor_cipher_order                                                                  = true,
  Optional[Stdlib::Absolutepath] $ssl_dhfile                                                       = undef,
  Array $ssl_ciphers                                                                               = [],
  Enum['true','false','peer','best_effort'] $ssl_crl_check                                         = 'false',
  Optional[Stdlib::Absolutepath] $ssl_crl_cache_hash_dir                                                         = undef,
  Optional[Integer] $ssl_crl_cache_http_timeout                                                    = undef,
  Boolean $stomp_ensure                                                                            = false,
  Boolean $ldap_auth                                                                               = false,
  Variant[String[1],Array[String[1]]] $ldap_server                                                 = 'ldap',
  Optional[String] $ldap_user_dn_pattern                                                           = undef,
  String $ldap_other_bind                                                                          = 'anon',
  Boolean $ldap_use_ssl                                                                            = false,
  Integer[1, 65535] $ldap_port                                                                     = 389,
  Boolean $ldap_log                                                                                = false,
  Hash $ldap_config_variables                                                                      = {},
  Integer[1, 65535] $stomp_port                                                                    = 6163,
  Boolean $stomp_ssl_only                                                                          = false,
  Boolean $wipe_db_on_cookie_change                                                                = false,
  String $cluster_partition_handling                                                               = 'ignore',
  Variant[Integer[-1],Enum['unlimited'],Pattern[/^(infinity|\d+(:(infinity|\d+))?)$/]] $file_limit = 16384,
  Integer[-1000, 1000] $oom_score_adj                                                              = 0,
  Hash $environment_variables                                                                      = { 'LC_ALL' => 'en_US.UTF-8' },
  Hash $config_variables                                                                           = {},
  Hash $config_kernel_variables                                                                    = {},
  Hash $config_management_variables                                                                = {},
  Hash $config_additional_variables                                                                = {},
  Optional[Array] $auth_backends                                                                   = undef,
  Optional[String] $key_content                                                                    = undef,
  Optional[Integer] $collect_statistics_interval                                                   = undef,
  Boolean $ipv6                                                                                    = false,
  String $inetrc_config                                                                            = 'rabbitmq/inetrc.erb',
  Stdlib::Absolutepath $inetrc_config_path                                                         = '/etc/rabbitmq/inetrc',
  Boolean $ssl_erl_dist                                                                            = false,
  Optional[String] $rabbitmqadmin_package                                                          = undef,
  Array $archive_options                                                                           = [],
  Array $loopback_users                                                                            = ['guest'],
  Boolean $service_restart                                                                         = true,
) {
  if $ssl_only and ! $ssl {
    fail('$ssl_only => true requires that $ssl => true')
  }

  if $config_stomp and $stomp_ssl_only and ! $ssl_stomp_port {
    fail('$stomp_ssl_only requires that $ssl_stomp_port be set')
  }

  if $ssl_versions {
    unless $ssl {
      fail('$ssl_versions requires that $ssl => true')
    }
  }

  if $ssl_crl_check != 'false' {
    unless $ssl {
      fail('$ssl_crl_check requires that $ssl => true')
    }
  }

  if $ssl_crl_cache_hash_dir {
    unless $ssl {
      fail('$ssl_crl_cache_hash_dir requires that $ssl => true')
    }
    if $ssl_crl_check == 'false' {
      fail('$ssl_crl_cache_http_timeout requires that $ssl_crl_check => true|peer|best_effort')
    }
  }

  if $ssl_crl_cache_http_timeout {
    unless $ssl {
      fail('$ssl_crl_cache_http_timeout requires that $ssl => true')
    }
    if $ssl_crl_check == 'false' {
      fail('$ssl_crl_cache_http_timeout requires that $ssl_crl_check => true|peer|best_effort')
    }
  }

  if $repos_ensure {
    case $facts['os']['family'] {
      'RedHat': {
        contain rabbitmq::repo::rhel
        Class['rabbitmq::repo::rhel'] -> Class['rabbitmq::install']
      }
      'Debian': {
        contain rabbitmq::repo::apt
        Class['rabbitmq::repo::apt'] -> Class['rabbitmq::install']
      }
      default: {
      }
    }
  }

  contain rabbitmq::install
  contain rabbitmq::config
  contain rabbitmq::service
  contain rabbitmq::management

  unless $use_config_file_for_plugins {
    # NOTE(hjensas): condition on $service_manage to keep current behaviour.
    # The condition is likely not required because installiton of rabbitmqadmin
    # is no longer handled here.
    # TODO: Remove the condition on $service_manage
    if ($management_enable or $admin_enable) and $service_manage {
      rabbitmq_plugin { 'rabbitmq_management':
        ensure   => present,
        notify   => Class['rabbitmq::service'],
        provider => 'rabbitmqplugins',
      }
    }

    if ($stomp_ensure) {
      rabbitmq_plugin { 'rabbitmq_stomp':
        ensure   => present,
        notify   => Class['rabbitmq::service'],
        provider => 'rabbitmqplugins',
      }
    }

    if ($ldap_auth) {
      rabbitmq_plugin { 'rabbitmq_auth_backend_ldap':
        ensure   => present,
        notify   => Class['rabbitmq::service'],
        provider => 'rabbitmqplugins',
      }
    }

    if ($config_shovel) {
      rabbitmq_plugin { 'rabbitmq_shovel':
        ensure   => present,
        notify   => Class['rabbitmq::service'],
        provider => 'rabbitmqplugins',
      }

      if ($management_enable or $admin_enable) {
        rabbitmq_plugin { 'rabbitmq_shovel_management':
          ensure   => present,
          notify   => Class['rabbitmq::service'],
          provider => 'rabbitmqplugins',
        }
      }
    }
  }

  if $admin_enable and $service_manage {
    include 'rabbitmq::install::rabbitmqadmin'

    Class['rabbitmq::service'] -> Class['rabbitmq::install::rabbitmqadmin']
    Class['rabbitmq::install::rabbitmqadmin'] -> Rabbitmq_exchange<| |>
  }

  if $config_cluster and $cluster['name'] and $cluster['init_node'] {
    create_resources('rabbitmq_cluster', {
        $cluster['name'] => {
          'init_node'      => $cluster['init_node'],
          'node_disc_type' => $cluster_node_type,
        }
    })
  }

  if ($service_restart) {
    Class['rabbitmq::config'] ~> Class['rabbitmq::service']
  }

  Class['rabbitmq::install']
  -> Class['rabbitmq::config']
  -> Class['rabbitmq::service']
  -> Class['rabbitmq::management']

  # Make sure the various providers have their requirements in place.
  Class['rabbitmq::install'] -> Rabbitmq_plugin<| |> -> Rabbitmq_cluster<| |>
}
