default['bind9']['options_file'] = '/etc/bind/named.conf.options'
default['bind9']['local_file'] = '/etc/bind/named.conf.local'
default['bind9']['data_dir'] = '/var/lib/bind'
default['bind9']['log_dir'] = '/var/log/bind'
default['bind9']['forwarders'] = [ '8.8.8.8', '8.8.4.4' ]
default['bind9']['user'] = 'bind'
default['bind9']['zones_db_item'] = 'zones'
