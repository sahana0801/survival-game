# 🎬 PLAN REVISED: 3 Phases Demo — Tất Cả Dựa Trên Repo Gốc

> **Approach:** Clone repo gốc → Copy 3 bản → Strip down Phase 1 → Bug-ify Phase 2 → Phase 3 giữ nguyên

---

## Execution Flow

```
Step 1: git clone repo gốc vào Phase3/  (giữ nguyên = final product)
Step 2: Copy Phase3/ → Phase1/          (rồi strip down)
Step 3: Copy Phase3/ → Phase2/          (rồi thêm bugs cố ý)
```

---

## PHASE 1: "The First Prompt" — Strip Down Từ Repo Gốc

> **Narrative:** *"Đây là lần đầu AI generate. Chỉ có player đi trên map. Chưa có gì khác."*

### Giữ lại (từ repo gốc)
| Giữ | Lý do |
|-----|-------|
| ✅ Player sprite + animation thật | Cho thấy AI đã tạo ra sprite thật |
| ✅ TileMap gốc (terrain, grass, water) | Map thật nhưng trống trơn |
| ✅ Player movement (WASD) | Core mechanic |
| ✅ Camera2D follow | Cơ bản |
| ✅ `project.godot` (config) | Cần để chạy |

### Bỏ đi / Vô hiệu hóa
| Bỏ | Lý do demo |
|----|-----------|
| ❌ Tất cả enemies (slime, skeleton, frog) | "Chưa có enemies" |
| ❌ Inventory system (toàn bộ `inventory/` folder) | "Chưa có inventory" |
| ❌ Survival bars (health, hunger, thirst UI) | "Chưa có UI" |
| ❌ Day/Night cycle | "Chưa có day/night" |
| ❌ Bow & Arrow | "Chưa có combat" |
| ❌ NPC & Dialogue | "Chưa có NPC" |
| ❌ Spawner system | "Chưa spawn gì" |
| ❌ Main Menu & Pause Menu | Vào thẳng game |
| ❌ Game Over screen | Không cần |
| ❌ Camp fire, Chest, Apple trees | "Map trống trơn" |
| ❌ Shaders (hit flash) | "Chưa có effects" |
| ❌ Audio/Sounds | "Im lặng" |
| ❌ FPS counter, Message layer | "Chưa có UI phụ" |
| ❌ Gloot addon (inventory plugin) | Không cần |

### Kết quả khi chạy Phase 1
- Mở game → **vào thẳng map** (không main menu)
- Player sprite thật, animation thật, đi được WASD
- Map tilemap thật (cỏ, nước, terrain) nhưng **TRỐNG** — không cây, không enemy, không items
- Không có UI gì trên màn hình
- Không có âm thanh
- → **Audience thấy:** "À, bước đầu tiên chỉ có nhân vật đi trên map thôi"

### Files cần chỉnh trong Phase1/
```
Phase1/
├── project.godot          # SỬA: bỏ autoloads, main_scene → world trực tiếp
├── scene/
│   ├── world.tscn         # SỬA: xóa hết child nodes (enemies, NPC, items, spawner, UI...)
│   │                      #       chỉ giữ TileMap + Player
│   └── player.tscn        # SỬA: xóa hết child trừ AnimatedSprite2D, CollisionShape2D, Camera2D
├── script/
│   └── player.gd          # SỬA: strip xuống chỉ còn movement + animation
│                           #       bỏ health, hunger, bow, inventory, signals
├── art/                   # GIỮ NGUYÊN — cần sprites
│   ├── character/         # Player sprites
│   └── environment/       # Tilemap textures
└── (xóa hết folders không cần: inventory/, dialogue/, addons/, sounds/, shaders/)
```

### player.gd sau khi strip (dựa trên file gốc):
```gdscript
# Stripped from original — chỉ giữ movement
extends CharacterBody2D

const SPEED = 100

func _physics_process(_delta):
    handleInput()
    move_and_slide()

func handleInput():
    var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity = direction * SPEED
    
    # Animation — giữ từ code gốc nhưng simplified
    if velocity != Vector2.ZERO:
        if abs(velocity.x) > abs(velocity.y):
            if velocity.x > 0:
                $AnimatedSprite2D.play("walk_right")
            else:
                $AnimatedSprite2D.play("walk_left")
        else:
            if velocity.y > 0:
                $AnimatedSprite2D.play("walk_down")
            else:
                $AnimatedSprite2D.play("walk_up")
    else:
        $AnimatedSprite2D.stop()
```

---

## PHASE 2: "The Bug Reel" — Thêm Features + Bugs Cố Ý

> **Narrative:** *"Rồi AI thêm enemies và combat... nhưng kết quả thế này"*

### Giữ lại từ repo gốc
- ✅ Everything from Phase 1
- ✅ Slime enemy (sprite + animation thật)
- ✅ Bow & Arrow (sprite thật)
- ✅ Health bar UI
- ✅ Spawner (nhưng broken)
- ✅ Basic inventory UI (nhưng broken)

### Bugs cố ý tạo (sửa code gốc để tạo bug)

#### 🐛 Bug 1: "Slime Xuyên Tường"
**Sửa trong `slime.gd`:**
```gdscript
# Comment out move_and_slide() → slime di chuyển nhưng xuyên mọi thứ
func _physics_process(delta):
    if player != null:
        position += (player.position - position) / SPEED
        # move_and_slide()  ← BỎ DÒNG NÀY
```
→ Slime chase player nhưng **bay xuyên qua walls, trees, water**

#### 🐛 Bug 2: "Arrow Bắn Ngược"
**Sửa trong `arrow.gd`:**
```gdscript
# Đảo direction → arrow bay về phía player thay vì về phía mouse
velocity = -direction * speed  # thêm dấu trừ
```
→ Player bắn arrow, arrow bay **về phía sau** 😂

#### 🐛 Bug 3: "Player Bất Tử"
**Sửa trong `player.gd`:**
```gdscript
# Comment out phần giảm HP → enemy đánh nhưng không damage
func hurtByEnemy(area):
    # current_health -= 10  ← BỎ
    pass
```
→ Enemy đánh player liên tục nhưng HP **không giảm**

#### 🐛 Bug 4: "Slime Flood"
**Sửa trong `spawner.gd`:**
```gdscript
# Bỏ limit check → spawn vô hạn
var max_slimes = 9999  # thay vì 3
# Timer interval: 0.1 giây thay vì vài giây
```
→ Slimes spawn liên tục, **tràn ngập map** trong vài giây

#### 🐛 Bug 5: "Disco Day/Night"
**Sửa trong `day_and_night.gd`:**
```gdscript
# Tăng speed lên cực nhanh → ngày đêm thay đổi mỗi 2 giây
var day_length = 2.0  # thay vì 120 giây
```
→ Màn hình **nhấp nháy sáng/tối liên tục** như disco

### Kết quả khi chạy Phase 2
- Player di chuyển + bắn cung (nhưng arrow bay ngược)
- Slimes xuất hiện nhưng xuyên tường
- HP bar hiện nhưng không giảm khi bị đánh
- Nếu đợi vài giây → slimes tràn ngập
- Ngày/đêm thay đổi điên cuồng
- → **Audience cười nghiêng ngả** 😂

---

## PHASE 3: "The Final Product" — Repo Gốc Nguyên Bản

> **Narrative:** *"Sau khi iterate, fix bugs, thêm features... đây là kết quả cuối cùng"*

### Execution
```bash
git clone https://github.com/z3dd4-de/Survival-Game.git Phase3
```
- Giữ nguyên 100% repo gốc
- Tất cả features hoạt động: enemies, inventory, survival bars, day/night, combat, NPC, menus
- → **Audience: WOW, từ cái Phase 1 tới đây!** 😮

---

## 🔧 EXECUTION STEPS (cho Phase 1)

```
Step 1: Clone repo gốc
        git clone https://github.com/z3dd4-de/Survival-Game.git Phase3

Step 2: Copy cho Phase 1
        xcopy Phase3 Phase1 /E /I

Step 3: Strip Phase 1
        - Xóa folders: inventory/, dialogue/, addons/, sounds/, shaders/, font/
        - Xóa scenes không cần: main_menu, pause_menu, game_over, credits...
        - Sửa project.godot: bỏ autoloads, đổi main_scene
        - Sửa world.tscn: xóa child nodes (enemies, items, UI...)
        - Sửa player.tscn: xóa nodes combat/inventory  
        - Rewrite player.gd: chỉ movement + animation
        - Xóa scripts không cần

Step 4: Test Phase 1 — mở Godot → chạy → player đi trên map trống ✅
```

---

## 📊 So Sánh 3 Phases

| Feature | Phase 1 | Phase 2 | Phase 3 |
|---------|---------|---------|---------|
| Player sprite & animation | ✅ | ✅ | ✅ |
| TileMap world | ✅ (trống) | ✅ (có objects) | ✅ (đầy đủ) |
| Enemies | ❌ | ✅ (có bugs) | ✅ |
| Combat (bow/arrow) | ❌ | ✅ (arrow ngược) | ✅ |
| Inventory | ❌ | ✅ (broken) | ✅ |
| Health/Hunger/Thirst bars | ❌ | ✅ (HP ko giảm) | ✅ |
| Day/Night cycle | ❌ | ✅ (disco mode) | ✅ |
| Main Menu | ❌ | ❌ | ✅ |
| NPC/Dialogue | ❌ | ❌ | ✅ |
| Audio | ❌ | ❌ | ✅ |
| Spawner | ❌ | ✅ (vô hạn) | ✅ |
| **Audience reaction** | 😐 "basic" | 😂 "haha bugs" | 😮 "wow!" |

---

> [!IMPORTANT]
> **Approve plan này để tôi bắt đầu:**
> 1. Clone repo gốc
> 2. Copy ra Phase1
> 3. Strip down Phase1 cho đúng concept
> 
> Tất cả dùng sprites/assets THẬT từ repo gốc — không fake!
