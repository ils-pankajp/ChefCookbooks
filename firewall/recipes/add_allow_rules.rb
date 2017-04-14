for i in node['ssh_allowed_list']
  execute "Add Allow Rules for IP #{i}" do
    command "sudo iptables -I INPUT -s #{i} -d #{node['ipaddress']} -p tcp --dport 22 -j ACCEPT"
  end
end
