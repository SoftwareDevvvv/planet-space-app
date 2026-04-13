import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  List<_QuizSet> _quizSets = const [];
  bool _isLoading = true;
  String? _loadError;

  _QuizSet? _activeQuiz;
  int _current = 0;
  int _score = 0;
  int? _selectedIndex;
  final Random _random = Random();
  bool _isComplete = false;
  @override
  void initState() {
    super.initState();
    _loadQuizSets();
  }

  Future<void> _loadQuizSets() async {
    try {
      final raw = await rootBundle.loadString('assets/quiz/quiz_sets.json');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final sets = decoded['sets'] as List<dynamic>;
      final parsed = sets
          .map((item) => _QuizSet.fromJson(item as Map<String, dynamic>))
          .toList();
      setState(() {
        _quizSets = parsed;
        _isLoading = false;
        _loadError = null;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _loadError = 'Failed to load quizzes.';
      });
    }
  }


  void _selectOption(int index) {
    if (_selectedIndex != null || _activeQuiz == null) {
      return;
    }
    setState(() {
      _selectedIndex = index;
      if (index == _activeQuiz!.questions[_current].correctIndex) {
        _score += 1;
      }
    });
  }

  void _next() {
    if (_selectedIndex == null || _activeQuiz == null) {
      return;
    }
    if (_current == _activeQuiz!.questions.length - 1) {
      setState(() {
        _isComplete = true;
      });
      return;
    }
    setState(() {
      _current += 1;
      _selectedIndex = null;
    });
  }

  void _restart() {
    setState(() {
      _current = 0;
      _score = 0;
      _selectedIndex = null;
      _isComplete = false;
    });
  }

  void _selectQuiz(_QuizSet quiz) {
    setState(() {
      _activeQuiz = _prepareQuizSet(quiz);
      _current = 0;
      _score = 0;
      _selectedIndex = null;
      _isComplete = false;
    });
  }

  _QuizSet _prepareQuizSet(_QuizSet quiz) {
    final shuffledQuestions = quiz.questions.map(_shuffleQuestion).toList();
    shuffledQuestions.shuffle(_random);
    return _QuizSet(
      title: quiz.title,
      subtitle: quiz.subtitle,
      questions: shuffledQuestions,
    );
  }

  _QuizQuestion _shuffleQuestion(_QuizQuestion question) {
    final indexedOptions = question.options
        .asMap()
        .entries
        .map((entry) => _IndexedOption(index: entry.key, value: entry.value))
        .toList();
    indexedOptions.shuffle(_random);
    final newOptions = indexedOptions.map((item) => item.value).toList();
    final newCorrectIndex = indexedOptions.indexWhere(
      (item) => item.index == question.correctIndex,
    );
    return _QuizQuestion(
      prompt: question.prompt,
      options: newOptions,
      correctIndex: newCorrectIndex,
      type: question.type,
      imageAsset: question.imageAsset,
      imageStyle: question.imageStyle,
    );
  }

  void _backToList() {
    setState(() {
      _activeQuiz = null;
      _current = 0;
      _score = 0;
      _selectedIndex = null;
      _isComplete = false;
    });
  }

  Future<void> _confirmExitQuiz() async {
    if (_current == 0 && _selectedIndex == null) {
      _backToList();
      return;
    }
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A0F1B),
          title: const Text('Exit quiz?'),
          content: const Text(
            'Your current progress will be reset if you leave now.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Stay'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
    if (shouldExit == true && mounted) {
      _backToList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF05070E),
      child: Stack(
        children: [
          const _QuizBackdrop(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: _isLoading
                  ? const _QuizLoading()
                  : _loadError != null
                      ? _QuizError(message: _loadError!, onRetry: _loadQuizSets)
                      : _activeQuiz == null
                          ? _buildQuizList(context)
                          : _isComplete
                              ? _buildResult(context)
                              : _buildQuiz(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUIZ ARCHIVE',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white.withOpacity(0.6),
                letterSpacing: 2.0,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Select a mission and test your planetary knowledge.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              if (width >= 800) {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: _quizSets.length,
                  itemBuilder: (context, index) {
                    final quiz = _quizSets[index];
                    return _QuizCard(
                      title: quiz.title,
                      subtitle: quiz.subtitle,
                      questionCount: quiz.questions.length,
                      onTap: () => _selectQuiz(quiz),
                    );
                  },
                );
              }
              return ListView.separated(
                itemCount: _quizSets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final quiz = _quizSets[index];
                  return _QuizCard(
                    title: quiz.title,
                    subtitle: quiz.subtitle,
                    questionCount: quiz.questions.length,
                    onTap: () => _selectQuiz(quiz),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuiz(BuildContext context) {
    final question = _activeQuiz!.questions[_current];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white70),
              onPressed: _confirmExitQuiz,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuizHeader(
                current: _current + 1,
                total: _activeQuiz!.questions.length,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _QuestionCard(question: question),
        const SizedBox(height: 18),
        Expanded(
          child: ListView.separated(
            itemCount: question.options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final isSelected = _selectedIndex == index;
              final isCorrect = index == question.correctIndex;
              final isWrong =
                  _selectedIndex != null && isSelected && !isCorrect;
              return _AnswerOption(
                label: question.options[index],
                isSelected: isSelected,
                isCorrect: _selectedIndex != null && isCorrect,
                isWrong: isWrong,
                onTap: () => _selectOption(index),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _selectedIndex == null ? null : _next,
                child: Text(_current == _activeQuiz!.questions.length - 1
                    ? 'FINISH'
                    : 'NEXT'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResult(BuildContext context) {
    final total = _activeQuiz?.questions.length ?? 0;
    final percent = (_score / total * 100).toStringAsFixed(0);
    return Center(
      child: _ResultCard(
        scoreText: '$_score / $total',
        percentText: '$percent%',
        onRestart: _restart,
        onBack: _backToList,
      ),
    );
  }
}

class _QuizQuestion {
  const _QuizQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.type,
    this.imageAsset,
    this.imageStyle,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String type;
  final String? imageAsset;
  final String? imageStyle;

  factory _QuizQuestion.fromJson(Map<String, dynamic> json) {
    return _QuizQuestion(
      prompt: json['prompt'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      correctIndex: json['correctIndex'] as int,
      type: json['type'] as String? ?? 'mcq',
      imageAsset: json['imageAsset'] as String?,
      imageStyle: json['imageStyle'] as String?,
    );
  }
}

class _IndexedOption {
  const _IndexedOption({required this.index, required this.value});

  final int index;
  final String value;
}

class _QuizSet {
  const _QuizSet({
    required this.title,
    required this.subtitle,
    required this.questions,
  });

  final String title;
  final String subtitle;
  final List<_QuizQuestion> questions;

  factory _QuizSet.fromJson(Map<String, dynamic> json) {
    return _QuizSet(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((item) => _QuizQuestion.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class _QuizBackdrop extends StatelessWidget {
  const _QuizBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridGlowPainter(),
      child: Container(),
    );
  }
}

class _QuizHeader extends StatelessWidget {
  const _QuizHeader({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = current / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUIZ · SOLAR SYSTEM',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white.withOpacity(0.6),
                letterSpacing: 2.0,
              ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  color: AppTheme.accent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$current/$total',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question});

  final _QuizQuestion question;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (question.imageAsset != null)
            Center(
              child: _QuestionImage(
                asset: question.imageAsset!,
                style: question.imageStyle,
              ),
            ),
          if (question.imageAsset != null) const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question.prompt,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.label,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final baseBorder = Colors.white.withOpacity(0.12);
    final borderColor = isCorrect
        ? const Color(0xFF5EE4A7)
        : isWrong
            ? const Color(0xFFFF7A7A)
            : isSelected
                ? AppTheme.accent
                : baseBorder;
    final background = isSelected
        ? AppTheme.accent.withOpacity(0.12)
        : const Color(0xFF0A0C14);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (isCorrect)
              const Icon(Icons.check_circle, color: Color(0xFF5EE4A7)),
            if (isWrong)
              const Icon(Icons.cancel, color: Color(0xFFFF7A7A)),
          ],
        ),
      ),
    );
  }
}

class _QuestionImage extends StatelessWidget {
  const _QuestionImage({required this.asset, this.style});

  final String asset;
  final String? style;

  @override
  Widget build(BuildContext context) {
    final isCircle = style == 'circle';
    if (isCircle) {
      return ClipOval(
        child: SizedBox(
          width: 180,
          height: 180,
          child: Image.asset(
            asset,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: double.infinity,
        height: 180,
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.scoreText,
    required this.percentText,
    required this.onRestart,
    required this.onBack,
  });

  final String scoreText;
  final String percentText;
  final VoidCallback onRestart;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D1628), Color(0xFF070A12)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'MISSION COMPLETE',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white.withOpacity(0.6),
                  letterSpacing: 2.0,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            percentText,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            scoreText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  child: const Text('BACK TO LIST'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onRestart,
                  child: const Text('RETRY'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({
    required this.title,
    required this.subtitle,
    required this.questionCount,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final int questionCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0F1B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.8),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            ),
            Text(
              '$questionCount Q',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0;
    const step = 38.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [AppTheme.accent.withOpacity(0.25), Colors.transparent],
      ).createShader(
        Rect.fromCircle(center: Offset(size.width * 0.8, size.height * 0.2), radius: size.width * 0.6),
      );
    canvas.drawRect(Offset.zero & size, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QuizLoading extends StatelessWidget {
  const _QuizLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppTheme.accent),
    );
  }
}

class _QuizError extends StatelessWidget {
  const _QuizError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('RETRY')),
        ],
      ),
    );
  }
}
