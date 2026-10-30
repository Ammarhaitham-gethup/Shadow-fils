SHADOW FILES — ONLINE MVP
=========================
المحتويات:
- index.html: نسخة اللعبة مع إضافة ربط أونلاين.
- online.js: تسجيل الحسابات، إنشاء/الانضمام لغرف، مزامنة حالة القضية.
- supabase_setup.sql: جداول وسياسات قاعدة البيانات.

خطوات التشغيل:
1) افتح Supabase Dashboard > SQL Editor > New query.
2) الصق محتوى supabase_setup.sql واضغط Run.
3) من Authentication > Providers > Email، فعّل Email provider.
4) للتجربة السريعة: من Authentication > URL Configuration أضف رابط GitHub Pages ضمن Site URL و Redirect URLs.
5) ارفع index.html و online.js إلى جذر مستودع GitHub Pages واستبدل index.html القديم. احتفظ بباقي الملفات مثل cipher.html و manifest.webmanifest و icon.svg و sw.js.
6) افتح الموقع. أنشئ حسابًا بالبريد وكلمة مرور. قد تحتاج تأكيد البريد من رسالة تصل إليك.
7) أنشئ غرفة، وانسخ الرمز، وأرسله لأصدقائك. كل لاعب ينشئ حسابًا ثم ينضم بالرمز.

ملاحظات:
- Publishable key موجود داخل online.js وهو مفتاح عام مخصص للمتصفح. لا تضع Secret/service_role key في الموقع.
- هذه نسخة أولية للتعاون في القضية الحالية: تقدم التحقيق المشترك وملاحظات الحالة تُزامن بين أعضاء الغرفة. ليست بعد نظام أدوار سرية منفصلة أو دردشة صوتية.
- لم يتم اختبار الاتصال بمشروع Supabase من داخل هذه البيئة. يجب تشغيل SQL أولًا ثم تجربة حسابين على جهازين.
