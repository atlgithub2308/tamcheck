#!/usr/bin/env python3

import os
import json
import subprocess
import sys

def main():
    output_dir = os.environ.get("PT_output_dir")

    if not output_dir or not os.path.isdir(output_dir):
        print(f"No {output_dir} directory exists to dump files")
        sys.exit(1)

    # Create sub-directory
    tamcheck_dir = os.path.join(output_dir, "tamcheck_data")
    os.makedirs(tamcheck_dir, exist_ok=True)

    # Define output files
    output_file = os.path.join(tamcheck_dir, "pe_server_node_count_not_expired.out")
    json_output_file = os.path.join(tamcheck_dir, "pe_server_node_count_not_expired.json")

    # Ensure Puppet commands in PATH
    puppet_bin = "/opt/puppetlabs/bin"
    if puppet_bin not in os.environ.get("PATH", ""):
        os.environ["PATH"] = f"{puppet_bin}:{os.environ['PATH']}"

    # Write start message
    with open(output_file, "w") as f:
        f.write("Collecting PE Server Node Count not expired\n")

    # Run puppet query
    try:
        cmd = ["puppet", "query", "nodes[count(certname)]{expired is null}"]
        result = subprocess.check_output(cmd, text=True)
    except Exception as e:
        with open(output_file, "a") as f:
            f.write(f"Error running puppet query: {e}\n")
        sys.exit(1)

    # Parse the node count
    node_count = "0"
    for line in result.splitlines():
        if '"count":' in line:
            parts = line.split(":")
            if len(parts) > 1:
                node_count = parts[1].strip().replace(",", "").replace("}", "")
                break

    # Append result to text output
    with open(output_file, "a") as f:
        f.write(f"Node Count not expired: {node_count}\n")

    # Write JSON output
    json_data = {"PE_Server_Node_Count_Not_Expired": node_count}
    with open(json_output_file, "w") as jf:
        json.dump(json_data, jf)

    print("")
    print("Output files are located at:")
    print(f"Text output: {output_file}")
    print(f"JSON output: {json_output_file}")
    print("")

if __name__ == "__main__":
    main()
