# تطبيق BuyTech المكتمل للهواتف الذكية (Flutter Mobile App) 📱

تطبيق الهاتف المحمول الرسمي لشركة **BuyTech**، مبني بالكامل باستخدام **Flutter & Material 3** وبتصميم مستوحى 100% من لغة التصميم العالمية **Blinq** مع دعم أصلي كامل للغة العربية والاتجاه من اليمين إلى اليسار (RTL) وخط Cairo الرسمي.

---

## 🌟 الميزات الجوهرية للتطبيق

### 1. 📇 إدارة البطاقات الذكية (Smart Cards Hub)
* عرض بطاقات فريق العمل مع شريط إحصائي تفاعلي (المشاهدات، حفظ الرقم vCard، العملاء المكتسبين).
* تفعيل وتعطيل البطاقة مباشرة بزر Switch تفاعلي مع الخادم السحابي.
* معاينة حية لشكل البطاقة العامة مع إمكانية التبديل بين وضعين:
  - **🏪 معرض وتجزئة (Retail)**
  - **🏢 جملة وشركات (B2B)**
* توليد ومشاركة رموز QR بدقة متجهة (Vector QR) وحفظها في الحافظة أو مشاركتها عبر النظام.

### 2. ⚡ برمجة شرائح NFC مباشرة من التطبيق (Native In-App NFC Writer)
* برمجة وكتابة شريحة البطاقة الذكية (NTAG213 / NTAG215 / NTAG216) مباشرة عبر لمس الهاتف بالبطاقة دون الحاجة لأي تطبيقات وسيطة مثل NFC Tools.
* دعم قياسي لمعيار NDEF URI Record مع فحص تلقائي لتوافق الشريحة وقابليتها للكتابة.
* واجهة رسومية نبضية (Pulse Animation) مع مؤثرات صوتية واهتزاز haptic feedback.

### 3. 🤝 إدارة ومتابعة العملاء المكتسبين (Leads CRM)
* استقبال وتحديث جهات اتصال العملاء الذين قاموا بملء نموذج التواصل فور مسح البطاقة.
* بحث فوري وفلترة بحسب البطاقة، الاسم، الشركة، الهاتف، أو البريد.
* إجراء مكالمة هاتفية فورية بنقرة واحدة (`tel:`).
* محادثة فورية ومباشرة عبر واتساب برسالة ترحيبية احترافية مخصصة (`wa.me`).
* تصدير ومشاركة بيانات العميل.

### 4. 🛒 كتالوج المنتجات وعروض الأسعار السريعة (Quote Cart via WhatsApp)
* استعراض قائمة أجهزة نقاط البيع POS، طابعات الفواتير، قارئات الباركود، والموازين الإلكترونية.
* إضافة المنتجات وتعديل الكميات في سلة تسعيرة عائمة.
* تصدير عرض سعر رسمي متكامل ومنسق بضغطة زر وإرساله مباشرة لعميلك عبر واتساب.

### 5. 🛡️ التوثيق والمزامنة السحابية الحية (Live Cloud Sync)
* متصل ومربوط مباشرة بنظام BuyTech السحابي الموحد عبر REST API:
  `https://op-system.buytech.app/api`
* مصادقة سريعة وآمنة للغاية بنظام Bearer Token المشفّر محلياً في `SharedPreferences`.

---

## 🏗️ هيكلية المشروع (Architecture)

```text
buytech_flutter/
├── android/                   # إعدادات Android الأصلية وتصاريح NFC والكاميرا
├── ios/                       # إعدادات iOS والأذونات الرسمية لـ Apple NFC
├── assets/                    # الخطوط والصور والشعارات
└── lib/
    ├── core/
    │   ├── constants/         # الروابط ونقاط النهاية (ApiConstants)
    │   └── theme/             # ألوان وهوية BuyTech وخط Cairo (AppTheme, AppColors)
    ├── data/
    │   ├── models/            # نماذج البيانات (SmartCard, Lead, Product, User)
    │   └── services/          # خدمات الشبكة والعتاد (ApiService, NfcService, StorageService)
    ├── ui/
    │   ├── auth/              # شاشة تسجيل الدخول (LoginScreen)
    │   ├── dashboard/         # الحاوية الرئيسية للتنقل السفلي (DashboardScreen)
    │   ├── smart_cards/       # شاشات البطاقات والمعاينة وNFC وQR
    │   ├── leads/             # شاشة إدارة العملاء المكتسبين (LeadsCrmScreen)
    │   ├── products/          # شاشات كتالوج المنتجات وسلة عروض الأسعار
    │   └── profile/           # الملف الشخصي وإعدادات النظام والسيرفر
    └── main.dart              # نقطة الانطلاق وإعدادات RTL واللغة العربية
```

---

## 🚀 كيفية تشغيل وبناء التطبيق

### 1. تثبيت الحزم:
```bash
flutter pub get
```

### 2. تشغيل التطبيق في وضع التطوير (Debug):
```bash
# على محاكي أو هاتف أندرويد متصل:
flutter run

# على جهاز آيفون أو Mac:
flutter run -d iOS
```

### 3. بناء النسخة الإنتاجية النهائية (Release APK / AAB / IPA):
```bash
# بناء ملف APK لتثبيته مباشرة على أي هاتف أندرويد:
flutter build apk --release

# بناء حزمة متجر Google Play:
flutter build appbundle --release

# بناء حزمة نظام iOS:
flutter build ipa --release
```

---

## 🔒 الصلاحيات المضمنة في النظام (Native Permissions)

* **Android (`AndroidManifest.xml`):**
  - `android.permission.NFC`
  - `android.permission.INTERNET`
  - `android.permission.CAMERA`
* **iOS (`Info.plist`):**
  - `NFCReaderUsageDescription`
  - `NSCameraUsageDescription`
  - `com.apple.developer.nfc.readersession.iso7816.select-identifiers`
