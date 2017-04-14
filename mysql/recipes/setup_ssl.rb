cookbook_file '/etc/mysql/ca-cert.pem' do
  source 'ca-cert.pem'
  mode '0755'
end

cookbook_file '/etc/mysql/ca-key.pem' do
  source 'ca-key.pem'
  mode '0755'
end

execute "Create Server Key" do
  cwd "/etc/mysql/"
  command "openssl req -sha1 -newkey rsa:2048 -days 730 -nodes -keyout server-key.pem > server-req.pem -subj \"/C=IN/ST=Madhya Pradesh/L=Indore/O=Synapses/OU=SXE/CN=#{node['ipaddress']}/emailAddress=p.patel@thesynapses.com\""
end

execute "Create Server Certificate" do
  cwd "/etc/mysql/"
  command "openssl x509 -sha1 -req -in server-req.pem -days 730  -CA ca-cert.pem -CAkey ca-key.pem -set_serial 01 > server-cert.pem"
end

execute "Convert Server key" do
  cwd "/etc/mysql/"
  command "openssl rsa -in server-key.pem -out server-key.pem"
end

execute "Create Client Key" do
  cwd "/etc/mysql/"
  command "openssl req -sha1 -newkey rsa:2048 -days 730 -nodes -keyout client-key.pem > client-req.pem -subj \"/C=IN/ST=Madhya Pradesh/L=Indore/O=Synapses/OU=SXE/CN=client.#{node['hostname']}/emailAddress=p.patel@thesynapses.com\""
end

execute "Create Client Certificate" do
  cwd "/etc/mysql/"
  command "openssl x509 -sha1 -req -in client-req.pem -days 730 -CA ca-cert.pem -CAkey ca-key.pem -set_serial 01 > client-cert.pem"
end

execute "Convert Client Key" do
  cwd "/etc/mysql/"
  command "openssl rsa -in client-key.pem -out client-key.pem"
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
config.set('mysqld', 'ssl', '1')
config.set('mysqld', 'ssl-ca', '/etc/mysql/ca-cert.pem')
config.set('mysqld', 'ssl-cert', '/etc/mysql/server-cert.pem')
config.set('mysqld', 'ssl-key', '/etc/mysql/server-key.pem')
with open('#{node['mysql_cnf']}', 'wb') as configfile:
    config.write(configfile)
  EOH
end

execute "Restart MySQL" do
  command "service #{node['mysql_service']} restart"
end