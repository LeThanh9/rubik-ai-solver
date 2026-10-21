import 'package:flutter/material.dart';

enum CubeFace { up, down, front, back, left, right }

enum CubeColor { white, yellow, green, blue, orange, red }

class CubeConstants {
  static const Map<CubeColor, Color> colorMap = {
    CubeColor.white: Color(0xFFF8F9FA),
    CubeColor.yellow: Color(0xFFFFD600),
    CubeColor.green: Color(0xFF00E676),
    CubeColor.blue: Color(0xFF2979FF),
    CubeColor.orange: Color(0xFFFF9100),
    CubeColor.red: Color(0xFFFF1744),
  };

  static const Map<CubeColor, String> colorNamesVi = {
    CubeColor.white: 'Trắng',
    CubeColor.yellow: 'Vàng',
    CubeColor.green: 'Xanh lá',
    CubeColor.blue: 'Xanh dương',
    CubeColor.orange: 'Cam',
    CubeColor.red: 'Đỏ',
  };

  static const Map<CubeFace, CubeColor> faceSolvedColor = {
    CubeFace.up: CubeColor.white,
    CubeFace.down: CubeColor.yellow,
    CubeFace.front: CubeColor.green,
    CubeFace.back: CubeColor.blue,
    CubeFace.left: CubeColor.orange,
    CubeFace.right: CubeColor.red,
  };

  static const Map<CubeFace, String> faceNamesVi = {
    CubeFace.up: 'Mặt Trên (U)',
    CubeFace.down: 'Mặt Dưới (D)',
    CubeFace.front: 'Mặt Trước (F)',
    CubeFace.back: 'Mặt Sau (B)',
    CubeFace.left: 'Mặt Trái (L)',
    CubeFace.right: 'Mặt Phải (R)',
  };

  static const Map<String, String> moveDescriptionsVi = {
    'U': 'Xoay mặt Trên (Up) theo chiều kim đồng hồ',
    "U'": 'Xoay mặt Trên (Up) ngược chiều kim đồng hồ',
    'U2': 'Xoay mặt Trên (Up) 180 độ',
    'D': 'Xoay mặt Dưới (Down) theo chiều kim đồng hồ',
    "D'": 'Xoay mặt Dưới (Down) ngược chiều kim đồng hồ',
    'D2': 'Xoay mặt Dưới (Down) 180 độ',
    'F': 'Xoay mặt Trước (Front) theo chiều kim đồng hồ',
    "F'": 'Xoay mặt Trước (Front) ngược chiều kim đồng hồ',
    'F2': 'Xoay mặt Trước (Front) 180 độ',
    'B': 'Xoay mặt Sau (Back) theo chiều kim đồng hồ',
    "B'": 'Xoay mặt Sau (Back) ngược chiều kim đồng hồ',
    'B2': 'Xoay mặt Sau (Back) 180 độ',
    'L': 'Xoay mặt Trái (Left) theo chiều kim đồng hồ',
    "L'": 'Xoay mặt Trái (Left) ngược chiều kim đồng hồ',
    'L2': 'Xoay mặt Trái (Left) 180 độ',
    'R': 'Xoay mặt Phải (Right) theo chiều kim đồng hồ',
    "R'": 'Xoay mặt Phải (Right) ngược chiều kim đồng hồ',
    'R2': 'Xoay mặt Phải (Right) 180 độ',
  };
}
