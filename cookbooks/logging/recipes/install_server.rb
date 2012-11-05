#
# Cookbook Name:: logging
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

logging "default" do
  action :configure_server
end

ruby_block 'Fix configuration permissions' do
  block do
    def replace_text(source, target)
      config_file = '/etc/rsyslog.conf'
      text = File.read(config_file)
      modified = text.gsub(/#{source}/, "#{target}")
      File.open(config_file, 'w') { |f| f.puts(modified) }
    end

    replace_text('$FileOwner syslog', '$FileOwner root')
    replace_text('$FileGroup adm', '$FileGroup root')
    replace_text('$PrivDropToUser syslog', '$PrivDropToUser root')
    replace_text('$PrivDropToGroup syslog', '$PrivDropToGroup root')
  end
end

rightscale_marker :end
