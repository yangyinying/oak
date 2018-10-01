#
# # encoding: utf-8

# Inspec test for recipe role_windows_ims::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

control '.NET Machine Configs' do
  impact 1.0
  title 'Verify all .NET machine configs'

  describe file('C:\Windows\Microsoft.NET\Framework\v4.0.30319\Config\machine.config') do
    it { should exist }
  end

  describe file('C:\Windows\Microsoft.NET\Framework\v2.0.50727\Config\machine.config') do
    it { should exist }
  end

  describe file('C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Config\machine.config') do
    it { should exist }
  end

  describe file('C:\Windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\machine.config') do
    it { should exist }
  end
end
