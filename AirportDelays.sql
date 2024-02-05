#Add Date column
ALTER TABLE flights
ADD COLUMN DATE DATE;


UPDATE flights
SET date = str_to_date(concat(YEAR,'-',MONTH,'-',DAY), '%Y-%m-%d');

SELECT *
from 
	flights
limit 5;

/*markdown
# Summary
*/

/*markdown
#### Total Flights in 2015
*/

select 
	count(*) as 'Total Flights in 2015'
from 
	flights;

/*markdown
#### Total Delayed Flights in 2015
*/

select 
	count(*) as 'Total Delayed Flights'
from 
	flights
where 
	DEPARTURE_DELAY>0;

/*markdown
#### Total Cancelled Flights in 2015
*/

select 
	count(*) as 'Total Cancelled Flights'
from 
	flights
where 
	CANCELLATION_REASON is not null;

/*markdown
#### Percentage of Flights Delayed in 2015
*/

select 
	round(count(*)/(select count(*) from flights)*100,2) as 'Percentage of Flights Delayed'
from 
	flights
where 
	DEPARTURE_DELAY>0;

/*markdown
#### Average Delay Time
*/

select 
    round(avg(DEPARTURE_DELAY),2) as 'Average Delay Time (min)'
from
    flights
where
    DEPARTURE_DELAY>0;

/*markdown
#### Percentage of Flights Cancelled
*/

#Calculate percentage of flights that are cancelled
select 
	round(count(*)/(select count(*) from flights)*100,2) as 'Percentage of Flights Cancelled'
from 
	flights
where 
	CANCELLATION_REASON is not null;

/*markdown
# Airlines
*/

/*markdown
#### Top 5 airlines with most flights
*/

select 
	a.AIRLINE as Airline,
	count(*) as Number_of_Flights
from 
	flights as f
left join 
	airlines as a
on 
	f.AIRLINE = a.IATA_CODE
group by 
	Airline
order by 
	Number_of_Flights desc
limit 
	5;

/*markdown
#### Top 5 arilnes with least flights
*/

select
	a.AIRLINE as Airline,
	count(*) as Number_of_Flights
from 
	flights as f
left join 
	airlines as a
on 
	f.AIRLINE = a.IATA_CODE
group by 
	Airline
order by 
	Number_of_Flights asc
limit 
	5; 

/*markdown
#### Percentage of flights delayed and average delay time by airline
*/

#Percentage of flights delayed and average delay time by airline
select
    a.AIRLINE as Airline,
    round(sum(case when f.DEPARTURE_DELAY > 0 then 1 else 0 end) * 100.0 / count(*), 2) as Percentage_of_Flights_Delayed,
    round(avg(case when f.DEPARTURE_DELAY > 0 then f.DEPARTURE_DELAY else null end), 0) as Average_Delay_Min,
    round(sum(case when f.CANCELLATION_REASON is not null then 1 else 0 end) * 100.0 / count(*), 2) as Percentage_of_Flights_Cancelled
from 
    flights as f
left join
    airlines as a
on
    f.AIRLINE = a.IATA_CODE
group by
    Airline
order by
    Percentage_of_Flights_Delayed desc;

/*markdown
#### Airlines Summary
*/

with summary as (
    select 
        a.AIRLINE as Airline,
        count(*) as Number_of_Flights,
        round(sum(case when f.DEPARTURE_DELAY > 0 then 1 else 0 end) * 100.0 / count(*), 2) as Percentage_of_Flights_Delayed,
        round(avg(case when f.DEPARTURE_DELAY > 0 then f.DEPARTURE_DELAY else null end), 0) as Average_Delay_Min,
        round(sum(case when f.CANCELLATION_REASON is not null then 1 else 0 end) * 100.0 / count(*), 2) as Percentage_of_Flights_Cancelled
    from
        flights as f
    left join
        airlines as a
    on
        f.AIRLINE = a.IATA_CODE
    group by
        Airline
    )
(select 
    'Most Flights' as Metrics,
    Airline,
    Number_of_Flights as Value
from 
    summary
order by
    Number_of_Flights desc
limit 1)
union
    (
    select 
        'Least Flights' as Metrics,
        Airline,
        Number_of_Flights as Value
    from
        summary
    order by
        Number_of_Flights asc
    limit 1
    )
union   
    (
    select 
        'Highest Percentage of Flights Delayed' as Metrics,
        Airline,
        Percentage_of_Flights_Delayed as Value
    from
        summary
    order by
        Percentage_of_Flights_Delayed desc
    limit 1
    )
union
    (select
        'Highest Average Delay Time (Min)' as Metrics,
        Airline,
        Average_Delay_Min as Value
    from
        summary
    order by
        Average_Delay_Min desc
    limit 1
    )
union
    (select
        'Least Percentage of Flights Delayed' as Metrics,
        Airline,
        Percentage_of_Flights_Delayed as Value
    from
        summary
    order by
        Percentage_of_Flights_Delayed asc
    limit 1
    )
union
    (select
        'Lowest Average Delay Time (Min)' as Metrics,
        Airline,
        Average_Delay_Min as Value
    from
        summary
    order by
        Average_Delay_Min asc
    limit 1      
    )
union
    (select 
        'Highest Percentage of Flights Cancelled' as Metrics,
        Airline,
        Percentage_of_Flights_Cancelled as Value
    from
        summary
    order by
        Percentage_of_Flights_Cancelled desc
    limit 1
    )
union
    (select 
        'Least Percentage of Flights Cancelled' as Metrics,
        Airline,
        Percentage_of_Flights_Cancelled as Value
    from
        summary
    order by
        Percentage_of_Flights_Cancelled asc
    limit 1
    );



/*markdown
# Airports
*/

/*markdown
#### Top 5 airports with most flights
*/

select 
    a.AIRPORT as Airport,
    count(*) as Number_of_Flights
from
    airports as a
left join
    flights as f
on
    f.ORIGIN_AIRPORT = a.IATA_CODE
group by
    Airport
order by
    Number_of_Flights desc
limit 5;

/*markdown
#### Top 5 airports with least flights
*/

select 
    a.AIRPORT as Airport,
    count(*) as Number_of_Flights
from
    airports as a
left join
    flights as f
on
    f.ORIGIN_AIRPORT = a.IATA_CODE
group by
    Airport
order by
    Number_of_Flights asc
limit 5;

/*markdown
#### Percentage of flights delayed and average delay time for those airports with at least 100,000 flights
*/

select
    a.AIRPORT as Airport,
    count(*) as Number_of_Flights,
    round(sum(case when f.DEPARTURE_DELAY > 0 then 1 else 0 end) * 100.0 / count(*), 2) as Percentage_of_Flights_Delayed,
    round(avg(case when f.DEPARTURE_DELAY > 0 then f.DEPARTURE_DELAY else null end), 2) as Average_Delay_Min,
    round(sum(case when f.CANCELLATION_REASON is not null then 1 else 0 end) * 100.0 / count(*), 2) as Percentage_of_Flights_Cancelled
from
    airports as a
left join
    flights as f
on
    f.ORIGIN_AIRPORT = a.IATA_CODE
group by
    Airport
having
    count(*) >= 100000
order by
    Percentage_of_Flights_Delayed desc;

/*markdown
#### Summary of Airports with at least 100,000 flights
*/

with summary as (
    select 
        a.AIRPORT as Airport,
        count(*) as Number_of_Flights,
        round(sum(case when f.DEPARTURE_DELAY > 0 then 1 else 0 end) * 100.0 / count(*), 2) as Percentage_of_Flights_Delayed,
        round(avg(case when f.DEPARTURE_DELAY > 0 then f.DEPARTURE_DELAY else null end), 2) as Average_Delay_Min,
        round(sum(case when f.CANCELLATION_REASON is not null then 1 else 0 end) * 100.0 / count(*), 2) as Percentage_of_Flights_Cancelled
    from
        airports as a
    left join
        flights as f
    on
        f.ORIGIN_AIRPORT = a.IATA_CODE
    group by
        Airport
    having
        count(*) >= 100000
    )
    (select 
        'Most Flights' as Metrics,
        Airport,
        Number_of_Flights as Value
    from 
        summary
    order by
        Number_of_Flights desc
    limit 1)
union
    (
    select 
        'Least Flights' as Metrics,
        Airport,
        Number_of_Flights as Value
    from
        summary
    order by
        Number_of_Flights asc
    limit 1
    )
union   
    (
    select 
        'Highest Percentage of Flights Delayed' as Metrics,
        Airport,
        Percentage_of_Flights_Delayed as Value
    from
        summary
    order by
        Percentage_of_Flights_Delayed desc
    limit 1
    )
union
    (select
        'Highest Average Delay Time' as Metrics,
        Airport,
        Average_Delay_Min as Value
    from
        summary
    order by
        Average_Delay_Min desc
    limit 1
    )
union
    (select
        'Least Percentage of Flights Delayed' as Metrics,
        Airport,
        Percentage_of_Flights_Delayed as Value
    from
        summary
    order by
        Percentage_of_Flights_Delayed asc
    limit 1
    )
union
    (select
        'Lowest Average Delay Time' as Metrics,
        Airport,
        Average_Delay_Min as Value
    from
        summary
    order by
        Average_Delay_Min asc
    limit 1      
    )
union
    (select 
        'Highest Percentage of Flights Cancelled' as Metrics,
        Airport,
        Percentage_of_Flights_Cancelled as Value
    from
        summary
    order by
        Percentage_of_Flights_Cancelled desc
    limit 1
    )
union
    (select 
        'Least Percentage of Flights Cancelled' as Metrics,
        Airport,
        Percentage_of_Flights_Cancelled as Value
    from
        summary
    order by
        Percentage_of_Flights_Cancelled asc
    limit 1
    );

/*markdown
# Month and Day of the Week Analysis
*/

/*markdown
#### Percentage of flights delayed, average delay and percentage of flights cancelled by month
*/

select
    MONTHNAME(DATE) as Month,
    count(*) as Number_of_Flights,
    round(sum(case when f.DEPARTURE_DELAY > 0 then 1 else 0 end) * 100.0 / count(*), 2) as Percentage_of_Flights_Delayed,
    round(avg(case when f.DEPARTURE_DELAY > 0 then f.DEPARTURE_DELAY else null end), 2) as Average_Delay_Min,
    round(sum(case when f.CANCELLATION_REASON is not null then 1 else 0 end) * 100.0 / count(*), 2) as Percentage_of_Flights_Cancelled
from
    flights as f
group by
    MONTHNAME(DATE)
order by
    Percentage_of_Flights_Delayed desc;

/*markdown
#### Summary statistics of months
*/

with summary as (
    select 
        MONTHNAME(DATE) as Month,
        count(*) as Number_of_Flights,
        round(sum(case when f.DEPARTURE_DELAY > 0 then 1 else 0 end) * 100.0 / count(*), 2) as Percentage_of_Flights_Delayed,
        round(avg(case when f.DEPARTURE_DELAY > 0 then f.DEPARTURE_DELAY else null end), 2) as Average_Delay_Min,
        round(sum(case when f.CANCELLATION_REASON is not null then 1 else 0 end) * 100.0 / count(*), 2) as Percentage_of_Flights_Cancelled
    from
        flights as f
    group by
        MONTHNAME(DATE)
    )
    (select 
        'Most Flights' as Metrics,
        Month,
        Number_of_Flights as Value
    from 
        summary
    order by
        Number_of_Flights desc
    limit 1)
union
    (select 
        'Least Flights' as Metrics,
        Month,
        Number_of_Flights as Value
    from
        summary
    order by
        Number_of_Flights asc
    limit 1
    )
union   
    (select 
        'Highest Percentage of Flights Delayed' as Metrics,
        Month,
        Percentage_of_Flights_Delayed as Value
    from
        summary
    order by
        Percentage_of_Flights_Delayed desc
    limit 1
    )
union
    (select
        'Highest Average Delay Time' as Metrics,
        Month,
        Average_Delay_Min as Value
    from
        summary
    order by
        Average_Delay_Min desc
    limit 1
    )
union
    (select
        'Least Percentage of Flights Delayed' as Metrics,
        Month,
        Percentage_of_Flights_Delayed as Value
    from
        summary
    order by
        Percentage_of_Flights_Delayed asc
    limit 1
    )
union
    (select 
        'Highest Percentage of Flights Cancelled' as Metrics,
        Month,
        Percentage_of_Flights_Cancelled as Value
    from
        summary
    order by
        Percentage_of_Flights_Cancelled desc
    limit 1
    )
union
    (select 
        'Least Percentage of Flights Cancelled' as Metrics,
        Month,
        Percentage_of_Flights_Cancelled as Value
    from
        summary
    order by
        Percentage_of_Flights_Cancelled asc
    limit 1
    );



/*markdown
#### Average number of flights, Percentage of flights delayed, average delay time, percentage of flights cancelled by day of week
*/

select
    DAYNAME(DATE) as 'Day of Week',
    round(count(*)/7,0) as 'Average Flights',
    round(sum(case when f.DEPARTURE_DELAY > 0 then 1 else 0 end) * 100.0 / count(*), 2) as Percentage_of_Flights_Delayed,
    round(avg(case when f.DEPARTURE_DELAY > 0 then f.DEPARTURE_DELAY else null end), 2) as Average_Delay_Min,
    round(sum(case when f.CANCELLATION_REASON is not null then 1 else 0 end) * 100.0 / count(*), 2) as Percentage_of_Flights_Cancelled
from
    flights as f
group by
    DAYNAME(DATE)
order by
    Percentage_of_Flights_Delayed desc; 

/*markdown
#### Month and Day Summary
*/

#Summary statistics of days of week
with summary as (
    select 
        DAYNAME(DATE) as Day_of_Week,
        round(count(*)/7,0) as Average_Flights,
        round(sum(case when f.DEPARTURE_DELAY > 0 then 1 else 0 end) * 100.0 / count(*), 2) as Percentage_of_Flights_Delayed,
        round(avg(case when f.DEPARTURE_DELAY > 0 then f.DEPARTURE_DELAY else null end), 2) as Average_Delay_Min,
        round(sum(case when f.CANCELLATION_REASON is not null then 1 else 0 end) * 100.0 / count(*), 2) as Percentage_of_Flights_Cancelled
    from
        flights as f
    group by
        DAYNAME(DATE)
    )
    (select 
        'Most Flights' as Metrics,
        Day_of_Week,
        Average_Flights as Value
    from
        summary
    order by
        Average_Flights desc
    limit 1)
union
    (select 
        'Least Flights' as Metrics,
        Day_of_Week,
        Average_Flights as Value
    from
        summary
    order by
        Average_Flights asc
    limit 1
    )
union
    (select 
        'Highest Percentage of Flights Delayed' as Metrics,
        Day_of_Week,
        Percentage_of_Flights_Delayed as Value
    from
        summary
    order by
        Percentage_of_Flights_Delayed desc
    limit 1
    )
union
    (select
        'Highest Average Delay Time' as Metrics,
        Day_of_Week,
        Average_Delay_Min as Value
    from
        summary
    order by
        Average_Delay_Min desc
    limit 1
    )
union
    (select
        'Least Percentage of Flights Delayed' as Metrics,
        Day_of_Week,
        Percentage_of_Flights_Delayed as Value
    from
        summary
    order by
        Percentage_of_Flights_Delayed asc
    limit 1
    )
union
    (select 
        'Highest Percentage of Flights Cancelled' as Metrics,
        Day_of_Week,
        Percentage_of_Flights_Cancelled as Value
    from
        summary
    order by
        Percentage_of_Flights_Cancelled desc
    limit 1
    )
union
    (select 
        'Least Percentage of Flights Cancelled' as Metrics,
        Day_of_Week,
        Percentage_of_Flights_Cancelled as Value
    from
        summary
    order by
        Percentage_of_Flights_Cancelled asc
    limit 1
    );       



/*markdown
# Delay and Cancellation Reasons Breakdown
*/

/*markdown
#### Percentage of flights delayed by reason
*/

    (select
        'Air System' as Delay_Reason,
        round(sum(case when f.AIR_SYSTEM_DELAY > 0 then 1 else 0 end) * 100.0 / sum(case when f.DEPARTURE_DELAY > 0 then 1 else 0 end), 2) as Percentage_of_Flights_Delayed
    from
        flights as f
    )
union
    (select
        'Security' as Delay_Reason,
        round(sum(case when f.SECURITY_DELAY > 0 then 1 else 0 end) * 100.0 / sum(case when f.DEPARTURE_DELAY > 0 then 1 else 0 end), 2) as Percentage_of_Flights_Delayed
    from
        flights as f
    )
union
    (select
        'Airline' as Delay_Reason,
        round(sum(case when f.AIRLINE_DELAY > 0 then 1 else 0 end) * 100.0 / sum(case when f.DEPARTURE_DELAY > 0 then 1 else 0 end), 2) as Percentage_of_Flights_Delayed
    from
        flights as f
    )
union
    (select
        'Late Aircraft' as Delay_Reason,
        round(sum(case when f.LATE_AIRCRAFT_DELAY > 0 then 1 else 0 end) * 100.0 / sum(case when f.DEPARTURE_DELAY > 0 then 1 else 0 end), 2) as Percentage_of_Flights_Delayed
    from
        flights as f
    )
union
    (select
        'Weather' as Delay_Reason,
        round(sum(case when f.WEATHER_DELAY > 0 then 1 else 0 end) * 100.0 / sum(case when f.DEPARTURE_DELAY > 0 then 1 else 0 end), 2) as Percentage_of_Flights_Delayed
    from
        flights as f
    )
order by
    Percentage_of_Flights_Delayed desc
;



/*markdown
Percentage does not add up to 100% because a flight can be delayed for multiple reasons.
*/

/*markdown
#### Distribution of delay time by reason
*/

with tot_del as 
(
    select
        (sum(AIR_SYSTEM_DELAY) + sum(SECURITY_DELAY) + sum(AIRLINE_DELAY) + sum(LATE_AIRCRAFT_DELAY) + sum(WEATHER_DELAY)) as Total_Delay
    from
        flights
)
    (select 
        'Airline Delay' as Delay_Reason,
        round(sum(AIR_SYSTEM_DELAY) * 100.0 / (select Total_Delay from tot_del),2) as Percentage_of_Total_Delaye_Time
    from
        flights
    )
union
    (select 
        'Security Delay' as Delay_Reason,
        round(sum(SECURITY_DELAY) * 100.0 / (select Total_Delay from tot_del),2) as Percentage_of_Total_Delaye_Time
    from
        flights
    )
union
    (select 
        'Airline Delay' as Delay_Reason,
        round(sum(AIRLINE_DELAY) * 100.0 / (select Total_Delay from tot_del),2) as Percentage_of_Total_Delaye_Time
    from
        flights
    )
union
    (select 
        'Late Aircraft Delay' as Delay_Reason,
        round(sum(LATE_AIRCRAFT_DELAY) * 100.0 / (select Total_Delay from tot_del),2) as Percentage_of_Total_Delaye_Time
    from
        flights
    )
union
    (select 
        'Weather Delay' as Delay_Reason,
        round(sum(WEATHER_DELAY) * 100.0 / (select Total_Delay from tot_del),2) as Percentage_of_Total_Delaye_Time
    from
        flights
    )
order by 
    Percentage_of_Total_Delaye_Time desc

/*markdown
#### Percentage of flights cancelled by reason
*/

select 
    c.CANCELLATION_DESCRIPTION as Cancellation_Reason,
    round(count(*) * 100.0 / (select count(*) from flights where flights.CANCELLATION_REASON is not null), 2) as Percentage_of_Flights_Cancelled
from flights 
left join
    cancellation_codes as c
on
    flights.CANCELLATION_REASON = c.CANCELLATION_REASON
where
    flights.CANCELLATION_REASON is not null
group by
    Cancellation_Reason
order by
    Percentage_of_Flights_Cancelled desc;

