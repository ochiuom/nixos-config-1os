# ── Terminal auto-detection ───────────────────────────────────────────
# Called by ~/.gnuplot — do not load manually
if (GPVAL_TERMINAL eq "wxt" || GPVAL_TERMINAL eq "qt") {
    # Interactive session
    load "style_publication.gp"
    print ">>> [gnuplot] interactive: style_publication loaded"
} else {
    if (GPVAL_TERMINAL eq "pdfcairo" || GPVAL_TERMINAL eq "pngcairo" || \
        GPVAL_TERMINAL eq "tikz") {
        # Batch/export session — style loaded by export.gp explicitly
        # Do nothing here; export.gp handles it
        print ">>> [gnuplot] batch terminal detected: defer to export.gp"
    } else {
        # Fallback (dumb, unknown)
        load "style_publication.gp"
        print ">>> [gnuplot] fallback: style_publication loaded"
    }
}
