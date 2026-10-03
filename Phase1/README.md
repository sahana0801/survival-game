# Phase 1: The Foundation (Bước 1 - Khởi đầu)

> **Mục tiêu trong bài thuyết trình:**
> Show cho khán giả thấy phiên bản đầu tiên được tạo bởi AI: "Một nhân vật pixel art có thể di chuyển 8 hướng mượt mà trên bản đồ hoàn chỉnh".
> Đây là bước chứng minh AI có thể nhanh chóng dựng khung game (scaffolding) chỉ sau 1 prompt ngắn gọn mà không cần kiến thức code chuyên sâu.

---

## 🎮 Tính năng có trong Phase 1
- **TileMap & Environment:** Bản đồ đảo sinh tồn hoàn chỉnh từ asset gốc (đồng cỏ, vách đá, cây cối, bờ biển).
- **Player Controller:** Nhân vật chính di chuyển 8 hướng mượt mà bằng phím **WASD** hoặc **Mũi tên**.
- **Animation System:** Tự động phát animation tương ứng (idle, n-walk, s-walk, e-walk, w-walk, ne-walk, nw-walk, se-walk, sw-walk).
- **Collision Borders:** Giới hạn va chạm tự nhiên quanh vách đá và viền biển.
- **Camera2D Follow:** Camera bám theo nhân vật mượt mà với zoom 2.5x.

---

## 🎯 Kịch bản Demo & AI Prompt (Dành cho Presentation)

### Kịch bản nói (Talking Point):
> *"Khi bắt đầu làm game với AI, sai lầm lớn nhất là yêu cầu: 'Làm cho tôi một game sinh tồn hoàn chỉnh'. Kết quả sẽ là hàng trăm dòng lỗi.  
> Chiến thuật đúng là **One Job - One Session**. Tôi chỉ yêu cầu AI làm duy nhất 1 việc: Tạo controller nhân vật di chuyển 8 hướng trên bản đồ."*

### Prompt mẫu đã dùng (Agent Prompt):
```markdown
Tạo cho tôi một CharacterBody2D trong Godot 4.2:
- Tốc độ di chuyển SPEED = 100
- Đọc input 4 chiều (WASD và Phím mũi tên)
- Xử lý animation 8 hướng (idle, n-walk, s-walk, e-walk, w-walk, ne-walk, nw-walk, se-walk, sw-walk)
- Camera2D zoom 2.5x bám theo nhân vật
- Tích hợp vào scene World chứa TileMap có sẵn
```

---

## 🚀 Hướng dẫn mở và chạy project

### Cách 1: Chạy bằng Godot Editor (Khuyên dùng)
1. Tải và mở **Godot Engine 4.2+** (Standard version).
2. Tại màn hình **Project Manager**, nhấn nút **Import** (Nhập).
3. Nhấn **Browse** và chọn file:
   `D:\Workspace\Antigravity\Demo_SurvivalGame\Phase1\project.godot`
4. Nhấn **Import & Edit**.
5. Nhấn phím **F5** (hoặc nút Play góc trên bên phải) để chạy game!

### Cách 2: Chạy trực tiếp từ dòng lệnh (Command Line)
Nếu bạn đã thêm `godot` vào biến môi trường PATH:
```powershell
godot --path "D:\Workspace\Antigravity\Demo_SurvivalGame\Phase1"
```

---

## ⌨️ Phím điều khiển
- **W / Mũi tên lên:** Đi lên
- **S / Mũi tên xuống:** Đi xuống
- **A / Mũi tên trái:** Đi sang trái
- **D / Mũi tên phải:** Đi sang phải
- **Tổ hợp phím chéo (ví dụ W + D):** Đi chéo góc
