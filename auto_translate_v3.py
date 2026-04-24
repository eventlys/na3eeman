import os
import re
import json

app_dir = "lib"

translations = {
    "Completed": "مكتمل",
    "Branch Management": "إدارة الفروع",
    "Inventory Management": "إدارة المخزون",
    "Services & Prices": "الخدمات والأسعار",
    "Email Address": "البريد الإلكتروني",
    "Subject": "الموضوع",
    "No Subscriptions Available": "لا توجد اشتراكات متاحة",
    "Pending": "قيد الانتظار",
    "Generating report...": "جاري إنشاء التقرير...",
    "Low Stock Alerts": "تنبيهات نقص المخزون",
    "Quick Actions": "إجراءات سريعة",
    "Active Campaigns": "الحملات النشطة",
    "Tools & Inventory": "الأدوات والمخزون",
    "Validity Period:": "فترة الصلاحية:",
    "Ad Campaign launched!": "تم إطلاق الحملة الإعلانية!",
    "Assign Manager": "تعيين مدير",
    "Edit": "تعديل",
    "Working Hours": "ساعات العمل",
    "Low Stock Alert": "تنبيه انخفاض المخزون",
    "Role": "الصلاحية",
    "Barber": "حلاق",
    "Monthly": "شهرياً",
    "Add First Branch": "إضافة أول فرع",
    "Additional Services:": "خدمات إضافية:",
    "Add Item": "إضافة عنصر",
    "New Password": "كلمة مرور جديدة",
    "Confirm Password": "تأكيد كلمة المرور",
    "Issue Type": "نوع المشكلة",
    "App Feedback": "ملاحظات حول التطبيق",
    "Rating:": "التقييم:",
    "Today\\": "اليوم\\",
    "Report Issue": "الإبلاغ عن مشكلة",
    "Error Details": "تفاصيل الخطأ",
    "Stack Trace:": "تتبع المشكلة:",
    "Builder Error": "خطأ في البناء",
    "Oops! Something went wrong": "عفواً! حدث خطأ ما",
    "Log Out": "تسجيل الخروج",
    "God Mode": "وضع المطور",
    "Account": "الحساب",
    "Failed to load subscriptions": "فشل تحميل الاشتراكات",
    "There are no subscription plans available at the moment.": "لا تتوفر خطط اشتراك في الوقت الحالي.",
    "Subscribe to the Salon": "اشترك في المتجر",
    "Show More": "عرض المزيد",
    "Item restocked to 10 units": "تم إعادة تزويد العنصر إلى 10 وحدات",
    "Popular": "شائع",
    "Refresh": "تحديث",
    "Failed to Load Subscriptions": "فشل تحميل الاشتراكات",
    "No Favorites Yet": "لا توجد مفضلة بعد",
    "Items you add to your favorites will appear here": "العناصر التي تضيفها إلى المفضلة ستظهر هنا",
    "Browse Products": "تصفح المنتجات",
    "Download Report": "تنزيل التقرير",
    "File Format: PDF": "تنسيق الملف: PDF",
    "Report Details": "تفاصيل التقرير",
    "Download": "تنزيل",
    "Report Type": "نوع التقرير",
    "Time Period": "الفترة الزمنية",
    "File Name": "اسم الملف",
    "Enter file name": "أدخل اسم الملف",
    "Hello": "مرحباً",
    "Gold": "ذهبي",
    "Select Date": "اختر التاريخ",
    "Available Times": "الأوقات المتاحة",
    "Select a date first to see available times": "اختر التاريخ أولاً لرؤية الأوقات المتاحة",
    "Pending Confirmations": "تأكيدات معلقة",
    "Weekly Earnings Trend": "اتجاه الأرباح الأسبوعية",
    "No earnings data available": "لا تتوفر بيانات أرباح",
    "Upgrade to unlock": "قم بالترقية للفتح",
    "Upgrade Now": "الترقية الآن",
    "View Plans": "عرض الخطط",
    "Subscription": "اشتراك",
    "No features available": "لا توجد ميزات متاحة",
    "Unable to Load Subscription": "غير قادر على تحميل الاشتراك",
    "No Active Subscription": "لا يوجد اشتراك نشط",
    "RETRY": "إعادة المحاولة",
    "Connection Error": "خطأ في الاتصال",
    "Pull down to refresh": "اسحب للأسفل للتحديث",
    "Refresh failed!": "فشل التحديث!",
    "Release to refresh": "أفلت للتحديث",
    "Refresh completed": "اكتمل التحديث",
    "Pull up to load more": "اسحب للأعلى للتحميل أكثر",
    "Load failed!": "فشل التحميل!",
    "Release to load more": "أفلت للتحميل أكثر",
    "No more data": "لا توجد بيانات أخرى",
    "Delete Profile": "حذف الملف الشخصي",
    "Are you sure you want to delete your profile? This action cannot be undone.": "هل أنت متأكد أنك تريد حذف ملفك الشخصي؟ لا يمكن التراجع عن هذا الإجراء.",
    "Profile deleted": "تم حذف الملف الشخصي",
    "Choose an option": "اختر خياراً",
    "Already have an account? Log in": "لديك حساب بالفعل؟ سجل دخولك",
    "Welcome to Na3eeman": "مرحباً بك في نعيمًا",
    "Your premium barber booking experience.\\nBook, manage, and discover the best barbers near you.": "تجربتك المميزة في حجز الحلاقين.\\nاحجز وأدِر واكتشف أفضل الحلاقين بالقرب منك.",
    "Personalise Your Theme": "تخصيص المظهر الخاص بك",
    "We\\'ll tailor the app colours to your preference.": "سنقوم بتعديل ألوان التطبيق وفقاً لتفضيلاتك.",
    "Prefer not to say": "أفضل عدم القول",
    "How will you use Na3eeman?": "كيف ستستخدم نعيمًا؟",
    "Dev Account Switcher": "مبدل حسابات المطورين",
    "Retail Snapshot": "لمحة عن التجزئة",
    "Team Leaderboard": "لوحة صدارة الفريق",
    "Reorder Now": "إعادة الطلب الآن",
    "View Mode": "وضع العرض",
    "Unified P&L": "الأرباح والخسائر الموحدة",
    "Global Stock Value": "قيمة المخزون العالمية",
    "+8.3% vs last month": "+8.3% مقارنة بالشهر الماضي",
    "Branch Comparison": "مقارنة الفروع",
    "Inter-Branch Transfers": "التحويلات بين الفروع",
    "New Transfer": "تحويل جديد",
    "Commission Calculator": "حاسبة العمولات",
    "Resource Occupancy": "إشغال الموارد",
    "Compliance Tracker": "متتبع الامتثال",
    "Consumable Waste": "النفايات الاستهلاكية",
    "Upgrade Plan": "ترقية الخطة",
    "Kit Maintenance": "صيانة المعدات",
    "Quick Book": "حجز سريع",
    "Add a new appointment": "إضافة موعد جديد",
    "Now": "الآن",
    "Today\\'s Earnings": "أرباح اليوم",
    "Welcome back 👋": "مرحباً بعودتك 👋",
    "on your plan": "في خطتك",
    "Trial": "تجريبي",
    "Intern Activity": "نشاط المتدربين",
    "Assign Daily Tip": "تخصيص البقشيش اليومي",
    "Select Intern": "اختر المتدرب",
    "Optional Note": "ملاحظة اختيارية",
    "Subscription Details": "تفاصيل الاشتراك",
    "Plan Features": "ميزات الخطة",
    "Review Plan": "مراجعة الخطة",
    "Plan Confirmed Selection": "الخطة المختارة والمؤكدة",
    "Total Charges": "إجمالي الرسوم",
    "Payment Instructions": "تعليمات الدفع",
    "Please proceed with your primary linked account balance, or choose a backup credit card setup configured inside configuration panels to finalize invoice sync.": "يرجى المتابعة باستخدام رصيد حسابك الأساسي المرتبط، أو اختيار بطاقة ائتمان بديلة مهيأة في لوحات الإعدادات لإتمام مزامنة الفاتورة.",
    "Multi-Branch support setup required admin action approval configuration setup.": "إعداد دعم الفروع المتعددة يتطلب موافقة من الإدارة.",
    "Processing payment mock step...": "جاري معالجة الدفع التجريبي...",
    "Proceed to Pay": "المتابعة للدفع",
    "Admin alerted regarding multi-branch access...": "تم إشعار الإدارة بشأن وصول الفروع المتعددة...",
    "Contact Admin": "اتصل بالمسؤول",
    "Active Offers": "العروض النشطة",
    "No offers available at this moment": "لا توجد عروض متاحة في الوقت الحالي",
    "Products & Prices": "المنتجات والأسعار",
    "Showcase": "العرض",
    "Manage all your branches, view performance metrics, and handle branch-specific settings from this page.": "قم بإدارة جميع فروعك، واعرض مقاييس الأداء، وتعامل مع الإعدادات الخاصة بكل فرع من هذه الصفحة.",
    "Salon Details": "تفاصيل المتجر",
    "Location": "الموقع",
    "Phone": "الهاتف",
    "Employee Details": "تفاصيل الموظف",
    "Performance & Rating": "الأداء والتقييم",
    "Remove from Salon": "إزالة من المتجر",
    "Employee detached successfully.": "تم فصل الموظف بنجاح.",
    "Add Employee": "إضافة موظف",
    "Add": "إضافة",
    "Employee Management": "إدارة الموظفين"
}

en_json_path = "assets/Lang/en-US.json"
ar_json_path = "assets/Lang/ar-EG.json"

with open(en_json_path, 'r', encoding='utf-8') as f:
    en_json = json.load(f)
with open(ar_json_path, 'r', encoding='utf-8') as f:
    ar_json = json.load(f)

dictionary = {}
for eng, ar in translations.items():
    eng_clean = eng.replace('\\n', '\n').replace("\\'", "'")
    ar_clean = ar.replace('\\n', '\n').replace("\\'", "'")
    
    key = re.sub(r'[^a-zA-Z0-9_]', '_', eng_clean.strip().lower())
    key = re.sub(r'_+', '_', key).strip('_')[:50]
    dictionary[eng_clean] = {"key": key, "ar": ar_clean}

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

for root, _, files in os.walk(app_dir):
    for filename in files:
        if not filename.endswith(".dart"): continue
        path = os.path.join(root, filename)
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()

        changed = False
        for eng, data in dictionary.items():
            safe_eng = re.escape(eng).replace('\\\\\\n', '\\\\n').replace('\\\\\'', '\\\'')
            
            # Pattern 1: Regex targeting const Text('...')
            pattern1 = r"const\s+Text\s*\(\s*['\"]" + safe_eng + r"['\"]\s*"
            if re.search(pattern1, content):
                content = re.sub(pattern1, f"Text('{data['key']}'.tr()", content)
                changed = True

            # Pattern 2: Regex targeting Text('...', or Text("...")
            pattern2 = r"(?<!\.)Text\s*\(\s*['\"]" + safe_eng + r"['\"]\s*"
            if re.search(pattern2, content):
                content = re.sub(pattern2, f"Text('{data['key']}'.tr()", content)
                changed = True

            # Pattern 3: (title|labelText|hintText|content): '...'
            pattern3 = r"(title|labelText|hintText|content)\s*:\s*['\"]" + safe_eng + r"['\"]"
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
