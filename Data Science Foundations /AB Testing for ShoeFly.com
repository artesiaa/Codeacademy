import codecademylib3
import pandas as pd

ad_clicks = pd.read_csv('ad_clicks.csv')
views = ad_clicks.groupby('utm_source').user_id.count().reset_index()

print(views)

ad_clicks['is_click'] = ~ad_clicks.ad_click_timestamp.isnull()

print(ad_clicks.head())
clicks_by_source = ad_clicks.groupby(['utm_source', 'is_click']).user_id.count().reset_index()

clicks_pivot = clicks_by_source.pivot(columns = 'is_click', index = 'utm_source', values = 'user_id')

clicks_pivot['percent_clicked'] = clicks_pivot[True] / (clicks_pivot[True] + clicks_pivot[False])
print(clicks_pivot)

print(ad_clicks.groupby('experimental_group').user_id.count().reset_index())

click_by_group = ad_clicks.groupby(['experimental_group','is_click']).user_id\
.count()\
.reset_index()\
.pivot(
  index = 'experimental_group', columns = 'is_click', values = 'user_id'
)\
.reset_index()

a_clicks = ad_clicks[ad_clicks.experimental_group == 'A']
b_clicks = ad_clicks[ad_clicks.experimental_group == 'B']

a_clicks_by_day = a_clicks.groupby(['is_click', 'day'])\
  .user_id.count()\
  .reset_index().pivot(
    columns = 'is_click',
    index = 'day',
    values = 'user_id'
  ).reset_index()

a_clicks_by_day = a_clicks.groupby(['is_click', 'day'])\
  .user_id.count()\
  .reset_index().pivot(
    columns = 'is_click',
    index = 'day',
    values = 'user_id'
  ).reset_index()

b_clicks_by_day = b_clicks.groupby(['is_click', 'day'])\
  .user_id.count()\
  .reset_index().pivot(
    columns = 'is_click',
    index = 'day',
    values = 'user_id'
  ).reset_index() 

a_clicks_by_day['percentage_clicked'] = a_clicks_by_day[True] / (a_clicks_by_day[True] +a_clicks_by_day[False])

b_clicks_by_day['percentage_clicked'] = b_clicks_by_day[True] / (b_clicks_by_day[True] +b_clicks_by_day[False])

print(a_clicks_by_day)
print(b_clicks_by_day)
