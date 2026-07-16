# carrel pack — the token-budget stats table. Record from the repo root: vhs demo/pack.tape
# --stats writes nothing, so this runs safely in the repo itself.
Output assets/demo/pack.gif

Require carrel

Set Shell bash
Set Theme {"name":"carrel","background":"#14100A","foreground":"#F2EADA","cursor":"#F2A93C","cursorAccent":"#14100A","selection":"#443826","black":"#211A11","red":"#C4573D","green":"#7D9257","yellow":"#F2A93C","blue":"#6E9EBF","magenta":"#A9748F","cyan":"#6FAEA5","white":"#A19278","brightBlack":"#443826","brightRed":"#E07856","brightGreen":"#9DB47A","brightYellow":"#F7C36E","brightBlue":"#8FB8D4","brightMagenta":"#C495AC","brightCyan":"#8FC9C0","brightWhite":"#F2EADA"}
Set Width 1000
Set Height 790
Set FontSize 13
Set Padding 16
Set Framerate 20
Set PlaybackSpeed 1.0
Set TypingSpeed 50ms
Set CursorBlink false

Sleep 0.5
Type "carrel pack src --stats"
Enter
Sleep 2
# hold so the table + TOTAL row can be read
Sleep 6.5
