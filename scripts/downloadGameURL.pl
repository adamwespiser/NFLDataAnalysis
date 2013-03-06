#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;

use lib '/home/adam/programming/github/NFLDataAnalysis';
use nfl; 


#use lib '/users/dcaffrey/bin';
# # # # # # # DESCRIPTION # # # # # # # 
#this code is designed to 

my ($inFile,$outFile);
GetOptions('i=s' => \$inFile, 'o=s' => \$outFile) or &usage;
my ($in, $out);
if (!defined $inFile){ print STDERR "\n\-i option was not specified\n";&usage;}
unless(open  $in, '<' ,$inFile){ print STDERR ("Could not open $inFile\n");&usage;}

  my $dir = "/home/adam/programming/github/NFLDataAnalysis/data/nflGamePages/";
  my $lcToAbr = &getTeamLcToAbrHash();
#  for my $key (keys %$lcToAbr){
#    print $lcToAbr->{$key}." ".$key."\n";
#  }
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
  system($cmd);
}
close($in);

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
