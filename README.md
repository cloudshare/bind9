Description
===========
Installs and configures a Bind9 name server.

Requirements
============
Ubuntu. Other platforms were not tested, and might require tweaking the package
names and configuration files.

Attributes
==========
+ `options_file` - Location to store the `named.conf.options` file (defaults to
  `/etc/bind/named.conf.options`).
+ `local_file` - Location to store the `named.conf.local` file (defaults to
  `/etc/bind/named.conf.local`).
+ `data_dir` - Location to store the zone files, journal files, etc (defaults to
  `/var/lib/bind`).
+ `log_dir` - Location to store log files (defaults to `/var/log/bind`).
+ `forwarders` - Name servers to forward requests to (defaults to `[ '8.8.8.8',
  '8.8.4.4' ]`).
+ `'user` - System user to run the service under (defaults to `bind`).
+ `zones_db_item` - A data bag item in a data bag named after the environment
  describing the zones (defaults to `zones`).

Usage
=====
The default recipe will also create the attribute `node[bind][rndc_key]` which
will hold the required key for updating the name server (e.g. from a DHCP
server), this works with the CloudShare DHCP3 cookbook.

Zone files define the zones to manage, control the SOA record of each zone, and
should look like this:

    {
        "id": "zones",
        "zones": {
            "staging.loc": {
                "global_ttl": 60,
                "contact": "devops",
                "type": "master",
                "master_nameserver": {
                    "name": "ns1.staging.loc",
                    "ip": "10.0.0.254"
                },
                "records": [],
                "mode": "dhcp",
                "updaters": [ "any" ]
            },
            "s.staging.loc": {
                "global_ttl": 60,
                "contact": "devops",
                "type": "master",
                "master_nameserver": {
                    "name": "ns1.s.staging.loc",
                    "ip": "10.0.0.254"
                },
                "records": [
                    {
                        "name": "www",
                        "ip": "10.0.0.240",
                        "ttl": 60,
                        "type": "A"
                    }
                ],
                "mode": "managed",
                "updaters": [ "any" ]
            }
        }
    }

+ The `master_nameserver` entry should point to the zone's master server.
+ When `mode` is set to 'dhcp', the recipe will only create the zone file when
  it is missing. When it is set to 'managed', it will be constantly rewritten,
  allowing the entries to be populated based on the 'records' map in the zone
  file.
+ The 'updaters' list provides a way to control the access list of peers allowed
  to update the zone.

License and Author
==================

Author:: Leeor Aharon (<leeor@cloudshare.com>)

Copyright 2013 CloudShare, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
