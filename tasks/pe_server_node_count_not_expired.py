#!/usr/bin/env python3

import os
import json
import subprocess
import sys
import traceback

def main():
    # Get output_dir from environment, default to /var/tmp if not provided
    output_dir = os.environ.get("PT_output_dir", "/var/tmp")

    # Ensure the output directory exists
    if not os.path.isdir(output_dir):
        try:
            os.makedirs(output_dir, exist_ok=True)
        except Exception as e:
            print(f"Cannot create output directory {output_dir}: {e}", file=sys.stderr)
            sys.exit(1)

    # Create tamcheck_data subdirectory
    tamcheck_dir = os.path.join(output_dir, "tamcheck_data")
    os.makedirs(tamcheck_dir, exist_ok=True)

    # Define output files
    output_file = os.path.join(tamcheck_dir, "pe_server_node_count_not_expired.out")
    json_output_file = os.path.join(tamcheck_dir, "pe_server_node_count_not_expired.json")

    # Ensure Puppet commands in PATH (if needed)
    puppet_bin = "/opt/puppetlabs/bin"
    if puppet_bin not in os.environ.get("PATH", ""):
        os.environ["PATH"] = f"{puppet_bin}:{os.environ['PATH']}"

    # Start logging
    with open(output_file, "w") as f:
        f.write("Collecting PE Server Node Count not expired\n")
    print("Collecting PE Server Node Count not expired")

    # Run puppet query safely
    node_count = "0"
    try:
        cmd = ["puppet", "query", "nodes[count(certname)]{expired is null}"]
        result = subprocess.check_output(cmd, text=True)
        for line in result.splitlines():
            if '"count":' in line:
                parts = line.split(":")
                if len(parts) > 1:
                    node_count = parts[1].strip().replace(",", "").replace("}", "")
                    break
    except Exception as e:
        error_msg = f"Error running puppet query: {e}\n{traceback.format_exc()}"
        print(error_msg, file=sys.stderr)  # show error on screen
        with open(output_file, "a") as f:
            f.write(error_msg + "\n")
        node_count = "0"

    # Log node count
    with open(output_file, "a") as f:
        f.write(f"Node Count not expired: {node_count}\n")
    print(f"Node Count not expired: {node_count}")

    # Write JSON output
    json_data = {"PE_Server_Node_Count_Not_Expired": node_count}
    with open(json_output_file, "w") as jf:
        json.dump(json_data, jf)

    # Print summary
    print("\nOutput files are located at:")
    print(f"Text output: {output_file}")
    print(f"JSON output: {json_output_file}\n")

if __name__ == "__main__":
    main()
