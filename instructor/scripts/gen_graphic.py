"""เจนภาพอธิบาย (infographic) ด้วย OpenAI gpt-image-2 — พื้นหลังโปร่งใส

ใช้งาน:
  export OPENAI_API_KEY=...        # หรือ: set -a && . ./.env && set +a
  python3 instructor/scripts/gen_graphic.py <โฟลเดอร์ปลายทาง> <ชื่อไฟล์> <ไฟล์ spec.txt>

ค่าเริ่มต้น: quality=medium, size=1536x720 (~1 บาท/ภาพ) · ปรับด้วย IMAGE_QUALITY / IMAGE_SIZE
สไตล์กลาง (ทางการ ธีมขาว-ฟ้า-น้ำเงิน ฟอนต์คล้าย Sarabun) ใส่ให้อัตโนมัติ — ไฟล์ spec เขียนแค่ layout และข้อความ
"""
import base64, json, os, sys, urllib.request, urllib.error

STYLE = """
This is a FORMAL, CONTENT-FOCUSED EXPLAINER INFOGRAPHIC for a Thai government training, designed for a trainer to talk through. Text content is the main carrier (about 70%), supported by clean professional icons (about 30%).
Style: formal and professional, like a government / corporate report infographic. Use clean flat or subtle-3D line icons and simple UI mock-ups. NO cartoon characters, NO mascots, NO cute faces, NO emoji-like decorations, NO sparkles. Not a slide: no title, no slide background, transparent background.
Layout: clean grid, clear hierarchy, aligned cards with rounded corners and thin light-blue borders, navy headings, dark-navy body text, light ice-blue boxes for examples, generous spacing.
Colors: white, light sky blue (#E6F2FF, #7CC4F2), navy (#0B2E6B), royal blue (#1F5FBF). Green only for small check icons, red only for small cross / warning icons.
Text rules: use ONLY the Thai / English text quoted below, exactly as written, correct Thai vowels and tone marks, clean formal Thai font similar to "Sarabun". Spell every Thai word with extreme care, character by character. Do NOT add any other words, numbers, labels on mock-ups, logos, brand marks or emblems. Keep every text line large enough to read on a projector.

"""

out, name, spec_file = sys.argv[1], sys.argv[2], sys.argv[3]
spec = open(spec_file, encoding="utf-8").read()
body = {"model": os.environ.get("IMAGE_MODEL", "gpt-image-2"), "prompt": STYLE + spec,
        "size": os.environ.get("IMAGE_SIZE", "1536x720"),
        "quality": os.environ.get("IMAGE_QUALITY", "medium"),
        "n": 1, "background": "transparent", "output_format": "png"}
req = urllib.request.Request("https://api.openai.com/v1/images/generations", data=json.dumps(body).encode(),
    headers={"Authorization": f"Bearer {os.environ['OPENAI_API_KEY']}", "Content-Type": "application/json"})
try:
    with urllib.request.urlopen(req, timeout=600) as r:
        data = json.load(r)
except urllib.error.HTTPError as e:
    sys.exit(f"ERROR {e.code} {e.read().decode()[:600]}")
os.makedirs(out, exist_ok=True)
path = os.path.join(out, name + ".png")
open(path, "wb").write(base64.b64decode(data["data"][0]["b64_json"]))
print(path, data.get("usage", ""))
