# 01 — Checklist ทีมงาน: เตรียมก่อนวันอบรม

ทำให้เสร็จ **ก่อนวันอบรมอย่างน้อย 3–5 วัน** · ทดสอบซ้ำอีกครั้ง **1 วันก่อนอบรม**

## ภาพรวมสิ่งที่ต้องเตรียม

| # | สิ่งที่ต้องเตรียม | ใช้ใน | ผู้รับผิดชอบ | เสร็จ |
|---|---|---|---|---|
| 1 | VM Ubuntu 1 เครื่อง/คน (+ สำรอง 2–3 เครื่อง) | Module 2, Deploy | ทีม Infra | ☐ |
| 2 | AI GLM: endpoint + ชื่อโมเดล + API Key ต่อคน (Claude Code เชื่อมผ่าน GLM) | Module 2, 3, Deploy | ทีม AI / Infra | ☐ |
| 2.1 | คลิปตัวอย่างสำหรับตัดต่อ + ทดสอบ HyperFrames render บน VM | Module 3 | วิทยากร | ☐ |
| 3 | Cloudflare Zone + สิทธิ์ผู้อบรม + SSL mode Flexible | Deploy | ทีม Infra | ☐ |
| 4 | บัตร VM + ซองรหัสผ่าน | ทั้งวัน | ผู้ประสานงาน | ☐ |
| 5 | แอปสำรองที่ deploy เสร็จแล้ว | Deploy | วิทยากร | ☐ |
| 6 | ระบบ RAG สำหรับสาธิต | Module 5 | วิทยากร | ☐ |
| 7 | อุปกรณ์ห้องอบรม (Wi-Fi สำรอง, ป้าย ได้/ไม่ได้, checklist พิมพ์) | ทั้งวัน | ผู้ประสานงาน | ☐ |
| 8 | TA 1 คน / ผู้อบรม 5–8 คน | Module 2, Deploy | ผู้ประสานงาน | ☐ |

---

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
3. ติดตั้ง `curl`, `git`, `python3`, **FFmpeg**, **Node.js 22**, **Google Chrome**, **ฟอนต์ไทย** (`fonts-thai-tlwg`, `fonts-noto-core`) และ **HyperFrames CLI** (`npm install -g hyperframes`) สำหรับ Workshop 3B
4. ตั้ง hostname เป็น `training-vm-<ชื่อผู้ใช้>` (ช่วยให้ TA ดูหน้าจอแล้วรู้ว่าเครื่องใคร)
5. สร้างโฟลเดอร์ `/opt/training/media` สำหรับคลิปตัวอย่าง (ต้องคัดลอกคลิปเข้าไปเอง — ดูหัวข้อ 2.2)
6. รัน `hyperframes doctor` ในนามผู้อบรมเพื่อตรวจความพร้อม
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

ผู้อบรมติดตั้ง Claude Code เอง แล้ว **ตั้งค่าให้ส่งงานไปที่ AI GLM ของเรา** ผ่านไฟล์ `~/.claude/settings.json` (คู่มือ 03 ขั้นที่ 2.1) — ไม่ต้องใช้บัญชี Claude

ต้องเตรียม:

| รายการ | ตัวอย่างในคู่มือ (placeholder) | หมายเหตุ |
|---|---|---|
| Endpoint ที่รองรับ Anthropic API | `https://your-glm-endpoint/api/anthropic` | ต้องรับ request รูปแบบ Anthropic Messages API (`/v1/messages`) |
| ชื่อโมเดล | `your-glm-model` | ใช้ชื่อเดียวกันทั้ง OPUS / SONNET / HAIKU ได้ ถ้ามีรุ่นเล็ก ใส่ใน HAIKU |
| API Key | — (แจกในซอง) | **1 key ต่อผู้อบรม** ตั้งวงเงิน/rate limit ต่อ key และ **revoke หลังอบรม** |

**ก่อนวันอบรม แทน placeholder ทั้ง repo ด้วยค่าจริง** (endpoint และชื่อโมเดลไม่ใช่ความลับ แต่ **ห้าม commit API Key**):

```bash
# macOS (Linux: ใช้ sed -i โดยไม่มี '')
grep -rl 'your-glm-endpoint\|your-glm-model' README.md manual instructor slides \
  | xargs sed -i '' -e 's#https://your-glm-endpoint/api/anthropic#https://GLM-ENDPOINT-จริง#g' \
                    -e 's#https://your-glm-endpoint#https://GLM-HOST-จริง#g' \
                    -e 's#your-glm-model#ชื่อโมเดลจริง#g'
```

ทดสอบบน VM หนึ่งเครื่องด้วยบัญชีผู้อบรมจริง: ตั้งค่าตามคู่มือ 03 → `claude` → ถาม 1 คำถาม → สั่งสร้าง `index.html` ตามโจทย์ A ให้ครบรอบ

> ⚠️ ผู้อบรม 20+ คนส่งงานพร้อมกัน — ตรวจว่า GLM รองรับ concurrency และ context ยาว (Claude Code ส่ง system prompt + skills ค่อนข้างยาว) ตั้ง `API_TIMEOUT_MS` ไว้ 600000 (10 นาที) แล้วในคู่มือ

### 2.2 HyperFrames (Workshop 3B ตัดต่อวิดีโอ)

`setup_vm.sh` ติดตั้ง Node.js 22, FFmpeg, Chrome, ฟอนต์ไทย และ HyperFrames CLI ให้แล้ว ที่ต้องทำเพิ่ม:

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
| `trainee01.your-training-domain.com` | `your-training-domain.com` | ✅ ได้ (ชั้นเดียว) — **รูปแบบที่คู่มือใช้** |
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

### 3.2 ตั้งค่า Zone

| การตั้งค่า | ค่า | เหตุผล |
|---|---|---|
| **SSL/TLS → Overview → encryption mode** | **Flexible** | VM เปิดแค่ HTTP port 80 — ถ้าเป็น Full/Strict จะเจอ Error 525/526 |
| SSL/TLS → Edge Certificates → Always Use HTTPS | On | ผู้ใช้พิมพ์ `http://` ก็ถูกพาไป `https://` |
| DNS records ของผู้อบรม | สร้างโดยผู้อบรมเอง (Workshop) หรือทีมงานสร้างล่วงหน้า | ดู 3.3 |

> ⚠️ **Flexible** หมายถึง ช่วง Cloudflare → VM ไม่เข้ารหัส ยอมรับได้สำหรับเว็บสาธิตที่ไม่มีข้อมูลสำคัญ **ไม่ควรใช้กับระบบจริง**

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

เลือก 1 แบบ ทดสอบคำถามทั้ง 5 ข้อใน [manual/06_RAG_CONCEPT](../manual/06_RAG_CONCEPT.md) ล่วงหน้า:

| แบบ | เตรียม |
|---|---|
| **เครื่องมือสำเร็จรูป** (NotebookLM / Claude Projects / ChatGPT Projects) | สร้าง notebook/project อัปโหลด 3 ไฟล์ใน `manual/samples/rag/` ไว้ก่อน — สาธิตถาม-ตอบ + ชี้ให้ดูแหล่งอ้างอิง |
| **ระบบที่ทีมพัฒนาเอง** | ใช้เอกสารชุดเดียวกัน เตรียมหน้าจอแสดง "ท่อนเอกสารที่ค้นเจอ" ก่อนคำตอบ เพื่ออธิบายขั้น Retrieval ให้เห็นภาพ |

> ⚠️ คำถามข้อ 4 (ไม่มีในเอกสาร) ต้องทดสอบว่าระบบตอบ "ไม่พบข้อมูล" จริง ถ้าระบบแต่งคำตอบ ให้ปรับ system prompt ก่อนวันงาน หรือใช้เป็นตัวอย่างอธิบาย hallucination

---

## 7. หลังอบรม (ภายใน 1–3 วัน)

- [ ] Revoke API Key ของ GLM ทั้งหมด
- [ ] ลบ Cloudflare API Token ของทีมงาน
- [ ] ลบ DNS record ของผู้อบรม (หรือเก็บไว้ตามที่ตกลงกับหน่วยงาน)
- [ ] ปิด / ลบ VM ทั้งหมด
- [ ] รวบรวม URL ผลงาน + แบบประเมินความพึงพอใจ สำหรับรายงานสรุปผลการอบรม
