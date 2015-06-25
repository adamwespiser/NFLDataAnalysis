#NFL Data Analysis

#### TODO
1) fix penalty for play type

### Analysis
1) what is the probablity of making a field goal at a given position?
2) what is the probability of scoring given a starting field position(expected score)
3) How does changing the xtra point to the 15 yardine affect teams?
		expected outcome of extra point at 2 ydline vs. feild goal
		How will this affect 2pt conv. or PA attemps?
		what is the effect of weather this has?

4) Is it worth it to go for it on 4th down?
		a = go for it (expected team points - expected opp points)
    b = punt      (        0            - expected opp points)
		if a/b < 1, then go for it is favorable



library(data.table)
DT <- fread(.csv)
 DT <- fread("2002-2011_nfl_play_type_plus.csv")

