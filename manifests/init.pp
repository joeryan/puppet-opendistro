## installation class for AWS released open distro for elasticsearch
# requires openjdk-11
class opendistroelastic (
  Boolean $allow_unsafe_demo                              = $opendistroelastic::params::allow_unsafe_demo,
  Boolean $allow_default_init_secindex                    = $opendistroelastic::params::allow_default_init_secindex,
  String  $audit_type                                     = $opendistroelastic::params::audit_type,
  Boolean $check_snap_restore_write_priv                  = $opendistroelastic::params::check_snap_restore_write_priv,
  String  $cluster_name                                   = $opendistroelastic::params::cluster_name,
  Boolean $disk_threshold_enabled                         = $opendistroelastic::params::disk_threshold_enabled,
  Array   $elastic_servers                                = $opendistroelastic::params::elastic_servers,
  Boolean $enable_snap_restore_priv                       = $opendistroelastic::params::enable_snap_restore_priv,
  Boolean $hostname_verification                          = $opendistroelastic::params::hostname_verification,
  Array   $initial_master_nodes                           = $opendistroelastic::params::minimum_master_nodes,
  String  $internal_admin_password                        = $opendistroelastic::params::internal_admin_password,
  String  $internal_kibanaserver_password                 = $opendistroelastic::params::internal_kibanaserver_password,
  String  $internal_logstash_password                     = $opendistroelastic::params::internal_logstash_password,
  String  $internal_readall_password                      = $opendistroelastic::params::internal_readall_password,
  String  $java_heap_size                                 = $opendistroelastic::params::java_heap_size,
  Integer $max_local_storage_nodes                        = $opendistroelastic::params::max_local_storage_nodes,
  String  $network_host                                   = $opendistroelastic::params::network_host,
  # String  $node_name                                      = $opendistroelastic::params::node_name,
  String  $path_data                                      = $opendistroelastic::params::path_data,
  Array   $rest_api_roles                                 = $opendistroelastic::params::rest_api_roles,
  Array   $security_admin_cert                            = $opendistroelastic::params::security_admin_cert,
  Array   $security_nodes_dn                              = $opendistroelastic::params::security_nodes_dn,
  Boolean $service_quiet                                  = $opendistroelastic::params::service_quiet,
  Boolean $ssl_enabled                                    = $opendistroelastic::params::ssl_enabled,
  String  $ssl_pemcert                                    = $opendistroelastic::params::ssl_pemcert,
  String  $ssl_pemkey                                     = $opendistroelastic::params::ssl_pemkey,
  String  $ssl_trusted_cas                                = $opendistroelastic::params::ssl_trusted_cas,
  String  $version_elasticsearch                          = $opendistroelastic::params::version_elasticsearch,
  String  $version_opendistro                             = $opendistroelastic::params::version_opendistro,
) inherits opendistroelastic::params {
  # TODO: /etc/default/elasticsearch?
  # TODO: /etc/elasticsearch/log4j2.properties

  package { 'apt-transport-https':
    ensure => installed,
  }
  package { 'elasticsearch-oss':
    ensure => $version_elasticsearch,
  }
  package {'opendistroforelasticsearch':
    ensure  => $version_opendistro,
    require => Package[ 'apt-transport-https', 'elasticsearch-oss'],
  }
  file { '/etc/elasticsearch/jvm.options':
    ensure  => present,
    content => epp('opendistroelastic/jvm.options.epp'),
    owner   => 'elasticsearch',
    group   => 'elasticsearch',
    mode    => '0660',
    require => Package[ 'opendistroforelasticsearch', 'elasticsearch-oss'],
    notify  => Service['elasticsearch']
  }
  file {'/etc/elasticsearch/elasticsearch.yml':
    ensure  => present,
    content => epp('opendistroelastic/elasticsearch.yml.epp'),
    owner   => 'elasticsearch',
    group   => 'elasticsearch',
    mode    => '0660',
    require => Package[ 'opendistroforelasticsearch', 'elasticsearch-oss'],
    notify  => Service['elasticsearch']
  }
  file {'/usr/share/elasticsearch':
    ensure  => directory,
    owner   => 'elasticsearch',
    group   => 'elasticsearch',
    recurse => true,
    require => Package[ 'opendistroforelasticsearch', 'elasticsearch-oss'],
  }
  file {'/usr/share/elasticsearch/plugins/opendistro_security/securityconfig/internal_users.yml':
    ensure  => present,
    content => epp('opendistroelastic/internal_users.yml.epp'),
    owner   => 'elasticsearch',
    group   => 'elasticsearch',
    mode    => '0644',
    require => Package[ 'opendistroforelasticsearch', 'elasticsearch-oss'],
  }
  file {'/usr/lib/systemd/system/elasticsearch.service':
    ensure  => present,
    content => epp('opendistroelastic/elasticsearch.service.epp'),
    mode    => '0644',
    require => Package[ 'opendistroforelasticsearch', 'elasticsearch-oss'],
    notify  => Exec['systemctl daemon-reload'],
  }
  file { '/etc/systemd/system/elasticsearch.service':
    ensure  => link,
    target  => '/usr/lib/systemd/system/elasticsearch.service',
    notify  => Exec['systemctl daemon-reload'],
    require => File['/usr/lib/systemd/system/elasticsearch.service'],
  }
  ## remove demo certs if not running unsafe demo
  if !$allow_unsafe_demo {
    $demo_certs = ['esnode.pem', 'esnode-key.pem', 'root-ca.pem', 'kirk.pem', 'kirk-key.pem']
    $demo_certs.each |String $file_name| {
      file { "/etc/elasticsearch/${file_name}":
        ensure  => absent,
        require => Package['opendistroforelasticsearch'],
      }
    }
  }
  exec { 'systemctl daemon-reload':
    refreshonly => true,
    path        => $::path,
    notify      => Service['elasticsearch'],
    require     => File['/usr/lib/systemd/system/elasticsearch.service', '/etc/systemd/system/elasticsearch.service', 
                        '/usr/share/elasticsearch/plugins/opendistro_security/securityconfig/internal_users.yml'],
  }

  service { 'elasticsearch':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

}
