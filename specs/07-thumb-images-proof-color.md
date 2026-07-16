# spec: thumb + extract-images + proof + color

**Owns:** `src/carrel/commands/{thumb,extract_images,proof,color}.py`, `tests/test_images_cmds.py`.

## thumb
`carrel thumb SRC... [--size 256] [--out-dir DIR=./thumbs] [--format png] [--json]`
pdf → pdftoppm first page; images → Pillow thumbnail (preserve aspect, pad none); html → weasyprint→pdf→ppm (degrade hint chain); ico → largest frame via Pillow. JSON: list of {src, thumb, w, h}.

## extract-images
`carrel extract-images SRC [--out-dir DIR] [--min-size 32] [--json]`
pdf → pdfimages -png (filter tiny by --min-size); ico → icotool -x (degrade: Pillow frame dump); html → copy local `<img src>` targets that exist relative to file. JSON: extracted file list.

## proof (ICC soft proofing)
`carrel proof SRC --profile PROFILE [--out OUT] [--intent perceptual|relative] [--json]`
PROFILE: path to .icc OR builtin alias (`cmyk` → ghostscript default_cmyk.icc, `srgb`, `gray`, `p3` — resolve from /usr/share/color/icc + gs iccprofiles, probe at runtime). Render soft proof via Pillow ImageCms (proof transform sRGB→profile→sRGB); output proofed image + JSON report {profile, intent, mean_delta (mean abs RGB diff), max_delta, pct_pixels_changed>threshold}. Missing lcms/profile → exit 3/4 with hint.

## color
`carrel color palette SRC [--n 8] [--json]` — dominant colors (Pillow quantize) as hex + proportions; human: rich color swatches.
`carrel color convert SRC --to-profile P [-o OUT]` — ImageCms convert & embed.
`carrel color check FG BG` — WCAG contrast ratio of two hex colors, pass/fail AA/AAA.

## Acceptance
thumb pdf+png fixtures sized ≤ size; extract-images on fixture pdf ≥1 png out; proof cmyk alias runs (profiles present on this box) and reports deltas; palette returns n hex colors summing ~1.0; contrast check known pair (#000/#fff = 21).
