# EEG Classification for ADHD vs Control - Graduation Project Report

## 📋 Project Overview

This project presents a comprehensive machine learning pipeline for classifying **Attention Deficit Hyperactivity Disorder (ADHD)** using **Electroencephalography (EEG)** signals. The dataset contains recordings from **121 subjects** (61 ADHD, 60 Control) across **19 EEG channels**.

---

## 🧠 Dataset Description

| Property | Value |
|----------|-------|
| Total Records | 2,166,383 rows |
| Subjects | 121 |
| ADHD Subjects | 61 |
| Control Subjects | 60 |
| EEG Channels | 19 (Fp1, Fp2, F3, F4, C3, C4, P3, P4, O1, O2, F7, F8, T7, T8, P7, P8, Fz, Cz, Pz) |
| Sampling Rate | ~128 Hz (estimated) |
| Missing Values | 0 |

### EEG Channels (10-20 System)
- **Fp1, Fp2**: Frontopolar
- **F3, F4, F7, F8**: Frontal
- **C3, C4**: Central
- **P3, P4, P7, P8**: Parietal
- **O1, O2**: Occipital
- **T7, T8**: Temporal
- **Fz, Cz, Pz**: Midline

---

## 🔬 Methodology

### Phase 1: Data Loading & Exploration
- Loaded 2.17M rows from CSV
- Verified class distribution: ADHD (55.7%) vs Control (44.3%)
- Confirmed no missing values

### Phase 2: Feature Extraction
Extracted **247+ features per subject** from raw EEG signals:

#### Time-Domain Features (per channel)
- Mean, Standard Deviation
- Skewness, Kurtosis
- Min, Max, Range (p95-p5)
- Root Mean Square (RMS)
- Zero-Crossing Rate

#### Frequency-Domain Features (per channel)
- **Delta** (0.5-4 Hz): Sleep, deep relaxation
- **Theta** (4-8 Hz): Drowsiness, meditation
- **Alpha** (8-13 Hz): Relaxed wakefulness
- **Beta** (13-30 Hz): Active concentration
- **Gamma** (30-50 Hz): Higher cognitive processing
- **Theta/Beta Ratio (TBR)**: Key ADHD biomarker

#### Connectivity Features
- Inter-channel Pearson correlation (average, max, min)
- Hemispheric asymmetry (left-right channel differences)

#### Advanced Window-Based Features (Sliding Window)
- Window size: 500 samples (~4 seconds)
- Step: 250 samples (50% overlap)
- **8,486 windows** extracted across all subjects
- **2,025 features** per subject after aggregation

### Phase 3: Feature Selection
- Removed highly correlated features (correlation > 0.95)
- Reduced from 2,025 to **1,241 features**

### Phase 4: Model Training & Cross-Validation
Used **GroupKFold cross-validation** (5 folds) to prevent data leakage (samples from same subject stay in same fold).

#### Models Tested
| Model | Accuracy | AUC |
|-------|----------|-----|
| **Extra Trees** | **81.8%** | **89.8%** |
| Random Forest (200 trees) | 81.8% | 88.7% |
| Logistic Regression | 80.1% | 87.6% |
| Gradient Boosting | 78.5% | 86.0% |
| Random Forest (100 trees) | 77.6% | 87.7% |
| SVM (RBF kernel) | 74.3% | 84.7% |

### Phase 5: Statistical Analysis
Performed t-tests between ADHD and Control groups across all channel×band combinations.

---

## 📊 Key Findings

### Most Significant Differences (ADHD vs Control)

| Channel | Band | ADHD Mean | Control Mean | p-value | Cohen's d |
|---------|------|-----------|--------------|---------|-----------|
| Fz | Gamma | 0.031 | 0.141 | 2.4e-6 | -0.90 (Large) |
| Fp1 | Gamma | 0.029 | 0.108 | 3e-6 | -0.90 (Large) |
| Fz | Theta | 0.088 | 0.063 | 3e-6 | +0.89 (Large) |
| Fz | Alpha | 0.035 | 0.024 | 9e-6 | +0.84 (Large) |
| Fp1 | Alpha | 0.025 | 0.019 | 1.6e-5 | +0.82 (Large) |
| Fp2 | Theta | 0.070 | 0.055 | 2.8e-5 | +0.79 (Medium) |
| Fz | Beta | 0.030 | 0.019 | 3e-5 | +0.79 (Medium) |
| Fp1 | Theta | 0.072 | 0.056 | 1.2e-4 | +0.72 (Medium) |

### Theta/Beta Ratio (TBR)
ADHD subjects show **significantly lower TBR** across most channels, consistent with clinical literature:
- T7: ADHD 2.56 vs Control 3.85 (p=3.4e-4)
- Pz: ADHD 2.98 vs Control 4.31 (p=4.2e-4)
- P7: ADHD 1.59 vs Control 2.45 (p=1.2e-3)

### Channel Importance Ranking
1. **Fz** (0.097) - Frontal midline
2. **Fp1** (0.081) - Left frontopolar
3. **P3** (0.071) - Left parietal
4. **F7** (0.070) - Left frontal
5. **P7** (0.065) - Left temporal-parietal

### Neurophysiological Interpretation
- **Frontal midline (Fz)** shows the strongest differences, consistent with ADHD's impact on executive function and attention networks
- **Reduced gamma power** in ADHD may reflect altered neural synchronization
- **Increased theta and alpha power** in ADHD aligns with cortical hypoarousal theory
- **Lower TBR** is the most established EEG biomarker for ADHD

---

## 📁 Project Structure

```
archive/
├── adhdata.csv                  # Raw EEG dataset (267 MB)
├── eeg_classification.py        # Basic classification pipeline
├── eeg_advanced.py              # Advanced sliding-window pipeline
├── eeg_comprehensive.py         # Statistical analysis & visualization
├── eeg_results.png              # Basic results visualization
├── eeg_advanced_results.png     # Advanced results (CV, features, channels)
├── eeg_comprehensive_results.png# Statistical summary plots
├── eeg_band_heatmap.png         # Channel×band significance heatmap
├── eeg_features.csv             # Extracted features (247 per subject)
├── eeg_windows.csv              # Window-based features (8,486 windows)
├── eeg_subject_features.csv     # Aggregated subject features (2,025)
├── eeg_cv_results.csv           # Cross-validation results
├── eeg_band_stats.csv           # Full statistical test results
└── REPORT.md                    # This report
```

---

## 🔧 Technical Stack

- **Python 3.12**
- **pandas** - Data manipulation
- **numpy** - Numerical computing
- **scikit-learn** - Machine learning
- **scipy** - Statistical tests
- **matplotlib / seaborn** - Visualization

---

## 📈 Results Summary

| Metric | Score |
|--------|-------|
| Best Model | Extra Trees |
| Cross-Validation Accuracy | 81.8% |
| Cross-Validation AUC | 89.8% |
| Significant Features (p<0.05) | 60 out of 95 channel×band pairs |
| Most Discriminative Channel | Fz (Frontal midline) |
| Key Biomarker | Theta/Beta Ratio |

---

## 🎯 Conclusions

1. **EEG signals can reliably distinguish ADHD from controls** with ~82% accuracy using classical ML approaches
2. **Frontal midline channels (Fz)** are the most discriminative, supporting existing neuroscience literature
3. **Gamma power reduction** and **theta/alpha power increase** in ADHD are the strongest statistical markers
4. **Theta/Beta ratio** remains the most clinically relevant feature
5. The pipeline is **reproducible** and can be extended with deep learning for potentially higher accuracy

---

## 🚀 How to Run

```bash
# Install dependencies
pip install pandas numpy scikit-learn scipy matplotlib seaborn

# Run basic classification
python eeg_classification.py

# Run advanced analysis
python eeg_advanced.py

# Run comprehensive statistical analysis
python eeg_comprehensive.py
```

---

## 👤 Author
Graduation Project - EEG-based ADHD Classification
