# ── Research-Grade Colormaps (Perceptually Uniform) ────────────────
# Prevents "false gradients" caused by Jet/Rainbow palettes

# Option: Viridis (Standard for science)
set palette defined ( 0 '#440154', 1 '#443983', 2 '#31688e', 3 '#21918c', \
                      4 '#35b779', 5 '#8fd744', 6 '#fde725' )

# Plotting Settings
set view map               # 2D view for pm3d
set size ratio -1          # Square pixels (important for physical data)
set pm3d interpolate 0,0   # Change to 2,2 for smoothing coarse data
set pm3d flush begin noftriangles corners2color mean

# Colorbar (cb) styling
set cbtics scale 0
set cblabel font ",12" offset 1,0
set format cb "%.1e"       # Scientific notation for colorbar

# Remove border around the plot but keep axes
set style line 100 lt 1 lc rgb "white" lw 0
set pm3d border ls 100
