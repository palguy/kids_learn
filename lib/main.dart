import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settingsBox');
  runApp(const EducationApp());
}

class Word {
  final String text;
  final bool isSolar;
  Word({required this.text, required this.isSolar});
}

class EducationApp extends StatelessWidget {
  const EducationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'المعلم الذكي',
      theme: ThemeData(primarySwatch: Colors.indigo, fontFamily: 'Arial'),
      home: const MainMenu(),
    );
  }
}

// --- 1. الشاشة الرئيسية ---
class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("المعلم الذكي"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _card(
              context,
              "اللغة العربية",
              "اللام الشمسية والقمرية",
              Colors.orange,
              const ArabicQuizPage(),
            ),
            const SizedBox(height: 20),
            _card(
              context,
              "الرياضيات",
              "تحدي الخيارات المتعددة",
              Colors.blue,
              const MathOperationSelectPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context,
    String title,
    String sub,
    Color color,
    Widget page,
  ) {
    return InkWell(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              sub,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 2. اختيار العملية الحسابية ---
class MathOperationSelectPage extends StatelessWidget {
  const MathOperationSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("اختر العملية")),
      body: GridView.count(
        padding: const EdgeInsets.all(30),
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          _opBtn(context, "جمع (+)", "+"),
          _opBtn(context, "طرح (-)", "-"),
          _opBtn(context, "ضرب (×)", "×"),
          _opBtn(context, "قسمة (÷)", "÷"),
          _opBtn(context, "مختلط (؟)", "mixed"),
        ],
      ),
    );
  }

  Widget _opBtn(BuildContext context, String label, String op) {
    return ElevatedButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MathDigitsSelectPage(operation: op)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 26)),
    );
  }
}

// --- 3. اختيار عدد الخانات ---
class MathDigitsSelectPage extends StatelessWidget {
  final String operation;
  const MathDigitsSelectPage({super.key, required this.operation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("عدد الخانات")),
      body: Center(
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [2, 3, 4, 5]
              .map(
                (d) => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 80),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MathQuizPage(digits: d, selectedOp: operation),
                    ),
                  ),
                  child: Text("$d خانات", style: const TextStyle(fontSize: 18)),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// --- 4. شاشة اختبار الرياضيات (الخيارات + زر التالي) ---
class MathQuizPage extends StatefulWidget {
  final int digits;
  final String selectedOp;
  const MathQuizPage({
    super.key,
    required this.digits,
    required this.selectedOp,
  });

  @override
  State<MathQuizPage> createState() => _MathQuizPageState();
}

class _MathQuizPageState extends State<MathQuizPage> {
  late int n1, n2, result;
  late String currentOp;
  List<int> options = [];
  int correctCount = 0, wrongCount = 0, currentIdx = 1;
  String feedback = "";
  bool hasAnswered = false;
  int? lastSelected;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    final r = Random();
    int min = pow(10, widget.digits - 1).toInt();
    int max = pow(10, widget.digits).toInt() - 1;

    if (widget.selectedOp == "mixed") {
      var ops = ['+', '-', '×', '÷'];
      currentOp = ops[r.nextInt(4)];
    } else {
      currentOp = widget.selectedOp;
    }

    n1 = r.nextInt(max - min + 1) + min;
    n2 = r.nextInt(max - min + 1) + min;

    if (currentOp == '+') {
      result = n1 + n2;
    } else if (currentOp == '-') {
      if (n1 < n2) {
        int t = n1;
        n1 = n2;
        n2 = t;
      }
      result = n1 - n2;
    } else if (currentOp == '×') {
      n1 = r.nextInt(12) + 1;
      n2 = r.nextInt(10) + 1;
      result = n1 * n2;
    } else {
      result = r.nextInt(10) + 1;
      n2 = r.nextInt(9) + 2;
      n1 = n2 * result;
    }

    options = [result];
    while (options.length < 4) {
      int offset = r.nextInt(20) - 10;
      int fakeResult = result + offset;
      if (fakeResult >= 0 && !options.contains(fakeResult)) {
        options.add(fakeResult);
      }
    }
    options.shuffle();
    setState(() {
      hasAnswered = false;
      feedback = "";
      lastSelected = null;
    });
  }

  void _checkAnswer(int selected) {
    if (hasAnswered) return;
    setState(() {
      hasAnswered = true;
      lastSelected = selected;
      if (selected == result) {
        correctCount++;
        feedback = "أحسنت! إجابة صحيحة ✅";
      } else {
        wrongCount++;
        feedback = "خطأ، الجواب الصحيح هو $result ❌";
      }
    });
  }

  void _nextQuestion() {
    if (currentIdx < 10) {
      setState(() {
        currentIdx++;
        _generate();
      });
    } else {
      _showFinalDialog();
    }
  }

  void _showFinalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("انتهى التحدي"),
        content: Text("النتيجة النهائية: $correctCount من 10"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(ctx);
              Navigator.pop(ctx);
              Navigator.pop(ctx);
            },
            child: const Text("العودة للرئيسية"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text("تحدي الأذكياء")),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white54,
                  border: Border.all(color: Colors.blue, width: 1.0),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "✅ $correctCount",
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        "❌ $wrongCount",
                        style: const TextStyle(color: Colors.red, fontSize: 20),
                      ),
                      Text(
                        "سؤال $currentIdx/10",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // عرض المسألة
              Container(
                width: 300,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade100, width: 2),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blue.withOpacity(0.05),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "$n1",
                      style: const TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 30.0),
                            child: Text(
                              currentOp,
                              style: const TextStyle(
                                fontSize: 45,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            "$n2",
                            style: const TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 8,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 5, color: Colors.black),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Text(
                feedback,
                style: TextStyle(
                  fontSize: 22,
                  color: feedback.contains('✅') ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),

              // الخيارات
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 2.2,
                ),
                itemCount: options.length,
                itemBuilder: (ctx, i) {
                  Color btnColor = Colors.indigo.shade400;
                  if (hasAnswered) {
                    if (options[i] == result)
                      btnColor = Colors.green;
                    else if (options[i] == lastSelected)
                      btnColor = Colors.red;
                    else
                      btnColor = Colors.grey.shade400;
                  }

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () => _checkAnswer(options[i]),
                    child: Text(
                      "${options[i]}",
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // زر السؤال التالي - يظهر فقط بعد الإجابة
              if (hasAnswered)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _nextQuestion,
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ), // لأن التطبيق RTL فالسهم لليسار هو للأمام
                  label: const Text(
                    "السؤال التالي",
                    style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 5. قسم اللغة العربية (كما هو) ---
class ArabicQuizPage extends StatefulWidget {
  const ArabicQuizPage({super.key});
  @override
  State<ArabicQuizPage> createState() => _ArabicQuizPageState();
}

class _ArabicQuizPageState extends State<ArabicQuizPage> {
  final List<Word> _db = [];
  List<Word> _session = [];
  int idx = 0, ok = 0, fail = 0;
  bool? isOk;

  @override
  void initState() {
    super.initState();
    _fill();
    _reset();
  }

  void _fill() {
    var moon = [
      "أسد",
      "باب",
      "جمل",
      "حمامة",
      "خبز",
      "عين",
      "فيل",
      "قمر",
      "كلب",
      "مدرسة",
      "هلال",
      "ولد",
      "يد",
    ];
    var sun = [
      "شمس",
      "تفاح",
      "تمساح",
      "ثوب",
      "ديك",
      "ذئب",
      "رجل",
      "زهرة",
      "سمك",
      "طالب",
      "طائرة",
      "نهر",
    ];
    for (var w in moon) _db.add(Word(text: "ال$w", isSolar: false));
    for (var w in sun) _db.add(Word(text: "ال$w", isSolar: true));
    while (_db.length < 1000) _db.addAll(List.from(_db));
  }

  void _reset() {
    setState(() {
      _db.shuffle();
      _session = _db.take(30).toList();
      idx = 0;
      ok = 0;
      fail = 0;
      isOk = null;
    });
  }

  void _check(bool val) {
    if (isOk != null) return;
    setState(() {
      isOk = val == _session[idx].isSolar;
      if (isOk!)
        ok++;
      else
        fail++;
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        if (idx < 29) {
          setState(() {
            idx++;
            isOk = null;
          });
        } else {
          _showArabicResult();
        }
      }
    });
  }

  void _showArabicResult() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("انتهى الاختبار"),
        content: Text("صح: $ok | خطأ: $fail", style: TextStyle(fontSize: 20)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(ctx);
            },
            child: const Text("رجوع"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text("شمسية ولا قمرية؟")),
        body: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),

              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white54, // Background color of the container
                  border: Border.all(
                    color: Colors.blue, // Color of the border line
                    width: 1.0, // Width of the border line
                  ),
                  borderRadius: BorderRadius.circular(
                    12.0,
                  ), // The radius to round the corners
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "✅ $ok",
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        "❌ $fail",
                        style: const TextStyle(color: Colors.red, fontSize: 20),
                      ),
                      Text("سؤال ${idx + 1}/30"),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            Text(
              _session[idx].text,
              style: const TextStyle(
                fontSize: 65,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 20),
            if (isOk != null)
              Icon(
                isOk! ? Icons.check_circle : Icons.cancel,
                color: isOk! ? Colors.green : Colors.red,
                size: 80,
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.all(20),
                      ),
                      onPressed: () => _check(true),
                      child: const Text(
                        "شمسية ☀️",
                        style: TextStyle(fontSize: 26, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        padding: const EdgeInsets.all(20),
                      ),
                      onPressed: () => _check(false),
                      child: const Text(
                        "قمرية 🌙",
                        style: TextStyle(fontSize: 26, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
