import re

with open("analyze.txt", "r") as f:
    lines = f.readlines()

fixes = {} # filepath -> {line_no: [error_type, variable_name]}

for line in lines:
    # Example line:
    #    info - lib/main.dart:118:12 - 'ShowCaseWidget' is deprecated and shouldn't be used... - deprecated_member_use
    #    warning - lib/Helpers/analytics_helper.dart:185:11 - The value of the local variable 'eventParameters' isn't used. Try removing the variable or using it. - unused_local_variable
    match = re.search(r'(warning|info)\s+-\s+([^:]+):(\d+):(\d+)\s+-\s+(.*?)\s+-\s+([a-zA-Z0-9_]+)$', line.strip())
    if match:
        severity, filepath, line_no, col, msg, error_type = match.groups()
        line_no = int(line_no)
        
        if error_type in ['unused_local_variable', 'unused_element', 'unused_field', 'unused_import', 'dead_null_aware_expression']:
            if filepath not in fixes:
                fixes[filepath] = []
            fixes[filepath].append(line_no)

for filepath, line_numbers in fixes.items():
    try:
        with open(filepath, "r") as f:
            file_lines = f.readlines()
        
        # Sort line numbers in descending order to delete safely
        for line_no in sorted(list(set(line_numbers)), reverse=True):
            idx = line_no - 1
            if idx < len(file_lines):
                if error_type == 'unused_import' or 'unused_local_variable' in error_type or 'unused_element' in error_type:
                    file_lines[idx] = "// " + file_lines[idx]
                else:
                    file_lines[idx] = "// " + file_lines[idx]

        with open(filepath, "w") as f:
            f.writelines(file_lines)
            
        print(f"Fixed {len(line_numbers)} issues in {filepath}")
    except Exception as e:
        print(f"Failed to fix {filepath}: {e}")

