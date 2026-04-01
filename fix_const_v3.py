import os
import re
from pathlib import Path

# Fix the specific file parsing errors
dialog_path = Path("lib/Helpers/customized/dialog_helper.dart")
if dialog_path.exists():
    c = dialog_path.read_text()
    c = c.replace("'select_language'.tr()", "tr('select_language')")
    c = c.replace("'english'.tr()", "tr('english')")
    c = c.replace("'select_theme'.tr()", "tr('select_theme')")
    c = c.replace("'light_mode'.tr()", "tr('light_mode')")
    c = c.replace("'dark_mode'.tr()", "tr('dark_mode')")
    dialog_path.write_text(c)

onboard_path = Path("lib/Packages/features/onboarding/pages/onboarding.dart")
if onboard_path.exists():
    c = onboard_path.read_text()
    c = c.replace("'i'.tr()m a Customer'", "tr('i_m_a_customer')")
    c = c.replace("'i'.tr()m a Barber / Staff'", "tr('i_m_a_barber_staff')")
    onboard_path.write_text(c)

app_dir = "lib"

# Fix const evaluation loops
for root, _, files in os.walk(app_dir):
    for filename in files:
        if not filename.endswith(".dart"): continue
        path = os.path.join(root, filename)
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()

        changed = False

        if '.tr()' in content or 'tr(' in content:
            lines = content.split('\n')
            for i, line in enumerate(lines):
                if '.tr()' in line or 'tr(' in line:
                    if 'const ' in line and not 'const [' in line and not 'const {' in line:
                        new_line = re.sub(r'const\s+(Text|InputDecoration|DashboardSectionHeader|Center|Padding|SizedBox|Row|Column|Icon|Expanded|Align|Container|ListTile|DropdownMenuItem|[A-Z][a-zA-Z0-9_]*)', r'\1', line)
                        if new_line != line:
                            lines[i] = new_line
                            changed = True

            if changed:
                new_content = '\n'.join(lines)
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f"Removed inline const in {path}")
