#!/bin/sh

# Puppet Task Name: pe_server_tuning_status

# Check for the output directory
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
output_file="${output_dir}/pe_server_tuning_status.out"
json_output_file="${output_dir}/pe_server_tuning_status.json"

# Run the puppet infrastructure tune command and capture output
tuning_output=$(puppet infrastructure tune --compare)

# Write to .out file
echo "$tuning_output" | tee "$output_file"

# Process the output for JSON format by splitting lines and creating JSON structure
# Extract each setting and value if the output has a recognizable structure (e.g., key: value)
json_content="{"
while IFS= read -r line; do
    if [[ "$line" =~ ^[[:alnum:]_]+: ]]; then
        key=$(echo "$line" | awk -F':' '{print $1}' | xargs)
        value=$(echo "$line" | awk -F':' '{print $2}' | xargs)
        json_content+="\"$key\": \"$value\","
    fi
done <<< "$tuning_output"
json_content="${json_content%,}}"  # Remove trailing comma and close JSON object

# Write JSON content to the .json file
echo "$json_content" > "$json_output_file"

# Final confirmation messages
echo ""
echo "Output files are located at:"
echo "Text output: ${output_file}"
echo "JSON output: ${json_output_file}"
echo ""

