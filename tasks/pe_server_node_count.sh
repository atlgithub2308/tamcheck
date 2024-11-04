#!/bin/sh

# Puppet Task Name: pe_server_node_count_with_json
#
# This script collects the Puppet Enterprise server node count and saves the output
# both in a standard text file and as a JSON file.
#
# Ensure the output directory exists or exit with an error
if [ -d "${PT_output_dir}" ]; then
    if [ ! -d "${PT_output_dir}/tamcheck_data" ]; then
        mkdir -p "${PT_output_dir}/tamcheck_data"
    fi
    output_dir="${PT_output_dir}/tamcheck_data"
else
    echo "No ${PT_output_dir} directory exists to dump files"
    exit 1
fi

# Ensure Puppet commands can be found in the PATH
[[ $PATH =~ "/opt/puppetlabs/bin" ]] || export PATH="/opt/puppetlabs/bin:${PATH}"

# File paths for output
output_file="${output_dir}/pe_server_node_count.out"
json_output_file="${output_dir}/pe_server_node_count.json"

# Get PE Server node count and write to text and JSON files
printf "Collecting PE Server Node Count \n"
printf "Number of Nodes = " | tee "$output_file"
node_count=$(puppet query 'nodes[count(certname)]{deactivated is null and expired is null}' | awk '/    "count":/ {print $2}')
echo "$node_count" | tee -a "$output_file"

# Create JSON output
echo "{\"node_count\": $node_count}" > "$json_output_file"

echo ""
echo "Output_file is found here: ${output_file}"
echo "JSON output file is found here: ${json_output_file}"
echo ""
