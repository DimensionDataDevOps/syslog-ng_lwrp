Description
===========

The Syslog NG cookbook installs and configures syslog-ng service. There are two recipes

* syslog-ng enables syslog-ng but does not affect the current system syslog configuration
* syslog-ng::global looks for and disables any existing syslog daemon, and configures syslog-ng to handle system logging

There are also six resources

* syslog_ng_source
* syslog_ng_destination
* syslog_ng_filter
* syslog_ng_logpath
* syslog_ng_file
* syslog_ng_forwarder

The cookbook has been written for and tested on CentOS and Ubuntu with syslog-ng 3.x
Syslog NG can be obtained [here: balabit.com](https://my.balabit.com/downloads/syslog-ng).

Requirements
============

* Chef 12.5+
* Syslog-NG 3.x package

Usage
=====

### In a run list:
    "run_list": [
        "recipe[syslog-ng]"
    ]

### In a cookbook:
    include_recipe "syslog-ng"
    
    syslog_ng_source "network_source" do
      index "01"
      host "127.0.0.1"
      port "514" # TCP+UDP
    end

    syslog_ng_source "custom_source" do
      index "02"
      drivers [
        {
          'driver' => 'syslog',
          'options' => 'port(9999)'
        },
        {
          'driver' => 'pipe',
          'options' => '"/dev/pipe"'
        },
      ]
    end


    syslog_ng_file "application_foo" do
      index "03"
      source_name "source_foo"
      days_uncompressed "7"
      log_base "/var/applogs"
      log_name "default.log"
    end

    syslog_ng_filter "warnings" do
      index  "04"
      filter "level(warning)"
    end

    syslog_ng_forwarder "application_foo_warnings" do
      index "05"
      source_name "custom_source"
      filters ["warnings"]
      destination_host "example.com"
      destination_port "514"
      destination_protocol "udp"
    end

Resources
=========

The resources provided by this cookbook create files in the /etc/syslog-ng/conf.d directory that represent various configuration objects.

Note most resources take an *index* attribute, which is prepended to the files created by the resources.  This is meant to control parse order.  Most syslog-ng directives are not order dependent except that log paths must come after the sources, destinations, and filters they reference.  The *index* attribute is available to control order if necessary, however, it can be left default in most cases.

All resources support :create and :delete actions.

Resources add a Hungarian notation "prefix" to their name option where appropriate.  As syslog-ng objects of different types share the same name space, this practice reduces name conflicts.  Defaults for destinations, sources, and filters are "d_", "s_", and "f_" respectively.

In most cases where an array of things is required, the array can be omitted as a convenience if only one of that thing is required.

syslog_ng_source
----------------

Configures syslog-ng to listen to a variety of types of [sources](https://www.balabit.com/documents/syslog-ng-ose-3.7-guides/en/syslog-ng-ose-guide-admin/html/chapter-sources.html).

If not provided a driver, this resource will use the *host* and *port* parameters to set up tcp and udp syslog listeners.

Attribute parameters:

* name - The name of the source.  Use this name to use the source in a logpath.
* drivers - Array of Hash objects describing which syslog-ng driver(s) to use in this source.  See the syslog-ng documentation for available drivers and their options.

      [{
        'driver' => 'udp',
        'options' => 'ip("localhost") port(514)"
      }]

* index - default '02'
* host - The ip address to listen for connections if not specifying a driver.  Default: 'localhost'
* port - The port number to listen for connections if not specifying a driver.  Default: 514
* source_prefix - default: node['syslog_ng']['source_prefix']
* template_file - override the template. default: 'syslog_ng_source.erb'

syslog_ng_destination
---------------------

Configures syslog-ng to write to a variety of types of [destinations](https://www.balabit.com/documents/syslog-ng-ose-3.7-guides/en/syslog-ng-ose-guide-admin/html/chapter-destinations.html).

Attribute parameters:

* name - The name of the destination.  Use this name to use the destination in a logpath.
* drivers - Array of Hash objects describing which syslog-ng driver(s) to use in this destination.  See the syslog-ng documentation for available drivers and their options.

      [{
        'driver' => 'network',
        'options' => 'host("remotehost")"
      }]

* index - default '02'
* host - The ip address to send syslog message to if not specifying a driver.
* destination_prefix - default: node['syslog_ng']['destination_prefix']
* template_file - override the template. default: 'syslog_ng_destination.erb'


syslog_ng_filter
----------------

Configures a message [filter](https://www.balabit.com/documents/syslog-ng-ose-3.7-guides/en/syslog-ng-ose-guide-admin/html/filters.html).  All filters applied to a message must return "true" or the message is dropped.

Note that filters are sensitive to ordering when referencing each other.

    syslog_ng_filter 'not_info' do
      filter 'not level(info)'
    end

Attribute parameters:

* name - The name of the filter.
* index - default: '03'
* filter_prefix - Default: node['syslog_ng']['filter_prefix']
* template_file - Override the template. default: 'syslog_ng_filter.erb'
* filter -  The actual filter string.

syslog_ng_logpath
-----------------

Connects a list of sources to a list of log paths with an optional list of filters.

Note that log paths can be order dependent if using flags such as *final*.

Attribute parameters:property :name, String, name_property: true

* name - A name for the logpath.  This is only used in chef as log paths are anonymous in syslog-ng.
* index - default: '04'
* sources - An array of strings naming the sources data is to be read from. (sans prefix)
* filters - An array of strings naming the filters applied to the log path.  If a message is read from a source and evaulates *false* from any of the filters on the path, the message is not sent to the destinations.  The message may however still be read from another path, if the same source is used in multiple paths.
* destinations An array of strings naming the destinations to send log messages to.
* flags - An array of [flag](https://www.balabit.com/documents/syslog-ng-ose-3.7-guides/en/syslog-ng-ose-guide-admin/html/reference-logflags.html) strings.
* source_prefix, filter_prefix, destination_prefix - Specifies the prefix for sources, filters, and destinations if not using the defaults.
* template_file - Override the template. default: 'syslog_ng_logpath.erb'

syslog_ng_file
--------------

A convenience method creating a destination to log to a file.

If any *source*s are specified, a syslog_ng_logpath is created read messages from those sources into this file.

The path to logfiles is generated by concatenating log_base, the application name, and log_name. When setting log_base and log_name you can use syslog-ng macros. For example, log_name could be "${YEAR}/${MONTH}/${DAY}/${HOUR}.log"

A compression cron job is provided.

* name - A name for the destination and logpath.
* index - default: '04'
* sources - An array of strings naming the sources data is to be read from. (sans prefix)
* source_prefix - default: node['syslog_ng']['source_prefix']
* filters - An array of strings naming the filters applied to the log path.

* days_uncompressed - The number of days to delay compression default: 1
* log_base - The base directory of the log path. default: node['syslog_ng']['log_dir']
* log_name - the name of the log file its self. default: 'default.log'

syslog_ng_forwarder
-------------------

A convenience method creating a destination to forward logs to another syslog server.

If any *source*s are specified, a syslog_ng_logpath is created forward messages from those sources to this destination.

* name - A name for the destination and logpath.
* index - default: '04'
* sources - An array of strings naming the sources data is to be read from. (sans prefix)
* source_prefix - default: node['syslog_ng']['source_prefix']
* filters - An array of strings naming the filters applied to the log path.

* destination_host - the host to forward message to.
* destination_port - the port on the remote host default: '514'
* destination_protocol, - The protocol (driver) to use.  default: 'udp'


License and Author
==================

This cookbook is based on the syslog-ng cookbook originally by Artem Veremey (<artem@veremey.net>).  Significant updates provided by Jason McNew (<foonix@yahoo.com>)

Copyright 2012, Artem Veremey
Re-factored syslog-ng::global to use internal LWRPs
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Changes
=======

### v 2.0.2 (beta)
* Converted definitions to Chef 12.5 style LWRPs
* Re-factored syslog-ng::global to use internal LWRPs
* Cleanup unused init script.
* Update documentation in README.md.

### v 2.0.1 (beta)

* Added support for ubuntu and centos 7.
* Added action :delete to all resources
* Remove logpaths generated by syslog_ng_file and syslog_ng_forwarder if no source is set.
* Add restart notification to ::global.  Fixes #15.

### v 2.0.0 (beta)

* Significant rewrite of conf.d inclusion code.  This requires versions of syslog-ng that support the @include directive and no longer overwrites the operating system's init scripts.  
  Warning: This breaks compatibility with older versions of the cookbook.  The init script that ships with the syslog-ng package will have to be reinstalled.
* Added configurations for test kitchen, berkshelf, and basic integration tests
* Added support for ubuntu, centos 6, and centos 7.
* Added new resources for building arbitrary source, logpath, and destination chains with airbrary filters.
* Rubocop / foodcritic cleanup
* Hungarian prefixes are added to all resource names automatically.

### v 1.3.0

* Create filter definition and have file and forwarder optionally take a filter

### v 1.2.0

* Break source out into its own definition

### v 1.1.0

* adding a new definition for configuring forwarding
* renaming the defintion that writes files to make that clearer in the name
* in the definition for writing files, allow specifying file name
* in the definition for writing files, compress old log files
* moving system logging configuration from the default recipe to a new recipe


### v 1.0.0

* Initial public release
