# HƯỚNG DẪN THAO TÁC GAMMA & PROMPT TINH CHỈNH 16 SLIDE (V2)

---

## PHẦN 1: HƯỚNG DẪN THAO TÁC TRÊN GIAO DIỆN GAMMA (STEP-BY-STEP)

Để slide sinh ra **không bị rác hình AI (AI Slop)**, giữ đúng style **Adventurer's Journal** và có bố cục sẵn sàng cho animation:

### Bước 1: Khởi tạo Project trên Gamma
1. Truy cập [Gamma.app](https://gamma.app) $\rightarrow$ Nhấn **Create New** (Tạo mới) $\rightarrow$ Chọn **Paste in text** (Dán văn bản).
2. Chọn loại định dạng: **Presentation** (Bài thuyết trình) $\rightarrow$ Tỉ lệ khung hình: **16:9**.
3. Số lượng thẻ: Chọn **16 Cards**.

### Bước 2: Thiết lập Tùy chọn Hình ảnh (CỰC KỲ QUAN TRỌNG ĐỂ TRÁNH AI SLOP)
* Trong ô **Image source (Nguồn ảnh)**:
  * **KHÔNG CHỌN** *"AI generated images"* (đây là lý do bản cũ bị toàn tranh vẽ hoạt hình generic!).
  * **HÃY CHỌN:** *"Web image search"* hoặc *"No images / Icons only"*. Chúng ta sẽ tự tay chèn các ảnh chụp thật từ repo vào.

### Bước 3: Chọn Theme & Màu sắc (Style Settings)
1. Khi Gamma hiển thị bảng chọn Theme, tìm kiếm hoặc tùy biến theme theo bộ thông số:
   * **Base Background:** Aged Parchment / Giấy da cổ (`#F5EEDC` hoặc tone Kem trầm ấm).
   * **Primary Color (Tiêu đề):** Forest Teal / Xanh rừng thẫm (`#1E5E52`).
   * **Accent Color (Điểm nhấn):** Honey Gold / Vàng mật ong (`#E5B842`).
   * **Body Text (Văn bản):** Deep Espresso / Nâu đen (`#2D241E`).
   * **Font Heading:** Cinzel, MedievalSharp, hoặc serif cổ điển.
   * **Font Body:** Inter, Lora, hoặc Roboto Serif.

### Bước 4: Chèn 2 Hình ảnh thực tế sau khi Gamma sinh khung
Sau khi Gamma sinh xong 16 Cards:
1. **Tại Card 3 (Chọn Engine):**
   * Đổi layout thành 2 hoặc 3 cột.
   * Chèn logo vector chính hãng của **Godot Engine** và **Blender** (tham chiếu theo ảnh `003. presentation_output/assets/reference_godot_blender_animation.png`).
2. **Tại Card 12 (Dedicated Visual Slide - Vẽ Map & TileSet):**
   * Đổi layout thành **Full-width Image / Media Focus** (ảnh lớn chiếm 70% diện tích).
   * Nhấn Upload và chọn file ảnh chụp Godot thật có sẵn trong repo:  
     `003. presentation_output/assets/real_godot_tileset_map_design.png`.

### Bước 5: Bật Chế độ Animation & Trình chiếu
* Khi thuyết trình trên Gamma: Nhấn nút **Present** $\rightarrow$ chọn tính năng **"Present card by card"** hoặc **"Stagger elements"**.
* Khi xuất ra PowerPoint (`.pptx`): Tải về máy và áp dụng tính năng `Animation` $\rightarrow$ `Appear / Fade` theo từng click chuột như hướng dẫn ở Phần 3.

---

## PHẦN 2: NỘI DUNG MASTER PROMPT DÁN VÀO GAMMA (16 CARDS)

*(Sao chép toàn bộ phần bên dưới và dán trực tiếp vào ô nội dung của Gamma)*

```markdown
# CHỦ ĐỀ THUYẾT TRÌNH: AI LÀM GAME NÀY — BÀI HỌC TỪ MỘT DỰ ÁN THẬT
- Phong cách: Nhật ký phát triển (Developer's Journal / Tech Talk thực chiến).
- Tông màu: Giấy da cổ (#F5EEDC), chữ xanh rừng thẫm (#1E5E52), điểm nhấn vàng (#E5B842), viền nâu (#2D241E).
- Yêu cầu bố cục: Thẻ gọn gàng, dùng icon công nghệ và bảng số liệu, không sinh tranh vẽ AI hoạt hình generic.

---

### CARD 1: TIÊU ĐỀ BÀI NÓI
- Tag: — NHẬT KÝ PHÁT TRIỂN · DEVELOPER TALK
- Tiêu đề: AI làm game này: Bài học từ một dự án thật
- Phụ đề: Từ prototype 43 dòng code, bug dở khóc dở cười đến một workflow game dev có kiểm chứng.
- Điểm nhấn:
  * Góc nhìn người trong cuộc: Không hype viển vông, chỉ chia sẻ thực tế làm được và chưa làm được.
  * Dự án minh chứng: Game 2D Action Survival xây dựng trên Godot Engine 4.7.
- Gợi ý visual: Layout bìa nhật ký da sang trọng, kèm badge "Dev Diary: Phase 1 to Phase 4".

---

### CARD 2: BÙNG NỔ QUY MÔ (THE REALITY CHECK)
- Tag: — QUY MÔ DỰ ÁN TĂNG TRƯỞNG
- Tiêu đề: Từ prototype đến hệ thống game hoàn chỉnh
- Bảng đối chiếu số liệu Git:
  * GDScript logic: 1 file (43 dòng) ➔ 65 files (Khoảng 5.700 dòng code) — Tăng gấp 132 lần!
  * Scene kiến trúc: 2 scenes ➔ 50 scenes lồng nhau (.tscn)
  * AI Tooling: Không có ➔ 99 Godot Domain Skills tích hợp sâu trong IDE
- Thông điệp cốt lõi:
  * "Code thử 1 tính năng thì AI nào cũng làm được trong 5 phút."
  * "Nhưng khi quy mô tăng 130 lần, nếu không có quy trình kiểm soát thay đổi, dự án sẽ vỡ vụn ngay lập tức."

---

### CARD 3: TẠI SAO CHỌN GODOT CHO AI GAME DEV?
- Tag: — LỰA CHỌN CÔNG CỤ THEO WORKFLOW
- Tiêu đề: Engine nào tối ưu nhất cho AI Coding?
- Layout: So sánh 3 cột (Sử dụng logo Godot, Blender, Unity/Unreal):
  * Cột 1 (Godot Engine - Khuyên dùng):
    - Scene dạng văn bản thuần (.tscn) ➔ AI đọc hiểu 100% cấu trúc Node và diff Git cực sạch.
    - Chạy headless qua CLI ➔ Chạy unit test và kiểm tra logic mất đúng 0.5 giây!
    - Dung lượng siêu nhẹ (~100MB), chi phí API cực thấp.
  * Cột 2 (Blender - Tạo Asset bổ trợ):
    - Đóng vai trò dựng khung model, hỗ trợ trích xuất góc quay và sprite sheet đồng bộ.
  * Cột 3 (Unreal Engine 5 & Unity):
    - Đồ họa đỉnh cao nhưng file binary khó đọc diff; chạy 1 task tự động tốn hàng ngàn USD chi phí token.
- Kết luận: "Chọn engine phục vụ cho vòng lặp phản hồi của AI, không chọn vì danh tiếng."

---

### CARD 4: PHÂN VAI AGENT (ARCHITECT VS BUILDER)
- Tag: — MÔ HÌNH PHỐI HỢP
- Tiêu đề: Đừng bắt một AI vừa thiết kế vừa gõ code
- 2 Khối vai trò đối xứng:
  * Khối 1: Claude (Lead Architect)
    - Trách nhiệm: Đọc toàn bộ repo, phân tích luồng dữ liệu, phát hiện rủi ro và viết bản đặc tả kỹ thuật (Spec).
    - Nguyên tắc: Không chạm vào code thực thi.
  * Khối 2: GPT-5.6 Sol / Antigravity Agent (Builder)
    - Trách nhiệm: Đọc spec, sử dụng 99 Domain Skills để thi công code, viết test cô lập và báo cáo diff.
- Hợp đồng bàn giao mẫu (Contract):
  * "Nhiệm vụ: Sửa lỗi click chuột vào Hotbar bị xuyên thấu bắn tên. Chỉ sửa duy nhất input handler trong file inventory_ui.gd. Tuyệt đối không sửa script của player."

---

### CARD 5: BÀI HỌC CỐT LÕI CHO NGƯỜI MỚI
- Tag: — NỀN TẢNG BẮT BUỘC
- Tiêu đề: Muốn làm game bằng AI? Phải hiểu Game Mechanics!
- Dành cho ai: Người ít chơi game nhưng hào hứng muốn dùng AI tạo ra trò chơi đầu tiên.
- Thông điệp chính:
  * AI không thể "đoán mò" bạn muốn game vận hành thế nào nếu bạn chỉ prompt chung chung: "Làm game bắn quái".
  * Lập trình web/app chỉ là dữ liệu tĩnh; Game là không gian vật lý thời gian thực 60 FPS.
- Case Study: Cơ chế Va chạm (Collision) — Bài học nhập môn sống còn:
  * 1. Collision Layer vs Mask: "Tôi thuộc nhóm nào" (Layer) và "Tôi va chạm với ai" (Mask). Cài sai một số ➔ Quái đi xuyên tường hoặc đạn tự nổ khi vừa rời nòng.
  * 2. Solid Body vs Area Trigger: Tường/Cây là vật cứng cản bước; còn Vùng Nước/Item là Sensor cho đi qua để kích hoạt sự kiện.
- Quy tắc vàng: "Hiểu rõ cơ chế ➔ Viết spec chính xác ➔ AI code chuẩn 100%."

---

### CARD 6: QUY TẮC 1 — ARTIFACT-FIRST (PLAN TRƯỚC CODE)
- Tag: — KỶ LUẬT THI CÔNG
- Tiêu đề: Cấm chỉ định: Prompt thẳng "Hãy code cho tôi..."
- Quy trình 3 bước bắt buộc:
  * Bước 1: Khảo sát repo ➔ Tách bạch tầng hiển thị (UI), tầng dữ liệu (Data) và tầng input.
  * Bước 2: Viết kế hoạch (bugfix_plan.md) ➔ Nêu rõ nguyên nhân gốc rễ, danh sách file can thiệp, diff dự kiến và kịch bản test.
  * Bước 3: Con người duyệt ➔ Người làm game bấm "Proceed" thì AI mới được phép mở file sửa code.
- Minh họa thực tế: Một file `bugfix_plan.md` chuẩn bị 10 phút cứu vãn 3 ngày ngồi sửa lỗi dây chuyền!

---

### CARD 7: QUY TẮC 2 — ONE JOB, ONE FRESH SESSION
- Tag: — QUẢN TRỊ NGỮ CẢNH
- Tiêu đề: Mỗi task bắt đầu bằng một phiên làm việc mới
- Vấn đề: Trò chuyện quá dài trong 1 session khiến context bị ô nhiễm (Context Pollution) ➔ AI bắt đầu bịa code, nhớ nhầm tên hàm cũ.
- Bài học xương máu từ Phase 2:
  * Nhồi nhét cùng lúc: Làm hệ thống Cung tên + Quái vật + Bộ đếm Spawner trong 1 phiên chat.
  * Hậu quả: Quái Slime spawn xuyên lòng núi, cung thủ quay lưng bắn tên ngược ra sau!
- Giải pháp:
  * Mang vào phiên mới: Chỉ mang Spec bàn giao + File liên quan + Tiêu chí nghiệm thu.
  * Xong 1 task ➔ Commit Git ➔ Xóa session, mở phiên mới làm task tiếp theo.

---

### CARD 8: QUY TẮC 3 — THE GAUNTLET LOOP
- Tag: — CỔNG KIỂM SOÁT TỰ ĐỘNG
- Tiêu đề: Vòng lặp đào thải: Chỉ merge khi vượt qua kiểm tra
- Sơ đồ quy trình (Workflow):
  * [Worker]: Thi công code theo spec ➔ Nộp Git Diff.
  * [Song song 1 - Measure]: Chạy test headless đo đạc định lượng (DPS, Cooldown 0.8s, Máu rút chuẩn).
  * [Song song 2 - Critic]: Agent phản biện độc lập rà soát chuẩn code và nguy cơ breaking change.
  * [Cổng con người]: Con người playtest và duyệt chất lượng cuối.
- Luật bất thành văn:
  * Bất kỳ bài test nào FAIL ➔ Mũi tên đỏ lập tức đẩy ngược về Worker bắt sửa lại!
  * Hai AI đồng ý với nhau vẫn chưa đủ điều kiện để Merge vào nhánh chính.

---

### CARD 9: QUY TẮC 4 — TEST CÔ LẬP VÀ ĐO ĐẠC
- Tag: — ĐỊNH LƯỢNG HÓA CHẤT LƯỢNG
- Tiêu đề: Đo thông số và nhìn kết quả trong Scene riêng
- Kỹ thuật cô lập:
  * Thay vì mở cả game đi tìm boss (mất 5 phút) ➔ Tạo riêng file `test_exec_damage.tscn`.
  * Scene chỉ gồm Boss Executioner và một Dummy gỗ đứng yên với đồng hồ 3 giây.
- 2 Tầng kiểm thử:
  * Tầng 1 (Logic Check): In log terminal kiểm tra sát thương chém có đúng 25 HP, hiệu ứng giật lùi có hoạt động không.
  * Tầng 2 (Visual Vision): Chụp ảnh kết quả từ engine để AI Vision soi lỗi thanh máu che mất chữ hoặc icon bị méo.

---

### CARD 10: 3 LỖI KHIẾN PIXEL ART GEN TỪ AI CHƯA THỂ DÙNG ĐƯỢC
- Tag: — NỖI ĐAU ĐỒ HỌA
- Tiêu đề: Đẹp trên ảnh tĩnh nhưng vỡ vụn khi vào game
- 3 Căn bệnh kinh niên của AI Pixel Art:
  * 1. Mixels (Hạt pixel không đều):
    - AI trộn lẫn pixel to và pixel nhỏ trên cùng một nhân vật, viền bị mờ mịn ➔ Phá vỡ phong cách Retro.
  * 2. Frame Bleeding (Tràn viền ô lưới):
    - Đao kiếm hoặc vạt áo tràn sang ô bên cạnh trên Sprite Sheet ➔ Khi cắt sprite, nhân vật bị dính rác hình của frame khác.
  * 3. Frame Drift (Lệch tâm chuyển động):
    - Trọng tâm và bàn chân nhảy lung tung giữa các frame ➔ Khi phát animation, nhân vật chạy như đang bị co giật trên băng!

---

### CARD 11: PIPELINE 5 BƯỚC BIẾN AI ART THÀNH ASSET GAME-READY
- Tag: — QUY TRÌNH CHUẨN HÓA
- Tiêu đề: Pipeline đồ họa có kiểm chứng (Nano Banana / GPT Image)
- 5 Bước thực hiện:
  * Bước 1 (Identity Anchor): Cố định phom dáng nhân vật trên canvas vuông 1024x1024 nền xanh chroma key.
  * Bước 2 (Pixel Snapping): Dùng script lọc bảng màu hữu hạn (Palette), ép viền pixel sắc cạnh với thuật toán Nearest-Neighbor.
  * Bước 3 (Pose Board): Dàn trang các tư thế (Attack 8 frames, Hurt 6 frames, Death 10 frames).
  * Bước 4 (Recovery & Curation): Tách nền tự động, kiểm tra bounding box và can thiệp thủ công loại bỏ frame lỗi.
  * Bước 5 (Anchoring & Onion Skin): Cố định chân tiếp đất và đưa vào AnimatedSprite2D trong Godot để kiểm tra nhịp chạy.

---

### CARD 12: ĐIỂM AI CHÀO THUA — LEVEL DESIGN & MAP BUILDING
- Tag: — CHỨNG MINH THỰC TẾ DỰ ÁN
- Tiêu đề: Tại sao vẽ Map bắt buộc phải cần bàn tay con người?
- Bố cục: Dành không gian lớn cho ảnh chụp Godot TileSet Editor (`real_godot_tileset_map_design.png`).
- Sự thật về AI trong thiết kế thế giới:
  * AI có thể viết code logic, nhưng AI hoàn toàn "mù" về cảm quan không gian của người chơi.
  * AI không biết xếp layer thế nào để nhân vật đi sau gốc cây thì được che bóng râm (Y-sort).
  * AI không biết bố trí bờ hồ, lối mòn quanh co và đặt giếng nước để tạo nên nhịp thở cho ngôi làng.
- Kết luận: "Level Design là nghệ thuật thủ công. Con người trực tiếp cầm chuột nhặt từng viên tile trong Godot mới tạo ra được linh hồn của trò chơi."

---

### CARD 13: MA TRẬN PHÂN CÔNG TRÁCH NHIỆM (AI VS NGƯỜI)
- Tag: — GIỚI HẠN THỰC TẾ
- Tiêu đề: Biết việc nào giao cho AI, việc nào giữ cho người
- Bảng phân chia 3 cấp độ:
  * AI Có Thể Dẫn Dắt (Automation 80%):
    - Viết thuật toán toán học, state machine, refactor hàm, sinh mã nguồn kiểm thử.
  * AI Cần Người Kèm Cặp Chặt Chẽ (50 - 50):
    - Lắp ráp Scene Node, canh chỉnh thông số animation, tinh chỉnh bố cục UI.
  * Con Người Bắt Buộc Phải Quyết Định (Human 100%):
    - Level Design & Vẽ Map, Game Feel (cảm giác nảy, độ đầm tay khi vung kiếm), Balance game và Cắt giảm Scope tính năng.

---

### CARD 14: BLOOPER REEL — KHI AI TẠO RA NHỮNG BUG "BẤT HỦ"
- Tag: — GÓC HÀI HƯỚC DỰ ÁN
- Tiêu đề: Bốn lỗi hài hước trở thành tài sản kiểm thử
- 4 Bug kinh điển từ Phase 4:
  * 1. Vũng nước sát thủ (WaterBlock): Mũi tên bay ngang vũng nước bị biến mất vì nhầm layer va chạm!
  * 2. Cung thủ mặc thiết giáp: Đổi class từ Chiến binh sang Cung thủ nhưng dữ liệu giáp nặng vẫn giữ nguyên.
  * 3. Click balo bắn tên: Nhấp chuột sắp xếp đồ trong Inventory thì nhân vật bên ngoài giương cung bắn loạn xạ.
  * 4. Vứt đồ tạo slot ma: Kéo item vứt ra đất, ngoài đất có đồ mà trong hòm vẫn còn slot ma vô hình.
- Bài học: "Mỗi bug ngớ ngẩn được phát hiện là cơ hội vàng để viết thêm 1 bài Regression Test tự động!"

---

### CARD 15: SÁU BƯỚC KHỞI ĐỘNG DỰ ÁN CHO ĐỒNG NGHIỆP
- Tag: — HÀNH ĐỘNG NGAY
- Tiêu đề: Công thức 6 bước để bắt đầu ngày mai
- Lộ trình rõ ràng:
  * 01. Chọn Gameplay Loop siêu nhỏ (Di chuyển + 1 đòn đánh + 1 quái).
  * 02. Nạp Rules & Domain Skills vào IDE trước khi gõ dòng lệnh đầu tiên.
  * 03. Luôn yêu cầu AI viết Plan chi tiết và bạn phải duyệt Plan trước.
  * 04. Chuẩn hóa Asset Pixel Art ngay từ khâu Identity Anchor và Bounding Box.
  * 05. Thiết lập quy trình Gauntlet (Code ➔ Test cô lập ➔ Critic phản biện).
  * 06. Tự mình Playtest bằng tay, lắng nghe cảm giác chơi và lặp lại vòng lặp.

---

### CARD 16: LIVE DEMO & HỎI ĐÁP (Q&A)
- Tag: — TRẢI NGHIỆM THỰC TẾ
- Tiêu đề: Xem game chạy thật & Thảo luận quy trình
- 3 Nội dung trình diễn trực tiếp:
  * 1. Combat & AI Loop: Giao chiến với Boss Undead Executioner (3 phase tiến hóa, triệu hồi minion).
  * 2. UI & Inventory: Thử nghiệm kéo thả hotbar, hoán đổi class nhân vật mượt mà không dính bug.
  * 3. Hậu trường IDE: Mở trực tiếp Godot 4.7 và các file `bugfix_plan.md` trong Antigravity.
- Mở rộng thảo luận: Sẵn sàng giải đáp chi phí API thực tế, cách setup skills và bí quyết debug cùng AI!
```

---

## PHẦN 3: HƯỚNG DẪN CẤU HÌNH ANIMATION TRÊN POWERPOINT (SAU KHI XUẤT .PPTX)

Khi bạn đã xuất file `.pptx` từ Gamma về máy:

1. **Card 3 (Chọn Engine - Logo Godot & Blender xuất hiện tuần tự):**
   * Chọn Logo Godot $\rightarrow$ Tab `Animations` $\rightarrow$ Chọn hiệu ứng `Zoom` hoặc `Fade` $\rightarrow$ Start: `On Click`.
   * Chọn Text mô tả Godot $\rightarrow$ Hiệu ứng `Fade` $\rightarrow$ Start: `With Previous` (hoặc trễ 0.2s).
   * Chọn Logo Blender/Unreal $\rightarrow$ Hiệu ứng `Zoom` $\rightarrow$ Start: `On Click`.
   * *Trải nghiệm:* Khi nói đến Godot, click chuột thì Godot hiện ra; khi nói đến Blender/Unreal thì click tiếp để hiện ra, hoàn toàn khớp với clip mẫu!

2. **Card 5 (Game Mechanics & Collision):**
   * Cho phần lý thuyết hiện trước.
   * Khi nói đến ví dụ *"Layer vs Mask"* và *"Solid Body vs Area Trigger"*, cài đặt hiệu ứng `Fly In` (từ dưới lên) theo từng click chuột để người nghe không bị ngợp kiến thức.

3. **Card 8 (The Gauntlet Loop):**
   * Khối Worker: Xuất hiện đầu tiên.
   * Khối Measure & Critic: Cài đặt `Fade` cùng lúc (`With Previous`).
   * Cổng người duyệt: Cài đặt `Fade` (`On Click`).
   * Mũi tên đỏ quay ngược đầu: Cài đặt `Wipe` kèm màu đỏ nổi bật xuất hiện cuối cùng để nhấn mạnh tính nghiêm ngặt của quy trình.

4. **Card 12 (Dedicated Slide - Ảnh Godot TileMap):**
   * Cho ảnh `real_godot_tileset_map_design.png` hiển thị toàn màn hình ngay từ đầu.
   * Khối hộp ghi chú luận điểm *"AI chào thua khâu Level Design"* cài đặt hiệu ứng `Fade In` sau 1 giây để người nghe tập trung quan sát bản đồ trước khi đọc chữ.
