#!/usr/bin/env bash
# เตรียม VM 1 เครื่องสำหรับผู้อบรม 1 คน (รันบน VM ด้วยสิทธิ์ root)
#
# ใช้งาน:
#   sudo bash setup_vm.sh <username> [password]
#   ถ้าไม่ใส่ password สคริปต์จะถามแบบซ่อนตัวอักษร (ไม่ติดใน shell history)
#
# สิ่งที่ทำ:
#   1. ติดตั้งเครื่องมือพื้นฐาน (curl, git, python3)
#   2. สร้าง user + รหัสผ่าน + sudo แบบไม่ต้องใส่รหัส (Claude Code ต้องใช้)
#   3. เปิด SSH แบบใช้รหัสผ่าน
#   4. ตั้ง hostname เป็น training-vm-<username>
# ไม่ติดตั้ง Claude Code และ nginx — ผู้อบรมทำเองใน Workshop
set -euo pipefail

USERNAME="${1:-}"
PASSWORD="${2:-}"

if [[ -z "$USERNAME" ]]; then
  echo "usage: sudo bash $0 <username> [password]" >&2
  exit 1
fi
if [[ $EUID -ne 0 ]]; then
  echo "ต้องรันด้วย sudo / root" >&2
  exit 1
fi
if [[ ! "$USERNAME" =~ ^[a-z][a-z0-9-]{1,30}$ ]]; then
  echo "username ต้องเป็น a-z, 0-9, - และขึ้นต้นด้วยตัวอักษร" >&2
  exit 1
fi
if [[ -z "$PASSWORD" ]]; then
  read -r -s -p "รหัสผ่านสำหรับ $USERNAME: " PASSWORD
  echo
fi

echo "==> [1/4] ติดตั้งแพ็กเกจพื้นฐาน"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y curl git python3 ca-certificates

echo "==> [2/4] สร้าง user $USERNAME"
if ! id "$USERNAME" &>/dev/null; then
  useradd -m -s /bin/bash "$USERNAME"
fi
echo "$USERNAME:$PASSWORD" | chpasswd
usermod -aG sudo "$USERNAME"

# Claude Code รันคำสั่งแบบไม่มี terminal ให้กรอกรหัส sudo จึงต้องเป็น NOPASSWD
SUDOERS_FILE="/etc/sudoers.d/90-training-$USERNAME"
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "$SUDOERS_FILE"
chmod 440 "$SUDOERS_FILE"
visudo -cf "$SUDOERS_FILE" >/dev/null

echo "==> [3/4] เปิด SSH แบบใช้รหัสผ่าน"
# ใช้ชื่อไฟล์ 01- เพื่อให้ถูกอ่านก่อน 50-cloud-init.conf (sshd ใช้ค่าที่เจอก่อน)
cat > /etc/ssh/sshd_config.d/01-training.conf <<'EOF'
PasswordAuthentication yes
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
EOF
sshd -t
systemctl reload ssh 2>/dev/null || systemctl reload sshd

echo "==> [4/4] ตั้ง hostname"
NEW_HOSTNAME="training-vm-$USERNAME"
hostnamectl set-hostname "$NEW_HOSTNAME"
if ! grep -q "$NEW_HOSTNAME" /etc/hosts; then
  echo "127.0.1.1 $NEW_HOSTNAME" >> /etc/hosts
fi

echo
echo "เสร็จแล้ว ✅  ทดสอบจากเครื่องอื่นด้วย:  ssh $USERNAME@<IP ของเครื่องนี้>"
echo "(อย่าลืมเปิด port 22, 80, 443 ใน Security Group / Firewall ของผู้ให้บริการคลาวด์)"
