#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;

use lib '/home/adam/work/projects/NFLDataAnalysis/scripts';
use nfl; 


# # # # # # # DESCRIPTION # # # # # # # 
#this code is designed to add the yards gained for run and pass plays

my ($inFile,$outFile,$dir);
GetOptions('i=s' => \$inFile, 'o=s' => \$outFile) or &usage;
my ($in, $out);
if (!defined $inFile){ print STDERR "\n\-i option was not specified\n";&usage;}
if (!defined $outFile){ print STDERR "\n\-o option was not specified\n";&usage;}
unless(open  $in, '<' ,$inFile){ print STDERR ("Could not open $inFile\n");&usage;}
unless (open $out,'>', $outFile ){ print STDERR "Could not write to  $outFile\n";}

my $lastPos = "";
my $lastGame = "";
my $driveId = 0;
my $lastydline = 0;

my $header = <$in>;
print $out $header;
while (defined(my $line =<$in>)){
  $line=~s/\n//g;
  my @line = split ',',$line;
  my ($gameid,$qtr,$min,$sec,$off,$def,$down,$togo,$ydline,$description,$offscore,$defscore,$season,$home,$away, $year, $month, $day, $playType) = @line;

	my $penaltyStatus = &determinePenaltyStatus($description);
	my $yardsGained = &determineYardsGained($description, $playType);
	my $fieldGoalStatus = &getFieldGoalStatus($description, $playType);

	my $drive = 'NA';
	my $netYardChange = 0;
	if ($lastPos eq $off and $lastGame eq $gameid){
    $drive = $driveId;
		$netYardChange = $ydline - $lastydline;
  } else {
		$lastPos = $off;
		$lastGame = $gameid;
		$driveId++;
		$drive = $driveId;

		$netYardChange = 0;
  }
  my $noplay = &getNoPlayStatus($description);
  print "${playType} status=${fieldGoalStatus} desc=${description}\n";


  $lastydline = $ydline;

	#print "${drive} ${playType} down=${down} togo= ${togo} gained= ${yardsGained}  offscore= ${offscore} ${description}\n";
	#print "${drive} ${off} ${playType} yd=${ydline} time=(${min}:${sec}) offscore=$offscore ${gameid}  ${description}\n";


	#print $out join(',',$line),"\n";
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
