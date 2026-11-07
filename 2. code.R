# =====================================================================
# Project: Diyarbakir-Snow-Drought-Pipeline
# Script: 03_advanced_snow_drought.R (Hatas??z S??r??m)
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

# Kar ayr??m?? ve hidrolojik y??l (Kas??m - Nisan k???? d??nemi)
df_processed <- df %>%
  mutate(
    Month = month(Date),
    WaterYear = ifelse(Month >= 10, YEAR + 1, YEAR),
    Snowfall = ifelse(Tmean <= 0.0, Precip, 0.0)
  )

annual_snow_summary <- df_processed %>%
  filter(Month %in% c(11, 12, 1, 2, 3, 4)) %>%
  group_by(WaterYear) %>%
  summarise(
    Total_Snow_Precip = sum(Snowfall, na.rm = TRUE),
    Mean_Winter_Tmean = mean(Tmean, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(WaterYear >= min(WaterYear) + 1 & WaterYear <= max(WaterYear) - 1)

# =====================================================================
# 2. PETTITT CHANGE-POINT TEST
# =====================================================================
pettitt_result <- pettitt.test(annual_snow_summary$Total_Snow_Precip)

cat("\n=========================================================\n")
cat(" PETTITT CHANGE-POINT TEST RESULTS (Kar Rejimi K??r??lma Y??l??)\n")
cat("=========================================================\n")
print(pettitt_result)

change_point_index <- pettitt_result$estimate
change_point_year <- annual_snow_summary$WaterYear[change_point_index]
cat(sprintf(">> K??r??lma Y??l?? (Change-Point Year): %d\n", change_point_year))
cat("=========================================================\n\n")

# =====================================================================
# 3. STANDARDIZE ED??LM???? KAR KURAKLI??I ??NDEKS?? (SSWEI)
# =====================================================================
mean_val <- mean(annual_snow_summary$Total_Snow_Precip, na.rm = TRUE)
sd_val   <- sd(annual_snow_summary$Total_Snow_Precip, na.rm = TRUE)

annual_snow_summary <- annual_snow_summary %>%
  mutate(
    SSWEI = (Total_Snow_Precip - mean_val) / sd_val,
    Drought_Category = case_when(
      SSWEI <= -1.5 ~ "Extreme Snow Drought",
      SSWEI <= -1.0 ~ "Severe Snow Drought",
      SSWEI <= -0.5 ~ "Moderate Snow Drought",
      TRUE          ~ "Normal / Wet"
    )
  )

if (!dir.exists("outputs")) dir.create("outputs", recursive = TRUE)

# =====================================================================
# 4. AKADEM??K G??RSELLE??T??RME
# =====================================================================
p_sswei <- ggplot(annual_snow_summary, aes(x = WaterYear, y = SSWEI, fill = SSWEI < 0)) +
  geom_col(width = 0.75, alpha = 0.9, show.legend = FALSE) +
  scale_fill_manual(values = c("#2b8cbe", "#de2d26")) +
  geom_hline(yintercept = -1.0, linetype = "dashed", color = "darkred", linewidth = 0.8) +
  geom_hline(yintercept = 0.0, linetype = "solid", color = "gray50", linewidth = 0.5) +
  labs(
    title = "Standardized Snow Water Equivalent Index (SSWEI) - Diyarbak??r",
    subtitle = sprintf("Pettitt Change-Point identified at Water Year %d (p-value: %.4f)", 
                       change_point_year, pettitt_result$p.value),
    x = "Hydrological Year",
    y = "SSWEI (Standardized Anomaly)",
    caption = "Data Source: NASA POWER API | Hydroclimatology Research Pipeline"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    plot.subtitle = element_text(color = "gray40", size = 10),
    panel.grid.minor = element_blank(),
    axis.text = element_text(color = "black")
  )

print(p_sswei)
ggsave("outputs/diyarbakir_advanced_sswei_analysis.png", plot = p_sswei, width = 11, height = 5, dpi = 300)

cat(">> BA??ARILI! Geli??mi?? SSWEI analizi ve Pettitt test grafi??i 'outputs/' klas??r??ne kaydedildi abim!\n")