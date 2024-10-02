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
result=[]
network_json = json.loads('''$network_setting_json''')
for net_name, details in network_json.items():

    result.append({
        "Name": net_name,
        "ID": details["NetworkID"][:12],
        "IP": f'{details["IPAddress"]}/{details["IPPrefixLen"]}'
    })

print(json.dumps(result, indent=4))
EOF

    # python3 -c "import json; result=[]; \
    #             network_json=json.loads('$network_setting_json'); \
    #             result=[{'Name': net_name, 'ID': network_json[net_name]['NetworkID'][:12], 'IP': ('{}/{}').format(network_json[net_name]['IPAddress'], network_json[net_name]['IPPrefixLen'])} for net_name in network_json]; \
    #             print(json.dumps(result, indent=4));"

    echo "---------------------------"
done
