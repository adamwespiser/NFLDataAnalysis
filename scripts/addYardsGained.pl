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
unless (open $out,'>', $outFile ){ print STDERR "Could not write to  $outFile\n";&usage;}

my $lastPos = "";
my $lastGame = "";
my $driveId = 0;
my $lastydline = 0;
my $lastHalf = "";
my $header = <$in>;
$header =~ s/\n//g;
print $out $header.",driveId,penaltyStatus,noplay,yardsGained,fgStatus,turnoverEvent,twoPointAttempt,half\n";
while (defined(my $line =<$in>)){
  $line=~s/\n//g;
  my @line = split ',',$line;
  my ($gameid,$qtr,$min,$sec,$off,$def,$down,$togo,$ydline,$description,$offscore,$defscore,$season,$home,$away, $year, $month, $day, $playType) = @line;

	$description = &handleReverseCalls($description);
	$playType =  &determinePlayType($description);
	my $penaltyStatus = &determinePenaltyStatus($description);
	my $yardsGained = &determineYardsGained($description, $playType);
	my $fieldGoalStatus = &getFieldGoalStatus($description, $playType);
  my $extraPoint      = &determine2ptConv($description);
  my $half            = &getHalfFromQuater($qtr);

	# fix error assigning ydline when enforced penalty present in punt
	if (( $playType eq "punt") and ($penaltyStatus eq "enforced")){
		my $newydline = &getPuntYardLine($description,$ydline);
		#if (not ($ydline eq $newydline)){
		#			print "old=${ydline} new=${newydline} desc=${description}\n";
		#}
		$ydline = $newydline;
  }

	my $drive = 'NA';
	my $netYardChange = 0;
	# update driveID if onside kick(pocession won't change)
	if ($playType eq "onsideKick" or $playType eq "kickoff"){
		 $driveId++;
  } 
	if ($lastPos eq $def and $lastGame eq $gameid and $half eq $lastHalf){
    $drive = $driveId;
		$netYardChange = $ydline - $lastydline;
  } else {
		$lastPos = $def;
		$lastGame = $gameid;
		$lastHalf = $half;
		$driveId++;
		$drive = $driveId;

		$netYardChange = 0;
  }
  my $noplay = &getNoPlayStatus($description);
	my $fumble = &determineTurnoverEvent($description);
	#print "${playType} status=${fumble} drive=${driveId} DEF=${def}  OFF=${off} desc=${description}\n";


  $lastydline = $ydline;

	print $out join(',',$gameid,$qtr,$min,$sec,$off,$def,$down,$togo,$ydline,$description,$offscore,$defscore,$season,$home,$away, $year, $month, $day, $playType,$driveId,$penaltyStatus, $noplay, $yardsGained, $fieldGoalStatus, $fumble,$extraPoint,$half)."\n";
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
