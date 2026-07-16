# spec: audiobook

**Owns:** `src/carrel/commands/audiobook.py`, `tests/test_audiobook.py`.

## CLI
`carrel audiobook SRC [-o OUT.mp3] [--voice VOICE] [--rate 170] [--engine auto|espeak|piper|edge-tts] [--split-chapters] [--format mp3|ogg|wav] [--json]`

## Behavior
- SRC: txt/md/pdf → text via textextract. md: strip syntax (headings → spoken "Chapter: <title>" pause markers, skip code blocks with "[code omitted]", links → text).
- Engine auto-preference: piper > edge-tts > espeak-ng (probe via adapters); only espeak-ng guaranteed here. espeak: chunk text ~4000 chars, synth WAV pieces, concat.
- ffmpeg: WAV → mp3/ogg (128k); absent ffmpeg + non-wav target → exit 3 hint; `--format wav` always works with espeak alone.
- `--split-chapters` (md/pdf-with-outline): one file per H1/H2 → OUT-NN-slug.mp3; else single file. Metadata: title from product of filename; ID3 title/track via ffmpeg -metadata.
- JSON: {src, outputs:[...], engine, duration_s (ffprobe when present else null), chars}.

## Acceptance
md fixture → mp3 exists, >1KB, ffprobe duration >0; --split-chapters on 2-chapter md → 2 files; pdf fixture → audio; engine forced espeak works; ffmpeg-absent path unit-tested via monkeypatched have().
