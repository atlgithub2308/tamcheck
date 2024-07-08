
#!/bin/bash

# Create output files
output_file="tse-$(date +%F).txt"
html_output_file="tse-$(date +%F).html"
create_date="$(date +%d\/%m\/%Y)"

# Create a temporary directory
temp_dir=$(mktemp -d)
input_file="$temp_dir/cert-expire.txt"

# Function to append a separator
append_separator() {
  printf "\n=======================\n\n" >> "$1"
}

# Function to collect command output and handle errors
collect_output() {
  local description="$1"
  local command="$2"
  printf "Collecting ${description} \n"
  eval "$command" 2>&1 | tee -a "$output_file"
  if [ "${PIPESTATUS[0]}" -ne 0 ]; then
    echo "Error collecting ${description}" | tee -a "$output_file"
  fi
  # append_separator "$output_file"
}

printf  "" > "$output_file"
printf "Collecting PE Server Name \n"
puppet config print | awk '/^server =/ {print $3}' >> "$output_file"1

append_separator "$output_file"

# Want to see in the next bit what info we can collect about the physical/virtual server


hostnamectl
printf "Collecting PE Server Details \n"
hostnamectl 1>> "$output_file"
lscpu 1>> "$output_file"
lsmem 1>> "$output_file"

# Add a separator for now - need to revisit this when we properly format the output 
append_separator "$output_file"

# Puppet Server Cert Expiry
printf "Collecting PE Server CA Certificate Status \n"
/opt/puppetlabs/puppet/bin/openssl x509 -in "$(/opt/puppetlabs/bin/puppet config print hostcert)" --enddate --noout > "$input_file"
awk '{print "Puppet Enterprise Server Certificate valid until: " substr($1,10,3) " " $2 " " $4}' "$input_file" >> "$output_file"
rm -f "$input_file"

# Add a separator for now - need to revisit this when we properly format the output 
append_separator "$output_file"

# Get PE Server status
printf "Collecting PE Server Infra Status \n"
puppet infrastructure status >> "$output_file"
# puppet infrastructure status  --render-as json >> "$output_file"

# Add a separator for now - need to revisit this when we properly format the output 
append_separator "$output_file"

# Get PE Server tuning status
printf "Collecting PE Server Tuning Status \n"
puppet infrastructure tune --compare >> "$output_file"

# Add a separator for now - need to revisit this when we properly format the output 
append_separator "$output_file"

# Get PE Server Module List (think Puppetfile here)
printf "Collecting PE Server Module List \n"
# puppet module list 2>>"$output_file" 1>>"$output_file"
puppet module list 2>>"$output_file" 1>>"$output_file"
# puppet module list --render-as json >>"$output_file"

# printf "\n\n"
# puppet module list 1>>"$output_file"

# Add a separator for now - need to revisit this when we properly format the output 
append_separator "$output_file"

# Get PE Server node count
printf "Collecting PE Server Node Count \n"
printf "Number of Nodes = " >> "$output_file"
puppet query 'nodes[count(certname)]{deactivated is null and expired is null}' | awk '/    "count":/ {print $2}' >> "$output_file"
# puppet query 'nodes[count(certname)]{deactivated is null and expired is null}' >> "$output_file"

# Add a separator for now - need to revisit this when we properly format the output 
append_separator "$output_file"

# Get PE Server node count that are not expired
printf "Collecting PE Server Node Count not expired \n"
printf "Number of Nodes not expired = " >> "$output_file"
puppet query 'nodes[count(certname)]{expired is null}' | awk '/    "count":/ {print $2}' >> "$output_file"

# Add a separator for now - need to revisit this when we properly format the output 
append_separator "$output_file"

# Get PE Server node count for inactive nodes
printf "Collecting PE Server Node Count Inactive\n"
printf "Number of Nodes are inactive = " >> "$output_file"
puppet query 'nodes[count(certname)]{ node_state = "inactive"}' | awk '/    "count":/ {print $2}' >> "$output_file"

# Add a separator for now - need to revisit this when we properly format the output 
append_separator "$output_file"

# Get PE Server node count for Nodes using a cached catalog
printf "Collecting PE Server Node Count using cached catalog \n"
printf "Number of Nodes are using cached catalog = " >> "$output_file"
puppet query 'nodes[count(certname)]{cached_catalog_status = "used"}' | awk '/    "count":/ {print $2}' >> "$output_file"

# Add a separator for now - need to revisit this when we properly format the output 
append_separator "$output_file"

# Get PE Server node count for Nodes without updated catalog
# Nodes without an updated catalog in the past 24-48 hours:
# Note: update the date to yesterday's date (YYYY-MM-DD). This identifies nodes that have not successfully compiled a new catalog within the past 24-48 hours:
printf "Collecting PE Server Node Count without updated catalog \n"
printf "Number of Nodes without updated catalog = " >> "$output_file"
puppet query 'nodes[count(certname)]{ catalog_timestamp < "2024-05-28T00:00:00.000Z" }' | awk '/    "count":/ {print $2}' >> "$output_file"

append_separator "$output_file"

printf "\n============ Collection Complete ============\n"
printf "============ Output file = $output_file"
printf "\n"

# Generate HTML output
{
  echo "<!DOCTYPE html>"
  echo "<html><head><title>Puppet Enterprise Server Report</title>"
  echo "<style>"
  echo "body { font-family: Arial, sans-serif; margin: 20px; }"
  echo "h1 { text-align: center; }"
  echo "h2 { color: #2e6c80; border-bottom: 1px solid #ddd; padding-bottom: 10px; }"
  echo "pre { background: #f4f4f4; border: 1px solid #ddd; padding: 10px; }"
  echo ".section { margin-bottom: 20px; }"
  echo "</style>"
  echo "</head><body>"
  echo "<h1>Puppet Enterprise Server Report</h1>"
  echo "<h2>$create_date</h2>"

  section_titles=("PE Server Name" "PE Server Details" "PE Server CA Certificate Status" "PE Server Infra Status" "PE Server Tuning Status" "PE Server Module List" "PE Server Node Count" "PE Server Node Count not expired" "PE Server Inactive Node Count" "PE Server Node Count using cached catalog" "PE Server Node Count without updated catalog")
  section_content=$(grep -n "=======================" "$output_file" | cut -d: -f1)

  start_line=1
  index=0
  for end_line in $section_content; do
    title="${section_titles[$index]}"
    content=$(sed -n "${start_line},${end_line}p" "$output_file")
    # to_html=$(echo "${content}" | head -n 1)
    echo "<div class='section'>"
    echo "<h2>$title</h2>"
    echo "<pre>$content</pre>"
    echo "</div>"
    start_line=$((end_line + 1))
    index=$((index + 1))
  done

  echo "</body></html>"
} > "$html_output_file"

printf "============ HTML output file = $html_output_file \n"