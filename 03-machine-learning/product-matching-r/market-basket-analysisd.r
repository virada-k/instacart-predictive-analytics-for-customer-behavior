# Download package
library(data.table)
library(dplyr)
library(arules)
library(arulesViz)
library(ggplot2)


# Download data
op_prior <- fread("order_products__prior.csv",
                  select = c("order_id", "product_id"))

products <- fread("products.csv",
                  select = c("product_id", "product_name"))


# Merge data
df_merged <- op_prior %>%
  left_join(products, by = "product_id")


## Check overall data
head(df_merged)
# ## result:
#    order_id product_id          product_name
#       <int>      <int>                <char>
# 1:        2      33120    Organic Egg Whites
# 2:        2      28985 Michigan Organic Kale
# 3:        2       9327         Garlic Powder
# 4:        2      45918        Coconut Butter
# 5:        2      30035     Natural Sweetener
# 6:        2      17794               Carrots

length(unique(df_merged$order_id))
# ## result:
# [1] 3214874



# Convert the data to "sampling"

all_order_id <- unique(df_merged$order_id)

set.seed(93)
n <- 10000
sample_order_id <- sample(all_order_id, size = n, replace = FALSE)

df_sample <- df_merged %>%
  filter(order_id %in% sample_order_id) %>%
  select(order_id, product_name)


head(df_sample)
# ## result:
#    order_id                              product_name
#       <int>                                    <char>
# 1:      907             Lifesavors Mints Wint O Green
# 2:      907                                      Cola
# 3:     1662                      Organic Blackberries
# 4:     1662          Meatles  Soy Gluten-Free Grounds
# 5:     1662 Meatless & Soy Free Frozen Chik'n Tenders
# 6:     1662                                   Carrots

length(unique(df_sample$order_id))
# ## result:
# [1] 10000

## Convert data frame to transaction format
transaction_list <- split(df_sample$product_name, df_sample$order_id)

## Convert "list" to object of transaction
transactions <- as(transaction_list, "transactions")

## View the first 3 transactions
inspect(transactions[1:3])
# ## result:
#     items                                                    transactionID
# [1] {Cola,                                                                
#      Lifesavors Mints Wint O Green}                                   907 
# [2] {Bag of Organic Bananas,                                              
#      California Extra Virgin Olive Oil,                                   
#      Carrots,                                                             
#      Fresh Cauliflower,                                                   
#      Meatles  Soy Gluten-Free Grounds,                                    
#      Meatless & Soy Free Frozen Chik'n Tenders,                           
#      Organic 1% Low Fat Milk,                                             
#      Organic Blackberries,                                                
#      Organic Brown Rice,                                                  
#      Organic Extra Large Grade AA Brown Eggs,                             
#      Organic Gala Apples,                                                 
#      Organic Good Seed Bread,                                             
#      Organic Grape Tomatoes,                                              
#      Organic Hass Avocado,                                                
#      Organic Raspberries,                                                 
#      Organic Red On the Vine Tomato,                                      
#      Organic Strawberries,                                                
#      Probiotic Dairy Culture Strawberry,                                  
#      Raspberry Essence Water,                                             
#      Sparkling Mineral Water, Natural Lemon Flavor,                       
#      Total 2% with Strawberry Lowfat Greek Strained Yogurt,               
#      Unsweet Peach Water}                                             1662
# [3] {Avocado,                                                             
#      Cherubs Heavenly Salad Tomatoes,                                     
#      Chicken Tortilla Soup,                                               
#      Fresh Whole Garlic,                                                  
#      Grated Parmesan Cheese,                                              
#      Kickstart Pineapple Orange Mango,                                    
#      Light Chicken & Dumpling Soup,                                       
#      Light Chicken Corn Chowder,                                          
#      Medium Scarlet Raspberries,                                          
#      Organic Blackberries,                                                
#      Plain Greek Yogurt,                                                  
#      Ready to Serve Long Grain White Rice,                                
#      Reduced Fat Shredded Mozzarella Cheese,                              
#      Rich & Hearty Chicken & Homestyle Noodles Soup,                      
#      Rich & Hearty Creamy Roasted Chicken Wild Rice Soup,                 
#      Strawberries,                                                        
#      Sweet Potatoes,                                                      
#      Tortillas, Flour,                                                    
#      Traditional Chickarina Chicken Soup with Meatballs,                  
#      Traditional Chicken & Herb Dumplings Soup,                           
#      Traditional Chicken & Orzo with Lemon Soup,                          
#      Traditional Chicken & Wild Rice Soup,                                
#      Traditional Italian-Style Wedding Soup,                              
#      Unsweetened Vanilla Almond Milk,                                     
#      Zero Ultra Energy Drink}                                         1979


## ML: apriori process
apriori_rules <- apriori(transactions, parameter = list(
  support = 0.001,  
  # 10000*0.001 = 10 (product matching behavior at least 10 times)
  
  confidence = 0.6,
  # Probability of the RHS item (threshold 60%) being purchased given the LHS item
  
  maxlen = 3
  # Maximum items per association rule (LHS + RHS)
))


summary(apriori_rules)
# ## result:
# set of 14 rules

# rule length distribution (lhs + rhs):sizes
#  2  3 
#  1 13 

#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#   2.000   3.000   3.000   2.929   3.000   3.000 

# summary of quality measures:
#     support           confidence        coverage             lift        
#  Min.   :0.001000   Min.   :0.6000   Min.   :0.001500   Min.   :  4.208  
#  1st Qu.:0.001025   1st Qu.:0.6250   1st Qu.:0.001600   1st Qu.:  4.394  
#  Median :0.001200   Median :0.6364   Median :0.001900   Median :  4.548  
#  Mean   :0.001179   Mean   :0.6411   Mean   :0.001843   Mean   : 21.419  
#  3rd Qu.:0.001300   3rd Qu.:0.6625   3rd Qu.:0.002000   3rd Qu.:  4.960  
#  Max.   :0.001400   Max.   :0.6875   Max.   :0.002200   Max.   :112.166  
#      count      
#  Min.   :10.00  
#  1st Qu.:10.25  
#  Median :12.00  
#  Mean   :11.79  
#  3rd Qu.:13.00  
#  Max.   :14.00  

# mining info:
#          data ntransactions support confidence
#  transactions         10000   0.001        0.6
# call
#  apriori(data = transactions, parameter = list(support = 0.001, confidence = 0.6, maxlen = 3))
























gdgd






































































































































































