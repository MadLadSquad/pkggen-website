# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

The static marketing/documentation website for **pkggen** (a universal desktop packaging
& deployment pipeline), served at https://pkggen.madladsquad.com/. It is built with
**UVKBuildTool (UBT)** — a custom C++ static-site/templating tool vendored as the
`UVKBuildTool` git submodule — plus `pandoc` for converting wiki Markdown to HTML.

## Setup

Clone with submodules (required — both `UVKBuildTool` and `docs` are submodules):

```bash
git submodule update --init --recursive
```

Build the UBT binary once (Linux/macOS; needs CMake + `libyaml-cpp-dev`):

```bash
cd UVKBuildTool && ./setup-web.sh .. && cd ..
```

`setup-web.sh` also scaffolds `UBTCustomFunctions/` and `Translations/ui18n-config.yaml`
into the project root if missing.

## Build / run

- `./run.sh` — runs UBT (`UVKBuildTool --build build .`), which executes the
  `custom-pre-generation-commands` from `uvproj.yaml` (i.e. `generate-html.sh`), expands
  templates, and (unless disabled) serves the site locally on **http://localhost:8080**
  via the `localhost-commands` in `uvproj.yaml`. This is the normal local dev command.
- `./generate-docs.sh` — preprocesses the `docs/` wiki submodule: appends `_Sidebar.md` to
  each page, rewrites `github.com/MadLadSquad/pkggen/wiki` links to `pkggen.madladsquad.com/docs`,
  and copies `Home.md` → `docs.md`. Run before a full build when docs changed.
- `./generate-html.sh` — converts every `.md` (root + `docs/`) to `.html` with `pandoc`
  (using `template.html`), in parallel via GNU `parallel`. Invoked automatically by UBT.
- `./ci-clean.sh` — **production-only** post-build step: flattens `build/` into the repo
  root, deletes sources, and rewrites relative URLs to absolute production URLs. Destructive;
  do not run during local development.

There is no test suite, linter, or package manager (`index.js` is essentially empty).
Deployment is fully automated by GitHub Actions.

## How the page system works (the big picture)

UBT assembles pages from three layered sources; understanding this layering is key to
editing anything:

1. **Hand-written pages** — `index.html`, `404.html`, `community.md` at the repo root.
2. **Reusable components** — `Components/*.tmpl.html` (header, footer, `<head>`). Pages pull
   them in with `{{ include Components/xxx.tmpl.html }}` directives that UBT resolves at build
   time. `.tmpl.html` is registered as an `intermediate-extensions` in `uvproj.yaml`, so these
   are partials, not standalone output pages.
3. **Documentation** — the `docs/` submodule is the **pkggen GitHub wiki**
   (`pkggen.wiki.git`), authored in Markdown. `generate-html.sh` wraps each doc in
   `template.html` (which itself includes the same `Components/*` partials) via pandoc.

`uvproj.yaml` is the UBT project manifest: `allowed-extensions`, `filename-blacklist`
(dirs UBT must not emit, e.g. `UVKBuildTool`, `.github`), `intermediate-extensions`,
build-time `variables` (e.g. `trademark`), and the localhost/pre-generation command hooks.

**URL handling:** sources use relative `./` and `.html` links for local dev. The production
pipeline rewrites these — stripping `.html`/`index.html` and turning `./` into
`https://pkggen.madladsquad.com/` — so links must remain in the local-relative form in
source. `.htaccess` provides the matching extensionless-URL rewrite for non-Pages hosting.

Editing rules of thumb:
- Site chrome (nav, footer, meta tags, fonts) → edit `Components/*.tmpl.html`, not each page.
- Documentation content → edit it in the **pkggen wiki** (the `docs` submodule upstream),
  not by hand in generated HTML.
- Styles → `main.css` (copied into the build by `generate-html.sh`).

## Deployment (GitHub Actions)

- `.github/workflows/pages.yaml` — on push to `master`: pulls submodules, installs the
  latest pandoc (`get-latest-pandoc.py` downloads the newest `.deb` from the pandoc
  releases API) and `libyaml-cpp-dev`, builds UBT (`setup-web.sh`), sets
  `run-localhost-automatically: false`, runs `run.sh` → `ci-clean.sh`, minifies JS/CSS/HTML
  (terser/csso/html-minifier), rewrites URLs to production, then builds & deploys via Jekyll
  to GitHub Pages.
- `.github/workflows/update-dependencies.yaml` — scheduled job that bumps the submodules
  (UBT + docs wiki) on the `auto` branch and opens a tracking issue.
