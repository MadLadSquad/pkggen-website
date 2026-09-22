# Bundled fonts

These are served from this site's own domain so that no request is made to a
third-party font host. See `content/privacy-policy.md` §4.

## Ubuntu (`ubuntu-*.woff2`)

Copyright 2010-2011 Canonical Ltd. Licensed under the **Ubuntu Font Licence,
Version 1.0**, which permits redistribution: <https://ubuntu.com/legal/font-licence>

Only the `latin` and `latin-ext` subsets are shipped, at weights 400 and 700.
The files and their `unicode-range` declarations come from the Google Fonts CSS
API; regenerate the list with:

```bash
curl -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36' \
  'https://fonts.googleapis.com/css2?family=Ubuntu:wght@400;700&display=swap'
```

## Twemoji Mozilla (`TwemojiMozilla.woff2`)

Copyright Twitter, Inc. and other contributors. Licensed **CC-BY 4.0**:
<https://github.com/mozilla/twemoji-colr>

Used so emoji render identically regardless of the operating system's own emoji
font. Its `unicode-range` restricts it to emoji codepoints, so the ~480 KB file
is only downloaded on pages that actually contain an emoji.
