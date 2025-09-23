import numpy as np
import pandas as pd

phones_df = pd.read_json("./dataset_phones.json", orient='records')


#print(phones_df.iloc[0]['devices'])#['devices'] = phones_df.iloc[0].apply(lambda row: [{**device, 'brand':row['brand_name']} for device in row['devices']])

#phones_df['devices']

print(phones_df.iloc[0].get(['devices']))

#phones_df = phones_df.apply(lambda row: [{**device, 'brand':row['brand_name']} for device in row.get(['devices'])])