#!/usr/bin/env bash
# ตรวจ VM ของผู้อบรมทุกเครื่องจากเครื่องทีมงาน (macOS / Linux)
#
# ใช้งาน:
#   bash check_vms.sh <trainees.csv>
#   DOMAIN=your-training-domain.com bash check_vms.sh <trainees.csv>   # ตรวจ HTTPS ผ่าน Cloudflare ด้วย
#
# CSV: username,full_name,ip,subdomain  (แถวแรกเป็นหัวตาราง)
#
# คอลัมน์ผลลัพธ์:
#   SSH   = port 22 เปิดรับการเชื่อมต่อ
#   HTTP  = HTTP status จาก http://<ip>  (000 = เชื่อมต่อไม่ได้ — ปกติถ้ายังไม่ติดตั้ง nginx)
#   HTTPS = HTTP status จาก https://<subdomain>.<DOMAIN>  (เฉพาะเมื่อกำหนด DOMAIN)
set -uo pipefail

CSV="${1:-}"
if [[ -z "$CSV" || ! -f "$CSV" ]]; then
  echo "usage: [DOMAIN=example.com] bash $0 <trainees.csv>" >&2
  exit 1
fi
DOMAIN="${DOMAIN:-}"

printf "%-12s %-16s %-6s %-6s %-6s\n" USERNAME IP SSH HTTP HTTPS
printf "%-12s %-16s %-6s %-6s %-6s\n" -------- -- --- ---- -----

fail=0
while IFS=, read -r username _full_name ip subdomain; do
  [[ -z "$username" ]] && continue
  ip="${ip//[[:space:]]/}"
  subdomain="${subdomain//[[:space:]]/}"

  if nc -z -w 3 "$ip" 22 >/dev/null 2>&1; then ssh_ok="OK"; else ssh_ok="FAIL"; fail=1; fi

  http_code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "http://$ip" || true)

  https_code="-"
  if [[ -n "$DOMAIN" && -n "$subdomain" ]]; then
    https_code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 8 "https://$subdomain.$DOMAIN" || true)
  fi

  printf "%-12s %-16s %-6s %-6s %-6s\n" "$username" "$ip" "$ssh_ok" "$http_code" "$https_code"
done < <(tail -n +2 "$CSV" | tr -d '\r')

echo
if [[ $fail -eq 0 ]]; then
  echo "SSH port 22 เปิดครบทุกเครื่อง ✅  (ทดสอบ login ด้วยรหัสผ่านจริงแบบสุ่มอย่างน้อย 3 เครื่อง)"
else
  echo "มีเครื่องที่ port 22 เชื่อมต่อไม่ได้ ❌  ตรวจ VM / Security Group"
  exit 1
fi
