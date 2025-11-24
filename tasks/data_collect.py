#!/usr/bin/env python3

import os
import sys
import tarfile
import datetime

def main():
    # Get output directory from environment
    pt_output_dir = os.environ.get("PT_output_dir")
    if not pt_output_dir:
        print("PT_output_dir is not set, terminating task.", file=sys.stderr)
        sys.exit(1)

    tamcheck_dir = os.path.join(pt_output_dir, "tamcheck_data")
    if not os.path.isdir(tamcheck_dir):
        print(f"{tamcheck_dir} does not exist, run the collection task(s) first.", file=sys.stderr)
        sys.exit(1)

    # List files with .out or .json
    files_to_archive = [f for f in os.listdir(tamcheck_dir) if f.endswith(".out") or f.endswith(".json")]
    if not files_to_archive:
        print(f"{tamcheck_dir} does not contain any output files, run the collection task(s) first.", file=sys.stderr)
        sys.exit(1)

    # Archive files
    date_str = datetime.datetime.now().strftime("%d-%m-%y")
    archive_name = f"tamcheck_archive_{date_str}.tar.gz"
    archive_path = os.path.join(tamcheck_dir, archive_name)

    try:
        with tarfile.open(archive_path, "w:gz") as tar:
            for file_name in files_to_archive:
                tar.add(os.path.join(tamcheck_dir, file_name), arcname=file_name)
        print(f"Created archive: {archive_path}")
    except Exception as e:
        print(f"Error creating archive: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
