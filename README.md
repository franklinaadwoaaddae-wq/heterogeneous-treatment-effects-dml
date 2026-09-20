# Who Benefits from Product Changes?

### Estimating Heterogeneous Treatment Effects in Digital Experiments Using Double Machine Learning

**Franklina Addae**  
Summer 2026 Research Project  
University of Northern Colorado

---

## Overview

Traditional A/B testing typically focuses on average treatment effects, but an intervention that works well on average may not affect all users equally.

This project investigates heterogeneous treatment effects in digital experiments using a simulated A/B testing environment. The analysis compares traditional treatment-effect estimation methods with Double Machine Learning (DML) to examine not only whether a product intervention improves user engagement, but also which users benefit most.

## Research Question

**How can causal machine learning methods identify differences in treatment response across users that may be hidden by traditional average treatment effects?**

## Methods

A simulated randomized experiment with **5,000 users** was created to represent a digital platform testing a new product feature.

The analysis compares three approaches:

- Traditional A/B testing using difference in means
- Regression adjustment
- Double Machine Learning (DML)

Double Machine Learning was implemented using random forest learners and five-fold cross-fitting.

Treatment-effect heterogeneity was examined across users with different levels of prior engagement.

## Key Results

The three methods produced similar estimates of the average treatment effect:

| Method | Estimated Treatment Effect |
|---|---:|
| A/B Test | 4.41 |
| Regression Adjustment | 4.81 |
| Double Machine Learning | 4.83 |

However, the analysis revealed substantial heterogeneity across users.

| Prior Engagement Group | Mean Treatment Effect |
|---|---:|
| Lowest Quartile | 3.71 |
| Quartile 2 | 4.53 |
| Quartile 3 | 5.14 |
| Highest Quartile | 6.01 |

Users with higher prior engagement experienced larger benefits from the product intervention. This demonstrates how relying only on an average treatment effect can conceal meaningful differences in user response.

## Tools and Methods

**R · DoubleML · Random Forests · Causal Inference · A/B Testing · Heterogeneous Treatment Effects · Data Simulation · Data Visualization**

## Repository Structure

heterogeneous-treatment-effects-dml/
├── R/
│   ├── README.md
│   └── heterogeneous-treatment-effects-dml.R
├── figures/
│   ├── README.md
│   ├── figure-1-treatment-effect-distribution.png
│   ├── figure-2-treatment-effects-prior-engagement.png
│   ├── figure-3-average-effect-by-engagement-group.png
│   └── figure-4-true-vs-estimated-effects.png
├── paper/
│   ├── README.md
│   └── heterogeneous-treatment-effects-dml.pdf
├── .gitignore
└── README.md
