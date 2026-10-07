# KỊCH BẢN THUYẾT TRÌNH CHI TIẾT (PRESENTATION PLAN V3 - SYNCED 16 SLIDES)
**Dự án:** 2D Action Survival Game (Godot 4.7 Engine)  
**Thời lượng dự kiến:** 30 – 40 phút (+ 10 phút Q&A)  
**Đối tượng người nghe:** Đồng nghiệp, anh/chị kỹ sư công nghệ, người muốn tìm hiểu cách làm game bằng AI thực chiến  
**Phiên bản đồng bộ:** Khớp 100% với `gamma_presentation_prompt.md` và `AI_GameDev_Presentation_ver03.pptx`

> **Trọng tâm bài nói:** 
> Không đi sâu kể lể tính năng game. Game là **vật chứng sống** để chia sẻ:
> 1. **Cách làm thực chiến** (Multi-model Claude + GPT 5.6 Sol, Gauntlet Method).
> 2. **Bí kíp Game Mechanics & Collision** (Dành cho người ít chơi game nhưng muốn bắt đầu).
> 3. **Bí kíp tạo Pixel Art Game-Ready** (Trị Mixels, Bleeding, Drift).
> 4. **Điểm AI làm cực tốt vs. Điểm AI hoàn toàn bất lực** (Minh chứng sống: Vẽ Map bằng TileSet).
> 5. **Các trend AI làm game hiện nay & Blooper Reel hài hước**.

---

## 🎬 CẤU TRÚC KỊCH BẢN (STORYTELLING FLOW - 16 SLIDES)

```
[ACT 1: HOOK & CON SỐ]       (3 phút)  ──► Slide 1: Hook & Slide 2: Con số bùng nổ quy mô
[ACT 2: CÔNG CỤ & ĐỘI NGŨ]   (5 phút)  ──► Slide 3: So sánh 3 Engine & Slide 4: Phân vai Agent
[ACT 3: NỀN TẢNG CƠ CHẾ]     (4 phút)  ──► Slide 5: Hiểu Game Mechanics (Case Study: Collision)
[ACT 4: 4 NGUYÊN TẮC CODE]   (8 phút)  ──► Slide 6: Rule 1 (Plan) -> Slide 7: Rule 2 (Session)
                                        ──► Slide 8: Rule 3 (Gauntlet) -> Slide 9: Rule 4 (Test Scene)
[ACT 5: QUY TRÌNH PIXEL ART] (7 phút)  ──► Slide 10: 3 Lỗi Pixel Art -> Slide 11: Pipeline 5 bước
[ACT 6: ĐƯỢC - MẤT & BẰNG CHỨNG] (7 phút) ──► Slide 12: AI chào thua vẽ Map -> Slide 13: Ma trận phân công
                                        ──► Slide 14: Blooper Reel 4 Bug hài hước
[ACT 7: TỔNG KẾT & DEMO]     (6 phút)  ──► Slide 15: 6 Bước bắt đầu -> Slide 16: Live Demo & Q&A
```

---

## CHI TIẾT TỪNG SLIDE (16 SLIDES)

### 📌 Slide 1: "AI làm game này: Bài học từ một dự án thật"
- **Visual:** Nền bàn làm việc studio góc tối ấm áp (bàn phím cơ, tablet vẽ, tay cầm gamepad).
- **Slogan chốt hạ (Animation Fade In):**  
  *Giao việc cho AI thi công · Giữ vững quyền nghiệm thu.*
- **Thông điệp:** Chia sẻ hành trình thực tế từ prototype nhỏ lên hệ thống hoàn chỉnh. Không thần thánh hóa AI, tập trung vào cách quản trị rủi ro và workflow kiểm soát chất lượng.

---

### 📌 Slide 2: "But first — Numbers: Quy mô dự án bùng nổ"
- **Bảng đối chiếu số liệu Git:**
  * **GDScript Code:** 1 file (43 dòng) ➔ **65 files (~5.700 dòng code)**
  * **Godot Scenes:** 2 scenes ➔ **50 scenes lồng nhau (.tscn)**
  * **Domain Skills:** Không có ➔ **99 Godot Domain Skills tích hợp sâu trong IDE**
- **Điểm nhấn thị giác:** Thẻ phóng to **`≈ 132×`** (Zoom Animation on click) — Tăng trưởng quy mô gấp 132 lần!
- **Takeaway:** *"Code thử 1 tính năng thì AI nào cũng làm được trong 5 phút. Nhưng khi quy mô phình to gấp 130 lần, nếu không có quy trình kiểm soát, dự án sẽ vỡ vụn ngay lập tức."*

---

### 📌 Slide 3: "Chọn Engine theo Workflow của AI: Tại sao Godot thay vì Unity hay Unreal 5?"
- **Bố cục 3 cột so sánh trực quan (3 Logo vector chính hãng):**
  1. **🔴 Unreal Engine 5:** Đồ họa đỉnh cao, AI can thiệp qua MCP (Claude Opus 5.5 + Higgsfield). Nhưng cái giá rất đắt: đốt hàng tỷ tokens (~$2.500/demo), máy trạm khủng, build C++ lâu, file binary khó diff.
  2. **🟡 Unity:** C# quen thuộc, kho asset khổng lồ. Nhưng vướng *"The Editor Gap"* (phải dùng chuột thao tác Inspector) và Domain Reload mất vài giây mỗi lần sửa code làm gián đoạn nhịp chạy của Agent.
  3. **🟢 Godot Engine 4 (★ LỰA CHỌN TỐI ƯU CHO DỰ ÁN ★):**
     * **100% Plain Text (`.tscn`):** AI đọc hiểu, diff và sửa thẳng cấu trúc Node/Signal cực sạch.
     * **Test Headless 0.5s:** Agent tự gõ lệnh CLI kiểm tra logic và chạy test trong tích tắc.
     * **Siêu tiết kiệm:** Dung lượng ~100MB, chi phí API cả dự án chỉ tốn vài chục USD!
- **Takeaway:** *"Chọn engine phục vụ cho vòng phản hồi của AI (Feedback Loop), không chọn theo danh tiếng."*

---

### 📌 Slide 4: "Phân vai Agent: Tách người thiết kế khỏi người thi công"
- **Mô hình 2 Agent chuyên biệt:**
  * **Lead Architect (Claude):** Đọc toàn bộ repo, phân tích luồng dữ liệu, phát hiện rủi ro và viết bản đặc tả kỹ thuật (Spec). Không chạm vào code thực thi.
  * **Builder / Worker (GPT-5.6 Sol / Antigravity Agent):** Đọc spec, dùng 99 Godot Domain Skills thi công code, viết test cô lập và báo cáo diff.
  * **Con người:** Duyệt phạm vi trước khi thi công.
- **Hợp đồng bàn giao mẫu:**  
  *"Sửa inventory_ui.gd để click Hotbar không bắn tên. Không sửa script player."*

---

### 📌 Slide 5: "Nền tảng cốt lõi: Muốn làm game bằng AI? Phải hiểu Game Mechanics!"
> *(Chuyên mục dành cho người mới hoặc ít chơi game nhưng muốn bắt đầu làm game với AI)*
- **Vấn đề cốt lõi:**
  * Làm web/app thông thường là dữ liệu tĩnh và xử lý CRUD. Nhưng Game là **vòng lặp 60 FPS trong không gian vật lý thời gian thực**.
  * Nếu không hiểu Game Mechanics, bạn chỉ biết prompt chung chung: *"Làm nhân vật đi và bắn quái"* ➔ AI sẽ đoán mò và sinh code sai logic ngay lập tức.
- **Case Study nhập môn sống còn — Cơ chế Va chạm (Collision):**
  1. **Collision Layer vs Collision Mask:**
     * `Layer`: "Đối tượng này thuộc nhóm nào?" (Ví dụ: Layer 1 = World, Layer 2 = Player, Layer 3 = Enemy, Layer 4 = Projectile).
     * `Mask`: "Đối tượng này va chạm với những nhóm nào?"
     * Cài sai một số ➔ Quái đi xuyên núi hoặc đạn tự nổ khi vừa rời nòng!
  2. **Solid Body (Vật cản) vs Area Trigger (Cảm biến):**
     * *Solid Body (CharacterBody/StaticBody):* Cản chuyển động (tường đá, gốc cây không cho đi xuyên).
     * *Area Trigger (Area2D):* Cho đi xuyên qua để nhận sự kiện (bước vào vũng nước làm chậm, nhặt vàng, dính đạn nhận sát thương).
- **Bài học thực chiến:** Bug *"WaterBlock nuốt mũi tên"* xảy ra vì gán nhầm vùng nước thành Solid Collider. Hiểu mechanic $\rightarrow$ Viết spec tách Layer $\rightarrow$ AI sửa đúng trong 1 nốt nhạc!

---

### 📌 Slide 6: Rule 1 — "Artifact-First: Không cho AI gõ code khi chưa duyệt Plan"
- **Sai lầm phổ biến:** Prompt vội *"Fix hết lỗi inventory và hotbar cho tôi"* ➔ AI sửa mò mẫm, fix slot 1 thì gãy slot 2, click UI bắn xuyên tên.
- **Quy trình 3 bước:**
  1. **Khảo sát repo:** Tách biệt tầng UI, tầng Data và tầng Input.
  2. **Viết kế hoạch (bugfix_plan.md):** Nêu rõ nguyên nhân gốc rễ, danh sách file can thiệp, diff dự kiến và kịch bản test.
  3. **Con người duyệt:** Xem xét phạm vi và test chống tái phát trước khi cho phép AI sửa file.
- **Takeaway:** *"Plan rẻ, code sai sửa mới đắt! Duyệt plan 2 phút cứu vãn cả buổi chiều debug."*

---

### 📌 Slide 7: Rule 2 — "One Job, One Fresh Session"
- **Vấn đề:** Nói chuyện quá dài trong 1 session gây ô nhiễm ngữ cảnh (Context Pollution) ➔ AI bắt đầu bịa code, nhớ nhầm tên biến cũ.
- **Bài học Phase 2:** Nhồi nhét Cung tên + Quái vật + Spawner vào cùng 1 phiên chat ➔ Slime spawn trong lòng núi, cung thủ quay lưng bắn ngược ra sau!
- **Giải pháp:** Mỗi task = 1 session sạch. Chỉ nạp Spec + File liên quan + Tiêu chí nghiệm thu. Xong việc $\rightarrow$ Commit Git $\rightarrow$ Xóa session, mở phiên mới.

---

### 📌 Slide 8: Rule 3 — "The Gauntlet Loop: Chỉ merge khi vượt qua kiểm tra"
- **Sơ đồ luồng tự động:**
  * `Worker` nộp code diff ➔ Rẽ 2 nhánh song song:
    - **Measure (Đo đạc):** Script tự động chạy headless kiểm tra định lượng (DPS, Cooldown 0.8s, HP).
    - **Critic (Phản biện):** Agent độc lập rà soát chuẩn code và nguy cơ breaking change.
  * Hai nhánh đạt chuẩn ➔ Chuyển tới **Con người playtest thực tế và duyệt cuối** ➔ **Git Merge**.
- **Luật sắt:** *FAIL ở bất kỳ nhánh nào ➔ Mũi tên đỏ lập tức đẩy ngược về Worker làm lại từ đầu!*

---

### 📌 Slide 9: Rule 4 — "Test cô lập và Đo đạc trong Scene riêng"
- **Kỹ thuật cô lập:** Thay vì chạy từ đầu game rồi đi bộ tìm boss (mất 5 phút) ➔ Tạo riêng file `test_exec_damage.tscn` gồm Boss Executioner và một Dummy gỗ đứng yên với đồng hồ 3 giây.
- **2 Tầng kiểm thử:**
  * **Tầng 1 (Logic Check):** In log terminal kiểm tra sát thương chém đúng 25 HP, knockback hoạt động chuẩn.
  * **Tầng 2 (Visual Screenshot):** Chụp ảnh kết quả từ engine để soi lỗi thanh máu che mất chữ hoặc icon bị méo.

---

### 📌 Slide 10: "3 Lỗi khiến Pixel Art gen từ AI chưa thể dùng được"
- **3 Căn bệnh kinh niên:**
  1. **Mixels (Lệch hạt Pixel):** AI trộn lẫn hạt to và hạt nhỏ trên cùng 1 nhân vật, viền bị mờ nhạt khử răng cưa ➔ Phá vỡ phong cách Retro.
  2. **Frame Bleeding (Tràn lưới):** Vũ khí vung chém tràn qua vạch ngăn ô trên Sprite Sheet ➔ Khi cắt sprite bị dính rác hình của frame bên cạnh.
  3. **Frame Drift (Lệch tâm chân):** Điểm tiếp đất nhảy giật lùi, không đồng trục Y ➔ Khi chạy animation nhân vật trượt như trên băng!

---

### 📌 Slide 11: "Pipeline 5 bước biến AI Art thành Asset Game-Ready"
- **5 Bước chuẩn hóa:**
  * **01. Identity Anchor:** Cố định phom dáng nhân vật trên canvas vuông 1024x1024 nền xanh chroma key.
  * **02. Pixel Snapping:** Dùng script ép bảng màu hữu hạn (Palette), ép viền pixel sắc cạnh (Nearest-Neighbor).
  * **03. Pose Board:** Dàn trang các tư thế (Attack 8 frames, Hurt 6 frames, Death 10 frames).
  * **04. Recovery & Curation:** Tách nền, kiểm tra bounding box và loại bỏ frame lỗi bằng mắt người.
  * **05. Anchoring & Onion Skin:** Khóa đồng trục bàn chân tiếp đất và đưa vào `AnimatedSprite2D` trong Godot để kiểm tra nhịp chạy.

---

### 📌 Slide 12: "Thực tế dự án: Điểm AI chào thua — Level Design & Vẽ Map"
- **Visual trung tâm:** Ảnh chụp màn hình thật **Godot 4.7.2 TileSet Editor đang vẽ map `route_1.tscn`** ([`real_godot_tileset_map_design.png`](file:///d:/Workspace/Antigravity/Demo_SurvivalGame/003.%20presentation_output/assets/real_godot_tileset_map_design.png)).
- **Luận điểm vàng:**
  * AI có thể sinh code logic rất nhanh, nhưng **Level Design & Vẽ Map** thì AI hoàn toàn chào thua.
  * AI không có cảm quan không gian của người chơi (*Player Flow*): Chỗ nào hẹp tạo căng thẳng, chỗ nào thoáng để thở.
  * AI không biết xếp layer thế nào để nhân vật đi sau gốc cây thì được che bóng râm (Y-sort), không biết uốn lượn bờ hồ và đặt giếng nước hài hòa.
- **Kết luận:** *"Level Design là nghệ thuật thủ công. Con người trực tiếp cầm chuột nhặt từng viên tile trong Godot mới tạo ra được linh hồn của trò chơi."*

---

### 📌 Slide 13: "Ma trận phân công trách nhiệm: AI làm gì vs Con người làm gì"
- **3 Cấp độ rõ ràng:**
  * **AI Có Thể Dẫn Dắt (80% tự động):** Viết thuật toán toán học, state machine, refactor hàm, sinh mã nguồn test.
  * **AI Cần Người Kèm Cặp (50 - 50):** Lắp ráp Scene Node, canh chỉnh thông số animation, bố cục giao diện UI.
  * **Con Người Bắt Buộc Quyết Định (100%):** Level Design & Vẽ Map, Game Feel (cảm giác nảy, độ đầm tay), Balance game và Cắt giảm Scope tính năng.

---

### 📌 Slide 14: "The Blooper Reel — Bốn bug hài hước trở thành regression test"
- **4 Câu chuyện thực chiến từ Phase 4 (Xuất hiện lần lượt On-Click):**
  1. 🐛 **WaterBlock nuốt mũi tên:** Đạn bay ngang vũng nước tự hủy vì gán nhầm layer va chạm.
  2. 🐛 **Cung thủ mặc thiết giáp:** Đổi class sang Cung thủ mà mở túi đồ vẫn thấy giáp sắt nặng trịch do hardcode UI.
  3. 🐛 **Click Balo bắn tên:** Nhấp chuột sắp xếp đồ trong hòm thì nhân vật ngoài màn hình giương cung bắn loạn xạ.
  4. 🐛 **Vứt đồ tạo slot ma:** Kéo item vứt ra đất, ngoài đất có đồ mà trong hòm vẫn ám slot ma vô hình.
- **Bài học:** *"Mỗi bug dở khóc dở cười là tài sản vô giá khi được biến thành một bài Regression Test tự động!"*

---

### 📌 Slide 15: "Sáu bước khởi động dự án cho đồng nghiệp"
- **Công thức hành động ngày mai:**
  1. **Chọn loop nhỏ:** Di chuyển + 1 đòn đánh + 1 quái vật.
  2. **Nạp nền tảng:** Rules & Domain Skills vào IDE trước khi gõ dòng code đầu tiên.
  3. **Duyệt kế hoạch:** Luôn bắt AI viết Plan chi tiết và bạn duyệt trước.
  4. **Chuẩn hóa asset:** Pixel Art + Bounding Box an toàn.
  5. **Chạy kiểm tra:** Code ➔ Test cô lập ➔ Critic phản biện chéo.
  6. **Playtest bằng tay:** Cầm bàn phím lên trải nghiệm game feel, ghi lỗi và lặp lại.

---

### 📌 Slide 16: "Live Demo & Thảo luận (Q&A)"
- **Trình diễn trực tiếp trên Godot 4.7:**
  * Boss Undead Executioner (3 phase tiến hóa, triệu hồi minion).
  * UI Hotbar kéo thả, đổi class nhân vật mượt mà.
  * Mở trực tiếp file `bugfix_plan.md` trong Antigravity IDE.
- **Thảo luận cởi mở:** Chi phí API thực tế, cách thiết lập Domain Skills và kinh nghiệm debug cùng AI.
