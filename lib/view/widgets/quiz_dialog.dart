import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/model/quiz_model.dart';
import '../../core/utils/app_colors.dart';
import '../../viewmodel/quiz_vm.dart';

/// Quiz Dialog Widget
class QuizDialog extends StatefulWidget {
  final QuizQuestion question;

  const QuizDialog({super.key, required this.question});

  @override
  State<QuizDialog> createState() => _QuizDialogState();
}

class _QuizDialogState extends State<QuizDialog>
    with SingleTickerProviderStateMixin {
  String? _selectedAnswer;
  bool _isAnswered = false;
  bool _isCorrect = false;
  bool _isClosing = false; // Prevent double-pop
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleAnswerSelection(String answer) async {
    if (_isAnswered || _isClosing) return;

    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
    });

    final quizVm = Provider.of<QuizViewModel>(context, listen: false);
    final isCorrect = await quizVm.submitAnswer(answer);

    if (!mounted) return;

    setState(() {
      _isCorrect = isCorrect;
    });

    // Trigger animation
    if (_isCorrect) {
      _animationController.forward(from: 0.0);
    }
  }

  void _closeDialog([bool? result]) {
    if (_isClosing || !mounted) return;
    _isClosing = true;
    Navigator.of(context).pop(result);
  }

  Color _getOptionColor(String option) {
    final primaryColor = ThemeColors.getPrimaryColor(context);
    final backgroundColor = ThemeColors.getBackgroundColor(context);

    if (!_isAnswered) {
      return _selectedAnswer == option
          ? primaryColor.withValues(alpha: 0.2)
          : Colors.transparent;
    }

    if (option == widget.question.correctAnswer) {
      // Use primary color with lighter shade for correct
      return primaryColor.withValues(alpha: 0.15);
    }

    if (option == _selectedAnswer && !_isCorrect) {
      // Use a darker shade of background for incorrect
      return backgroundColor.withValues(alpha: 0.5);
    }

    return Colors.transparent;
  }

  Color _getOptionBorderColor(String option) {
    final primaryColor = ThemeColors.getPrimaryColor(context);

    if (!_isAnswered) {
      return _selectedAnswer == option
          ? primaryColor
          : ThemeColors.getBorderColor(context);
    }

    if (option == widget.question.correctAnswer) {
      // Use primary color for correct answer
      return primaryColor;
    }

    if (option == _selectedAnswer && !_isCorrect) {
      // Use a muted color for incorrect
      return ThemeColors.getSecondaryTextColor(context);
    }

    return ThemeColors.getBorderColor(context);
  }

  IconData? _getOptionIcon(String option) {
    if (!_isAnswered) return null;

    if (option == widget.question.correctAnswer) {
      return Icons.check_circle;
    }

    if (option == _selectedAnswer && !_isCorrect) {
      return Icons.cancel;
    }

    return null;
  }

  Color _getOptionIconColor(String option) {
    final primaryColor = ThemeColors.getPrimaryColor(context);

    if (option == widget.question.correctAnswer) {
      return primaryColor; // Use primary color instead of green
    }

    if (option == _selectedAnswer && !_isCorrect) {
      return ThemeColors.getSecondaryTextColor(
        context,
      ); // Muted color for incorrect
    }

    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColors.getCardColor(context),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button only
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: ThemeColors.getTextColor(context),
                  ),
                  onPressed: () => _closeDialog(false),
                ),
              ],
            ),

            // Question
            Text(
              widget.question.question,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ThemeColors.getTextColor(context),
              ),
            ),
            const SizedBox(height: 24),

            // Options
            ...widget.question.options.map((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOptionButton(option),
              );
            }),

            // Feedback
            if (_isAnswered) ...[const SizedBox(height: 20), _buildFeedback()],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String option) {
    final hasIcon = _getOptionIcon(option) != null;
    final iconColor = _getOptionIconColor(option);

    return GestureDetector(
      onTap: _isAnswered ? null : () => _handleAnswerSelection(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _getOptionColor(option),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _getOptionBorderColor(option), width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: _selectedAnswer == option
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: ThemeColors.getTextColor(context),
                ),
              ),
            ),
            if (hasIcon)
              Icon(_getOptionIcon(option), color: iconColor, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isCorrect ? _scaleAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isCorrect
                  ? ThemeColors.getPrimaryColor(context).withValues(alpha: 0.15)
                  : ThemeColors.getBackgroundColor(
                      context,
                    ).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isCorrect
                    ? ThemeColors.getPrimaryColor(context)
                    : ThemeColors.getSecondaryTextColor(context),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isCorrect ? Icons.check_circle : Icons.cancel,
                      color: _isCorrect
                          ? ThemeColors.getPrimaryColor(context)
                          : ThemeColors.getSecondaryTextColor(context),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isCorrect ? 'Correct!' : 'Incorrect',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _isCorrect
                            ? ThemeColors.getPrimaryColor(context)
                            : ThemeColors.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
                if (_isCorrect) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Correct answer: ${widget.question.correctAnswer}',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeColors.getSecondaryTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  Text(
                    'Correct answer: ${widget.question.correctAnswer}',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeColors.getSecondaryTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

}
