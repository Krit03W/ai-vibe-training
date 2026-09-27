# คู่มือ Linux เสริม (อ่านเพิ่มเติม)

คู่มือชุดนี้ใช้เป็น **ความรู้เสริม** สำหรับคนที่อยากเข้าใจเครื่อง VM และเครื่องมือเบื้องหลังมากขึ้น ไม่จำเป็นต้องอ่านก่อนทำ Workshop — ขั้นตอนที่ต้องทำในวันอบรมอยู่ใน [คู่มือ 00–10](../../README.md) แล้ว

> 📚 **ที่มา:** เนื้อหาทั้งหมดในโฟลเดอร์นี้นำมาจาก [utarn/linux-tutorials — manual/day_1](https://github.com/utarn/linux-tutorials/tree/main/manual/day_1)

| ไฟล์ | เนื้อหา | เกี่ยวกับ Workshop ไหน |
|---|---|---|
| [01_LINUX.md](01_LINUX.md) | คำสั่ง Linux พื้นฐาน จัดการไฟล์ โปรเซส ดิสก์ | ทุก Workshop บน VM (ต่อยอดจาก [02_SSH_VM](../02_SSH_VM.md)) |
| [02_PUBLICKEY.md](02_PUBLICKEY.md) | สร้าง SSH Key เข้า VM โดยไม่ต้องพิมพ์รหัสผ่าน | [02_SSH_VM](../02_SSH_VM.md) |
| [03_SSH_FILESYSTEM.md](03_SSH_FILESYSTEM.md) | รับส่งไฟล์ด้วย SCP, SFTP, rsync, FileZilla และ SSH Tunnel | 3B ดาวน์โหลดคลิป · 6B อัปโหลดโปสเตอร์ · การเปิดท่อ `ssh -L` |
| [04_VSCODE.md](04_VSCODE.md) | ใช้ VS Code เชื่อมต่อ VM ผ่าน Remote - SSH | ทางเลือกแทน Terminal ใน Workshop 2A |
| [05_GIT.md](05_GIT.md) | Git พื้นฐาน commit, branch, push | Workshop สำรอง 2G (ปุ่มย้อนกลับด้วย Git) |
| [06_WSL_INSTALLATION.md](06_WSL_INSTALLATION.md) | ติดตั้ง Ubuntu บน Windows ด้วย WSL และคำสั่ง `sudo` | ฝึก Linux ต่อบนเครื่องตัวเองหลังอบรม |
| [07_DOCKER.md](07_DOCKER.md) | ติดตั้งและใช้งาน Docker เบื้องต้น | ความรู้เสริม (Workshop วันอบรมไม่ได้ใช้ Docker) |

> ⚠️ ตัวอย่างในคู่มือเสริมเขียนสำหรับงานวิจัยและนักพัฒนา บางคำสั่งต้องใช้สิทธิ์ `sudo` หรือติดตั้งโปรแกรมเพิ่ม — ถ้าจะลองบน VM อบรม ให้ลองในโฟลเดอร์ของตัวเองเท่านั้น และอย่าลบหรือแก้ไฟล์ใน `/var/www/myapp` ระหว่างอบรม
