name             'syslog-ng'
maintainer       'Jason McNew'
maintainer_email 'foonix@yahoo.com'
license          'Apache 2.0'
description      'Installs/Configures syslog-ng'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.0.0'

depends 'yum-epel', '~> 0.6.3'

supports 'centos', '~> 6.0'
