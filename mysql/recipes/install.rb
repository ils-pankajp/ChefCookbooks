# Install MySQL

execute "Update Repo" do
  command node['update_repo']
end

package 'Install MySQL' do
  package_name node['mysql_package']
end

package 'Install Pip installer' do
  package_name 'python-pip'
end

execute "Install Config Parser" do
  command "pip install configparser"
end

python "Configure MySQL" do
  code <<-EOH
import ConfigParser

config = ConfigParser.RawConfigParser(allow_no_value=True)
config.read('#{node['mysql_cnf']}')
config.set('mysqld', 'bind-address', '#{node['ipaddress']}')
with open('#{node['mysql_cnf']}', 'wb') as configfile:
    config.write(configfile)
  EOH
end

service node['mysql_service'] do
  action [:start, :enable]
end