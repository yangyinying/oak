#
# # encoding: utf-8

# Inspec test for recipe role_windows_ims::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

control 'Installed Packages' do
  impact 1.0
  title 'Check for installed packages'

  describe package('IMSServerInstaller') do
    it { should be_installed }
  end

  describe package('PowerMTA 4.0r13') do
    it { should be_installed }
    its('version') { should eq '40.101.21073.54272' }
  end

  describe package('GACInstaller') do
    it { should be_installed }
  end
end
