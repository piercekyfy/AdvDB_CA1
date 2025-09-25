import json
import pandas as pd

# Make 'brand_name' a field of each device
brands = pd.read_json("dataset_phones.json")
brands = brands.explode("devices", ignore_index=True)
devices = pd.DataFrame(brands['devices'].tolist())
brands.drop(columns=['devices'], inplace=True)
final = pd.concat([brands, devices], axis=1)

# Wrap json in docs: field for CouchDB importing

out = {"docs": final.to_dict(orient='records')}

with open("processed_dataset_phones.json", 'w') as f:
    json.dump(out, f, indent=2)