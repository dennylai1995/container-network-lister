# Container Network Lister

A script to list network information of all running docker containers.

## Usage
```bash
$ bash container-network-lister.sh
[container_name]
modest_nightingale

[port_mapping]
3000/tcp -> 0.0.0.0:3000
3000/tcp -> [::]:3000

[network]
[
    {
        "Host NIC Name": "docker0",
        "Name": "bridge",
        "ID": "3070dc0814bf",
        "IP": "172.26.0.2/16"
    }
]
---------------------------
```

## Test Environment
<table>
    <tr>
        <td>OS</td>
        <td>Ubuntu 20.04</td>
    </tr>
    <tr>
        <td>Docker</td>
        <td>23.0.3, build 3e7cbfd</td>
    </tr>
</table>
