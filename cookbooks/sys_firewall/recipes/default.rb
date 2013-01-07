#
# Cookbook Name:: sys_firewall
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

if node[:sys_firewall][:enabled] == "enabled"
  # See https://github.com/rightscale/cookbooks/blob/master/iptables/recipes/default.rb for the "iptables::default" recipe.
  include_recipe "iptables"
  # See cookbooks/sys_firewall/providers/default.rb for the "update" action.
  sys_firewall "22" # SSH
  sys_firewall "80" # HTTP
  sys_firewall "443" # HTTPS

  if node[:cloud][:provider] == "softlayer"
    # Open ports for SoftLayer monitoring agent
    (48000..48020).each do |port|
      sys_firewall port do
        ip_addr "10.0.0.0" # Net mask to open to all addresses on the internal 10.*.*.*
      end
    end
  end

else
  service "iptables" do
    supports :status => true
    action [:disable, :stop]
  end
end


# Increase connection tracking table sizes
#
# Increase the value for the 'net.ipv4.netfilter.ip_conntrack_max' parameter
# to avoid dropping packets on high-throughput systems.
#
# The ip_conntrack_max is calculated based on the RAM available on
# the VM using this formula: ip_conntrack_max=32*n, where n is the amount
# of RAM in MB. For the instance types greater or equal to 2GB, the value is
# 65536.

if node[:platform] =~ /redhat|centos/
  GB=1024*1024
  mem_mb = node[:memory][:total].to_i/1024
  conn_max = (mem_mb >= 2*GB) ? 65536 : 32*mem_mb

  log "  Setup IP connection tracking limit of #{conn_max}"
  bash "Update net.ipv4.ip_conntrack_max" do
    flags "-ex"
    code "sysctl -e -w net.ipv4.ip_conntrack_max=#{conn_max}"
  end
end


rightscale_marker :end
