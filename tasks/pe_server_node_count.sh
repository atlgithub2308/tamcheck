#!/bin/sh

# Puppet Task Name: pe_server_node_count
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

# Get PE Server node count
printf "Collecting PE Server Node Count \n"
printf "Number of Nodes = " >> "$output_file"
puppet query 'nodes[count(certname)]{deactivated is null and expired is null}' | awk '/    "count":/ {print $2}' >> "$output_file"
# puppet query 'nodes[count(certname)]{deactivated is null and expired is null}' >> "$output_file"

# Add a separator for now - need to revisit this when we properly format the output 
append_separator "$output_file"

