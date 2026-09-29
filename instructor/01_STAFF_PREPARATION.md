# 01 — Checklist ทีมงาน: เตรียมก่อนวันอบรม

ทำให้เสร็จ **ก่อนวันอบรมอย่างน้อย 3–5 วัน** · ทดสอบซ้ำอีกครั้ง **1 วันก่อนอบรม**

## ภาพรวมสิ่งที่ต้องเตรียม

| # | สิ่งที่ต้องเตรียม | ใช้ใน | ผู้รับผิดชอบ | เสร็จ |
|---|---|---|---|---|
| 1 | VM Ubuntu 1 เครื่อง/คน (+ สำรอง 2–3 เครื่อง) | Module 2, Deploy | ทีม Infra | ☐ |
| 2 | AI GLM: endpoint + ชื่อโมเดล + API Key ต่อคน (Claude Code เชื่อมผ่าน GLM) | Module 2, 3, Deploy | ทีม AI / Infra | ☐ |
| 2.1 | คลิปตัวอย่างสำหรับตัดต่อ + ทดสอบ HyperFrames render บน VM | Module 3 | วิทยากร | ☐ |
| 3 | Cloudflare Zone + สิทธิ์ผู้อบรม (record แบบ DNS only · HTTPS ด้วย Certbot บน VM) | Deploy | ทีม Infra | ☐ |
| 4 | บัตร VM + ซองรหัสผ่าน | ทั้งวัน | ผู้ประสานงาน | ☐ |
| 5 | แอปสำรองที่ deploy เสร็จแล้ว | Deploy | วิทยากร | ☐ |
| 6 | ระบบ RAG สำหรับสาธิต | Module 5 | วิทยากร | ☐ |
| 7 | อุปกรณ์ห้องอบรม (Wi-Fi สำรอง, ป้าย ได้/ไม่ได้, checklist พิมพ์) | ทั้งวัน | ผู้ประสานงาน | ☐ |
| 8 | TA 1 คน / ผู้อบรม 5–8 คน | Module 2, Deploy | ผู้ประสานงาน | ☐ |

---

## 0. เครื่องของผู้อบรม (โน้ตบุ๊ก)

ผู้อบรมเข้า VM ด้วย **VS Code + Remote - SSH** ตลอดวัน (คู่มือ 02 หัวข้อ 1)

- [ ] ติดตั้ง **VS Code** และส่วนเสริม **Remote - SSH** (ของ Microsoft) ล่วงหน้า — เครื่องหน่วยงานมักติดตั้งโปรแกรมเองไม่ได้ ให้ประสาน IT ติดตั้งให้ หรือเตรียม VS Code แบบ **User Installer / .zip** ไว้ใน USB
- [ ] เครือข่ายสถานที่อบรมออก port 22 ได้ (VS Code Remote - SSH ใช้ SSH เหมือนกัน)
- [ ] **แจ้งผู้อบรมล่วงหน้าให้สมัครบัญชี GitHub** (ฟรี <https://github.com/signup>) และล็อกอินได้บนเบราว์เซอร์ของโน้ตบุ๊กที่จะนำมา (ถ้าเปิด 2FA ต้องมีมือถือ/แอปยืนยันติดตัว) — ใช้ push งานใน Module 2 ด้วย `gh auth login`
- [ ] เครือข่ายสถานที่อบรมเข้า `github.com`, `api.github.com`, `cli.github.com` ได้
- [ ] VM ต้องออกอินเทอร์เน็ตได้ — ครั้งแรกที่เชื่อม VS Code จะดาวน์โหลด VS Code Server ลง VM (ประมาณ 100 MB ต่อเครื่อง ใช้ RAM ราว 300–500 MB ขณะเชื่อม)

## 1. VM (ต่อผู้อบรม 1 เครื่อง)

### สเปกขั้นต่ำ

| รายการ | ค่า |
|---|---|
| OS | Ubuntu Server 24.04 LTS (หรือ 22.04 LTS) |
| CPU / RAM / Disk | 2 vCPU / 4 GB / 20 GB (เอกสารของ Claude Code แนะนำ RAM 4 GB ขึ้นไป) |
| Public IP | IPv4 เป็นของตัวเอง 1 IP ต่อเครื่อง |
| Inbound ports | `22/tcp` (SSH), `80/tcp` (HTTP), `443/tcp` (HTTPS) |
| Outbound | อินเทอร์เน็ตเต็ม (ต้องดาวน์โหลด Claude Code, apt, เชื่อม API ของ AI) |

> 💡 จำกัด inbound port 80 ให้รับเฉพาะ [IP ranges ของ Cloudflare](https://www.cloudflare.com/ips/) ได้ แต่วันอบรม **ควรเปิดทั้งหมด** เพราะขั้นตอนในคู่มือให้ผู้อบรมทดสอบ `http://<IP>` จากเบราว์เซอร์ก่อนเพิ่ม DNS

### ตั้งค่าแต่ละเครื่อง

ใช้สคริปต์ [`scripts/setup_vm.sh`](scripts/setup_vm.sh) — รันบน VM แต่ละเครื่องด้วยสิทธิ์ root:

```bash
# บน VM (ในฐานะผู้ดูแล) — แทน trainee01 และรหัสผ่านตามรายชื่อ
curl -fsSL https://raw.githubusercontent.com/Krit03W/ai-vibe-training/main/instructor/scripts/setup_vm.sh -o setup_vm.sh
sudo bash setup_vm.sh trainee01 'รหัสผ่านของผู้อบรม'
```

สคริปต์จะทำ:

1. สร้าง user พร้อมรหัสผ่าน และเปิด SSH แบบใช้รหัสผ่าน
2. ให้สิทธิ์ `sudo` **แบบไม่ต้องใส่รหัสผ่าน (NOPASSWD)** — ⚠️ **จำเป็น** เพราะ Claude Code รันคำสั่งแบบไม่มี terminal ให้กรอกรหัส ถ้าไม่ตั้ง AI จะติดตั้ง nginx ไม่ได้
3. ติดตั้ง `curl`, `git`, `python3`, `qrencode` เท่านั้น — **ไม่ติดตั้ง** FFmpeg / Chrome / Node.js / HyperFrames เพราะผู้อบรมติดตั้งเองใน Workshop 3B
4. ตั้ง hostname เป็น `training-vm-<ชื่อผู้ใช้>` (ช่วยให้ TA ดูหน้าจอแล้วรู้ว่าเครื่องใคร)
5. สร้างโฟลเดอร์ `/opt/training/media` สำหรับคลิปตัวอย่าง (ต้องคัดลอกคลิปเข้าไปเอง — ดูหัวข้อ 2.2)
7. **ไม่** ติดตั้ง Claude Code และ **ไม่** ติดตั้ง nginx (ให้ผู้อบรมทำเองใน Workshop)

### ตรวจทุกเครื่องก่อนวันจริง

ใช้ [`scripts/check_vms.sh`](scripts/check_vms.sh) จากเครื่องทีมงาน (อ่านรายชื่อจาก CSV):

```bash
# ตรวจ port 22 และ HTTP ของทุกเครื่อง
bash instructor/scripts/check_vms.sh ~/secure/trainees.csv

# หลังเพิ่ม DNS แล้ว ตรวจ HTTPS ผ่าน Cloudflare ด้วย
DOMAIN=your-training-domain.com bash instructor/scripts/check_vms.sh ~/secure/trainees.csv
```

สคริปต์ตรวจ port 22 และ HTTP status ของทุกเครื่อง — **ทดสอบ SSH login ด้วยรหัสผ่านจริงเพิ่มเองอย่างน้อยแบบสุ่ม** (ควรทำครบทุกเครื่องถ้ามีเวลา)

> ⚠️ **ทดสอบ SSH จากเครือข่ายเดียวกับสถานที่อบรม** — Wi-Fi หน่วยงานราชการบางแห่งบล็อก outbound port 22 ถ้าบล็อก ต้องเตรียม Wi-Fi / 4G router สำรอง หรือขอเปิด port ล่วงหน้า

---

## 2. AI GLM + HyperFrames

### 2.1 AI GLM สำหรับ Claude Code

ผู้อบรมติดตั้ง Claude Code เอง แล้ว **ตั้งค่าให้ส่งงานไปที่ AI GLM ของเรา** ผ่านไฟล์ `~/.claude/settings.json` (คู่มือ 03 ขั้นที่ 2.3) — ไม่ต้องใช้บัญชี Claude

ต้องเตรียม:

| รายการ | ตัวอย่างในคู่มือ (placeholder) | หมายเหตุ |
|---|---|---|
| Endpoint | `https://coding.modelharbor.com` | รูปแบบ Anthropic Messages API (ตรวจแล้ว `/v1/messages` ตอบ 401 เมื่อไม่มี key) |
| โมเดลหลัก (OPUS / SONNET) | `glm-latest` | |
| โมเดลเล็ก (HAIKU / SUBAGENT) | `deepseek-flash-latest` | |
| API Key | — (แจกในซอง) | **1 key ต่อผู้อบรม** ตั้งวงเงิน/rate limit ต่อ key และ **revoke หลังอบรม** |

ค่าทั้งหมดใส่ไว้ในคู่มือ 03 ขั้นที่ 2.3 แล้ว ผู้อบรม **วางแค่ API Key ของตัวเอง** · ห้าม commit API Key ลง repo

ทดสอบบน VM หนึ่งเครื่องด้วยบัญชีผู้อบรมจริง: ตั้งค่าตามคู่มือ 03 → `claude` → ถาม 1 คำถาม → สั่งสร้าง `index.html` ตามโจทย์ A ให้ครบรอบ

> ⚠️ ผู้อบรม 20+ คนส่งงานพร้อมกัน — ตรวจว่า GLM รองรับ concurrency และ context ยาว (Claude Code ส่ง system prompt + skills ค่อนข้างยาว) ตั้ง `API_TIMEOUT_MS` ไว้ 600000 (10 นาที) แล้วในคู่มือ

### 2.2 HyperFrames (Workshop 3B ตัดต่อวิดีโอ)

ผู้อบรม **ติดตั้ง HyperFrames เอง** ด้วยคำสั่ง 3 บล็อกในคู่มือ 04 ขั้นที่ 2 (ต้องมี sudo แบบไม่ใส่รหัส + VM ออกอินเทอร์เน็ตได้ และต้องเป็นเครื่อง **amd64** เพราะใช้ Google Chrome แบบ .deb) ที่ทีมงานต้องทำเพิ่ม:

0. เพิ่ม disk ให้ VM อย่างน้อย **20 GB** (FFmpeg + Chrome + Node.js + cache ใช้ราว 1.5 GB)

1. **คลิปตัวอย่าง 3–4 คลิป** (ความยาวคลิปละ 5–10 วินาที, MP4 H.264, 1080p หรือต่ำกว่า) — ใช้คลิปที่ **หน่วยงานเป็นเจ้าของ** หรือคลิปฟรีที่อนุญาตให้ใช้ (เช่น Pexels / Pixabay) เนื้อหาเกี่ยวกับการทำงาน / สัมภาษณ์งาน / บูธรับสมัคร **ไม่มีใบหน้าบุคคลที่ไม่ได้ให้อนุญาต**
2. ตั้งชื่อ `clip1.mp4`, `clip2.mp4`, `clip3.mp4` แล้วคัดลอกไปทุก VM:

   ```bash
   # จากเครื่องทีมงาน: คัดลอกคลิปไปทุก VM ตามรายชื่อใน CSV (ใช้ user ผู้ดูแลที่มี sudo)
   tail -n +2 ~/secure/trainees.csv | while IFS=, read -r user _ ip _; do
     scp clips/*.mp4 admin@"$ip":/tmp/ && ssh admin@"$ip" 'sudo mv /tmp/clip*.mp4 /opt/training/media/ && sudo chmod 644 /opt/training/media/*'
   done
   ```

3. **ทดสอบครบรอบบน VM 1 เครื่อง** ด้วยบัญชีผู้อบรม: skills update → prompt แบบ A → preview ผ่าน SSH tunnel → render → scp ลงเครื่อง — จับเวลาไว้ (เป้าหมาย < 15 นาที) และตรวจว่าตัวหนังสือไทยในวิดีโอไม่เป็น □□□
4. เตรียม **คลิปผลลัพธ์ตัวอย่าง** ที่ render เสร็จแล้วไว้โชว์ตอนเริ่ม Workshop และเป็นแผนสำรอง

> 💡 Render ใช้ Chrome ประมาณ 256 MB ต่อ worker — VM 4 GB จะเข้า low-memory mode อัตโนมัติ (render ช้าลงแต่ไม่ล้ม) คลิป 20 วินาทีแบบ draft ใช้เวลาประมาณ 1–3 นาที

---

## 3. Cloudflare

### 3.1 เลือกโดเมน — ⚠️ อ่านก่อนตัดสินใจ

Cloudflare Universal SSL (ฟรี) ออกใบรับรองให้ **`โดเมน` และ `*.โดเมน` เพียงชั้นเดียว** เท่านั้น

| รูปแบบ URL ผู้อบรม | Zone ใน Cloudflare | HTTPS ฟรีใช้ได้? |
|---|---|---|
| `trainee01.your-training-domain.com` | `your-training-domain.com` | ✅ (Certbot ออกใบรับรองให้ทุกระดับ subdomain อยู่แล้ว) — **รูปแบบที่คู่มือใช้** |
| `trainee01.training.yourdomain.go.th` | `yourdomain.go.th` | ❌ **ไม่ได้** (สองชั้น) — ต้องซื้อ Advanced Certificate Manager หรือเปิด Total TLS |
| `trainee01.training.yourdomain.go.th` | `training.yourdomain.go.th` (subdomain zone) | ⚠️ ตรวจก่อนว่าแผน Cloudflare ของ account รองรับการเพิ่ม subdomain เป็น zone แยก |

**คำแนะนำ:** ใช้ **โดเมนเฉพาะสำหรับอบรม** (เช่นจดโดเมน `.com` / `.in.th` ราคาถูก) แล้วใช้ URL แบบชั้นเดียว `trainee01.<โดเมน>` — ไม่ต้องยุ่งกับ DNS ของหน่วยงาน (`.go.th`) และได้ HTTPS ฟรีทันที

> คู่มือใช้ `your-training-domain.com` เป็นโดเมนตัวอย่าง เมื่อได้โดเมนจริงแล้ว ให้ **ค้นหา-แทนที่** ทั้ง repo ก่อนวันอบรม (ตัวอย่าง: โดเมนจริงคือ `aitraining-example.com`):
>
> ```bash
> # macOS
> grep -rl 'your-training-domain.com' README.md manual slides | xargs sed -i '' 's/your-training-domain\.com/aitraining-example.com/g'
> # Linux
> grep -rl 'your-training-domain.com' README.md manual slides | xargs sed -i 's/your-training-domain\.com/aitraining-example.com/g'
> ```

### 3.2 ตั้งค่า Zone และ HTTPS

HTTPS ทำด้วย **Certbot (Let's Encrypt) บน VM แต่ละเครื่อง** — Cloudflare ใช้เป็น DNS อย่างเดียว

| การตั้งค่า | ค่า | เหตุผล |
|---|---|---|
| Proxy status ของ record ผู้อบรม | **DNS only (เมฆสีเทา)** | Certbot ต้องยืนยันโดเมนกับ VM โดยตรงผ่าน port 80 |
| Security Group / Firewall ของ VM | เปิด **22, 80, 443** | 80 = Certbot ยืนยันโดเมน · 443 = HTTPS |
| SSL/TLS mode ของ zone | ไม่มีผล (record ไม่ผ่าน proxy) | — |

> ⚠️ **โควตา Let's Encrypt:** ขอใบรับรองชื่อเดิมได้ไม่เกิน **5 ใบต่อ 7 วัน** และไม่เกิน 50 ใบต่อโดเมนหลักต่อ 7 วัน — ตอนซ้อมให้ใช้ `--staging` (`sudo certbot --nginx --staging -d …`) หรือใช้ subdomain สำหรับซ้อมแยกจากที่แจกผู้อบรม

### 3.3 สิทธิ์ของผู้อบรมในการเพิ่ม DNS record

| ทางเลือก | วิธี | ข้อดี / ข้อเสีย |
|---|---|---|
| **A. เพิ่มผู้อบรมเป็น Member** | Manage Account → Members → Invite ด้วยบทบาทที่จำกัดเฉพาะ DNS (เลือก role ที่แผนของ account รองรับ เช่น DNS / Domain DNS) | ✅ ผู้อบรมได้ลงมือเอง / ❌ ต้องใช้อีเมลผู้อบรม และยืนยันอีเมลก่อนวันงาน |
| **B. บัญชีกลาง 1 บัญชี / กลุ่ม TA** | ผู้อบรมกลุ่มละ 5–8 คนใช้บัญชีกลางบนเครื่อง TA ผลัดกันเพิ่ม record | ✅ ไม่ต้องเตรียมบัญชีรายคน / ❌ ช้ากว่า และเสี่ยงแก้ record ของคนอื่น |
| **C. ทีมงานสร้าง record ล่วงหน้า** | ใช้ [`scripts/create_dns_records.sh`](scripts/create_dns_records.sh) สร้างจาก CSV | ✅ เร็ว ไม่มีจุดติดขัด / ❌ ผู้อบรมไม่ได้ลงมือขั้นนี้ (ให้ดูบนจอวิทยากรแทน) |

แนะนำ: **A** ถ้าเตรียมทัน · สำรองด้วย **C** (รันสคริปต์ได้ทันทีหน้างาน ถ้าเวลาเหลือไม่พอ)

### 3.4 API Token สำหรับสคริปต์ (ทีมงานเท่านั้น)

My Profile → API Tokens → **Create Token** → Custom token:

| สิทธิ์ | ระดับ |
|---|---|
| Zone → DNS → **Edit** | เฉพาะ zone ที่ใช้อบรม |

> ⚠️ **ห้ามใช้ Global API Key** และห้ามแจก token นี้ให้ผู้อบรม · ลบ token หลังอบรม

---

## 4. บัตร VM + ซองรหัสผ่าน

ทำรายชื่อจาก [`scripts/trainees.example.csv`](scripts/trainees.example.csv) (คัดลอกไปไว้ **นอก repo** ก่อนใส่ข้อมูลจริง):

```csv
username,full_name,ip,subdomain
trainee01,ผู้อบรม คนที่หนึ่ง,203.0.113.10,trainee01
```

บัตร 1 ใบ / คน ประกอบด้วย: ชื่อผู้อบรม · VM Public IP · SSH Username · Subdomain เต็ม · QR code ไปที่ README ของ repo นี้

รหัสผ่าน VM และ **API Key ของ GLM** **พิมพ์แยกใส่ซองปิด**

---

## 5. แอปสำรอง

Deploy เว็บตัวอย่าง (เช่น เครื่องคำนวณวันลา จากโจทย์ A) ไว้ที่ `demo.<โดเมน>` ล่วงหน้า ใช้เมื่อ:

- โชว์เป้าหมายตอนเริ่มช่วง Deploy
- ผู้อบรมที่ทำไม่ทัน ได้เห็นผลลัพธ์และถ่ายรูปกลับไป

---

## 6. ระบบ RAG สำหรับสาธิต (Module 5)

ใช้ **NotebookLM** ทั้งการสาธิตและ Workshop 5 (ผู้อบรมลองเอง) — ทำตาม [manual/06_RAG_CONCEPT](../manual/06_RAG_CONCEPT.md) หัวข้อ 4 ล่วงหน้าครบทุกขั้น:

- [ ] บัญชี Google ของวิทยากรสร้าง notebook `ทดลอง RAG` อัปโหลด 3 ไฟล์ใน `manual/samples/rag/` (rag_01–03) ไว้สำรอง
- [ ] ถามครบ 6 ข้อในขั้นที่ 3 เทียบกับเฉลย และทดลองขั้นที่ 4 (ปิดแหล่ง / ใส่ rag_04) — จดผลไว้ ถ้า NotebookLM ตอบต่างจากที่คู่มือบอก ให้แก้คู่มือก่อนวันงาน
- [ ] ทดสอบว่า **Wi-Fi สถานที่อบรมเปิด notebooklm.google.com ได้** และอัปโหลดไฟล์ `.md` ได้ (ถ้าไม่ได้ ใช้แบบ "ข้อความที่คัดลอก")
- [ ] แจ้งผู้อบรมล่วงหน้าให้มี **บัญชี Google** ที่ล็อกอินได้ (บัญชี Google Workspace ของบางหน่วยงานปิด NotebookLM ไว้ ให้ใช้ Gmail ส่วนตัว)
- [ ] ทางสำรองสำหรับคนที่ใช้ NotebookLM ไม่ได้: Claude Code บน VM ([06 ทางสำรอง](../manual/06_RAG_CONCEPT.md#rag-fallback))
- [ ] อัดวิดีโอหน้าจอการสาธิตไว้ เผื่ออินเทอร์เน็ตล่ม

> ⚠️ คำถามข้อ 4 (ไม่มีในเอกสาร) ต้องทดสอบว่าระบบตอบ "ไม่พบข้อมูล" จริง ถ้าตอบเป็นตัวเลข ให้ใช้เป็นตัวอย่างอธิบาย hallucination หน้าห้อง

---

## 7. หลังอบรม (ภายใน 1–3 วัน)

- [ ] Revoke API Key ของ GLM ทั้งหมด
- [ ] ลบ Cloudflare API Token ของทีมงาน
- [ ] ลบ DNS record ของผู้อบรม (หรือเก็บไว้ตามที่ตกลงกับหน่วยงาน)
- [ ] ปิด / ลบ VM ทั้งหมด
- [ ] รวบรวม URL ผลงาน + แบบประเมินความพึงพอใจ สำหรับรายงานสรุปผลการอบรม
