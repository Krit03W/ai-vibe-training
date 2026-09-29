# 09 — Troubleshooting: เจอปัญหา แก้ตรงนี้

ค้นหาอาการด้วย `Ctrl + F` (Mac: `⌘ + F`) แล้วพิมพ์ข้อความ error ที่เห็น · แก้ไม่ได้ภายใน 3 นาที → **ยกมือเรียก TA**

## สารบัญ

- [SSH](#ssh)
- [VS Code Remote - SSH](#vscode)
- [Claude Code (AI CLI)](#claude-code) · [GitHub (gh / push)](#github)
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

- ตรวจชื่อผู้ใช้ในคำสั่ง `ssh admins@...` ตรงกับบัตรไหม (ตัวพิมพ์เล็ก-ใหญ่มีผล)
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

<a id="vscode"></a>

### VS Code: `Could not establish connection to "…"`

- ตรวจ IP / ชื่อผู้ใช้ — กด `><` → **Connect to Host...** → **Configure SSH Hosts...** → เปิดไฟล์ config แล้วดูว่าบรรทัด `HostName` และ `User` ถูกไหม
- ลองเข้าด้วย Terminal ธรรมดา `ssh admins@IP` (คู่มือ 02 หัวข้อ 2) — ถ้า Terminal ก็เข้าไม่ได้ ดูหัวข้อ SSH ด้านบน

### VS Code ค้างที่ `Setting up SSH Host … (Downloading VS Code Server)`

ครั้งแรก VS Code ต้องดาวน์โหลดตัวเชื่อมต่อลง VM (ประมาณ 1 นาที) ถ้านานเกิน 3 นาที:

1. `Ctrl + Shift + P` → พิมพ์ `Remote-SSH: Kill VS Code Server on Host...` → เลือก IP ของตัวเอง
2. เชื่อมต่อใหม่ — ถ้ายังไม่ได้ แจ้ง TA (VM อาจออกอินเทอร์เน็ตไม่ได้)

### VS Code ถามรหัสผ่านหลายครั้ง

ปกติสำหรับการเชื่อมต่อครั้งแรกและตอนเปิดโฟลเดอร์ ถ้าอยากเลิกพิมพ์รหัสผ่าน ใช้ SSH Key ตาม [linux/02_PUBLICKEY.md](linux/02_PUBLICKEY.md)

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

API Key ผิดหรือวางไม่ครบ → ออกจาก Claude Code (`/exit`) แล้วเปิดไฟล์แก้ key ใหม่ใน VS Code (ดูขั้นที่ 2.3 ของ [03_VIBE_CODING_WORKSHOP](03_VIBE_CODING_WORKSHOP.md)):

```bash
code ~/.claude/settings.json
```

ระวัง: key ต้องอยู่ในเครื่องหมาย `" "` · ไม่มีเว้นวรรคหน้า-หลัง · ห้ามลบเครื่องหมาย `,` ท้ายบรรทัด

ตรวจว่าไฟล์ตั้งค่าถูกต้อง (ไม่แสดง key):

```bash
python3 -m json.tool ~/.claude/settings.json > /dev/null && echo "ไฟล์ถูกรูปแบบ" ; grep -o '"ANTHROPIC_BASE_URL": "[^"]*"' ~/.claude/settings.json
```

### Claude Code ขึ้นหน้าเลือกวิธีล็อกอิน (Select login method) ทั้งที่ตั้งค่า GLM แล้ว

ไฟล์ `~/.claude/settings.json` ไม่มีหรือเขียนผิด → กด `Ctrl + C` สองครั้ง แล้ววางบล็อกตั้งค่าในขั้นที่ 2.3 ใหม่

### ส่งคำสั่งแล้วค้างนาน / `Connection error` / `timeout`

VM ติดต่อ GLM ไม่ได้ ทดสอบ (ทีมงานจะแจ้งที่อยู่ GLM):

```bash
curl -sI https://coding.modelharbor.com | head -n 1
```

ไม่มีผลลัพธ์ → แจ้ง TA (ปัญหาเครือข่าย หรือ GLM ล่ม)

### ขึ้น `model not found` / `unknown model`

ชื่อโมเดลในไฟล์ตั้งค่าไม่ตรงกับที่ GLM มี → แจ้ง TA ให้ตรวจชื่อโมเดล

### AI บอกว่า `sudo: a password is required` หรือ `sudo: a terminal is required`

User ของ VM ยังไม่ได้ตั้ง sudo แบบไม่ต้องใส่รหัสผ่าน → ออกจาก Claude Code (`/exit`) แล้วทำ [02_SSH_VM หัวข้อ 4.1](02_SSH_VM.md#sudo-nopasswd) จากนั้นเปิด `claude --continue` ใหม่ · ถ้ายังไม่ได้ ใช้ **🛟 ทางสำรอง** ใน [07_DEPLOY_CLOUDFLARE](07_DEPLOY_CLOUDFLARE.md) โดยออกจาก Claude Code แล้ววางคำสั่งเอง (จะถามรหัสผ่าน VM — ใส่รหัสจากซอง)

### พิมพ์ `/grill-with-docs` แล้วขึ้น `Unknown command` / AI ไม่รู้จัก skill

- ตรวจว่าติดตั้งแล้ว: `ls ~/.claude/skills` ต้องเห็นชื่อ skill
- ถ้ายังไม่มี: `npx -y skills@latest add Krit03W/krit-engineer-skills -g -a claude-code -s '*' -y`
- **ออกจาก Claude Code (`/exit`) แล้วเปิดใหม่** — skill ที่ติดตั้งระหว่างเปิดอยู่จะยังไม่ถูกโหลด

### skill ขอให้รัน `/setup-krit-skills` หรือถามเรื่อง GitHub / issue tracker

ยังไม่มีไฟล์ `CONTEXT.md` → ทำ [03 ขั้นที่ 2.6](03_VIBE_CODING_WORKSHOP.md#step-2-6) หรือพิมพ์บอก AI ว่า `ไม่ต้องตั้งค่า issue tracker ใช้แบบ local ตาม CONTEXT.md`

<a id="github"></a>

### GitHub: `gh auth login` / `git push` ไม่สำเร็จ

| อาการ | แก้ |
|---|---|
| `gh: command not found` | ทำ [03 ขั้นที่ 2.5](03_VIBE_CODING_WORKSHOP.md#gh-login) ข้อ 1 ใหม่ |
| ใส่โค้ดไม่ทัน / `expired` | รัน `gh auth login --hostname github.com --git-protocol https --web` ใหม่ ได้โค้ดใหม่ |
| หน้า `github.com/login/device` ให้ล็อกอินก่อน | ล็อกอิน GitHub ในเบราว์เซอร์เครื่องตัวเอง (ยืนยัน 2FA ถ้ามี) แล้วใส่โค้ดอีกครั้ง |
| `git push` ขึ้น `Authentication failed` / `could not read Username` | `gh auth setup-git` แล้ว `git push` ใหม่ |
| `gh repo create` ขึ้น `Name already exists on this account` | ใช้ชื่ออื่น: `gh repo create myapp-ai-training --private --source=. --remote=origin --push` |
| `git push` ขึ้น `! [rejected] ... (fetch first)` | `git pull --rebase origin main && git push` |
| `error: src refspec main does not match any` | ยังไม่มี commit: `git add -A && git commit -m "เริ่มโปรเจกต์" && git push -u origin main` |
| `Author identity unknown` ตอน commit | ทำ 03 ขั้นที่ 2.5 ข้อ 3 (ตั้งชื่อผู้เขียน commit) |

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

### `npx: command not found` หรือ `node: command not found`

Node.js ยังไม่ได้ติดตั้ง → วาง **บล็อก 1** ในขั้นที่ 2 ของ [04_MEDIA_WORKSHOP](04_MEDIA_WORKSHOP.md) ใหม่อีกครั้ง

### `npx hyperframes doctor` ขึ้น `✗` ที่ FFmpeg / Chrome / Node.js

| แถวที่ `✗` | แก้ |
|---|---|
| FFmpeg / FFprobe | `sudo apt-get install -y ffmpeg` |
| Chrome | `curl -fsSL -o /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && sudo apt-get install -y /tmp/chrome.deb` |
| Node.js ต่ำกว่า 22 | `curl -fsSL https://deb.nodesource.com/setup_22.x \| sudo -E bash - && sudo apt-get install -y nodejs` |

แก้แล้วรัน `npx hyperframes doctor` ตรวจอีกครั้ง

### ติดตั้งแล้วขึ้น `Could not get lock /var/lib/dpkg/lock`

เครื่องกำลังอัปเดตตัวเองอยู่เบื้องหลัง → รอ 1–2 นาที แล้ววางบล็อกเดิมใหม่

### เปิด `http://localhost:3002` ไม่ขึ้น

1. VS Code ยังเชื่อม VM อยู่ไหม (มุมซ้ายล่างขึ้น `SSH: …`) — ถ้าหลุด กด `><` → **Connect to Host...** ใหม่
2. แท็บ **PORTS** มี `3002` ไหม — ถ้าไม่มี กด **Forward a Port** → `3002`
3. Preview บน VM รันอยู่ไหม — ใน Terminal ของ VS Code วาง:

```bash
cd ~/myvideo && npx hyperframes preview --background --port 3002
```

### แท็บ PORTS ขึ้นว่า port ถูกใช้อยู่ / เปิดเป็น `localhost:3003`

เครื่องเรามีโปรแกรมอื่นใช้ port นั้นอยู่ VS Code จึงเลือกเลขใหม่ให้ → ดูคอลัมน์ **Forwarded Address** ในแท็บ PORTS แล้วเปิดตามที่อยู่นั้นแทน

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

1. ออกจาก Claude Code (`/exit`) → `cd ~ && npx hyperframes skills update` → เปิด `claude` ใหม่ในโฟลเดอร์ `~/myvideo`
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

ต้องได้ **IP ของ VM ตัวเอง** — ถ้าได้ IP อื่น (ขึ้นต้น `104.` / `172.`) แปลว่ายังเปิดเมฆสีส้ม → แก้ record เป็น **DNS only**

### Certbot: `DNS problem: NXDOMAIN looking up A for …`

DNS ยังไม่ชี้มาที่ VM → ตรวจ record ใน Cloudflare (Type `A`, Name ถูก, IP ถูก, **DNS only**) รอ 1–2 นาที แล้วรัน certbot ใหม่

### Certbot: `Timeout during connect (likely firewall problem)`

Let's Encrypt เข้า port 80 ของ VM ไม่ได้:

```bash
sudo ufw status
```

ถ้า `Status: active` → `sudo ufw allow 'Nginx Full'` · ถ้า `inactive` → Security Group ของ Cloud ปิด port 80 / 443 → แจ้ง TA

### Certbot: `Could not automatically find a matching server block`

`server_name` ใน config ยังเป็น `_` → แก้เป็นชื่อโดเมนของตัวเองก่อน (แทน `trainee01` ให้ตรง):

```bash
D=trainee01.your-training-domain.com
sudo sed -i "s/server_name _;/server_name $D;/" /etc/nginx/sites-available/myapp
sudo nginx -t && sudo systemctl reload nginx
```

แล้วรัน certbot ใหม่

### Certbot: `too many certificates (5) already issued for this exact set of identifiers`

ขอใบรับรองโดเมนเดิมซ้ำเกิน 5 ครั้งใน 7 วัน (โควตาของ Let's Encrypt) → แจ้งวิทยากร (ใช้ subdomain ใหม่ เช่น `trainee01b`)

### เปิดได้แต่เป็น `http://` ไม่มีกุญแจ

ยังไม่ได้รัน Certbot สำเร็จ → ทำขั้นที่ 3 ของ [07_DEPLOY_CLOUDFLARE](07_DEPLOY_CLOUDFLARE.md) ใหม่

### เปิด `https://` ไม่ได้ แต่ `http://` ได้

port 443 ถูกปิด → `sudo ufw allow 'Nginx Full'` หรือแจ้ง TA ตรวจ Security Group

### เว็บขึ้นแต่เป็นเวอร์ชันเก่า

```bash
sudo cp -r ~/myapp/. /var/www/myapp/
```

แล้วกด `Ctrl + Shift + R` ในเบราว์เซอร์

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
