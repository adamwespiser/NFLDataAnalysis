use strict;
use warnings;

my $timeInfoFile = "/home/adam/programming/github/NFLDataAnalysis/data/nflClubInfo.csv";

sub getTeamLcToAbrHash(){
  open my $fh, '<', $timeInfoFile or print "cannot open $timeInfoFile\n\n";
  my $lcToABR = {};
  while( defined ( my $line = <$fh>)){
    chomp($line);
    my ($abr,$full,$conf,$div,$lc)  = split ',', $line;
    $lcToABR->{$lc} = $abr;
  }
  return $lcToABR;
}

sub getTeamAbrToLcHash(){
  open my $in, '<', $timeInfoFile or print "cannot open $timeInfoFile\n";
  my $lcToABR = {};
  while( defined ( my $line = <$in>)){
    chomp($line);
    my ($abr,$full,$conf,$div,$lc)  = split ',', $line;
    $lcToABR->{$abr} = $lc;
  }
  return $lcToABR;
}

#play types: run, pass, incompletePass, punt, kickoff, extra-point,2pt,safety
sub determinePlayType(){
	my $desc = shift;
	return "pass" if ($desc =~ m/ pass / or $desc =~ m/ passed incomplete/);
	return "run" if ($desc =~ m/ up the middle | left end | right end | left tackle | right tackle | left guard | right guard | rushed / );
	return "kickoff" if ($desc !~ m/^\(/ and $desc =~ m/ kicks /);
   return "extraPoint" if ($desc =~ m/ extra point /);	
   return "field goal" if ($desc =~ m/ field goal /);
   return "kneel" if ($desc =~ m/ kneels /);
   return "sack" if ($desc =~ m/ sacked /); 
   return "punt" if ($desc =~ m/ punts /); 
   return "puntBlock" if ($desc =~ m/ punt is BLOCKED /); 
   return "puntFakeOrLoss" if ($desc =~ m/\(Punt formation\)/);
   return "penalty" if ($desc =~ m/PENALTY /); 
   return "spike" if ($desc =~ m/ spiked /); 
   return "fumble" if ($desc =~ m/ FUMBLES /);
   return "twoPtConv" if ($desc =~ m/POINT CONVERSION ATTEMPT/);
   return "underReview" if ($desc =~ /play under review/);
   return "onsideKickFormation" if ($desc =~ m/\(Onside Kick formation\)/ );
   return "qbScramble" if ($desc =~ m/ scrambles /);
   #return "qbRun" if ($desc =~ m/[A-Za-z]+\sto\s[A-Z]+\sfor/);
   #if ($desc =~ m/(\d\d\)\s+\w\.\w+\sto\s[A-Z]+\s\d+)/){
   if ($desc =~ m/(\s+\w\s?\.\w+\sto\s[A-Z]+\s)/ 
				   or $desc =~ m/(\s+\w\s?\.\w+\sfor\s-?[\d]+\syards)/ 
				   or $desc =~ m/(pushed|ran) ob /){
#   		print "....$1\n";
		return "run";
}
  if (  ($desc =~ m/to/ or $desc =~ m/touchdown/i) 
		and $desc =~ m/yards?/
		and $desc =~ m/for/
		and $desc !~ m/pass/
        and $desc !~ m/kicked/){
        
	return "runDefault";
  }  
   #return "qbRun" if ($desc =~ m/\)\s[A-Z]\.[A-Za-z]+\sto\s[A-Z]+\sfor\s[0-9]+\sy/);
	return "noneFound";
}



sub getYearMonthDayFromGameId(){
	my $id = shift;
	my $year = substr($id,0,4);
	my $month = substr($id,4,2);
	my $day = substr($id,6,2);
	return ($year,$month,$day);
}

sub getHomeAwayTeamsFromGameId(){
	my $id = shift;
	my $teams = (split "_",$id)[1];
	my ($away_team,$home_team) = split "@", $teams;
	return ($home_team, $away_team);
}





1;





