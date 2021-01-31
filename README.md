# Louisville Dock-less Vehicles Open Data Analysis

A project for the course of Data mining and computational statistics.
This repo is mirrored [here](https://github.com/baggiponte/blogdown-escooters-louisville-r), the repo to host the static HTML website of the project.

## Libraries for Machine Learning

I have almost relied entirely on [`tidymodels`](https://github.com/tidymodels/tidymodels).
I have also made a [repository](https://github.com/baggiponte/learn-tidymodels) to reproduce some basic tutorials with this framework:
you can find the originals [here](https://www.tidymodels.org/start/).

## The data

The original raw data can be obtained from [here](https://data.louisvilleky.gov/dataset/dockless-vehicles).

I did some preprocessing in Python, which you can find [here](https://github.com/baggiponte/escooters-louisville-python). I basically used it for two things:
a starting data cleaning to get deal with mislabelled observations and then used [`geopandas`](https://geopandas.org/) to intersect the data with a shapefile of the city.

## Quick Table of Contents

The analysis goes as follows:

1. **Exploratory Data Analysis**.
2. **Some Advanced Visualisations** using `{circlize}` and `{ggalluvial}`.
3. **Final Feature Engineering**: creating the final dataset that will be used.
3. **Multinomial Logistic Regression**.
4. **Decision Tree**.
5. **K-means and Hierarchical Clustering**.
6. **Final Considerations** on what is missing and how I felt using Tidymodels.
