# Clean Firewall
bash "Clean Firewall" do
  code <<-EOH
    export WORKDIR='/opt/chefworkspace'
    export RRFILE=$WORKDIR/rrules.file
    export ARFILE=$WORKDIR/arules.file
    mkdir -p $WORKDIR
    iptables-save | grep "^-A INPUT" | grep 'REJECT'> $RRFILE
    sed -i 's/^-A/iptables -D/g' $RRFILE
    while read line
    do
    $line
    done < $RRFILE
    iptables-save | grep "^-A INPUT" | grep 'ACCEPT'> $ARFILE
    sed -i 's/^-A/iptables -D/g' $ARFILE
    while read line
    do
    $line
    done < $ARFILE
    iptables -X
  EOH
end
