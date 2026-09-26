# 09 — Troubleshooting: เจอปัญหา แก้ตรงนี้

ค้นหาอาการด้วย `Ctrl + F` (Mac: `⌘ + F`) แล้วพิมพ์ข้อความ error ที่เห็น · แก้ไม่ได้ภายใน 3 นาที → **ยกมือเรียก TA**

## สารบัญ

- [SSH](#ssh)
- [Claude Code (AI CLI)](#claude-code)
- [HyperFrames (ตัดต่อวิดีโอ)](#hyperframes)
- [Deploy / Nginx / Cloudflare](#deploy)
- [อื่น ๆ](#other)

---

<a id="ssh"></a>

## 🔑 SSH

<a id="ssh-is-not-recognized"></a>

### `'ssh' is not recognized as an internal or external command` (Windows)

Windows ยังไม่ได้เปิดฟีเจอร์ OpenSSH Client

1. `Settings` → `System` → `Optional features` (Windows 10: `Apps` → `Optional features`)
2. กด **View features / Add a feature** → ค้นหา `OpenSSH Client` → **Install**
3. ปิด-เปิด Terminal ใหม่ แล้วลอง `ssh -V`

หรือใช้ PowerShell แบบ **Run as Administrator** แล้ววาง:

```powershell
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
```

### `Permission denied, please try again.`

รหัสผ่านผิด หรือชื่อผู้ใช้ผิด

- ตรวจชื่อผู้ใช้ในคำสั่ง `ssh trainee01@...` ตรงกับบัตรไหม (ตัวพิมพ์เล็ก-ใหญ่มีผล)
- พิมพ์รหัสผ่านใหม่ช้า ๆ (มองไม่เห็นตัวอักษรเป็นเรื่องปกติ) — ระวัง Caps Lock และภาษาไทย/อังกฤษ
- ลองวางรหัสผ่านด้วยคลิกขวา (Windows) / `⌘ + V` (Mac)

### `Connection timed out` หรือค้างนานไม่มีอะไรขึ้น

- ตรวจ IP ในคำสั่งตรงกับบัตรไหม
- Wi-Fi บางเครือข่ายบล็อก port 22 → ลองสลับไป Wi-Fi สำรอง / Hotspot มือถือ
- ถ้ายังไม่ได้ → TA ตรวจว่า VM เปิดอยู่และ Firewall เปิด port 22

### `Connection refused`

VM เปิดอยู่แต่บริการ SSH ไม่ทำงาน → แจ้ง TA

### `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!`

เกิดเมื่อทีมงานสร้าง VM ใหม่ให้ที่ IP เดิม ลบข้อมูลเครื่องเก่าที่จำไว้ด้วยคำสั่งนี้ (บนเครื่องตัวเอง แทน IP ด้วยของตัวเอง):

```bash
ssh-keygen -R 203.0.113.10
```

แล้ว `ssh` ใหม่ ตอบ `yes`

### SSH หลุดเอง (`client_loop: send disconnect: Broken pipe`)

เกิดจากเน็ตสะดุดหรือปล่อยไว้นาน — SSH ใหม่ แล้วเปิด Claude Code ต่อจากเดิม:

```bash
cd ~/myapp && claude --continue
```

---

<a id="claude-code"></a>

## 🤖 Claude Code (AI CLI)

<a id="claude-command-not-found"></a>

### `claude: command not found`

ติดตั้งแล้วแต่ Terminal ยังหาไม่เจอ:

```bash
# เพิ่มที่อยู่โปรแกรมเข้า PATH แล้วโหลดค่าใหม่
grep -q '.local/bin' ~/.bashrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
claude --version
```

ถ้ายังไม่ได้ ตรวจว่าไฟล์มีอยู่จริง:

```bash
ls -la ~/.local/bin/claude
```

ไม่มีไฟล์ → ติดตั้งใหม่: `curl -fsSL https://claude.ai/install.sh | bash`

### ติดตั้งแล้วขึ้น `curl: (6) Could not resolve host` หรือค้าง

VM ออกอินเทอร์เน็ตไม่ได้ ทดสอบ:

```bash
curl -sI https://claude.ai | head -n 1
```

ไม่มีผลลัพธ์ → แจ้ง TA (ปัญหาเครือข่าย VM)

<a id="claude-glm"></a>

### เชื่อม GLM ไม่ได้: `API Error`, `401`, `Invalid API key`, `authentication_error`

API Key ผิดหรือวางไม่ครบ → ออกจาก Claude Code (`/exit`) แล้ว **วางบล็อกตั้งค่าในขั้นที่ 2.1 ของ [03_VIBE_CODING_WORKSHOP](03_VIBE_CODING_WORKSHOP.md) ใหม่ทั้งบล็อก** (จะเขียนทับไฟล์เดิม) ระวังเว้นวรรคหน้า-หลัง key

ตรวจว่าไฟล์ตั้งค่าถูกต้อง (ไม่แสดง key):

```bash
python3 -m json.tool ~/.claude/settings.json > /dev/null && echo "ไฟล์ถูกรูปแบบ" ; grep -o '"ANTHROPIC_BASE_URL": "[^"]*"' ~/.claude/settings.json
```

### Claude Code ขึ้นหน้าเลือกวิธีล็อกอิน (Select login method) ทั้งที่ตั้งค่า GLM แล้ว

ไฟล์ `~/.claude/settings.json` ไม่มีหรือเขียนผิด → กด `Ctrl + C` สองครั้ง แล้ววางบล็อกตั้งค่าในขั้นที่ 2.1 ใหม่

### ส่งคำสั่งแล้วค้างนาน / `Connection error` / `timeout`

VM ติดต่อ GLM ไม่ได้ ทดสอบ (ทีมงานจะแจ้งที่อยู่ GLM):

```bash
curl -sI https://your-glm-endpoint | head -n 1
```

ไม่มีผลลัพธ์ → แจ้ง TA (ปัญหาเครือข่าย หรือ GLM ล่ม)

### ขึ้น `model not found` / `unknown model`

ชื่อโมเดลในไฟล์ตั้งค่าไม่ตรงกับที่ GLM มี → แจ้ง TA ให้ตรวจชื่อโมเดล

### AI บอกว่า `sudo: a password is required` หรือ `sudo: a terminal is required`

User ของ VM ยังไม่ได้ตั้ง sudo แบบไม่ต้องใส่รหัสผ่าน → แจ้ง TA หรือใช้ **🛟 ทางสำรอง** ใน [07_DEPLOY_CLOUDFLARE](07_DEPLOY_CLOUDFLARE.md) โดยออกจาก Claude Code แล้ววางคำสั่งเอง (จะถามรหัสผ่าน VM — ใส่รหัสจากซอง)

### AI ทำงานนานมาก / วนไปวนมา

กด `Esc` เพื่อหยุด แล้วพิมพ์สั่งให้ชัดขึ้น เช่น:

```text
หยุดก่อน ตอนนี้ทำถึงไหนแล้ว สรุปให้ฟังสั้น ๆ แล้วรอคำสั่งต่อไป
```

### ขึ้น `rate limit` / `usage limit` / `credit balance is too low`

บัญชี AI ใช้งานเกินโควตา → แจ้ง TA เพื่อสลับบัญชี / API Key

### เผลอกด No แล้ว AI หยุด

พิมพ์บอกต่อได้เลย เช่น `ทำขั้นตอนเดิมต่อได้เลย ฉันอนุญาต`

---

<a id="hyperframes"></a>

## 🎬 HyperFrames (ตัดต่อวิดีโอ)

### `hyperframes: command not found`

ยังไม่ได้ติดตั้งแบบ global → ใช้ `npx hyperframes` แทน `hyperframes` ได้ทุกคำสั่ง เช่น `npx hyperframes doctor` (ครั้งแรกจะดาวน์โหลดประมาณ 1 นาที) และแจ้ง TA

### `hyperframes doctor` ขึ้น `✗` ที่ FFmpeg / Chrome / Node.js

| แถวที่ `✗` | แก้ |
|---|---|
| FFmpeg | `sudo apt-get install -y ffmpeg` |
| Chrome | `hyperframes browser ensure` |
| Node.js ต่ำกว่า 22 | แจ้ง TA (ต้องติดตั้ง Node.js 22 ใหม่) |

### เปิด `http://localhost:3002` ไม่ขึ้น

1. หน้าต่าง SSH ที่มี `-L 3002:localhost:3002` ยังเปิดอยู่ไหม — ถ้าปิดไปแล้ว SSH ใหม่ด้วยคำสั่งในขั้นที่ 1 ของ [04_MEDIA_WORKSHOP](04_MEDIA_WORKSHOP.md)
2. Preview บน VM รันอยู่ไหม — บน VM ในโฟลเดอร์ `~/myvideo` วาง:

```bash
cd ~/myvideo && hyperframes preview --background --port 3002
```

### ตอน SSH ขึ้น `bind [127.0.0.1]:3002: Address already in use`

เครื่องเราใช้ port 3002 อยู่แล้ว (เช่นเปิด SSH หลายหน้าต่าง) → ปิดหน้าต่าง SSH อื่นก่อน หรือใช้ port อื่นบนเครื่องเรา แล้วเปิด `http://localhost:3003` แทน:

```bash
ssh -L 3003:localhost:3002 trainee01@203.0.113.10
```

### ตัวหนังสือภาษาไทยในวิดีโอเป็นสี่เหลี่ยม □□□

VM ไม่มีฟอนต์ไทย → แจ้ง TA หรือติดตั้งเอง แล้ว render ใหม่:

```bash
sudo apt-get install -y fonts-thai-tlwg fonts-noto-core
```

### Render ช้ามาก / ล้ม / ขึ้น `Killed` หรือ out of memory

บอก AI ว่า:

```text
render ใหม่แบบ draft โดยใช้ --workers 1 --low-memory-mode
```

ถ้าคลิปยาวเกิน 30 วินาที ให้สั่งตัดให้สั้นลงก่อน

### AI ไม่ใช้ HyperFrames / เขียนวิดีโอแบบอื่น

skill ยังไม่ได้ติดตั้ง หรือ AI ไม่ได้เรียกใช้:

1. ออกจาก Claude Code (`/exit`) → `cd ~ && hyperframes skills update` → เปิด `claude` ใหม่ในโฟลเดอร์ `~/myvideo`
2. ขึ้นต้น prompt ด้วย `/hyperframes` เสมอ

### ดาวน์โหลดด้วย `scp` ขึ้น `No such file or directory`

ยัง render ไม่เสร็จ หรือชื่อไฟล์ต่าง → บน VM ตรวจด้วย `ls -lh ~/myvideo/renders/` แล้วแก้ชื่อไฟล์ในคำสั่ง `scp` ให้ตรง

---

<a id="deploy"></a>

## 🌐 Deploy / Nginx / Cloudflare

### `curl http://localhost` ได้หน้า "Welcome to nginx!" แทนเว็บเรา

config default ยังเปิดอยู่ หรือยังไม่ได้คัดลอกไฟล์:

```bash
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/myapp
sudo cp -r ~/myapp/. /var/www/myapp/
sudo nginx -t && sudo systemctl reload nginx
curl -s http://localhost | head -n 5
```

### `curl http://localhost` ขึ้น `Connection refused`

nginx ไม่ได้ทำงาน:

```bash
sudo systemctl status nginx --no-pager
```

ถ้าเป็น `failed` → ดูสาเหตุ:

```bash
sudo nginx -t
sudo journalctl -u nginx --no-pager -n 20
```

`bind() to 0.0.0.0:80 failed (98: Address already in use)` → มีโปรแกรมอื่นใช้ port 80 อยู่ → แจ้ง TA

### ขึ้น `403 Forbidden`

ไม่มีไฟล์ `index.html` ใน `/var/www/myapp` หรือ nginx อ่านไม่ได้:

```bash
ls -la /var/www/myapp
sudo cp -r ~/myapp/. /var/www/myapp/
sudo chmod -R a+rX /var/www/myapp
```

### ขึ้น `404 Not Found`

ไฟล์หน้าแรกไม่ได้ชื่อ `index.html` — ดูชื่อไฟล์ด้วย `ls ~/myapp` แล้วบอก AI ว่า `เปลี่ยนชื่อไฟล์หน้าแรกเป็น index.html แล้วคัดลอกไป /var/www/myapp ใหม่`

### เปิด `http://IP` จากเบราว์เซอร์ไม่ได้ (แต่ `curl localhost` บน VM ได้)

port 80 ถูกปิด:

```bash
sudo ufw status
```

ถ้า `Status: active` → `sudo ufw allow 80/tcp` · ถ้า `inactive` → Security Group ของ Cloud ปิด port 80 → แจ้ง TA

### เปิดโดเมนแล้วขึ้น `DNS_PROBE_FINISHED_NXDOMAIN` / `This site can't be reached`

- DNS ยังไม่กระจาย → รอ 1–2 นาที ลองใหม่ / ลองจากมือถือที่ใช้ 4G
- ตรวจชื่อใน Cloudflare สะกดตรงกับ URL ที่พิมพ์ไหม
- ตรวจจาก VM:

```bash
getent hosts trainee01.your-training-domain.com
```

ได้ IP กลับมา (จะเป็น IP ของ Cloudflare ไม่ใช่ IP ของ VM — ถูกต้องเพราะเปิดเมฆส้ม) = DNS ใช้ได้แล้ว

### Cloudflare `Error 521: Web server is down`

Cloudflare ติดต่อ VM ที่ port 80 ไม่ได้ → nginx ไม่ทำงาน หรือ port 80 ปิด → ตรวจ 2 หัวข้อด้านบน

### Cloudflare `Error 522: Connection timed out`

IP ใน A record ผิด หรือ Firewall บล็อก → ตรวจ IP ใน Cloudflare ตรงกับบัตรไหม

### Cloudflare `Error 525 / 526` (SSL handshake failed)

โซนตั้ง SSL/TLS mode เป็น Full/Strict แต่ VM ไม่มี HTTPS → **ทีมงาน**ต้องตั้ง SSL/TLS mode ของโซนเป็น **Flexible** (ดู [instructor/01_STAFF_PREPARATION](../instructor/01_STAFF_PREPARATION.md))

### เว็บขึ้นแต่เป็นเวอร์ชันเก่า

```bash
sudo cp -r ~/myapp/. /var/www/myapp/
```

แล้วกด `Ctrl + Shift + R` ในเบราว์เซอร์ (ถ้ายังไม่เปลี่ยน อาจติด cache ของ Cloudflare — รอสักครู่)

### เปิดได้แต่เป็น `http://` ไม่มีกุญแจ

Proxy status ยังเป็นเมฆเทา (DNS only) → Cloudflare → DNS → Records → **Edit** → เปลี่ยนเป็น 🟠 **Proxied** → Save

### `ERR_TOO_MANY_REDIRECTS`

ถ้าให้ AI เพิ่มการ redirect ไป https ใน nginx จะวนกับ Cloudflare Flexible → บอก AI ว่า `ลบการ redirect จาก http ไป https ใน config nginx ออก แล้ว reload`

---

<a id="other"></a>

## 🧩 อื่น ๆ

### วางคำสั่งแล้วมีบรรทัดแปลก ๆ `^[[200~`

Terminal ไม่รองรับการวางแบบนั้น → กด `Ctrl + C` แล้ววางใหม่ทีละบรรทัด หรือใช้คลิกขวาวาง

### Terminal ค้าง พิมพ์อะไรไม่ขึ้น

- กด `Ctrl + C`
- ถ้าเผลอกด `Ctrl + S` (หยุดหน้าจอ) → กด `Ctrl + Q`
- ถ้ายังค้าง ปิดหน้าต่าง Terminal เปิดใหม่ แล้ว `ssh` เข้าใหม่

### เผลอเข้าโปรแกรม `nano` / `vim` ออกไม่เป็น

- `nano` (มีเมนูด้านล่าง): กด `Ctrl + X` → ถ้าถามว่าบันทึกไหม กด `N`
- `vim` (หน้าจอมี `~` ด้านซ้าย): กด `Esc` แล้วพิมพ์ `:q!` กด `Enter`

### ภาษาไทยใน PowerShell เป็น `?????`

ไม่มีผลต่อการทำงาน — แต่ถ้าต้องการให้แสดงถูก ใช้ **Windows Terminal** แทน PowerShell หน้าต่างสีน้ำเงิน
