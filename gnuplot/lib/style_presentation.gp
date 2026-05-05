# ── Presentation Quality (Projector Optimized) ──────────────────────
# Reload publication base first, then override
load "~/.config/gnuplot/lib/style_publication.gp"

# Override line widths and point sizes for distance viewing
set linetype 1 lw 4 pt 7 ps 1.5
set linetype 2 lw 4 pt 9 ps 1.5
set linetype 3 lw 4 pt 5 ps 1.5
set linetype 4 lw 4 pt 13 ps 1.5

# Font Scaling (assuming pdfcairo or qt)
set tics font ",16"
set xlabel font ",20" offset 0,-1
set ylabel font ",20" offset -1,0
set key font ",16" spacing 1.5 vertical maxrows 3

# Margin adjustment for large fonts
set bmargin 5
set lmargin 12
