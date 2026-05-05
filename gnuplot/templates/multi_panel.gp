load "~/.config/gnuplot/lib/style_publication.gp"

set multiplot layout 1,2 title "Combined Spectroscopic Analysis"

# --- Panel A ---
set lmargin at screen 0.1
set rmargin at screen 0.45
set title "Raman"
plot "raman.dat" w l

# --- Panel B ---
set lmargin at screen 0.55
set rmargin at screen 0.9
set title "Photoluminescence"
plot "pl.dat" w l

unset multiplot
