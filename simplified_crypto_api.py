import requests
import pandas as pd
import os
from time import sleep
import json

#API setup
url = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest'
parameters = {'start': '1', 'limit': '15', 'convert': 'USD'}
headers = {'Accepts': 'application/json', 'X-CMC_PRO_API_KEY': '0ad53085-1cb2-4eb8-ad9e-3ffbd7e56509'}

#Global DataFrame
df = pd.DataFrame()

#API runner function
def api_runner():
    global df
    try:
        response = requests.get(url, headers=headers, params=parameters)
        data = response.json()['data']

        #Normalise and new data appending 
        df2 = pd.json_normalize(data)
        df2['Timestamp'] = pd.to_datetime('now')
        df = pd.concat([df, df2], ignore_index=True)

        #Saving to CSV
        file_path = '/Users/utkarshkumargiri/Downloads/Crpto API Call/API_data.csv'
        mode = 'w' if not os.path.exists(file_path) else 'a'
        df.to_csv(file_path, mode=mode, header=not os.path.exists(file_path), index=False)

    except requests.exceptions.RequestException as e:
        print(f"Error: {e}")

#Running API call every minute 
for _ in range(333):
    api_runner()
    print('API Runner completed.')
    sleep(60)

# Final output
print(df)
