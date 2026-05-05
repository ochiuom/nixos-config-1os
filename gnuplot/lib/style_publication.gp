# ── Publication Quality (Journal Standards) ─────────────────────────
set encoding utf8

# Colors: Paul Tol's "Bright" palette (Colorblind safe & distinct)
set linetype 1 lc rgb "#4477AA" lw 2 pt 7  ps 0.8  # Blue
set linetype 2 lc rgb "#EE6677" lw 2 pt 9  ps 0.8  # Red
set linetype 3 lc rgb "#228833" lw 2 pt 5  ps 0.8  # Green
set linetype 4 lc rgb "#CCBB44" lw 2 pt 13 ps 0.8  # Yellow
set linetype 5 lc rgb "#66CCEE" lw 2 pt 11 ps 0.8  # Cyan
set linetype 6 lc rgb "#AA3377" lw 2 pt 15 ps 0.8  # Purple
set linetype 7 lc rgb "#BBBBBB" lw 2 pt 1  ps 0.8  # Grey
set linetype cycle 7

# Canvas Aesthetics
set border 3 back lw 1.5           # Only Bottom (1) and Left (2) axes
set tics nomirror out scale 0.75   # Tics point out, no mirrored tics
set grid xtics ytics lt 0 lc rgb "#D6D6D6" lw 1

# Key (Legend) - Minimalist
set key top right box lt -1 lw 0.5 spacing 1.2 font ",11"
set key samplen 2  # Length of line samples in legend

# Default Plot Style
set style data linespoints
set style function lines
