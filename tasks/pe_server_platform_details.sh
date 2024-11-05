#!/bin/sh

# Puppet Task Name: pe_server_platform_details

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
output_file="${output_dir}/pe_server_platform_details.out"
json_output_file="${output_dir}/pe_server_platform_details.json"

# Collect platform details using Puppet facts
fqdn=$(puppet facts networking.fqdn --render-as s | awk -F\" '{print $4}')
ip=$(puppet facts networking.ip --render-as s | awk -F\" '{print $4}')
os_name=$(puppet facts os.name --render-as s | awk -F\" '{print $4}')
os_ver=$(puppet facts os.release.full --render-as s | awk -F\" '{print $4}')
vcpu=$(puppet facts processors.count --render-as s | awk -F\> '{print $2}' | sed 's/\}//g')
cpu_model=$(puppet facts processors.models --render-as s | awk -F\" '{print $4}')
memory=$(puppet facts memory.system.total --render-as s | awk -F\" '{print $4}')

# Output to console and .out file
echo "PE Server FQDN: ${fqdn}" | tee "$output_file"
echo "PE Server IP Address: ${ip}" | tee -a "$output_file"
echo "PE Server Operating System: ${os_name}" | tee -a "$output_file"
echo "PE Server Operating System Version: ${os_ver}" | tee -a "$output_file"
echo "PE Server vCPU Count: ${vcpu}" | tee -a "$output_file"
echo "PE Server CPU Model: ${cpu_model}" | tee -a "$output_file"
echo "PE Server Memory: ${memory}" | tee -a "$output_file"

# Create JSON output file
cat <<EOF > "$json_output_file"
{
    "PE Server FQDN": "$fqdn",
    "PE Server IP Address": "$ip",
    "PE Server Operating System": "$os_name",
    "PE Server Operating System Version": "$os_ver",
    "PE Server vCPU Count": "$vcpu",
    "PE Server CPU Model": "$cpu_model",
    "PE Server Memory": "$memory"
}
EOF

echo ""
echo "Output files are located at:"
echo "Text output: ${output_file}"
echo "JSON output: ${json_output_file}"
echo ""
