#!/usr/bin/R

library(data.table)
library(reshape2)

dataFile <<- "/home/adam/data/nfl/2002-2011_nfl_play_type_plus.csv"

annotateDrives <- function(infile=dataFile){
		DT = fread(dataFile)
    DT2 <- DT[year == 2010]
		DT2 <- DT
    DT2[driveId == 78131]

    fgGood = DT2[noplay=="play", .("good" == fgStatus[which(playType == "field goal")]),by=.(driveId)][V1 == TRUE, driveId]
    fgBad = DT2[noplay=="play", .(fgStatus[which(playType == "field goal")] %in% c("nogood","block")),by=.(driveId)][V1 == TRUE, driveId]
    punt = DT2[, .("punt" == playType[.N],yardsGained[.N]), driveId][V1 == TRUE, driveId]
		td = DT2[penaltyStatus != "enforced" & noplay == "play", .(any(which(playType == "pass" | playType == "run") %in% which(yardsGained == ydline))), driveId][V1 == TRUE,driveId]
		turnover = DT2[noplay == "play", .( (playType[.N] %in% c("run","pass","sack","fumble")) && (turnoverEvent[.N]  %in% c("fumble","interception"))), driveId][V1 == TRUE, driveId]
    turnoverOnDowns = DT2[noplay == "play", .(down[.N] == 4 && (yardsGained[.N] < togo[.N])), driveId][V1==TRUE, driveId]
    safety = DT2[, .(any("safety" %in% turnoverEvent)), driveId][V1 == TRUE, driveId]
    #kickoff = DT2[!(driveId %in% c(fgGood, fgBad, punt, td,turnover)), .(playType[1],driveId = driveId[1]),.(gameid,qtr %in% c(1,3))][qtr == TRUE,driveId]
		#kickoff2 <- DT2[noplay == "play", .(.N == 1 && playType[.N] == "kickoff"), .(driveId)][V1==TRUE, driveId]
		kickoff <- DT2[, .(.N == 1 && playType[.N] == "kickoff"), .(driveId)][V1 == TRUE,driveId]
		oKick <- DT2[, .(.N == 1 && playType[.N] == "onsideKick"), .(driveId)][V1 == TRUE,driveId]
    kneel <- DT2[, .(playType[.N] == "kneel"), .(driveId)][V1 == TRUE, driveId]
    lastDriveOfHalf <- DT2[noplay == "play", .(driveId[.N]), .(gameid,qtr)][qtr %in% c(2,4)][,V1]
		endOfHalf <- DT2[driveId %in% lastDriveOfHalf & !(playType == "kickoff" & min == 30 & qtr == 3), .(ydline = ydline[.N],yardsGained = yardsGained[.N],playType = playType[.N],min = min[.N],sec = sec[.N] ), .(driveId)][, .(playType == "kneel" || ((playType %in% c("pass", "run", "sack")) && ydline > yardsGained)),.(driveId)][V1 == TRUE,driveId]
    returnedForTD <-DT2[,(playType[.N] == "extraPoint" && .N == 1), .(driveId)][V1==TRUE,driveId]
    DT2[!(driveId %in% c(fgGood, fgBad, punt, td,turnover,turnoverOnDowns,safety,kickoff,endOfHalf,kneel,returnedForTD)), .(driveId, playType, yardsGained, turnoverEvent )][1:100]
    
    DT2[,driveScore:=NA_integer_]
    DT2[driveId %in% fgGood, driveScore := 3L]
		DT2[driveId %in% fgBad, driveScore := 0L]
		DT2[driveId %in% punt, driveScore := 0L]
		DT2[driveId %in% td, driveScore := 7L]
		DT2[driveId %in% turnover, driveScore := 0L]
		DT2[driveId %in% turnoverOnDowns, driveScore := 0L]
		DT2[driveId %in% safety, driveScore := -2L]

    DT2
}
    
getExpectedPointsForPosition = function(dt=annotateDrives()){
    DT2 = dt
  
		safety.td <-  DT2[driveScore == -2L,.(startPos = max(ydline,na.rm=TRUE), endPos=min(ydline,na.rm=TRUE)), .(driveId)
		                  ][ , .(safety=.N), .(startPos)][order(startPos)]  
		
    td.td <- DT2[driveScore == 7L,.(startPos = max(ydline,na.rm=TRUE), endPos=0L), .(driveId)
                 ][ , .(td=.N), .(startPos)][order(startPos)]    
		td.td[, endPos:=0L]
    setkey(td.td,startPos)
    
    fg.td <- DT2[driveScore == 3L,.(startPos = max(ydline,na.rm=TRUE), endPos=min(ydline,na.rm=TRUE)), .(driveId)
                 ][ , .(fg=.N), .(startPos)][order(startPos)]    
		setkey(fg.td,startPos)
    
		empty.td <- DT2[driveScore == 0L,.(startPos = max(ydline,na.rm=TRUE), endPos=min(ydline,na.rm=TRUE)), .(driveId)
		                ][ , .(empty=.N), .(startPos)][order(startPos)]    
		setkey(empty.td,startPos)
		
		together.td <- td.td[fg.td[empty.td]]
    
    # start position vs. expected point return
    start.td = together.td[, .(expScore = (7*td + 3*fg)/(td + fg + empty), N=(td+fg+empty) ), .(startPos)]
    
    
    idx = data.table(start=100L:1L,end=100L:1L)
    setkey(idx,start,end)
    
    setkey(td.td, endPos, startPos)
		td.over = foverlaps(x=idx,y=td.td,by.y=c("endPos","startPos"), by.x=c("start","end"))
    td.sum = td.over[, .(td=sum(td)), .(start)]
	
    lfg.td <- DT2[driveScore == 3L,.(startPos = max(ydline,na.rm=TRUE), endPos=min(ydline,na.rm=TRUE)), .(driveId)][ , .(fg=.N), .(endPos,startPos)]    
		#fg.td[,endPos:=0L]
    
    setkey(lfg.td, endPos, startPos,fg)
		fg.over = foverlaps(x=idx,y=lfg.td, by.y=c("endPos","startPos"), by.x=c("start","end"))
		fg.sum = fg.over[, .(fg=sum(fg)), .(start)]
    
		empty.td <- DT2[driveScore == 0L,.(startPos = max(ydline,na.rm=TRUE), endPos=min(ydline,na.rm=TRUE)), .(driveId)][ , .(empty=.N), .(endPos,startPos)]    
		setkey(empty.td,endPos,startPos,empty)
		empty.over = foverlaps(x=idx,y=empty.td, by.y=c("endPos","startPos"), by.x=c("start","end"))
		empty.sum = empty.over[, .(empty=sum(empty)), .(start)]
    
		cum.together.td <- td.sum[fg.sum[empty.sum]]
		
		# expected point return for a given spot on the field
		cum.td = cum.together.td[, .(expScoreCumm = (7*td + 3*fg)/(td + fg + empty), Ncumm = (td + fg + empty) ), .(start)]
		
		cum.td[, startPos := start]
		setkey(cum.td, startPos)
		setkey(start.td, startPos)
    start.td[cum.td]
}

getGainDistro <- function(DT){
  gainDistro = DT[!is.na(yardsGained) & noplay == "play" & (playType %in% c("run","pass","sack")) & penaltyStatus == "none"
                  & turnoverEvent == "none",
                       .(yardsGained = as.integer(yardsGained)), .(ydline,playType)][order(ydline)]
  gainDistro
  
}

getAveYardsOnPlayCumm <- function(dt=fread(dataFile),dcastResult=FALSE){
  DT2 <- dt
  DTdrive <- DT2[!is.na(DT2$driveScore),]
  #DTdrive[!is.na(yardsGained) & noplay == "play" & (playType %in% c("run", "pass" ,"sack")),.(median(as.integer(yardsGained))), .(ydline)][order(ydline)]
  gainDistro = getGainDistro(DTdrive)
  if (dcastResult == TRUE){
    dcast(gainDistro[ , .(prGain = sapply(1:ydline,function(x){sum(yardsGained >= x)/.N}),yards = 1:ydline), .(ydline)],
          ydline ~ yards ,value.var="prGain")
    
  } else {
    gainDistro[ , .(prGain = sapply(1:ydline,function(x){sum(yardsGained >= x)/.N}),yards = 1:ydline, N=.N), .(ydline)]
    
  }
  
}
getAveYardsOnPlay <- function(dt=fread(dataFile),dcastResult=FALSE){
  DT2 <- dt
  DTdrive <- DT2[!is.na(DT2$driveScore),]
  #DTdrive[!is.na(yardsGained) & noplay == "play" & (playType %in% c("run", "pass" ,"sack")),.(median(as.integer(yardsGained))), .(ydline)][order(ydline)]
  gainDistro = getGainDistro(DTdrive)
  if (dcastResult == TRUE){
    dcast(gainDistro[ , .(prGain = sapply(1:ydline,function(x){sum(yardsGained == x)/.N}),yards = 1:ydline), .(ydline)],
          ydline ~ yards ,value.var="prGain")
    
  } else {
    gainDistro[ , .(prGain = sapply(-5:ydline,function(x){sum(yardsGained == x)/.N}),yards = -5:ydline, N=.N), .(ydline)]
    
  }
  
}

getNoGainTdByYdline <- function(DTdrive){
  gainDistro = getGainDistro(DTdrive)
  gainDistro[, .(noGain = sum(yardsGained < 0), touchDown = sum(yardsGained == ydline), N = .N,playType), .(ydline,playType)]
}

getStatsOverPlayType <- function(DTdrive){
  gainDistro = getGainDistro(DTdrive)
  #gainDistro = DTdrive[!is.na(yardsGained) & yardsGained > 0 & noplay == "play" & (playType %in% c("run","pass","sack")),.(yardsGained = as.integer(yardsGained)), .(ydline,playType)][order(ydline)]
  
  melt(gainDistro[, .(mean= mean(yardsGained), sd=sd(yardsGained)), .(ydline,playType)],id.vars=c("ydline","playType"))
  
  
}


getPuntYards <- function(dt){
  DT = fread(dataFile)
  punt = DT[, .("punt" == playType[.N],yardsGained[.N]), driveId][V1 == TRUE, driveId]
  
  DTpunt     <- DT[driveId %in% c(punt)]
  #DTpuntPlay <- DTpunt[, .(puntPT=playType[.N],puntYD= ydline[.N],puntOFF=off[.N],puntNOPLAY=noplay[.N]),.(driveId)]
  DTpuntPlay <- DTpunt[noplay == "play", .(puntPT=playType[.N],puntYD= ydline[.N],puntOFF=off[.N],puntNOPLAY=noplay[.N]),.(driveId)]
  
  setkey(DTpuntPlay, driveId)
  DTpuntNext <- DT[driveId %in% c(punt+1),]
  #
  DTpuntNextPlay <- DTpuntNext[, .(lastDriveId = driveId[1] - 1, nextPT = playType[1],nextYD= (100 - ydline[1]),playDEF=def[1],playNOPLAY=noplay[1]),.(driveId)]
  setkey(DTpuntNextPlay, lastDriveId)
  
  joinPlays <- DTpuntPlay[DTpuntNextPlay][puntNOPLAY == "play" ,.(count=.N), .(puntYD, nextYD)][order(puntYD)]
  joinPlaysMean <-  DTpuntPlay[DTpuntNextPlay][puntNOPLAY == "play" ,.(mean(nextYD),.N), .(puntYD)][order(puntYD)]
  joinPlays
  }


getFGpercent <- function(){
    DT = fread(dataFile)
    fgGood = DT[noplay=="play", .("good" == fgStatus[which(playType == "field goal")]),by=.(driveId)][V1 == TRUE, driveId]
    fgBad = DT[noplay=="play", .(fgStatus[which(playType == "field goal")] %in% c("nogood","block")),by=.(driveId)][V1 == TRUE, driveId]
    DTfg = DT[noplay=="play" & playType == "field goal"]
}

goForItAlgoithm <- function(){
  # for a given 4 down situation(togo & yardline)
    # a = the probability of converting * expected points                          #
    # b = the probability of failing to convert * opents expected points           # 
    # the expected opp points after punting
  
  
  
  
}



