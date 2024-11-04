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

# Initialize output file
echo "" > "$output_file"

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
    
    # Return the description and count for JSON formatting
    echo "\"$description\": $count"
}

# Collecting data and format for JSON
json_content="{\"node_counts\": {"
first_entry=true

# Collecting counts for each category
for query_info in 'nodes[count(certname)]{}:PE Server Total Node Count' \
                  'nodes[count(certname)]{deactivated is null and expired is null}:PE Server Node Count (minus de-activated & expired nodes)' \
                  'nodes[count(certname)]{expired is null}:PE Server Node Count (Number of Nodes not expired)' \
                  'nodes[count(certname)]{node_state = "inactive"}:PE Server Node Count (Inactive nodes)' \
                  'nodes[count(certname)]{cached_catalog_status = "used"}:PE Server Node Count (Nodes using a cached catalog)'; do
    query=${query_info%%:*}
    description=${query_info#*:}
    node_data=$(get_node_count "$query" "$description")

    # Append to JSON content
    if [ "$first_entry" = true ]; then
        json_content="$json_content$node_data"
        first_entry=false
    else
        json_content="$json_content, $node_data"
    fi
done

json_content="$json_content}}"

# Write JSON content to file
echo "$json_content" > "$json_output_file"

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
