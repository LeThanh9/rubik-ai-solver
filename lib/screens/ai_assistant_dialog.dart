import 'package:flutter/material.dart';
import '../models/rubik_cube.dart';
import '../services/gemini_service.dart';

class AiAssistantDialog extends StatefulWidget {
  final GeminiService geminiService;
  final RubikCube currentCube;

  const AiAssistantDialog({
    super.key,
    required this.geminiService,
    required this.currentCube,
  });

  @override
  State<AiAssistantDialog> createState() => _AiAssistantDialogState();
}

class _AiAssistantDialogState extends State<AiAssistantDialog> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  bool _obscureKey = true;
  bool _isLoading = false;
  String? _analysisResult;
  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _apiKeyController.text = widget.geminiService.apiKey ?? '';
    _messages.add(
      const _ChatMessage(
        isAi: true,
        text: 'Xin chào! Tôi là Trợ lý Huấn luyện viên Rubik AI của bạn. Bạn muốn phân tích thế Rubik hiện tại hay tìm hiểu công thức nào?',
      ),
    );
  }

  Future<void> _saveApiKey() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      await widget.geminiService.removeApiKey();
    } else {
      await widget.geminiService.setApiKey(key);
    }
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật Gemini API Key!'),
          backgroundColor: Color(0xFF00E676),
        ),
      );
    }
  }

  Future<void> _analyzeCurrentCube() async {
    setState(() {
      _isLoading = true;
      _analysisResult = null;
    });

    try {
      final res = await widget.geminiService.analyzeCube(widget.currentCube);
      setState(() {
        _analysisResult = res;
      });
    } catch (e) {
      setState(() {
        _analysisResult = 'Lỗi phân tích: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _askQuestion(String question) async {
    if (question.trim().isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(isAi: false, text: question));
      _isLoading = true;
    });
    _questionController.clear();

    try {
      final answer = await widget.geminiService.askAiCoach(question, widget.currentCube);
      setState(() {
        _messages.add(_ChatMessage(isAi: true, text: answer));
      });
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(isAi: true, text: 'Lỗi: $e'));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
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

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2979FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Color(0xFF2979FF), size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Google Gemini AI Coach',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Phân tích thế cờ & Hướng dẫn Speedcubing',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white60),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // API Key Settings Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161C2C),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.key, color: Color(0xFFFFD600), size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Cấu hình Gemini API Key (Miễn phí)',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const Spacer(),
                          Text(
                            widget.geminiService.hasApiKey ? 'ĐÃ KẾT NỐI' : 'CHƯA NHẬP',
                            style: TextStyle(
                              color: widget.geminiService.hasApiKey ? const Color(0xFF00E676) : Colors.orangeAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _apiKeyController,
                        obscureText: _obscureKey,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Nhập API key từ Google AI Studio...',
                          hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                          filled: true,
                          fillColor: const Color(0xFF0D111A),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureKey ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white54,
                              size: 18,
                            ),
                            onPressed: () => setState(() => _obscureKey = !_obscureKey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _saveApiKey,
                            child: const Text('Lưu API Key', style: TextStyle(color: Color(0xFF2979FF), fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Button Analyze Current Cube
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2979FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.analytics_outlined, size: 20),
                  label: const Text(
                    'PHÂN TÍCH KHỐI RUBIK HIỆN TẠI',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  onPressed: _isLoading ? null : _analyzeCurrentCube,
                ),

                if (_isLoading) ...[
                  const SizedBox(height: 20),
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: Color(0xFF2979FF)),
                        SizedBox(height: 10),
                        Text(
                          'Gemini AI đang suy nghĩ và tính toán chiến thuật...',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],

                if (_analysisResult != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161E30),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2979FF).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.psychology, color: Color(0xFF00E676), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'KẾT QUẢ PHÂN TÍCH AI',
                              style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _analysisResult!,
                          style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Quick Prompt Chips
                const Text(
                  'CÂU HỎI THƯỜNG GẶP',
                  style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChip('Sexy Move là gì?'),
                    _buildChip('Cách giải tầng 2 (F2L)?'),
                    _buildChip('Công thức Sune lật mặt vàng?'),
                    _buildChip('Mẹo xoay Rubik dưới 20 giây?'),
                  ],
                ),

                const SizedBox(height: 16),

                // Conversation history
                ..._messages.map((msg) {
                  return Align(
                    alignment: msg.isAi ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.78,
                      ),
                      decoration: BoxDecoration(
                        color: msg.isAi ? const Color(0xFF192132) : const Color(0xFF2979FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: msg.isAi ? Colors.white70 : Colors.white,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Message input bar
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF141A28),
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Hỏi AI Coach về công thức, mẹo chơi...',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF0B0E17),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (val) => _askQuestion(val),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: Color(0xFF2979FF)),
                  onPressed: () => _askQuestion(_questionController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text) {
    return ActionChip(
      label: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      backgroundColor: const Color(0xFF171E2D),
      side: BorderSide(color: Colors.white.withOpacity(0.08)),
      onPressed: () => _askQuestion(text),
    );
  }
}

class _ChatMessage {
  final bool isAi;
  final String text;

  const _ChatMessage({required this.isAi, required this.text});
}
