load "~/.config/gnuplot/lib/style_publication.gp"
load "~/.config/gnuplot/lib/colormap.gp" # Loads Viridis/Settings

set title "Potential Energy Surface"
set xlabel "X-Coordinate (Å)"
set ylabel "Y-Coordinate (Å)"
set zlabel "Energy (eV)" rotate by 90

# 3D Specifics
set xyplane at 0            # No floating base
set view 60, 30, 1.0, 1.0   # Professional angle
set hidden3d                # Hide lines behind the surface

splot "grid_data.dat" u 1:2:3 with pm3d title "PES Scan"
