import 'dart:math';
import 'cube_constants.dart';

class RubikCube {
  Map<CubeFace, List<CubeColor>> faces;

  RubikCube({Map<CubeFace, List<CubeColor>>? initialFaces})
      : faces = initialFaces ?? _createSolvedFaces();

  static Map<CubeFace, List<CubeColor>> _createSolvedFaces() {
    return {
      CubeFace.up: List.filled(9, CubeColor.white),
      CubeFace.down: List.filled(9, CubeColor.yellow),
      CubeFace.front: List.filled(9, CubeColor.green),
      CubeFace.back: List.filled(9, CubeColor.blue),
      CubeFace.left: List.filled(9, CubeColor.orange),
      CubeFace.right: List.filled(9, CubeColor.red),
    };
  }

  RubikCube clone() {
    final Map<CubeFace, List<CubeColor>> copy = {};
    faces.forEach((face, colors) {
      copy[face] = List.from(colors);
    });
    return RubikCube(initialFaces: copy);
  }

  void reset() {
    faces = _createSolvedFaces();
  }

  bool isSolved() {
    for (final face in CubeFace.values) {
      final centerColor = faces[face]![4];
      for (final color in faces[face]!) {
        if (color != centerColor) return false;
      }
    }
    return true;
  }

  Map<CubeColor, int> getColorCounts() {
    final Map<CubeColor, int> counts = {
      for (final c in CubeColor.values) c: 0,
    };
    for (final faceList in faces.values) {
      for (final color in faceList) {
        counts[color] = (counts[color] ?? 0) + 1;
      }
    }
    return counts;
  }

  bool isValidState() {
    final counts = getColorCounts();
    for (final count in counts.values) {
      if (count != 9) return false;
    }
    return true;
  }

  void applyMove(String move) {
    switch (move) {
      case 'U':
        _moveU();
        break;
      case "U'":
        _moveU();
        _moveU();
        _moveU();
        break;
      case 'U2':
        _moveU();
        _moveU();
        break;

      case 'D':
        _moveD();
        break;
      case "D'":
        _moveD();
        _moveD();
        _moveD();
        break;
      case 'D2':
        _moveD();
        _moveD();
        break;

      case 'F':
        _moveF();
        break;
      case "F'":
        _moveF();
        _moveF();
        _moveF();
        break;
      case 'F2':
        _moveF();
        _moveF();
        break;

      case 'B':
        _moveB();
        break;
      case "B'":
        _moveB();
        _moveB();
        _moveB();
        break;
      case 'B2':
        _moveB();
        _moveB();
        break;

      case 'L':
        _moveL();
        break;
      case "L'":
        _moveL();
        _moveL();
        _moveL();
        break;
      case 'L2':
        _moveL();
        _moveL();
        break;

      case 'R':
        _moveR();
        break;
      case "R'":
        _moveR();
        _moveR();
        _moveR();
        break;
      case 'R2':
        _moveR();
        _moveR();
        break;
    }
  }

  void applyMoves(List<String> moves) {
    for (final m in moves) {
      applyMove(m);
    }
  }

  static List<CubeColor> _rotateFaceCW(List<CubeColor> f) {
    return [
      f[6], f[3], f[0],
      f[7], f[4], f[1],
      f[8], f[5], f[2],
    ];
  }

  void _moveU() {
    faces[CubeFace.up] = _rotateFaceCW(faces[CubeFace.up]!);
    final temp0 = faces[CubeFace.front]![0];
    final temp1 = faces[CubeFace.front]![1];
    final temp2 = faces[CubeFace.front]![2];

    faces[CubeFace.front]![0] = faces[CubeFace.right]![0];
    faces[CubeFace.front]![1] = faces[CubeFace.right]![1];
    faces[CubeFace.front]![2] = faces[CubeFace.right]![2];

    faces[CubeFace.right]![0] = faces[CubeFace.back]![0];
    faces[CubeFace.right]![1] = faces[CubeFace.back]![1];
    faces[CubeFace.right]![2] = faces[CubeFace.back]![2];

    faces[CubeFace.back]![0] = faces[CubeFace.left]![0];
    faces[CubeFace.back]![1] = faces[CubeFace.left]![1];
    faces[CubeFace.back]![2] = faces[CubeFace.left]![2];

    faces[CubeFace.left]![0] = temp0;
    faces[CubeFace.left]![1] = temp1;
    faces[CubeFace.left]![2] = temp2;
  }

  void _moveD() {
    faces[CubeFace.down] = _rotateFaceCW(faces[CubeFace.down]!);
    final temp6 = faces[CubeFace.front]![6];
    final temp7 = faces[CubeFace.front]![7];
    final temp8 = faces[CubeFace.front]![8];

    faces[CubeFace.front]![6] = faces[CubeFace.left]![6];
    faces[CubeFace.front]![7] = faces[CubeFace.left]![7];
    faces[CubeFace.front]![8] = faces[CubeFace.left]![8];

    faces[CubeFace.left]![6] = faces[CubeFace.back]![6];
    faces[CubeFace.left]![7] = faces[CubeFace.back]![7];
    faces[CubeFace.left]![8] = faces[CubeFace.back]![8];

    faces[CubeFace.back]![6] = faces[CubeFace.right]![6];
    faces[CubeFace.back]![7] = faces[CubeFace.right]![7];
    faces[CubeFace.back]![8] = faces[CubeFace.right]![8];

    faces[CubeFace.right]![6] = temp6;
    faces[CubeFace.right]![7] = temp7;
    faces[CubeFace.right]![8] = temp8;
  }

  void _moveF() {
    faces[CubeFace.front] = _rotateFaceCW(faces[CubeFace.front]!);
    final u6 = faces[CubeFace.up]![6];
    final u7 = faces[CubeFace.up]![7];
    final u8 = faces[CubeFace.up]![8];

    faces[CubeFace.up]![6] = faces[CubeFace.left]![8];
    faces[CubeFace.up]![7] = faces[CubeFace.left]![5];
    faces[CubeFace.up]![8] = faces[CubeFace.left]![2];

    faces[CubeFace.left]![2] = faces[CubeFace.down]![0];
    faces[CubeFace.left]![5] = faces[CubeFace.down]![1];
    faces[CubeFace.left]![8] = faces[CubeFace.down]![2];

    faces[CubeFace.down]![0] = faces[CubeFace.right]![6];
    faces[CubeFace.down]![1] = faces[CubeFace.right]![3];
    faces[CubeFace.down]![2] = faces[CubeFace.right]![0];

    faces[CubeFace.right]![0] = u6;
    faces[CubeFace.right]![3] = u7;
    faces[CubeFace.right]![6] = u8;
  }

  void _moveB() {
    faces[CubeFace.back] = _rotateFaceCW(faces[CubeFace.back]!);
    final u0 = faces[CubeFace.up]![0];
    final u1 = faces[CubeFace.up]![1];
    final u2 = faces[CubeFace.up]![2];

    faces[CubeFace.up]![0] = faces[CubeFace.right]![2];
    faces[CubeFace.up]![1] = faces[CubeFace.right]![5];
    faces[CubeFace.up]![2] = faces[CubeFace.right]![8];

    faces[CubeFace.right]![2] = faces[CubeFace.down]![8];
    faces[CubeFace.right]![5] = faces[CubeFace.down]![7];
    faces[CubeFace.right]![8] = faces[CubeFace.down]![6];

    faces[CubeFace.down]![6] = faces[CubeFace.left]![0];
    faces[CubeFace.down]![7] = faces[CubeFace.left]![3];
    faces[CubeFace.down]![8] = faces[CubeFace.left]![6];

    faces[CubeFace.left]![0] = u2;
    faces[CubeFace.left]![3] = u1;
    faces[CubeFace.left]![6] = u0;
  }

  void _moveL() {
    faces[CubeFace.left] = _rotateFaceCW(faces[CubeFace.left]!);
    final u0 = faces[CubeFace.up]![0];
    final u3 = faces[CubeFace.up]![3];
    final u6 = faces[CubeFace.up]![6];

    faces[CubeFace.up]![0] = faces[CubeFace.back]![8];
    faces[CubeFace.up]![3] = faces[CubeFace.back]![5];
    faces[CubeFace.up]![6] = faces[CubeFace.back]![2];

    faces[CubeFace.back]![2] = faces[CubeFace.down]![6];
    faces[CubeFace.back]![5] = faces[CubeFace.down]![3];
    faces[CubeFace.back]![8] = faces[CubeFace.down]![0];

    faces[CubeFace.down]![0] = faces[CubeFace.front]![0];
    faces[CubeFace.down]![3] = faces[CubeFace.front]![3];
    faces[CubeFace.down]![6] = faces[CubeFace.front]![6];

    faces[CubeFace.front]![0] = u0;
    faces[CubeFace.front]![3] = u3;
    faces[CubeFace.front]![6] = u6;
  }

  void _moveR() {
    faces[CubeFace.right] = _rotateFaceCW(faces[CubeFace.right]!);
    final u2 = faces[CubeFace.up]![2];
    final u5 = faces[CubeFace.up]![5];
    final u8 = faces[CubeFace.up]![8];

    faces[CubeFace.up]![2] = faces[CubeFace.front]![2];
    faces[CubeFace.up]![5] = faces[CubeFace.front]![5];
    faces[CubeFace.up]![8] = faces[CubeFace.front]![8];

    faces[CubeFace.front]![2] = faces[CubeFace.down]![2];
    faces[CubeFace.front]![5] = faces[CubeFace.down]![5];
    faces[CubeFace.front]![8] = faces[CubeFace.down]![8];

    faces[CubeFace.down]![2] = faces[CubeFace.back]![6];
    faces[CubeFace.down]![5] = faces[CubeFace.back]![3];
    faces[CubeFace.down]![8] = faces[CubeFace.back]![0];

    faces[CubeFace.back]![0] = u8;
    faces[CubeFace.back]![3] = u5;
    faces[CubeFace.back]![6] = u2;
  }

  List<String> scramble([int moveCount = 20]) {
    const allMoves = ['U', "U'", 'U2', 'D', "D'", 'D2', 'F', "F'", 'F2', 'B', "B'", 'B2', 'L', "L'", 'L2', 'R', "R'", 'R2'];
    final random = Random();
    final List<String> generated = [];
    String lastBase = '';

    while (generated.length < moveCount) {
      final move = allMoves[random.nextInt(allMoves.length)];
      final base = move[0];
      if (base == lastBase) continue;
      lastBase = base;
      generated.add(move);
      applyMove(move);
    }
    return generated;
  }

  String toCubeString() {
    final StringBuffer sb = StringBuffer();
    for (final face in [CubeFace.up, CubeFace.right, CubeFace.front, CubeFace.down, CubeFace.left, CubeFace.back]) {
      for (final color in faces[face]!) {
        sb.write(color.name[0].toUpperCase());
      }
    }
    return sb.toString();
  }
}
