#!/bin/sh

# Puppet Task Name: pe_server_node_detail
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
if [ -d ${T_output_dir} ]
then
    if [ ! -d "${PT_output_dir}/tamcheck_data" ]
    then
        mkdir -p "${PT_output_dir}/tamcheck_data"
        output_dir="${PT_output_dir}"
        output_dir+="/"
        output_dir+="tamcheck_data"
    else
        output_dir="${PT_output_dir}"
        output_dir+="/"
        output_dir+="tamcheck_data"
    fi
else
    echo "No ${PT_output_dir} directory exists to dump files"
    exit
fi

# Ensure pathing is set to be able to run puppet commands
[[ $PATH =~ "/opt/puppetlabs/bin" ]] || export PATH="/opt/puppetlabs/bin:${PATH}"

# File variable to use in redirections of command outputs to files
output_file_pe_node_count="${output_dir}/pe_node_count.out"

echo "" > $output_file_pe_node_count
echo -n "PE Server Total Node Count: " >> $output_file_pe_node_count
puppet query 'nodes[count(certname)]{}' | awk '/"count":/ {print $2}' >> $output_file_pe_node_count
echo "" >> $output_file_pe_node_count

echo -n "PE Server Node Count (minus de-actived & expired nodes): " >> $output_file_pe_node_count
puppet query 'nodes[count(certname)]{deactivated is null and expired is null}' | awk '/"count":/ {print $2}' >> $output_file_pe_node_count
echo "" >> $output_file_pe_node_count

echo -n "PE Server Node Count (Number of Nodes not expired): " >> $output_file_pe_node_count
puppet query 'nodes[count(certname)]{expired is null}' | awk '/"count":/ {print $2}' >> $output_file_pe_node_count 
echo "" >> $output_file_pe_node_count

echo -n "PE Server Node Count (Inactive nodes): " >> $output_file_pe_node_count
puppet query 'nodes[count(certname)]{node_state = "inactive"}' | awk '/"count":/ {print $2}' >> $output_file_pe_node_count
echo "" >> $output_file_pe_node_count

echo -n "PE Server Node Count (Nodes using a cached catalog): " >> $output_file_pe_node_count
puppet query 'nodes[count(certname)]{cached_catalog_status = "used"}' | awk '/"count":/ {print $2}' >> $output_file_pe_node_count
echo "" >> $output_file_pe_node_count