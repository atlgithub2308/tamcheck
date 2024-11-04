#!/bin/sh

# Puppet Task Name: pe_server_node_detail

if [ -d ${PT_output_dir} ]; then
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
output_file="${output_dir}/pe_server_node_detail.out"
json_output_file="${output_dir}/pe_server_node_detail.json"

# Initialize output file and JSON structure
echo "" > $output_file
json_output="{\"node_counts\": {}}"

# Collect data and update both output file and JSON
get_node_count() {
    local query="$1"
    local description="$2"
    local count=$(puppet query "$query" | awk '/"count":/ {print $2}')
    
    # Print and log to output file
    echo -n "$description: " | tee -a $output_file
    echo "$count" | tee -a $output_file

    # Update JSON output
    json_output=$(echo "$json_output" | jq --arg key "$description" --argjson value "$count" '.node_counts[$key] = $value')
}

get_node_count 'nodes[count(certname)]{}' "PE Server Total Node Count"
get_node_count 'nodes[count(certname)]{deactivated is null and expired is null}' "PE Server Node Count (minus de-activated & expired nodes)"
get_node_count 'nodes[count(certname)]{expired is null}' "PE Server Node Count (Number of Nodes not expired)"
get_node_count 'nodes[count(certname)]{node_state = "inactive"}' "PE Server Node Count (Inactive nodes)"
get_node_count 'nodes[count(certname)]{cached_catalog_status = "used"}' "PE Server Node Count (Nodes using a cached catalog)"

# Write JSON output to file
echo "$json_output" | jq . > "$json_output_file"

echo ""
echo "Output files are located at:"
echo "Text output: ${output_file}"
echo "JSON output: ${json_output_file}"
echo ""
