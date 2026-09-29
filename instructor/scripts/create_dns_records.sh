#!/usr/bin/env bash
# สร้าง / ลบ A record ของผู้อบรมใน Cloudflare จาก CSV (ทางสำรองเมื่อผู้อบรมเพิ่ม record เองไม่ทัน)
#
# ต้องมี:
#   CF_API_TOKEN  = API Token สิทธิ์ Zone → DNS → Edit เฉพาะ zone อบรม (ห้ามใช้ Global API Key)
#   CF_ZONE_ID    = Zone ID (Cloudflare Dashboard → โดเมน → Overview → แถบขวา "Zone ID")
#   python3       = ใช้อ่านผลลัพธ์ JSON
#
# ใช้งาน:
#   export CF_API_TOKEN=xxxx CF_ZONE_ID=yyyy
#   bash create_dns_records.sh create <trainees.csv>   # สร้าง A record (DNS only) ให้ทุกคน
#   bash create_dns_records.sh delete <trainees.csv>   # ลบ A record ของทุกคน (หลังอบรม)
#
# CSV: username,full_name,ip,subdomain  (แถวแรกเป็นหัวตาราง)
set -euo pipefail

ACTION="${1:-}"
CSV="${2:-}"
: "${CF_API_TOKEN:?ต้องตั้งค่า CF_API_TOKEN}"
: "${CF_ZONE_ID:?ต้องตั้งค่า CF_ZONE_ID}"

if [[ "$ACTION" != "create" && "$ACTION" != "delete" ]] || [[ ! -f "$CSV" ]]; then
  echo "usage: bash $0 create|delete <trainees.csv>" >&2
  exit 1
fi

API="https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records"
AUTH=(-H "Authorization: Bearer $CF_API_TOKEN" -H "Content-Type: application/json")

# ชื่อโดเมนของ zone (ใช้ประกอบชื่อเต็มตอนค้นหา record)
ZONE_NAME=$(curl -fsS "${AUTH[@]}" "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID" \
  | python3 -c 'import json,sys; print(json.load(sys.stdin)["result"]["name"])')
echo "Zone: $ZONE_NAME"

json_field() {
  # อ่านค่าจาก JSON ที่ stdin ด้วย expression python เช่น 'd["success"]'
  python3 -c "import json,sys; d=json.load(sys.stdin); print($1)"
}

while IFS=, read -r username _full_name ip subdomain; do
  [[ -z "$username" ]] && continue
  ip="${ip//[[:space:]]/}"
  subdomain="${subdomain//[[:space:]]/}"
  fqdn="$subdomain.$ZONE_NAME"

  existing_id=$(curl -fsS "${AUTH[@]}" "$API?type=A&name=$fqdn" \
    | json_field 'd["result"][0]["id"] if d["result"] else ""')

  if [[ "$ACTION" == "create" ]]; then
    if [[ -n "$existing_id" ]]; then
      echo "ข้าม   $fqdn (มี record อยู่แล้ว)"
      continue
    fi
    body=$(printf '{"type":"A","name":"%s","content":"%s","proxied":false,"ttl":1,"comment":"training %s"}' \
      "$subdomain" "$ip" "$username")
    ok=$(curl -sS "${AUTH[@]}" -X POST "$API" --data "$body" | json_field 'd["success"]')
    echo "สร้าง  $fqdn -> $ip : $ok"
  else
    if [[ -z "$existing_id" ]]; then
      echo "ข้าม   $fqdn (ไม่มี record)"
      continue
    fi
    ok=$(curl -sS "${AUTH[@]}" -X DELETE "$API/$existing_id" | json_field 'd["success"]')
    echo "ลบ    $fqdn : $ok"
  fi
done < <(tail -n +2 "$CSV" | tr -d '\r')
