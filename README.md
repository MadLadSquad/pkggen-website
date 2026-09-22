# pkggen-website

[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)
[![Discord](https://img.shields.io/discord/717037253292982315.svg?label=&logo=discord&logoColor=ffffff&color=7389D8&labelColor=6A7EC2)](https://discord.gg/4wgH8ZE)

The website for pkggen, built with [Hugo](https://gohugo.io) and deployed to Cloudflare Pages.

## Developing

```bash
git submodule update --init --recursive   # docs/ is the pkggen wiki
hugo server                               # http://localhost:1313
```

Hugo 0.146 or newer. The *extended* build is not required.

Documentation content lives in the [pkggen wiki](https://github.com/MadLadSquad/pkggen/wiki),
which is vendored here as the `docs/` submodule — edit it there, not in this repository.

## Building

```bash
hugo --gc     # output in public/
```
