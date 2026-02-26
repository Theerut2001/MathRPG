# 🧠 Math Battle RPG
Math Battle RPG is a Turn-Based Educational RPG game built with Godot Engine.  
Players must solve math problems to perform actions during combat.
---

## 🎮 Game Overview
Math Battle RPG combines:
- 📚 Mathematics practice
- ⚔️ Turn-Based RPG mechanics
- 🔁 Endless enemy progression
- 🎨 Randomized battle backgrounds
Answer correctly to attack, defend, heal, or use special skills!
---

## 🕹 Gameplay Mechanics

### Turn Flow
1. Player chooses an action
2. A math problem appears
3. Player answers
4. If correct → action succeeds
5. If wrong → action fails
6. Enemy takes turn
7. Repeat
---

## ⚔️ Actions
| Action   | Difficulty | Description                      |
|----------|------------|----------------------------------|
| Attack   | Easy       | Basic damage                     |
| Defend   | Easy       | Reduce incoming damage by 50%    |
| Heal     | Hard       | Restore HP (Cooldown: 2 turns)   |
| Special  | Very Hard  | Heavy damage (Cooldown: 3 turns) |
---

## 🧮 Math System
- Supports integers
- Supports decimals
- Supports fractions (e.g., `3/4`)
- Difficulty scales with action type
---

## 👾 Enemy System
- 10 unique enemies
- Endless loop system
- After defeating all 10:
  - Enemies restart
  - HP increases
  - Damage increases
---

## 🌄 Background System
- 10 battle backgrounds
- Randomized every new enemy encounter
- No consecutive duplicate backgrounds
---

## ⏸ Pause Menu
- Resume
- Try Again
- Return to Main Menu
---

## 🏆 Upgrade System
After defeating enemies:
- Increase Max HP
- Increase Damage
- Improve Healing power
---

## 🛠 Project Structure
main.gd         → Game state & turn logic
combat.gd       → Damage & combat calculation
math_gen.gd     → Math problem generator
battler.gd      → Animation controller
game_manager.gd → Scene management
pause_menu.gd   → Pause system
---

## 🎯 Educational Purpose
This project is designed to:
- Improve math skills
- Encourage problem-solving
- Demonstrate game logic using Godot
---

## 🧑‍💻 Built With
- Godot Engine 4.x
- GDScript
---

## 📜 License
For educational purposes.
---

# 🧠 Math Battle RPG
Math Battle RPG คือเกมแนว Turn-Based RPG เชิงการศึกษา  
พัฒนาโดยใช้ Godot Engine
ผู้เล่นจะต้องแก้โจทย์คณิตศาสตร์ให้ถูกต้อง  
เพื่อใช้ท่าทางโจมตี ป้องกัน ฮีล หรือสกิลพิเศษ
---

## 🎮 ภาพรวมเกม
เกมนี้ผสมผสานระหว่าง
- 📚 การฝึกคณิตศาสตร์
- ⚔️ ระบบต่อสู้แบบเทิร์น (Turn-Based)
- 🔁 ระบบ Endless Mode
- 🎨 ระบบพื้นหลังสุ่ม
ตอบถูก = ใช้สกิลสำเร็จ  
ตอบผิด = เสียเทิร์น
---

## 🔄 ระบบการเล่น
ลำดับการเล่นในแต่ละรอบ:
1. ผู้เล่นเลือกคำสั่ง
2. ระบบสุ่มโจทย์ตามระดับความยาก
3. ผู้เล่นตอบคำถาม
4. ถ้าตอบถูก → ใช้สกิลได้
5. ถ้าตอบผิด → เสียเทิร์น
6. ศัตรูทำการโจมตีหรือฮีล
7. วนกลับมาที่ผู้เล่น
---

## ⚔️ คำสั่งในเกม
| คำสั่ง     | ระดับความยาก | คำอธิบาย                     |
|----------|-------------|-----------------------------|
| Attack   | ง่าย         | โจมตีปกติ                     |
| Defend   | ง่าย         | ลดดาเมจ 50%                 |
| Heal     | ยาก         | ฟื้น HP (Cooldown 2 เทิร์น)     |
| Special  | ยากมาก      | ดาเมจรุนแรง (Cooldown 3 เทิร์น) |
---

## 🧮 ระบบโจทย์คณิตศาสตร์
รองรับ:
- จำนวนเต็ม
- ทศนิยม
- เศษส่วน เช่น `3/4`
- สมการเชิงเส้น
- สมการกำลังสอง (ระดับยาก)
---

## 👾 ระบบศัตรู
- มีศัตรู 10 ตัว
- เมื่อชนะครบ 10 ตัว จะวนกลับตัวแรก
- แต่จะเก่งขึ้น:
  - HP เพิ่ม
  - ดาเมจเพิ่ม
  - ความยากเพิ่ม
---

## 🌄 ระบบพื้นหลัง
- มีพื้นหลัง 10 แบบ
- เปลี่ยนแบบสุ่มทุกครั้งที่เจอศัตรูใหม่
- ไม่สุ่มซ้ำติดกัน
---

## ⏸ เมนูหยุดเกม
- Resume → เล่นต่อ
- Try Again → เริ่มใหม่
- Main Menu → กลับหน้าหลัก
---

## 🛠 โครงสร้างไฟล์หลัก
main.gd → ควบคุมสถานะเกม
combat.gd → ระบบคำนวณดาเมจ
math_gen.gd → สุ่มโจทย์คณิต
battler.gd → ระบบแอนิเมชัน
game_manager.gd → จัดการเปลี่ยนฉาก
pause_menu.gd → ระบบเมนูหยุดเกม
---

## 🎯 วัตถุประสงค์ของโปรเจกต์
- ฝึกทักษะคณิตศาสตร์
- เรียนรู้การพัฒนาเกมด้วย Godot
- ประยุกต์ใช้ OOP และระบบ State Machine
---

## 🧑‍💻 พัฒนาโดย
Godot Engine 4.x  
GDScript
---