# ENVIRONMENT — probed 2026-07-16

All entries verified by executing the tool (`--version` etc.), not assumed. Probe script preserved in spirit as the `doctor` command (Phase 2+).

**System:** Ubuntu 26.04 LTS on WSL2 (kernel 6.18, x86_64) · bash · 16 CPU · 29 GiB RAM
**Package managers:** apt 3.2.0, snap 2.75 (no brew)

## Present

| Tool | Version | Feeds capability |
|---|---|---|
| python3 | 3.14.4 | core runtime |
| uv / pip / pipx | 0.11.28 / 25.1.1 / 1.8.0 | dependency management |
| node / npm / pnpm | 22.22.1 / 9.2 / 11.13 | (fallback runtime, unused) |
| pandoc | 3.7.0.2 | conversion hub (md↔html↔pdf-via-engine, many more) |
| pdftotext / pdftoppm / pdfimages (poppler) | 26.01.0 | pdf text extraction, thumbnails, image extraction |
| qpdf | 12.3.2 | pdf surgery: split/merge/rotate/decrypt/linearize |
| ghostscript (gs) | 10.06.0 | pdf render/compress, ICC soft proofing, PDF/A |
| weasyprint | 69.0 | html/css → pdf (form building, styled docs) |
| tesseract | 5.5.0 (langs: eng, osd) | OCR |
| ocrmypdf | 16.13.0 | pdf OCR layer (wraps tesseract, best-in-class) |
| imagemagick (magick/convert) | 7.1.2-18 Q16 | image conversion/resize/ico, thumbnails |
| exiftool | 13.50 | metadata inspect/strip for images+pdf |
| ffmpeg | 8.0.1 | audio encode (audiobook mp3/ogg), image ops |
| pngquant | 4.0.3 | png optimization |
| icotool (icoutils) | 0.32.3 | .ico build/extract |
| jq / yq | 1.8.1 / 3.4.3 | json/yaml processing |
| mlr (miller) | 6.16.0 | csv/tsv/json transforms |
| csvkit | 2.2.0 | csv stats/utilities |
| rg (ripgrep) | 15.1.0 | fast content search |
| fdfind | 10.3.0 | fast file find (note: binary is `fdfind`, not `fd`) |
| fzf | 0.67.0 | interactive pickers (snippets) |
| sqlite3 | 3.46.1 | index/search DB (FTS5 confirmed available in Python stdlib sqlite3) |
| inotifywait (inotify-tools) | 4.23.9.0 | folder watching (native Linux events; works on ext4 in WSL2) |
| espeak-ng | 1.52.0 | TTS → WAV (verified emits RIFF/WAV to stdout) |
| gpg | 2.4.8 | detached signatures for checksum manifests |
| git / gh | 2.53.0 / 2.46.0 | vcs, repo creation (gh auth status checked at finalize time) |
| claude (Claude Code CLI) | 2.1.211 | marketplace validation in Phase 5 |
| ICC profiles | /usr/share/color/icc (Adobe/Apple compat, DCI-P3, sRGB…) + ghostscript profiles | soft proofing sources |

## Missing → implication & degradation plan

| Tool | Implication | Plan |
|---|---|---|
| mutool (mupdf) | alternate pdf renderer | not needed; poppler+gs cover it |
| wkhtmltopdf, libreoffice | alt html→pdf, office formats | weasyprint + pandoc cover html→pdf; office formats out of scope |
| oxipng | png optimization alt | pngquant present; oxipng optional hint |
| xsv | csv speed tool | mlr + csvkit cover |
| watchexec / fswatch / entr | watch runners | inotifywait present → native watch works; Python watchdog lib as portable layer |
| delta / difft | pretty diffs | render diffs ourselves (rich); optional hint |
| piper / edge-tts / say | higher-quality TTS | espeak-ng works now; adapter prefers piper/edge-tts if user installs (install hints in doctor) |
| minisign | modern signing | gpg present; manifest signing uses gpg, sha256 always available |
| go / cargo / brew | other toolchains | unused |

## Consequences for the feature matrix

- **Every required capability has at least one present tool or pure-Python path.** Nothing is blocked.
- OCR quality path is strong (ocrmypdf 16 + tesseract 5.5), English only out of the box — doctor should hint `apt install tesseract-ocr-<lang>` for more languages.
- Audiobook: espeak-ng (robotic but real) → ffmpeg → mp3. Adapter designed so piper drops in for natural voices.
- Watch: inotify events are native on the ext4 side of WSL2 (project convention: work under `~/projects`), so watching is reliable; `/mnt/c` paths would need polling — document this.
- Soft proofing: gs + ICC profiles present; CMYK preview feasible via ImageMagick `-profile` too.
- No installs performed (D-004). `doctor` command will re-probe and print apt install hints.
