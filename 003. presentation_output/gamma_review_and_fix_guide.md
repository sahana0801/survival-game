# ĐÁNH GIÁ CHI TIẾT VÀ HƯỚNG DẪN KHẮC PHỤC POWERPOINT (GAMMA DRAFT)
**Dự án:** Survival Game (Godot 4.7) · **Tài liệu thuyết trình:** `AI-lam-game-nay-Bai-hoc-tu-mot-du-an-that.pptx`  
**Ngày review:** 04/10/2026 · **Người thực hiện:** Antigravity AI Assistant

---

## I. TỔNG QUAN REVIEW: NHỮNG ĐIỂM ĐƯỢC & ĐIỂM CHƯA ĐẠT

### 1. Điểm đã làm tốt của Gamma
* **Tone màu & Phong cách nền:** Đã bám được tông giấy da cổ (*Aged Parchment* `#F5EEDC`) và xanh rừng thẫm (*Forest Teal* `#1E5E52`), tạo cảm giác nhật ký phiêu lưu (*Adventurer's Journal*).
* **Cấu trúc nội dung:** Bám sát dàn ý 15 slide của `presentation_plan_v3.md`, không bị nhảy cóc hay sót các phần quan trọng (Gauntlet, Mixel, 4 bugs blooper reel).
* **Speaker Notes:** Đã tạo sẵn ghi chú cho người thuyết trình khá chi tiết dưới mỗi slide.

### 2. Bốn vấn đề "chí mạng" cần khắc phục ngay
1. **Lạm dụng hình vẽ AI Generic ("AI Slop"):**
   * Gamma tự động sinh các bức tranh fantasy pixel art ước lệ (Slide 1, 4, 5, 6, 8, 9, 13, 15).
   * *Hậu quả:* Người xem (đồng nghiệp) sẽ nghĩ đây là bài nói lý thuyết, viển vông. Ví dụ: Slide 4 nói về Claude & GPT lại vẽ 2 chú thợ mộc đóng nhà gỗ; Slide 5 nói về duyệt plan lại vẽ mấy tờ giấy da trống trên bàn; Slide 13 nói về 4 bug thật trong game lại vẽ tranh cái túi, con suối phong cách hoạt hình!
2. **Hoàn toàn thiếu Animation & Progressive Reveal (Slide quá tĩnh):**
   * Toàn bộ 15 slides là dạng ảnh phẳng tĩnh. Người nghe nhìn thấy toàn bộ nội dung cùng lúc ngay khi chuyển slide, làm mất nhịp kể chuyện (*pacing*), mất sự tập trung và giảm tính kịch tính của bài nói.
   * Cần có **hiệu ứng xuất hiện tuần tự (On-Click / After Previous)** như trong clip mẫu: nói đến Engine nào thì logo đó hiện ra (Godot $\rightarrow$ Blender $\rightarrow$ Unity/Unreal).
3. **Thiếu Data Visualization & GIF động:**
   * Slide 2 (Scope bùng nổ gấp 132 lần code) chỉ là 1 cái bảng text cằn cỗi, không tạo được cảm giác choáng ngợp về quy mô.
   * Slide 9 & 10 (Lỗi Sprite: Frame Drift, Bleeding) là lỗi liên quan tới **chuyển động của animation**, dùng ảnh tĩnh thì người xem không thể hình dung được sprite bị trôi lệch chân như thế nào.
4. **Thiếu "Proof of Real Work" (Minh chứng dự án thật):**
   * Thiếu hoàn toàn ảnh chụp Godot Editor thật, code diff thật, terminal thật.
   * Đặc biệt, bạn đã có sẵn ảnh chụp thực tế màn hình **vẽ Map & TileSet trong Godot** (`route_1.tscn`), đây chính là **"bằng chứng vàng"** để chứng minh luận điểm: *"AI viết logic rất tốt, nhưng khâu Level Design / Vẽ Map thì AI hoàn toàn chào thua, con người bắt buộc phải trực tiếp nhặt từng viên tile và phân lớp collision"*.

---

## II. BẢNG AUDIT & HƯỚNG DẪN SỬA CHI TIẾT TỪNG SLIDE (SLIDE 1 $\rightarrow$ 15)

| Slide | Nội dung hiện tại của Gamma | Vấn đề phát hiện | Giải pháp khắc phục & Assets thay thế |
| :--- | :--- | :--- | :--- |
| **Slide 1: Title** | Hộp chữ bên trái, bên phải là tranh AI vẽ rừng slime. Dưới có dòng *"Minh họa khái niệm..."*. | Tranh AI generic làm giảm độ uy tín ngay từ giây đầu tiên. Dòng disclaimer làm bài nói thiếu tự tin. | **Thay ảnh nền:** Dùng ảnh chụp game thật (nhân vật đứng giữa map `route_1` hoặc đấu trường Boss Executioner) với overlay tối mờ. Xóa bỏ dòng disclaimer. |
| **Slide 2: Scope bùng nổ** | Bảng text xám 4 dòng: 43 dòng vs 5.700 dòng, 2 scenes vs 50 scenes. | Quá khô khốc, không toát lên được mức tăng trưởng khổng lồ (**gấp 132 lần code, 25 lần scene**). | **Chuyển thành Biểu đồ cột so sánh / Stat Callout:**<br>• Hiển thị số phóng to: **5,700+** dòng GDScript, **50** Scenes, **99** Skills.<br>• Thêm badge: *"Quy mô tăng 132 lần — Không có workflow kiểm soát thì vỡ trận"*. |
| **Slide 3: Chọn Engine** | Bảng so sánh text 3 cột Godot, Unity, Unreal. | Thiếu visual, text đơn điệu, không có logo nhận diện. | **Học theo mẫu video (`media_1791117220212.png`):**<br>• Dùng Logo chính hãng nổi bật: **Godot Engine** (xanh), **Blender** (cam), **Unity/Unreal**.<br>• **Animation:** Xuất hiện từng logo kèm subtitle ngắn:<br>&nbsp;&nbsp;+ *Godot: Text-based .tscn, test headless 0.5s, AI đọc hiểu 100%*<br>&nbsp;&nbsp;+ *Blender: Pipeline 3D/Sprite*<br>&nbsp;&nbsp;+ *Unreal/Unity: Mạnh nhưng chi phí token & binary asset quá đắt*. |
| **Slide 4: Team Setup** | 2 cột Architect & Builder, bên phải là tranh AI vẽ 2 thợ mộc gọt nhà gỗ. | Hình thợ mộc medieval là AI slop vô nghĩa, không ăn nhập với công nghệ. | **Bỏ tranh thợ mộc:** Thay bằng sơ đồ 2 Agent công nghệ:<br>• Cột trái: Logo Claude + Badge *"Lead Architect"* (Khảo sát repo, sinh spec).<br>• Cột phải: Logo Antigravity / GPT + Badge *"Builder"* (99 Skills, Godot CLI test).<br>• Ở giữa: Mũi tên bàn giao *"Spec & Acceptance Criteria"*. |
| **Slide 5: Rule 1 - Plan trước Code** | 3 bước (Khảo sát, Viết plan, Duyệt), bên trái là tranh AI vẽ mấy tờ giấy da trống trên bàn. | Tranh vẽ giấy da không thể hiện được giá trị của "Artifact-First". | **Thay ảnh:** Đặt ảnh chụp màn hình thực tế file `bugfix_plan.md` trong editor (hiển thị rõ mục lục: Root Cause, File Diff, Regression Test) hoặc khung mockup Code Diff. |
| **Slide 6: Rule 2 - Fresh Session** | Cột text 3 ý, bên phải là tranh nữ cung thủ bắn tên ngược vào slime trong núi. | Ý tưởng minh họa khá vui nhưng phong cách tranh vẽ bị lệch tone tech-talk. | **Giữ lại ý tưởng hài hước nhưng bổ sung context:** Có thể giữ hình này hoặc thay bằng meme / screenshot game thật lúc bị bug. Thêm animation xuất hiện câu kết: *"Mang vào session mới: Chỉ Spec + Test, vứt bỏ toàn bộ rác hội thoại cũ"*. |
| **Slide 7: The Gauntlet Loop** | 4 khối hộp xám nối bằng mũi tên chữ: Worker $\rightarrow$ Measure/Critic $\rightarrow$ Gate $\rightarrow$ Merge. | Bố cục tĩnh, khô cứng, không thể hiện được bản chất của một "Vòng lặp đào thải" (Loop). | **Thiết kế lại thành Dynamic Workflow Diagram:**<br>• Worker code $\rightarrow$ rẽ nhánh song song sang **Measure (Đo đạc)** và **Critic (Phản biện)**.<br>• **Animation:**<br>&nbsp;&nbsp;+ Nhánh Đỏ (Fail): Mũi tên quay ngược đầu đập về Worker làm lại!<br>&nbsp;&nbsp;+ Nhánh Xanh (Pass): Mũi tên đi tiếp vào Gate con người duyệt $\rightarrow$ Merge Git. |
| **Slide 8: Rule 4 - Test cô lập** | 2 cột Test logic & Screenshot, bên trái là tranh AI vẽ đấu trường đá có bù nhìn. | Tranh AI vẽ đấu trường không chứng minh được "Test Scene cô lập trong Godot". | **Thay bằng ảnh thực tế:** Ảnh chụp Godot đang chạy scene `test_exec_damage.tscn` (có dummy gỗ thật của game, output console in ra DPS/HP) + cửa sổ debug visual. |
| **Slide 9: 3 Lỗi Sprite (Mixel/Bleed/Drift)** | 3 cột: Mixels (hình slime), Frame bleeding (hình 2 cung thủ), Frame drift (hình 3 bộ xương). | **Lỗi nghiêm trọng:** 3 tranh này vẽ AI tĩnh nên hoàn toàn KHÔNG THỂ HIỆN ĐƯỢC lỗi Mixel (pixel không đều), Bleeding (tràn ô lưới), Drift (lệch tâm). | **Thay bằng Visual thực chứng / GIF:**<br>• Mixels: Hình zoom cận cảnh so sánh hạt pixel to nhỏ lộn xộn vs pixel chuẩn lưới.<br>• Frame bleeding: Sprite sheet có ô lưới màu đỏ bị nhân vật chém lẹm sang ô bên.<br>• Frame drift: **GIF động** (hoặc 3 frame chồng onion-skin) cho thấy chân nhân vật nhảy giật lùi khi chạy. |
| **Slide 10: 5 Bước Asset Pipeline** | 5 cột chữ số 01 $\rightarrow$ 05, hoàn toàn không có hình ảnh nào. | 5 cột thuần chữ rất nhàm chán khi trình bày quy trình đồ họa. | **Chuyển thành Pipeline trực quan có thumbnail cho từng bước:**<br>• 01: Character Base (Chroma key xanh) $\rightarrow$ 02: Pixel Snapping (viền nét) $\rightarrow$ 03: Pose Board $\rightarrow$ 04: Curation $\rightarrow$ 05: In-game Animation. |
| **Slide 11: Bài học Stack** | 1 trang màu xanh lá đậm chỉ có chữ to tướng: *"IDE · Skills · Scripts · Test · Chi phí cache"*. | Bị trống trải, không có visual phân cấp. | **Chuyển thành bảng xếp hạng Stack công nghệ:** Dùng logo/badge: Antigravity IDE, Godot Engine, Claude Sonnet 3.7 / Opus 5.5, Domain Skills Pack. |
| **Slide 12: Trách nhiệm nghiệm thu (AI vs Người)** | Bảng 3 dòng text: AI có thể dẫn, AI cần kèm, Người quyết định. | Rất khô khan, thiếu bằng chứng thực tế cho thấy tại sao con người là bắt buộc. | **VỊ TRÍ VÀNG CHO ẢNH VẼ MAP CỦA BẠN:**<br>• Chèn trực tiếp ảnh `real_godot_tileset_map_design.png` (Màn hình Godot TileSet Editor vẽ `route_1.tscn`).<br>• **Key Takeaway:** *"AI có thể sinh 100 dòng code state machine trong 10 giây, nhưng vẽ một cái Map có nhịp điệu, có bờ sông, giếng nước và va chạm chuẩn thì AI BÓ TAY. Level Design bắt buộc cần con người cầm chuột nhặt từng viên tile!"* |
| **Slide 13: Blooper Reel 4 Bug** | 4 thẻ: WaterBlock hủy tên, Cung thủ mặc giáp, Click UI bắn tên, Drop tạo slot ma kèm 4 tranh AI vẽ. | 4 tranh AI vẽ (cái túi, bộ giáp, con suối...) rất trẻ con và giả tạo. | **Thay ảnh:**<br>• Dùng screenshot bug thật từ game hoặc icon cảnh báo bug màu đỏ retro pixel.<br>• Nhấn mạnh: *"Mỗi bug dở khóc dở cười này là một bài học đắt giá được biến thành 1 file Regression Test tự động"*. |
| **Slide 14: Checklist 6 bước** | 6 ô số 01 $\rightarrow$ 06 chia 2 hàng. | Tương đối ổn về bố cục, nhưng thiếu điểm nhấn thị giác. | Thêm icon nhỏ hoặc checkbox pixel art cho mỗi bước để trông giống một Quest Log / Checklist của game thủ. |
| **Slide 15: Live Demo & Q&A** | 3 ý (Combat, UI, Q&A), bên trái là tranh AI vẽ Boss Undead Executioner khổng lồ. | Tranh vẽ AI không phải Boss thật trong game của bạn. | **Thay bằng ảnh Boss thật trong game:** Ảnh chụp `executioner_arena.tscn` lúc boss đang vung rìu hoặc player đang giao chiến trong Godot thật. Kèm dòng chữ: *"Hãy cùng xem thực tế chạy như thế nào!"* |

---

## III. ASSETS ĐÃ ĐƯỢC CHUẨN BỊ SẴN TRONG DỰ ÁN

Các tài nguyên phục vụ việc thay thế đã được lưu trữ sẵn sàng tại thư mục:  
`d:\Workspace\Antigravity\Demo_SurvivalGame\003. presentation_output\assets\`

1. **`reference_godot_blender_animation.png`**: Ảnh tham chiếu phong cách tối giản, icon thương hiệu nổi bật kèm animation tuần tự (dùng làm mẫu cho Slide 3 & Slide 11).
2. **`real_godot_tileset_map_design.png`**: Ảnh chụp thực tế Godot 4.7.2 TileSet Editor đang vẽ map `route_1.tscn` (dùng làm nhân vật chính cho Slide 12 - Chứng minh AI không thể thay thế Level Design của con người).

---

## IV. HƯỚNG DẪN 2 CÁCH KHẮC PHỤC (TRÊN GAMMA HOẶC TRỰC TIẾP TRÊN POWERPOINT)

### Cách 1: Tinh chỉnh lại trên Gamma (Nếu bạn muốn Gamma tự sinh lại layout)
Nếu bạn vẫn muốn dùng giao diện web của Gamma để gen lại:
1. Mở deck trên Gamma, chọn từng card có hình AI generic (Card 4, 5, 8, 9, 12, 13, 15).
2. Nhấn vào ảnh $\rightarrow$ Chọn **Delete image** hoặc đổi Layout sang dạng **Split with custom image / Mockup**.
3. **Upload ảnh thật:**
   * Tại Card 12: Nhấn Upload $\rightarrow$ chọn file `real_godot_tileset_map_design.png`.
   * Tại Card 3: Xóa bảng text, chọn định dạng **2 Columns / Visual Cards**, chèn icon Godot Engine và Blender.
4. **Bật hiệu ứng chuyển động trên Gamma:**
   * Trong phần cài đặt trình chiếu của Gamma, chọn chế độ **Presentation Mode** $\rightarrow$ bật tính năng **"Present card by card"** hoặc **"Stagger elements"** để các ý xuất hiện lần lượt khi bạn bấm click chuột.

---

### Cách 2: Tinh chỉnh trực tiếp trên file PowerPoint (`.pptx`) — **KHUYÊN DÙNG ĐỂ CÓ FULL ANIMATION & BẢN QUYỀN**
PowerPoint có đầy đủ sức mạnh nhất để làm Animation, gắn GIF và thay hình ảnh mà Gamma bị giới hạn:

#### Bước 1: Thay thế hình ảnh thật vào Slide
* **Slide 12:** Mở Slide 12 $\rightarrow$ Thu nhỏ bảng text sang góc trái $\rightarrow$ Kéo ảnh `real_godot_tileset_map_design.png` vào chiếm 60% diện tích bên phải $\rightarrow$ Thêm 1 viền mỏng màu vàng đất (`#E5B842`) hoặc đổ bóng nhẹ để tạo chất screenshot kỹ thuật.
* **Slide 3:** Tải logo SVG/PNG trong suốt của **Godot Engine** và **Blender** (hoặc Unity) $\rightarrow$ Đặt 2 logo nằm song song tương tự ảnh mẫu $\rightarrow$ Đặt subtitle chữ trắng/xanh bên dưới.
* **Slide 4 & 5:** Xóa bỏ tranh thợ mộc và tranh giấy da $\rightarrow$ Thay bằng hộp text dạng **Terminal Dark Theme** (nền đen, chữ xanh/vàng) thể hiện nội dung file `bugfix_plan.md` và lệnh chạy agent.

#### Bước 2: Thêm Animation xuất hiện tuần tự (Sequential Animation)
Để bài nói cuốn hút như video review công nghệ chuyên nghiệp:
1. **Ở Slide 3 (Chọn Engine):**
   * Chọn Logo Godot + text: Thêm hiệu ứng `Animations` $\rightarrow$ `Fade` (hoặc `Zoom`) $\rightarrow$ Start: `On Click`.
   * Chọn Logo Blender/Unreal: Thêm `Fade` $\rightarrow$ Start: `On Click`.
   * *Khi thuyết trình:* Bạn bấm click 1 lần, Godot hiện ra và bạn giải thích tại sao chọn Godot. Bấm click lần 2, các công cụ phụ trợ hiện ra.
2. **Ở Slide 7 (The Gauntlet Loop):**
   * Hộp **Worker**: Xuất hiện đầu tiên.
   * Hộp **Measure & Critic**: Xuất hiện cùng lúc (Start: `With Previous` hoặc `After Previous`).
   * Hộp **Cổng nghiệm thu con người**: Xuất hiện tiếp theo.
   * Mũi tên đỏ quay lại: Xuất hiện cuối cùng kèm lời nhấn mạnh: *"Không đạt $\rightarrow$ đập về Worker viết lại từ đầu!"*.
3. **Ở Slide 13 (Blooper Reel):**
   * Đặt hiệu ứng `Appear` hoặc `Wipe` lần lượt cho 4 ô bug. Mỗi lần bấm phím là một câu chuyện dở khóc dở cười được bật mí, tạo tiếng cười cho khán phòng trước khi chuyển sang phần kết luận.

---

## V. KẾ HOẠCH HÀNH ĐỘNG TIẾP THEO

Bạn muốn tiến hành theo hướng nào:
1. **Bạn muốn mình trực tiếp can thiệp vào file `.pptx`** (sử dụng thư viện Python `python-pptx` để tự động thay ảnh Slide 12 bằng ảnh Godot Map thật, gỡ bỏ các hình AI generic rác, chuẩn hóa lại text)?
2. Hay **bạn muốn mình viết sẵn một prompt tinh chỉnh chính xác cho Gamma** kèm danh sách hướng dẫn để bạn thao tác trên web Gamma?
