# 08 — Cheatsheet: สรุปคำสั่งและ Prompt ในหน้าเดียว

พิมพ์หน้านี้แจก หรือเปิดค้างไว้ระหว่างอบรม · แทน `trainee01` และ `203.0.113.10` ด้วยข้อมูลตามบัตร VM ของตัวเอง

---

## 🔑 เข้า-ออก VM

| ทำอะไร | คำสั่ง | พิมพ์ที่ |
|---|---|---|
| เข้า VM ด้วย VS Code (วิธีหลัก) | `><` มุมซ้ายล่าง → **Connect to Host...** → `ssh trainee01@203.0.113.10` | VS Code |
| เปิด Terminal ของ VM | **Terminal → New Terminal** หรือ `` Ctrl + ` `` | VS Code |
| ส่งต่อ port ไว้ดูเว็บ / วิดีโอ | แท็บ **PORTS** → **Forward a Port** → `8080` และ `3002` | VS Code |
| ดูเว็บทดสอบ / Studio วิดีโอ | `http://localhost:8080` / `http://localhost:3002` | เบราว์เซอร์เครื่องตัวเอง |
| เปิดไฟล์บน VM ในตัวแก้ไข | `code ชื่อไฟล์` | Terminal ของ VS Code |
| เข้า VM ด้วย Terminal (ทางสำรอง) | `ssh trainee01@203.0.113.10` | เครื่องตัวเอง |
| ออกจาก VM | `exit` | VM |
| ตรวจว่าอยู่เครื่องไหน | ดูหน้าเคอร์เซอร์: `trainee01@...:~$` = VM | — |

## 📁 คำสั่งพื้นฐานบน VM

| คำสั่ง | ทำอะไร |
|---|---|
| `pwd` | ดูว่าอยู่โฟลเดอร์ไหน |
| `ls` / `ls -la` | ดูไฟล์ / ดูไฟล์ทั้งหมดแบบละเอียด |
| `cd ~/myapp` | เข้าโฟลเดอร์ myapp |
| `cd ~` | กลับโฟลเดอร์บ้าน |
| `mkdir -p ~/myapp` | สร้างโฟลเดอร์ |
| `cat index.html` | ดูเนื้อหาไฟล์ |
| `clear` | ล้างหน้าจอ |
| `↑` | เรียกคำสั่งก่อนหน้า |
| `Ctrl + C` | ยกเลิกคำสั่งที่ค้าง |

## 🤖 Claude Code (AI CLI)

| ทำอะไร | คำสั่ง |
|---|---|
| ติดตั้ง | `curl -fsSL https://claude.ai/install.sh \| bash` |
| เชื่อมกับ AI GLM | วางบล็อกตั้งค่าในคู่มือ 03 ขั้นที่ 2.3 (สร้าง `~/.claude/settings.json`) |
| เตรียมเครื่อง (VM ใหม่) | `sudo apt-get update -y && sudo apt-get install -y curl git ca-certificates nano` |
| เปิด (ในโฟลเดอร์งาน) | `cd ~/myapp && claude` |
| สร้างคำสั่งลัด `ccc` | `echo 'alias ccc="claude --permission-mode bypassPermissions"' >> ~/.bashrc && source ~/.bashrc` |
| ติดตั้ง Engineer Skills | `npx -y skills@latest add Krit03W/krit-engineer-skills -g -a claude-code -s '*' -y` |
| ให้ AI สัมภาษณ์ก่อนสร้าง | `/grill-with-docs …` (พิมพ์ใน Claude Code) |
| ต้นแบบหน้าตาหลายแบบ | `/prototype …` |
| ขั้นตอนแบบวิศวกร | `/to-spec` → `/to-tickets` → `/implement` → `/code-review` |
| เปิดแบบไม่ต้องกด Yes | `cd ~/myapp && ccc` (ใช้บน VM ฝึกเท่านั้น) |
| เปิดแล้วคุยต่อจากเดิม | `cd ~/myapp && claude --continue` |
| รันคำสั่งเองในหน้า Claude | `!คำสั่ง` เช่น `!ls` |
| หยุด AI กลางคัน | `Esc` |
| ล้างบทสนทนา | `/clear` |
| ออก | `/exit` |

## 🎬 ตัดต่อวิดีโอด้วย HyperFrames (Module 3)

| ทำอะไร | คำสั่ง | พิมพ์ที่ |
|---|---|---|
| ติดตั้งโปรแกรมเบื้องหลัง | วางบล็อก 1 ในคู่มือ 04 ขั้นที่ 2 | VM |
| ตรวจเครื่องพร้อมไหม | `npx -y hyperframes@latest doctor` | VM |
| ติดตั้ง skill ให้ AI | `cd ~ && npx hyperframes skills update` | VM |
| เตรียมโฟลเดอร์ + คลิป | `mkdir -p ~/myvideo/assets && cp /opt/training/media/* ~/myvideo/assets/` (ไม่มีคลิป → ใช้ prompt แบบ B) | VM |
| สั่ง AI | `cd ~/myvideo && claude` แล้วขึ้นต้น prompt ด้วย `/hyperframes` | VM |
| ดูตัวอย่าง | เปิด `http://localhost:3002` | เบราว์เซอร์เครื่องตัวเอง |
| render เอง | `npx hyperframes render --quality draft -o renders/promo.mp4` | VM (ใน `~/myvideo`) |
| ดาวน์โหลดคลิป | แถบซ้าย VS Code → `myvideo/renders/promo.mp4` → คลิกขวา → **Download...** | VS Code |
| อัปโหลดไฟล์ขึ้น VM | ลากไฟล์จากเครื่องไปวางในโฟลเดอร์ที่แถบซ้าย VS Code | VS Code |

## 🌐 Deploy

| ทำอะไร | คำสั่ง |
|---|---|
| ทดสอบเว็บทดสอบ (port 8080) | `curl -s http://localhost:8080 \| head` |
| ทดสอบ nginx (port 80) | `curl -s http://localhost \| head` |
| ตรวจ DNS ชี้มาที่ VM | `getent hosts trainee01.your-training-domain.com` |
| ทดสอบผ่านโดเมนจริง | `curl -sI https://trainee01.your-training-domain.com` |
| อัปเดตไฟล์เว็บหลังแก้ | `sudo cp -r ~/myapp/. /var/www/myapp/` |
| ดูสถานะ nginx | `sudo systemctl status nginx --no-pager` |
| ตรวจ config nginx | `sudo nginx -t` |
| reload nginx | `sudo systemctl reload nginx` |

**Cloudflare A record:** Type `A` · Name `trainee01` · IPv4 `IP ของ VM` · Proxy ⚪ **DNS only** (เมฆสีเทา) · TTL `Auto`

**ขอ HTTPS:** `sudo certbot --nginx -d trainee01.your-training-domain.com --non-interactive --agree-tos --register-unsafely-without-email --redirect` (หลัง DNS ชี้มาที่ VM แล้ว)

---

## ✍️ Prompt 5 องค์ประกอบ (Module 1)

```text
[บทบาท] คุณคือ...
[บริบท] ด้านล่างคือ... สำหรับ...
[งาน] ช่วย...
[รูปแบบ] เป็น... ไม่เกิน... ข้อ
[ข้อจำกัด] ใช้ภาษา... ห้าม... ถ้าข้อมูลไม่พอให้ตอบว่า "ไม่มีข้อมูล"
```

**สั่งแก้เฉพาะจุด:** `ย่อหน้าที่ 2 ให้เหลือ 2 บรรทัด ส่วนอื่นคงเดิม`

**กัน AI แต่งข้อมูล:** `ตอบจากเอกสารที่ให้เท่านั้น ถ้าไม่มีให้ตอบว่า "ไม่มีข้อมูลในเอกสาร"`

## 🎨 Prompt ภาพ (Module 3)

```text
ภาพประกอบ[แนวตั้ง 4:5] สไตล์[flat design]
เนื้อหา: [สิ่งที่ปรากฏ]
การจัดวาง: เว้นพื้นที่ว่าง[ด้านบน] 35% สำหรับข้อความ
โทนสี: [สี] ให้ความรู้สึก[อารมณ์]
ห้ามมี: ตัวอักษร โลโก้ ลายน้ำ ใบหน้าบุคคลจริง
```

## 🛡️ ก่อนส่งข้อมูลให้ AI (Module 4)

☐ ไม่มีชื่อ / เลขบัตร / เบอร์โทร / ที่อยู่ของคนจริง · ☐ ไม่ใช่ข้อมูลผู้รับบริการ · ☐ ไม่ใช่เอกสารลับ · ☐ ไม่มีรหัสผ่าน / API Key · ☐ ใช้บัญชีที่หน่วยงานอนุญาต · ☐ คนตรวจทานก่อนใช้จริง

**Masking:** ชื่อ → `นาย ก.` · บริษัท → `บริษัท X` · เลขบัตร → `X-XXXX-XXXXX-XX-X` · เบอร์ → `0XX-XXX-XXXX`

## 📚 RAG ในประโยคเดียว (Module 5)

**ค้นเอกสารของหน่วยงานที่เกี่ยวข้องก่อน → ให้ AI อ่านแล้วสรุปคำตอบ → แสดงแหล่งอ้างอิง**
