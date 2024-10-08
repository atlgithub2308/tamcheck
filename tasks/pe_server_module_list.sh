#!/bin/bash

# Puppet Task: pe_server_module_list
# This script lists the installed Puppet modules, writes the output to a file,
# converts the output to JSON, and saves both files in the specified directory.

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
output_file="${output_dir}/pe_server_module_list.out"

# Generate the clean output file without color codes and exclude '---' lines
puppet module list --color=false | perl -pe 's/\e\[[0-9;]*[a-zA-Z]//g' | grep -v '^---' > "$output_file"

# Convert the output to JSON format
json_output_file="${output_dir}/pe_server_module_list.json"

# Read the output file, extract module names and versions, and convert to JSON
awk '
BEGIN { print "{" }
{
    if ($1 ~ /^\//) {
        next  # Skip lines that start with '/' (these are directories)
    }
    if (NR > 1) printf ",\n"
    match($0, /\((v[^\)]+)\)/, ver)  # Match the version number
    module_name = $1
    module_version = ver[1]
    printf "  \"%s\": \"%s\"", module_name, module_version
}
END { print "\n}" }
' "$output_file" > "$json_output_file"

# Output the location of the result file
echo ""
echo "Output file is found here: ${output_file}"
echo "JSON output file is found here: ${json_output_file}"
echo ""

# Display the output with version numbers in the terminal
echo "Displaying module output:"
cat "$output_file" | perl -pe 's/\((v[^\)]+)\)/"\e[34m($1)\e[0m"/g'
