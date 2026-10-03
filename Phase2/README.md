# Phase 2: The Bug Reel (Những pha AI Fail hài hước)

> **Mục tiêu trong bài thuyết trình:**
> Khán giả rất thích xem **AI fail → phát hiện lỗi → fix lỗi**.  
> Phase 2 minh họa giai đoạn khi bạn yêu cầu AI thêm Combat, Enemies và Spawner mà thiếu quy trình kiểm thử (**AI Testing: Measure + Look**). Kết quả là tạo ra những pha lỗi code kinh điển và hài hước.

---

## 🎬 4 Bugs "kinh điển" trong Phase 2:

| STT | Tên Bug | Nguyên nhân AI Fail | Trải nghiệm trong game |
|---|---|---|---|
| 🐛 **1** | **Slime Xuyên Tường (Ghost Slimes)** | AI quên gọi hàm `move_and_slide()`, cộng thẳng toạ độ `position += dir * speed` | Slime lướt xuyên qua mọi vách núi, cây cối, mặt nước như bóng ma để săn người chơi. |
| 🐛 **2** | **Cung Tên Bắn Ngược (Reverse Archery)** | AI bị nhầm dấu vector hướng: `-Vector2.RIGHT` thay vì `+` | Nhắm vào quái vật, bấm bắn thì mũi tên bay ngược 180 độ về phía sau lưng! 😂 |
| 🐛 **3** | **Người Chơi Bất Tử (God Mode Glitch)** | AI viết hiệu ứng chớp đỏ rất đẹp, nhưng quên dòng code trừ máu: `current_health -= damage` | Bị cả bầy slime cắn xé tơi bời, nhấp nháy đỏ liên tục nhưng thanh máu luôn 100%. |
| 🐛 **4** | **Bùng nổ Slime (Slime Flood)** | AI quên đặt giới hạn `max_slimes` và để timer quá ngắn (0.8s) | Cứ mỗi giây quái đẻ ra không ngừng. *(Bấm phím **B** để đẻ thêm 5 con cùng lúc biểu diễn!)* |

---

## 🎯 Kịch bản Thuyết trình (Presentation Talking Points)

> *"Sau khi có Phase 1, tôi hưng phấn bảo AI: 'Hay quá, bây giờ thêm cho tôi hệ thống bắn cung, quái slime đuổi theo cắn, thanh máu và spawner luôn nhé!'.  
> Và đây là những gì xảy ra trên màn hình...  
> 1. Quái vật đuổi theo tôi: Nó bay xuyên qua vách núi như bóng ma (Bug 1)!  
> 2. Tôi hoảng quá, bấm phím `1` giương cung nhắm vào nó rồi click chuột... và mũi tên bay ngược về sau lưng tôi (Bug 2)!  
> 3. Tôi đứng cho quái cắn thử: Nhân vật chớp đỏ liên tục... nhưng thanh máu vẫn 100% vì AI quên viết logic trừ máu (Bug 3)!  
> 4. Bầy slime bắt đầu sinh sôi tràn ngập bản đồ... (Bấm phím `B` để biểu diễn slime tràn ra!).  
> 👉 **Bài học rút ra:** Đừng bao giờ 'giao khoán' toàn bộ game cho AI trong 1 prompt. Chúng ta phải chia nhỏ session (**One Job - One Session**) và luôn có vòng lặp kiểm thử trực quan (**The Gauntlet Loop: Measure + Look**) để phát hiện và sửa bug từng bước!"*

---

## 🚀 Hướng dẫn mở và chạy Phase 2

1. Mở **Godot Engine 4.2+**.
2. Tại màn hình **Project Manager**, bấm **Import**.
3. Chọn file:
   ```text
   D:\Workspace\Antigravity\Demo_SurvivalGame\Phase2\project.godot
   ```
4. Bấm **Import & Edit**, sau đó nhấn **F5** (hoặc nút **Play** ▶️).

---

## ⌨️ Phím điều khiển Demo:
- **WASD / Mũi tên:** Di chuyển 8 hướng.
- **Phím `1`:** Trang bị / cất Cung Tên (nhân vật sẽ chuyển sang tư thế giương cung theo chuột).
- **Chuột Trái:** Bắn tên (thử nghiệm Bug 2: bắn ngược).
- **Phím `B`:** Trigger đẻ thêm đàn Slime (Bug 4).
