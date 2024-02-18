## Homework

This is the solution for homework from first workshop about data ingestion [Here](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/cohorts/2024/workshops/dlt.md).

#### Question 1: What is the sum of the outputs of the generator for limit = 5?

`C: 8.382332347441762`

We can take a look the code from homework notebook and modify it. [This is my attempt](https://github.com/jadugd/Jadug_ZoomCamp2024/blob/main/workshop/data_ingestion/Homework_data_talks_club_data_extraction_and_ingestion.ipynb)

```python
def square_root_generator(limit):
    n = 1
    while n <= limit:
        yield n ** 0.5
        n += 1

# Example usage:
limit = 5
generator = square_root_generator(limit)

sum_value = 0

for sqrt_value in generator:
    sum_value += sqrt_value
    print(sqrt_value)

print(f"sum value is : {sum_value:.4}")
```

#### Question 2: What is the 13th number yielded by the generator?

`B: 3.605551275463989`

try to change the limit to 13 and run it.
```python
def square_root_generator(limit):
    n = 1
    while n <= limit:
        yield n ** 0.5
        n += 1

# Example usage:
limit = 13
generator = square_root_generator(limit)

for sqrt_value in generator:
    print(f"{sqrt_value:.5}")
```

#### Question 3: Append the 2 generators. After correctly appending the data, calculate the sum of all ages of people.
`A: 353`

Here's how i do that. I load the first genarator first to table on the DuckDB and then load the second generator with `append` on `write_dispotition` argument on the same table.

```python
# Question 3
import dlt
import duckdb

# create pipeline that load to duckdb
people_pipeline = dlt.pipeline(destination='duckdb', dataset_name='peoples_data')

# run the pipeline for first generators
info = people_pipeline.run(people_1(),
                           table_name='people',
                           write_disposition="replace",
                           primary_key='ID')

# show the outcome

conn = duckdb.connect(f"{people_pipeline.pipeline_name}.duckdb")

# let's see the tables
conn.sql(f"SET search_path = '{people_pipeline.dataset_name}'")
print('Loaded tables: ')
display(conn.sql("show tables"))

print("\n\n\n people with only first generator:")
peoples = conn.sql("SELECT * FROM people").df()
display(peoples)

print("\n\n\n Sum All Age on table:")
sum_age = conn.sql("SELECT SUM(AGE) FROM people").df()
display(sum_age)

# append second generator to the table
info = people_pipeline.run(people_2(),
                           table_name='people',
                           write_disposition="append",
                           primary_key='ID')

print("\n\n\n people with both generator:")
all_peoples = conn.sql("SELECT * FROM people").df()
display(all_peoples)

print("\n\n\n Sum All Age on table:")
sum_all = conn.sql("SELECT SUM(AGE) FROM people").df()
display(sum_all)
```

#### Question 4: Merge the 2 generators using the ID column. Calculate the sum of ages of all the people loaded as described above.

`B: 266`

Same method in the question 3 but, when load the second generator use `merge` on `write_dispotition` argument intead of `append` now the first generator value on the table will be overlapped and updated with value from second generator.

```python
# Question 4
import dlt
import duckdb

# create pipeline that load to duckdb
people_pipeline = dlt.pipeline(destination='duckdb', dataset_name='peoples_data')

# run the pipeline for first generators
info = people_pipeline.run(people_1(),
                           table_name='people',
                           write_disposition="replace",
                           primary_key='ID')

# merge second generator to the table
info = people_pipeline.run(people_2(),
                           table_name='people',
                           write_disposition="merge",
                           primary_key='ID')

# show the outcome

conn = duckdb.connect(f"{people_pipeline.pipeline_name}.duckdb")

# let's see the tables
conn.sql(f"SET search_path = '{people_pipeline.dataset_name}'")
print('Loaded tables: ')
display(conn.sql("show tables"))

print("\n\n\n people with both generator:")
all_peoples = conn.sql("SELECT * FROM people").df()
display(all_peoples)

print("\n\n\n Sum All Age on table:")
sum_all = conn.sql("SELECT SUM(AGE) FROM people").df()
display(sum_all)
```

### Closing
That's all for the Workshop 1 Homework.
The code can be found on the notebook in this same folder.