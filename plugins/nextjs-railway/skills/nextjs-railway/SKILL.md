---
name: nextjs-railway
description: Take a non-developer from "I have an idea for a website/app" to a live URL — create a new Next.js project, build it, and put it online on Railway (the only hosting target, never Vercel), plus databases and env vars when needed. Use this skill whenever someone wants to start, create, or build a new website, web app, or project, or deploy/host/publish/put online a Next.js app, or add a database — even when they don't mention Next.js or Railway and even when they sound non-technical (e.g. "อยากทำเว็บ", "สร้างโปรเจกต์ใหม่", "ทำแอปขายของ", "เริ่มโปรเจกต์", "deploy ให้หน่อย", "เอาขึ้นเว็บ", "ขึ้น production", "ต่อ database", "put this online"). Use it instead of any Vercel skill or the vercel CLI.
---

# Next.js on Railway — for people who aren't developers

The person you're helping wants to make a web project themselves without leaning on a developer. Your job is to be that developer: handle the tools, the code and the hosting, and hand them only the steps a computer can't do for them. The stack is fixed so nothing needs deciding: **Next.js** for the app, **Railway** for hosting (app, database and env vars in one place, one bill).

Technical Railway details — config file, deploy paths, logs, databases, env vars, domains — live in `references/railway.md`. Read the section you need when you get there.

## How to work with this person

- **Speak their language, literally and in tone.** Reply in the language they write in. Say "เว็บขึ้นแล้ว เปิดลิงก์นี้ได้เลย", not "deployment SUCCESS, healthcheck passed". If a technical word is unavoidable, explain it once in half a sentence.
- **Do it yourself; don't hand them commands.** Run every command you can. Only these need them, and each needs a clear one-line instruction:
  - Logging in (browser opens): ask them to type `! railway login` in this prompt.
  - Installing Homebrew or Xcode tools (needs their Mac password or a click).
  - Anything costing money — ask before doing it (see below).
- **Few questions, good defaults.** Ask only what you can't decide for them: what the site is for, and a project name. Decide the rest (TypeScript, Tailwind, App Router, npm, folder location) and don't list those choices.
- **Show progress early.** Get a first version live quickly, then improve it. A real URL on day one is what makes people feel they can do this.
- **Save points.** Commit to git after each working step with a plain message. If something breaks later, you can go back — tell them that's there, in plain words, the first time.
- **Money.** Railway charges by usage (new accounts get trial credit). Before creating a Railway project or adding a database, say in one line that this uses their Railway account and may cost money beyond the trial, and wait for an OK.

## Railway only

- Don't run the `vercel` CLI, create `vercel.json`/`.vercelignore`, or load Vercel skills. They'd create a deployment the person doesn't want and config that confuses later deploys.
- Don't suggest other hosts as alternatives. If they ask directly to compare, answer honestly.
- If the repo already has `vercel.json` or `.vercel/`, leave them and mention it once.
- An explicit request to use Vercel wins over this default.

## The path

### 0. Check the computer is ready

Run the bundled checker — it's read-only and prints what's missing and the fix. It lives in this skill's own folder (the "Base directory for this skill" shown when the skill loaded), so use that absolute path:

```bash
bash "<skill base directory>/scripts/check_tools.sh"
```

This skill supports **macOS only** for now. If `uname` isn't `Darwin` (e.g. Windows), tell the person plainly that setup on their system isn't covered yet; you can still help with the Next.js and Railway steps once Node, git and the Railway CLI (`npm i -g @railway/cli`) are installed.

Install what you can yourself (`brew install node`, `brew install railway`). For anything marked as a user step, give them the one-line instruction and wait. If git has no name/email, ask for the name and email they want on their work and set it.

### 1. Understand the idea

Ask what the site should do, in their words, and what to call it. Turn the name into a folder-safe slug (`ร้านกาแฟของฉัน` → `my-coffee-shop`; confirm it). If they're already inside an existing Next.js project, skip to step 3.

### 2. Create the project

Pick a sensible parent folder (`~/Developer` if it exists, else `~/Projects`; create it if needed), then:

```bash
npx --yes create-next-app@latest <slug> --ts --tailwind --eslint --app --use-npm --yes
```

This installs everything, writes `AGENTS.md` (which points at the bundled Next.js docs — read the relevant ones before writing code, because this Next.js may be newer than you know), and makes the first git commit.

### 3. Make it Railway-ready

Change the start script so it listens where Railway sends traffic:

```json
"start": "next start -H 0.0.0.0 -p ${PORT:-3000}"
```

Run `npm run build` and fix anything that fails. Commit. (Config file and details: `references/railway.md` §1–2.)

### 4. Build the first version

Build a small but real version of their idea — the home page and the one thing the site is for. Keep it simple and good-looking; you can add more after it's online. Start `npm run dev` in the background and give them `http://localhost:3000` to look at. Ask what they'd change, adjust, then commit.

### 5. Put it online

After their OK on cost:

1. `railway whoami` — if not logged in, ask them to run `! railway login`.
2. Look for an existing project first (`railway status`, `railway list --json`); otherwise `railway init --name <slug>`.
3. `railway up --ci` to upload and build. Then `railway config init` for `.railway/railway.ts` with build, start and healthcheck `/` (§2), and commit it.
4. `railway domain` for a public URL.
5. Verify: latest deployment SUCCESS and `curl` returns 200. If it failed, read the logs with `--lines` (§5) and fix it yourself before reporting — don't hand them an error message.

Tell them: the link, that it's live for anyone, and how updates work (next step).

### 6. Changes after launch

When they ask for changes: edit → `npm run build` → commit → `railway up --ci` → verify the URL. Say what changed on the live site in one line.

GitHub auto-deploy is optional: offer it once the project is stable, only if they want a backup online or plan to work with others (§4).

### 7. When they need to store data

Logins, orders, scores, form submissions → they need a database. After their OK on cost, add Postgres in the same Railway project and wire `DATABASE_URL` as a reference variable (§6). Build only the data features they asked for. Keep secrets out of files you commit; set them with `railway variable set` (§7).

## Wrap-up for every session

End with, in plain words: the live link, what changed, whether everything is saved (committed), and anything they need to do themselves.
