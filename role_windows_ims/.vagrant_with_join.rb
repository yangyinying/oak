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
SHELL

  # Join Domain
  config.vm.provision 'shell' do |s|
    s.inline = <<-SHELL
      $password = $Args[1] | ConvertTo-SecureString -asPlainText -Force
      $username = $Args[0]
      $targetDomain = $Args[2]
      $credential = New-Object System.Management.Automation.PSCredential($username, $password)
      Write-Output $Args[0]
      Add-Computer -DomainName $targetDomain -Credential $credential
    SHELL
    s.args = [ENV.fetch('DOMAIN_USER'), ENV.fetch('DOMAIN_PASSWORD'), ENV.fetch('TARGET_DOMAIN', 'qa.local')]
  end

  config.vm.provision 'shell', inline: <<SHELL
winrm set winrm/config/client '@{TrustedHosts="*"}'
SHELL

end
