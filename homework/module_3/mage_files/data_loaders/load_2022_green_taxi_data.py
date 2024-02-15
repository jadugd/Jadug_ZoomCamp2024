import io
import pandas as pd
import requests
if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@data_loader
def load_data_from_api(*args, **kwargs):
    combined_df = pd.DataFrame()

    """
    Template for loading data from API
    """
    for i in range(1, 13):
        print(f'Processing : {i:02}')
        url = f'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022-{i:02}.parquet'

        df = pd.read_parquet(url)

        combined_df = pd.concat([combined_df,df], ignore_index=True)

    return combined_df


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'
