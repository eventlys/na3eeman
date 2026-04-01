import os
import re
import json

app_dir = "lib/Packages"
en_json_path = "assets/Lang/en-US.json"
ar_json_path = "assets/Lang/ar-EG.json"

translations = {
    "Cancel": {"ar": "إلغاء", "key": "cancel"},
    "Try Again": {"ar": "حاول مرة أخرى", "key": "try_again"},
    "Confirm": {"ar": "تأكيد", "key": "confirm"},
    "Close": {"ar": "إغلاق", "key": "close"},
    "Create": {"ar": "إنشاء", "key": "create"},
    "Change Profile Picture": {"ar": "تغيير صورة الملف الشخصي", "key": "change_profile_picture"},
    "View All": {"ar": "عرض الكل", "key": "view_all"},
    "See All": {"ar": "عرض الكل", "key": "see_all"},
    "System Health": {"ar": "حالة النظام", "key": "system_health_title"}, # Avoid conflict with system_health
    "Send Feedback": {"ar": "إرسال تعليقات", "key": "send_feedback"},
    "Retry": {"ar": "إعادة المحاولة", "key": "retry"},
    "Delete": {"ar": "حذف", "key": "delete"},
    "Gallery": {"ar": "معرض الصور", "key": "gallery"},
    "Camera": {"ar": "الكاميرا", "key": "camera"},
    "Redeem": {"ar": "استبدال", "key": "redeem"},
    "History": {"ar": "السجل", "key": "history"},
    "Complete Payment": {"ar": "إتمام الدفع", "key": "complete_payment"},
    "Change Password": {"ar": "تغيير كلمة المرور", "key": "change_password"},
    "Report generated successfully!": {"ar": "تم إنشاء التقرير بنجاح!", "key": "report_success"},
    "Offer created successfully!": {"ar": "تم إنشاء العرض بنجاح!", "key": "offer_success"},
    "Manage Shop Profile": {"ar": "إدارة ملف المتجر", "key": "manage_shop"},
    "Launch": {"ar": "إطلاق", "key": "launch"},
    "Include Options:": {"ar": "تضمين الخيارات:", "key": "include_options"},
    "Create Promotion": {"ar": "إنشاء ترويج", "key": "create_promotion"},
    "Create New Offer": {"ar": "إنشاء عرض جديد", "key": "create_offer"},
    "Create Ad Campaign": {"ar": "إنشاء حملة إعلانية", "key": "create_ad"},
    "Explore Shops": {"ar": "استكشف المتاجر", "key": "explore_shops"},
    "Book Appointment": {"ar": "حجز موعد", "key": "book_appointment"},
    "Subscription Plans": {"ar": "خطط الاشتراك", "key": "subscription_plans"},
    "Select Plan": {"ar": "اختر الخطة", "key": "select_plan"},
    "RECOMMENDED": {"ar": "موصى به", "key": "recommended"},
    "Appointment History": {"ar": "سجل المواعيد", "key": "appointment_history"},
    "Report Options": {"ar": "خيارات التقرير", "key": "report_options"},
    "Generate": {"ar": "توليد", "key": "generate"},
    "Share": {"ar": "مشاركة", "key": "share"},
    "Report a Problem": {"ar": "الإبلاغ عن مشكلة", "key": "report_problem"},
    "Bug Report": {"ar": "الإبلاغ عن خطأ", "key": "bug_report"},
    "Usage Abuse": {"ar": "إساءة الاستخدام", "key": "usage_abuse"},
    "Feature Request": {"ar": "طلب ميزة", "key": "feature_request"},
    "Other": {"ar": "أخرى", "key": "other"}
}

# Update JSON
with open(en_json_path, 'r', encoding='utf-8') as f:
    en_json = json.load(f)
with open(ar_json_path, 'r', encoding='utf-8') as f:
    ar_json = json.load(f)

for english, data in translations.items():
    if data['key'] not in en_json:
        en_json[data['key']] = english
    if data['key'] not in ar_json:
        ar_json[data['key']] = data['ar']

with open(en_json_path, 'w', encoding='utf-8') as f:
    json.dump(en_json, f, ensure_ascii=False, indent=2)
with open(ar_json_path, 'w', encoding='utf-8') as f:
    json.dump(ar_json, f, ensure_ascii=False, indent=2)

print("JSON updated.")

import_statement = "import 'package:easy_localization/easy_localization.dart';"

# Update Dart files
for root, _, files in os.walk(app_dir):
    for filename in files:
        if not filename.endswith(".dart"): continue
        path = os.path.join(root, filename)
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()

        changed = False
        for eng, data in translations.items():
            # Replace `const Text('ENG'` to `Text('key'.tr()`
            pattern1 = rf"const\s+Text\s*\(\s*['\"]{re.escape(eng)}['\"]"
            if re.search(pattern1, content):
                content = re.sub(pattern1, f"Text('{data['key']}'.tr()", content)
                changed = True

            # Replace `Text('ENG'` to `Text('key'.tr()`
            pattern2 = rf"(?<!\.)Text\s*\(\s*['\"]{re.escape(eng)}['\"]"
            if re.search(pattern2, content):
                content = re.sub(pattern2, f"Text('{data['key']}'.tr()", content)
                changed = True

        if changed:
            if import_statement not in content:
                # Add import after other imports
                lines = content.split('\n')
                last_import = 0
                for i, l in enumerate(lines):
                    if l.startswith("import "): last_import = i
                lines.insert(last_import + 1, import_statement)
                content = '\n'.join(lines)
            
            with open(path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Updated {path}")

