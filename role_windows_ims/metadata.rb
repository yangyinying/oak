name 'role_windows_ims'
maintainer 'Salesforce'
maintainer_email 'mc-infraautomation@salesforce.com'
license 'All Rights Reserved'
description 'Installs/Configures role_windows_ims'
long_description 'Installs/Configures role_windows_ims'
version '1.0.4'
chef_version '>= 12.1' if respond_to?(:chef_version)
issues_url 'https://github.com/<insert_org_here>/role_windows_ims/issues'
source_url 'https://github.com/<insert_org_here>/role_windows_ims'

supports 'windows', '= 6.1' # Server 2008r2
supports 'windows', '>= 10' # Server 2016+

depends 'sf_windows_apps', '= 3.0.0'
depends 'sf_machine_config', '= 2.0.1'
