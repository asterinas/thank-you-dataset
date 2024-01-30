# The Thank You Dataset

This project automatically generates
and maintains a list of Asterinas contributors,
ranked by their contribution scores,
for display on the Thank You page of the official website.

This project includes datasets
for contributions during different periods of time.

* [`dataset/all_time.json`](dataset/all_time.json)
* [`dataset/last_year.json` ](dataset/last_year.json)
* [`dataset/last_6_months.json`](dataset/last_6_months.json)
* [`dataset/last_3_months.json`](dataset/last_3_months.json)
* [`dataset/last_month.json`](dataset/last_month.json)

The dataset is generated by the [`gen_dataset.sh`](gen_dataset.sh) script.
The script is called into action by a Github Action,
which runs at scheduled intervals
to ensure that the "Thank You" page
reflects the most up-to-date results.

The script is powered by the [score-and-rank-contributors](https://github.com/asterinas/score-and-rank-contributors) tool.
