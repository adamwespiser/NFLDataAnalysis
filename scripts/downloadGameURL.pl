#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;

use lib '/home/adam/work/projects/NFLDataAnalysis/scripts';
use nfl; 


#this code is designed to 

my ($inFile,$outFile);
GetOptions('i=s' => \$inFile, 'o=s' => \$outFile) or &usage;
my ($in, $out);
if (!defined $inFile){ print STDERR "\n\-i option was not specified\n";&usage;}
unless(open  $in, '<' ,$inFile){ print STDERR ("Could not open $inFile\n");&usage;}

  my $dir = "/home/adam/data/nfl/gamePages/";
  my $lcToAbr = &getTeamLcToAbrHash();
  for my $key (keys %$lcToAbr){
    print $lcToAbr->{$key}." ".$key."\n";
  }
#exit;
my $header = <$in>;
my $found = 0;
my $missing = 0;
while (defined(my $line =<$in>)){
  $line=~s/\n//g;
  my @line = split ',',$line;
  my ($gameURL,$season,$week,$weekNumber,$date,$awayTeam,$homeTeam)= @line;

  my $seasonDir = "${dir}${season}";
  my $weekDir = "${dir}${season}/${weekNumber}";
  if (!-e $seasonDir){system("mkdir ${seasonDir}");}
  if (!-e $weekDir){system("mkdir ${weekDir}");}
  my $awayAbr = $lcToAbr->{$awayTeam}; 
  my $homeAbr = $lcToAbr->{$homeTeam};
  my ($month,$day,$year) = split '/', $date;
  my $playId = "${year}${month}${day}_${awayAbr}\@${homeAbr}";
  my $cmd = "wget ${gameURL} -O ${weekDir}/${playId}.html 2>&1 > /dev/null";
  print "$date $awayTeam\@$homeTeam\n" ;
	print $cmd."\n";
	system($cmd);
}
close($in);

sub usage{
print STDERR "\n\n";
print STDERR "This script ...\n";
print STDERR "Usage:\n\n";
print STDERR "\n";
print STDERR "perl $0 [-i inFile]\n";
print STDERR "cd into project dir, then:\n";
print STDERR "perl script/downloadGameURL.pl -i data/nflUrlLinks.csv\n";
exit;
}
