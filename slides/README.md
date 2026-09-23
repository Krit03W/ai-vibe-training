# สไลด์ประกอบการอบรม

สไลด์ทุกชุดเขียนเป็น Markdown แบบ [Marp](https://marp.app/) — แก้ไขด้วย text editor ได้ทันที และ export เป็น PDF / PPTX / HTML ได้

| ไฟล์ | ช่วง | เวลา |
|---|---|---|
| [00_opening.md](00_opening.md) | พิธีเปิด + ภาพรวมวัน | 09.00–09.15 |
| [01_module1_prompt.md](01_module1_prompt.md) | Module 1 — Prompt Engineering + Workshop 1 | 09.15–10.15 |
| [02_module2_vibe_coding.md](02_module2_vibe_coding.md) | Module 2 — Vibe Coding + Workshop 2 | 10.30–11.20 |
| [03_module3_media.md](03_module3_media.md) | Module 3 — ผลิตสื่อ + Workshop 3 | 11.20–12.00 |
| [04_module4_safety.md](04_module4_safety.md) | Module 4 — ความปลอดภัย + Workshop 4 | 13.00–13.40 |
| [05_module5_rag.md](05_module5_rag.md) | Module 5 — RAG + สาธิต | 13.40–14.20 |
| [06_deploy.md](06_deploy.md) | Deploy จริง | 14.20–14.50 |
| [07_closing.md](07_closing.md) | สรุป + ปิด | 14.50–15.00 |

ธีมอยู่ที่ [`themes/nti.css`](themes/nti.css) (ฟอนต์ Kanit + Sarabun, สีน้ำเงินเข้ม-ส้ม)

## นำเสนอ / Export

### วิธีที่ 1 — VS Code (แนะนำสำหรับแก้ไข)

1. ติดตั้ง extension **Marp for VS Code**
2. เปิดโฟลเดอร์ repo นี้ใน VS Code (ไฟล์ `.vscode/settings.json` ลงทะเบียนธีม `nti` ไว้แล้ว)
3. เปิดไฟล์สไลด์ → กดไอคอน Preview ด้านขวาบน
4. Export: `Ctrl + Shift + P` → **Marp: Export Slide Deck...** → เลือก PDF / PPTX

### วิธีที่ 2 — Marp CLI (ต้องมี Node.js)

รันที่ root ของ repo (ไฟล์ `.marprc.yml` ตั้งค่าโฟลเดอร์ธีมไว้แล้ว):

```bash
# export ทุกชุดเป็น PDF ไว้ในโฟลเดอร์ slides/dist
npx @marp-team/marp-cli@latest --input-dir slides --output slides/dist --pdf

# export ชุดเดียวเป็น PowerPoint
npx @marp-team/marp-cli@latest slides/01_module1_prompt.md --pptx -o slides/dist/01_module1_prompt.pptx

# เปิดโหมดนำเสนอแบบ live preview ในเบราว์เซอร์
npx @marp-team/marp-cli@latest --server slides
```

> `slides/dist/` ถูก ignore ใน git — แจกไฟล์ PDF แยกต่างหาก

## รูปแบบที่ใช้ในสไลด์

| คำสั่งใน Markdown | ผล |
|---|---|
| `---` | ขึ้นสไลด์ใหม่ |
| `<!-- _class: lead -->` | หน้าปก / หน้าคั่น (พื้นน้ำเงิน) |
| `<!-- _class: workshop -->` | หน้า Workshop (พื้นส้มอ่อน) |
| `<!-- ข้อความ -->` | บันทึกผู้บรรยาย (speaker notes) — ไม่แสดงบนสไลด์ |

## ก่อนวันอบรม

- แทนโดเมนตัวอย่าง `your-training-domain.com` ด้วยโดเมนจริง (ดู [instructor/01_STAFF_PREPARATION](../instructor/01_STAFF_PREPARATION.md) หัวข้อ 3.1)
- ใส่ข่าวกรณีศึกษาจริงในสไลด์ Module 4 หัวข้อ 4.6
- ใส่ URL ผลงานผู้อบรมในสไลด์ปิดท้ายระหว่างวัน
