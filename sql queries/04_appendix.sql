
-- What is the conversion rate (CVR) from session to order?
select utm_source, utm_campaign, http_referer, 
  count(distinct ws.website_session_id) as sessions,
  count(distinct o.order_id) as orders,
  round(count(distinct o.order_id)/count(distinct ws.website_session_id), 4) as conversion_rate
from `raw_data.website_sessions` ws
left join `raw_data.orders` o
on ws.website_session_id = o.website_session_id
group by 1, 2, 3
order by 5 desc;



-- define the AB testing landing page launch date
select pageview_url, min(created_at) launch_date, max(created_at) end_date
from `raw_data.website_pageviews`
group by 1
order by 2;


-- utm_source launch data
select utm_source, min(created_at) launch_date, max(created_at) end_date
from `raw_data.website_sessions`
group by 1
order by 2;

-- revenue per session, order
select
  extract(year from ws.created_at) as year,
  extract(quarter from ws.created_at) as quarter,
  count(distinct o.order_id)/count(distinct ws.website_session_id) as conversion_rate,
  sum(o.price_usd)/count(distinct o.order_id) as revenue_per_order,
  sum(o.price_usd)/count(distinct ws.website_session_id) as revenue_per_session
from `raw_data.website_sessions` ws
left join `raw_data.orders` o
on ws.website_session_id = o.website_session_id
group by 1, 2
order by 1, 2;

-- quarter trend for gsearch nonbrand, bsearchnonbrand, brand search overall, organic search, and direct type-in
select 
  extract(year from ws.created_at) as year,
  extract(quarter from ws.created_at) as quarter,
  count(distinct case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then o.order_id else null end) as gsearch_nonbrand_orders,
  count(distinct case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then o.order_id else null end) as bsearch_nonbrand_orders,
  count(distinct case when utm_campaign = 'brand' then o.order_id else null end) as brand_search_orders
  -- count(distinct case when utm_source is null and ws.http_referer is not null then o.order_id else null end) as referral_orders,
  -- count(distinct case when utm_source is null and ws.http_referer is null then o.order_id else null end) as organic_search_orders
from `raw_data.website_sessions` ws
left join `raw_data.orders` o
on ws.website_session_id = o.website_session_id
group by 1, 2
order by 1, 2;

select max(created_at) from `raw_data.website_sessions` where extract(year from created_at) = 2012;
