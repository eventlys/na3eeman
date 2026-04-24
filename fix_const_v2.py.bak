import re

def fix_errors(filepaths):
    from pathlib import Path
    
    # 1. Ambiguous extensions in error_widget.dart
    error_w = Path("lib/Packages/Core/widgets/shared/error_widget.dart")
    if error_w.exists():
        content = error_w.read_text()
        content = content.replace("'refresh'.tr()", "tr('refresh')").replace("'go_back'.tr()", "tr('go_back')")
        error_w.write_text(content)

    # 2. Fix const invocations in the list
    files_to_deconst = [
        "lib/Packages/Core/utils/helpers/profile_helper_functions.dart",
        "lib/Packages/features/auth/pages/signup.dart",
        "lib/Packages/features/home/pages/barber_home.dart",
        "lib/Packages/features/navigation/overlays/contact_us_overlay.dart",
        "lib/Packages/features/navigation/overlays/feedback_overlay.dart",
        "lib/Packages/features/navigation/overlays/report_problem_overlay.dart",
        "lib/Packages/features/navigation/overlays/report_salon_overlay.dart",
        "lib/Packages/features/owner/widgets/campaign_management_widgets.dart",
        "lib/Packages/features/salon/widgets/customer_salon_ads.dart",
        "lib/Packages/features/salon/widgets/inventory_alert_card.dart",
        "lib/Packages/features/salon/widgets/offers_card.dart",
        "lib/Packages/features/salon/widgets/staff_management_page.dart",
        "lib/Packages/features/staff/pages/receptionist_dashboard.dart",
        "lib/Packages/features/subscription/pages/subscription_upgrade.dart",
    ]

    for f in files_to_deconst:
        p = Path(f)
        if p.exists():
            content = p.read_text()
            lines = content.split('\n')
            for i in range(len(lines)):
                if '.tr()' in lines[i]:
                    lines[i] = re.sub(r'const\s+', '', lines[i])
            p.write_text('\n'.join(lines))
            print("Fixed", f)

fix_errors([])
