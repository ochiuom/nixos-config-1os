# Base style load
load "~/.config/gnuplot/lib/style_publication.gp"

set title "Structural Characterization of Sample A"
set xlabel "Applied Strain (%)"
set ylabel "Stress (MPa)"

# Optional: Secondary Y-axis
# set y2label "Poisson Ratio"
# set y2tics
# set link y2 via y*0.1 inverse y/0.1

plot "data.dat" u 1:2 w lp ls 1 title "Experimental", \
     "data.dat" u 1:3 w l  ls 2 title "Theory"
