if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@transformer
def transform(data, *args, **kwargs):
    print("Preprocessing rows: rows with zero passengers: ", data['passenger_count'].isin([0]).sum())

    print("Preprocessing rows: rows with zero trip distance: ", data['trip_distance'].isin([0]).sum())

    # Filter passenger_count and trip_distance with 0 values
    data = data[(data['passenger_count'] > 0) & (data['trip_distance'] > 0)]

    data.columns = (data.columns
                .str.replace('(?<=[a-z])(?=[A-Z])', '_', regex=True)
                .str.lower()
             )

    data['lpep_pickup_date'] = data['lpep_pickup_datetime'].dt.date

    return data

# Assert blocks for testing
@test
def test_vendorid(output, *args):
    values_to_check = output['vendor_id'].unique()
    assert output['vendor_id'].isin(values_to_check).any(), 'Column vendor_id does not have any existing values.'

@test
def test_passenger(output, *args):
    assert output['passenger_count'].isin([0]).sum() == 0, 'There are row with zero passenger'

@test
def test_trip(output, *args):
    assert output['trip_distance'].isin([0]).sum() == 0, 'There are row with zero trip distance'
