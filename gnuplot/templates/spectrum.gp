load "~/.config/gnuplot/lib/style_publication.gp"

set xlabel "Wavenumber (cm^{-1})"  # Use LaTeX-style formatting
set ylabel "Normalized Intensity (a.u.)"
unset ytics                        # Standard for spectra comparison

# Define offsets for stacking (Researcher Pro Move)
off1 = 0.5
off2 = 1.0

set xrange [200:1000]

plot "raman_300k.dat" u 1:($2/max_val)          w l ls 1 title "300 K", \
     "raman_100k.dat" u 1:($2/max_val + off1)   w l ls 2 title "100 K", \
     "raman_10k.dat"  u 1:($2/max_val + off2)   w l ls 3 title "10 K"
