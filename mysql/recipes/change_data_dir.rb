python "Prepare Disk" do
  code <<-EOH
import subprocess
import glob
partitions = glob.glob('/dev/disk/by-id/*')
mount_point = "#{node['mount_point']}"
for partition in partitions:
    print(str(partition).upper())
    try:
        if int(subprocess.check_output("mkfs.ext4 -F %s 1>>/dev/null 2>>/dev/null; echo $?" % partition, shell=True)) == 0:
            if int(subprocess.check_output("mkdir -p %s 1>>/dev/null 2>>/dev/null; echo $?" % mount_point, shell=True)) == 0:
                if int(subprocess.check_output("mount -o discard,defaults %s %s 1>>/dev/null 2>>/dev/null; echo $?" % (partition, mount_point), shell=True)) == 0:
                    if int(subprocess.check_output('echo %s %s ext4 defaults,nofail,discard 0 0 >> /etc/fstab; echo $?' % (partition, mount_point), shell=True)) == 0:
                        print("Success with %s " % partition)
                        break
                    else:
                        print("Failed to write FSTAB with disk %s " % partition)
                else:
                    print ("Failed to mount disk with disk %s " % partition)
            else:
                print ("Fail to Create Directory with disk %s " % partition)
        else:
            print ("Fail to make filesystem of disk %s " % partition)
    except:
        pass
  EOH
end

ohai 'Ohai Reload' do
  action :reload
end

execute "Stop MySQL" do
  command "service #{node['mysql_service']} stop"
end

script 'Backup MySQL data' do
  interpreter "bash"
  cwd "/var/lib/"
  code <<-EOH
    dt=`date +%Y_%m_%d-%H_%M_%S`
    tar cvf mysql.$dt.tar.gz mysql
  EOH
end

execute "Sync MySQL Data" do
  command "sudo rsync -av /var/lib/mysql #{node['mount_point']}"
end

execute "Configure AppArmor Access Control" do
  command "echo 'alias /var/lib/mysql/ -> #{node['mount_point']}/mysql/,' >> /etc/apparmor.d/tunables/alias"
end

package 'Install Pip installer' do
  package_name 'python-pip'
end

execute "Install Config Parser" do
  command "pip install configparser"
end

python "Configure MySQL Data Dir" do
  code <<-EOH
import ConfigParser

config = ConfigParser.RawConfigParser(allow_no_value=True)
config.read('#{node['mysql_cnf']}')
config.set('mysqld', 'datadir', '#{node['mount_point']}/mysql/')
with open('#{node['mysql_cnf']}', 'wb') as configfile:
    config.write(configfile)
  EOH
end

execte "Restart App Armor" do
  command "service apparmor restart"
end

execute "Start MySQL" do
  command "service #{node['mysql_service']} restart"
end