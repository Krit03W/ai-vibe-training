# 03 — คู่มือ TA (ผู้ช่วยสอน)

อัตรา **TA 1 คน : ผู้อบรม 5–8 คน** · ช่วงที่ต้องประจำโต๊ะเต็มที่: เบรกเช้า, Module 2, Deploy

## หลักการช่วยผู้อบรม

1. **ให้ผู้อบรมกดเอง** — ชี้ให้ดู อย่าแย่งคีย์บอร์ด (ยกเว้นเวลาเหลือน้อยมาก)
2. **อ่านหน้าจอก่อน** — ดูหน้าเคอร์เซอร์ก่อนเสมอ: อยู่เครื่องตัวเอง (`PS C:\>`) หรืออยู่ VM (`admins@...:~$`)?
3. **3 นาทีแล้วไม่หาย → ใช้ทางสำรอง** อย่าปล่อยให้คนตกขบวนทั้ง Module
4. **ห้ามถ่ายรูปหน้าจอที่มีรหัสผ่าน / API Key** และห้ามพิมพ์ key ลงไฟล์ให้ผู้อบรม

## จุดตรวจของแต่ละช่วง (ติ๊กรายชื่อ)

| ช่วง | ✅ ผ่านเมื่อ |
|---|---|
| ลงทะเบียน | `ssh -V` ขึ้นเวอร์ชัน |
| เบรกเช้า | SSH เข้า VM ได้ + `sudo: OK` |
| Module 2 ขั้นที่ 2 | `claude --version` ขึ้นเวอร์ชัน + AI ตอบคำถามทดสอบเป็นภาษาไทย (เชื่อม GLM สำเร็จ) |
| Module 2 จบ | `ls ~/myapp` มี `index.html` |
| Module 3B | เปิด `http://localhost:3002` เห็น Studio + มี `~/myvideo/renders/promo.mp4` |
| Deploy ขั้นที่ 1 | เปิด `http://<IP>` จากเบราว์เซอร์เห็นเว็บ |
| Deploy จบ | Certbot สำเร็จ + เปิด `https://<subdomain>.<โดเมน>` เห็นเว็บ 🔒 |

## คำสั่งตรวจเครื่องผู้อบรมแบบรวดเดียว (วางบน VM ของผู้อบรม)

```bash
echo "== user/host =="; whoami; hostname
echo "== sudo =="; sudo -n true && echo OK || echo "ต้องใส่รหัส (ต้องแก้)"
echo "== claude =="; command -v claude && claude --version || echo "ไม่พบ claude"
echo "== glm settings =="; test -f ~/.claude/settings.json && grep -o '"ANTHROPIC_BASE_URL": "[^"]*"' ~/.claude/settings.json || echo "ยังไม่ได้ตั้งค่า GLM"
echo "== myapp =="; ls -la ~/myapp 2>/dev/null || echo "ไม่มีโฟลเดอร์ ~/myapp"
echo "== myvideo =="; ls -la ~/myvideo/renders 2>/dev/null || echo "ยังไม่มีวิดีโอ"
echo "== port 8080 =="; curl -s -o /dev/null -w '%{http_code}\n' --max-time 3 http://localhost:8080
echo "== nginx =="; systemctl is-active nginx 2>/dev/null || echo "ยังไม่ติดตั้ง"
echo "== port 80 =="; curl -s -o /dev/null -w '%{http_code}\n' --max-time 3 http://localhost
echo "== ufw =="; sudo ufw status 2>/dev/null | head -n 1
```

## ปัญหาที่พบบ่อย (เรียงตามความถี่ที่คาด)

| อาการ | สาเหตุที่พบบ่อย | แก้ |
|---|---|---|
| `Permission denied` ตอน SSH | พิมพ์รหัสผิด / สลับภาษาไทย / Caps Lock | ให้วางรหัสด้วยคลิกขวา |
| วางคำสั่งแล้ว `'ssh' is not recognized` | Windows ไม่มี OpenSSH | ดู troubleshooting หรือให้ใช้เครื่องสำรอง |
| วางคำสั่ง Linux ลงใน PowerShell ของเครื่องตัวเอง | ยังไม่ได้ SSH | ดูหน้าเคอร์เซอร์ → SSH ก่อน |
| `claude: command not found` | PATH ยังไม่โหลด | `source ~/.bashrc` |
| AI ตอบ `401` / `Invalid API key` | วาง key ไม่ครบ / มีเว้นวรรค | วางบล็อกตั้งค่า GLM ในคู่มือ 03 ขั้นที่ 2.3 ใหม่ |
| ขึ้นหน้าเลือกวิธีล็อกอิน | ไม่มี `~/.claude/settings.json` | วางบล็อกตั้งค่า GLM ใหม่ |
| `localhost:3002` ไม่ขึ้น | ยังไม่ได้ Forward port / preview ไม่รัน | แท็บ PORTS → Forward a Port `3002` / `npx hyperframes preview --background --port 3002` ใน `~/myvideo` |
| ตัวไทยในวิดีโอเป็น □□□ | ไม่มีฟอนต์ไทย | `sudo apt-get install -y fonts-thai-tlwg fonts-noto-core` แล้ว render ใหม่ |
| AI ขอ sudo แล้วค้าง/ล้มเหลว | ไม่ได้ตั้ง NOPASSWD | `echo "$USER ALL=(ALL) NOPASSWD:ALL" \| sudo tee /etc/sudoers.d/90-training-$USER` (ใส่รหัสผู้อบรม) |
| AI สร้างไฟล์ผิดโฟลเดอร์ | เปิด `claude` นอก `~/myapp` | ย้ายไฟล์: `mv ~/index.html ~/myapp/` |
| เว็บขึ้น "Welcome to nginx!" | config default ยังเปิด | ดู troubleshooting หัวข้อ Deploy |
| Certbot `DNS problem` / `Timeout` | DNS ยังไม่ชี้มา / ยังเปิดเมฆส้ม / port 80 ปิด | ตรวจ `getent hosts โดเมน` ต้องได้ IP ของ VM · ตั้ง record เป็น DNS only · เปิด port 80/443 |
| SSH หลุด Claude หาย | เน็ตสะดุด | SSH ใหม่ → `cd ~/myapp && claude --continue` |

## สิ่งที่ TA ต้องมีติดตัว

- รายชื่อผู้อบรมในกลุ่ม + IP + subdomain (พิมพ์ใส่กระดาษ ไม่ต้องมีรหัสผ่าน)
- ซอง API Key สำรอง (ถ้าใช้)
- โน้ตบุ๊กที่ SSH ได้ (สำหรับเข้า VM ผู้อบรมช่วยแก้ ถ้าผู้อบรมอนุญาต)
- ลิงก์คู่มือ [`manual/09_TROUBLESHOOTING.md`](../manual/09_TROUBLESHOOTING.md) เปิดค้างไว้
