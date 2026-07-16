# carrel redact — prove the text is really gone. Record from the repo root: vhs demo/redact-proof.tape
# Works on a scratch copy in /tmp so the repo is never touched.
Output assets/demo/redact-proof.gif

Require carrel
Require pdftotext

Set Shell bash
Set Theme {"name":"carrel","background":"#14100A","foreground":"#F2EADA","cursor":"#F2A93C","cursorAccent":"#14100A","selection":"#443826","black":"#211A11","red":"#C4573D","green":"#7D9257","yellow":"#F2A93C","blue":"#6E9EBF","magenta":"#A9748F","cyan":"#6FAEA5","white":"#A19278","brightBlack":"#443826","brightRed":"#E07856","brightGreen":"#9DB47A","brightYellow":"#F7C36E","brightBlue":"#8FB8D4","brightMagenta":"#C495AC","brightCyan":"#8FC9C0","brightWhite":"#F2EADA"}
Set Width 1000
Set Height 480
Set FontSize 14
Set Padding 16
Set Framerate 20
Set PlaybackSpeed 1.0
Set TypingSpeed 40ms
Set CursorBlink false

Hide
Type "rm -rf /tmp/carrel-demo/redact && mkdir -p /tmp/carrel-demo/redact && cp 'tests/fixtures/text+image.pdf' /tmp/carrel-demo/redact/ && cd /tmp/carrel-demo/redact && clear"
Enter
Show

Sleep 0.5
# 1. the secret is in the PDF text layer
Type `pdftotext text+image.pdf - | grep --color=always "palimpsest harbor"`
Enter
Sleep 2

# 2. true raster redaction: boxes painted over the words, no text layer survives
Type `carrel redact text+image.pdf --pattern "palimpsest harbor" -o redacted.pdf`
Enter
Sleep 3.5

# 3. proof: grep finds nothing — exit 1
Type `pdftotext redacted.pdf - | grep "palimpsest harbor"; echo "exit $?"`
Enter
Sleep 3.5
