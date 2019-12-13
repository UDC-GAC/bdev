#!/bin/bash

DAT_LEGEND_FILE=$1/legend.dat
PLOT_LEGEND_FILE=$1/legend.eps

#!/bin/bash

DAT_HEADER=""
DAT_LINE=""

for SOLUTION in $SOLUTIONS
do
	DAT_HEADER="$DAT_HEADER ${SOLUTION}"
	DAT_LINE="$DAT_LINE 1"
done

echo "$DAT_HEADER" > $DAT_LEGEND_FILE
echo "$DAT_LINE" >> $DAT_LEGEND_FILE

COLS=`echo $SOLUTIONS | wc -w`

echo gnuplot -e "input_file='$DAT_LEGEND_FILE'; \
		legend_file='$PLOT_LEGEND_FILE';palette_file='$PLOT_HOME/palette.plt'; \
		cols='$COLS'; " $PLOT_HOME/legend.gplot 

gnuplot -e "input_file='$DAT_LEGEND_FILE'; \
		legend_file='$PLOT_LEGEND_FILE';palette_file='$PLOT_HOME/palette.plt'; \
		cols='$COLS'; " $PLOT_HOME/legend.gplot 

rm $DAT_LEGEND_FILE