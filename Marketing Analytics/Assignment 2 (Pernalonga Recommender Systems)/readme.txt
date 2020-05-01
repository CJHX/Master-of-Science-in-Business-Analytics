Background
Pernalonga, a leading supermarket chain of over 400 stores in Lunitunia, sells over 10 thousand products in over 400 categories.  Pernalonga regularly partners with suppliers to fund promotions and derives about 30% of its sales on promotions.  While a majority of its promotion activities are in-store promotions, it recently started partnering with select suppliers to experiment on personalized promotions.  In theory, personalized promotions are more efficient as offers are only made to targeted individuals who required an offer to purchase a product.  In contrast, most in-store promotions make temporary price reductions on a product available to all customers whether or not a customer needs the incentive to purchase the product.  The efficiency of personalized promotion comes from an additional analysis required on customer transaction data to determine which customers are most likely to purchase a product to be offered in order to maximize the opportunity for incremental sales and profits.

Problem
Your analytics consulting firm was selected by Pernalonga (the client) to develop a marketing campaign to experiment on personalized promotions.  While the details of specific partnerships with suppliers to fund the experimental personalized promotions are still being negotiated, you have received data from the client.  You have two weeks to analyze the data to support the proposed marketing campaign below (assigned according to your group number) that is scheduled to run for two weeks in April 2020.

Colgate-Palmolive is interested in a promotional campaign to boost the sales of Colgate toothpaste.
Kimberly-Clark is planning to promote the Huggies brand targeting customers who are currently buying another brand.
Heineken is interested in knowing whether or not it can increase the sales of Heineken branded products by targeting customers who currently buy Super Bock.
Nestle is interested in promoting its chocolate products to increase its overall share of the category.
Unilever wants to find out which Dove branded products to promote in order to increase overall sales for the Dove brand.
Coca-cola and Pepsi Cola are both planning personalized promotion campaigns, but Pernalonga can only pick one. Which one?
Mondelez is interested in promoting its Oreo and Chips Ahoy! brands to increase its markets share in the Fine Wafers category.
Pernalonga plans to have personalized offers to at least 500 customers who purchased at least L$5,000 in 2017. Each customer will be provided 2 product offers to be funded by at most 5 suppliers.
Pernalonga plans to invite one brand from the Yogurt Health category to participate in a personalized promotion campaign. Which brand should it invite?
Pernalonga plans to invite one brand from the Shampoo and Hair Conditioner categories to participate in a personalized promotion campaign. Which brand should it invite?
Pernalonga plans to have a personalized promotion campaign for one of its PRIVATE LABEL subcategory. Which one should it promote?
A restriction for all campaigns except for #11 is customers who purchase Pernalonga’s PRIVATE LABEL equivalent of the promoted brand should not be targeted.

For each of the above campaigns, a minimum requirement is to provide (with justification) a personalized promotion plan with the following:

The customers that will be targeted
For each targeted customer, which product is being promoted with an offer
Not required, but a plus for your firm (bonus points to you) if your plan includes the following information:

The expected total redemption cost for the promotion (total discounts redeemed)
The expected incremental volume for each product
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
Project written reports  and computer codes are due on March 2, 2020.  Groups who can submit final written report and computer codes by February 28, 2020 will be given extra credit.  Five groups will be selected to present their reports on March 17, 2020.