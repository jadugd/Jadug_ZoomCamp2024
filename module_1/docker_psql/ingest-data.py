#!/usr/bin/env python
# coding: utf-8

import os
import argparse
import pandas as pd
from sqlalchemy import create_engine
from time import time

def main(params):
    user = params.user
    password = params.password
    host = params.host
    port = params.port
    database = params.database
    table = params.table
    url = params.url

    output_name = 'output.csv.gz'
    csv_name = 'output.csv'

    #download the csv in gz format
    os.system(f"wget -O {output_name} {url}")
    #decompress the gz file
    os.system(f"gzip -d {output_name}")

    engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{database}')

    df_iter = pd.read_csv(csv_name, iterator=True, chunksize=100000)

    df= next(df_iter)


    df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
    df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

    df.head(n=0).to_sql(name=table, con=engine, if_exists='replace')

    while True:
        t_start = time()
        
        df=next(df_iter)
        
        df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
        df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)
        
        df.to_sql(name=table, con=engine, if_exists='append')
        
        t_end = time()
        
        print('Inserted another chunk..., took %.3f second' % (t_end-t_start))

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Ingest CSV Data to Postgres')


    parser.add_argument('--user', help='username for postgres')
    parser.add_argument('--password', help='password for postgres')
    parser.add_argument('--host', help='hostname for postgres')
    parser.add_argument('--port', help='port for postgres')
    parser.add_argument('--database', help='database name for postgres')
    parser.add_argument('--table', help='table name for postgres')
    parser.add_argument('--url', help='url for the csv')

    args = parser.parse_args()

    main(args)

