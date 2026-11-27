# رفع IELTS Master إلى GitHub

هذه نسخة مستقلة من أحدث ملفات المشروع الموجودة وقت التجهيز. المشروع الأصلي لم يتغير، ولم يتم رفع هذه النسخة إلى الإنترنت.

## الطريقة الأسهل: GitHub Desktop

1. أنشئ مستودعًا جديدًا باسم `IELTSMaster` في GitHub Desktop، داخل مجلد فارغ آخر، واختر عدم إنشاء README أو ترخيص تلقائي.
2. انسخ جميع محتويات هذا المجلد إلى مجلد المستودع الجديد، بما فيها `.gitignore`. لإظهار الملفات المخفية في Finder اضغط Command + Shift + نقطة.
3. راجع الملفات في GitHub Desktop ثم احفظ أول Commit برسالة `Initial project release`.
4. اضغط Publish repository واختر Public أو Private، ثم أكد النشر.

## باستخدام Terminal

افتح Terminal داخل هذا المجلد، ثم نفذ:

```bash
git init -b main
git add .
git status --short
git commit -m "Initial project release"
```

أنشئ مستودعًا فارغًا في حسابك على GitHub، دون README أو ترخيص أو gitignore. بعد ذلك نفذ الأوامر التالية، مع استبدال YOUR_USERNAME باسم حسابك:

```bash
git remote add origin https://github.com/YOUR_USERNAME/IELTSMaster.git
git push -u origin main
```

## وصف مقترح للمستودع

IELTS Academic preparation platform with a native macOS app, React web interface, bilingual support, mock exams, progress tracking, and AI-assisted learning.

## مواضيع مقترحة

`ielts`, `swift`, `swiftui`, `react`, `education`, `language-learning`, `macos`, `ollama`

## محتويات النسخة

- ملفات المصدر الحالية، بما فيها التغييرات التي لم تحفظ بعد في Git الخاص بالمشروع الأصلي.
- README جديد لتشغيل تطبيق Mac ونسخة الويب.
- ملف .gitignore يستبعد بيانات المستخدمين والأسرار وملفات البناء.
- لا تتضمن سجل Git القديم أو الحسابات أو قواعد البيانات أو الحزم القديمة.
- لم تتم إضافة ترخيص تلقائي؛ اختر الترخيص المناسب إذا أردت السماح للآخرين بإعادة استخدام الكود.

ملف ZIP المرافق نسخة للتحميل أو المشاركة. عند الرفع اليدوي إلى GitHub، فك ضغطه وارفع محتوياته، ولا ترفع ملف ZIP بوصفه بديلًا عن ملفات المصدر.
