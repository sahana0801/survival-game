# KỊCH BẢN NÓI CHI TIẾT (SPEECH SCRIPT - ONLINE PRESENTATION)

**Chủ đề:** Giao việc cho AI code game: Bài học xương máu từ một dự án thật
**Diễn giả:** [Tên của bạn]
**Phong cách nói:** Dân dã, tự nhiên, khiêm tốn, gần gũi. Xưng *"em"* - gọi *"các anh chị / mọi người"*. Viết theo dạng văn nói để đọc online mượt mà, không bị lộ là đọc sách.

---

## 📌 SLIDE 1: MỞ MÀN & TỔNG QUAN DỰ ÁN

Dạ chào các anh chị và mọi người ạ.

Thú thật trước với mọi người là em cũng ít khi đứng nói trước đông người như thế này, nên tí nữa trong lúc chia sẻ nếu em có đoạn nào hơi vấp hay ấp úng một xíu thì mọi người thông cảm giùm em nha. *(Cười nhẹ)*

Chuyện là đợt vừa rồi em có tò mò ngồi vọc vạch làm một con game 2D nho nhỏ trên Godot Engine, và có ứng dụng AI vào để hỗ trợ từ khâu code cho tới làm asset hình ảnh. Lúc mới bắt đầu thì em hào hứng lắm mọi người ạ. Xem mấy video trên mạng thấy người ta bảo giờ có AI làm game nhàn tênh, chỉ cần gõ vài câu prompt là nó nặn ra nguyên con game.

Nhưng mà... bắt tay vào làm thật rồi mới thấy nó không màu hồng như thế. Nó phát sinh đủ thứ chuyện dở khóc dở cười, có những hôm ngồi debug mà toát hết cả mồ hôi.

Bức ảnh bên phải màn hình này là con game thực tế em làm ra, tí nữa ở cuối buổi em sẽ mở máy lên demo cho mọi người xem và chơi thử cho vui. Nhưng buổi hôm nay em không tính lên đây để kể lể tính năng hay khoe con game này đâu ạ. Mục đích chính của em là muốn chia sẻ lại mấy cái bài học xương máu mà em rút ra được:

Dạ rồi, để không làm mất thời gian của mọi người nữa, em xin phép đi vào câu chuyện đầu tiên luôn ạ...

*(👉 Bấm Next sang Slide 2)*

---

## 📌 SLIDE 2: CON SỐ THỰC TẾ & QUY MÔ BÙNG NỔ

Trước khi đi sâu vào chi tiết, em muốn chiếu cho mọi người xem qua vài con số thực tế từ dự án này trước đã.

Đoạn này là bài học đầu tiên mà em thấm thía này mọi người:

Nếu mình chỉ bảo AI code thử 1 tính năng nhỏ lẻ, kiểu như làm một cái nút bấm hay cho nhân vật nhảy lên nhảy xuống, thì thú thật là AI nào nó cũng làm được trong 5 phút. Ai nhìn vào demo ngắn cũng thấy rất ấn tượng.

Nhưng câu chuyện sẽ hoàn toàn khác khi dự án nó phình to lên hàng chục file và hàng nghìn dòng code như thế này. Nếu mình cứ chat theo kiểu vô tư, tiện đâu prompt đó mà không có một quy trình kỷ luật để kiểm soát, thì em đảm bảo chỉ sau 2 đến 3 ngày thôi, toàn bộ code sẽ bị vỡ vụn, các file đá nhau chan chát và không một AI nào có thể tự đi mà fix nổi.

Vậy thì làm thế nào để em kiểm soát được một hệ thống 65 file, hơn 50 scene, hơn 6k line code này mà không bị overload? Trước hết, nó bắt đầu từ việc em chọn công cụ và Game Engine. Em xin phép bấm qua slide tiếp theo ạ...

*(👉 Bấm Next sang Slide 3)*

---

## 📌 SLIDE 3: CHỌN ENGINE THEO WORKFLOW CỦA AI

Khi bắt đầu làm một con game, câu hỏi đầu tiên mà ai cũng nghĩ tới là: Nên chọn Game Engine nào?

Bình thường người ta hay đu trend — cứ Unity hay Unreal 5 mà làm. Nhưng khi làm việc cùng AI, tiêu chí chọn engine của em nó lại hoàn toàn khác: **Engine nào phục vụ tốt nhất cho vòng lặp phản hồi của AI (Feedback Loop)?**

Trên màn hình là 3 lựa chọn mà em đã cân nhắc:

Đầu tiên là **Unreal Engine 5** ở cột màu đỏ bên trái. Đồ họa thì khỏi bàn rồi, cực kỳ đỉnh cao. Gần đây người ta cũng tích hợp AI qua giao thức MCP để điều khiển Unreal rất ấn tượng. Nhưng cái giá phải trả thì có 1 số điểm như:

- Máy trạm phải rất khủng, build C++ mỗi lần mất cả buổi.
- Có những case study thử nghiệm chạy 1 cái demo nhỏ bằng Unreal mà đốt tới hơn hai nghìn rưỡi đô tiền token API!

Lựa chọn thứ hai phổ biến hơn là **Unity** ở cột giữa. Unity dùng ngôn ngữ C# rất quen thuộc, kho asset bạt ngàn Nhưng nó bị vướng đúng 2 điểm chí mạng khi làm việc với AI Agent:

- Thứ nhất là cái gọi là 'The Editor Gap' — tức là AI nó gõ code xong, mình vẫn phải tự cầm chuột mở lên để kéo thả component, gắn biến bằng tay. Nó không tự động hóa hoàn toàn từ đầu đến đuôi được.
- Thứ hai là mỗi lần sửa xong 1 file script, Unity nó phải 'Domain Reload' mất tầm 3 đến 5 giây. Nghe 3-5 giây thì tưởng ít, nhưng khi AI nó tự chạy vòng lặp test 20-30 lần liên tục thì việc này làm đứt hẳn nhịp làm việc của Agent.

Và đó là lý do vì sao em chọn **Godot Engine 4**. Với cá nhân em, Godot nó có 3 yếu tố mà AI cực kỳ thích:

- Thứ nhất: **Toàn bộ cấu trúc Scene của Godot (.tscn) là văn bản thuần (Plain Text)**. Tức là AI nó đọc hiểu 100% cấu trúc file mà không cần con người phải đụng chuột kéo thả. Nó cũng giống việc các dự án áp dụng AI hiện tại đều chuyển qua markdown cũng vì lý do tương tự đấy ạ
- Ngoài ra 1 số lý do khác như Agent vừa sửa code xong là tự gõ lệnh chạy kiểm tra logic ngay lập tức, cực kỳ nhanh. Và cuối cùng engine này siêu nhẹ, và chi phí API cũng rẻ nữa.

Sau khi đã chốt được engine rồi, thì em sắp xếp AI làm việc như sau

*(👉 Bấm Next sang Slide 4)*

---

## 📌 SLIDE 4: PHÂN VAI AGENT (ARCHITECT VS BUILDER & NGUYÊN TẮC BÀN GIAO)

Dạo này lướt mạng, chắc mọi người cũng hay thấy cái trend người ta test mấy con model AI mới bằng mấy cái video YouTube kiểu: *'Thử thách làm game chỉ bằng 1 prompt duy nhất'* hay là *'Build cả con game trong 10 phút'*.

Nhưng mà thú thật với mọi người, đấy chỉ là mấy con game siêu đơn giản thôi. Chứ bước vào một dự án game thật có chiều sâu, nếu mình cũng bắt chước ném một cái prompt thật to bảo AI tự làm hết cả con game, thì em đảm bảo là chỉ sau vài bước thôi là dự án nát bét ngay.

Sau vài lần bị vỡ trận như thế, em mới đi mò mẫm học hỏi kinh nghiệm từ các anh em AI Game Dev thực chiến. Thì em học đc 1 điều như này, e cx note phía dưới slide

> *"Stop asking AI to build the whole game at once. Let the architect plan, let the builder execute."*
> *(Tạm dịch: Đừng bao giờ bắt AI làm cả con game cùng một lúc. Hãy để Kiến trúc sư lập kế hoạch, và để Thợ thi công gõ code).*

Và áp dụng đúng câu nói đó, em đã tách đội ngũ AI của mình thành 2 vai trò hoàn toàn độc lập như mọi người thấy trên màn hình:

- **Bên thứ nhất là Architect — Kiến trúc sư (em dùng Claude):**Claude có nhiệm vụ đọc hiểu toàn bộ cấu trúc repo, phân tích luồng dữ liệu, lường trước rủi ro và viết ra một bản đặc tả kỹ thuật (Spec) thật chi tiết. 
- **Bên thứ hai là Builder — Thợ thi công (em dùng GPT-5.6 Sol trong Antigravity Agent):**Con Builder này sẽ cầm bản spec của Claude, dùng các bộ Godot Domain Skills thi công code, viết test cô lập và nộp lại báo cáo. Builder chỉ làm đúng trong phạm vi được giao, không được tự ý sửa lan man.
- **Và ở giữa chính là Con người chúng ta (Human Approve):**
  Mình đứng làm trọng tài kiểm soát phạm vi và duyệt hợp đồng bàn giao trước khi cho code.

Nhưng mà muốn duyệt được kế hoạch và giao việc đúng cho AI, thì bản thân người làm phải hiểu được bản chất vận hành của game. Đặc biệt là những ai ít chơi game thì rất dễ bị ngợp ở khâu này. Em xin mời mọi người sang Slide 5 để xem một case study sống còn: Cơ chế Va chạm (Collision) ạ...

*(👉 Bấm Next sang Slide 5)*

---

## 📌 SLIDE 5: NỀN TẢNG CỐT LÕI (HIỂU GAME MECHANICS TRƯỚC KHI PROMPT)

Sang slide này, em muốn dành một chút thời gian để nói về một thứ cực kỳ quan trọng, đặc biệt là với những anh chị em nào ít chơi game nhưng lại muốn thử dùng AI làm game: đó là **Hiểu Game Mechanics (Cơ chế game)**.

Nếu mình không hiểu cơ chế game, mình sẽ chỉ biết mở cửa sổ chat lên rồi gõ một câu prompt chung chung kiểu: *'Làm cho nhân vật đi tới bắn con quái vật'* — thì đảm bảo là con AI nó sẽ đoán mò và sinh ra code sai logic ngay lập tức.

Để minh họa cụ thể, em xin lấy một Case Study nhập môn sống còn nhất trong game: đó là **Cơ chế Va chạm (Collision)**.

Em từng dính trong dự án: **Bug 'Vũng nước nuốt mũi tên'**.

Lúc đó em điều khiển nhân vật đứng bên này bờ hồ bắn cung sang con quái bên kia bờ, thì mũi tên cứ bay ngang qua vũng nước là tự nhiên biến mất hút, không làm sao bắn trúng quái được!

Hóa ra nguyên nhân rất ngớ ngẩn: Vì lúc trước em prompt bảo AI tạo vũng nước, thế là AI nó tiện tay gán luôn vũng nước thành một cái **Solid Collider (Vật cản cứng)** như một tảng đá! Mũi tên bay đụng vật cản là tự hủy luôn.

Sau khi em phát hiện ra cơ chế, em chỉ cần viết đúng một dòng đặc tả kỹ thuật cho Claude: *'Chuyển vũng nước thành Area2D,  tuyệt đối không va chạm với Layer mũi tên'*.

Thế là con AI nó vào sửa đúng 1 nốt nhạc, chạy chuẩn 100% luôn!

Đó, cho nên bài học ở đây là: **Muốn AI code đúng, thì bản thân mình phải hiểu cơ chế game để viết spec chuẩn**.

Và nói về cơ chế game thì mỗi loại game sẽ có thể thêm vài cơ chế khác nhau, FPS, openworld....

*(👉 Bấm Next sang Slide 6)*

---

## 📌 SLIDE 6: RULE 1 (DUYỆT KẾ HOẠCH TRƯỚC KHI SỬA CODE)

em rút ra 3 quy tắc khi lam game. Quy tắc đầu tiên: **Tuyệt đối không cho AI gõ code khi chưa duyệt Plan**.

Cái bẫy lớn nhất là hễ gặp lỗi, mình lại prompt vội: *'Fix lỗi này giùm tao'*. AI nó sẽ vào sửa mò, fix được chỗ này thì làm gãy chỗ khác thành một chuỗi sụp đổ dây chuyền.

Quy trình chuẩn của em gồm 3 bước rất nhanh:

1. **AI khảo sát repo:** Tách biệt rõ tầng UI, tầng Data và tầng Input.
2. **AI viết kế hoạch (file `bugfix_plan.md`):** Nêu rõ nguyên nhân gốc rễ, danh sách file sẽ can thiệp và diff dự kiến.
3. **Mình duyệt phạm vi:** Thấy an toàn rồi mới cho phép AI sửa file.

Bài học chốt ở đây rất ngắn gọn: **Viết plan thì rất rẻ, nhưng code sai rồi đi sửa lại mới cực kỳ đắt.** Bỏ ra 2 phút duyệt plan sẽ cứu được cả buổi chiều debug của mọi người.

*(👉 Bấm Next sang Slide 7)*

---

## 📌 SLIDE 7: RULE 2 (MỘT TASK, MỘT PHIÊN MỚI - TRÁNH Ô NHIỄM NGỮ CẢNH)

Quy tắc số 2: **One Job, One Fresh Session — Mỗi task là một phiên chat sạch hoàn toàn**.

Nhiều người có thói quen mở đúng 1 cửa sổ chat rồi nói chuyện từ sáng tới chiều: vừa code di chuyển, vừa làm bắn cung, vừa làm quái vật. Kết quả như cột bên trái mọi người thấy:

- Ngữ cảnh bị ô nhiễm nặng nề (Context Pollution).
- AI bắt đầu hallucination, sinh ra mấy lỗi ngớ ngẩn.
- Chưa kể mỗi lần prompt là phải đọc lại cả đống lịch sử chat cũ, đốt token gấp 3 lần bình thường.

Cách làm đúng ở cột bên phải: **Mỗi task chỉ làm trong 1 phiên độc lập**.

- Chỉ nạp đúng bản spec và các file liên quan đến task đó.
- Vừa tiết kiệm 65% chi phí token, vừa đảm bảo AI luôn có một cái đầu sạch 100% để không bị nhớ nhầm.

*(👉 Bấm Next sang Slide 8)*

---
