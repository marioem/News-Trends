# Create Your Own R News Trends Feature
# from:
# https://www.datacamp.com/community/tutorials/recreate-bloomberg-terminal-news-trends-r
#
# Updated for gtrendsR v. 1.4.1

# Import quantmod
library(quantmod)

# Import gridExtra
library(gridExtra)

# Import grid
library(grid)

# Import ggplot2
library(ggplot2)

# Import ggthemes
library(ggthemes)

# Import gtrendsR
library(gtrendsR)


# Query Google Trends
poke <- gtrends('Pokemon Go', gprop = "news")

# out of curiosity
eric <- gtrends('Ericsson', gprop = "news")
pol <- gtrends('Poland', gprop = "news")
ipn <- gtrends('IPN', gprop = "news")

# Plot the query results
plot(poke)
plot(eric)
plot(pol)
plot(ipn)

# Specify which stock data to download and from where
setSymbolLookup(YJ7974.T='yahooj')

# Load YJ7974.T from Yahoo Japan
getSymbols('YJ7974.T')

# Plot the Yahoo data
plot(YJ7974.T)

# Subset the time series
nintendo.xts <- YJ7974.T['2016-01/2018-01']

# Get the weekly average of the time series
nintendo.xts <- apply.weekly(nintendo.xts, mean)

plot(nintendo.xts) # Lots of data, take a lot of time

# Take a look at the trends
str(poke$interest_over_time)

# Extract the weekly Pokémon trends
poke.df<-poke$interest_over_time

# Now we need to sync poke and stock data
poke.df <- poke.df[as.Date(poke.df$date) > as.Date("2016-01-08"),]

poorman.nt<-data.frame(nintendo.close=nintendo.xts$YJ7974.T.Close,
                       poke.trends=poke.df$hits,
                       week.2016=seq(1:nrow(nintendo.xts)))

poorman.nt$poke.trends <- as.integer(poorman.nt$poke.trends)
names(poorman.nt)[1] <- "nintendo.close"

cor(poorman.nt$nintendo.close,
    poorman.nt$poke.trends) 

nintendo.price<-ggplot(poorman.nt, aes(x=week.2016, y=nintendo.close,group = 1)) + geom_line(color='darkred', size=1)+ theme_gdocs() + 
  theme(legend.position="none",
        axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank()) +
  ggtitle("Nintendo Stock Price")
nintendo.price

pokemon.trend<-ggplot(poorman.nt, aes(x=week.2016, y=poke.trends,group = 1)) + geom_line(color='darkblue', size=1)+ theme_gdocs() + 
  theme(legend.position="none",
        axis.title.y=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank()) +
  ggtitle("Pokemon GO News Trends")
pokemon.trend

grid.arrange(nintendo.price, pokemon.trend) 
