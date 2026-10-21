import 'dart:collection';
import 'package:flutter/material.dart';
import '../models/cube_constants.dart';
import '../models/rubik_cube.dart';
import '../services/gemini_service.dart';
import '../services/rubik_solver.dart';
import '../widgets/rubik_3d_canvas.dart';
import 'ai_assistant_dialog.dart';
import 'color_scanner_screen.dart';
import 'solver_guide_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late RubikCube _cube;
  final GeminiService _geminiService = GeminiService();
  final List<String> _scrambleHistory = [];
  final Queue<String> _moveQueue = Queue<String>();

  late AnimationController _animController;
  String? _currentAnimatingMove;

  @override
  void initState() {
    super.initState();
    _cube = RubikCube();
    _geminiService.init();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _animController.addListener(() {
      setState(() {});
    });

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_currentAnimatingMove != null) {
          _cube.applyMove(_currentAnimatingMove!);
          _currentAnimatingMove = null;
        }
        _animController.reset();

        // Process next queued move if any
        if (_moveQueue.isNotEmpty) {
          final nextMove = _moveQueue.removeFirst();
          _triggerAnimatedMove(nextMove);
        } else {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _triggerAnimatedMove(String move) {
    if (_animController.isAnimating) {
      _moveQueue.add(move);
      return;
    }

    setState(() {
      _currentAnimatingMove = move;
    });
    _animController.forward(from: 0.0);
  }

  void _onManualMove(String move) {
    _scrambleHistory.add(move);
    _triggerAnimatedMove(move);
  }

  void _scrambleCube() {
    _moveQueue.clear();
    _scrambleHistory.clear();
    final moves = _cube.scramble(20);
    _scrambleHistory.addAll(moves);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xáo trộn 20 bước: ${moves.take(6).join(" ")}...'),
        backgroundColor: const Color(0xFF1E283D),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resetCube() {
    _moveQueue.clear();
    _scrambleHistory.clear();
    setState(() {
      _cube.reset();
    });
  }

  void _openSolverSheet() {
    final steps = RubikSolver.solve(_cube, scrambleHistory: _scrambleHistory);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SolverGuideSheet(
        steps: steps,
        currentStepIndex: 0,
        geminiService: _geminiService,
        onExecuteMove: (move) {
          _triggerAnimatedMove(move);
        },
        onStepSelected: (newIdx) {
          setState(() {});
        },
      ),
    );
  }

  void _openColorScanner() async {
    final updatedCube = await Navigator.of(context).push<RubikCube>(
      MaterialPageRoute(
        builder: (_) => ColorScannerScreen(initialCube: _cube),
      ),
    );

    if (updatedCube != null) {
      _scrambleHistory.clear();
      setState(() {
        _cube = updatedCube;
      });
      _openSolverSheet();
    }
  }

  void _openAiAssistant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AiAssistantDialog(
        geminiService: _geminiService,
        currentCube: _cube,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSolved = _cube.isSolved();

    return Scaffold(
      backgroundColor: const Color(0xFF090C14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1320),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E676), Color(0xFF2979FF)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.view_in_ar, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Rubik AI 3D',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          // Solved Status Chip
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isSolved ? const Color(0xFF00E676).withOpacity(0.15) : Colors.orangeAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSolved ? const Color(0xFF00E676) : Colors.orangeAccent,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSolved ? Icons.check_circle : Icons.shuffle,
                  color: isSolved ? const Color(0xFF00E676) : Colors.orangeAccent,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  isSolved ? 'HOÀN THÀNH' : 'ĐANG XÁO',
                  style: TextStyle(
                    color: isSolved ? const Color(0xFF00E676) : Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            tooltip: 'Đặt lại Rubik',
            onPressed: _resetCube,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 3D Canvas
            Expanded(
              flex: 11,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Rubik3DCanvas(
                  cube: _cube,
                  animatingMove: _currentAnimatingMove,
                  animationProgress: _animController.value,
                  onMoveTriggered: _onManualMove,
                ),
              ),
            ),

            // Quick Manual Rotation Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMoveButton('U'),
                      _buildMoveButton("U'"),
                      _buildMoveButton('D'),
                      _buildMoveButton("D'"),
                      _buildMoveButton('L'),
                      _buildMoveButton("L'"),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMoveButton('R'),
                      _buildMoveButton("R'"),
                      _buildMoveButton('F'),
                      _buildMoveButton("F'"),
                      _buildMoveButton('B'),
                      _buildMoveButton("B'"),
                    ],
                  ),
                ],
              ),
            ),

            // Main Action Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: const BoxDecoration(
                color: Color(0xFF0F1422),
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Scramble Button
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withOpacity(0.2)),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: BorderRadius.circular(14),
                          ),
                          icon: const Icon(Icons.shuffle, size: 18, color: Colors.orangeAccent),
                          label: const Text('XÁO TRỘN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          onPressed: _scrambleCube,
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Solve Button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E676),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: BorderRadius.circular(14),
                            elevation: 4,
                          ),
                          icon: const Icon(Icons.psychology, size: 20, color: Colors.black),
                          label: const Text('GIẢI BẰNG AI', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                          onPressed: _openSolverSheet,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      // Color Scanner Button
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E283D),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: BorderRadius.circular(12),
                          ),
                          icon: const Icon(Icons.palette_outlined, size: 18, color: Color(0xFF2979FF)),
                          label: const Text('QUÉT / NHẬP MÀU', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: _openColorScanner,
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Gemini AI Coach Button
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E283D),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: BorderRadius.circular(12),
                          ),
                          icon: const Icon(Icons.auto_awesome, size: 18, color: Color(0xFFFFD600)),
                          label: const Text('GEMINI AI COACH', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: _openAiAssistant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoveButton(String move) {
    return SizedBox(
      width: 48,
      height: 38,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF151C2C),
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          elevation: 2,
          shape: BorderRadius.circular(8),
          side: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        onPressed: () => _onManualMove(move),
        child: Text(
          move,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: move.length > 1 ? 12 : 14,
            color: move.contains("'") ? Colors.cyanAccent : Colors.white,
          ),
        ),
      ),
    );
  }
}
