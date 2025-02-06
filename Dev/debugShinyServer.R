library(stringr)

r <- system('ls /datasets/work/sc-shiny/work/scratch/app_logs/*/dbTest* -lrt | tail -1', intern = T)
r


r <- system('ls /datasets/work/sc-shiny/work/scratch/app_logs/*/Soil* -lrt | tail -1', intern = T)
r

bits <- str_split(r, ' ')
nlines <- length(bits[[1]])
readr::read_lines(bits[[1]][nlines])

