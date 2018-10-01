# vim: ft=ruby
Vagrant.configure(2) do |config|
  config.vm.boot_timeout = 1800
  config.winrm.retry_limit = 30
  config.winrm.retry_delay = 10
  config.vm.provision 'shell', inline: <<SHELL
$script = @"
select volume 1
shrink desired=10000
select disk 0
create partition primary
assign letter=d
select volume 2
format fs=ntfs quick label=Data
"@
$script | diskpart
winrm set winrm/config/client '@{TrustedHosts="*"}'
SHELL
end
