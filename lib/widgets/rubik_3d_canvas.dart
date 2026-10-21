import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/cube_constants.dart';
import '../models/rubik_cube.dart';

class Rubik3DCanvas extends StatefulWidget {
  final RubikCube cube;
  final String? animatingMove;
  final double animationProgress; // 0.0 to 1.0
  final Function(String move)? onMoveTriggered;

  const Rubik3DCanvas({
    super.key,
    required this.cube,
    this.animatingMove,
    this.animationProgress = 0.0,
    this.onMoveTriggered,
  });

  @override
  State<Rubik3DCanvas> createState() => Rubik3DCanvasState();
}

class Rubik3DCanvasState extends State<Rubik3DCanvas> {
  double _rotX = -0.45; // Pitch
  double _rotY = 0.55;  // Yaw
  Offset? _lastPanPos;

  void resetCamera() {
    setState(() {
      _rotX = -0.45;
      _rotY = 0.55;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        _lastPanPos = details.localPosition;
      },
      onPanUpdate: (details) {
        if (_lastPanPos == null) return;
        final delta = details.localPosition - _lastPanPos!;
        _lastPanPos = details.localPosition;

        setState(() {
          _rotY += delta.dx * 0.01;
          _rotX = (_rotX - delta.dy * 0.01).clamp(-math.pi / 2.2, math.pi / 2.2);
        });
      },
      onPanEnd: (_) => _lastPanPos = null,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.1),
            radius: 1.1,
            colors: [
              const Color(0xFF1E2640),
              const Color(0xFF0F1322),
              const Color(0xFF070913),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              CustomPaint(
                painter: _CubePainter(
                  cube: widget.cube,
                  rotX: _rotX,
                  rotY: _rotY,
                  animatingMove: widget.animatingMove,
                  progress: widget.animationProgress,
                ),
                child: const SizedBox.expand(),
              ),

              // Reset camera orientation button
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.screen_rotation_alt, color: Colors.white70, size: 20),
                    tooltip: 'Đặt lại góc nhìn 3D',
                    onPressed: resetCamera,
                  ),
                ),
              ),

              // Active move indicator overlay
              if (widget.animatingMove != null)
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withOpacity(0.2),
                      border: Border.all(color: const Color(0xFF00E676)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Đang xoay: ${widget.animatingMove}',
                          style: const TextStyle(
                            color: Color(0xFF00E676),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Hint at bottom
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Vuốt để xoay tự do 360°',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CubePainter extends CustomPainter {
  final RubikCube cube;
  final double rotX;
  final double rotY;
  final String? animatingMove;
  final double progress;

  _CubePainter({
    required this.cube,
    required this.rotX,
    required this.rotY,
    this.animatingMove,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final cubieSize = math.min(size.width, size.height) * 0.165;
    const spacing = 1.05;

    // Determine animating slice and rotation angle
    int? activeAxis; // 0=X, 1=Y, 2=Z
    int? activeLayer; // -1, 0, or 1
    double animAngle = 0;

    if (animatingMove != null && progress > 0) {
      final m = animatingMove!;
      final base = m[0];
      final isDouble = m.endsWith('2');
      final isPrime = m.endsWith("'");

      double targetAngle = math.pi / 2;
      if (isDouble) targetAngle = math.pi;
      if (isPrime) targetAngle = -targetAngle;

      final currentAngle = targetAngle * progress;

      switch (base) {
        case 'R':
          activeAxis = 0;
          activeLayer = 1;
          animAngle = -currentAngle;
          break;
        case 'L':
          activeAxis = 0;
          activeLayer = -1;
          animAngle = currentAngle;
          break;
        case 'U':
          activeAxis = 1;
          activeLayer = -1;
          animAngle = currentAngle;
          break;
        case 'D':
          activeAxis = 1;
          activeLayer = 1;
          animAngle = -currentAngle;
          break;
        case 'F':
          activeAxis = 2;
          activeLayer = 1;
          animAngle = -currentAngle;
          break;
        case 'B':
          activeAxis = 2;
          activeLayer = -1;
          animAngle = currentAngle;
          break;
      }
    }

    final List<_FacePolygon> polygons = [];

    // Loop through 27 cubies
    for (int x = -1; x <= 1; x++) {
      for (int y = -1; y <= 1; y++) {
        for (int z = -1; z <= 1; z++) {
          if (x == 0 && y == 0 && z == 0) continue; // Skip invisible internal core

          final bool isAnimating = (activeAxis == 0 && x == activeLayer) ||
              (activeAxis == 1 && y == activeLayer) ||
              (activeAxis == 2 && z == activeLayer);

          final sliceAngle = isAnimating ? animAngle : 0.0;
          final sliceAxis = activeAxis;

          // Check all 6 faces for stickers
          if (y == -1) {
            // Up face (White)
            final stickerIndex = (z + 1) * 3 + (x + 1);
            final color = CubeConstants.colorMap[cube.faces[CubeFace.up]![stickerIndex]]!;
            _addFacePolygon(polygons, x, y, z, 0, -1, 0, color, cubieSize, spacing, sliceAxis, sliceAngle);
          }
          if (y == 1) {
            // Down face (Yellow)
            final stickerIndex = (1 - z) * 3 + (x + 1);
            final color = CubeConstants.colorMap[cube.faces[CubeFace.down]![stickerIndex]]!;
            _addFacePolygon(polygons, x, y, z, 0, 1, 0, color, cubieSize, spacing, sliceAxis, sliceAngle);
          }
          if (z == 1) {
            // Front face (Green)
            final stickerIndex = (y + 1) * 3 + (x + 1);
            final color = CubeConstants.colorMap[cube.faces[CubeFace.front]![stickerIndex]]!;
            _addFacePolygon(polygons, x, y, z, 0, 0, 1, color, cubieSize, spacing, sliceAxis, sliceAngle);
          }
          if (z == -1) {
            // Back face (Blue)
            final stickerIndex = (y + 1) * 3 + (1 - x);
            final color = CubeConstants.colorMap[cube.faces[CubeFace.back]![stickerIndex]]!;
            _addFacePolygon(polygons, x, y, z, 0, 0, -1, color, cubieSize, spacing, sliceAxis, sliceAngle);
          }
          if (x == -1) {
            // Left face (Orange)
            final stickerIndex = (y + 1) * 3 + (z + 1);
            final color = CubeConstants.colorMap[cube.faces[CubeFace.left]![stickerIndex]]!;
            _addFacePolygon(polygons, x, y, z, -1, 0, 0, color, cubieSize, spacing, sliceAxis, sliceAngle);
          }
          if (x == 1) {
            // Right face (Red)
            final stickerIndex = (y + 1) * 3 + (1 - z);
            final color = CubeConstants.colorMap[cube.faces[CubeFace.right]![stickerIndex]]!;
            _addFacePolygon(polygons, x, y, z, 1, 0, 0, color, cubieSize, spacing, sliceAxis, sliceAngle);
          }
        }
      }
    }

    // Sort polygons by depth (deepest Z first)
    polygons.sort((a, b) => b.averageZ.compareTo(a.averageZ));

    // Paint visible polygons
    final plasticPaint = Paint()
      ..color = const Color(0xFF12141A)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF090A0E)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (final poly in polygons) {
      if (!poly.isFacingCamera) continue; // Backface culling

      // Project vertices to 2D screen
      final points = poly.vertices.map((v) => _project(v, center)).toList();

      // Draw plastic cubie face
      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      path.close();
      canvas.drawPath(path, plasticPaint);
      canvas.drawPath(path, borderPaint);

      // Inset sticker points
      final insetPoints = _insetQuad(points, 0.88);
      final stickerPath = Path()..moveTo(insetPoints[0].dx, insetPoints[0].dy);
      for (int i = 1; i < insetPoints.length; i++) {
        stickerPath.lineTo(insetPoints[i].dx, insetPoints[i].dy);
      }
      stickerPath.close();

      // Lighting calculation based on surface normal
      final shade = math.max(0.65, math.min(1.15, 0.75 + poly.normalZ * 0.45));
      final shadedColor = Color.fromARGB(
        255,
        (poly.color.red * shade).clamp(0, 255).toInt(),
        (poly.color.green * shade).clamp(0, 255).toInt(),
        (poly.color.blue * shade).clamp(0, 255).toInt(),
      );

      final stickerPaint = Paint()
        ..color = shadedColor
        ..style = PaintingStyle.fill;

      canvas.drawPath(stickerPath, stickerPaint);

      // Specular highlight outline
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      canvas.drawPath(stickerPath, highlightPaint);
    }
  }

  void _addFacePolygon(
    List<_FacePolygon> list,
    int cx, int cy, int cz,
    int nx, int ny, int nz,
    Color color,
    double size,
    double spacing,
    int? sliceAxis,
    double sliceAngle,
  ) {
    final half = size / 2;
    final ox = cx * size * spacing;
    final oy = cy * size * spacing;
    final oz = cz * size * spacing;

    List<_Vec3> localVertices;

    if (nx != 0) {
      // X face (+-1)
      final xVal = ox + nx * half;
      localVertices = [
        _Vec3(xVal, oy - half, oz - half),
        _Vec3(xVal, oy - half, oz + half),
        _Vec3(xVal, oy + half, oz + half),
        _Vec3(xVal, oy + half, oz - half),
      ];
      if (nx < 0) localVertices = localVertices.reversed.toList();
    } else if (ny != 0) {
      // Y face (+-1)
      final yVal = oy + ny * half;
      localVertices = [
        _Vec3(ox - half, yVal, oz - half),
        _Vec3(ox + half, yVal, oz - half),
        _Vec3(ox + half, yVal, oz + half),
        _Vec3(ox - half, yVal, oz + half),
      ];
      if (ny > 0) localVertices = localVertices.reversed.toList();
    } else {
      // Z face (+-1)
      final zVal = oz + nz * half;
      localVertices = [
        _Vec3(ox - half, oy - half, zVal),
        _Vec3(ox + half, oy - half, zVal),
        _Vec3(ox + half, oy + half, zVal),
        _Vec3(ox - half, oy + half, zVal),
      ];
      if (nz < 0) localVertices = localVertices.reversed.toList();
    }

    _Vec3 norm = _Vec3(nx.toDouble(), ny.toDouble(), nz.toDouble());

    // Apply slice animation rotation if animating
    if (sliceAxis != null && sliceAngle != 0) {
      localVertices = localVertices.map((v) => _rotateAroundAxis(v, sliceAxis, sliceAngle)).toList();
      norm = _rotateAroundAxis(norm, sliceAxis, sliceAngle);
    }

    // Apply camera rotation
    final worldVertices = localVertices.map((v) => _rotateCamera(v, rotX, rotY)).toList();
    final worldNorm = _rotateCamera(norm, rotX, rotY);

    double avgZ = 0;
    for (final v in worldVertices) {
      avgZ += v.z;
    }
    avgZ /= worldVertices.length;

    // Normal dot (0, 0, -1) looking at camera. Facing camera if worldNorm.z < 0 (in right-hand view)
    final isFacing = worldNorm.z < 0.05;

    list.add(_FacePolygon(
      vertices: worldVertices,
      averageZ: avgZ,
      color: color,
      isFacingCamera: isFacing,
      normalZ: -worldNorm.z,
    ));
  }

  static _Vec3 _rotateAroundAxis(_Vec3 p, int axis, double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    if (axis == 0) {
      // X axis
      return _Vec3(p.x, p.y * cosA - p.z * sinA, p.y * sinA + p.z * cosA);
    } else if (axis == 1) {
      // Y axis
      return _Vec3(p.x * cosA + p.z * sinA, p.y, -p.x * sinA + p.z * cosA);
    } else {
      // Z axis
      return _Vec3(p.x * cosA - p.y * sinA, p.x * sinA + p.y * cosA, p.z);
    }
  }

  static _Vec3 _rotateCamera(_Vec3 p, double rx, double ry) {
    // Rotate Yaw (around Y axis)
    final cosY = math.cos(ry);
    final sinY = math.sin(ry);
    final x1 = p.x * cosY + p.z * sinY;
    final y1 = p.y;
    final z1 = -p.x * sinY + p.z * cosY;

    // Rotate Pitch (around X axis)
    final cosX = math.cos(rx);
    final sinX = math.sin(rx);
    final x2 = x1;
    final y2 = y1 * cosX - z1 * sinX;
    final z2 = y1 * sinX + z1 * cosX;

    return _Vec3(x2, y2, z2);
  }

  Offset _project(_Vec3 v, Offset center) {
    const fov = 650.0;
    final scale = fov / (fov + v.z);
    return Offset(center.dx + v.x * scale, center.dy + v.y * scale);
  }

  List<Offset> _insetQuad(List<Offset> pts, double factor) {
    final cx = (pts[0].dx + pts[1].dx + pts[2].dx + pts[3].dx) / 4;
    final cy = (pts[0].dy + pts[1].dy + pts[2].dy + pts[3].dy) / 4;
    return pts.map((p) {
      return Offset(cx + (p.dx - cx) * factor, cy + (p.dy - cy) * factor);
    }).toList();
  }

  @override
  bool shouldRepaint(covariant _CubePainter oldDelegate) {
    return oldDelegate.rotX != rotX ||
        oldDelegate.rotY != rotY ||
        oldDelegate.progress != progress ||
        oldDelegate.animatingMove != animatingMove ||
        oldDelegate.cube != cube;
  }
}

class _Vec3 {
  final double x, y, z;
  const _Vec3(this.x, this.y, this.z);
}

class _FacePolygon {
  final List<_Vec3> vertices;
  final double averageZ;
  final Color color;
  final bool isFacingCamera;
  final double normalZ;

  _FacePolygon({
    required this.vertices,
    required this.averageZ,
    required this.color,
    required this.isFacingCamera,
    required this.normalZ,
  });
}
