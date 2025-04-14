## Description 

**website_sessions**
- website_session_id is the primary key of the website sessions table.
- created_at is a timestamp indicating when that session takes place.
- user_id is linked to the cookie in a user’s browser used to track users across multiple sessions.
- is_repeat_session is a binary number. represented by 0 or 1 depending on whether or not this user has been to the website before.
- utm_source, utm_campaign and utm_content are tracking parameters that used to measure our paid marketing activity.they are appended link tags to our website URLs. 
- Device_type indicates whether the user is on their computer or if they’re on a mobile device.
http_referer indicates where traffic is coming from.

**website_pageviews**
- website_pageviews - the Website_pageview table is basically the page views that a user saw when they were on the e-commerce website.
- created_at - is a timestamp indicating when that pageview happened.
- website_session_id - note that this column is a primary key on website_session table and in the  website_pageviews it corresponds to the foreign key, so when we want to use those two table together we will use a join clause.
- pageview_url - means that an user first landed on the home page in a specific time and then later he/she went to the products page then clicked through to the original Mr. Fuzzy page then clicked through to the cart then to the shipping page, the billing page and finally they landed on thank you for your order. This is important for conversion funnel analysis.

**orders**
- order_id - is the number of the transaction
- created_at - is a timestamp indicating when that order happened.
- website_session_id - this column is a primary key on website_session table and in the order_id it corresponds to the foreign key, so when we want to use those two table together we will use a join clause.
- user_id is linked to the cookie in a user’s browser used to track users across multiple sessions.
- primary_procut_id - indicats the product that a customer puts in their cart first. It has 4 different numbers rnge between 1 to 4.
- item_purchased - 
- price_usd is the price of the products in dollars 
- cogs_usd is the cost of goods sold in dollars
