class opendistroelastic::kibana (
  Array   $elastic_hosts                              = $opendistroelastic::params::kibana::elastic_hosts,
  String  $elastic_ssl_verify_mode                    = $opendistroelastic::params::kibana::elastic_ssl_verify_mode,
  String  $elastic_username                           = $opendistroelastic::params::kibana::elastic_username,
  String  $elastic_password                           = $opendistroelastic::params::kibana::elastic_password,
  Array   $headers_whitelist                          = $opendistroelastic::params::kibana::headers_whitelist,
  Boolean $multitennancy                              = $opendistroelastic::params::kibana::multitennancy,
  Array   $multitennant_prefer                        = $opendistroelastic::params::kibana::multitennant_prefer,
  Array   $readonly_roles                             = $opendistroelastic::params::kibana::readonly_roles,
  String  $server_host                                = $opendistroelastic::params::kibana::server_host,
  String  $ssl_cert                                   = $opendistroelastic::params::kibana::ssl_cert,
  Boolean $ssl_enabled                                = $opendistroelastic::params::kibana::ssl_enabled,
  String  $ssl_key                                    = $opendistroelastic::params::kibana::ssl_key,
  String  $version_kibana                             = $opendistroelastic::params::kibana::version_kibana,
) inherits opendistroelastic::params::kibana {
  package {'opendistroforelasticsearch-kibana':
    ensure => $version_kibana,
  }
  file {'/etc/kibana/kibana.yml':
    ensure  => present,
    content => epp('opendistroelastic/kibana.yml.epp'),
    mode    => '0644',
    require => Package[ 'opendistroforelasticsearch-kibana' ],
    notify  => Service['kibana']
  }
  file { '/etc/systemd/system/kibana.service':
    ensure  => present,
    content => epp('opendistroelastic/kibana.service.epp'),
    require => Package[ 'opendistroforelasticsearch-kibana' ],
    notify  => Exec['systemctl kibana-daemon-reload'],
  }
  exec { 'systemctl kibana-daemon-reload':
    refreshonly => true,
    path        => $::path,
    notify      => Service['kibana'],
    require     => File[ '/etc/systemd/system/kibana.service'],
  }

  service { 'kibana':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
