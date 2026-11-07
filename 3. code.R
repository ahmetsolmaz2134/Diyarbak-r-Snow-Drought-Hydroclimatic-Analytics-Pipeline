# =====================================================================
# Project: Diyarbakir-Snow-Drought-Pipeline
# Script: 04_rain_to_snow_ratio.R
# Description: Rain-to-Snow Ratio (RSR), Winter Thermal Trends, and 
#              Hydrological Transition Analysis.
# =====================================================================

library(tidyverse)
library(lubridate)
library(trend)
library(ggplot2)
library(scales)

# 1. Veriyi Oku ve Haz??rla
if (!file.exists("data/diyarbakir_daily_meteo.csv")) {
  stop("HATA: 'data/diyarbakir_daily_meteo.csv' bulunamad??!")
}

df <- read_csv("data/diyarbakir_daily_meteo.csv", show_col_types = FALSE)

# Kar/Ya??mur ayr??m?? ve hidrolojik y??l hesaplamas??
df_processed <- df %>%
  mutate(
    Month = month(Date),
    WaterYear = ifelse(Month >= 10, YEAR + 1, YEAR),
    Snowfall = ifelse(Tmean <= 0.0, Precip, 0.0),
    Rainfall = ifelse(Tmean > 0.0, Precip, 0.0)
  )

# K???? Sezonu (Kas??m - Nisan) Analizleri
annual_ratio_summary <- df_processed %>%
  filter(Month %in% c(11, 12, 1, 2, 3, 4)) %>%
  group_by(WaterYear) %>%
  summarise(
    Total_Snow = sum(Snowfall, na.rm = TRUE),
    Total_Rain = sum(Rainfall, na.rm = TRUE),
    Total_Precip = sum(Precip, na.rm = TRUE),
    Mean_Winter_Temp = mean(Tmean, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(WaterYear >= min(WaterYear) + 1 & WaterYear <= max(WaterYear) - 1) %>%
  mutate(
    # Kar Oran?? Y??zdesi (Solid Precipitation Ratio)
    Snow_Ratio_Pct = (Total_Snow / Total_Precip) * 100
  )

# =====================================================================
# 2. ??STAT??ST??KSEL TREND TEST?? (KAR ORANI ??????N)
# =====================================================================
ratio_mk <- mk.test(annual_ratio_summary$Snow_Ratio_Pct)
ratio_sens <- sens.slope(annual_ratio_summary$Snow_Ratio_Pct)

cat("\n=========================================================\n")
cat(" RAIN-TO-SNOW RATIO TREND ANALYSIS (Mann-Kendall)\n")
cat("=========================================================\n")
print(ratio_mk)
print(ratio_sens)
cat("=========================================================\n\n")

if (!dir.exists("outputs")) dir.create("outputs", recursive = TRUE)

# =====================================================================
# 3. AKADEM??K G??RSELLE??T??RME: KAR ORANI (%) DE????????M?? VE SICAKLIK
# =====================================================================
p_ratio <- ggplot(annual_ratio_summary, aes(x = WaterYear, y = Snow_Ratio_Pct)) +
  geom_line(color = "#08519c", linewidth = 1) +
  geom_point(aes(color = Mean_Winter_Temp), size = 3) +
  scale_color_viridis_c(option = "plasma", name = "Mean Winter\nTemp (??C)") +
  geom_smooth(method = "lm", formula = y ~ x, color = "darkred", linetype = "dashed", linewidth = 0.8, se = TRUE, alpha = 0.2) +
  labs(
    title = "Winter Solid Precipitation Ratio (Snow vs. Total Precip) - Diyarbak??r",
    subtitle = sprintf("Mann-Kendall Trend p-value: %.4f | Sen's Slope: %.3f %%/year", ratio_mk$p.value, ratio_sens$estimates),
    x = "Hydrological Year",
    y = "Snowfall Percentage of Total Winter Precip (%)",
    caption = "Data Source: NASA POWER API | Hydroclimatology Research Pipeline"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    plot.subtitle = element_text(color = "gray40", size = 10),
    panel.grid.minor = element_blank(),
    axis.text = element_text(color = "black"),
    legend.position = "right"
  )

print(p_ratio)
ggsave("outputs/diyarbakir_rain_to_snow_ratio.png", plot = p_ratio, width = 11, height = 5, dpi = 300)

cat(">> BA??ARILI! Kar/Ya??mur oran de??i??imi ve termal ge??i?? analizi tamamland??, grafik 'outputs/' klas??r??ne kaydedildi abim!\n")