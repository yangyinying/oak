#
# # encoding: utf-8

# Inspec test for recipe role_windows_ims::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

# Attributes
windows_svc_user = attribute('windows_svc_user', description: 'Default service account for running the end application') || raise('No windows_svc_user found in attributes')

control 'Folders and files validation' do
  impact 1.0
  title 'Validate the folders and files permissions'

  describe directory('D:\\') do
    it { should exist }
  end

  describe directory('D:\Data') do
    it { should exist }
  end

  describe file('D:\pmta') do
    it { should exist }
    it { should be_directory }
  end

  describe directory('D:\pmta\inbound') do
    it { should exist }
  end

  describe directory('D:\pmta\log') do
    it { should exist }
  end

  describe directory('D:\pmta\spool') do
    it { should exist }
  end

  describe directory('D:\pmta\dead_letter') do
    it { should exist }
  end

  describe directory('D:\pmta\dupe_letter') do
    it { should exist }
  end

  describe file('C:\pmta\license.dat') do
    it { should exist }
  end

  describe file('C:\pmta\config.dat') do
    it { should exist }
  end

  describe file('C:\pmta\bin\pmtawatch.exe') do
    it { should exist }
  end

  describe win_file('D:\Services') do
    it { should exist }
    it { should be_directory }
    it { should be_allowed('Synchronize', by_user: windows_svc_user) }
    it { should be_allowed('ReadAndExecute', by_user: windows_svc_user) }
  end

  describe win_file('C:\PMTA') do
    it { should exist }
    it { should be_directory }
    it { should be_allowed('Synchronize', by_user: windows_svc_user) }
    it { should be_allowed('Modify', by_user: windows_svc_user) }
  end
end
