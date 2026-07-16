# demo/ — reproducible demo recordings

The GIFs in `assets/demo/` are recorded from the committed [vhs](https://github.com/charmbracelet/vhs) tapes here — never screen-captured by hand.

To re-record (from the repo root):

```sh
# needs: vhs + ttyd on PATH (static binaries work), ffmpeg, and `carrel` installed
vhs demo/desk-tour.tape
vhs demo/pack.tape
vhs demo/redact-proof.tape
```

Each tape does its file work in a scratch directory under `/tmp/carrel-demo/` (or, for `pack.tape`, runs a command that writes nothing), so recording never dirties the repo. The terminal theme inside each tape is the brand palette from [docs/BRAND.md](../docs/BRAND.md).

Budgets, enforced by review at record time: ≤20 s, 1000 px wide, ≤4 MB per GIF.
