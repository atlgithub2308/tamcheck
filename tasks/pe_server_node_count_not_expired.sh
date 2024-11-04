#!/bin/sh

# Puppet Task Name: pe_server_node_detail

if [ -d "${PT_output_dir}" ]; then
    if [ ! -d "${PT_output_dir}/tamcheck_data" ]; then
        mkdir -p "${PT_output_dir}/tamcheck_data"
    fi
    output_dir="${PT_output_dir}/tamcheck_data"
else
    echo "No ${PT_output_dir} directory exists to dump files"
    exit
fi

# Ensure pathing is set to be able to run puppet commands
[[ $PATH =~ "/opt/puppetlabs/bin" ]] || export PATH="/opt/puppetlabs/bin:${PATH}"

# Define output files
output_file="${output_dir}/pe_node_detail.out"
json_output_file="${output_dir}/pe_node_detail.json"

# Capture each node count in a variable, using default values if null
total_node_count=$(puppet query 'nodes[count(certname)]{}' | awk '/"count":/ {print $2}')
total_node_count=${total_node_count:-0}

active_nodes_count=$(puppet query 'nodes[count(certname)]{deactivated is null and expired is null}' | awk '/"count":/ {print $2}')
active_nodes_count=${active_nodes_count:-0}

not_expired_count=$(puppet query 'nodes[count(certname)]{expired is null}' | awk '/"count":/ {print $2}')
not_expired_count=${not_expired_count:-0}

inactive_nodes_count=$(puppet query 'nodes[count(certname)]{node_state = "inactive"}' | awk '/"count":/ {print $2}')
inactive_nodes_count=${inactive_nodes_count:-0}

cached_catalog_count=$(puppet query 'nodes[count(certname)]{cached_catalog_status = "used"}' | awk '/"count":/ {print $2}')
cached_catalog_count=${cached_catalog_count:-0}

# Write to text output file for verification
{
    echo "PE Server Total Node Count: $total_node_count"
    echo "PE Server Node Count (minus deactivated & expired nodes): $active_nodes_count"
    echo "PE Server Node Count (Number of Nodes not expired): $not_expired_count"
    echo "PE Server Node Count (Inactive nodes): $inactive_nodes_count"
    echo "PE Server Node Count (Nodes using a cached catalog): $cached_catalog_count"
} | tee "$output_file"

# Write to JSON output file using jq
jq -n \
    --arg total_node_count "$total_node_count" \
    --arg active_nodes_count "$active_nodes_count" \
    --arg not_expired_count "$not_expired_count" \
    --arg inactive_nodes_count "$inactive_nodes_count" \
    --arg cached_catalog_count "$cached_catalog_count" \
    '{
        "PE_Server_Total_Node_Count": $total_node_count,
        "PE_Server_Node_Count_Active": $active_nodes_count,
        "PE_Server_Node_Count_Not_Expired": $not_expired_count,
        "PE_Server_Node_Count_Inactive": $inactive_nodes_count,
        "PE_Server_Node_Count_Cached_Catalog": $cached_catalog_count
    }' > "$json_output_file"

echo ""
echo "Output files are located at:"
echo "Text output: ${output_file}"
echo "JSON output: ${json_output_file}"
echo ""

