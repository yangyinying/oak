#
# # encoding: utf-8

# Inspec test for recipe role_windows_ims::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

control 'Registry key' do
  impact 1.0
  title 'Validation the registry keys'

  describe registry_key(
    hive: 'HKEY_LOCAL_MACHINE',
    key: 'System\\CurrentControlSet\\Control\\FileSystem'
  ) do
    its('NtfsDisable8dot3NameCreation') { should eq 1 }
  end

  describe registry_key('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4.0') do
    #     [+] .Net Framework 4 should be installed 913ms
    it { should exist }
  end

  describe registry_key('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full') do
    #     [+] .Net Framework 4.5 or higher should be installed 813ms
    it { should exist }
    it { should have_property 'version' }
    its('version') { should cmp > '4.5' }
  end
end
