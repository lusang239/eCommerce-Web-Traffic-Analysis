------------------------------------------------
-- part 2) Landing Page
------------------------------------------------

-- rank of mosted viewed website pages by session volume
select pageview_url, count(website_pageview_id) as page_views
from `raw_data.website_pageviews`
where created_at < '2012-06-19'
group by 1
order by page_views desc;

-- top entry page
select 
  pageview_url as landing_page_url, 
  count(distinct website_session_id) as sessions_hitting_this_landing_page
from `raw_data.website_pageviews`
where website_pageview_id in (select min(website_pageview_id) from `raw_data.website_pageviews` group by website_session_id)
  and created_at < '2012-06-19'
group by 1
order by 2 desc;


-- bounce rate for traffic landing on the homepage
with session_landing_page as (
  select 
    website_session_id,
    pageview_url as landing_page_url
  from `raw_data.website_pageviews`
  where website_pageview_id in (select min(website_pageview_id) from `raw_data.website_pageviews` group by website_session_id)
    and created_at < '2012-06-19'
), bounced_sessions as (
  select website_session_id as bounced_session_id
  from `raw_data.website_pageviews`
  where created_at < '2012-06-19'
  group by 1
  having count(website_pageview_id) = 1
)
select
  slh.landing_page_url,
  count(distinct wpv.website_session_id) as sessions,
  count(distinct bs.bounced_session_id) as bounced_sessions,
  round(count(distinct bs.bounced_session_id)/count(distinct wpv.website_session_id), 4) as bounce_rate
from `raw_data.website_pageviews` wpv
join session_landing_page slh
on wpv.website_session_id = slh.website_session_id
left join bounced_sessions bs
on wpv.website_session_id = bs.bounced_session_id
group by 1;

------------------------------------------------
-- AB lander test /home vs /lander-1
------------------------------------------------
/* 
the website manager ran a new custom landing page (/lander-1) in a 50/50 A/B testing 
against the homepage(/home) for the gsearch nonbrand traffic from Jun 19 — July 28.
*/

-- Compare the bounce rate between two groups
with session_landing_homepage_lander1 as (
  select 
    website_session_id,
    pageview_url as landing_page_url
  from `raw_data.website_pageviews`
  where website_pageview_id in (select min(website_pageview_id) from `raw_data.website_pageviews` group by website_session_id)
    and created_at between '2012-06-19' and '2012-07-28'
    and website_session_id in (select distinct website_session_id from `raw_data.website_sessions` where utm_source = 'gsearch' and utm_campaign = 'nonbrand')
), bounced_sessions as (
  select website_session_id as bounced_session_id
  from `raw_data.website_pageviews`
  where created_at between '2012-06-19' and '2012-07-28'
  group by 1
  having count(website_pageview_id) = 1
)
select
  slh.landing_page_url,
  count(distinct wpv.website_session_id) as sessions,
  count(distinct bs.bounced_session_id) as bounced_sessions,
  round(count(distinct bs.bounced_session_id)/count(distinct wpv.website_session_id), 4) as bounce_rate
from `raw_data.website_pageviews` wpv
join session_landing_homepage_lander1 slh
on wpv.website_session_id = slh.website_session_id
left join bounced_sessions bs
on wpv.website_session_id = bs.bounced_session_id
group by 1;

-- check volume routed to two groups
with session_landing_homepage_lander1 as (
  select
    created_at as session_created_at,
    website_session_id,
    pageview_url as landing_page_url
  from `raw_data.website_pageviews`
  where website_pageview_id in (select min(website_pageview_id) from `raw_data.website_pageviews` group by website_session_id)
    and created_at between '2012-06-01' and '2012-08-31'
    and website_session_id in (select distinct website_session_id from `raw_data.website_sessions` where utm_source = 'gsearch' and utm_campaign = 'nonbrand')
), session_pageviews as (
  select 
    website_session_id,
    count(website_pageview_id) as count_pageviews
  from `raw_data.website_pageviews`
  where created_at between '2012-06-01' and '2012-08-31'
  group by 1
)
select 
  min(date(created_at)) as week_start_date,
  round(count(distinct case when sp.count_pageviews = 1 then sp.website_session_id else null end)/count(distinct sp.website_session_id), 4) as bounce_rate,
  count(distinct case when slh.landing_page_url = '/home' then slh.website_session_id else null end) as home_sessions,
  count(distinct case when slh.landing_page_url = '/lander-1' then slh.website_session_id else null end) as lander_sessions
from `raw_data.website_pageviews` wpv
join session_landing_homepage_lander1 slh
on wpv.website_session_id = slh.website_session_id
left join session_pageviews sp
on wpv.website_session_id = sp.website_session_id
group by extract(week from slh.session_created_at)
order by 1;

-- Compare the conversion rate
with session_landing_homepage_lander1 as (
  select 
    website_session_id,
    pageview_url as landing_page_url
  from `raw_data.website_pageviews`
  where website_pageview_id in (select min(website_pageview_id) from `raw_data.website_pageviews` group by website_session_id)
    and created_at between '2012-06-19' and '2012-07-28'
    and website_session_id in (select distinct website_session_id from `raw_data.website_sessions` where utm_source = 'gsearch' and utm_campaign = 'nonbrand')
)
select
  slh.landing_page_url,
  count(distinct slh.website_session_id) as sessions,
  count(distinct o.order_id) as orders,
  round(count(distinct o.order_id)/count(distinct slh.website_session_id), 4) as conversion_rate
from session_landing_homepage_lander1 slh
left join `raw_data.orders` o
on slh.website_session_id = o.website_session_id
group by 1;


-- Incremental orders for the next 4 months (7/29 ~ 11/27) 
-- 22972
select count(distinct website_session_id) sessions_since_test
from `raw_data.website_sessions`
where created_at between '2012-07-29' and '2012-11-27'
and website_session_id in (select distinct website_session_id from `raw_data.website_sessions` where utm_source = 'gsearch' and utm_campaign = 'nonbrand')
and website_session_id > (
    select max(website_session_id) 
  from `raw_data.website_pageviews` 
  where pageview_url = '/home' 
    and created_at < '2012-11-27' 
    and website_session_id in (select distinct website_session_id from `raw_data.website_sessions` where utm_source = 'gsearch' and utm_campaign = 'nonbrand')
);


-- generate a temp view for session level funnel tables
create or replace view `raw_data.session_level_funnel_table` as
select
  website_session_id,
  max(homepage) as homepage,
  max(custom_lender) as custom_lender,
  max(products_page) as view_products,
  max(mrfuzzy_page) as see_mrfuzzy,
  max(cart_page) as go_to_cart,
  max(shipping_page) as fill_in_shipping,
  max(billing_page) as add_billing,
  max(thankyou_page) as complete_checkout
from (
  select
    website_session_id,
    pageview_url,
    case when pageview_url = '/home' then 1 else null end as homepage,
    case when pageview_url = '/lander-1' then 1 else null end as custom_lender,
    case when pageview_url = '/products' then 1 else null end as products_page,
    case when pageview_url = '/the-original-mr-fuzzy' then 1 else null end as mrfuzzy_page,
    case when pageview_url = '/cart' then 1 else null end as cart_page,
    case when pageview_url = '/shipping' then 1 else null end as shipping_page,
    case when pageview_url = '/billing' then 1 else null end as billing_page,
    case when pageview_url = '/thank-you-for-your-order' then 1 else null end as thankyou_page
  from `raw_data.website_pageviews`
  where created_at between '2012-06-19' and '2012-07-28'
    and website_session_id in (
        select distinct website_session_id 
        from `raw_data.website_sessions` 
        where utm_source = 'gsearch' 
        and utm_campaign = 'nonbrand')
  order by website_session_id, created_at
  ) pageview_level
group by 1;

select * from `raw_data.session_level_funnel_table`;

-- Showcase full funnel traffic volume
select
  case when homepage = 1 then 'homepage'
      when custom_lender = 1 then 'custom_lender'
      else null
  end as from_landing_page,
  count(distinct website_session_id) as sessions,
  count(view_products) as to_product,
  count(see_mrfuzzy) as to_mrfuzzy,
  count(go_to_cart) as to_cart,
  count(fill_in_shipping) as to_shipping,
  count(add_billing) as to_billing,
  count(complete_checkout) as to_thankyou,
  round(count(complete_checkout)/count(view_products), 4) as product_to_thank_you_CVR
from `raw_data.session_level_funnel_table`
group by 1;

-- Showcase full funnel conversion
select
  case when homepage = 1 then 'homepage'
      when custom_lender = 1 then 'custom_lender'
      else null
  end as from_landing_page,
  round(count(view_products)/count(distinct website_session_id), 4) as lander_to_product,
  round(count(see_mrfuzzy)/count(view_products), 4) as product_to_mrfuzzy,
  round(count(go_to_cart)/count(see_mrfuzzy), 4) as mrfuzzy_to_cart,
  round(count(fill_in_shipping)/count(go_to_cart), 4) as cart_to_shipping,
  round(count(add_billing)/count(fill_in_shipping), 4) as shipping_to_billing,
  round(count(complete_checkout)/count(add_billing), 4) as billing_to_checkout
from `raw_data.session_level_funnel_table`
group by 1;


------------------------------------------------
-- AB billing test /billing vs /billing-2
------------------------------------------------
/*
the website manager ran a new custom billing page (/billing-2) in a 50/50 A/B test 
against the original billing page(/billing) for the gsearch nonbrand traffic from Sep 10 - Nov 10.
*/

-- Compare the conversion rate between /billing and /billing-2
create or replace view `raw_data.sessions_w_billing_pageview` as
select
  website_session_id,
  max(billing_page) as billing_page,
  max(new_billing_page) as new_billing_page,
  max(thankyou_page) as thankyou_page
from (
  select
    website_session_id,
    case when pageview_url = '/billing' then 1 else null end as billing_page,
    case when pageview_url = '/billing-2' then 1 else null end as new_billing_page,
    case when pageview_url = '/thank-you-for-your-order' then 1 else null end as thankyou_page
  from `raw_data.website_pageviews`
  where created_at between '2012-09-10' and '2013-01-05'
) tbl
group by 1
having billing_page is not null or new_billing_page is not null;

select * from `raw_data.sessions_w_billing_pageview`;

select
  case when billing_page = 1 then '/billing' 
       when new_billing_page = 1 then '/billing-2'
      else null
  end as from_billing_page,
  count(distinct website_session_id) as billing_sessions,
  count(thankyou_page) as billing_to_thankyou,
  round(count(thankyou_page)/count(distinct website_session_id), 4) as billing_to_thankyou_CVR
from`raw_data.sessions_w_billing_pageview`
group by 1;


-- get an estimated converted sales for the next 4 months (2013/01/06 ~ 2013/05/06)
select count(website_session_id) as billing_session_past_month
from `raw_data.website_pageviews`
where created_at between '2013-01-06' and '2013-05-06'
  and pageview_url in ('/billing', '/billing-2');

-- check volume routed to two groups
with session_created_date as(
  select 
    created_at,
    website_session_id
  from `raw_data.website_pageviews`
  where website_pageview_id in (select min(website_pageview_id) from `raw_data.website_pageviews` group by website_session_id)
    and created_at between '2012-08-01' and '2013-03-31'
), billing_w_create_date as (
  select
    ssd.created_at,
    sbp.*
  from `raw_data.sessions_w_billing_pageview` sbp
  left join session_created_date ssd
    on sbp.website_session_id = ssd.website_session_id
)
select
  min(date(created_at)) as week_start_at,
  round(count(thankyou_page)/count(distinct website_session_id), 4) as to_thankyou_CVR,
  count(billing_page) as billing_sessions,
  count(new_billing_page) as new_billing_sessions
from billing_w_create_date
group by extract(week from created_at)
order by 1;

-- revenue per billing session
select
  pageview_url,
  count(distinct website_session_id) as sessions,
  round(sum(price_usd)/count(distinct website_session_id), 4) as revenue_per_session,
  round(sum(price_usd - cogs_usd)/count(distinct website_session_id), 4) as margin_per_session,
from (
  select
    wpv.pageview_url,
    wpv.website_session_id,
    o.order_id,
    o.price_usd,
    o.cogs_usd
  from `raw_data.website_pageviews` wpv
  left join `raw_data.orders` o
    on wpv.website_session_id = o.website_session_id
  where wpv.created_at between '2012-09-10' and '2013-01-05'
    and wpv.pageview_url in ('/billing', '/billing-2')
) billing_pageview_and_orders_data
group by 1;

-- get an estimated revenue earn for the next 4 months (2013/01/06 ~ 2013/02/06)
select count(website_session_id) as billing_session_past_month
from `raw_data.website_pageviews`
where created_at between '2013-01-06' and '2013-02-06'
  and pageview_url in ('/billing', '/billing-2');


