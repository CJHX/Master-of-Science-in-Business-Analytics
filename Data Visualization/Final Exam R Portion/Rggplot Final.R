library(gapminder)
library(ggplot2)
library(ggthemes)

Source <- gapminder
Source$Continent <- Source$continent
Source$Population <- Source$pop

ggplot(Source, aes(log(gdpPercap), lifeExp, color=Continent, size=Population)) + ggtitle("Carl Xi - Economic Development and Life Expectancy around the World") +
  geom_point() + theme_few() + facet_wrap(year, 3,4) + scale_color_manual(name = "continent", values = c("#7A1501", "#CF7019", "#7B7000", "#8BAEA2", "#002742"))+
  geom_point(alpha=0.5) +ylab("Life Expectancy(years)") + xlab("log(GDP per Capita)") +labs(subtitle = "This proves that I know how to place a subtitle.")
