#
# Cookbook:: role_windows_ims
# Recipe:: default
#
# Copyright:: 2017, Salesforce, All Rights Reserved.

include_recipe 'sf_windows_apps::default'

data_bag = data_bag_item(node.chef_environment, 'windows_svc_accounts')
windows_svc_user = data_bag['username']
# If joined to the domain, set windows_svc_user to domain.local\user for domain joined testing.
is_joined_to_domain = (powershell_out('Write-Host (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain').stdout.strip == 'True')
if is_joined_to_domain
  windows_svc_user = [node['domain'], windows_svc_user].join('\\')
end
windows_svc_password = data_bag['password']

service_user = windows_svc_user
unless is_joined_to_domain || windows_svc_user.include?('\\')
  service_user = ['.', windows_svc_user].join('\\')
end

# Create directories
directory 'D:\pmta' do
  inherits true
  rights WINDOWS_PERM.fetch(:full_control), [windows_svc_user], applies_to_children: true
end

directory 'D:\pmta\inbound'

directory 'D:\pmta\log'

directory 'D:\pmta\spool'

directory 'D:\pmta\dead_letter'

directory 'D:\pmta\dupe_letter'

# Install msi
include_recipe 'sf_windows_apps::ims_server'
include_recipe 'sf_windows_apps::powermta'
# Rapter runbook SERVER-IMS.ps1 does not have the step to install GAC, but pester test checks it, so add it
include_recipe 'sf_windows_apps::gac'

directory 'C:\PMTA' do
  inherits true
  rights WINDOWS_PERM.fetch(:modify), [windows_svc_user], applies_to_children: true
  rights WINDOWS_PERM.fetch(:synchronize), [windows_svc_user], applies_to_children: true
end

cookbook_file 'files/license.dat' do
  path 'C:\pmta\license.dat'
end

cookbook_file 'files/config.dat' do
  path 'C:\pmta\config.dat'
end

# Copy the config files in place
include_recipe 'sf_machine_config::default'

# Register relay service
batch 'Register relay service' do
  code 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe D:\services\RelayService.exe'
  not_if { ::Win32::Service.exists?('Exacttarget Relay') }
end

batch 'Register relay monitor' do
  code 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe D:\services\RelayMonitorService.exe'
  not_if { ::Win32::Service.exists?('ExactTarget Relay Monitor') }
end

batch 'Register relay recycle' do
  code 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe D:\services\RelayRecycleService.exe'
  not_if { ::Win32::Service.exists?('ExactTarget Relay Recycle') }
end

directory 'D:\Services' do
  inherits true
  rights WINDOWS_PERM.fetch(:synchronize), [windows_svc_user], applies_to_children: true
  rights WINDOWS_PERM.fetch(:read_and_execute), [windows_svc_user], applies_to_children: true
end

services = [
  'Exacttarget Relay',
  'ExactTarget Relay Monitor',
  'ExactTarget Relay Recycle',
]
services.each do |service|
  windows_service service do
    action :configure_startup
    startup_type :manual
    timeout 600
    run_as_user service_user
    run_as_password windows_svc_password
  end

  powershell_script "Set User for #{service}" do
    code "(gwmi win32_service -filter \"name='#{service}'\").change($null,$null,$null,$null,$null,$null,'#{service_user}','#{windows_svc_password.gsub("'", %(' + "'" + '))}',$null,$null,$null)"
    not_if "if ((gwmi win32_service -filter \"name='#{service}'\").StartName -eq '#{service_user}') {return $true} else {return $false}"
  end
end
