#!/bin/sh

# Puppet Task Name: pe_server_infrastructure_status
# This script checks the Puppet Enterprise server infrastructure status,
# writes the output to a file, filters out unwanted lines, and converts the output to JSON format.

# Check if the output directory exists, create it if necessary
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
output_file="${output_dir}/pe_server_infrastructure_status.out"

# Run the puppet infrastructure status command and filter out the unwanted line
puppet infrastructure status | grep -v "Notice: Contacting services for status information..." | tee "$output_file"

# Convert the output to JSON format
json_output_file="${output_dir}/pe_server_infrastructure_status.json"

# Transform the status file to JSON (basic transformation for illustrative purposes)
awk '
BEGIN { print "{\"infrastructure_status\": [" }
{
    gsub(/"/, "\\\"")  # Escape double quotes
    if (NR>1) printf ",\n"
    printf "  \"%s\"", $0
}
END { print "\n]}" }
' "$output_file" > "$json_output_file"

# Output the location of both the result files
echo "Output file is found here: ${output_file}"
echo "JSON output file is found here: ${json_output_file}"

