
# Et si j'utilisais Shiny pour rendre ca tres stylé ? https://shiny.rstudio.com/



##### NOTES
# 0.3 a minuit a l'air d'etre ok pour dormir
# preferer utiliser la version en python


step <- 0.1 # time subdivision
x <- seq(0,24,step) # time 

cp <- 10 # mg inside a pill
dose <- cp*0.4 # bioabailability=0.4 source : https://escholarship.org/uc/item/9gv7p39v
half_life <- 2.5 # en heure source : https://escholarship.org/uc/item/9gv7p39v

# time at which the dose is taken
hour_taken <- c(8,9,11)
#      ajoute 1h30 si a jeun ou 1h si pendant le repas ; source : https://escholarship.org/uc/item/9gv7p39v
total_amount <- length(hour_taken)*cp



#curve_template <- dose*exp(-(log(2)/half_life*(x)))
curve_template <- dose*(-exp(-log(2)/0.4*x)+exp(-(log(2)/half_life*x)))
# why /0.4 ? found empirically while tinkering with the curve to comeup within 1h13 (about the average between 1h (during meal) and 1h30 (on empty stomach))
y <- rep(0,length(x))
for(i in seq(1,length(hour_taken))) {
  y <- y+ c(rep(0,hour_taken[i]*(1/step)-1),curve_template)[1:length(x)]
}



########## plot
starting_hour_plot <- 7
max_y_plot <- 8
plot(seq(starting_hour_plot,max(x),step),y[seq(starting_hour_plot,max(x),step)*10],
     # xlab=("Time over the day (hour)"),ylab="Amount of MPH (arbitrary unit)",
     type="l",ylim=c(0,max_y_plot),xaxt='n',yaxt='n',density=25)
#plot details
plot_title=paste(c("Methylphenidate Pharmacokinetic Simulator\n(", total_amount, "mg in ",length(hour_taken), " pills)"),collapse='')
title(plot_title)
abline(h=c(y[length(y)],max(y)),col=3,lty=2)
#mtext(text = paste("t1/2=", half_life, "h ; AUC=",round(trapz(x,y),1)),side=1)
legend("topright",legend=c("Now"),col=c("purple"),lty=1:2, cex=0.8)
abline(v=hour_taken,lty=2,col="red")
#axis
#axis(1,at=c(starting_hour_plot,hour_taken,24)) #horizontal
axis(1,at=seq(starting_hour_plot,24,1))
axis(2,las=1) # left
axis(4,at=round(c(y[hour_taken*1/step],y[length(y)]),2),las=1) # right, duplicated to make reading easier

#display time
hour <- as.numeric(format(Sys.time(), "%H"))
minute <- as.numeric(format(Sys.time(), "%M"))/60
time <- hour+minute
arrows(time,y[time*1/step]+3,time,y[time*1/step]+1,col="purple",lty=5)
#arrows(time,-1.01,time,y[time*1/step]-1,col="purple",lty=5) # fleche du haut
axis(1,at=round(time,2),col="purple") ; axis(4,at=round(y[time*1/step],2),las=1,col="purple") # unit at current time

#display polygons
#red before waking up
xx <- c(starting_hour_plot-1,hour_taken[1],hour_taken[1],starting_hour_plot-1)
yy <- c(-2,-2,11,11)
polygon(xx,yy,density=10,col="grey")
#grey when under a certain threshold for sleep
sleep_threshold <- 0.4
last_time_focused <- (length(y) - which(rev(y)>sleep_threshold)[1])*step
ltf <- last_time_focused
xx <- c(ltf, 26, 26, ltf)
yy <- c(-2,-2,11,11)
polygon(xx,yy,density=10,col="grey")
#under the curve
#xx <- c(seq(hour_taken[1],ltf,0.1),ltf,hour_taken[1])
#yy <- c(y[seq(hour_taken[1],ltf,0.1)/step],y[ltf],0)
#polygon(xx,yy,density=50,col="blue")
