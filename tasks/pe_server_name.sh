#!/bin/sh

# Puppet Task Name: pe_server_name
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

# Create output files
output_file="pe_server_name_$(date +%F).txt"
# html_output_file="tse-$(date +%F).html"
create_date="$(date +%d\/%m\/%Y)"

# Create a temporary directory
# temp_dir=$(mktemp -d)
# input_file="$temp_dir/cert-expire.txt"


printf "$create_date" > "$output_file"
printf "\n" >> "$output_file"
printf "Collecting PE Server Name \n"
printf "PE Server Name = " >> "$output_file"
puppet config print | awk '/^server =/ {print $3}' >> "$output_file"


