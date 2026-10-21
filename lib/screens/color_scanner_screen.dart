import 'package:flutter/material.dart';
import '../models/cube_constants.dart';
import '../models/rubik_cube.dart';

class ColorScannerScreen extends StatefulWidget {
  final RubikCube initialCube;

  const ColorScannerScreen({super.key, required this.initialCube});

  @override
  State<ColorScannerScreen> createState() => _ColorScannerScreenState();
}

class _ColorScannerScreenState extends State<ColorScannerScreen> {
  late Map<CubeFace, List<CubeColor>> _faces;
  CubeColor _selectedColor = CubeColor.white;
  CubeFace _activeFace = CubeFace.front;

  @override
  void initState() {
    super.initState();
    _faces = {};
    widget.initialCube.faces.forEach((face, list) {
      _faces[face] = List.from(list);
    });
  }

  Map<CubeColor, int> _getColorCounts() {
    final Map<CubeColor, int> counts = {
      for (final c in CubeColor.values) c: 0,
    };
    for (final faceList in _faces.values) {
      for (final color in faceList) {
        counts[color] = (counts[color] ?? 0) + 1;
      }
    }
    return counts;
  }

  bool _isAllFacesComplete() {
    final counts = _getColorCounts();
    for (final count in counts.values) {
      if (count != 9) return false;
    }
    return true;
  }

  void _onStickerTap(CubeFace face, int index) {
    // Keep center stickers fixed to prevent impossible physical coordinates
    if (index == 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tâm mặt ${CubeConstants.faceNamesVi[face]} cố định theo quy chuẩn Rubik!',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: const Color(0xFF263238),
        ),
      );
      return;
    }

    setState(() {
      _faces[face]![index] = _selectedColor;
    });
  }

  void _resetToSolved() {
    setState(() {
      _faces = RubikCube().faces;
    });
  }

  @override
  Widget build(BuildContext context) {
    final counts = _getColorCounts();
    final isComplete = _isAllFacesComplete();

    return Scaffold(
      backgroundColor: const Color(0xFF0C0F17),
      appBar: AppBar(
        title: const Text('Nhập màu & Quét Rubik', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF141926),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            tooltip: 'Đặt lại đồng màu',
            onPressed: _resetToSolved,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF171E2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2979FF).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.touch_app, color: Color(0xFF2979FF), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Chọn màu ở thanh bên dưới, sau đó chạm vào từng ô để tô màu theo khối Rubik thật của bạn.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Color counts bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF131824),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: CubeColor.values.map((c) {
                  final count = counts[c] ?? 0;
                  final isDone = count == 9;
                  return Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: CubeConstants.colorMap[c],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count/9',
                        style: TextStyle(
                          color: isDone ? const Color(0xFF00E676) : (count > 9 ? const Color(0xFFFF1744) : Colors.white60),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Face selector tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: CubeFace.values.map((face) {
                  final isSelected = _activeFace == face;
                  final faceColor = CubeConstants.faceSolvedColor[face]!;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      avatar: CircleAvatar(
                        backgroundColor: CubeConstants.colorMap[faceColor],
                        radius: 8,
                      ),
                      label: Text(CubeConstants.faceNamesVi[face]!),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      backgroundColor: const Color(0xFF161C2C),
                      selectedColor: const Color(0xFF2979FF),
                      onSelected: (_) => setState(() => _activeFace = face),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Active Face 3x3 Grid
            Center(
              child: Container(
                width: 250,
                height: 250,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF141926),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    final color = _faces[_activeFace]![index];
                    final isCenter = index == 4;
                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _onStickerTap(_activeFace, index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: CubeConstants.colorMap[color],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: isCenter
                            ? Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'TÂM',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Color Palette Selector
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF171E2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  const Text(
                    'BẢNG MÀU ĐANG CHỌN',
                    style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: CubeColor.values.map((color) {
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isSelected ? 44 : 36,
                          height: isSelected ? 44 : 36,
                          decoration: BoxDecoration(
                            color: CubeConstants.colorMap[color],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.black45,
                              width: isSelected ? 3.5 : 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: CubeConstants.colorMap[color]!.withOpacity(0.6),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.black, size: 22)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isComplete ? const Color(0xFF00E676) : const Color(0xFF2979FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: BorderRadius.circular(14),
                elevation: 4,
              ),
              onPressed: () {
                final result = RubikCube(initialFaces: _faces);
                Navigator.of(context).pop(result);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isComplete ? Icons.check_circle : Icons.save, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isComplete
                        ? 'XÁC NHẬN & NẠP VÀO BỘ GIẢI 3D'
                        : 'LƯU TRẠNG THÁI HIỆN TẠI',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
