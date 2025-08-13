# קבוצת הדיווחים של אסף ארמה — תבנית Flutter (עברית)

תבנית מוכנה לאפליקציית דיווחים + פוש לפי קטגוריות, עם CI/CD להעלאה לחנויות (מוכנים להפעלה לאחר הוספת מפתחות).

## מה בקבצים כאן
- `lib/main.dart` — אפליקציית דמו מלאה (RTL), מסכי משתמש + מנהל (דמו).
- `assets/logo.png` — הלוגו שסיפקת, ישמש לאייקון ולספלאש.
- `pubspec.yaml` — תלויות (כולל firebase_*), וקומפוננטים ל-icons ול-splash.
- `.github/workflows` — צנרת CI לבניית APK/IPA ולהעלאה לחנויות (לאחר הגדרת מפתחות).
- `android_fastlane` / `ios_fastlane` — קבצי Fastlane לדוגמה.

> הערה: אין כאן תיקיות `android/` ו-`ios/` מלאות. מומלץ ליצור פרויקט Flutter חדש ולהעתיק את התוכן של תבנית זו פנימה (הסבר בהמשך).

## יצירת פרויקט Flutter מקומי
1. התקן Flutter (אם אין): https://docs.flutter.dev/get-started/install
2. צור פרויקט חדש:
   ```bash
   flutter create assaf_arma_reports
   cd assaf_arma_reports
   ```
3. העתק את התוכן של תבנית זו אל תוך הפרויקט שיצרת **על גבי** הקבצים (החלפה):
   - העתק `lib/`, `assets/`, `pubspec.yaml`, `.github/`, `android_fastlane/`, `ios_fastlane/` לשורש הפרויקט.
4. התקן תלויות:
   ```bash
   flutter pub get
   ```
5. הפקת אייקונים וספלאש (לא חובה עכשיו):
   ```bash
   flutter pub run flutter_launcher_icons
   dart run flutter_native_splash:create
   ```

## הרצת דמו מקומי
```bash
flutter run
```
> ברירת המחדל: ללא Firebase (המשתנה `kUseFirebase=false`). אפשר לבדוק UI ולהוסיף "דיווח דמו" מה-FAB.

## חיבור Firebase + Push
1. צור פרויקט Firebase והוסף אפליקציה Android ו-iOS.
2. הורד את:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
3. הוסף את הקבצים במסלולים המתאימים בפרויקט.
4. הפוך את `kUseFirebase` ל-`true` בקובץ `lib/main.dart` והרחב לוגיקה לפי צורך.
5. (אופציונלי) הירשם ל-topics לפי קטגוריה במכשיר:
   ```dart
   // אחרי קבלת ההרשאות לפוש:
   // await FirebaseMessaging.instance.subscribeToTopic("traffic");
   ```
   שבהתאם לקטגוריות שלך (עברית), מומלץ להשתמש במפתחי topic באנגלית (למשל `traffic`, `crime`, וכו').

## Backend לשליחה לפי קטגוריות
- אופציה מהירה: Cloud Functions ב-Node.js שמקבל קריאת REST מהאפליקציה עם `category`, ושולח התראה ל-`/topics/<category_key>`.
- אלטרנטיבות: שרת קטן ב-Firestore + Cloud Functions, או שרת משלך (Node/Express).

## Bundle ID / Package Name
- אנדרואיד: `applicationId` — `com.assafarma.reports`
- iOS: `PRODUCT_BUNDLE_IDENTIFIER` — `com.assafarma.reports`

עדכן לפי הצורך בקבצי הפרויקט (Android/iOS) לאחר `flutter create`:
- Android: `android/app/build.gradle` (`applicationId`)
- iOS: `ios/Runner.xcodeproj` או דרך Xcode (General → Bundle Identifier)

## אדמין דמו
- אימייל: `admin@assafarma.local`
- סיסמה: `Admin1234!`

## בניית APK לבדיקה
```bash
flutter build apk --debug
# או:
flutter build apk --release
```
קובץ ה-APK יופק תחת `build/app/outputs/flutter-apk/`.

## פתיחת חשבונות מפתחים (נדרש להעלאה לחנויות)
- Google Play: תשלום חד פעמי $25.
- Apple Developer: תשלום שנתי $99.
לאחר פתיחת החשבונות נוכל להגדיר העלאה אוטומטית.

## CI/CD עם GitHub Actions + Fastlane
1. פתח ריפו חדש ב-GitHub והעלה את קבצי הפרויקט.
2. תחת **Settings → Secrets and variables → Actions → New repository secret** הוסף:
   - `GOOGLE_PLAY_JSON` — תוכן קובץ service account JSON בקידוד base64 (ראה למטה).
   - `ANDROID_KEYSTORE_BASE64` — keystore בקידוד base64 (ל-Release).
   - `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`.
   - `APP_STORE_CONNECT_API_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`, `APP_STORE_CONNECT_PRIVATE_KEY` (base64 של קובץ p8).
3. ה-workflows שבקובץ `.github/workflows` יבנו APK/IPA ועל פי דחיפה ל-tag `v*.*.*` יבצעו גם upload (לאחר הגדרת המפתחות).

### המרת קבצים ל-base64 (להדבקה ב-Secrets)
```bash
base64 -w 0 google-play-service-account.json > google.json.b64
base64 -w 0 keystore.jks > keystore.jks.b64
base64 -w 0 AuthKey_XXXX.p8 > apple_key.p8.b64
```

## הערות
- תבנית זו מינימלית ומוכנה להרחבה. מומלץ להוסיף שכבת נתונים (Firestore) וניהול הרשאות אמיתי למנהלים.
- פוש לא יעבוד בלי Firebase וקבצי קונפיגורציה כנדרש.

## בניית APK בלי להגדיר כלום מקומית (GitHub Actions)
1. פתח ריפו חדש ב-GitHub (Private/Public).
2. העלה את כל הקבצים מהתיקייה הזו (כולל `.github/workflows`).
3. עבור ל-**Actions** → רץ workflow בשם **Android CI** אוטומטית.
4. בסיום, תחת ה-run, לחץ על **Artifacts** והורד את `app-debug-apk` — בפנים תמצא את ה-APK לבדיקה.

## בניית APK ב-Windows (PowerShell)
1. התקן Android Studio (כלול SDK + Platform Tools) ו-Flutter.
2. פתח PowerShell בתיקיית הפרויקט והרץ:
   ```powershell
   flutter pub get
   flutter build apk --debug
   ```
3. ה-APK יופק בנתיב: `build\app\outputs\flutter-apk\app-debug.apk`.
4. העבר למכשיר והתקן (אפשר דרך WhatsApp/Drive/USB).