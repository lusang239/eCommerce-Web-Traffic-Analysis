------------------------------------------------
-- Import data
------------------------------------------------
-- order_item_refunds
create or replace external table `raw_data.external_order_item_refunds`
options (
  format = 'csv',
  uris = ['gs://ecom-web-traffic-data01/order_item_refunds.csv']
);

create or replace table `raw_data.order_item_refunds`
partition by date_trunc(created_at, month)
as
select * from `raw_data.external_order_item_refunds`;

-- order_items
create or replace external table `raw_data.external_order_items`
options (
  format = 'csv',
  uris = ['gs://ecom-web-traffic-data01/order_items.csv']
);

create or replace table `raw_data.order_items`
partition by date_trunc(created_at, month)
as
select * from `raw_data.external_order_items`;


--orders
create or replace external table `raw_data.external_orders`
options (
  format = 'csv',
  uris = ['gs://ecom-web-traffic-data01/orders.csv']
);

create or replace table `raw_data.orders`
partition by date_trunc(created_at, month)
as
select * from `raw_data.external_orders`;

-- products
create or replace external table `raw_data.external_products`
options (
  format = 'csv',
  uris = ['gs://ecom-web-traffic-data01/products.csv']
);

create or replace table `raw_data.products`
partition by date_trunc(created_at, month)
as
select * from `raw_data.external_products`;


-- webiste_pageviews
create or replace external table `raw_data.external_website_pageviews`
options (
  format = 'csv',
  uris = ['gs://ecom-web-traffic-data01/website_pageviews.csv']
);

create or replace table `raw_data.website_pageviews`
partition by date_trunc(created_at, month)
cluster by pageview_url
as
select * from `raw_data.external_website_pageviews`;

-- webiste_sessions
create or replace external table `raw_data.external_website_sessions`
options (
  format = 'csv',
  uris = ['gs://ecom-web-traffic-data01/website_sessions.csv']
);

create or replace table `raw_data.website_sessions`
partition by date_trunc(created_at, month)
cluster by utm_source, utm_campaign
as
select * from `raw_data.external_website_sessions`;

-- UTM
create or replace view `raw_data.utm` as 
select distinct utm_source, utm_campaign, http_referer 
from `raw_data.website_sessions` 
order by 1, 2, 3;

