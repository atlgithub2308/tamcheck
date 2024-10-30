#!/bin/sh

# Puppet Task Name: pe_server_ca_status
#
# This is where you put the shell code for your task.
#
# You can write Puppet tasks in any language you want and it's easy to
# adapt an existing Python, PowerShell, Ruby, etc. script. Learn more at:
# https://puppet.com/docs/bolt/0.x/writing_tasks.html
#
# Puppet tasks make it easy for you to enable others to use your script. Tasks
# describe what it does, explains parameters and which are required or optional,
# as well as validates parameter type. For examples, if parameter "instances"
# must be an integer and the optional "datacenter" parameter must be one of
# portland, sydney, belfast or singapore then the .json file
# would include:
#   "parameters": {
#     "instances": {
#       "description": "Number of instances to create",
#       "type": "Integer"
#     },
#     "datacenter": {
#       "description": "Datacenter where instances will be created",
#       "type": "Enum[portland, sydney, belfast, singapore]"
#     }
#   }
# Learn more at: https://puppet.com/docs/bolt/0.x/writing_tasks.html#ariaid-title11
#

# Puppet Task Name: pe_server_ca_status
# This script collects the Puppet Enterprise Server CA certificate expiry status,
# saves it to a file, and also converts it to JSON format.

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
output_file="${output_dir}/pe_server_ca_status.out"
json_output_file="${output_dir}/pe_server_ca_status.json"
input_file="${output_dir}/pe_server_ca_status.in"

# Collect the CA certificate expiry status and save it to the output file
printf "Collecting PE Server CA Certificate Status \n"
/opt/puppetlabs/puppet/bin/openssl x509 -in "$(/opt/puppetlabs/bin/puppet config print hostcert)" -enddate -noout > "$input_file"
awk '{print "Puppet Enterprise Server Certificate valid until: " substr($1,10,3) " " $2 " " $4}' "$input_file" | tee "$output_file"
rm -f "$input_file"

# Convert the output file to JSON format
expiry_date=$(awk '{print $7, $8, $9}' "$output_file")
echo "{ \"PEServerCACertificateExpiry\": \"$expiry_date\" }" > "$json_output_file"

echo ""
echo "Output file is found here: ${output_file}"
echo "JSON output file is found here: ${json_output_file}"
echo ""
