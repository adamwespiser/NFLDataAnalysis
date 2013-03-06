#!/usr/bin/perl

use strict;
my $file = "/home/adam/programming/github/NFLDataAnalysis/data/nflURLLinks.csv";
open my $out, '>',$file;
print $out "nflLink,year,week,weekNumber,date,awayTeam,hometeam\n";
for my $season (2002..2012){
  for my $weekNum (1..21){
    my $week = "";
    if ($weekNum < 18){
      $week = "REG".$weekNum;
    }
    else {
      $week = "POST".$weekNum;
    }

    my $url = "http://www.nfl.com/scores/${season}/${week}";
    my $dir = "/home/adam/programming/github/NFLDataAnalysis/data/nflGameLinks/";
    my $outFile = "${dir}${season}_${week}_gameLinks.html";
    my $cmd = "wget $url -O $outFile 2>&1 > /dev/null";


    if (!-e $outFile){
      print $cmd."\n";
      open my $fcmd, '-|', $cmd; 
      while(<$fcmd>){
        print ".";
      }
      close($fcmd);
      print "getting ".$url."\n";
    }

    open my $of, '<', $outFile;

    while(defined( my $line = <$of>)){
      if ($line =~ m/linkBack/){
	    my @line = split "\'", $line;
		my $nflLink = $line[1];
		my $nflGameId = (split '/', $nflLink)[4];
		my $year = substr( $nflGameId, 0,4);
		my $month = substr( $nflGameId, 4,2);
		my $day = substr( $nflGameId, 6,2);
		my $date = "${month}/${day}/${year}";
		my ($awayteam,$hometeam) = split '@', (split '/', $nflLink)[7];
	    print $out "${nflLink},${season},${week},${weekNum},${date},${awayteam},${hometeam},${nflGameId}\n";
      }	
    }
  
  }#end year
}#end week
close($out);

