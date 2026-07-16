# carrel desk — TUI tour. Record from the repo root: vhs demo/desk-tour.tape
# Works on a scratch copy of the fixtures in /tmp so the repo is never touched.
Output assets/demo/desk-tour.gif

Require carrel

Set Shell bash
Set Theme {"name":"carrel","background":"#14100A","foreground":"#F2EADA","cursor":"#F2A93C","cursorAccent":"#14100A","selection":"#443826","black":"#211A11","red":"#C4573D","green":"#7D9257","yellow":"#F2A93C","blue":"#6E9EBF","magenta":"#A9748F","cyan":"#6FAEA5","white":"#A19278","brightBlack":"#443826","brightRed":"#E07856","brightGreen":"#9DB47A","brightYellow":"#F7C36E","brightBlue":"#8FB8D4","brightMagenta":"#C495AC","brightCyan":"#8FC9C0","brightWhite":"#F2EADA"}
Set Width 1000
Set Height 650
Set FontSize 14
Set Padding 16
Set Framerate 20
Set PlaybackSpeed 1.0
Set TypingSpeed 50ms
Set CursorBlink false

# ---- hidden setup: scratch desk in /tmp — never touches the repo ----
Hide
Type "rm -rf /tmp/carrel-demo/desk && mkdir -p /tmp/carrel-demo/desk"
Enter
Type "cp tests/fixtures/b.pdf tests/fixtures/form.pdf tests/fixtures/scanned.pdf 'tests/fixtures/text+image.pdf' tests/fixtures/sample.csv tests/fixtures/sample.html tests/fixtures/sample.jpg tests/fixtures/sample.json tests/fixtures/sample.md tests/fixtures/sample.png tests/fixtures/sample.txt tests/fixtures/sample.xml /tmp/carrel-demo/desk/"
Enter
# the desk db lands under --root, so root it explicitly
Type "carrel --root /tmp/carrel-demo/desk index /tmp/carrel-demo/desk"
Enter
Sleep 2
Type "clear"
Enter
Show

# ---- launch ---------------------------------------------------------
Type "carrel desk /tmp/carrel-demo/desk"
Enter
Sleep 2.5

# ---- tree → inspector (12 files, alphabetical; 8 Downs = sample.png)
Down@150ms 8
Enter
Sleep 2

# ---- actions: run "Convert → pdf" (first Down lands on option 0) ----
Tab
Tab
Down@200ms 1
Enter
Sleep 2

# ---- search ---------------------------------------------------------
Type "/"
Type "palimpsest"
Enter
Sleep 1.5
Down@200ms 2
Enter
Sleep 2.5
Escape
Sleep 1

# ---- quit -----------------------------------------------------------
Type "q"
Sleep 1.5
