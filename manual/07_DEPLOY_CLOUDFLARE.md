# 07 — Deploy จริง: ขึ้นเว็บด้วย Nginx + Certbot + Cloudflare DNS

**เวลา:** 14.20–14.50 น. (30 นาที) · **ใช้:** VS Code (Remote - SSH) + Claude Code + Cloudflare Dashboard

**เป้าหมาย:** นำเครื่องมือที่สร้างใน Workshop 2 ขึ้นอินเทอร์เน็ตจริง เปิดได้จากมือถือที่ `https://trainee01.your-training-domain.com` พร้อมกุญแจ 🔒

## สิ่งที่ต้องรู้ก่อน

```mermaid
flowchart LR
    U["📱 มือถือ / เบราว์เซอร์<br/>https://trainee01.your-training..."] -->|"1. ถาม DNS: ชื่อนี้อยู่ที่ IP ไหน"| CF["☁️ Cloudflare DNS<br/>(เมฆสีเทา · DNS only)"]
    CF -->|"2. ตอบ IP ของ VM"| U
    U -->|"3. เข้าเว็บตรงที่ VM (port 443)"| N["🌐 Nginx บน VM<br/>+ ใบรับรองจาก Certbot"]
    N -->|"4. อ่านไฟล์"| F["📄 /var/www/myapp/index.html"]
```

| คำ | ความหมายแบบง่าย |
|---|---|
| **Nginx** (อ่านว่า "เอ็นจิ้น-เอ็กซ์") | โปรแกรม "พนักงานเสิร์ฟเว็บ" — รอรับคนเข้าเว็บแล้วส่งไฟล์ให้ |
| **Certbot** | โปรแกรมขอ **ใบรับรอง HTTPS (กุญแจ 🔒) ฟรี** จาก Let's Encrypt แล้วตั้งค่าให้ Nginx อัตโนมัติ |
| **DNS** | "สมุดโทรศัพท์ของอินเทอร์เน็ต" แปลงชื่อเว็บ → IP |
| **A record** | บรรทัดในสมุด DNS: "ชื่อนี้ → IP นี้" |
| **DNS only (เมฆสีเทา)** | Cloudflare ทำหน้าที่แค่สมุดโทรศัพท์ คนเข้าเว็บจะวิ่งตรงไปที่ VM — Certbot จึงยืนยันโดเมนกับ VM ได้ |
| **Port 80 / 443** | "ประตู" ของเว็บ: 80 = http · 443 = https |

### แผนผังขั้นตอน (3 ขั้น)

| ขั้น | ทำที่ | เวลา | ผลที่ควรเห็น |
|---|---|---|---|
| 1. ติดตั้ง Nginx + Certbot | VM (สั่ง AI) | 10 นาที | เปิด `http://203.0.113.10` เห็นเว็บ |
| 2. เพิ่ม DNS record (เมฆสีเทา) | Cloudflare Dashboard | 10 นาที | มีแถว `trainee01` · `DNS only` |
| 3. ขอ HTTPS ด้วย Certbot + ทดสอบ | VM (สั่ง AI) + มือถือ | 10 นาที | เปิด `https://trainee01.your-training...` เห็นกุญแจ 🔒 |

> 📌 **ต้องทำตามลำดับนี้** — Certbot ขอใบรับรองได้ก็ต่อเมื่อ DNS ชี้มาที่ VM แล้ว (ขั้นที่ 2 ต้องเสร็จก่อนขั้นที่ 3)

---

## ขั้นที่ 1 — ให้ AI ติดตั้ง Nginx + Certbot (10 นาที)

### 1.1 เข้า VM และเปิด Claude Code ต่อจากเมื่อเช้า

เปิด VS Code → กด `><` มุมซ้ายล่าง → **Connect to Host...** → เลือก IP ของตัวเอง → เปิด Terminal (**Terminal → New Terminal**)

```bash
# เข้าโฟลเดอร์เดิม แล้วเปิด Claude Code คุยต่อจากครั้งล่าสุด
cd ~/myapp && claude --continue
```

> ถ้าขึ้นว่าไม่มีบทสนทนาเดิม ใช้ `cd ~/myapp && claude` แทนได้

### 1.2 วาง prompt นี้ใน Claude Code

```text
ช่วยนำเว็บในโฟลเดอร์นี้ขึ้นเว็บจริงด้วย nginx ตามขั้นตอนนี้:
1. ติดตั้ง nginx, certbot และ python3-certbot-nginx ด้วย sudo apt-get install -y (ถ้ายังไม่มี) — ยังไม่ต้องขอใบรับรองตอนนี้
2. สร้างโฟลเดอร์ /var/www/myapp แล้วคัดลอกไฟล์ทั้งหมดในโฟลเดอร์ปัจจุบันไปไว้ที่นั่น
3. สร้างไฟล์ config ชื่อ /etc/nginx/sites-available/myapp ให้ nginx รับทุกชื่อโดเมนที่ port 80 (listen 80 default_server และ server_name _) แล้วแสดงไฟล์จาก /var/www/myapp โดยมี index.html เป็นหน้าแรก
4. ลบลิงก์ config default เดิมใน /etc/nginx/sites-enabled แล้วเปิดใช้ config myapp แทน
5. ตรวจ config ด้วย nginx -t แล้ว reload nginx
6. ถ้ามี firewall ufw เปิดอยู่ ให้อนุญาต port 80 และ 443
7. ทดสอบด้วย curl http://localhost แล้วแสดงผล 10 บรรทัดแรกให้ดู
ทำทีละขั้นและอธิบายเป็นภาษาไทยสั้น ๆ ว่าแต่ละขั้นทำอะไร
```

AI จะขออนุญาตรันคำสั่งทีละคำสั่ง (เช่น `sudo apt-get install -y nginx certbot python3-certbot-nginx`) → อ่านแล้วกด **1. Yes** (ถ้าเปิดด้วย `ccc` AI จะทำเลยไม่ถาม)

### 1.3 ตรวจผลด้วยตัวเอง

```bash
!curl -s http://localhost | head -n 5
```

✅ **ผลที่ควรเห็น:** HTML ของเครื่องมือเรา (ไม่ใช่หน้า "Welcome to nginx!")

### 1.4 ลองเปิดจากเบราว์เซอร์ด้วย IP

เปิดเบราว์เซอร์บนเครื่องตัวเอง (หรือมือถือ) ไปที่:

```text
http://203.0.113.10
```

✅ **ผลที่ควรเห็น:** หน้าเว็บเครื่องมือของเรา 🎉 (ยังเป็น `http` ไม่มีกุญแจ — ขั้นที่ 3 จะได้ HTTPS)

<details>
<summary>🛟 <b>ทางสำรอง</b> — ถ้า AI ทำไม่สำเร็จ หรือเวลาไม่พอ: ออกจาก Claude Code (<code>/exit</code>) แล้ววางคำสั่งชุดนี้ทีละบล็อก</summary>

```bash
# 1) ติดตั้ง nginx และ certbot
sudo apt-get update && sudo apt-get install -y nginx certbot python3-certbot-nginx
```

```bash
# 2) คัดลอกไฟล์เว็บไปไว้ในโฟลเดอร์ที่ nginx อ่านได้
sudo mkdir -p /var/www/myapp
sudo cp -r ~/myapp/. /var/www/myapp/
```

```bash
# 3) สร้างไฟล์ config ของ nginx
sudo tee /etc/nginx/sites-available/myapp > /dev/null <<'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    root /var/www/myapp;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF
```

```bash
# 4) ปิด config เดิม เปิด config ของเรา ตรวจ แล้ว reload
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/myapp
sudo nginx -t && sudo systemctl reload nginx
```

```bash
# 5) ถ้ามี firewall (ufw) เปิดอยู่ ให้อนุญาต port 80 และ 443 (ถ้าไม่มี ufw บรรทัดนี้จะข้ามไปเอง)
sudo ufw status | grep -q "Status: active" && sudo ufw allow 'Nginx Full' || echo "ufw ไม่ได้เปิด — ข้ามได้"
```

```bash
# 6) ทดสอบ
curl -s http://localhost | head -n 5
```

✅ `nginx -t` ต้องขึ้น `syntax is ok` และ `test is successful`

</details>

---

## ขั้นที่ 2 — เพิ่ม DNS Record ใน Cloudflare แบบเมฆสีเทา (10 นาที)

### 2.1 ล็อกอิน

1. เปิด <https://dash.cloudflare.com> บนเครื่องตัวเอง
2. ล็อกอินด้วยบัญชีที่ทีมงานแจก
3. คลิกโดเมน `your-training-domain.com` (หรือโดเมนที่วิทยากรแจ้ง) ในรายการ

### 2.2 เพิ่ม A record

1. เมนูซ้าย → **DNS** → **Records**
2. กดปุ่ม **+ Add record**
3. กรอกข้อมูล:

| ช่อง | กรอก | หมายเหตุ |
|---|---|---|
| **Type** | `A` | |
| **Name** | `trainee01` | **ชื่อ subdomain ตามบัตรของตัวเอง** — ห้ามซ้ำคนอื่น, ใช้ a–z, 0–9, `-` เท่านั้น |
| **IPv4 address** | `203.0.113.10` | **Public IP ของ VM ตัวเอง** ตามบัตร |
| **Proxy status** | ⚪ **DNS only** (เมฆสีเทา) | **ปิด** สวิตช์ Proxy — ถ้าเป็นเมฆสีส้ม ให้กดสวิตช์ให้เป็นสีเทา |
| **TTL** | `Auto` | ค่าเริ่มต้น |

4. กด **Save**

✅ **ผลที่ควรเห็น:** ตาราง DNS มีแถวใหม่ `A | trainee01 | 203.0.113.10 | DNS only`

> ⚠️ **ห้ามแก้หรือลบ record ของคนอื่น** — ทุกคนใช้โดเมนเดียวกัน ถ้ากดผิดให้แจ้ง TA ทันที
>
> ⚠️ ถ้าช่อง Name กรอกแล้วชื่อเต็มแสดงเป็น `trainee01.your-training-domain.com` = ถูกต้อง ไม่ต้องพิมพ์ชื่อเต็มเอง

### 2.3 ตรวจว่า DNS ชี้มาที่ VM แล้ว

ใน Terminal ของ VS Code (แทน `trainee01` ด้วย subdomain ของตัวเอง):

```bash
getent hosts trainee01.your-training-domain.com
```

✅ **ผลที่ควรเห็น:** ขึ้น **IP ของ VM ตัวเอง** (เช่น `203.0.113.10`) — ถ้ายังไม่มีผลลัพธ์ รอ 1–2 นาทีแล้วลองใหม่

> ❗ ถ้าขึ้น IP อื่นที่ไม่ใช่ของ VM (เช่นขึ้นต้นด้วย `104.` หรือ `172.`) แปลว่ายังเปิดเมฆสีส้มอยู่ → กลับไปแก้เป็น **DNS only**

---

## ขั้นที่ 3 — ขอ HTTPS ด้วย Certbot แล้วทดสอบ (10 นาที)

### 3.1 สั่ง AI ขอใบรับรอง

วางใน Claude Code (แก้ `trainee01` เป็น subdomain ของตัวเอง):

```text
ช่วยขอใบรับรอง HTTPS ให้โดเมน trainee01.your-training-domain.com ด้วย certbot ตามขั้นตอนนี้:
1. แก้ server_name ใน /etc/nginx/sites-available/myapp จาก _ เป็น trainee01.your-training-domain.com แล้ว nginx -t และ reload
2. รัน certbot --nginx -d trainee01.your-training-domain.com --non-interactive --agree-tos --register-unsafely-without-email --redirect
3. ทดสอบด้วย curl -sI https://trainee01.your-training-domain.com แล้วแสดงผล 5 บรรทัดแรก
ถ้ามี error ให้อธิบายสาเหตุเป็นภาษาไทยสั้น ๆ
```

<details>
<summary>🛟 <b>ทางสำรอง</b> — ถ้า AI ทำไม่สำเร็จ: ออกจาก Claude Code (<code>/exit</code>) แล้ววางคำสั่งชุดนี้</summary>

```bash
# แก้ trainee01 เป็น subdomain ของตัวเองในบรรทัดแรกก่อนกด Enter
D=trainee01.your-training-domain.com
sudo sed -i "s/server_name _;/server_name $D;/" /etc/nginx/sites-available/myapp
sudo nginx -t && sudo systemctl reload nginx
sudo certbot --nginx -d "$D" --non-interactive --agree-tos --register-unsafely-without-email --redirect
```

✅ Certbot ขึ้น `Successfully received certificate` และ `Congratulations! You have successfully enabled HTTPS`

</details>

### 3.2 ทดสอบจาก VM ก่อน (เร็วที่สุด)

```bash
curl -sI https://trainee01.your-training-domain.com | head -n 5
```

✅ **ผลที่ควรเห็น:**

```text
HTTP/1.1 200 OK
Server: nginx/...
...
```

`200 OK` + `Server: nginx` = **HTTPS ทำงานบน VM ของเราแล้ว**

### 3.3 เปิดจากมือถือ / เบราว์เซอร์

```text
https://trainee01.your-training-domain.com
```

✅ **ผลที่ควรเห็น:** เว็บเครื่องมือของเรา พร้อมไอคอนกุญแจ 🔒 ที่แถบที่อยู่ 🎉🎉

> 📌 **ส่ง URL ของตัวเองให้วิทยากร** (กรอกในเอกสารกลาง / กระดาน) เพื่อโชว์ช่วงปิดท้าย

### 3.4 ไม่สำเร็จ? ดูอาการแล้วแก้ตามนี้

| อาการ | สาเหตุ | วิธีแก้ |
|---|---|---|
| Certbot แจ้ง `DNS problem: NXDOMAIN` | DNS ยังไม่ชี้มาที่ VM | ตรวจ record ในขั้นที่ 2 · รอ 1–2 นาที แล้วรัน certbot ใหม่ |
| Certbot แจ้ง `Timeout during connect` | port 80 ถูกปิด | แจ้ง TA เปิด port 80 และ 443 |
| Certbot แจ้ง `Could not automatically find a matching server block` | server_name ยังไม่ได้แก้ | ทำข้อ 1 ในขั้นที่ 3.1 ใหม่ |
| `getent hosts` ขึ้น IP ของ Cloudflare | ยังเปิดเมฆสีส้ม | แก้ record เป็น **DNS only** |
| เปิด `https://` ไม่ได้ แต่ `http://` ได้ | port 443 ถูกปิด | แจ้ง TA |
| เว็บขึ้นแต่ไม่มีกุญแจ | ยังไม่ได้รัน Certbot สำเร็จ | ทำขั้นที่ 3.1 ใหม่ |
| Certbot แจ้ง `too many certificates` | ขอใบรับรองซ้ำเกินโควตาของ Let's Encrypt | แจ้งวิทยากร |

รายละเอียดเพิ่มเติม: [09_TROUBLESHOOTING.md](09_TROUBLESHOOTING.md#deploy)

---

## 🔁 แก้เว็บแล้วอยากให้หน้าเว็บจริงเปลี่ยนตาม

เมื่อสั่ง AI แก้ไฟล์ใน `~/myapp` แล้ว ไฟล์ที่ nginx ใช้ (`/var/www/myapp`) จะยังเป็นของเดิม — บอก AI ว่า:

```text
แก้เสร็จแล้วให้คัดลอกไฟล์ทั้งหมดในโฟลเดอร์นี้ไปทับที่ /var/www/myapp ด้วย
```

หรือวางคำสั่งเอง:

```bash
sudo cp -r ~/myapp/. /var/www/myapp/
```

แล้วรีเฟรชเบราว์เซอร์ (ถ้ายังไม่เปลี่ยน กด `Ctrl + Shift + R` เพื่อล้าง cache)

---

## ⚠️ ข้อควรระวัง

- เว็บนี้ **เปิดสาธารณะ** ทุกคนบนอินเทอร์เน็ตเข้าได้ — ห้ามใส่ข้อมูลส่วนบุคคล / ข้อมูลภายในหน่วยงาน
- VM และโดเมนนี้ใช้ **เพื่อการอบรมเท่านั้น** ทีมงานจะปิดหลังจบการอบรม — ถ้าจะใช้งานจริง ต้องผ่าน IT ของหน่วยงาน
- ห้ามพิมพ์รหัสผ่าน / API Key ลงในไฟล์เว็บ

➡️ ต่อไป: สรุปการอบรม · อ้างอิงคำสั่งทั้งหมด [08_CHEATSHEET.md](08_CHEATSHEET.md)
