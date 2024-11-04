#!/bin/sh

# Puppet Task Name: pe_server_node_detail

# Check for output directory
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
json_content="{\"node_counts\": {}}"

# Function to get node counts
get_node_count() {
    local query="$1"
    local description="$2"
    local count

    # Execute the query and extract the count
    count=$(puppet query "$query" | awk '/"count":/ {print $2}')
    
    # Default count to 0 if the command fails to return a valid number
    [ -z "$count" ] && count=0

    # Print and log to output file
    echo "$description: $count" | tee -a "$output_file"

    # Prepare JSON entry
    json_entry="\"$description\": $count"
    json_content=$(echo "$json_content" | jq --arg key "$description" --argjson value "$count" '.node_counts[$key] = $value')
}

# Collect data for each query
get_node_count 'nodes[count(certname)]{}' "PE Server Total Node Count"
get_node_count 'nodes[count(certname)]{deactivated is null and expired is null}' "PE Server Node Count (minus de-activated & expired nodes)"
get_node_count 'nodes[count(certname)]{expired is null}' "PE Server Node Count (Number of Nodes not expired)"
get_node_count 'nodes[count(certname)]{node_state = "inactive"}' "PE Server Node Count (Inactive nodes)"
get_node_count 'nodes[count(certname)]{cached_catalog_status = "used"}' "PE Server Node Count (Nodes using a cached catalog)"

# Write JSON output to file
echo "$json_content" | jq . > "$json_output_file"

# Check if JSON file was created and populated
if [ -s "$json_output_file" ]; then
    echo "JSON output successfully written to: $json_output_file"
else
    echo "Failed to write JSON output. Check permissions and query results."
    exit 1
fi

echo "Output files are located at:"
echo "Text output: ${output_file}"
echo "JSON output: ${json_output_file}"
echo ""
