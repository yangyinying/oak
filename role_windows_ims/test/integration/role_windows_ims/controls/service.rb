#
# # encoding: utf-8

# Inspec test for recipe role_windows_ims::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

# Attributes
windows_svc_user = attribute('windows_svc_user', description: 'Default service account for running the end application') || raise('No windows_svc_user found in attributes')
is_joined_to_domain = (powershell('Write-Host (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain').stdout.strip == 'True')
unless is_joined_to_domain || windows_svc_user.include?('\\')
  windows_svc_user = ['.', windows_svc_user].join('\\')
end

sledgehammer_svc_user = attribute('sledgehammer_svc_user', description: 'ExactTarget user') || raise('No attribute sledgehammer_svc_user')

control 'Service Validation' do
  impact 1.0
  title 'Verify ExactTarget Configuration Service'

  describe sf_win_service('ExactTarget Configuration Service') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
    its('pathname') { should eq '"D:\ExactTargetSCM\Configuration Service\ExactTarget.SCM.Service.exe"' }
    its('username') { should include(sledgehammer_svc_user) }
  end

  describe sf_win_service('Exacttarget Relay') do
    it { should be_installed }
    # it { should be_running }
    its('pathname') { should eq '"D:\services\RelayService.exe"' }
    its('username') { should cmp windows_svc_user }
  end

  describe sf_win_service('ExactTarget Relay Monitor') do
    it { should be_installed }
    # it { should be_running }
    its('pathname') { should eq '"D:\services\RelayMonitorService.exe"' }
    its('username') { should cmp windows_svc_user }
  end

  describe sf_win_service('ExactTarget Relay Recycle') do
    it { should be_installed }
    # it { should be_running }
    its('pathname') { should eq '"D:\services\RelayRecycleService.exe"' }
    its('username') { should cmp windows_svc_user }
  end
end
