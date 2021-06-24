
use VaccineVisualizer;

-- calculate the average new cases per week before the lockdown, the average new cases per week during the lockdown, and the gain during the lockdown period versus before the lockdown date for each state
select
    state_name,
    round(avg_cases_prelockdown, 2),
    round(avg_cases_during_lockdown, 2),
    round(ifnull(avg_cases_during_lockdown / avg_cases_prelockdown, avg_cases_during_lockdown), 2) as avg_times_increase
from state
join covid_data using (state_id)
join (
    select state_id, avg(new_cases) as 'avg_cases_prelockdown'
    from regulations join covid_data using (state_id)
    where week < lockdown_date
    group by state_id
) as a using (state_id)
join (
    select state_id, avg(new_cases) as 'avg_cases_during_lockdown'
    from regulations join covid_data using (state_id)
    where week between lockdown_date and reopen_date
    group by state_id
) as b using (state_id)
group by state_id
order by avg_times_increase asc;

-- calculate the average percent vaccinated people in each state, sorted by the state’s political affiliation
select political_affiliation, round(avg(percent_vaccinated), 4)
from state join (
    select state_id, tot_vaccinated / population as percent_vaccinated
    from covid_data join state using (state_id)
    where week = '2021-06-13'
    ) as perc_vacc using (state_id)
group by political_affiliation;


-- queries that were made for our analysis and to help us throughout the project but were not used for visualizations:


-- correlation between number of cases per week in march versus lockdown date? 
    -- march 11 is when WHO declared covid as a global pandemic and was declared a national emergency
select state_name, week, tot_cases, lockdown_date
from covid_data
join state using (state_id)
join regulations using (state_id)
where monthname(week) = 'March' AND year(week) = 2020;

-- how many cases had been occurring in the us before they declared covid a global pandemic? (march 11 2020)
    -- our data starts from march, so we are only able to look at march 1 - march 11
select state_name, sum(tot_cases)
from covid_data
join state using (state_id)
where week between '2020-03-01' and '2020-03-11'
group by state_name;


-- first vaccine given in the us was 12/14/2020, has there been a change in growth weekly cases?
    -- could potentially be accomplished by looking at taking avg of increasing percentage of cases before vaccine vs after
select state_name, week, new_cases, tot_vaccinated
from covid_data
join state using (state_id)
where week between '2020-12-14' and now();

-- do states w higher vax rates have lower cases?
select *, round(tot_vaccinated/population, 2)*100 as vax_rate
from covid_data
join state using (state_id);

select state_name, week, tot_cases, lockdown_date, (tot_cases / population) * 100 as 'case_population_percentage'
from covid_data 
join state using (state_id)
join regulations using (state_id)
where month(week) = 03 and year(week) = 2020
order by case_population_percentage desc, lockdown_date;

 
-- returns the percentage of states with no mask mandates that are republican or democratic
select
    round(repub_count/(repub_count + dem_count)*100,2)no_mask_republican_states,
    round(dem_count/(repub_count + dem_count)*100,2)no_mask_democratic_states
from (
    select count(state_id)repub_count
    from regulations
    join state using (state_id)
    where mask_start is null AND political_affiliation = 'Republican')rtmp
join (
    select count(state_id)dem_count
    from regulations
    join state using (state_id)
    where mask_start is null AND political_affiliation = 'Democrat')dtmp;

-- returns the percentage of states with mask mandates that are republican or democratic
select
    round(repub_count/(repub_count + dem_count)*100,2)masked_republican_states,
    round(dem_count/(repub_count + dem_count)*100,2)masked_democratic_states
from (
    select count(state_id)repub_count
    from regulations
    join state using (state_id)
    where mask_start is not null AND political_affiliation = 'Republican')rtmp
join (
    select count(state_id)dem_count
    from regulations
    join state using (state_id)
    where mask_start is not null AND political_affiliation = 'Democrat')dtmp;

