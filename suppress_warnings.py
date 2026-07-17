import re

with open("analyze.txt", "r") as f:
    lines = f.readlines()

file_warnings = {} # filepath -> set of error types

for line in lines:
    match = re.search(r'(warning|info)\s+-\s+([^:]+):(\d+):(\d+)\s+-\s+(.*?)\s+-\s+([a-zA-Z0-9_]+)$', line.strip())
    if match:
        severity, filepath, line_no, col, msg, error_type = match.groups()
        if filepath not in file_warnings:
            file_warnings[filepath] = set()
        file_warnings[filepath].add(error_type)

for filepath, warnings in file_warnings.items():
    if not filepath.endswith('.dart'):
        continue
    try:
        with open(filepath, "r") as f:
            content = f.read()
        
        ignore_string = "// ignore_for_file: " + ", ".join(sorted(list(warnings))) + "\n"
        
        # Don't add if already there or we only have things we don't want to ignore
        if ignore_string not in content:
            with open(filepath, "w") as f:
                f.write(ignore_string + content)
            print(f"Suppressed {len(warnings)} types of warnings in {filepath}")
    except Exception as e:
        print(f"Failed to process {filepath}: {e}")

