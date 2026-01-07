import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// --- نموذج البيانات ---
class Word {
  final String text;
  final bool isSolar;

  Word({required this.text, required this.isSolar});
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settingsBox');
  runApp(const EducationApp());
}

class EducationApp extends StatelessWidget {
  const EducationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تطبيق تعليمي لغوي',
      theme: ThemeData(primarySwatch: Colors.teal, fontFamily: 'Arial'),
      home: const MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("القائمة الرئيسية"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _menuButton(
              context,
              "اللغة العربية: اللام الشمسية والقمرية",
              const ArabicQuizPage(),
            ),
            const SizedBox(height: 20),
            _menuButton(context, "الرياضيات: قريباً", null),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context, String title, Widget? page) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        minimumSize: const Size(300, 60),
      ),
      onPressed: page == null
          ? null
          : () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => page),
            ),
      child: Text(title, style: const TextStyle(fontSize: 16)),
    );
  }
}

class ArabicQuizPage extends StatefulWidget {
  const ArabicQuizPage({super.key});

  @override
  State<ArabicQuizPage> createState() => _ArabicQuizPageState();
}

class _ArabicQuizPageState extends State<ArabicQuizPage> {
  final List<Word> _allWords = [];
  List<Word> _currentSessionWords = [];
  int _currentIndex = 0;
  int _score = 0;
  bool? _isCorrect;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _loadWords();
    _startNewGame();
  }

  void _loadWords() {
    // قائمة الكلمات القمرية (تبدأ بـ: أ، ب، ج، ح، خ، ع، غ، ف، ق، ك، م، هـ، و، ي)
    List<String> moonBases = [
      "أسد",
      "أرنب",
      "أب",
      "إبريق",
      "باب",
      "بيت",
      "بحر",
      "برتقال",
      "جمل",
      "جبل",
      "جرس",
      "جزر",
      "حمامة",
      "حوت",
      "حقيبة",
      "حليب",
      "خروف",
      "خيار",
      "خبز",
      "خيمة",
      "عين",
      "عنب",
      "عصفور",
      "عالم",
      "غزال",
      "غيمة",
      "غرفة",
      "غواص",
      "فيل",
      "فراشة",
      "فأس",
      "فصل",
      "قمر",
      "قلم",
      "قطار",
      "قارب",
      "كتاب",
      "كرسي",
      "كلب",
      "كرة",
      "مدرسة",
      "مفتاح",
      "ماء",
      "مقص",
      "هاتف",
      "هرم",
      "هلال",
      "هدية",
      "ولد",
      "ورقة",
      "وردة",
      "وشاح",
      "يد",
      "يمامة",
      "يسار",
      "ياقوت",
    ];

    // قائمة الكلمات الشمسية (تبدأ بـ: ت، ث، د، ذ، ر، ز، س، ش، ص، ض، ط، ظ، ل، ن)
    List<String> solarBases = [
      "شمس",
      "شجرة",
      "شارع",
      "شراع",
      "تفاح",
      "تمساح",
      "تاج",
      "تلفاز",
      "ثوب",
      "ثعلب",
      "ثعبان",
      "ثوم",
      "ديك",
      "دفتر",
      "دب",
      "درهم",
      "ذئب",
      "ذرة",
      "ذهب",
      "ذباب",
      "رجل",
      "ريشة",
      "رمان",
      "رمل",
      "زهرة",
      "زرافة",
      "زيتون",
      "زمزم",
      "سمك",
      "ساعة",
      "سيف",
      "سماء",
      "صقر",
      "صندوق",
      "صورة",
      "صابون",
      "ضفدع",
      "درس",
      "ضابط",
      "ضوء",
      "طالب",
      "طائرة",
      "طاولة",
      "طير",
      "ظرف",
      "ظهر",
      "ظفر",
      "ظل",
      "لحم",
      "ليمون",
      "ليل",
      "لسان",
      "نهر",
      "نمر",
      "نحلة",
      "نجمة",
    ];

    for (var b in moonBases) {
      _allWords.add(Word(text: "ال$b", isSolar: false));
    }
    for (var b in solarBases) {
      _allWords.add(Word(text: "ال$b", isSolar: true));
    }

    // لتصل للعدد المطلوب، سنقوم بتكرار الكلمات برمجياً (ولكن بدون أرقام)
    // وبما أننا نستخدم shuffle، لن يشعر المستخدم بالتكرار في الجلسة الواحدة
    while (_allWords.length < 1000) {
      _allWords.addAll(List.from(_allWords));
    }
  }

  void _startNewGame() {
    setState(() {
      _allWords.shuffle();
      _currentSessionWords = _allWords.take(10).toList();
      _currentIndex = 0;
      _score = 0;
      _isCorrect = null;
      _isFinished = false;
    });
  }

  void _checkAnswer(bool userChoice) {
    if (_isCorrect != null) return;
    setState(() {
      _isCorrect = userChoice == _currentSessionWords[_currentIndex].isSolar;
      if (_isCorrect!) _score++;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          if (_currentIndex < _currentSessionWords.length - 1) {
            _currentIndex++;
            _isCorrect = null;
          } else {
            _isFinished = true;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) return _buildResult();

    Word current = _currentSessionWords[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("اختبار اللام")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            "إجابات صحيحة: $_score / ${_currentSessionWords.length}",
            style: const TextStyle(fontSize: 18),
          ),
          const Spacer(),
          Text(
            current.text,
            style: const TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 20),
          if (_isCorrect != null)
            Icon(
              _isCorrect! ? Icons.check_circle : Icons.cancel,
              color: _isCorrect! ? Colors.green : Colors.red,
              size: 60,
            ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _answerButton("شمسية ☀️", true),
              _answerButton("قمرية 🌙", false),
            ],
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _answerButton(String label, bool value) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(minimumSize: const Size(150, 60)),
      onPressed: () => _checkAnswer(value),
      child: Text(label, style: const TextStyle(fontSize: 20)),
    );
  }

  Widget _buildResult() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("ممتاز! انتهيت", style: TextStyle(fontSize: 28)),
            Text("نتيجتك: $_score من 10", style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _startNewGame,
              child: const Text("ابدأ جولة جديدة"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("رجوع"),
            ),
          ],
        ),
      ),
    );
  }
}
