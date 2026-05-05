load "~/.config/gnuplot/lib/style_publication.gp"

# Define the Model
f(x) = m*x + b

# Perform the Fit
fit f(x) "data.txt" u 1:2 via m, b

# Display Stats on Plot
set label 1 sprintf("m = %.3f\nb = %.3f", m, b) at graph 0.05, 0.85

plot "data.txt" u 1:2 w p ls 1 title "Data", \
     f(x) w l ls 2 dt 2 title "Linear Fit"
