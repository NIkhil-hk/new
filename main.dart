import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuizApp());
}

class AppColors {
  static const Color primary = Color(0xFF6750A4); // Deep purple
  static const Color secondary = Color(0xFF00BFA6); // Teal
  static const Color bgDark = Color(0xFF0F1222);
  static const Color bgLight = Color(0xFFF2F3F8);
  static const Color correct = Color(0xFF42B883); // Green
  static const Color wrong = Color(0xFFE53935);   // Red
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Science Quiz',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.bgLight,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

// --------------------------- Splash Screen ---------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..forward();
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    Future.delayed(const Duration(milliseconds: 1700), () async {
      final prefs = await SharedPreferences.getInstance();
      final hasProfile = prefs.getString('name')?.isNotEmpty == true;
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => hasProfile ? const HomeScreen() : const ProfileScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E335A), Color(0xFF1C1B33)],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 110,
                    width: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.secondary, AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 12),
                        )
                      ],
                    ),
                    child: const Icon(Icons.science, color: Colors.white, size: 56),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Science Quiz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------- Profile Screen ---------------------------
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameCtrl.text.trim());
    await prefs.setInt('age', int.parse(_ageCtrl.text.trim()));
    await prefs.setString('mobile', _mobileCtrl.text.trim());
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEDE7F6), Color(0xFFE3FDF5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxWidth: 520),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Let’s get to know you',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'We’ll save this for future logins',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Please enter your name'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.cake_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter age';
                        final n = int.tryParse(v.trim());
                        if (n == null || n < 5 || n > 100) return 'Enter a valid age';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _mobileCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter mobile number';
                        final cleaned = v.replaceAll(RegExp(r'\s+'), '');
                        if (!RegExp(r'^\d{10,12}$').hasMatch(cleaned)) {
                          return 'Enter 10-12 digit number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _save,
                        child: const Text('Continue'),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------- Home Screen ---------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _name = '';
  int _age = 0;
  String _mobile = '';
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? '';
      _age = prefs.getInt('age') ?? 0;
      _mobile = prefs.getString('mobile') ?? '';
      _highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Science Quiz'),
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            icon: const Icon(Icons.edit_outlined),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F7FF), Color(0xFFE6FFFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.secondary,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, $_name',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text('Age: $_age    •    Mobile: $_mobile',
                                  style: TextStyle(color: Colors.grey.shade700)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('High Score', style: TextStyle(fontWeight: FontWeight.w600)),
                            Text('$_highScore / 20',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => QuizScreen(questions: QuestionBank.all)),
                        );
                      },
                      child: const Text('Start Quiz'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------- Quiz Data ---------------------------
class Question {
  final String text;
  final List<String> options; // length 4
  final int answerIndex; // 0..3

  const Question({required this.text, required this.options, required this.answerIndex});
}

class QuestionBank {
  static final List<Question> all = [
    Question(
      text: '1. Which law states that pressure is directly proportional to temperature at constant volume?',
      options: ['Boyle\'s Law', 'Charles\' Law', 'Gay-Lussac\'s Law', 'Avogadro\'s Law'],
      answerIndex: 2,
    ),
    Question(
      text: '2. What is the SI unit of electric charge?',
      options: ['Volt', 'Coulomb', 'Ampere', 'Ohm'],
      answerIndex: 1,
    ),
    Question(
      text: '3. DNA replication is ___ in nature.',
      options: ['Conservative', 'Semi-conservative', 'Dispersive', 'Random'],
      answerIndex: 1,
    ),
    Question(
      text: '4. Which orbital has the highest penetration power?',
      options: ['3d', '3p', '3s', '2p'],
      answerIndex: 2,
    ),
    Question(
      text: '5. The focal length of a convex lens is positive/negative?',
      options: ['Positive', 'Negative', 'Zero', 'Depends on object distance'],
      answerIndex: 0,
    ),
    Question(
      text: '6. In plants, which hormone promotes cell elongation?',
      options: ['Auxin', 'Cytokinin', 'Gibberellin', 'Abscisic acid'],
      answerIndex: 0,
    ),
    Question(
      text: '7. For a first-order reaction, half-life is ___ to initial concentration.',
      options: ['Directly proportional', 'Inversely proportional', 'Independent', 'Exponential'],
      answerIndex: 2,
    ),
    Question(
      text: '8. The work function is related to which phenomenon?',
      options: ['Compton effect', 'Photoelectric effect', 'Zeeman effect', 'Hall effect'],
      answerIndex: 1,
    ),
    Question(
      text: '9. Which bond is strongest among these?',
      options: ['Hydrogen bond', 'Ionic bond', 'Covalent bond', 'Van der Waals force'],
      answerIndex: 2,
    ),
    Question(
      text: '10. Which organelle is the site of ATP synthesis in eukaryotic cells?',
      options: ['Golgi apparatus', 'Mitochondria', 'Ribosome', 'Lysosome'],
      answerIndex: 1,
    ),
    Question(
      text: '11. Which of the following is a vector quantity?',
      options: ['Speed', 'Work', 'Power', 'Momentum'],
      answerIndex: 3,
    ),
    Question(
      text: '12. Electronegativity generally ___ across a period and ___ down a group.',
      options: ['Decreases, decreases', 'Increases, decreases', 'Decreases, increases', 'Increases, increases'],
      answerIndex: 1,
    ),
    Question(
      text: '13. Which of the following has the smallest wavelength?',
      options: ['Radio waves', 'Microwaves', 'Visible light', 'X-rays'],
      answerIndex: 3,
    ),
    Question(
      text: '14. Which enzyme unwinds the DNA helix during replication?',
      options: ['Ligase', 'Polymerase', 'Helicase', 'Primase'],
      answerIndex: 2,
    ),
    Question(
      text: '15. Which principle explains buoyant force?',
      options: ['Bernoulli\'s principle', 'Archimedes\' principle', 'Pascal\'s principle', 'Hooke\'s law'],
      answerIndex: 1,
    ),
    Question(
      text: '16. In electrochemistry, the anode in a galvanic cell is the electrode where ___ occurs.',
      options: ['Reduction', 'Oxidation', 'Both happen', 'No reaction'],
      answerIndex: 1,
    ),
    Question(
      text: '17. Which carbohydrate is a structural component of plant cell walls?',
      options: ['Starch', 'Glycogen', 'Cellulose', 'Sucrose'],
      answerIndex: 2,
    ),
    Question(
      text: '18. In optics, the power of a lens is measured in ___.',
      options: ['Diopters', 'Teslas', 'Newtons', 'Joules'],
      answerIndex: 0,
    ),
    Question(
      text: '19. Which gas shows the greatest deviation from ideal behavior at high pressure?',
      options: ['He', 'H2', 'CO2', 'Ne'],
      answerIndex: 2,
    ),
    Question(
      text: '20. The basic unit of heredity is ___.',
      options: ['Chromosome', 'Gene', 'Allele', 'Nucleotide'],
      answerIndex: 1,
    ),
  ];
}

enum AnswerState { notAnswered, correct, wrong }

// --------------------------- Quiz Screen ---------------------------
class QuizScreen extends StatefulWidget {
  final List<Question> questions;
  const QuizScreen({super.key, required this.questions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int index = 0;
  int score = 0;
  final Map<int, AnswerState> status = {}; // qIndex -> state
  final Map<int, int> selectedOption = {}; // qIndex -> optionIndex

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.questions.length; i++) {
      status[i] = AnswerState.notAnswered;
    }
  }

  void _selectOption(int opt) {
    final q = widget.questions[index];
    if (status[index] != AnswerState.notAnswered) return; // prevent re-answering

    final isCorrect = opt == q.answerIndex;
    setState(() {
      selectedOption[index] = opt;
      status[index] = isCorrect ? AnswerState.correct : AnswerState.wrong;
      if (isCorrect) score++;
    });
  }

  void _next() {
    if (index < widget.questions.length - 1) {
      setState(() => index++);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            total: widget.questions.length,
            score: score,
          ),
        ),
      );
    }
  }

  Color _chipColor(AnswerState s) {
    switch (s) {
      case AnswerState.correct:
        return AppColors.correct;
      case AnswerState.wrong:
        return AppColors.wrong;
      case AnswerState.notAnswered:
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[index];
    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${index + 1} / ${widget.questions.length}'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress chips row
            SizedBox(
              height: 64,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) {
                  final s = status[i]!;
                  final color = _chipColor(s);
                  return GestureDetector(
                    onTap: () => setState(() => index = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black12),
                        boxShadow: [
                          if (s != AnswerState.notAnswered)
                            BoxShadow(
                              color: color.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: s == AnswerState.notAnswered ? Colors.black87 : Colors.white,
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: widget.questions.length,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Text(
                        q.text,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...List.generate(q.options.length, (optIdx) {
                      final selected = selectedOption[index] == optIdx;
                      final hasAnswered = status[index] != AnswerState.notAnswered;
                      Color bg = Colors.white;
                      Color fg = Colors.black87;
                      if (hasAnswered && selected) {
                        bg = (optIdx == q.answerIndex) ? AppColors.correct : AppColors.wrong;
                        fg = Colors.white;
                      }

                      return AnimatedContainer(
                        key: ValueKey('q${index}_opt$optIdx'),
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _selectOption(optIdx),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: hasAnswered && selected
                                        ? Colors.white.withOpacity(0.25)
                                        : Colors.black12,
                                  ),
                                  child: Center(
                                    child: Text(String.fromCharCode(65 + optIdx),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: hasAnswered && selected ? Colors.white : Colors.black87,
                                        )),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    q.options[optIdx],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: fg,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Skip behaves like not-answered; move forward
                        if (index < widget.questions.length - 1) {
                          setState(() => index++);
                        }
                      },
                      child: const Text('Skip'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _next,
                      child: Text(index == widget.questions.length - 1 ? 'Finish' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------- Result Screen ---------------------------
class ResultScreen extends StatefulWidget {
  final int total;
  final int score;
  const ResultScreen({super.key, required this.total, required this.score});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _saveAndLoad();
  }

  Future<void> _saveAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getInt('highScore') ?? 0;
    if (widget.score > existing) {
      await prefs.setInt('highScore', widget.score);
    }
    setState(() => _highScore = prefs.getInt('highScore') ?? widget.score);
  }

  @override
  Widget build(BuildContext context) {
    final percent = (widget.score / widget.total * 100).toStringAsFixed(1);
    return Scaffold(
      appBar: AppBar(title: const Text('Your Result')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFDFBFB), Color(0xFFEBEDEE)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events_outlined, size: 72, color: AppColors.secondary),
                    const SizedBox(height: 10),
                    Text(
                      'Score: ${widget.score} / ${widget.total}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text('Percentage: $percent%', style: TextStyle(color: Colors.grey.shade700)),
                    const SizedBox(height: 6),
                    Text('High Score: $_highScore / ${widget.total}',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.replay_outlined),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => QuizScreen(questions: QuestionBank.all)),
                                (route) => route.isFirst,
                              );
                            },
                            label: const Text('Retry Quiz'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.home_outlined),
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const HomeScreen()),
                                (route) => false,
                              );
                            },
                            label: const Text('Home'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
