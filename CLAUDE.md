# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

The static marketing/documentation website for **pkggen** (a universal desktop packaging
& deployment pipeline), served at https://pkggen.madladsquad.com/. It is built with
**Hugo** and deployed to **Cloudflare Pages**.

The site ships **no JavaScript** and loads **no third-party resources** — fonts, styles,
icons and syntax highlighting are all self-hosted or done at build time. Keep it that way:
it is the basis for the claims in `content/privacy-policy.md`, and for the strict
Content-Security-Policy in `static/_headers`.

## Setup

Clone with submodules (`docs` is the pkggen GitHub wiki):

```bash
git submodule update --init --recursive
```

Install Hugo (any 0.146+; CI pins the version below). The **extended** build is not
required — deliberately no SCSS is used, because Cloudflare Pages does not reliably
provision `hugo_extended`.

## Build / run

- `hugo server` — local dev server on **http://localhost:1313** with live reload.
  Unlike the old pipeline, local URLs match production exactly.
- `hugo --gc` — production build into `public/`. CSS is concatenated, minified and
  fingerprinted automatically when `hugo.IsProduction` (i.e. not `hugo server`).

There is no test suite, linter, or package manager. Deployment is automatic.

## How the page system works

Hugo assembles pages from the usual places, with two project-specific wrinkles:

1. **Layouts** live in `layouts/` using the modern (v0.146+) convention: `baseof.html`,
   `home.html`, `page.html`, `section.html`, `404.html`, plus `layouts/_partials/` and
   `layouts/_markup/`. There is **no external theme**. `layouts/docs/` overrides the
   docs section so it gets the two-column sidebar layout.
2. **The landing page markup lives in `layouts/home.html`**, not in content. It is bespoke
   marketing markup; `content/_index.md` only carries the title. Its code samples use the
   `{{ highlight }}` function with **backtick raw strings**, because the samples contain
   literal `{{ pkgname }}` placeholders that must not be parsed as template actions.

### The docs submodule

`docs/` is the **pkggen GitHub wiki** (`pkggen.wiki.git`) and stays the source of truth.
`hugo.toml` mounts it into the content tree rather than copying it:

- `docs/*.md` → `content/docs/`, excluding `_Sidebar.md`, `_Footer.md` and `Home.md`.
  Note the exclusion glob syntax requires a **space** after `!` (`"! _Sidebar.md"`).
- `docs/Home.md` → `content/docs/_index.md`, so the wiki's Home page is the docs index.
  It has no front matter, so a scoped `[[cascade]]` supplies the "Documentation" title.
- `docs/_Sidebar.md` is rendered as the real sidebar by
  `layouts/_partials/docs-sidebar.html`, which reads the file with `os.ReadFile`.

Wiki pages carry **no front matter**, and Hugo no longer derives a title from the
filename, so `layouts/_partials/page-title.html` does it. Use that partial, not `.Title`,
anywhere a page title is rendered.

Links to `github.com/MadLadSquad/pkggen/wiki/<Page>` are rewritten to local `/docs/<slug>/`
paths by `layouts/_partials/wiki-url.html`, used from both the sidebar partial and the
`layouts/_markup/render-link.html` render hook.

`> [!NOTE]` GitHub alerts in the wiki are rendered as styled callouts by
`layouts/_markup/render-blockquote.html`.

### Assets

Everything in `assets/` goes through Hugo Pipes and is only published if a template
references it — so the large source SVGs stay out of the build.

- `assets/css/fonts.css` is run through `resources.ExecuteAsTemplate`, so its `url()`s
  resolve to real fingerprinted font files. Keep the `unicode-range` declarations: they
  are what stops browsers downloading font subsets (and the 480 KB emoji font) they don't need.
- `assets/css/chroma.css` is generated — regenerate with
  `hugo gen chromastyles --style=dracula > assets/css/chroma.css`.
- `assets/img/{favicon,pkggen-logo}.svg` are the **sources**. The shipped rasters
  (`favicon.ico`, `apple-touch-icon.png`, `og-image.png`, `pkggen-logo.webp`) are generated
  from them with `rsvg-convert` + `magick`; the originals are hundreds of KB and are not served.

Editing rules of thumb:
- Site chrome (nav, footer, meta tags) → `layouts/_partials/`, not each page.
- Documentation content → edit it in the **pkggen wiki** (the `docs` submodule upstream).
- Styles → `assets/css/main.css`.

## Deployment (Cloudflare Pages)

Deployed by **Cloudflare Pages' Git integration** — no GitHub Actions workflow is involved.
Cloudflare builds on every push to `master`. Build configuration lives in the Cloudflare
dashboard:

| Setting | Value |
|---|---|
| Build command | `hugo --gc` |
| Output directory | `public` |
| `HUGO_VERSION` | `0.166.0` |
| `HUGO_ENVIRONMENT` | `production` |

Cloudflare clones with `--recurse-submodules`; the `docs` submodule is a public HTTPS URL
so it resolves without credentials.

- `static/_redirects` — 301s from the old capitalised GitHub Pages doc URLs to the new
  lowercase ones. Don't remove these.
- `static/_headers` — security headers and the strict CSP. If you ever add a script or a
  third-party asset, this file and the privacy policy both have to change.
- `.github/workflows/update-dependencies.yaml` — scheduled job that bumps the `docs` wiki
  submodule on the `auto` branch and opens a tracking issue.
