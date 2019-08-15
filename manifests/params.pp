# parameters class
class opendistroelastic::params () {
  $allow_unsafe_demo                                = true
  $allow_default_init_secindex                      = true
  $audit_type                                       = 'internal_elasticsearch'
  $check_snap_restore_write_priv                    = true
  $cluster_name                                     = 'aws-cluster'
  $disk_threshold_enabled                           = false
  $elastic_servers                                  = ['localhost']
  $enable_snap_restore_priv                         = true
  $hostname_verification                            = false
  $initial_master_nodes                             = ['localhost']
  $internal_admin_password                          = '$2y$12$v3.lYj1YwHvlHwPDckUQiuiQMOpeWbEpE8WtxQL9fPGxc0CRpgPm2' #hash of admin, created with plugin/tools/hash.sh
  $internal_kibanaserver_password                   = '$2y$12$QGVNgK88d8cJAT98zKb75OjTSw2ka1ZQwQ7Vbdmdkc2HWfbxm6Ttu' #hash of kibanaserver, created with plugin/tools/hash.sh
  $internal_logstash_password                       = '$2y$12$umkOdXTE53XYbTae3fp4EOi98upDGsk54J978UT9XFbtsl9n7d4I6' #hash of logstash, created with plugin/tools/hash.sh
  $internal_readall_password                        = '$2y$12$kn0RNVOWicChPSaew3XgdOYBx.XtiLWOtcyESZLkUayQqqEQSWRqS' #hash of readall, created with plugin/tools/hash.sh
  $java_heap_size                                   = '1g'
  $max_local_storage_nodes                          = 3
  $network_host                                     = '0.0.0.0'
  $node_name                                        = 'localhost'
  $node_data                                        = true
  $node_master                                      = true
  $path_data                                        = '/var/data/elasticsearch'
  $rest_api_roles                                   = ["all_access", "security_rest_api_access"]
  $security_admin_cert                              = ['CN=kirk,OU=client,O=client,L=test,C=de']
  $security_nodes_dn                                = ['*']
  $service_quiet                                    = true
  $ssl_pemcert                                      = 'esnode.pem'
  $ssl_pemkey                                       = 'esnode-key.pem'
  $ssl_trusted_cas                                  = 'root-ca.pem'
  $ssl_enabled                                      = true
  $version_elasticsearch                            = 'present'
  $version_opendistro                               = 'present'
}

class opendistroelastic::params::kibana () {
  $elastic_hosts                                    = ['https://localhost:9200']
  $elastic_ssl_verify_mode                          = 'none'
  $elastic_username                                 = 'kibanaserver'
  $elastic_password                                 = 'kibanaserver'
  $headers_whitelist                                = ["securitytenant","Authorization"]
  $multitennancy                                    = true
  $multitennant_prefer                              = ["Private", "Global"]
  $readonly_roles                                   = ["kibana_read_only"]
  $server_host                                      = 'localhost'
  $server_basepath                                  = '/'
  $server_rewrite_basepath                          = false
  $ssl_cert                                         = 'esnode.pem'
  $ssl_enabled                                      = true
  $ssl_key                                          = 'esnode-key.pem'
  $version_kibana                                   = 'present'

}
