library(ggplot2)

source("./analysis/readInPlays.R")

# yards per play
prepDataTable <- function(){
  DT <- annotateDrives()
  DTdrive <- DT[! is.na(driveScore)]
  DTdrive
  #DTdrivePlays <- DTdrive[playType %in% c("pass", "run", "sack")]
  #DTdrivePlays
}
  
# -> ./plots/basicStats
# all the basic plots, 
# yards gained at position
# punting, probability of outcomes, etc
plotBasicYardage <- function(){
  DTdrive <- prepDataTable()
  DTdrivePlays <- DTdrive[playType %in% c("pass", "run", "sack")]
   ggplot(DTdrivePlays, aes(x=yardsGained)) + geom_histogram(binwidth=1) + 
    facet_grid(playType ~ ., scale="free_y") + 
    theme_bw() + 
    xlim(-20, 100) +
    ggtitle("Yards Gained(2002-2011)\nall plays,teams in classified drived\nplaytype is run,pass,sack")
  ggsave("./plots/basicStats/yardsPerPlay.pdf")
  
  DTpunt <- DTdrive[playType == "punt"]
  #ggplot(DTpunt[,sapply(1:100) , ydline], aes(y=ydline, x = ydline - yardsGained)) + geom_bin2d() + 
  DTpuntNorm <- DTpunt[, .(count=.N), .(ydline,yardsGained)][, .(normCount = count/.N,yardsGained=yardsGained), .(ydline)]
 punt <- getPuntYards()
 puntNorm <- punt[, .(normCount=count/.N,nextYD), .(puntYD)]
 
   ggplot(puntNorm,  
         aes(y=puntYD, x = nextYD, fill=normCount)) + geom_tile() + 
    xlim(100,1) +
    ylim(100,1) + 
    theme_bw() + 
    ylab("kicking team position")+
    xlab("recieving team position(after punt)")+
    scale_fill_gradient2(low="white", mid="green", high="black") + 
    geom_vline(xintercept=20, color="lightgrey") +
    ggtitle("punt team position vs. recover team position \n at end of play")
   ggsave("./plots/basicStats/puntYards.pdf")
   
   
   DTfg <- getFGpercent()
   ggplot(DTfg[, .(good = (fgStatus == "good"), ydline)], aes(ydline,fill=good)) + 
     geom_histogram(binwidth=1,position="fill") + 
     theme_bw() +
     xlim(51,1) +
     ggtitle("field goal outcome by field position\n(@ snap, not at kick)")+
     xlab("field position @ snap")
   ggsave("./plots/basicStats/fieldGoalOutcome.png")
   

   yardDistroCumm <- getAveYardsOnPlayCumm(dt=DTdrivePlays,dcastResult = FALSE)
   ggplot(yardDistroCumm, aes(x=ydline, y=yards, fill=prGain))+geom_tile() + 
     scale_fill_gradient2(low="white", mid="black",high="green")+ 
     xlim(99,1) + 
     theme_bw() +
     ggtitle("pr of getting at least y yards\nat given field position") + 
     xlab("field position")
   ggsave("./plots/basicStats/prGainAtYdline.png")

   playStats = getStatsOverPlayType(DTdrive)
   ggplot(playStats, aes(x=ydline, y=value, color=variable))+geom_point()+
     facet_grid(playType ~ ., scale="free_y") + 
     xlim(99,1) + 
     theme_bw() +
     xlab("field position")+
     ggtitle("mean/sd for run/pass/sack\nat each ydline")
   ggsave("./plots/basicStats/gainStatsOverYdline.png")
     
 
   gainTd <- getNoGainTdByYdline(DTdrive)[, .(posYards = N - noGain - touchDown, touchDown, noGain, ydline,playType)]
   gainTdTmp <- gainTd
   gainTdTmp <- gainTdTmp[, .(posYards=sum(posYards), touchDown=sum(touchDown), noGain=sum(noGain)), ydline]
   gainTdTmp$playType = "all"
   gainTdAll <- rbind(gainTd,gainTdTmp )
    ggplot(melt(gainTdAll,id.vars= c("ydline","playType")), aes(x=ydline,y=value,fill=variable)) + 
     geom_histogram(stat="identity", binwidth=1) + 
     xlim(99,1) + 
     theme_bw() + 
     xlab("field position") + 
     facet_grid(playType ~ ., scale="free_y") +
     ggtitle("number of run/pass/sack plays \n at field position")
   ggsave("./plots/basicStats/playResultFromYdline.png")
   
   ggplot(melt(gainTdAll,id.vars= c("ydline","playType")), aes(x=ydline,y=value,fill=variable)) + 
     geom_histogram(stat="identity", position="fill",binwidth=1) + 
     xlim(99,1) + 
     theme_bw() + 
     xlab("field position") + 
     facet_grid(playType ~ ., scale="free_y") +
     ggtitle("number of run/pass/sack plays \n at field position")
   ggsave("./plots/basicStats/playResultFromYdline_fill.png")
   
   
   expScore = getExpectedPointsForPosition(dt = DTdrive)
   ggplot(expScore, aes(x=start, y=expScoreCumm)) + geom_bar(binwidth=1,stat="identity")+
     xlab("field position") + ylab("Expected Points") + 
     theme_bw() + xlim(99,1) + 
     ggtitle("expected score @ off field position") 
   ggsave("./plots/basicStats/expScore_cumm.png")
     
}



# pr score
# punt distribution
# expected point per field position
# yards per field position(all plays)

