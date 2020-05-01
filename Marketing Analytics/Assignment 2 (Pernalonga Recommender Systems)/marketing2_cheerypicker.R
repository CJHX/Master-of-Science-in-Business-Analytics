# Generate customer table -- from last project --------------------------------------------------------


library(data.table)
library(ggplot2)
library(cluster)
library(factoextra)
library(dplyr)
product <- fread('e:/Downloads/Marketing/product_table.csv') # original product table
transaction <- fread('e:/Downloads/Marketing/transaction_table.csv') # original transaction table

# check missing value
str(transaction)
sapply(transaction,function(x) sum(is.na(x)))
sapply(product,function(x) sum(is.na(x)))
#hist(transaction[,sum(tran_prod_sale_amt),cust_id][,.(V1)])

# create new transaction id
transaction[,ti:=paste(tran_dt,store_id,cust_id)]

# Merge transaction data and product data
data <- merge(transaction,product,by = 'prod_id') 
#There are 500 transaction with products not inluded in product data

# create a binary variable to see which row is about discounted item
data[,onsale:=1]
data[tran_prod_sale_amt==tran_prod_paid_amt,onsale:=0]

colnames(data)


# generate the corresponding customer table with defined attributes
l <- data[,.(total_revenue=sum(tran_prod_paid_amt), # total revenue
             total_transaction=length(unique(ti)), # total number of transaction
             t_d_product=length(unique(prod_id)), # total number of distinct product purchased
             t_d_store=length(unique(store_id)), # total number of distinct stores visited 
             t_d_category=length(unique(category_id)), # total number of distinct categories purchased
             t_d_brand=length(unique(brand_desc)), # total number of distinct brands purchased
             p_o_discount_purchase=sum(onsale)/.N, # percentage of productes purchased on sale
             avg_discount_rate=-sum(tran_prod_discount_amt)/sum(tran_prod_sale_amt)),
          cust_id] # the sales amount on sale over total sales amount 

# Generate Production Table -- from last project -------------------------------

# Products descriptive analysis 
## products with the best volumes (count and KG are separated)
prod_vol_count <- transaction %>% group_by(prod_id, prod_unit) %>% summarise(total_vol = sum(tran_prod_sale_qty)) %>% arrange(desc(total_vol)) %>% filter(prod_unit == "CT")
prod_vol_KG <- transaction %>% group_by(prod_id, prod_unit) %>% summarise(total_vol = sum(tran_prod_sale_qty)) %>% arrange(desc(total_vol)) %>% filter(prod_unit == "KG")
intersect(prod_vol_count$prod_id,prod_vol_KG$prod_id)

## products with the best revenues
prod_rev <- transaction %>% group_by(prod_id) %>% summarise(total_rev = sum(tran_prod_paid_amt)) %>% arrange(desc(total_rev))
## products with the most customers
prod_cust <- transaction %>% group_by(prod_id) %>% summarise(total_cust = n_distinct(cust_id)) %>% arrange(desc(total_cust))
## products with the most stores
prod_cust <- transaction %>% group_by(store_id) %>% summarise(total_store = n_distinct(store_id)) %>% arrange(desc(total_store))
## products with the most transactions
prod_rev <- data %>% group_by(ti) %>% summarise(total_trans = n()) %>% arrange(desc(total_trans))


## subcategories with the best volumes (count and KG are separated)
subcategory_vol_count <- data %>% group_by(subcategory_id, prod_unit) %>% summarise(total_vol = sum(tran_prod_sale_qty)) %>% arrange(desc(total_vol)) %>% filter(prod_unit == "CT")
subcategory_vol_KG <- data %>% group_by(subcategory_id, prod_unit) %>% summarise(total_vol = sum(tran_prod_sale_qty)) %>% arrange(desc(total_vol)) %>% filter(prod_unit == "KG")
## subcategories with the best revenues
subcategory_rev <- data %>% group_by(subcategory_id) %>% summarise(total_rev = sum(tran_prod_paid_amt)) %>% arrange(desc(total_rev))
## subcategories with the best customers
subcategory_cust <- data %>% group_by(subcategory_id) %>% summarise(total_cust = n_distinct(cust_id)) %>% arrange(desc(total_cust))

## categories with the best volumes (count and KG are separated)
category_vol_count <- data %>% group_by(category_id, prod_unit) %>% summarise(total_vol = sum(tran_prod_sale_qty)) %>% arrange(desc(total_vol)) %>% filter(prod_unit == "CT")
category_vol_KG <- data %>% group_by(category_id, prod_unit) %>% summarise(total_vol = sum(tran_prod_sale_qty)) %>% arrange(desc(total_vol)) %>% filter(prod_unit == "KG")
## categories with the best revenues
category_rev <- data %>% group_by(category_id) %>% summarise(total_rev = sum(tran_prod_paid_amt)) %>% arrange(desc(total_rev))
## categories with the best customers
category_cust <- data %>% group_by(category_id) %>% summarise(total_cust = n_distinct(cust_id)) %>% arrange(desc(total_cust))

# Product clustering 
## create key attributes for product clustering
product_statistics <- data %>% group_by(prod_id) %>% summarise(total_revenue = sum(tran_prod_paid_amt), total_transact=n_distinct(ti), total_distinct_customer = n_distinct(cust_id), total_stores = n_distinct(store_id), avg_discount_rate = (abs(sum(tran_prod_discount_amt))/sum(tran_prod_sale_amt)))
discounted_product_cnt <- data %>% filter(tran_prod_discount_amt < 0) %>% group_by(prod_id) %>% summarise(discounted_tran_cnt=n_distinct(tran_id))

#the final product table. 
product_statistics <- inner_join(discounted_product_cnt,product_statistics, by="prod_id") %>% mutate(percentage_discount_product = discounted_tran_cnt/total_transact)

# remove unuseful data for clear view. 
rm(transaction)
rm(category_cust)
rm(category_rev)
rm(category_vol_count)
rm(category_vol_KG)
rm(subcategory_cust)
rm(subcategory_rev)
rm(subcategory_vol_count)
rm(subcategory_vol_KG)
rm(prod_cust)
rm(prod_rev)
rm(prod_vol_count)
rm(prod_vol_KG)
rm(discounted_product_cnt)


# Find chocolate cherry pickers  --------------------------------------------------------------------

# find the total amount of transactions including chocolate for each customer
cl_amt <- data %>% group_by(cust_id) %>% filter(category_desc_eng=="CHOCOLATE") %>% summarise((cl_amt = length(ti)))
# find the total amount of transactions including Nestle Chocolate for each customer
Nestle_amt <- data %>% group_by(cust_id) %>% filter(category_desc_eng=="CHOCOLATE" & brand_desc =="NESTLE") %>% summarise((cl_amt = length(ti)))
colnames(cl_amt) <- c("cust_id","cl_amt")
colnames(Nestle_amt) <- c("cust_id","Nestle_amt")
# merge aboving two attributes into the customer table 
l <- merge(cl_amt,l,all.y =T)
l <- merge(Nestle_amt,l,all.y=T)
sapply(l,function(x) sum(is.na(x)))
l[is.na(l)] <- 0

# find the total value of transactions including CHOCOLATE for each customer
cl_value <- data %>% group_by(cust_id) %>% filter(category_desc_eng=="CHOCOLATE") %>% summarise(cl_value=sum(tran_prod_paid_amt))
# find the total value of transactions including Nestle CHOCOLATE for each customer
Nestle_value <- data %>% group_by(cust_id) %>% filter(category_desc_eng=="CHOCOLATE" & brand_desc =="NESTLE") %>% summarise(Nestle_value=sum(tran_prod_paid_amt))
colnames(cl_value) <- c("cust_id","cl_value")
colnames(Nestle_value) <- c("cust_id","Nestle_value")
# merge aboving two attributes into the customer table 
l <- merge(cl_value,l,all.y =T)
l <- merge(Nestle_value,l,all.y=T)
sapply(l,function(x) sum(is.na(x)))
l[is.na(l)] <- 0



# Calculate the ratio of the total amount of transactions including CHOCOLATE (customer_level)
l$cl_amt_ratio <- l$cl_amt/l$total_transaction
# calculate the ratio of the total values of transactions inlcuding CHOCOLATE (customer-level)
l$cl_value_ratio <- l$cl_value/l$total_revenue

# pick up only useful attributes to make the table for cherry pickers. (for potential later use)
cp <- l[,c(1,2,3,4,5,6,7,12,13,14,15)]

# finally formed the customer-level table with only 4 attributes: "p_o_discount_purchase", "avg_discount_rate", "cl_amt_ratio", "cl_value_ratio"
cpc <- cp[,c(1,8,9,10,11)]

cor(cpc[,2:5]) # calculate correlation

# create normalization function
standarlize <- function(x){
  return((x-min(x))/(max(x)-min(x)))
}
# normalization
cpcs <- lapply(cpc,standarlize)
cpcs <- as.data.table(cpcs)
cpc <- as.data.table(cpc)
cpcs <- cbind(cpc[,.(cust_id)],cpcs[,-c('cust_id')])
# find the best k
fviz_nbclust(cpcs[, 2:5], kmeans, method = "wss", k.max = 10, print.summary = T)
fviz_nbclust(cpcs[, 2:5], kmeans, method = "silhouette", k.max = 10, print.summary = T) #3
fviz_nbclust(cpcs[, 2:5], kmeans, method = "gap_stat",nboot = 30, k.max = 10, print.summary = T) #2
# the best k we have is 3. 
set.seed(1234)
clusters <- kmeans(cpcs[, 2:5], 3)
clusters$size # 2513 1921 3486
clusters$centers # centric after normalization

#p_o_discount_purchase avg_discount_rate cl_amt_ratio cl_value_ratio
#1             0.1881072         0.2206440   0.02122495     0.02169495
#2             0.4647039         0.5399674   0.02320734     0.02324895
#3             0.3129384         0.3814931   0.02481333     0.02458643
cpcs[,cluster_3:=clusters$cluster]
three_cluster <- cpcs[,-c('cust_id')][,lapply(.SD,mean),cluster_3][order(cluster_3)] # centric before normalization

set.seed(1234)
clusters_2 <- kmeans(cpcs[, 2:5], 2)
clusters_2$size # 4249 3671
clusters_2$centers # centric after normalization
# result from 2 cluster model
#p_o_discount_purchase avg_discount_rate cl_amt_ratio cl_value_ratio
#1             0.2253550         0.2704901   0.02232536     0.02281131
#2             0.4082755         0.4827918   0.02439618     0.02396177
cpcs[,cluster_2:=clusters_2$cluster]
two_cluster <- cpcs[,-c('cust_id')][,lapply(.SD,mean),cluster_2][order(cluster_2)] # centric before normalization

hist(cpcs$p_o_discount_purchase)
hist(cpcs$avg_discount_rate)
hist(cpcs$cl_amt_ratio)
hist(cpcs$cl_value_ratio)

# targeted customers with target products ------------------------------------------------------

# filter out those cherry-pickers based on CHOCOLATE likeness
cp_cl <- cpcs %>% filter(cluster_3 == 2)

# taregt customer list for cherry pickers
target_cust_list <- unique(cp_cl$cust_id)

write.csv(target_cust_list,"Cherry_pickers.csv")





# all following steps are aimed to explore the four sub-brand of CHOCOLATE. 
ccl <- data %>% filter(category_desc_eng=="CHOCOLATE" & brand_desc == "NESTLE")
table(ccl$sub_category_desc)



# filter out all Nestle products
Nestle_info <- product %>% filter(prod_id %in% ccl$prod_id)
Nestle_info <- Nestle_info[,c(1,3)]
#merge it with product table. 
Nestle_info <- merge(Nestle_info, product_statistics,all.x=T)



# find the summary stats for each of the four sub-category. 
Nestle_info_BRANQ <- Nestle_info %>% filter(sub_category_desc=="SABORISANTES")
summary(Nestle_info_BRANQ[,3:8]) 






cc <- data %>% filter(category_desc_eng=="CHOCOLATE" & sub_category_desc=="SABORISANTES" )
table(cc$sub_category_desc)
table(cc$brand_desc)
# COLA CAO         NESQUIK          NESTLE        PRIVATE LABEL       SUCHARD EXPRESS 

# filter out all cl products
all_info <- product %>% filter(prod_id %in% cc$prod_id)
all_info <- all_info[,c(1,6)]
#merge it with product table. 
all_info <- merge(all_info, product_statistics,all.x=T)
all_info1 <- all_info %>% filter(brand_desc=="COLA CAO")
summary(all_info1[,3:8]) 
all_info2 <- all_info %>% filter(brand_desc=="SUCHARD EXPRESS")
summary(all_info2[,3:8]) 
