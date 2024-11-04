#!/bin/sh

# Puppet Task Name: pe_server_node_count_not_expired

if [ -d "${PT_output_dir}" ]; then
    if [ ! -d "${PT_output_dir}/tamcheck_data" ]; then
        mkdir -p "${PT_output_dir}/tamcheck_data"
    fi
    output_dir="${PT_output_dir}/tamcheck_data"
else
    echo "No ${PT_output_dir} directory exists to dump files"
    exit 1
fi

# Ensure PATH includes Puppet commands
[[ $PATH =~ "/opt/puppetlabs/bin" ]] || export PATH="/opt/puppetlabs/bin:${PATH}"

# Define output files
output_file="${output_dir}/pe_server_node_count_not_expired.out"
json_output_file="${output_dir}/pe_server_node_count_not_expired.json"

# Get PE Server node count that are not expired
printf "Collecting PE Server Node Count not expired\n" | tee "$output_file"
node_count=$(puppet query 'nodes[count(certname)]{expired is null}' | awk '/"count":/ {print $2}')
node_count=${node_count:-"0"}  # Use 0 if node_count is empty

# Log the node count for debugging
echo "Node Count not expired: $node_count" | tee -a "$output_file"

# Create JSON output
echo "{\"PE_Server_Node_Count_Not_Expired\": \"$node_count\"}" > "$json_output_file"

echo ""
echo "Output files are located at:"
echo "Text output: ${output_file}"
echo "JSON output: ${json_output_file}"
echo ""
