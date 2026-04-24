import re
from pathlib import Path

files = [
    "lib/Packages/Core/widgets/navigation/app_bottom_nav.dart",
    "lib/Packages/features/navigation/overlays/report_problem_overlay.dart",
    "lib/Packages/features/navigation/overlays/report_salon_overlay.dart",
    "lib/Packages/features/salon/overlays/Inventory_add_item_dialog.dart",
    "lib/Packages/features/salon/pages/salon_details.dart",
    "lib/Packages/features/salon/pages/salon_schedule_page.dart",
    "lib/Packages/features/staff/pages/receptionist/receptionist_feedback_page.dart",
    "lib/app/app.dart"
]

for f in files:
    p = Path(f)
    if not p.exists(): continue
    c = p.read_text()
    
    lines = c.split('\n')
    for i in range(len(lines)):
        if '.tr()' in lines[i] or 'tr(' in lines[i]:
            lines[i] = lines[i].replace('const InputDecoration(', 'InputDecoration(').replace('const Text(', 'Text(').replace('const Padding(', 'Padding(').replace('const Center(', 'Center(').replace('const SizedBox(', 'SizedBox(').replace('const DropdownMenuItem', 'DropdownMenuItem').replace('const BottomNavigationBarItem', 'BottomNavigationBarItem').replace('const Align', 'Align')
    p.write_text('\n'.join(lines))
