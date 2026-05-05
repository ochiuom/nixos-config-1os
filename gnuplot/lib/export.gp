# ── Multi-Format Export Wrapper ─────────────────────────────────────
# Usage: gnuplot -e "OUTFILE='Results'; SCRIPT='plot.gp'" export.gp

if (!exists("OUTFILE")) OUTFILE='plot_output'
if (!exists("SCRIPT"))  print "Error: No SCRIPT variable defined!"; exit

# 1. PDF (Best for Papers)
set terminal pdfcairo enhanced color font "Liberation Sans,12" size 12cm,9cm
set output OUTFILE.".pdf"
print "Exporting ".OUTFILE.".pdf..."
load SCRIPT

# 2. PNG (Best for Quick Previews/Presentations)
# High DPI (300) ensures it looks good even when scaled
set terminal pngcairo enhanced color font "Liberation Sans,12" size 1200,900 dpi 300
set output OUTFILE.".png"
print "Exporting ".OUTFILE.".png..."
load SCRIPT

set output # Close file handles
