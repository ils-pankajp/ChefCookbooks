case node['platform']
  when 'ubuntu', 'debian'
    default['update_repo'] = 'apt-get update'
    default['mysql_package'] = 'mysql-server'
    default['mysql_service'] = 'mysql'
end

default['mount_point'] = "/mnt/#{node['hostname']}-data"

default['mysql_cnf'] = '/etc/mysql/my.cnf'