import os
import re
import json

app_dir = "lib"

translations = {
  "Cancel": "إلغاء",
  "Profile": "الملف الشخصي",
  "Close": "إغلاق",
  "logout": "تسجيل الخروج",
  "Home": "الرئيسية",
  "completed": "مكتمل",
  "NA3EEMAN": "نعيمًا",
  "subject": "الموضوع",
  "Upgrade": "ترقية",
  "Staff Performance Report": "تقرير أداء الموظفين",
  "Are you sure you want to logout?": "هل أنت متأكد أنك تريد تسجيل الخروج؟",
  "Confirm Booking": "تأكيد الحجز",
  "Privacy Policy": "سياسة الخصوصية",
  "Security Policy": "سياسة الأمان",
  "Application Rules": "قواعد التطبيق",
  "Invite Friends": "دعوة الأصدقاء",
  "Contact Us": "اتصل بنا",
  "Report Shop": "الإبلاغ عن المشغل",
  "Report A Problem": "الإبلاغ عن مشكلة",
  "User Reports": "تقارير المستخدمين",
  "Book Appointment": "حجز موعد",
  "User Management": "إدارة المستخدمين",
  "Staff": "الموظفين",
  "Reports": "التقارير",
  "Bookings": "الحجوزات",
  "History": "السجل",
  "pending": "قيد الانتظار",
  "I\\": "أنا\\",
  "Cash": "نقدي",
  "barber": "حلاق",
  "Employee": "موظف",
  "Customer Feedback": "ملاحظات العملاء",
  "Retry": "إعادة المحاولة",
  "Back to Login": "العودة لتسجيل الدخول",
  "Admin": "مسؤول",
  "Verify OTP": "التحقق من رمز OTP",
  "Submit Report": "إرسال التقرير",
  "Confirm & Pay": "تأكيد ودفع",
  "Shop Name": "اسم المتجر",
  "Description": "الوصف",
  "This is a notification message mockup details.": "هذه تفاصيل رسالة إشعار تجريبية.",
  "2h ago": "منذ ساعتين",
  "notifications": "الإشعارات",
  "Upgrade Subscription": "ترقية الاشتراك",
  "Enterprise Plan": "خطة الشركات",
  "Premium Plan": "الخطة المميزة",
  "Debug Menu": "قائمة المطور",
  "DEBUG": "تصحيح",
  "Debug Banner": "شريط التصحيح",
  "Performance Overlay": "عرض الأداء",
  "Slow Animations": "الرسوم المتحركة البطيئة",
  "Debug Logging": "تسجيل التصحيح",
  "Profile updated successfully": "تم تحديث الملف الشخصي بنجاح",
  "Delete": "حذف",
  "Profile deleted successfully": "تم حذف الملف الشخصي بنجاح",
  "Choose from Gallery": "الاستعراض من المعرض",
  "Take a Photo": "التقاط صورة",
  "Select Language": "اختر اللغة",
  "English": "الإنجليزية",
  "Select Theme": "اختر المظهر",
  "Light Mode": "الوضع النهاري",
  "Dark Mode": "الوضع الليلي",
  "Summer Glow Package ☀️": "باقة الصيف المتوهجة ☀️",
  "Complete Bridal Glow 💅": "تجهيز العروس الكامل 💅",
  "Home Page": "الصفحة الرئيسية",
  "Home Page Content": "محتوى الصفحة الرئيسية",
  "Appointment Reminder": "تذكير بالموعد",
  "Pay Now": "ادفع الآن",
  "Awesome!": "رائع!",
  "your Feedback matters": "ملاحظاتك تهمنا",
  "Your Feedback Matters": "رأيك يهمنا",
  "Complete Payment": "إتمام الدفع",
  "Loyalty Points Earned!": "كسبت نقاط ولاء!",
  "test@example.com": "test@example.com",
  "Test123!": "Test123!",
  "Overview": "نظرة عامة",
  "Financial Reports": "التقارير المالية",
  "Analytics": "التحليلات",
  "Compliance": "الامتثال",
  "System Health": "صحة النظام",
  "My Shop": "متجري",
  "account": "الحساب",
  "Settings": "الإعدادات",
  "Subscription": "الاشتراك",
  "Report Issue": "الإبلاغ عن مشكلة",
  "Shops": "المتاجر",
  "Favourites": "المفضلة",
  "Email": "البريد الإلكتروني",
  "Book Now": "احجز الان",
  "Total": "الإجمالي",
  "Appointments": "المواعيد",
  "Average": "المتوسط",
  "Male": "ذكر",
  "Female": "أنثى",
  "Card": "بطاقة",
  "Quick Book": "حجز سريع",
  "Assign Tip": "تخصيص الإكرامية",
  "Upgrade Plan": "ترقية الخطة",
  "location": "الموقع",
  "phone": "الهاتف",
  "Name": "الاسم",
  "John Doe": "محمد أحمد",
  "role": "الدور",
  "Financial Performance": "الأداء المالي",
  "Shop Branches": "فروع المتجر",
  "No Branches Available": "لا توجد فروع متاحة",
  "Add your first branch to get started": "أضف فرعك الأول للبدء",
  "Delete Item": "حذف العنصر",
  "Inventory management is only available for owners": "إدارة المخزون متاحة فقط لأصحاب المتاجر",
  "Initializing shop details...": "جاري تهيئة تفاصيل المتجر...",
  "Failed to load inventory": "فشل في تحميل المخزون",
  "No items in inventory": "لا توجد عناصر في المخزون",
  "Unable to load services. Please try again.": "غير قادر على تحميل الخدمات. يرجى المحاولة مرة أخرى.",
  "No services available": "لا توجد خدمات متاحة",
  "Manage Inventory": "إدارة المخزون",
  "Customer Reviews": "آراء العملاء",
  "Add Your Review": "أضف تقييمك",
  "Submit Review": "إرسال التقييم",
  "Write your review here...": "اكتب تقييمك هنا...",
  "Our Barbers": "حلاقونا",
  "Could not launch maps": "تعذر فتح الخرائط",
  "Add Additional Services": "إضافة خدمات إضافية",
  "Service Details": "تفاصيل الخدمة",
  "Main Service": "الخدمة الأساسية",
  "Total Duration:": "المدة الإجمالية:",
  "Total Price:": "السعر الإجمالي:",
  "Add More Services": "إضافة المزيد من الخدمات",
  "No Service Selected": "لم يتم تحديد أي خدمة",
  "Please select a main service to continue": "يرجى تحديد خدمة أساسية للمتابعة",
  "Add New Item": "إضافة عنصر جديد",
  "Item Name": "اسم العنصر",
  "Initial Count": "الرصيد الافتتاحي",
  "Description (Optional)": "الوصف (اختياري)",
  "Added to Favorites": "تمت الإضافة للمفضلة",
  "Share Dialog Opened": "تم فتح نافذة المشاركة",
  "Catigories": "خدماتنا",
  "Packages": "الباقات",
  "Packages and bundles coming soon!": "الباقات والعروض قريباً!",
  "Products": "المنتجات",
  "Shop products catalog coming soon!": "تشكيلة منتجات المتجر قريباً!",
  "Offers & Groups": "العروض والمجموعات",
  "Exclusive offers coming soon!": "عروض حصرية قريباً!",
  "Shop Feedback": "آراء المتجر",
  "4.8 / 5": "4.8 / 5",
  "(120 reviews)": "(120 تقييم)",
  "Ahmed M.": "أحمد م.",
  "Great service! Completely transformed my look. Highly recommended!": "خدمة ممتازة! غيّر مظهري تمامًا. أنصح به بشدة!",
  "Feedback Entry Dialog": "نافذة إدخال التعليقات",
  "Add your feedback": "أضف تعليقك",
  "About This Offer": "حوال هذا العرض",
  "Included Services": "الخدمات المشمولة",
  "Book This Offer": "احجز هذا العرض",
  "Select Date & Time": "اختر التاريخ والوقت",
  "Available Slots": "المواعيد المتاحة",
  "Booking request sent successfully!": "تم إرسال طلب الحجز بنجاح!",
  "Schedule Type": "نوع الجدول",
  "Please select both date and time": "يرجى تحديد التاريخ والوقت",
  "Confirm Schedule": "تأكيد الجدول",
  "Selected Services": "الخدمات المحددة",
  "Add More Services:": "إضافة المزيد من الخدمات:",
  "One Time Only": "مرة واحدة فقط",
  "Schedule this appointment once": "جدولة هذا الموعد مرة واحدة",
  "Bi-Weekly": "كل أسبوعين",
  "Repeat every 2 weeks": "تكرار كل أسبوعين",
  "monthly": "شهرياً",
  "Repeat every month": "كرر كل شهر",
  "Book a haircut": "احجز حلاقة",
  "Owner Dashboard": "لوحة المالك",
  "New Action": "إجراء جديد",
  "No reviews found.": "لا توجد تقييمات.",
  "Feedback Reviews": "مراجعات التعليقات",
  "You do not have permission to add branches": "ليس لديك إذن لإضافة فروع",
  "Add new branch functionality - Coming soon": "إضافة ميزة فروع جديدة - قريباً",
  "You do not have permission to assign managers": "ليس لديك إذن لتعيين المديرين",
  "Assign": "تعيين",
  "Branches": "الفروع",
  "Failed to load branches": "فشل في تحميل الفروع",
  "No branches found": "لم يتم العثور على فروع",
  "Loading branches...": "جاري تحميل الفروع...",
  "Discover Shops": "اكتشف المتاجر",
  "No shops found nearby": "لم يتم العثور على متاجر قريبة",
  "Search by name or location...": "البحث بالاسم أو الموقع...",
  "Password changed successfully": "تم تغيير كلمة المرور بنجاح",
  "Current Password": "كلمة المرور الحالية",
  "Confirm New Password": "تأكيد كلمة المرور الجديدة",
  "Check your spam or junk folder if you don\'t see the email.": "تحقق من مجلد الرسائل غير المرغوب فيها إذا لم ترَ البريد الإلكتروني.",
  "Enter your email address and we'll send you a One-Time Password (OTP) to reset your password.": "أدخل عنوان بريدك الإلكتروني وسنرسل لك رمز OTP لإعادة تعيين كلمة المرور.",
  "email": "البريد الإلكتروني",
  "Send OTP": "إرسال الرمز",
  "Professional Grooming Services": "خدمات العناية الشخصية الاحترافية",
  "Remember me": "تذكرني",
  "OR": "أو",
  "Don't have an account?": "ليس لديك حساب؟",
  "Quick Access (Fast Login)": "دخول سريع",
  "Fast Login as": "دخول سريع كـ",
  "Mock Owner Variants (Local State)": "خيارات تجريبية للمالك"
}

en_json_path = "assets/Lang/en-US.json"
ar_json_path = "assets/Lang/ar-EG.json"

with open(en_json_path, 'r', encoding='utf-8') as f:
    en_json = json.load(f)
with open(ar_json_path, 'r', encoding='utf-8') as f:
    ar_json = json.load(f)

dictionary = {}
for eng, ar in translations.items():
    eng_clean = eng.replace('\\n', '\n').replace('\\`', '`').replace("\\'", "'")
    ar_clean = ar.replace('\\n', '\n').replace('\\`', '`').replace("\\'", "'")
    
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

            # Pattern 2: Regex targeting Text('... or Text("...
            pattern2 = r"(?<!\.)Text\s*\(\s*['\"]" + safe_eng + r"['\"]\s*"
            if re.search(pattern2, content):
                content = re.sub(pattern2, f"Text('{data['key']}'.tr()", content)
                changed = True

            # Pattern 3: (title|labelText|hintText|content|text|label|message): '...'
            pattern3 = r"(title|labelText|hintText|content|text|label|message)\s*:\s*['\"]" + safe_eng + r"['\"]"
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
