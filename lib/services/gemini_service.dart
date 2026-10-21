import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cube_constants.dart';
import '../models/rubik_cube.dart';

class GeminiService {
  static const String _keyPrefKey = 'gemini_api_key';
  static const String _modelName = 'gemini-1.5-flash';

  String? _apiKey;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_keyPrefKey);
  }

  bool get hasApiKey => _apiKey != null && _apiKey!.trim().isNotEmpty;

  String? get apiKey => _apiKey;

  Future<void> setApiKey(String key) async {
    _apiKey = key.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPrefKey, _apiKey!);
  }

  Future<void> removeApiKey() async {
    _apiKey = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPrefKey);
  }

  /// Analyze current Rubik cube state with Gemini AI
  Future<String> analyzeCube(RubikCube cube) async {
    if (!hasApiKey) {
      return _generateOfflineAnalysis(cube);
    }

    final cubeDescription = _describeCubeState(cube);
    final prompt = '''
Bạn là một Đại kiện tướng giải Rubik (Speedcuber Master) kiêm huấn luyện viên AI chuyên nghiệp.
Dưới đây là trạng thái hiện tại của khối Rubik 3x3:
$cubeDescription

Hãy phân tích khối Rubik này bằng tiếng Việt ngắn gọn, hấp dẫn, dễ hiểu:
1. Đánh giá độ xáo trộn và độ khó hiện tại (Thang điểm 1-10).
2. Tình trạng các mặt (Mặt nào gần hoàn thành nhất, chữ thập trắng đã sẵn sàng chưa).
3. Đề xuất chiến lược giải tối ưu nhất (CFOP / Roux / Layer-by-Layer).
4. Lời khuyên mẹo xoay (Fingertricks) cho bước tiếp theo.
''';

    try {
      final responseText = await _callGeminiApi(prompt);
      return responseText;
    } catch (e) {
      return '⚠️ Không thể kết nối với Gemini AI (${e.toString()}).\n\n${_generateOfflineAnalysis(cube)}';
    }
  }

  /// Explain a specific move or algorithm
  Future<String> explainMove(String move, String phase) async {
    if (!hasApiKey) {
      return _getOfflineMoveExplanation(move);
    }

    final prompt = '''
Bạn là chuyên gia Rubik. Hãy giải thích ngắn gọn bằng tiếng Việt:
- Ký hiệu: $move
- Giai đoạn: $phase
- Ý nghĩa: Nước đi này làm thay đổi những viên nào trên khối Rubik?
- Mẹo ngón tay (Fingertrick): Cách dùng ngón trỏ/ngón cái để xoay bước này mượt nhất trong 0.2 giây.
''';

    try {
      return await _callGeminiApi(prompt);
    } catch (e) {
      return _getOfflineMoveExplanation(move);
    }
  }

  /// Free-form chat with AI Rubik Coach
  Future<String> askAiCoach(String userQuestion, RubikCube currentCube) async {
    if (!hasApiKey) {
      return 'Để trò chuyện trực tiếp với AI Coach thông minh, vui lòng nhập Gemini API Key của bạn trong phần Cài đặt AI (hoàn toàn miễn phí từ Google AI Studio).\n\n💡 Mẹo cơ bản: Bạn có thể dùng thuật toán Sexy Move (R U R\' U\') 6 lần liên tiếp để đưa khối Rubik về vị trí ban đầu!';
    }

    final cubeDescription = _describeCubeState(currentCube);
    final prompt = '''
Bạn là Huấn luyện viên Rubik AI thông thái. Trạng thái khối Rubik hiện tại của người dùng là:
$cubeDescription

Câu hỏi của người dùng:
"$userQuestion"

Hãy trả lời bằng tiếng Việt thân thiện, súc tích, hướng dẫn mẹo và các công thức (U, R, F...) chuẩn xác nhất.
''';

    return await _callGeminiApi(prompt);
  }

  Future<String> _callGeminiApi(String prompt) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_modelName:generateContent?key=$_apiKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 800,
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?[0]?['parts']?[0]?['text'] ??
          data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (text != null && text.toString().isNotEmpty) {
        return text.toString().trim();
      }
      return 'Gemini AI không trả về nội dung.';
    } else {
      final err = jsonDecode(response.body);
      final msg = err['error']?['message'] ?? 'Lỗi HTTP ${response.statusCode}';
      throw Exception(msg);
    }
  }

  String _describeCubeState(RubikCube cube) {
    final sb = StringBuffer();
    sb.writeln('Chuỗi các mặt:');
    for (final face in CubeFace.values) {
      final name = CubeConstants.faceNamesVi[face];
      final colors = cube.faces[face]!
          .map((c) => CubeConstants.colorNamesVi[c] ?? c.name)
          .join(', ');
      sb.writeln('- $name: [$colors]');
    }
    return sb.toString();
  }

  String _generateOfflineAnalysis(RubikCube cube) {
    if (cube.isSolved()) {
      return '🎉 Khối Rubik đang ở trạng thái HOÀN TẤT (Solved)!\n\nTất cả 6 mặt đều đồng màu hoàn hảo. Bạn có thể bấm nút "Xáo trộn (Scramble)" để bắt đầu thử thách mới.';
    }

    final counts = cube.getColorCounts();
    final valid = cube.isValidState();

    return '''
🤖 Phân tích Rubik AI (Chế độ Offline):
- Tính hợp lệ: ${valid ? '✅ Hợp lệ (Đủ 9 viên mỗi màu)' : '⚠️ Cảnh báo: Số lượng màu chưa đồng đều'}
- Thống kê: Trắng (${counts[CubeColor.white]}), Vàng (${counts[CubeColor.yellow]}), Xanh lá (${counts[CubeColor.green]}), Đỏ (${counts[CubeColor.red]}), Cam (${counts[CubeColor.orange]}), Xanh dương (${counts[CubeColor.blue]})
- Lộ trình đề xuất:
  1. Hoàn thành chữ thập trắng (White Cross) ở mặt trên.
  2. Đặt đúng 4 góc trắng bằng công thức R U R\' U\'.
  3. Giải tầng 2 bằng công thức U R U\' R\' U\' F\' U F.
  4. Lật mặt vàng và hoán vị góc/cạnh về đích.

💡 Tip: Nhập Gemini API Key để nhận lời khuyên chiến thuật chi tiết theo thời gian thực!
''';
  }

  String _getOfflineMoveExplanation(String move) {
    final desc = CubeConstants.moveDescriptionsVi[move] ?? 'Nước đi $move';
    return '''
$desc
- Ký hiệu: $move
- Fingertrick: Dùng ngón trỏ tay phải/trái gạt góc trên để thực hiện thao tác nhanh gọn.
''';
  }
}
