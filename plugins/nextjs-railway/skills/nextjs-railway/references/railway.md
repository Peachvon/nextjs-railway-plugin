# Railway technical reference (Railway CLI 5.x)

Read the section you need. Every command here was checked against `railway <cmd> --help` for CLI 5.59; if the installed CLI is newer and a flag errors, run `--help` and adapt.

## Contents
1. Making a Next.js app Railway-ready
2. Config file: `.railway/railway.ts`
3. Finding or creating the project
4. Deploying (two paths)
5. Verifying and reading logs
6. Databases
7. Environment variables
8. Custom domains

## 1. Making a Next.js app Railway-ready

**Start script.** Railway injects `$PORT` and routes outside traffic to it, so the server must listen on all interfaces at that port. create-next-app generates plain `"start": "next start"` — change it to:

```json
"start": "next start -H 0.0.0.0 -p ${PORT:-3000}"
```

**Build locally first** (`npm run build`). A failed build on Railway costs minutes per round trip; locally it's seconds with the full error.

**Build-time vs runtime env.** `NEXT_PUBLIC_*` values are inlined at build time, so set them in Railway before the build that needs them; changing them later needs a redeploy. Server-only vars are read at runtime.

**Next.js may be newer than you know.** If the project has `AGENTS.md` pointing at `node_modules/next/dist/docs/`, read the relevant guide before editing config.

## 2. Config file: `.railway/railway.ts`

`railway.json` / `railway.toml` ("Config as Code") is deprecated; existing files keep working only until 2026-12-01. Don't create them. Don't hand-write `railway.ts` either — generate it so it matches the installed CLI's schema:

- **New project (linked):** `railway config init`, then set the service's build `npm run build`, start `npm run start`, healthcheck `/`.
- **Repo has `railway.json`/`railway.toml`:** `railway config migrate` (dry run, show the user), then `railway config migrate --apply --delete-files`. The migration drops `restartPolicyType`/`restartPolicyMaxRetries`; Railway's default already restarts on failure, but mention it if the old file set them.
- Preview with `railway config plan`; apply with `railway config apply`.

The healthcheck on `/` matters: Railway only switches traffic to a new deployment once it answers, so a broken build never replaces a working site.

## 3. Finding or creating the project

```bash
railway status            # is this folder already linked?
railway list --json       # projects and their services
```

If a project already has a service for this app, `railway link --project <id> --service <name>`. Only `railway init --name <app>` when nothing matches — a duplicate project splits data and domains. `railway init` links the folder to the new project's environment; the first `railway up` creates the service.

## 4. Deploying (two paths)

Check `railway status` for a `repo:` line.

- **Connected to GitHub** → deploys happen on `git push` to the tracked branch. Commit and push (ask before pushing).
- **No repo connected** (the default for projects made with this skill) → `railway up --ci` uploads the folder, streams build logs, and exits when the build finishes. It respects `.gitignore`; add a `.railwayignore` for anything else that shouldn't be uploaded (stray worktrees such as `.kilo/`, `.claude/worktrees/`).

Get a public URL with `railway domain` (generates `*.up.railway.app`). `railway domain list` shows existing ones.

## 5. Verifying and reading logs

```bash
railway deployment list --limit 3 --json    # latest should be SUCCESS
curl -s -o /dev/null -w "%{http_code}\n" https://<domain>
```

On failure, read logs before changing anything:

```bash
railway logs --build --lines 200         # build failed
railway logs --deployment --lines 200    # app crashed after starting
```

Always pass `--lines` (or `--since`) — without it `railway logs` streams forever and never returns.

Usual causes: start script on localhost or a fixed port; a missing env var; a file the build needs is gitignored.

## 6. Databases

```bash
railway add --database postgres     # or mysql, redis, mongo
```

Wire it to the app with a reference variable, not a copied connection string — the reference follows credential rotation and uses the private network:

```bash
railway variable set 'DATABASE_URL=${{Postgres.DATABASE_URL}}' --service <app-service>
```

Single quotes stop the shell expanding `${{…}}`. The name before the dot is the database service's name from `railway status`.

**Private network gotcha:** `*.railway.internal` resolves only at runtime, not during the build. A page that queries the DB while prerendering at build time fails — make such routes dynamic, or connect lazily on first request.

For local development use the database's public URL (`DATABASE_PUBLIC_URL`) in `.env.local`; the private host doesn't resolve from a laptop.

## 7. Environment variables

```bash
railway variable list --service <app-service>
railway variable set KEY=value --service <app-service>
echo "$SECRET" | railway variable set API_KEY --stdin --service <app-service>
```

Pipe secrets through `--stdin` so they stay out of shell history. Each set triggers a redeploy; add `--skip-deploys` when setting several and finish with `railway redeploy --yes`.

`railway run <cmd>` runs a local command with the service's variables injected (e.g. migrations).

## 8. Custom domains

The domain is bought elsewhere (e.g. Cloudflare). Then:

```bash
railway domain example.com          # prints the DNS records to add
railway domain status example.com   # check verification
```

The user adds the printed CNAME (and TXT, if shown) at their DNS provider — point by name, never by IP, because Railway's IPs aren't fixed. An apex domain (no `www`) needs a DNS provider that supports CNAME flattening/ALIAS (Cloudflare does). If Cloudflare's proxy is on, SSL/TLS mode must be **Full**, or the site loops on redirects. Railway issues and renews HTTPS certificates automatically.
