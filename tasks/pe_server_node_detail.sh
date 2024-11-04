#!/bin/sh

# Puppet Task Name: pe_server_node_detail

if [ -d "${PT_output_dir}" ]; then
    if [ ! -d "${PT_output_dir}/tamcheck_data" ]; then
        mkdir -p "${PT_output_dir}/tamcheck_data"
    fi
    output_dir="${PT_output_dir}/tamcheck_data"
else
    echo "No ${PT_output_dir} directory exists to dump files"
    exit 1
fi

# Ensure pathing is set to be able to run puppet commands
[[ $PATH =~ "/opt/puppetlabs/bin" ]] || export PATH="/opt/puppetlabs/bin:${PATH}"

# File variable to use in redirections of command outputs to files
output_file_pe_node_count="${output_dir}/pe_server_node_detail.out"
json_output_file="${output_dir}/pe_server_node_detail.json"

# Initialize output files
echo "" > "$output_file_pe_node_count"
declare -A node_counts

# Get total PE Server Node Count
node_counts[total]=$(puppet query 'nodes[count(certname)]{}' | awk '/"count":/ {print $2}')
echo -n "PE Server Total Node Count: ${node_counts[total]}" >> "$output_file_pe_node_count"
echo "" >> "$output_file_pe_node_count"

# Get PE Server Node Count (minus deactivated & expired nodes)
node_counts[active]=$(puppet query 'nodes[count(certname)]{deactivated is null and expired is null}' | awk '/"count":/ {print $2}')
echo -n "PE Server Node Count (minus de-activated & expired nodes): ${node_counts[active]}" >> "$output_file_pe_node_count"
echo "" >> "$output_file_pe_node_count"

# Get PE Server Node Count (Number of Nodes not expired)
node_counts[not_expired]=$(puppet query 'nodes[count(certname)]{expired is null}' | awk '/"count":/ {print $2}')
echo -n "PE Server Node Count (Number of Nodes not expired): ${node_counts[not_expired]}" >> "$output_file_pe_node_count"
echo "" >> "$output_file_pe_node_count"

# Get PE Server Node Count (Inactive nodes)
node_counts[inactive]=$(puppet query 'nodes[count(certname)]{node_state = "inactive"}' | awk '/"count":/ {print $2}')
echo -n "PE Server Node Count (Inactive nodes): ${node_counts[inactive]}" >> "$output_file_pe_node_count"
echo "" >> "$output_file_pe_node_count"

# Get PE Server Node Count (Nodes using a cached catalog)
node_counts[cached]=$(puppet query 'nodes[count(certname)]{cached_catalog_status = "used"}' | awk '/"count":/ {print $2}')
echo -n "PE Server Node Count (Nodes using a cached catalog): ${node_counts[cached]}" >> "$output_file_pe_node_count"
echo "" >> "$output_file_pe_node_count"

# Create JSON output
jq -n \
    --arg total "${node_counts[total]}" \
    --arg active "${node_counts[active]}" \
    --arg not_expired "${node_counts[not_expired]}" \
    --arg inactive "${node_counts[inactive]}" \
    --arg cached "${node_counts[cached]}" \
    '{
        "PE_Server_Total_Node_Count": $total,
        "PE_Server_Node_Count_Active": $active,
        "PE_Server_Node_Count_Not_Expired": $not_expired,
        "PE_Server_Node_Count_Inactive": $inactive,
        "PE_Server_Node_Count_Cached": $cached
    }' > "$json_output_file"

echo ""
echo "Output files are located at:"
echo "Text output: ${output_file_pe_node_count}"
echo "JSON output: ${json_output_file}"
echo ""
