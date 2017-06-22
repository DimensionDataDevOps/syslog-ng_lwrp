name             'syslog-ng'
maintainer       'Jason McNew'
maintainer_email 'foonix@yahoo.com'
license          'Apache-2.0'
description      'Installs/Configures syslog-ng'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.0.4'
issues_url       'https://github.com/DimensionDataDevOps/syslog-ng_lwrp/issues'
source_url       'https://github.com/DimensionDataDevOps/syslog-ng_lwrp'

chef_version '~> 12.9'
chef_version '~> 13'

supports 'centos', '~> 6.0'
