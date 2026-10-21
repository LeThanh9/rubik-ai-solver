# 🧊 Rubik 3D AI Solver & Simulator (Flutter + GitHub Actions)

Ứng dụng di động Native (Flutter) giả lập khối Rubik 3D tương tác chân thực, tích hợp thuật toán giải thông minh từng bước, bộ nhập màu trực quan và trợ lý ảo **Google Gemini AI**, được thiết lập sẵn **GitHub Actions CI/CD** để tự động biên dịch và xuất file cài đặt Android **APK** miễn phí trên GitHub.

---

## 🌟 4 Tính năng chính đã tích hợp

### 1. 🎮 Giả lập Rubik 3D tương tác (3D Interactive Simulator)
- Mô phỏng không gian 3 chiều (3D Canvas) với độ phân giải cao và hiệu ứng ánh sáng bề mặt (specular reflections).
- Hỗ trợ cảm ứng vuốt xoay tự do 360 độ quanh mọi trục.
- Hoạt ảnh xoay tầng (layer slice animation) mượt mà cho 12 phép xoay chuẩn: `U, U', D, D', L, L', R, R', F, F', B, B'` và các phép xoay 180° (`U2, D2...`).
- Tính năng **Xáo trộn ngẫu nhiên (Scramble)** 20 bước tiêu chuẩn thi đấu.

### 2. 🧠 Thuật toán AI giải Rubik từng bước (Step-by-Step Solver)
- Phân tích và đưa ra lộ trình giải tối ưu theo từng giai đoạn:
  - **Bước 1**: Chữ thập trắng (White Cross)
  - **Bước 2**: Hoàn thành tầng 1 (White Corners - Sexy Move)
  - **Bước 3**: Tầng 2 (F2L Middle Edges)
  - **Bước 4**: Chữ thập vàng (Yellow Cross)
  - **Bước 5**: Hoán vị cạnh vàng (Sune)
  - **Bước 6**: Định vị 4 góc vàng (Niklas)
  - **Bước 7**: Định hướng góc vàng hoàn tất
- Bảng điều khiển phát lời giải: **Tua tới, Lùi bước, Tự động chạy (Auto-Play)** với thanh điều chỉnh tốc độ từ 0.4s - 2.0s mỗi bước.

### 3. 🎨 Quét & Nhập màu các mặt Rubik (Color Scanner & Net Input)
- Trực quan hóa toàn bộ 6 mặt phẳng mở rộng (Unfolded 2D Net): Mặt Trên (Trắng), Trước (Xanh lá), Phải (Đỏ), Sau (Xanh dương), Trái (Cam), Dưới (Vàng).
- Bảng chọn 6 màu linh hoạt, chạm để tô màu từng ô của khối Rubik thật.
- Tự động kiểm tra tính hợp lệ và đếm số lượng (9 viên mỗi màu) trước khi nạp vào bộ giải 3D.

### 4. 🤖 Tích hợp Google Gemini AI Coach
- Kết nối trực tiếp với API Google Gemini (hỗ trợ `gemini-1.5-flash` siêu nhanh).
- **Phân tích thế cờ**: Đánh giá độ khó, mặt thuận lợi và đề xuất chiến lược giải tối ưu (CFOP / Roux / LBL).
- **Giải thích nước đi**: Hướng dẫn mẹo ngón tay (fingertricks) cho từng công thức.
- **AI Chat Coach**: Trò chuyện và hỏi đáp mọi kỹ thuật Speedcubing bằng tiếng Việt.

---

## 🚀 Hướng dẫn xuất file APK qua GitHub Actions

Bạn **không cần** cài đặt Flutter hay Android Studio trên máy tính. GitHub Actions sẽ tự động biên dịch và tạo file APK trên đám mây:

### Bước 1: Tạo Repository trên GitHub
1. Truy cập [github.com/new](https://github.com/new)
2. Đặt tên Repository (ví dụ: `rubik-ai-solver`).
3. Chọn chế độ **Public** hoặc **Private** tuỳ ý.
4. Bấm **Create repository**.
5. Sao chép đường dẫn repository (ví dụ: `https://github.com/ten-cua-ban/rubik-ai-solver.git`).

### Bước 2: Đẩy mã nguồn lên GitHub
Có 2 cách thực hiện:

#### Cách 1: Sử dụng file script tự động (Khuyên dùng)
- Nhấp đúp chuột vào file **`push_to_github.bat`** (hoặc mở PowerShell chạy `.\push_to_github.ps1`).
- Dán đường dẫn link GitHub Repository đã copy ở Bước 1 và nhấn **Enter**.

#### Cách 2: Chạy lệnh Git thủ công bằng Terminal
Mở terminal trong thư mục `rubik_ai_solver` và gõ:
```bash
git init
git add .
git commit -m "feat: Rubik 3D AI Solver app"
git branch -M main
git remote add origin https://github.com/ten-cua-ban/rubik-ai-solver.git
git push -u origin main --force
```

---

### Bước 3: Tải file APK từ GitHub
1. Trên trình duyệt, vào trang Repository GitHub của bạn.
2. Bấm vào tab **Actions** (ở thanh menu phía trên).
3. Bạn sẽ thấy quy trình `Build and Release Rubik AI APK` đang chạy màu vàng (thời gian build khoảng 2 - 3 phút).
4. Khi chuyển sang biểu tượng màu xanh lá `✓ Build Android APK`:
   - Bấm vào tên lần chạy đó.
   - Kéo xuống mục **Artifacts** ở dưới cùng.
   - Bấm vào **`Rubik-AI-Solver-Release-APK`** để tải file `.zip` chứa file `app-release.apk`.
5. Giải nén và chuyển file `app-release.apk` sang điện thoại Android để cài đặt và trải nghiệm!

---

## 📂 Cấu trúc thư mục dự án

```text
rubik_ai_solver/
├── .github/
│   └── workflows/
│       └── build_apk.yml       # Quy trình CI/CD build APK tự động của GitHub Actions
├── android/                    # Cấu hình Gradle & Android Native (API 21-34)
├── lib/
│   ├── models/
│   │   ├── cube_constants.dart # Định nghĩa mặt, màu sắc, ký hiệu Rubik
│   │   └── rubik_cube.dart     # Mô hình toán học Rubik, phép xoay U, D, L, R, F, B
│   ├── services/
│   │   ├── gemini_service.dart # Tích hợp Gemini AI API và trợ lý Speedcubing
│   │   └── rubik_solver.dart   # Thuật toán giải Rubik từng bước (Layer-by-Layer)
│   ├── widgets/
│   │   └── rubik_3d_canvas.dart# Không gian vẽ 3D tương tác vuốt xoay 360 độ
│   ├── screens/
│   │   ├── home_screen.dart    # Màn hình chính điều khiển & mô phỏng
│   │   ├── color_scanner_screen.dart # Bộ nhập màu & quét 6 mặt
│   │   ├── solver_guide_screen.dart  # Bảng điều khiển phát lời giải từng bước
│   │   └── ai_assistant_dialog.dart  # Cửa sổ Gemini AI Coach & phân tích
│   └── main.dart               # Khởi động ứng dụng giao diện Dark Mode
├── pubspec.yaml                # Khai báo thư viện (http, provider, cupertino_icons)
├── push_to_github.bat          # Script 1-click đẩy code lên GitHub cho Windows
├── push_to_github.ps1          # Script PowerShell đẩy code lên GitHub
└── README.md                   # Hướng dẫn chi tiết
```
