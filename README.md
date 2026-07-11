# Movies, Ratings and Oscars Analysis

This project explores how movie budget, revenue, ratings, genres, runtime, directors, and Oscar recognition relate to commercial and critical success.

The analysis combines IMDb title data, IMDb ratings, TMDB financial data, and Oscar nomination/winner data into a cleaned dataset for exploratory analysis.

## Research Questions

1. Does a bigger budget produce more revenue?
2. Do Oscar-winning movies receive higher ratings?
3. Which genres generate the highest revenue?
4. Does movie runtime influence ratings?
5. Which directors consistently produce successful movies?

## Main Findings

- Higher budgets are associated with higher median revenue, but budget alone does not guarantee strong ROI.
- Oscar-winning movies tend to have higher ratings than non-winning movies.
- Adventure, Animation, Fantasy, and Sci-Fi perform strongly by median revenue.
- Runtime has a weak positive relationship with rating.
- Some Oscar-recognised directors combine repeated nominations with strong revenue performance.

## Data Sources

The notebook uses four raw data files:

- `title_basics.tsv` - IMDb title basics, including title, year, runtime, and genres.
- `title.ratings.tsv` - IMDb average ratings and vote counts.
- `TMDB_movie_dataset_v11.csv` - TMDB movie metadata, budget, revenue, runtime, and genres.
- `full_data.csv` - Oscar nominations and winners, with IMDb IDs used as join keys.

Join keys:

- IMDb `tconst`
- TMDB `imdb_id`
- Oscar `FilmId`

## Project Structure

```text
sql_movies_project/
|-- README.md
|-- eda.ipynb
|-- full_data.csv
|-- ERD.mwb
|-- .gitignore
`-- output/
    |-- movies_base.csv
    |-- ratings.csv
    |-- oscars_2.csv
    `-- tmdb.csv
```

## Notebook Workflow

The main notebook is `eda.ipynb`.

It performs the following steps:

1. Loads raw IMDb, TMDB, and Oscar datasets.
2. Cleans text fields by removing accents, quotes, and embedded line breaks.
3. Exports cleaned CSV files into `output/`.
4. Joins movies, ratings, TMDB financials, and Oscar data.
5. Builds visual and statistical analysis for each research question.
6. Summarises the project conclusions and limitations.

## How to Run

Install the Python dependencies:

pip install pandas numpy matplotlib seaborn jupyter


Place the raw data files in the project folder:


title_basics.tsv
title.ratings.tsv
TMDB_movie_dataset_v11.csv
full_data.csv

Then open and run:

jupyter notebook eda.ipynb

The notebook writes cleaned intermediate files to `output/`.

## Output Files

- `output/movies_base.csv` - cleaned IMDb movie basics.
- `output/ratings.csv` - cleaned IMDb ratings.
- `output/oscars_2.csv` - cleaned Oscar data.
- `output/tmdb.csv` - cleaned TMDB data.

## Caveats

- TMDB often records missing budgets or revenues as `0`; these are treated as missing values.
- The director analysis focuses on Oscar-recognised directors, so it is not a full industry-wide director ranking.
- Some ratings and voting metrics come from TMDB rather than IMDb depending on the analysis step.
- Large raw datasets are not ideal for GitHub and may need to be downloaded separately.

## Tools Used

- Python
- pandas
- NumPy
- Matplotlib
- Seaborn
- Jupyter Notebook
