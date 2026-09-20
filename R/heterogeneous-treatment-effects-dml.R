# ============================================================
# Who Benefits from Product Changes?
# Estimating Heterogeneous Treatment Effects in Digital
# Experiments Using Double Machine Learning
#
# Franklina Addae
# Summer 2026 Research Project
# ============================================================


# ============================================================
# 1. Setup
# ============================================================

rm(list = ls())

set.seed(123)

library(data.table)
library(dplyr)
library(ggplot2)
library(tidyr)
library(DoubleML)
library(mlr3)
library(mlr3learners)


# ============================================================
# 2. Simulate A/B Experiment
# ============================================================

n <- 5000

age <- rnorm(
  n,
  mean = 35,
  sd = 10
)

prior_engagement <- rnorm(
  n,
  mean = 50,
  sd = 15
)

subscribed <- rbinom(
  n,
  size = 1,
  prob = 0.35
)

mobile_user <- rbinom(
  n,
  size = 1,
  prob = 0.60
)

treatment <- rbinom(
  n,
  size = 1,
  prob = 0.50
)


# ============================================================
# 3. Define Heterogeneous Treatment Effects
# ============================================================

true_tau <- 2 +
  0.06 * prior_engagement +
  1.5 * subscribed -
  0.02 * age


# ============================================================
# 4. Generate Baseline Engagement
# ============================================================

baseline <- 20 +
  0.40 * prior_engagement +
  3 * subscribed +
  2 * mobile_user -
  0.05 * age


# ============================================================
# 5. Generate Observed Outcome
# ============================================================

engagement <- baseline +
  true_tau * treatment +
  rnorm(n, mean = 0, sd = 5)


# ============================================================
# 6. Create Analysis Dataset
# ============================================================

data <- data.frame(
  age,
  prior_engagement,
  subscribed,
  mobile_user,
  treatment,
  true_tau,
  engagement
)

head(data)


# ============================================================
# 7. Descriptive Statistics
# ============================================================

summary(data)

data %>%
  summarise(
    across(
      c(
        age,
        prior_engagement,
        subscribed,
        mobile_user,
        treatment,
        true_tau,
        engagement
      ),
      list(
        Mean = mean,
        SD = sd,
        Min = min,
        Max = max
      )
    )
  )


# ============================================================
# 8. Traditional A/B Test
# ============================================================

mean_treated <- mean(
  data$engagement[data$treatment == 1]
)

mean_control <- mean(
  data$engagement[data$treatment == 0]
)

ate_ab <- mean_treated - mean_control

ate_ab


# ============================================================
# 9. Regression Adjustment
# ============================================================

reg_model <- lm(
  engagement ~
    treatment +
    age +
    prior_engagement +
    subscribed +
    mobile_user,
  data = data
)

summary(reg_model)

coef(reg_model)["treatment"]


# ============================================================
# 10. Double Machine Learning
# ============================================================

data <- as.data.table(data)

dml_data <- DoubleMLData$new(
  data = data,
  y_col = "engagement",
  d_cols = "treatment",
  x_cols = c(
    "age",
    "prior_engagement",
    "subscribed",
    "mobile_user"
  )
)

ml_g <- lrn(
  "regr.ranger",
  num.trees = 500
)

ml_m <- lrn(
  "classif.ranger",
  num.trees = 500,
  predict_type = "prob"
)

dml_irm <- DoubleMLIRM$new(
  data = dml_data,
  ml_g = ml_g,
  ml_m = ml_m,
  n_folds = 5
)

dml_irm$fit()

dml_irm$summary()


# ============================================================
# 11. Distribution of True Heterogeneous Treatment Effects
# ============================================================

ggplot(
  data,
  aes(x = true_tau)
) +
  geom_histogram(
    bins = 40
  ) +
  labs(
    title = "Distribution of True Heterogeneous Treatment Effects",
    x = "Treatment Effect",
    y = "Frequency"
  ) +
  theme_minimal()


# ============================================================
# 12. Treatment Effects by Prior Engagement
# ============================================================

ggplot(
  data,
  aes(
    x = prior_engagement,
    y = true_tau
  )
) +
  geom_point(
    alpha = 0.25
  ) +
  geom_smooth(
    method = "lm",
    se = FALSE
  ) +
  labs(
    title = "Treatment Effects by Prior Engagement Level",
    x = "Prior Engagement",
    y = "Treatment Effect"
  ) +
  theme_minimal()


# ============================================================
# 13. Prior Engagement Quartiles
# ============================================================

data <- data %>%
  mutate(
    engagement_group = ntile(
      prior_engagement,
      4
    )
  )


# ============================================================
# 14. True Treatment Effects by Engagement Group
# ============================================================

true_group_effects <- data %>%
  group_by(engagement_group) %>%
  summarise(
    mean_prior_engagement = mean(prior_engagement),
    true_effect = mean(true_tau),
    .groups = "drop"
  )

true_group_effects


# ============================================================
# 15. Average Treatment Effect by Engagement Group
# ============================================================

ggplot(
  true_group_effects,
  aes(
    x = engagement_group,
    y = true_effect
  )
) +
  geom_point(
    size = 3
  ) +
  geom_line() +
  scale_x_continuous(
    breaks = 1:4
  ) +
  labs(
    title = "Average Treatment Effect by Prior Engagement Group",
    x = "Engagement Group",
    y = "Average Treatment Effect"
  ) +
  theme_minimal()


# ============================================================
# 16. Estimate Treatment Effects Within Engagement Groups
# ============================================================

estimated_group_effects <- data %>%
  group_by(engagement_group) %>%
  summarise(
    estimated_effect =
      mean(engagement[treatment == 1]) -
      mean(engagement[treatment == 0]),
    .groups = "drop"
  )

estimated_group_effects


# ============================================================
# 17. Recovery Analysis
# ============================================================

recovery_results <- true_group_effects %>%
  left_join(
    estimated_group_effects,
    by = "engagement_group"
  ) %>%
  mutate(
    absolute_error = abs(
      true_effect - estimated_effect
    )
  )

recovery_results


# ============================================================
# 18. True vs Estimated Treatment Effects
# ============================================================

recovery_long <- recovery_results %>%
  select(
    engagement_group,
    true_effect,
    estimated_effect
  ) %>%
  pivot_longer(
    cols = c(
      true_effect,
      estimated_effect
    ),
    names_to = "effect_type",
    values_to = "treatment_effect"
  )

ggplot(
  recovery_long,
  aes(
    x = engagement_group,
    y = treatment_effect,
    group = effect_type,
    linetype = effect_type
  )
) +
  geom_point(
    size = 3
  ) +
  geom_line() +
  scale_x_continuous(
    breaks = 1:4
  ) +
  labs(
    title = "True versus Estimated Treatment Effects Across Engagement Groups",
    x = "Engagement Group",
    y = "Treatment Effect",
    linetype = "Effect"
  ) +
  theme_minimal()


# ============================================================
# 19. Final Treatment Effect Comparison
# ============================================================

results <- data.frame(
  Method = c(
    "A/B Test",
    "Regression Adjustment",
    "Double Machine Learning"
  ),
  Estimate = c(
    ate_ab,
    coef(reg_model)["treatment"],
    dml_irm$coef
  )
)

results


# ============================================================
# End of Analysis
# ============================================================
