#!/bin/sh

# Puppet Task Name: pe_server_node_detail

if [ -d "${PT_output_dir}" ]; then
    # Create output directory if it doesn't exist
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

# Define output files
output_file="${output_dir}/pe_server_node_detail.out"
json_output_file="${output_dir}/pe_server_node_detail.json"

# Initialize output file and JSON structure
echo "" > "$output_file"
json_output="{\"node_counts\": {}}"

# Function to collect node counts
get_node_count() {
    local query="$1"
    local description="$2"
    local count=$(puppet query "$query" | awk '/"count":/ {print $2}')

    # Check if count is empty
    if [ -z "$count" ]; then
        count=0  # Set count to 0 if empty
    fi

    # Print and log to output file
    echo "$description: $count" | tee -a "$output_file"

    # Update JSON output
    json_output=$(echo "$json_output" | jq --arg key "$description" --argjson value "$count" '.node_counts[$key] = $value')
}

# Collecting data
get_node_count 'nodes[count(certname)]{}' "PE Server Total Node Count"
get_node_count 'nodes[count(certname)]{deactivated is null and expired is null}' "PE Server Node Count (minus de-activated & expired nodes)"
get_node_count 'nodes[count(certname)]{expired is null}' "PE Server Node Count (Number of Nodes not expired)"
get_node_count 'nodes[count(certname)]{node_state = "inactive"}' "PE Server Node Count (Inactive nodes)"
get_node_count 'nodes[count(certname)]{cached_catalog_status = "used"}' "PE Server Node Count (Nodes using a cached catalog)"

# Write JSON output to file
echo "$json_output" | jq . > "$json_output_file"

# Check if JSON file is created and populated
if [ -s "$json_output_file" ]; then
    echo "JSON output successfully written to: $json_output_file"
else
    echo "Failed to write JSON output."
fi

echo ""
echo "Output files are located at:"
echo "Text output: ${output_file}"
echo "JSON output: ${json_output_file}"
echo ""
