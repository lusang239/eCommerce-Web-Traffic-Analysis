------------------------------------------------
-- part 3) Seasonality
------------------------------------------------

-- Compare average number of orders between holiday (i.e. black friday and cyber monday) vs non-holiday  
with holiday_effect_orders as (
  select
    extract(year from created_at) as year,
    count(case when date(created_at) in ('2012-11-23', '2012-11-26', '2013-11-29', '2013-12-09', '2014-11-28', '2014-12-01') 
          then 1 else null end) as isHoliday,
    count(case when date(created_at) not in ('2012-11-23', '2012-11-26', '2013-11-29', '2013-12-09', '2014-11-28', '2014-12-01') 
          then 1 else null end) as nonHoliday,
    count(distinct date(created_at)) as total_days
  from `raw_data.orders`
  group by 1
)
select
  year,
  round(isHoliday/2,0) as holiday_avg_orders,
  round(nonHoliday/(total_days-2), 0) as nonHoliday_avg_orders,
  round((isHoliday/2)/(nonHoliday/(total_days-2)), 0) as rate
from holiday_effect_orders
order by 1;

