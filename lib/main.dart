import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Firebase - כבוי כברירת מחדל עד הוספת קבצי קונפיגורציה
bool kUseFirebase = false;
Future<void> maybeInitFirebase() async {
  if (!kUseFirebase) return;
  try {
    // Defer import to avoid crashing if packages not configured
    // ignore: unused_local_variable
    final core = await Future.microtask(() => null);
  } catch (_) {}
}

const appDisplayName = "קבוצת הדיווחים של אסף ארמה";
const adminEmailSeed = "admin@assafarma.local";
const adminPasswordSeed = "Admin1234!";
const categories = <String>[
  "חדשות כלליות",
  "פיגועים ואירועי ביטחון",
  "שריפות ואירועי חירום",
  "מזג אוויר קיצוני",
  "תאונות דרכים",
  "עומסי תנועה וחסימות",
  "חדשות כלכלה",
  "חדשות ספורט",
  "חדשות בידור ותרבות",
  "חדשות טכנולוגיה",
  "חדשות בריאות",
  "חדשות חינוך",
  "חדשות מהעולם",
  "חדשות מקומיות"
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await maybeInitFirebase();
  runApp(const AssafReportsApp());
}

class AssafReportsApp extends StatelessWidget {
  const AssafReportsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appDisplayName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LandingScreen(),
    );
  }
}

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text(appDisplayName)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const UserHomeScreen()));
                },
                icon: const Icon(Icons.list),
                label: const Text("לצפייה בדיווחים"),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen()));
                },
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text("כניסת מנהלים"),
              ),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Image.asset('assets/logo.png', width: 120, height: 120),
                    const SizedBox(height: 8),
                    const Text("גרסת דמו - ללא שרת/פיירבייס", style: TextStyle(fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ===== משתמשים =====
class Report {
  final String title;
  final String body;
  final String category;
  final DateTime createdAt;
  Report({required this.title, required this.body, required this.category, DateTime? createdAt})
      : createdAt = createdAt ?? DateTime.now();
}

class ReportsStore extends ChangeNotifier {
  final List<Report> _reports = [];
  List<Report> get reports => List.unmodifiable(_reports);

  void add(Report r) {
    _reports.insert(0, r);
    notifyListeners();
  }
}

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});
  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final store = ReportsStore();
  late SharedPreferences prefs;
  final selectedCategories = <String>{};

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      prefs = p;
      final saved = prefs.getStringList('selected_categories') ?? [];
      selectedCategories.addAll(saved);
      setState(() {});
    });
  }

  void toggleCategory(String c) async {
    setState(() {
      if (selectedCategories.contains(c)) {
        selectedCategories.remove(c);
      } else {
        selectedCategories.add(c);
      }
    });
    await prefs.setStringList('selected_categories', selectedCategories.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("דיווחים אחרונים"),
          actions: [
            IconButton(
              onPressed: () async {
                await showDialog(context: context, builder: (_) => CategoryPickerDialog(selected: selectedCategories, onToggle: toggleCategory));
              },
              icon: const Icon(Icons.filter_alt),
              tooltip: "בחירת קטגוריות",
            )
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            // דמו בלבד: הוספת דיווח מקומי כדי לראות UI
            store.add(Report(title: "דיווח דמו", body: "זהו דיווח דמו להצגת הממשק.", category: categories.first));
            setState(() {});
          },
          icon: const Icon(Icons.play_arrow),
          label: const Text("הוסף דיווח דמו"),
        ),
        body: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final filtered = store.reports.where((r) => selectedCategories.isEmpty || selectedCategories.contains(r.category)).toList();
            if (filtered.isEmpty) {
              return Center(
                child: Text(selectedCategories.isEmpty
                    ? "אין דיווחים עדיין.\nלחץ על 'הוסף דיווח דמו' לבדיקה."
                    : "אין דיווחים בקטגוריות שנבחרו."),
              );
            }
            return ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final r = filtered[i];
                return ListTile(
                  title: Text(r.title),
                  subtitle: Text(r.body),
                  leading: const Icon(Icons.notifications),
                  trailing: Text("${r.createdAt.hour.toString().padLeft(2,'0')}:${r.createdAt.minute.toString().padLeft(2,'0')}"),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class CategoryPickerDialog extends StatelessWidget {
  final Set<String> selected;
  final void Function(String) onToggle;
  const CategoryPickerDialog({super.key, required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("בחירת קטגוריות"),
      content: SizedBox(
        width: 300,
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final c in categories)
              CheckboxListTile(
                value: selected.contains(c),
                onChanged: (_) => onToggle(c),
                title: Text(c),
              )
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("סגור"))
      ],
    );
  }
}

// ===== מנהלים =====
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final emailCtrl = TextEditingController(text: adminEmailSeed);
  final passCtrl = TextEditingController(text: adminPasswordSeed);
  String? error;

  void login() {
    if (emailCtrl.text.trim() == adminEmailSeed && passCtrl.text == adminPasswordSeed) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminComposeScreen()));
    } else {
      setState(() => error = "אימייל או סיסמה שגויים (דמו)");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text("כניסת מנהלים")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "אימייל")),
              const SizedBox(height: 12),
              TextField(controller: passCtrl, decoration: const InputDecoration(labelText: "סיסמה"), obscureText: true),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: login, child: const Text("כניסה")),
              if (error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error!, style: const TextStyle(color: Colors.red))),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminComposeScreen extends StatefulWidget {
  const AdminComposeScreen({super.key});

  @override
  State<AdminComposeScreen> createState() => _AdminComposeScreenState();
}

class _AdminComposeScreenState extends State<AdminComposeScreen> {
  final titleCtrl = TextEditingController();
  final bodyCtrl = TextEditingController();
  String selectedCategory = categories.first;

  Future<void> sendReport() async {
    // בדמו: נציג snackbar. בגרסה אמיתית: שליחת פוש לפי topic של הקטגוריה.
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("הדיווח נשלח (דמו)")));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text("יצירת דיווח")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "כותרת")),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: [for (final c in categories) DropdownMenuItem(value: c, child: Text(c))],
                onChanged: (v) => setState(() => selectedCategory = v ?? selectedCategory),
                decoration: const InputDecoration(labelText: "קטגוריה"),
              ),
              const SizedBox(height: 12),
              TextField(controller: bodyCtrl, decoration: const InputDecoration(labelText: "תוכן"), maxLines: 5),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: sendReport,
                icon: const Icon(Icons.send),
                label: const Text("שלח דיווח (פוש)"),
              ),
              const SizedBox(height: 8),
              const Text("הערה: זהו דמו. הפוש יעבוד לאחר חיבור Firebase ו-backend (Cloud Functions)."),
            ],
          ),
        ),
      ),
    );
  }
}