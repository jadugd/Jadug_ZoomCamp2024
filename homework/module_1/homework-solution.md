## Homework Solution

Original link for the homework : [2024_Homework](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/cohorts/2024/01-docker-terraform/homework.md)

## Question 1. Knowing docker tags

run this docker run help command:

```docker run --help```

the answer is :

`--rm                               Automatically remove the container when it exits`

## Question 2. Understanding docker first run

To run docker with python 3.9 image use this command :

```docker run -it python:3.9```

The -i option ensures that input from the user is passed to the container, while the -t option associates the user's terminal with a terminal within the container.

but it'll be directing you to python window like you type python in terminal.

To set the entrypoint of bash so we can type the command you can additional command when running :

```docker run -it --entrypoint /bin/bash python:3.9```

then you can run `pip list` on the terminal window and it'll give you output like this :

```bash
$ docker run -it --entrypoint /bin/bash python:3.9
root@b2db6ccd7cd7:/# pip listt
ERROR: unknown command "listt" - maybe you meant "list"
root@b2db6ccd7cd7:/# pip list
Package    Version
---------- -------
pip        23.0.1
setuptools 58.1.0
wheel      0.42.0

[notice] A new release of pip is available: 23.0.1 -> 23.3.2
[notice] To update, run: pip install --upgrade pip
root@b2db6ccd7cd7:/# exit
exit
```




