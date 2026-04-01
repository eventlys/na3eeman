import os
import re

app_dir = "lib"

for root, _, files in os.walk(app_dir):
    for filename in files:
        if not filename.endswith(".dart"): continue
        path = os.path.join(root, filename)
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()

        changed = False

        # Find const Widget(...) where inside there is .tr()
        # This is a bit tricky with regex, so we'll do an iterative approach:
        # Just remove 'const ' if the line contains '.tr()' and doesn't define a class.
        lines = content.split('\n')
        for i, line in enumerate(lines):
            # Fix Today's syntax errors
            if "'today'.tr()s" in line:
                line = line.replace("'today'.tr()s Profit'", "tr('today_s_earnings')")
                line = line.replace("'today'.tr()s Earnings'", "tr('today_s_earnings')")
                line = line.replace("'today'.tr()s Appointments'", "tr('today_s_appointments')")
                lines[i] = line
                changed = True

            if '.tr()' in line or 'tr(' in line:
                if 'const ' in line and not 'const [' in line and not 'const {' in line:
                    # Remove const if it precedes a widget like const Text, const InputDecoration
                    new_line = re.sub(r'const\s+(Text|InputDecoration|DashboardSectionHeader|Center|Padding|SizedBox|Row|Column|Icon|Expanded|Align|Container|ListTile|DropdownMenuItem)', r'\1', line)
                    if new_line != line:
                        lines[i] = new_line
                        changed = True

        new_content = '\n'.join(lines)
        
        # Also let's fix the ambiguous extension member access in error_widget.dart
        if 'error_widget.dart' in path:
            new_content = new_content.replace("'refresh'.tr()", "tr('refresh')")
            new_content = new_content.replace("'go_back'.tr()", "tr('go_back')")
            new_content = new_content.replace("'error'.tr()", "tr('error')")
            changed = True

        if changed:
            with open(path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Fixed const/tr in {path}")
