import os
import re
import json

app_dir = "lib"

translations = {
    "Email": "البريد الإلكتروني",
    "Password": "كلمة المرور",
    "Login": "تسجيل الدخول",
    "Sign Up": "إنشاء حساب",
    "Sign up": "إنشاء حساب",
    "Full Name": "الاسم الكامل",
    "Phone Number": "رقم الهاتف",
    "Forgot Password?": "هل نسيت كلمة المرور؟",
    "Forgot password?": "هل نسيت كلمة المرور؟",
    "Welcome Back!": "مرحباً بعودتك!",
    "Welcome back!": "مرحباً بعودتك!",
    "Sign in to continue": "تسجيل الدخول للمتابعة",
    "Sign In": "تسجيل الدخول",
    "Create an Account": "إنشاء حساب جديد",
    "Male": "ذكر",
    "Female": "أنثى",
    "Gender": "الجنس",
    "Email is required": "البريد الإلكتروني مطلوب",
    "Password is required": "كلمة المرور مطلوبة",
    "Error": "خطأ",
    "Success": "نجاح",
    "OK": "حسناً",
    "Yes": "نعم",
    "No": "لا",
    "Search": "بحث",
    "Search...": "ابحث...",
    "Done": "تم",
    "Next": "التالي",
    "Back": "رجوع",
    "Save": "حفظ",
    "Update": "تحديث",
    "Continue": "استمرار",
    "Appointments": "المواعيد",
    "Favorites": "المفضلة",
    "Home": "الرئيسية",
    "Profile": "الملف الشخصي",
    "Notifications": "الإشعارات",
    "Messages": "الرسائل",
    "Logout": "تسجيل الخروج",
    "Settings": "الإعدادات",
    "Date": "التاريخ",
    "Time": "الوقت",
    "Price": "السعر",
    "Status": "الحالة",
    "Available": "متاح",
    "Busy": "مشغول",
    "Book Now": "احجز الان",
    "Booking": "حجز",
    "Select": "اختر",
    "Selected": "تم الاختيار",
    "Submit": "إرسال",
    "Total": "الإجمالي",
    "Dashboard": "لوحة التحكم",
    "Receptionist Desk": "مكتب الاستقبال",
    "Staff Actions": "إجراءات الموظفين",
    "Pending Payments": "مدفوعات قيد الانتظار",
    "Shop Management": "إدارة المتجر",
    "Support": "الدعم",
    "Active": "نشط",
    "Inactive": "غير نشط",
    "Loading...": "جاري التحميل...",
    "No data found": "لا توجد بيانات",
    "Please wait...": "يرجى الانتظار...",
    "Payment successful": "تم الدفع بنجاح",
    "Payment failed": "فشل الدفع",
    "Welcome": "مرحباً",
    "Don't have an account? Sign up": "ليس لديك حساب؟ أنشئ حساب",
    "Already have an account? Login": "لديك حساب بالفعل؟ سجل دخول",
    "Logout Page - Coming Soon": "صفحة تسجيل الخروج - قريباً",
    "System Alerts": "تنبيهات النظام",
}

# Update JSON files
en_json_path = "assets/Lang/en-US.json"
ar_json_path = "assets/Lang/ar-EG.json"

with open(en_json_path, 'r', encoding='utf-8') as f:
    en_json = json.load(f)
with open(ar_json_path, 'r', encoding='utf-8') as f:
    ar_json = json.load(f)

# Auto generate snake_case keys for dictionary
dictionary = {}
for eng, ar in translations.items():
    key = re.sub(r'[^a-zA-Z0-9_]', '_', eng.strip().lower())
    key = re.sub(r'_+', '_', key).strip('_')
    dictionary[eng] = {"key": key, "ar": ar}

for english, data in dictionary.items():
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
        for eng, data in dictionary.items():
            pattern1 = rf"const\s+Text\s*\(\s*['\"]{re.escape(eng)}['\"]"
            if re.search(pattern1, content):
                content = re.sub(pattern1, f"Text('{data['key']}'.tr()", content)
                changed = True

            pattern2 = rf"(?<!\.)Text\s*\(\s*['\"]{re.escape(eng)}['\"]"
            if re.search(pattern2, content):
                content = re.sub(pattern2, f"Text('{data['key']}'.tr()", content)
                changed = True
                
            # Pattern for labels in TextFields, AppBars etc that are raw strings
            # Wait, replacing raw strings outside of Text() is risky, could break keys or paths.
            # I will only safely match title: '...', labelText: '...', hintText: '...'
            pattern3 = rf"(title|labelText|hintText)\s*:\s*['\"]{re.escape(eng)}['\"]"
            if re.search(pattern3, content):
                content = re.sub(pattern3, rf"\1: '{data['key']}'.tr()", content)
                changed = True

        if changed:
            if import_statement not in content:
                lines = content.split('\n')
                last_import = 0
                for i, l in enumerate(lines):
                    if l.startswith("import "): last_import = i
                lines.insert(last_import + 1, import_statement)
                content = '\n'.join(lines)
            
            with open(path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Updated {path}")
