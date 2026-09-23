# nextjs-railway — สร้างเว็บเองได้ ไม่ต้องเป็น developer

Plugin สำหรับ Claude Code: บอกไอเดียเว็บที่อยากทำ แล้ว Claude จะสร้างโปรเจกต์ เขียนเว็บให้ และเอาขึ้นอินเทอร์เน็ตจนได้ลิงก์ที่คนอื่นเปิดได้

- เว็บสร้างด้วย **Next.js**
- เอาขึ้นเว็บที่ **Railway** (ตัวเว็บ ฐานข้อมูล และการตั้งค่าอยู่ที่เดียว)
- คุณทำเองแค่ login กับกดยืนยัน ที่เหลือ Claude ทำให้

> ตอนนี้รองรับเฉพาะ **Mac** — Windows กำลังจะตามมา

## ต้องมีอะไรบ้าง

| อย่าง | ทำไม |
|---|---|
| เครื่อง Mac | plugin ตั้งค่าเครื่องให้อัตโนมัติผ่าน Homebrew |
| [Claude Code](https://claude.com/claude-code) ที่ login แล้ว | plugin ทำงานใน Claude Code |
| [Homebrew](https://brew.sh) | ใช้ลงโปรแกรมอื่นให้อัตโนมัติ — ต้องลงเองครั้งแรก (ต้องใส่รหัสผ่านเครื่อง) |
| บัญชี [Railway](https://railway.com) | ที่เก็บเว็บ — สมัครฟรีได้ตอน login มีเครดิตทดลอง ใช้เกินแล้วคิดเงินตามการใช้งาน |

Node.js, git และ Railway CLI — Claude ลงให้เองถ้ายังไม่มี

## ติดตั้ง

เปิด Claude Code แล้วพิมพ์ทีละบรรทัด:

```
/plugin marketplace add Peachvon/nextjs-railway-plugin
/plugin install nextjs-railway@peachvon-plugins
```

## เริ่มใช้

พิมพ์สิ่งที่อยากได้เป็นภาษาปกติ เช่น

- "อยากทำเว็บร้านกาแฟ มีเมนูกับเบอร์โทร เอาขึ้นเว็บให้คนอื่นเปิดได้"
- "ทำหน้าเว็บแนะนำตัวเองให้หน่อย"
- "เว็บนี้อยากให้เก็บรายชื่อคนที่ลงทะเบียนได้"

Claude จะถามแค่ว่าเว็บทำอะไรกับจะตั้งชื่อว่าอะไร แล้วพาทำไปทีละขั้น ก่อนทำอะไรที่อาจเสียเงินบน Railway จะถามคุณก่อนเสมอ

## อัปเดต

```
/plugin marketplace update peachvon-plugins
```

## สำหรับคนดูแล plugin

- ตัว skill: `plugins/nextjs-railway/skills/nextjs-railway/SKILL.md`
- รายละเอียดเทคนิค Railway: `.../references/railway.md`
- สคริปต์เช็กเครื่อง: `.../scripts/check_tools.sh`
- ชุดทดสอบ: `evals/evals.json`
- ตรวจ manifest: `claude plugin validate .`
- ออกเวอร์ชันใหม่: แก้ `version` ใน `plugins/nextjs-railway/.claude-plugin/plugin.json` แล้ว push
