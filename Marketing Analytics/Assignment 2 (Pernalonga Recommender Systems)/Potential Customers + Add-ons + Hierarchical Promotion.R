# Part 1: Use IBCF to identify potential customers of Nestle Cholate products
library(readr)
transaction_table <- read_csv("transaction_table.csv")
product_table <- read_csv("product_table.csv")

library(dplyr)
# find products under chocolate category
chocolate <- filter(product_table, grepl('CHOCOLATE',category_desc_eng))
# find Nestle chocolate products
nestle <- product_table %>% filter(brand_desc == "NESTLE" & grepl('CHOCOLATE',category_desc_eng))

# find customers who bought chocolate products, the number of transactions and paid amount
customer_buy_chocolate <- transaction_table %>% filter(prod_id %in% chocolate$prod_id) %>% group_by(cust_id) %>% summarise(transaction_tp = n() , amount_tp = sum(tran_prod_paid_amt))

# find customers who bought Nestle chocolates, the number of transactions and paid amount
customer_buy_nestle <- transaction_table %>% filter(prod_id %in% nestle$prod_id) %>% group_by(cust_id) %>% summarise(transaction_col = n(), amount_col = sum(tran_prod_paid_amt))

# join the two tables together
customer_purchase <- customer_buy_chocolate %>% left_join(customer_buy_nestle,by="cust_id")

write.csv(customer_purchase, file = "customer_purchase.csv", row.names = FALSE, col.names = FALSE)

# find discount rate of each transaction
customer_buy_stat <- transaction_table %>% filter(prod_id %in% chocolate$prod_id) %>% mutate(disc_rate = abs(tran_prod_discount_amt/tran_prod_sale_amt))

# find the average discount rate a customer used for Nestle chocolate products
customer_buy_stat_nestle <- customer_buy_stat %>% filter(prod_id %in% nestle$prod_id) %>% group_by(cust_id) %>% summarise(avg_disc_rate_col = mean(disc_rate))
# find the average discount rate a customer used for other chocolate products
customer_buy_stat_other <- customer_buy_stat %>% filter(!prod_id %in% nestle$prod_id) %>% group_by(cust_id) %>% summarise(avg_disc_rate_other = mean(disc_rate))

# join tables together and write out
customer_buy_stat <- customer_buy_stat_other %>% full_join(customer_buy_stat_col,by="cust_id")
customer_buy <- customer_purchase %>% full_join(customer_buy_stat,by="cust_id")
write.csv(customer_buy, file = "customer_buy.csv", row.names = FALSE, col.names = FALSE)



# find people who didn't buy Nestle chocolate products but will probably like Nestle chocolate products by using collaborative filtering
# find the amount a customer paid for a product
library(tidyr)
#graph_table <- transaction_table %>% select(cust_id,prod_id) %>% group_by(cust_id,prod_id) %>% summarise(weight = n())
graph_table <- transaction_table %>% select(cust_id,prod_id,tran_prod_paid_amt) %>% group_by(cust_id,prod_id) %>% summarise(weight = sum(tran_prod_paid_amt)) %>% filter(weight > 0)
# check the distribution and use logarithm to adjust skewed product revenue
library(ggplot2)
qplot(graph_table$weight, geom="histogram",xlab = "Paid amount",ylab = "Count")
graph_table$weight <- log(graph_table$weight)
qplot(graph_table$weight, geom="histogram",xlab = "Logarithm # of paid amount",ylab = "Count")
# use min-max to standardize the weight column
rescale.fun <- function(x){(x-min(x))/diff(range(x))}
graph_table$weight <- rescale.fun(graph_table$weight)
hist(graph_table$weight)
summary(graph_table$weight) # 0.4836 is the median, use 0.4836 as a cutoff of 'good rating' in model

# make table into affiliation matrix
matrix <- spread(graph_table,prod_id, weight)
member_matrix <- matrix[, -1]
member_matrix <- as.data.frame(member_matrix)
rownames(member_matrix) <- matrix$cust_id
library(recommenderlab)
ratings <- as(t(as.matrix(member_matrix)),"realRatingMatrix")

# build recommender systems based on collaborative filtering, use different similarity distances and find the best model
e <- evaluationScheme(ratings, method="split", train=0.8, given = -1, goodRating=0.4836)

r1.jaccard <- Recommender(getData(e, "train"), method = "UBCF", param = list(method = "Jaccard"))
r1.cosine <- Recommender(getData(e, "train"), method = "UBCF", param = list(method = "cosine"))
r1.pearson <- Recommender(getData(e, "train"), method = "UBCF", param = list(method = "Pearson")) # this library takes rows as customers and columns as products as default, but since we transposed the matrix, our matrix had products as rows and customers as columns. Thus the "UBCF" here actually is "IBCF". We were using item-based collaborative filtering

p1 <- predict(r1.jaccard, getData(e, "known"), type="ratings")
p2 <- predict(r1.cosine, getData(e, "known"), type="ratings")
p3 <- predict(r1.pearson, getData(e, "known"), type="ratings")

error <- rbind(IBCF.jaccard = calcPredictionAccuracy(p1, getData(e, "unknown")),
               IBCF.cosine = calcPredictionAccuracy(p2, getData(e, "unknown")),
               IBCF.pearson = calcPredictionAccuracy(p3, getData(e, "unknown")))
error # based on the error, pearson similarity based model is the best one

# find how many customers would like which Nestle products
cust_id_rec <- c()
ratingtable <- data.frame()
for (i in nestle$prod_id) {
  i <- as.character(i)
  recom <- predict(r1.pearson, ratings[i,], type="ratings")
  ratingmatrix <- t(as(recom, "matrix"))
  ratingdf <- as.data.frame(ratingmatrix)
  ratingdf$custid <- rownames(ratingdf)
  ratingdf <- na.omit(ratingdf)
  ratingdf$prod_id <- i
  colnames(ratingdf) <- c('rating','cust_id','prod_id')
  ratingtable <- rbind.data.frame(ratingtable, ratingdf)
  cust_rec <- ratingdf[ratingdf[,1] >= 0.4836,2]
  cust_id_rec <- c(cust_id_rec,cust_rec)
}

recommend <- ratingtable %>% filter(rating >= 0.50)

cust_id <- as.data.frame(unique(recommend$cust_id))
write.csv(cust_id, file = "potential_cust.csv",row.names = FALSE)
table(recommend$prod_id)




# Part 2: Use association rules model to identify customers who bought Nestle chocolates as add-ons
# create new transaction ID with tran_id + cust_id + store_id
transaction_table$tran_id <- as.character(transaction_table$tran_id)
transaction_table$new_tran_id <- substring(transaction_table$tran_id,1,8)
transaction_table$new_tran_id <- paste(transaction_table$new_tran_id,as.character(transaction_table$cust_id),sep="")
transaction_table$new_tran_id <- paste(transaction_table$new_tran_id,as.character(transaction_table$store_id),sep="")
# select new transaction id and product id
try <- transaction_table %>% select(new_tran_id, prod_id)
# find unique pairs
bags <- product_table %>% filter(category_desc_eng == 'BAGS') %>% select(prod_id)
try <- unique(try)
try <- try %>% filter(!prod_id %in% bags$prod_id)
# execute association rule
library(arules)
library(arulesViz)
ar <- as(split(try$prod_id, try$new_tran_id), "transactions")
nestle_rules <- apriori(data=ar, parameter=list (supp=0.0015,conf = 0.003), appearance = list (rhs=nestle$prod_id)) # use nestle product id as right hand side, which suggests
summary(nestle_rules) # got 10 association rules
inspect(nestle_rules)



# Part 3 : Use Venn Diagram to identify overlaps of different customer groups and develop promoting strategies
# draw Venn diagram
# combine customer id from 4 groups
cust_id$type <- 'potential customer'
colnames(cust_id) <- c('cust_id','type')
cust_id$cust_id <- as.integer(as.character(cust_id$cust_id))
Cherry_pickers <- read_csv("Cherry_pickers.csv", col_types = cols(X1 = col_skip()))
Cherry_pickers$type <- 'cherry pickers'
colnames(Cherry_pickers) <- c('cust_id','type')
Cherry_pickers$cust_id <- as.integer(Cherry_pickers$cust_id)
nestle_lover_id <- read_csv("nestle_fans.csv", col_types = cols(X1 = col_skip()))
nestle_lover_id$type <- 'Nestle-lovers'
colnames(nestle_lover_id) <- c('cust_id','type')
nestle_lover_id$cust_id <- as.integer(nestle_lover_id$cust_id)
other_lover_id <- read_csv("competitor_fans.csv", col_types = cols(X1 = col_skip()))
other_lover_id$type <- 'fans of competitors'
colnames(other_lover_id) <- c('cust_id','type')
other_lover_id$cust_id <- as.integer(other_lover_id$cust_id)
# draw the diagram
library(VennDiagram)
venn.diagram(
  x = list(Cherry_pickers$cust_id, other_lover_id$cust_id, nestle_lover_id$cust_id, cust_id$cust_id),
  category.names = c('cherry-pickers','fans of competitors','Nestle-lovers',"potential customers"),filename = 'venn_diagram.png',
  output = TRUE ,
  imagetype="png" ,
  height = 850 ,
  width = 850 ,
  resolution = 300,
  compression = "lzw",
  lwd = 2,
  lty = 'blank',
  fill = c('red', 'orange', 'green','blue'),cex = 0.3,
  fontface = "bold",
  fontfamily = "sans",cat.cex = 0.3,
  cat.fontface = "bold",
  cat.fontfamily = "sans",
  cat.default.pos = "outer")
