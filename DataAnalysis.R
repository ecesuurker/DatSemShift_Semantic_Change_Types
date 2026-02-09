library(tidyr)
library(dplyr)
library(ggplot2)
library(reshape2)
library(forcats)
library(patchwork)

rm(list = ls())

setwd("~/Desktop/Internship/DatSemShift")

data <- read.csv('Annotations/FinalData.csv')

data <- data[c('ID', 'Language_1', 'Lexemes_1', 'Meanings_1', 'PoS_1',
               'Direction', 'Languages_2', 'Lexemes_2', 'Meanings_2', 
               'PoS_2', 'Confidence', 'Extension', 'Connotation', 'Emotive.Value', 
               'Frame')]

head(data,5)

change_cols <- c("Extension", "Emotive.Value", "Frame")

#Frequency Graph

long_data <- data %>%
  pivot_longer(cols = all_of(change_cols),
               names_to = "ChangeCategory",
               values_to = "ChangeType") %>%
  filter(!is.na(ChangeType), trimws(ChangeType) != "")

type_order <- long_data %>%
  count(ChangeType, sort = TRUE) %>%
  pull(ChangeType)

long_data <- long_data %>%
  mutate(ChangeType = factor(ChangeType, levels = type_order))

percent_data <- long_data %>%
  group_by(ChangeCategory, ChangeType) %>%
  summarise(Freq = n(), .groups = "drop") %>%
  mutate(Percent = 100 * Freq / sum(Freq))  # overall percentages

p1 <- ggplot(percent_data, aes(x = ChangeType, y = Percent, fill = ChangeType)) +
  geom_col(position = position_dodge(width = 0.8), color = "black") +
  geom_text(aes(label = Freq),
            position = position_dodge(width = 0.8),
            vjust = -0.5, size = 3, color = "black") +
  facet_wrap(~ChangeCategory, scales = "free_x") +
  labs(title = "A: Overall Percentage of \n Semantic Change Types",
       x = "Semantic Change Type",
       y = "Percentage (%)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none",
        plot.title = element_text(size = 25, hjust = 0.5))

#Heatmap

binary_data <- data %>%
  mutate(across(c(Extension, Emotive.Value, Frame),
                ~ ifelse(trimws(.) != "" & !is.na(.), 1, 0)))

co_matrix <- t(binary_data[, c("Extension", "Emotive.Value", "Frame")]) %*%
  as.matrix(binary_data[, c("Extension", "Emotive.Value", "Frame")])

co_long <- melt(co_matrix)

p4 <- ggplot(co_long, aes(x = Var1, y = forcats::fct_rev(Var2), fill = value)) +
  geom_tile(color = "white") +
  geom_text(aes(label = value), color = "black", size = 5) +
  scale_fill_gradient(low = "white", high = "red") +
  labs(title = "D: Co-occurrence of \n Semantic Change Types",
       x = "Semantic Change Categories",
       y = "Semantic Change Categories",
       fill = "Count") +
  theme_minimal() +
  theme(plot.title = element_text(size = 25, hjust=0.5))

#Relative PoS Frequency Change Type

long_data_both <- data %>%
  pivot_longer(cols = all_of(change_cols),
               names_to = "ChangeCategory",
               values_to = "ChangeType") %>%
  filter(!is.na(ChangeType), trimws(ChangeType) != "") %>%
  pivot_longer(cols = c(PoS_1, PoS_2),
               names_to = "PoSColumn",
               values_to = "PoS") %>%
  filter(!is.na(PoS), trimws(PoS) != "")

pos_percentages <- long_data_both %>%
  group_by(ChangeType, PoSColumn, PoS) %>%
  summarise(Freq = n(), .groups = "drop") %>%
  group_by(ChangeType, PoSColumn) %>%
  mutate(Percent = 100 * Freq / sum(Freq))

p5 <- ggplot(pos_percentages, aes(x = ChangeType, y = Percent, fill = PoS)) +
  geom_col(position = "stack", color = "white") +
  geom_text(
    aes(label = Freq),
    position = position_stack(vjust = 0.5),
    size = 3,
    color = "black",
    fontface = "bold"
  ) +
  facet_wrap(~PoSColumn) +
  labs(title = "E: Prevalence of \n PoS per Change Type",
       x = "Semantic Change Type",
       y = "Percentage (%)",
       fill = "Part of Speech") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "none",                     # ✅ remove legend
    plot.title = element_text(size = 25, hjust = 0.5)
  )


#Relative PoS Change Category

pos_percentages <- long_data_both %>%
  group_by(ChangeCategory, PoSColumn, PoS) %>%
  summarise(Freq = n(), .groups = "drop") %>%
  group_by(ChangeCategory, PoSColumn) %>%
  mutate(Percent = 100 * Freq / sum(Freq))

p6 <- ggplot(pos_percentages, aes(x = ChangeCategory, y = Percent, fill = PoS)) +
  geom_col(position = "stack", color = "white") +
  geom_text(
    aes(label = Freq),
    position = position_stack(vjust = 0.5),
    size = 3,
    color = "black",
    fontface = "bold"
  ) +
  facet_wrap(~PoSColumn) +
  labs(title = "F: Prevalence of PoS \n per Change Category",
       x = "Semantic Change Category",
       y = "Percentage (%)",
       fill = "Part of Speech") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(size = 25, hjust=0.5))


#PoS Change

long_data_pos_change <- data %>%
  pivot_longer(cols = all_of(change_cols),
               names_to = "ChangeCategory",
               values_to = "ChangeType") %>%
  filter(!is.na(ChangeType), trimws(ChangeType) != "") %>%
  mutate(
    PoS_change = ifelse(PoS_1 != PoS_2, "Different PoS", "Same PoS"),
    ChangeType = factor(ChangeType, levels = type_order)  # enforce consistent order
  )

percent_data_pos <- long_data_pos_change %>%
  group_by(PoS_change, ChangeCategory, ChangeType) %>%
  summarise(Freq = n(), .groups = "drop") %>%
  group_by(PoS_change) %>%
  mutate(Percent = 100 * Freq / sum(Freq))

# --- Step 5: Plot 2 — Different PoS ---
different_pos_data <- percent_data_pos %>% filter(PoS_change == "Different PoS")

p2 <- ggplot(different_pos_data, aes(x = ChangeType, y = Percent, fill = ChangeType)) +
  geom_col(position = position_dodge(width = 0.8), color = "black") +
  geom_text(aes(label = Freq),
            position = position_dodge(width = 0.8),
            vjust = -0.5, size = 3, color = "black") +
  facet_wrap(~ChangeCategory, scales = "free_x") +   # same structure as Plot A
  labs(title = "B: Change in \n Part of Speech",
       x = "Semantic Change Type",
       y = "Percentage (%)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none",                    # same as Plot A
        plot.title = element_text(size = 25, hjust = 0.5))

# --- Step 6: Plot 3 — Same PoS ---
same_pos_data <- percent_data_pos %>% filter(PoS_change == "Same PoS")

# --- Step 6 (Revised): Plot C — No Change in Part of Speech ---
p3 <- ggplot(same_pos_data, aes(x = ChangeType, y = Percent, fill = ChangeType)) +
  geom_col(position = position_dodge(width = 0.8), color = "black") +
  geom_text(aes(label = Freq),
            position = position_dodge(width = 0.8),
            vjust = -0.5, size = 3, color = "black") +
  facet_wrap(~ChangeCategory, scales = "free_x") +
  labs(title = "C: No Change in \n Part of Speech",
       x = "Semantic Change Type",
       y = "Percentage (%)",
       fill = "Change Type") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "right",                    # ✅ legend on the right
    legend.title = element_text(size = 11, face = "bold"),
    legend.text = element_text(size = 10),
    plot.title = element_text(size = 25, hjust = 0.5)
  )


pdf("overall.pdf", width = 12, height = 8)
(p1 | p2 | p3) /
  (p4 | p5 | p6)
dev.off()
