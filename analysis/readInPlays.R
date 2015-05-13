#!/usr/bin/R

library(data.table)

dataFile <<- "/home/adam/data/nfl/2002-2011_nfl_play_type_plus.csv"

annotateDrive <- function(infile=dataFile){
		DT = fread(dataFile)
    DT2 <- DT[year == 2010]
		DT2[driveId == 78131]

    fgGood = DT2[noplay=="play", .("good" == fgStatus[which(playType == "field goal")]),by=.(driveId)][V1 == TRUE, driveId]
    fgBad = DT2[noplay=="play", .(fgStatus[which(playType == "field goal")] %in% c("nogood","block")),by=.(driveId)][V1 == TRUE, driveId]
    punt = DT2[, .("punt" == playType[.N],yardsGained[.N]), driveId][V1 == TRUE, driveId]
		td = DT2[penaltyStatus != "enforeced" && noplay == "play", .(any(which(playType == "pass" | playType == "run") %in% which(yardsGained == ydline))), driveId][V1 == TRUE,driveId]
		turnover = DT2[noplay == "play", .( (playType[.N] %in% c("run","pass","sack","fumble")) && (turnoverEvent[.N]  %in% c("fumble","interception"))), driveId][V1 == TRUE, driveId]
    turnoverOnDowns = DT2[noplay == "play", .(down[.N] == 4 && (yardsGained[.N] < togo[.N])), driveId][V1==TRUE, driveId]
    safety = DT2[, .(any("safety" %in% turnoverEvent)), driveId][V1 == TRUE, driveId]
    #kickoff = DT2[!(driveId %in% c(fgGood, fgBad, punt, td,turnover)), .(playType[1],driveId = driveId[1]),.(gameid,qtr %in% c(1,3))][qtr == TRUE,driveId]
		#kickoff2 <- DT2[noplay == "play", .(.N == 1 && playType[.N] == "kickoff"), .(driveId)][V1==TRUE, driveId]
		kickoff <- DT2[, .(.N == 1 && playType[.N] == "kickoff"), .(driveId)][V1 == TRUE,driveId]
		kneel <- DT2[, .(playType[.N] == "kneel"), .(driveId)][V1 == TRUE, driveId]
    lastDriveOfHalf <- DT2[noplay == "play", .(driveId[.N]), .(gameid,qtr)][qtr %in% c(2,4)][,V1]
		endOfHalf <- DT2[driveId %in% lastDriveOfHalf & !(playType == "kickoff" & min == 30 & qtr == 3), .(ydline = ydline[.N],yardsGained = yardsGained[.N],playType = playType[.N],min = min[.N],sec = sec[.N] ), .(driveId)][, .(playType == "kneel" || ((playType %in% c("pass", "run", "sack")) && ydline > yardsGained)),.(driveId)][V1 == TRUE,driveId]
    
    DT2[!(driveId %in% c(fgGood, fgBad, punt, td,turnover,turnoverOnDowns,safety,kickoff,endOfHalf,kneel)), .(driveId, playType, yardsGained, turnoverEvent )][1:100]
    
    