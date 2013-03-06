#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;

use lib '/home/adam/programming/github/NFLDataAnalysis';
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
print $out $header;
while (defined(my $line =<$in>)){
  $line=~s/\n//g;
  my @line = split ',',$line;
  my ($gameid,$qtr,$min,$sec,$off,$def,$down,$togo,$ydline,$description,$offscore,$defscore,$season) = @line;
  my ($home, $away) = &getHomeAwayTeamsFromGameId($gameid);   
  my ($year,$month,$day) = &getYearMonthDayFromGameId($gameid);

  print $out join(',',$line),"\n";
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
