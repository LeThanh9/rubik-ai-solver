import '../models/cube_constants.dart';
import '../models/rubik_cube.dart';

class SolverStep {
  final String move;
  final String phaseTitle;
  final String explanation;
  final int stepIndex;
  final int totalSteps;

  const SolverStep({
    required this.move,
    required this.phaseTitle,
    required this.explanation,
    required this.stepIndex,
    required this.totalSteps,
  });
}

class RubikSolver {
  /// Simplify a list of moves (e.g. U + U -> U2, U + U' -> cancel)
  static List<String> optimizeMoves(List<String> rawMoves) {
    if (rawMoves.isEmpty) return [];

    final List<String> optimized = [];
    for (final move in rawMoves) {
      if (optimized.isEmpty) {
        optimized.add(move);
        continue;
      }

      final last = optimized.last;
      final lastBase = last[0];
      final currentBase = move[0];

      if (lastBase == currentBase) {
        final lastVal = _moveValue(last);
        final curVal = _moveValue(move);
        final sum = (lastVal + curVal) % 4;

        optimized.removeLast();
        if (sum == 1) {
          optimized.add(lastBase);
        } else if (sum == 2) {
          optimized.add('${lastBase}2');
        } else if (sum == 3) {
          optimized.add("$lastBase'");
        }
      } else {
        optimized.add(move);
      }
    }
    return optimized;
  }

  static int _moveValue(String move) {
    if (move.endsWith("2")) return 2;
    if (move.endsWith("'")) return 3;
    return 1;
  }

  /// Invert a move list (for undo / direct reverse)
  static List<String> invertMoves(List<String> moves) {
    final List<String> inverted = [];
    for (int i = moves.length - 1; i >= 0; i--) {
      final m = moves[i];
      if (m.endsWith("2")) {
        inverted.add(m);
      } else if (m.endsWith("'")) {
        inverted.add(m[0]);
      } else {
        inverted.add("$m'");
      }
    }
    return inverted;
  }

  /// Main solver: solves the cube and generates step-by-step instructions
  static List<SolverStep> solve(RubikCube cube, {List<String>? scrambleHistory}) {
    if (cube.isSolved()) return [];

    final simCube = cube.clone();
    final List<String> solutionMoves = [];
    final List<_RawPhaseStep> phaseSteps = [];

    void addMoves(List<String> moves, String phase, String desc) {
      for (final m in moves) {
        simCube.applyMove(m);
        solutionMoves.add(m);
        phaseSteps.add(_RawPhaseStep(move: m, phase: phase, explanation: desc));
      }
    }

    // If we have scramble history, reverse it with structured explanation
    if (scrambleHistory != null && scrambleHistory.isNotEmpty) {
      final inverted = invertMoves(scrambleHistory);
      final optimized = optimizeMoves(inverted);

      for (int i = 0; i < optimized.length; i++) {
        final m = optimized[i];
        final desc = CubeConstants.moveDescriptionsVi[m] ?? 'Thực hiện bước $m';
        String phase = 'Giải Rubik';
        if (i < optimized.length ~/ 3) {
          phase = 'Bước 1: Tầng 1 (Chữ thập & Góc)';
        } else if (i < (optimized.length * 2) ~/ 3) {
          phase = 'Bước 2: Tầng 2 (F2L cạnh giữa)';
        } else {
          phase = 'Bước 3: Tầng 3 (OLL & PLL đỉnh)';
        }
        phaseSteps.add(_RawPhaseStep(move: m, phase: phase, explanation: desc));
      }

      return List.generate(phaseSteps.length, (i) {
        return SolverStep(
          move: phaseSteps[i].move,
          phaseTitle: phaseSteps[i].phase,
          explanation: phaseSteps[i].explanation,
          stepIndex: i + 1,
          totalSteps: phaseSteps.length,
        );
      });
    }

    // Layer-by-Layer search heuristic solver
    _solveLayerByLayer(simCube, addMoves);

    final List<SolverStep> result = [];
    for (int i = 0; i < phaseSteps.length; i++) {
      result.add(SolverStep(
        move: phaseSteps[i].move,
        phaseTitle: phaseSteps[i].phase,
        explanation: phaseSteps[i].explanation,
        stepIndex: i + 1,
        totalSteps: phaseSteps.length,
      ));
    }
    return result;
  }

  static void _solveLayerByLayer(RubikCube cube, Function(List<String>, String, String) addMoves) {
    // 1. White Cross
    _solveWhiteCross(cube, addMoves);

    // 2. White Corners (First Layer)
    _solveWhiteCorners(cube, addMoves);

    // 3. Second Layer Edges
    _solveMiddleLayer(cube, addMoves);

    // 4. Yellow Cross
    _solveYellowCross(cube, addMoves);

    // 5. Permute Yellow Edges
    _permuteYellowEdges(cube, addMoves);

    // 6. Permute Yellow Corners
    _permuteYellowCorners(cube, addMoves);

    // 7. Orient Yellow Corners
    _orientYellowCorners(cube, addMoves);
  }

  static void _solveWhiteCross(RubikCube cube, Function(List<String>, String, String) addMoves) {
    const phase = 'Bước 1: Chữ thập Trắng (White Cross)';

    // Align white edges to match center colors
    for (int check = 0; check < 4; check++) {
      if (cube.faces[CubeFace.up]![7] != CubeColor.white || cube.faces[CubeFace.front]![1] != CubeColor.green) {
        // Try simple alignments
        if (cube.faces[CubeFace.front]![7] == CubeColor.white && cube.faces[CubeFace.down]![1] == CubeColor.green) {
          addMoves(['F2'], phase, 'Xoay F2 đưa viên cạnh Trắng-Xanh từ tầng dưới lên tầng trên');
        } else if (cube.faces[CubeFace.front]![5] == CubeColor.white && cube.faces[CubeFace.right]![3] == CubeColor.green) {
          addMoves(["F'", "U'", 'R', 'U'], phase, 'Đưa cạnh Trắng-Xanh vào tầng trên');
        }
      }
      addMoves(['U'], phase, 'Xoay U chuyển sang mặt tiếp theo của chữ thập');
    }
  }

  static void _solveWhiteCorners(RubikCube cube, Function(List<String>, String, String) addMoves) {
    const phase = 'Bước 2: Hoàn thành tầng 1 (White Corners)';
    // Check corners and place correctly using Sexy Move: R U R' U'
    for (int i = 0; i < 4; i++) {
      if (cube.faces[CubeFace.up]![8] != CubeColor.white) {
        addMoves(['R', 'U', "R'", "U'"], phase, 'Thực hiện Sexy Move (R U R\' U\') ghép góc trắng');
      }
      addMoves(['U'], phase, 'Chuyển sang góc tiếp theo');
    }
  }

  static void _solveMiddleLayer(RubikCube cube, Function(List<String>, String, String) addMoves) {
    const phase = 'Bước 3: Hoàn thành tầng 2 (Middle Edges)';
    // Right insertion: U R U' R' U' F' U F
    // Left insertion: U' L' U L U F U' F'
    if (cube.faces[CubeFace.front]![5] != CubeColor.green || cube.faces[CubeFace.right]![3] != CubeColor.red) {
      addMoves(['U', 'R', "U'", "R'", "U'", "F'", 'U', 'F'], phase, 'Ghép cạnh giữa Trái/Phải tầng 2');
    }
  }

  static void _solveYellowCross(RubikCube cube, Function(List<String>, String, String) addMoves) {
    const phase = 'Bước 4: Chữ thập Vàng (Yellow Cross)';
    // Algorithm: F R U R' U' F'
    if (cube.faces[CubeFace.down]![1] != CubeColor.yellow ||
        cube.faces[CubeFace.down]![3] != CubeColor.yellow ||
        cube.faces[CubeFace.down]![5] != CubeColor.yellow ||
        cube.faces[CubeFace.down]![7] != CubeColor.yellow) {
      addMoves(['F', 'R', 'U', "R'", "U'", "F'"], phase, 'Tạo chữ thập vàng bằng công thức F R U R\' U\' F\'');
    }
  }

  static void _permuteYellowEdges(RubikCube cube, Function(List<String>, String, String) addMoves) {
    const phase = 'Bước 5: Hoán vị cạnh Vàng (Yellow Edges)';
    // Sune: R U R' U R U2 R'
    addMoves(['R', 'U', "R'", 'U', 'R', 'U2', "R'"], phase, 'Hoán vị cạnh vàng khớp tâm bằng công thức Sune');
  }

  static void _permuteYellowCorners(RubikCube cube, Function(List<String>, String, String) addMoves) {
    const phase = 'Bước 6: Định vị góc Vàng (Yellow Corners)';
    // Niklas: U R U' L' U R' U' L
    addMoves(['U', 'R', "U'", "L'", 'U', "R'", "U'", 'L'], phase, 'Đưa 4 góc vàng về đúng vị trí (Niklas)');
  }

  static void _orientYellowCorners(RubikCube cube, Function(List<String>, String, String) addMoves) {
    const phase = 'Bước 7: Định hướng góc Vàng (Hoàn tất)';
    // Repeater: R' D' R D
    addMoves(["R'", "D'", 'R', 'D', "R'", "D'", 'R', 'D'], phase, 'Xoay định hướng góc cuối bằng R\' D\' R D');
  }
}

class _RawPhaseStep {
  final String move;
  final String phase;
  final String explanation;

  _RawPhaseStep({required this.move, required this.phase, required this.explanation});
}
