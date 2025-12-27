import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'; 
// --- REQUIRED IMPORT FOR COLORS ---
import 'package:maxim___frontend/theme/app_theme.dart'; 

// --- CONSTANTS ---
const double kButtonRadius = 14.0; 

// --- QUIZ DATA MODEL ---
class QuizQuestion {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;

  const QuizQuestion({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
  });
}

// --- MOCK QUIZ CONTENT ---
final List<QuizQuestion> financialQuiz = const [
  QuizQuestion(
    questionText: "What is the single most important factor affecting your credit score?",
    options: ["Credit Mix", "Payment History", "Length of Credit History", "Amounts Owed"],
    correctAnswerIndex: 1,
  ),
  QuizQuestion(
    questionText: "What is 'Credit Utilization'?",
    options: ["How often you use your cards", "The ratio of your debt to your available credit", "Your total credit limit", "The interest rate on your debt"],
    correctAnswerIndex: 1,
  ),
  QuizQuestion(
    questionText: "Which action would have the LEAST impact on immediately improving a low credit score?",
    options: ["Paying off a collection account", "Opening 3 new credit cards", "Lowering your credit utilization", "Disputing an error on your report"],
    correctAnswerIndex: 1,
  ),
  QuizQuestion(
    questionText: "What is typically the largest component of a FICO credit score?",
    options: ["New Credit", "Types of Credit Used", "Payment History", "Debt Amount"],
    correctAnswerIndex: 2,
  ),
  QuizQuestion(
    questionText: "If you have a credit card with a \$10,000 limit, what balance should you maintain to keep your utilization optimal?",
    options: ["\$9,000", "\$5,000", "Under \$3,000", "Exactly \$0"],
    correctAnswerIndex: 2,
  ),
  QuizQuestion(
    questionText: "What does BNPL stand for in finance?",
    options: ["Borrow Now, Pay Later", "Budget N' Plan Logic", "Buy Now, Pay Later", "Bank National Payment Limit"],
    correctAnswerIndex: 2,
  ),
  QuizQuestion(
    questionText: "Which item is NOT usually factored into your credit score?",
    options: ["Student loan debt", "Car loan payments", "Savings account balance", "Credit card balance"],
    correctAnswerIndex: 2,
  ),
  QuizQuestion(
    questionText: "What is a 'hard inquiry' on a credit report?",
    options: ["Checking your own score", "Reviewing a loan application", "Requesting a free report online", "Pre-qualifying for a mortgage"],
    correctAnswerIndex: 1,
  ),
  QuizQuestion(
    questionText: "What is considered a 'Good' FICO credit score range?",
    options: ["300-579", "580-669", "670-739", "800+"],
    correctAnswerIndex: 2,
  ),
  QuizQuestion(
    questionText: "To maximize the length of your credit history, what should you generally avoid doing?",
    options: ["Paying off debt", "Closing old credit accounts", "Opening new credit accounts", "Using only one card"],
    correctAnswerIndex: 1,
  ),
];


class FinancialInsightPage extends StatefulWidget {
  const FinancialInsightPage({super.key});

  @override
  State<FinancialInsightPage> createState() => _FinancialInsightPageState();
}

enum InsightStage { video, quiz, results }

class _FinancialInsightPageState extends State<FinancialInsightPage> {
  InsightStage _currentStage = InsightStage.video;
  int _currentQuestionIndex = 0;
  final List<int?> _userAnswers = List.filled(financialQuiz.length, null);
  bool _videoWatched = false;
  int _score = 0;
  int _xpEarned = 0;
  
  // Video Player Controllers
  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;
  
  // Timer related state
  late Stopwatch _quizTimer;
  late Duration _timeLimit;
  String _timeRemainingDisplay = "10:00"; 
  bool _quizActive = false;

  @override
  void initState() {
    super.initState();
    _timeLimit = const Duration(minutes: 10);
    _quizTimer = Stopwatch();

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse('https://pub-ab2ca7f8a2a6497b844d4614c034e9e9.r2.dev/videoplayback.mp4'), 
    );

    // FIX 1 & 2: Set volume to 1.0 (max) and attach post-initialization logic
    _initializeVideoPlayerFuture = _videoController.initialize().then((_) {
      // FIX 1: Set volume to 1.0 to ensure audio is audible
      _videoController.setVolume(1.0); 
      setState(() {}); 
    });
    
    // Add Listener to detect video completion
    _videoController.addListener(_videoListener);
  }

  void _videoListener() {
    // FIX 2 & 4: Only handle completion and UI updates outside of playback.
    // The FutureBuilder listening to the controller handles the progress bar and time updates automatically during playback.
    
    // Completion Logic (Must happen only once)
    if (_videoController.value.isCompleted && !_videoWatched) {
      
      // Set the flag and update the state to unlock the button
      setState(() {
        _videoWatched = true;
      });
      
      // Show the Snackbar (will only happen once)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Video complete! Quiz is now unlocked.',
            style: TextStyle(color: AppColors.kAccentWhite), 
          ),
          backgroundColor: AppColors.kDarkBackground, 
        ),
      );
    }
  }

  @override
  void dispose() {
    _videoController.removeListener(_videoListener);
    _videoController.dispose(); 
    _quizTimer.stop();
    super.dispose();
  }

  // New: Helper function to format Duration object into MM:SS string.
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    // Optionally include hours if duration can exceed 60 minutes
    if (duration.inHours > 0) {
      return '${duration.inHours}:${minutes}:${seconds}';
    }
    return '$minutes:$seconds';
  }

  void _startQuiz() {
    setState(() {
      _currentStage = InsightStage.quiz;
      _quizActive = true;
      _quizTimer.reset();
      _quizTimer.start();
      _startTimerUpdate();
    });
  }

  void _startTimerUpdate() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!_quizActive) return false;

      final elapsed = _quizTimer.elapsed;
      final remaining = _timeLimit - elapsed;

      if (remaining.isNegative) {
        _submitQuiz(timedOut: true);
        return false;
      }

      setState(() {
        final seconds = remaining.inSeconds % 60;
        final minutes = remaining.inMinutes;
        _timeRemainingDisplay = "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
      });
      return true;
    });
  }
  
  void _submitAnswer(int selectedOptionIndex) {
    _userAnswers[_currentQuestionIndex] = selectedOptionIndex;
    
    // Auto advance or finish
    if (_currentQuestionIndex < financialQuiz.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _submitQuiz();
    }
  }

  void _submitQuiz({bool timedOut = false}) {
    if (_quizActive) {
      _quizTimer.stop();
      _quizActive = false;
    }

    int finalScore = 0;
    for (int i = 0; i < financialQuiz.length; i++) {
      if (_userAnswers[i] == financialQuiz[i].correctAnswerIndex) {
        finalScore++;
      }
    }
    
    final int xpPerCorrectAnswer = 10;
    final int xpEarned = finalScore * xpPerCorrectAnswer;

    setState(() {
      _score = finalScore;
      _xpEarned = xpEarned;
      _currentStage = InsightStage.results;
      if (timedOut) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Time's up! Your quiz was submitted automatically."),
              backgroundColor: AppColors.kErrorRed, // Themed color
            ),
          );
      }
    });
  }

  // --- WIDGET BUILDERS ---

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 20,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.kDarkBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.kAccentWhite, size: 24),
          ),
          const Text(
            'Financial Insight',
            style: TextStyle(
              color: AppColors.kAccentWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Quiz Timer or Placeholder
          if (_currentStage == InsightStage.quiz) 
            Row(
              children: [
                Icon(Icons.timer_outlined, color: AppColors.kAccentGrey, size: 20),
                const SizedBox(width: 4),
                Text( 
                  _timeRemainingDisplay,
                  style: const TextStyle(color: AppColors.kAccentWhite, fontWeight: FontWeight.bold),
                ),
              ],
            )
          else 
            const SizedBox(width: 48), // Placeholder
        ],
      ),
    );
  }

  Widget _buildVideoStage(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Improve Your Credit Score',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.kDarkBackground,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Watch this short segment to understand the fundamentals of credit utilization and payment history.',
            style: TextStyle(fontSize: 16, color: AppColors.kDullTextColor),
          ),
          const SizedBox(height: 20),
          
          // --- VIDEO PLAYER ---
          // FIX: FutureBuilder is essential for listening to the controller and updating time/progress.
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        VideoPlayer(_videoController),
                        // Custom Controls Overlay (Themed) - Handles Play/Pause
                        _VideoControlsOverlay(controller: _videoController),
                        
                        // Position the current time and duration labels
                        Positioned(
                          bottom: 12, 
                          left: 10,
                          right: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Display Current Position (Updates with FutureBuilder rebuilds)
                              Text(
                                _formatDuration(_videoController.value.position), 
                                style: const TextStyle(
                                  color: AppColors.kAccentWhite,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  shadows: [Shadow(color: Colors.black, blurRadius: 3)],
                                ),
                              ),
                              // Display Total Duration
                              Text(
                                _formatDuration(_videoController.value.duration),
                                style: const TextStyle(
                                  color: AppColors.kAccentWhite,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  shadows: [Shadow(color: Colors.black, blurRadius: 3)],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Progress Indicator (Themed)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: VideoProgressIndicator(
                            _videoController, 
                            allowScrubbing: true, 
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), 
                            colors: const VideoProgressColors(
                              playedColor: AppColors.kDarkBackground, 
                              bufferedColor: AppColors.kDarkBackground, 
                              backgroundColor: AppColors.kAccentGrey,
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // Loading indicator (Themed)
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.kDarkBackground.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(child: CircularProgressIndicator(color: AppColors.kDarkBackground)), 
                );
              }
            },
          ),
          const SizedBox(height: 30),

          // 'Video Completed' status text
          Center(
            child: Text(
              _videoWatched ? 'Video playback completed successfully!' : 'Playback must be completed to unlock quiz.',
              style: TextStyle(
                fontSize: 16,
                color: _videoWatched ? AppColors.kDarkBackground : AppColors.kDullTextColor, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 15),

          // --- QUIZ BUTTON (Sleek, Full Width) ---
          GestureDetector(
            onTap: _videoWatched ? _startQuiz : null,
            child: Container(
              width: double.infinity,
              height: 56, 
              decoration: BoxDecoration(
                // Use kDarkBackground when active, kDullTextColor when disabled
                color: _videoWatched ? AppColors.kDarkBackground : AppColors.kDullTextColor, 
                borderRadius: BorderRadius.circular(kButtonRadius),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.quiz_outlined,
                      color: AppColors.kAccentWhite,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Start 10-Question Quiz',
                      style: TextStyle(
                        color: AppColors.kAccentWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for video play/pause control (Themed)
  Widget _VideoControlsOverlay({required VideoPlayerController controller}) {
    return Positioned.fill(
      child: Center(
        child: InkWell(
          // FIX 3: This logic is correct for toggling play/pause. 
          // It relies on the surrounding FutureBuilder to rebuild the UI.
          onTap: () {
            setState(() {
              controller.value.isPlaying ? controller.pause() : controller.play();
            });
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 50),
            reverseDuration: const Duration(milliseconds: 200),
            child: controller.value.isPlaying
                ? const SizedBox.shrink()
                : Container(
                    decoration: BoxDecoration(
                      color: AppColors.kDarkBackground.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.play_arrow,
                      color: AppColors.kAccentWhite, // Themed color
                      size: 40.0,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
  
  // Quiz Stage (Themed)
  Widget _buildQuizStage() {
    final question = financialQuiz[_currentQuestionIndex];
    final selectedOption = _userAnswers[_currentQuestionIndex];
    final progress = (_currentQuestionIndex / financialQuiz.length);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Bar (Themed)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text( 
                'Question ${_currentQuestionIndex + 1} of ${financialQuiz.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.kDarkBackground),
              ),
              Text(
                'XP: ${(_currentQuestionIndex * 10)} / ${financialQuiz.length * 10}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.kDarkBackground), 
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.kAccentGrey,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.kDarkBackground), 
            ),
          ),
          const SizedBox(height: 30),

          // Question Text
          Text(
            question.questionText,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.kDarkBackground,
            ),
          ),
          const SizedBox(height: 25),

          // Options (Themed)
          ...question.options.asMap().entries.map((entry) {
            final int index = entry.key;
            final String option = entry.value;
            final bool isSelected = selectedOption == index;

            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: GestureDetector(
                onTap: () => _submitAnswer(index),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.kDarkBackground.withOpacity(0.1) : AppColors.kAccentWhite, 
                    borderRadius: BorderRadius.circular(kButtonRadius), 
                    border: Border.all(
                      color: isSelected ? AppColors.kDarkBackground : AppColors.kAccentGrey, 
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isSelected ? AppColors.kDarkBackground : AppColors.kDullTextColor, 
                        size: 24,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.normal,
                            color: AppColors.kDarkBackground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 20),

          // Submit Quiz Button (Sleek, Full Width)
          if (_currentQuestionIndex == financialQuiz.length - 1)
            GestureDetector(
              onTap: () => _submitQuiz(),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.kDarkBackground, 
                  borderRadius: BorderRadius.circular(kButtonRadius),
                ),
                child: const Center(
                  child: Text(
                    'Submit Quiz & Get Results',
                    style: TextStyle(
                      color: AppColors.kAccentWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Results Stage (Themed)
  Widget _buildResultsStage() {
    final double percentage = (_score / financialQuiz.length) * 100;
    
    String resultMessage;
    Color resultColor;
    if (percentage >= 80) {
      resultMessage = "Excellent! You are a Credit Expert!";
      resultColor = AppColors.kDarkBackground; 
    } else if (percentage >= 60) {
      resultMessage = "Great job! Keep learning.";
      resultColor = AppColors.kDarkBackground;
    } else {
      resultMessage = "Keep practicing! Review the video.";
      resultColor = AppColors.kErrorRed; 
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.military_tech_outlined, size: 80, color: resultColor),
            const SizedBox(height: 20),
            Text(
              resultMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: resultColor,
              ),
            ),
            const SizedBox(height: 30),
            
            _buildResultCard(
              title: 'Total Score',
              value: '$_score / ${financialQuiz.length}',
              color: AppColors.kDarkBackground,
            ),
            _buildResultCard(
              title: 'XP Earned',
              value: '$_xpEarned XP',
              color: AppColors.kDarkBackground, 
              icon: Icons.star_border,
            ),
            _buildResultCard(
              title: 'Time Taken',
              value: (_timeLimit - _quizTimer.elapsed).isNegative 
                  ? "10:00 (Timeout)"
                  : _quizTimer.elapsed.inMinutes > 0 
                      ? "${_quizTimer.elapsed.inMinutes}m ${_quizTimer.elapsed.inSeconds % 60}s"
                      : "${_quizTimer.elapsed.inSeconds}s",
              color: AppColors.kDullTextColor,
            ),
            
            const SizedBox(height: 40),
            // Back to Summary Button (Sleek, Full Width)
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.kDarkBackground, 
                  borderRadius: BorderRadius.circular(kButtonRadius),
                ),
                child: const Center(
                  child: Text(
                    'Back to Summary',
                    style: TextStyle(
                      color: AppColors.kAccentWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard({required String title, required String value, required Color color, IconData? icon}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.kAccentWhite,
        borderRadius: BorderRadius.circular(kButtonRadius), 
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text( 
            title,
            style: const TextStyle(fontSize: 17, color: AppColors.kDarkBackground),
          ),
          Row(
            children: [
              if (icon != null) Icon(icon, color: color, size: 20),
              if (icon != null) const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    switch (_currentStage) {
      case InsightStage.video:
        bodyContent = _buildVideoStage(context);
        break;
      case InsightStage.quiz:
        bodyContent = _buildQuizStage();
        break;
      case InsightStage.results:
        bodyContent = _buildResultsStage();
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.kLightBackground, // Themed color
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: bodyContent),
        ],
      ),
    );
  }
}