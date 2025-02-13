library(stringr)


#######  Make a link to new app for getting around caching

#cd /datasets/work/sc-shiny/work/live_apps/RossSearle/SoilDataEntry/
#ln -s SoilDataEntry app3



# r <- system('ls /datasets/work/sc-shiny/work/scratch/app_logs/*/dbTest* -lrt | tail -1', intern = T)
# r
#r <- system('ls /datasets/work/sc-shiny/work/scratch/app_logs/*/app3* -lrt | tail -1', intern = T)

r <- system('ls /datasets/work/sc-shiny/work/scratch/app_logs/*/app2* -lrt | tail -1', intern = T)


r <- system('ls /datasets/work/sc-shiny/work/scratch/app_logs/*/SoilData* -lrt | tail -1', intern = T)
r

bits <- str_split(r, ' ')
nlines <- length(bits[[1]])
lines <- readr::read_lines(bits[[1]][nlines])
r
tail(lines, 10)
