load "~/.config/gnuplot/lib/style_publication.gp"

# Higher-order model
g(x) = a*x**2 + b*x + c

# Initial guesses (Crucial for non-linear convergence)
a = 1; b = 1; c = 1

fit g(x) "data.txt" u 1:2 via a, b, c

set title "Non-linear Response"
plot "data.txt" u 1:2 w p ls 1 title "Samples", \
     g(x) w l ls 2 lw 3 title "Quadratic Fit"
