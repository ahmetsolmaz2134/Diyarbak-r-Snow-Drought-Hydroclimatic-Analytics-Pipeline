# ❄️💧 Diyarbakır Snow Drought & Hydroclimatic Analytics Pipeline

[![R Version](https://img.shields.io/badge/R-%3E%3D_4.2.0-blue?logo=r&logoColor=white)](https://www.r-project.org/)
[![Data Source](https://img.shields.io/badge/Data-NASA_POWER-orange)](https://power.larc.nasa.gov/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Status](https://img.shields.io/badge/Status-Active_Research-success)]()

An advanced, station-free R pipeline designed to model **Snow Drought** and hydroclimatic anomalies for the **Diyarbakır region and upper basin catchments**, utilizing meteorological time series data extracted directly from the **NASA POWER API**. 

This repository provides fully reproducible scripts to isolate solid precipitation (snowfall), track seasonal snow accumulation (Snow Water Equivalent proxy), and analyze inter-annual snow drought severities without requiring ground sensor networks or heavy raster datasets.

---

## 🎯 Key Scientific Framework

* **Automated Data Retrieval:** Fetches multi-decadal daily gridded meteorological variables ($T_{max}$, $T_{min}$, $T_{mean}$, and Precipitation) for target coordinates in the Diyarbakır upper basin.
* **Rain-Snow Partitioning:** Applies temperature-index thresholds to separate total daily precipitation into liquid (rainfall) and solid (snowfall) components.
* **Snow Accumulation & Melt Modeling:** Computes seasonal Snow Water Equivalent (SWE) dynamics using a temperature index (degree-day) approach.
* **Snow Drought Indexing:** Evaluates seasonal peak snow anomalies, deficit persistence, and dry-winter periods over multi-decadal time spans.
* **Non-Parametric Trend Testing:** Runs Mann-Kendall trend tests and Sen's Slope estimators to detect monotonic changes in regional snow regimes.

---

## 📂 Repository Structure

```text
├── data/                  # Downloaded raw CSV data (diyarbakir_daily_meteo.csv)
├── R/                     
│   ├── 01_fetch_data.R    # NASA POWER API meteorological data downloader
│   ├── 02_snow_model.R    # Rain-snow separation & cumulative SWE modeling
│   ├── 03_drought_stats.R # Snow drought anomaly calculations & Mann-Kendall tests
│   └── 04_visualize.R     # Publication-ready ggplot2 time-series & anomaly plots
├── outputs/               # Rendered analytical graphs and statistical tables
└── README.md              # Project documentation
