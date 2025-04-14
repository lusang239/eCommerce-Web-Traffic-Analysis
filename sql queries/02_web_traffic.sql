------------------------------------------------
-- part 1) Web traffic
------------------------------------------------

-- Which Channels drive traffic to the website?
select *,
  round(sessions/(sum(sessions) over ())*100,2) as `% of total`
from (
  select utm_source, utm_campaign, http_referer, count(distinct website_session_id) as sessions
  from `raw_data.website_sessions`
  group by 1, 2, 3
) tbl
order by 4 desc;


-- What is the conversion rate (CVR) by digital channels?
select utm_source, utm_campaign, 
  count(distinct ws.website_session_id) as sessions,
  count(distinct o.order_id) as orders,
  round(count(distinct o.order_id)/count(distinct ws.website_session_id), 4) as conversion_rate
from `raw_data.website_sessions` ws
left join `raw_data.orders` o
on ws.website_session_id = o.website_session_id
group by 1, 2
order by 5 desc;


-- What is the overall monthly conversion rate (CVR)?
SELECT
  extract(YEAR from ws.created_at) AS year,
  extract(month from ws.created_at) as month,
  count(distinct ws.website_session_id) AS sessions,
  count(distinct o.order_id) AS orders,
  round(count(distinct o.order_id)/count(distinct ws.website_session_id), 4) as conversion_rate
FROM `raw_data.website_sessions` ws
LEFT JOIN `raw_data.orders` o
  ON ws.website_session_id = o.website_session_id
where ws.created_at < '2012-11-27'
  and utm_source = 'gsearch'
GROUP BY 1, 2
ORDER BY 1, 2;


-- Monthly trend split out non-brand vs. brand campaigns
select 
  extract(year from ws.created_at) as year,
  extract(month from ws.created_at) as month,
  count(distinct case when ws.utm_campaign = 'nonbrand' then ws.website_session_id else null end) as nonbrand_sessions,
  count(distinct case when ws.utm_campaign = 'brand' then ws.website_session_id else null end) as brand_sessions,
  count(distinct case when ws.utm_campaign = 'nonbrand' then o.order_id else null end) as nonbrand_orders,
  count(distinct case when ws.utm_campaign = 'brand' then o.order_id else null end) as brand_orders
from `raw_data.website_sessions` ws
left join `raw_data.orders` o
  on ws.website_session_id = o.website_session_id
where ws.created_at < '2012-11-27'
  and utm_source = 'gsearch'
group by 1, 2
order by 1, 2;



-- Which type of device brings the most sessions through gsearch engine?
select
  device_type,
  count(distinct ws.website_session_id) AS sessions,
  count(distinct o.order_id) AS orders,
  round(count(distinct o.order_id)/count(distinct ws.website_session_id), 4) as conversion_rate
from `raw_data.website_sessions` ws
left join `raw_data.orders` o
  on ws.website_session_id = o.website_session_id
where ws.created_at < '2012-11-27'
  and utm_source = 'gsearch'
group by 1;








