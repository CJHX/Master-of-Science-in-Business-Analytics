Background
Pernalonga, a leading supermarket chain of over 400 stores in Lunitunia, sells over 10 thousand products in over 400 categories.  Pernalonga has two main levers to induce sales - shelf price and promoted price.  Product level shelf prices are increased to drive contribution and lowered to drive sales.  Pernalonga partners with suppliers to fund in-store temporary price reductions and derives about 30% of its sales on promotions.  

Problem
Your analytics consulting firm was selected by Pernalonga (the client) to adjust list (shelf) prices to improve revenue.  While Pernalonga understands the benefits of data and analytics-driven decision making, it is constrained in resources to implement price changes to take effect in stores in the week of April 13-19, 2020 due to holidays in the week immediately preceding.  Specifically, it can only make price changes to the same 100 products across 2 categories (fresh products excluded) in 10 stores.  As supplier-funded in-store temporary price reductions on products are still being negotiated, you can assume the same promotion schedule as the same week in 2017, i.e., timing and product temporary price reduction levels are the same for corresponding weeks in 2017 and 2020.  You have two weeks to analyze the data and recommend price changes that will improve Pernalonga's expected revenue while maintaining overall profitability.

Your pricing model should at least consider the following factors:

list price
promoted price
product affinity: substitutes and complements
sales seasonality
Your price change recommendations should be realistic, reasonable and justified with price elasticity measures.  Minimum requirements:

a list of 100 products with recommended price changes and justifications
expected changes in sales quantity, revenue and profitability for each store and overall across 10 stores
Since the problem is on changing list prices, it is not necessary to analyze data in the customer dimension, but bonus points will be given if effects of recommended price changes on each customer segment's sales quantity, revenue and profitability are reported.

Available Data
The file Pernalonga.zip contains two tables:

transaction_table.csv contains transaction history in 2016 and 2017 for close to 8,000 customers
cust_id – Customer ID
tran_id – Transaction ID
tran_dt – Transaction Date
store_id – Store ID
prod_id – Product ID
prod_unit – Product unit of measure: CT for count and KG for kilograms
prod_unit_price – Unit price of the product
tran_prod_sale_qty – Quantity/units of the product in the transaction
tran_prod_sale_amt – Sales amount for the product before discounts in the transaction
tran_prod_discount_amt – Total amount of discounts applied to the product in the transaction
tran_prod_offer_cts – Total number of offers on the product resulting in the total amount of discounts in the transaction
tran_prod_paid_amt – Amount paid for the product after discounts are applied in the transaction
product_table.csv contains the product to subcategory and category mapping and descriptions for about 11,000 products
prod_id – Product ID
subcategory_id – Subcategory ID
category_id – Category ID
sub_category_desc – Subcategory name (in Portuguese)
category_desc – Category name (in Portuguese)
category_desc_eng – Category name (in English)
brand_desc – Brand of the product, including NO LABEL and PRIVATE LABEL
Note that customer, store and product information beyond what is available above are not provided.

Grading
Professional data scientists are expected to be domain experts implementing sound mathematical models using robust and reusable computer programs.  Your work will be graded according to the following criteria:

Integration of domain knowledge/practicality into solution (20%)
Creativity and mathematically sound application/execution of chosen technique/model (25%)
Robustness and efficiency of solution/code (25%)
Report and presentation flow, delivery, and defense (20%)
Peer evaluation (10%)
Reports
Project written reports and computer codes are due on March 31, 2020.  Three groups will be selected to present their reports. 