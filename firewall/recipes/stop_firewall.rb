# Stop Firewall
execute "Stop and Disable UFW" do
  command "sudo ufw disable"
end
