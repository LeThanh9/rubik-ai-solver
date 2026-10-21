import 'dart:async';
import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../services/rubik_solver.dart';

class SolverGuideSheet extends StatefulWidget {
  final List<SolverStep> steps;
  final int currentStepIndex;
  final Function(int newIndex) onStepSelected;
  final Function(String move) onExecuteMove;
  final GeminiService geminiService;

  const SolverGuideSheet({
    super.key,
    required this.steps,
    required this.currentStepIndex,
    required this.onStepSelected,
    required this.onExecuteMove,
    required this.geminiService,
  });

  @override
  State<SolverGuideSheet> createState() => _SolverGuideSheetState();
}

class _SolverGuideSheetState extends State<SolverGuideSheet> {
  bool _isPlaying = false;
  Timer? _autoPlayTimer;
  double _speedSeconds = 1.0;

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  void _toggleAutoPlay() {
    if (_isPlaying) {
      _stopAutoPlay();
    } else {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    setState(() => _isPlaying = true);
    _autoPlayTimer = Timer.periodic(
      Duration(milliseconds: (_speedSeconds * 1000).toInt()),
      (timer) {
        if (widget.currentStepIndex < widget.steps.length) {
          _goNext();
        } else {
          _stopAutoPlay();
        }
      },
    );
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    setState(() => _isPlaying = false);
  }

  void _goNext() {
    if (widget.currentStepIndex < widget.steps.length) {
      final currentStep = widget.steps[widget.currentStepIndex];
      widget.onExecuteMove(currentStep.move);
      widget.onStepSelected(widget.currentStepIndex + 1);
    } else {
      _stopAutoPlay();
    }
  }

  void _goPrevious() {
    if (widget.currentStepIndex > 0) {
      widget.onStepSelected(widget.currentStepIndex - 1);
    }
  }

  void _explainCurrentMove(SolverStep step) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141926),
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFF00E676), size: 20),
            const SizedBox(width: 8),
            Text('Giải thích bước: ${step.move}', style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: FutureBuilder<String>(
          future: widget.geminiService.explainMove(step.move, step.phaseTitle),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF00E676)),
                ),
              );
            }
            return Text(
              snapshot.data ?? 'Không có phản hồi.',
              style: const TextStyle(color: Colors.white70, height: 1.4, fontSize: 13),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng', style: TextStyle(color: Color(0xFF2979FF))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.steps.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF121622),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, color: Color(0xFF00E676), size: 48),
            const SizedBox(height: 12),
            const Text(
              'Khối Rubik đã hoàn tất giải!',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tất cả các mặt đã đồng màu. Hãy xáo trộn để giải tiếp.',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2979FF),
                shape: BorderRadius.circular(12),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final isDone = widget.currentStepIndex >= widget.steps.length;
    final currentStep = isDone ? widget.steps.last : widget.steps[widget.currentStepIndex];

    return Container(
      height: MediaQuery.of(context).size.height * 0.58,
      decoration: const BoxDecoration(
        color: Color(0xFF0F131E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Progress indicator & title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LỜI GIẢI TỪNG BƯỚC (${isDone ? widget.steps.length : widget.currentStepIndex + 1}/${widget.steps.length})',
                  style: const TextStyle(
                    color: Color(0xFF00E676),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  '${((widget.currentStepIndex / widget.steps.length) * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: LinearProgressIndicator(
              value: widget.steps.isEmpty ? 0 : widget.currentStepIndex / widget.steps.length,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(height: 12),

          // Current step highlight card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E283D),
                  const Color(0xFF151C2C),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2979FF).withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                // Move notation badge
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2979FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2979FF), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      isDone ? '✓' : currentStep.move,
                      style: TextStyle(
                        color: isDone ? const Color(0xFF00E676) : Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Phase title & description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentStep.phaseTitle,
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentStep.explanation,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // AI explain icon
                IconButton(
                  icon: const Icon(Icons.auto_awesome, color: Color(0xFFFFD600), size: 22),
                  tooltip: 'Hỏi AI giải thích bước này',
                  onPressed: () => _explainCurrentMove(currentStep),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Playback Control bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Previous button
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 30),
                  tooltip: 'Bước trước',
                  onPressed: widget.currentStepIndex > 0 ? _goPrevious : null,
                ),

                // Play / Pause auto
                GestureDetector(
                  onTap: _toggleAutoPlay,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E676).withOpacity(0.4),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.black,
                      size: 34,
                    ),
                  ),
                ),

                // Next button
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 30),
                  tooltip: 'Bước tiếp theo',
                  onPressed: widget.currentStepIndex < widget.steps.length ? _goNext : null,
                ),
              ],
            ),
          ),

          // Speed slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Text('Tốc độ tự động:', style: TextStyle(color: Colors.white54, fontSize: 11)),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: _speedSeconds,
                      min: 0.4,
                      max: 2.0,
                      divisions: 8,
                      label: '${_speedSeconds.toStringAsFixed(1)}s',
                      activeColor: const Color(0xFF2979FF),
                      inactiveColor: Colors.white12,
                      onChanged: (val) {
                        setState(() => _speedSeconds = val);
                        if (_isPlaying) {
                          _stopAutoPlay();
                          _startAutoPlay();
                        }
                      },
                    ),
                  ),
                ),
                Text('${_speedSeconds.toStringAsFixed(1)}s', style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
