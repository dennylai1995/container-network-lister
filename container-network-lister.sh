set -e

container_list=($(docker ps --format='{{print .Names}}'))

for ((index=0; index<${#container_list[@]}; index++))
do
    container_name="${container_list[$index]}"
    network_setting_json=$(docker inspect --format "{{json .NetworkSettings.Networks}}" $container_name)
    port_mapping=$(docker port $container_name)

    printf "[container_name]\n$container_name\n\n"
    printf "[port_mapping]\n$port_mapping\n\n"
    printf "[network]\n"

    # here-document (a way to pass multiline strings to commands), <<EOF ~ EOF are passed to python
    python3 - <<EOF
import json
import subprocess
import re

# thanks to ChatGPT
def find_interface_by_ip(ipv4_address):
    if ipv4_address == "":
        return None

    # Run ifconfig to get network interface information
    try:
        ifconfig_result = subprocess.check_output("ifconfig", universal_newlines=True)
    except subprocess.CalledProcessError:
        return None
    
    # Split the ifconfig output by interface sections
    interfaces = re.split(r'(?=^\S)', ifconfig_result, flags=re.MULTILINE)
    
    # Loop through each interface's block of information
    for interface in interfaces:
        # Extract the interface name (the first word before the colon)
        iface_name = re.match(r'^\S+', interface)
        if iface_name:
            iface_name = iface_name.group(0).rstrip(":")
        
        # Search for the IP address in the current interface's block
        if ipv4_address in interface:
            return iface_name
    
    return None

result=[]
network_json = json.loads('''$network_setting_json''')
for net_name, details in network_json.items():

    cmd = ["docker", "network", "inspect", net_name, "--format='{{range .IPAM.Config}}{{.Gateway}}{{end}}'"]

    cmd_result = subprocess.run(cmd, capture_output=True, text=True)

    gateway_ip = cmd_result.stdout.strip().replace("'", "")

    result.append({
        "Host NIC Name": find_interface_by_ip(gateway_ip),
        "Name": net_name,
        "ID": details["NetworkID"][:12],
        "IP": f'{details["IPAddress"]}/{details["IPPrefixLen"]}'
    })

print(json.dumps(result, indent=4))
EOF

    echo "---------------------------"
done
