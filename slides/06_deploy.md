---
marp: true
theme: nti
paginate: true
header: 'AI + Vibe Coding + Deploy จริง'
footer: 'Deploy จริง · Nginx + Subdomain + Cloudflare DNS'
---

<!-- _class: lead -->
<!-- _paginate: false -->
<!-- _header: '' -->
<!-- _footer: '' -->

## ช่วงขยาย · 30 นาที

# Deploy จริง<br>ขึ้นเว็บด้วยโดเมนของตัวเอง

Nginx + Subdomain + Cloudflare DNS

---

## เป้าหมาย

เครื่องมือที่สร้างเมื่อเช้า → เปิดได้จากมือถือทุกที่

### `https://trainee01.your-training-domain.com` 🔒

```text
 📱 เบราว์เซอร์ ──(1) ถาม DNS──▶ ☁️ Cloudflare ──(2) port 80──▶ 🌐 Nginx บน VM ──(3)──▶ 📄 index.html
                                 (HTTPS ฟรี · เมฆส้ม)                (พนักงานเสิร์ฟเว็บ)       (ที่ AI สร้าง)
```

---

## คำศัพท์ 5 คำ

| คำ | ความหมายแบบง่าย |
|---|---|
| **Nginx** | โปรแกรม "พนักงานเสิร์ฟเว็บ" รอรับคนเข้าเว็บที่ port 80 |
| **Port 80** | "ประตูมาตรฐาน" ของเว็บ ไม่ต้องพิมพ์เลขต่อท้าย |
| **DNS** | "สมุดโทรศัพท์อินเทอร์เน็ต" ชื่อเว็บ → IP |
| **A record** | บรรทัดในสมุด: "ชื่อนี้ → IP นี้" |
| **Proxied 🟠** | Cloudflare เป็นด่านหน้า → **HTTPS อัตโนมัติ** |

---

<!-- _class: workshop -->

## ขั้นที่ 1 · ติดตั้ง Nginx โดยสั่ง AI (10 นาที)

```bash
ssh trainee01@203.0.113.10
cd ~/myapp && claude --continue
```

วาง prompt จากคู่มือ **07_DEPLOY_CLOUDFLARE** หัวข้อ 1.2 → AI ติดตั้ง nginx, คัดลอกไฟล์ไป `/var/www/myapp`, ตั้งค่า, reload

✅ ตรวจ: `!curl -s http://localhost | head -n 5` → HTML ของเรา
✅ เปิดเบราว์เซอร์: `http://203.0.113.10` → **เห็นเว็บ!** 🎉

🛟 AI ทำไม่สำเร็จ → `/exit` แล้วใช้ **คำสั่งสำรอง** ในคู่มือ (กล่อง 🛟)

---

<!-- _class: workshop -->

## ขั้นที่ 2 · เพิ่ม A record ใน Cloudflare (10–15 นาที)

`dash.cloudflare.com` → โดเมนอบรม → **DNS** → **Records** → **+ Add record**

| ช่อง | กรอก |
|---|---|
| Type | `A` |
| Name | `trainee01` ← **ตามบัตรตัวเอง** |
| IPv4 address | `203.0.113.10` ← **IP VM ตัวเอง** |
| Proxy status | 🟠 **Proxied** |
| TTL | `Auto` |

→ **Save** · ⚠️ **ห้ามแก้ / ลบ record ของคนอื่น**

---

<!-- _class: workshop -->

## ขั้นที่ 3 · ทดสอบ (5 นาที)

จาก VM ก่อน (เร็วที่สุด):

```bash
!curl -sI https://trainee01.your-training-domain.com | head -n 5
```

✅ `HTTP/2 200` + `server: cloudflare`

แล้วเปิดจาก **มือถือ** → เห็นกุญแจ 🔒 🎉🎉

📌 **ส่ง URL ของตัวเองเข้าเอกสารกลาง** — จะเปิดโชว์ช่วงปิดท้าย

---

## เข้าไม่ได้? ตรวจตามลำดับ

| # | ตรวจ | ไม่ผ่าน → |
|---|---|---|
| 1 | `curl http://localhost` บน VM | nginx มีปัญหา → คำสั่งสำรอง |
| 2 | เปิด `http://<IP>` จากเบราว์เซอร์ | port 80 ปิด → TA |
| 3 | Cloudflare: A · ชื่อถูก · IP ถูก · 🟠 | แก้ record |
| 4 | รอ 1–2 นาที ให้ DNS กระจาย | ลองใหม่ |
| 5 | ยังไม่ได้ | เรียก TA |

**Error 521** nginx ไม่รัน · **522** IP ผิด · **525/526** แจ้งวิทยากร

---

## 🔁 แก้เว็บต่อหลังจากนี้

บอก AI:

```text
แก้เสร็จแล้วให้คัดลอกไฟล์ทั้งหมดในโฟลเดอร์นี้ไปทับที่ /var/www/myapp ด้วย
```

หรือวางเอง: `sudo cp -r ~/myapp/. /var/www/myapp/` แล้ว `Ctrl + Shift + R`

⚠️ เว็บนี้ **เปิดสาธารณะ** — ห้ามใส่ข้อมูลส่วนบุคคล / ข้อมูลภายใน
⚠️ VM และโดเมนใช้ **เพื่อการอบรมเท่านั้น** — ใช้งานจริงต้องผ่าน IT ของหน่วยงาน
