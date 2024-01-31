import codecademylib3
import pandas as pd

ad_clicks = pd.read_csv('ad_clicks.csv')
# Task 1: Examine the first few rows of ad_clicks
print(ad_clicks.head())

# Task 2: Count views from each utm_source
views_by_source = ad_clicks.groupby('utm_source').user_id.count()

# Task 3: Create a new column is_click
ad_clicks['is_click'] = ad_clicks['ad_click_timestamp'].notnull()

# Task 4: Group by utm_source and is_click, count user_id, and save to clicks_by_source
clicks_by_source = ad_clicks.groupby(['utm_source', 'is_click']).user_id.count().reset_index(name='click_count')

# Task 5: Pivot the data to have columns as is_click, index as utm_source, and values as user_id
clicks_pivot = clicks_by_source.pivot(columns='is_click', index='utm_source', values='click_count').reset_index()

# Task 6: Create a new column percent_clicked in clicks_pivot
clicks_pivot['percent_clicked'] = (clicks_pivot[True] / (clicks_pivot[True] + clicks_pivot[False])) * 100

# Task 7: Check if approximately the same number of people were shown both ads
ad_shown_counts = ad_clicks.groupby('experimental_group').user_id.count()

# Task 8: Check the click percentage for Ad A and Ad B
click_percentage_by_ad = ad_clicks.groupby(['experimental_group', 'is_click']).user_id.count().unstack()
click_percentage_by_ad['click_percentage'] = (click_percentage_by_ad[True] / (click_percentage_by_ad[True] + click_percentage_by_ad[False])) * 100

# Task 9: Create two DataFrames a_clicks and b_clicks
a_clicks = ad_clicks[ad_clicks['experimental_group'] == 'A']
b_clicks = ad_clicks[ad_clicks['experimental_group'] == 'B']

# Task 10: Calculate the percent of users who clicked on the ad by day for A and B groups
a_clicks_by_day = a_clicks.groupby(['day', 'is_click']).user_id.count().unstack()
a_clicks_by_day['click_percentage'] = (a_clicks_by_day[True] / (a_clicks_by_day[True] + a_clicks_by_day[False])) * 100

b_clicks_by_day = b_clicks.groupby(['day', 'is_click']).user_id.count().unstack()
b_clicks_by_day['click_percentage'] = (b_clicks_by_day[True] / (b_clicks_by_day[True] + b_clicks_by_day[False])) * 100

# Task 11: Compare the results for A and B, and make a recommendation
print("A clicks by day:")
print(a_clicks_by_day)

print("B clicks by day:")
print(b_clicks_by_day)
