#!/bin/bash

# Puppet Task: pe_server_module_list
# This script lists the installed Puppet modules, writes the output to a file,
# and displays the version numbers in color when shown in the terminal.

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

# Generate the clean output file without color codes
puppet module list --color=false | perl -pe 's/\e\[[0-9;]*[a-zA-Z]//g' > "$output_file"

# Output the location of the result file
echo ""
echo "Output file is found here: ${output_file}"
echo ""

# Display the output with version numbers in the terminal
echo "Displaying module output:"
cat "$output_file" | perl -pe 's/\((v[^\)]+)\)/"\e[34m($1)\e[0m"/g'
