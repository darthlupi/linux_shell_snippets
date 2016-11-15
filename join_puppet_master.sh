#!/bin/bash
#########################
#Description:  This script will install puppet and configure the agent to point  
# towards the server you specify in the $SERVER variable.
#Last modified:    11/30/2015
#Last modified by: Robert Lupinek
#########################

#Server FQDN
SERVER='PUPPET.FQDN.COM'

# and add the puppet package
yum -t -y -e 0 install puppet --nogpg

echo "Configuring puppet"
cat > /etc/puppet/puppet.conf << EOF

[main]
vardir = /var/lib/puppet
logdir = /var/log/puppet
rundir = /var/run/puppet
ssldir = \$vardir/ssl

[agent]
pluginsync      = true
report          = true
ignoreschedules = true
daemon          = false
ca_server       = $SERVER
certname        = `hostname`
environment     = production
server          = $SERVER

EOF

# Setup puppet to run on system reboot
/sbin/chkconfig --level 345 puppet on

/usr/bin/puppet agent --config /etc/puppet/puppet.conf -o --tags no_such_tag --server $SERVER --no-daemonize

#Run the initial test
puppet agent --test

#Echo next steps
echo "At this point you will need to login to the Foreman server and sign the pending cert from this server."
echo "Browse to this URL: https://$SERVER/smart_proxies/1-$SERVER/puppetca?state=pending"
echo "Run 'puppet agent test' on the host you just signed, and verify all is working."
echo "You should be able to configure the host for any host group or Puppet modules you need using Foreman now."
