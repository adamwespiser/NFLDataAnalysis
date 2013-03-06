#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;

use lib '/home/adam/programming/github/NFLDataAnalysis/scripts';
use nfl; 


#use lib '/users/dcaffrey/bin';
# # # # # # # DESCRIPTION # # # # # # # 
#this code is designed to 

my ($inFile,$outFile,$dir);
GetOptions('i=s' => \$inFile, 'o=s' => \$outFile) or &usage;
my ($in, $out);
if (!defined $inFile){ print STDERR "\n\-i option was not specified\n";&usage;}
if (!defined $outFile){ print STDERR "\n\-o option was not specified\n";&usage;}
unless(open  $in, '<' ,$inFile){ print STDERR ("Could not open $inFile\n");&usage;}
unless (open $out,'>', $outFile ){ print STDERR "Could not write to  $outFile\n";}

my $header = <$in>;
$header=~s/\n//g;
$header=~s/[^a-z,]//g;
print $out $header.",hometeam,awayteam,year,month,date,playType\n";
my $total = 0;
my $nf = 0;
while (defined(my $line =<$in>)){
  next if $line =~ m/fttxt1/g;
  next if $line =~ m/20111204_DET/;
  $line=~s/\n//g;
  my @line = split ',',$line;
  my ($gameid,$qtr,$min,$sec,$off,$def,$down,$togo,$ydline,$description,$offscore,$defscore,$season) = @line;
  $season =~ s/[^0-9]//g;
  $line[12] = $season;
  my ($home, $away) = &getHomeAwayTeamsFromGameId($gameid);   
  my ($year,$month,$day) = &getYearMonthDayFromGameId($gameid);

  my $playType =  &determinePlayType($description);
  print $out join(',',@line,$home,$away,$year,$month,$day,$playType)."\n";
  $total = $total + 1;
##  if ($playType ~~ "noneFound"){
#    print "...${playType}\n";
#	print $line."\n";
#	$nf = $nf + 1;
#    print "${nf} / ${total} missing\n"; 
#  }
}
close($in);
close($out);

sub usage{
print STDERR "\n\n";
print STDERR "This script ...\n";
print STDERR "Usage:\n\n";
print STDERR "\n";
print STDERR "perl $0 [-i inFile] [-o outFile] \n";
print STDERR "cp \n";
print STDERR "perl $0 -i  -o  \n";
exit;
}
