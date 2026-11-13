"""
Comprehensive EEG Analysis for ADHD vs Control
- Detailed statistical comparisons
- Per-channel frequency band analysis
- Feature correlation with diagnosis
- Visualization suite
"""
import pandas as pd
import numpy as np
from scipy import stats
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns
import warnings
warnings.filterwarnings('ignore')

print("="*70)
print("Comprehensive EEG Analysis")
print("="*70)

# Load subject features (has all features before aggressive selection)
df = pd.read_csv('/home/alpha/university/archive/eeg_subject_features.csv')
print(f"Subject features shape: {df.shape}")

# Identify feature columns
eeg_channels = ['Fp1', 'Fp2', 'F3', 'F4', 'C3', 'C4', 'P3', 'P4',
                'O1', 'O2', 'F7', 'F8', 'T7', 'T8', 'P7', 'P8', 'Fz', 'Cz', 'Pz']

y = df['Class'].values
X = df.drop(columns=['ID', 'Class'])

print(f"\n[1] Statistical comparison: ADHD vs Control")
print("-"*50)

# Key frequency features per channel
stat_results = []

for ch in eeg_channels:
    for band in ['delta', 'theta', 'alpha', 'beta', 'gamma']:
        # Find the mean column for this channel and band
        col_name = f'{ch}_{band}_rel_mean'
        if col_name not in X.columns:
            # Try without _mean suffix (first window features)
            col_name = f'{ch}_{band}_rel'
            if col_name not in X.columns:
                continue
        
        adhd_vals = X.loc[y == 1, col_name].dropna()
        control_vals = X.loc[y == 0, col_name].dropna()
        
        if len(adhd_vals) < 3 or len(control_vals) < 3:
            continue
        
        t_stat, p_val = stats.ttest_ind(adhd_vals, control_vals)
        cohen_d = (adhd_vals.mean() - control_vals.mean()) / np.sqrt(
            ((len(adhd_vals)-1)*adhd_vals.std()**2 + (len(control_vals)-1)*control_vals.std()**2) / (len(adhd_vals)+len(control_vals)-2)
        )
        
        stat_results.append({
            'channel': ch,
            'band': band,
            'adhd_mean': adhd_vals.mean(),
            'control_mean': control_vals.mean(),
            'difference': adhd_vals.mean() - control_vals.mean(),
            't_stat': t_stat,
            'p_value': p_val,
            'cohen_d': cohen_d,
            'significant': p_val < 0.05
        })

stat_df = pd.DataFrame(stat_results)

# Show significant results
sig_df = stat_df[stat_df['significant']].sort_values('p_value')
print(f"\nSignificant differences (p < 0.05): {len(sig_df)} out of {len(stat_df)}")
print("\nTop 20 most significant differences:")
print(sig_df.head(20)[['channel', 'band', 'adhd_mean', 'control_mean', 'difference', 't_stat', 'p_value', 'cohen_d']].to_string(index=False))

# Save full stats
stat_df.to_csv('/home/alpha/university/archive/eeg_band_stats.csv', index=False)

# ============================================================
# Per-channel summary
# ============================================================
print(f"\n\n[2] Per-channel band power summary")
print("-"*50)

channel_summary = []
for ch in eeg_channels:
    for band in ['delta', 'theta', 'alpha', 'beta', 'gamma']:
        col_name = f'{ch}_{band}_rel_mean'
        if col_name not in X.columns:
            col_name = f'{ch}_{band}_rel'
            if col_name not in X.columns:
                continue
        
        adhd_vals = X.loc[y == 1, col_name].dropna()
        control_vals = X.loc[y == 0, col_name].dropna()
        
        if len(adhd_vals) < 3 or len(control_vals) < 3:
            continue
        
        t_stat, p_val = stats.ttest_ind(adhd_vals, control_vals)
        channel_summary.append({
            'channel': ch,
            'band': band,
            'adhd_mean': adhd_vals.mean(),
            'control_mean': control_vals.mean(),
            'p_value': p_val,
            'significant': p_val < 0.05
        })

ch_summary_df = pd.DataFrame(channel_summary)

# Pivot for heatmap
heatmap_data = ch_summary_df.pivot(index='channel', columns='band', values='p_value')
# Use -log10(p) for better visualization
heatmap_data = -np.log10(heatmap_data.clip(lower=1e-10))

fig, ax = plt.subplots(figsize=(10, 8))
sns.heatmap(heatmap_data, annot=True, fmt='.2f', cmap='RdBu_r', 
            center=0, ax=ax, cbar_kws={'label': '-log10(p-value)'})
ax.set_title('Statistical Significance by Channel and Frequency Band\n(ADHD vs Control)')
ax.set_xlabel('Frequency Band')
ax.set_ylabel('EEG Channel')
plt.tight_layout()
plt.savefig('/home/alpha/university/archive/eeg_band_heatmap.png', dpi=150, bbox_inches='tight')
print("Band significance heatmap saved")

# ============================================================
# Theta/Beta ratio analysis
# ============================================================
print(f"\n\n[3] Theta/Beta ratio analysis")
print("-"*50)

tb_cols = [c for c in X.columns if 'tb_ratio' in c and 'mean' in c]
if not tb_cols:
    tb_cols = [c for c in X.columns if 'tb_ratio' in c]

print(f"Found {len(tb_cols)} theta/beta ratio features")

tb_stats = []
for col in tb_cols:
    adhd_vals = X.loc[y == 1, col].dropna()
    control_vals = X.loc[y == 0, col].dropna()
    
    if len(adhd_vals) < 3 or len(control_vals) < 3:
        continue
    
    t_stat, p_val = stats.ttest_ind(adhd_vals, control_vals)
    tb_stats.append({
        'feature': col,
        'adhd_mean': adhd_vals.mean(),
        'control_mean': control_vals.mean(),
        'ratio': adhd_vals.mean() / (control_vals.mean() + 1e-10),
        't_stat': t_stat,
        'p_value': p_val,
        'significant': p_val < 0.05
    })

tb_df = pd.DataFrame(tb_stats)
if len(tb_df) > 0:
    print(tb_df.sort_values('p_value').head(10).to_string(index=False))
else:
    print("No theta/beta ratio features found in aggregated data")

# ============================================================
# Hemispheric asymmetry analysis
# ============================================================
print(f"\n\n[4] Hemispheric asymmetry analysis")
print("-"*50)

asym_cols = [c for c in X.columns if 'hemi_asym' in c and 'mean' in c]
if not asym_cols:
    asym_cols = [c for c in X.columns if 'hemi_asym' in c]

print(f"Found {len(asym_cols)} asymmetry features")

asym_stats = []
for col in asym_cols:
    adhd_vals = X.loc[y == 1, col].dropna()
    control_vals = X.loc[y == 0, col].dropna()
    
    if len(adhd_vals) < 3 or len(control_vals) < 3:
        continue
    
    t_stat, p_val = stats.ttest_ind(adhd_vals, control_vals)
    asym_stats.append({
        'feature': col,
        'adhd_mean': adhd_vals.mean(),
        'control_mean': control_vals.mean(),
        'difference': adhd_vals.mean() - control_vals.mean(),
        't_stat': t_stat,
        'p_value': p_val,
        'significant': p_val < 0.05
    })

asym_df = pd.DataFrame(asym_stats)
if len(asym_df) > 0:
    print(asym_df.sort_values('p_value').head(10).to_string(index=False))
else:
    print("No asymmetry features found")

# ============================================================
# Connectivity analysis
# ============================================================
print(f"\n\n[5] Inter-channel connectivity analysis")
print("-"*50)

conn_cols = [c for c in X.columns if 'corr' in c.lower()]
print(f"Found {len(conn_cols)} connectivity features")

conn_stats = []
for col in conn_cols:
    adhd_vals = X.loc[y == 1, col].dropna()
    control_vals = X.loc[y == 0, col].dropna()
    
    if len(adhd_vals) < 3 or len(control_vals) < 3:
        continue
    
    t_stat, p_val = stats.ttest_ind(adhd_vals, control_vals)
    conn_stats.append({
        'feature': col,
        'adhd_mean': adhd_vals.mean(),
        'control_mean': control_vals.mean(),
        'difference': adhd_vals.mean() - control_vals.mean(),
        't_stat': t_stat,
        'p_value': p_val,
        'significant': p_val < 0.05
    })

conn_df = pd.DataFrame(conn_stats)
if len(conn_df) > 0:
    print(conn_df.sort_values('p_value').head(10).to_string(index=False))
else:
    print("No connectivity features found")

# ============================================================
# Summary visualization
# ============================================================
print(f"\n\n[6] Generating summary visualizations...")
print("-"*50)

fig, axes = plt.subplots(2, 2, figsize=(16, 12))

# 1. Band power comparison for key channels
key_channels = ['Fz', 'Cz', 'Pz', 'C3', 'C4']
bands = ['delta', 'theta', 'alpha', 'beta', 'gamma']
x_pos = np.arange(len(key_channels))
width = 0.15

for i, band in enumerate(bands):
    means = []
    for ch in key_channels:
        col = f'{ch}_{band}_rel_mean'
        if col in X.columns:
            means.append(X.loc[y==0, col].mean())
        else:
            means.append(0)
    axes[0,0].bar(x_pos + i*width, means, width, label=band)

axes[0,0].set_xticks(x_pos + width*2)
axes[0,0].set_xticklabels(key_channels)
axes[0,0].set_title('Control Group: Band Power by Channel')
axes[0,0].set_ylabel('Relative Power')
axes[0,0].legend()

for i, band in enumerate(bands):
    means = []
    for ch in key_channels:
        col = f'{ch}_{band}_rel_mean'
        if col in X.columns:
            means.append(X.loc[y==1, col].mean())
        else:
            means.append(0)
    axes[0,1].bar(x_pos + i*width, means, width, label=band)

axes[0,1].set_xticks(x_pos + width*2)
axes[0,1].set_xticklabels(key_channels)
axes[0,1].set_title('ADHD Group: Band Power by Channel')
axes[0,1].set_ylabel('Relative Power')
axes[0,1].legend()

# 2. P-value distribution
p_values = stat_df['p_value'].dropna()
axes[1,0].hist(p_values, bins=20, color='#2196F3', edgecolor='black')
axes[1,0].axvline(0.05, color='red', linestyle='--', label='p=0.05')
axes[1,0].set_title('Distribution of p-values (All Channel-Band Combinations)')
axes[1,0].set_xlabel('p-value')
axes[1,0].set_ylabel('Count')
axes[1,0].legend()

# 3. Cohen's d distribution
cohen_ds = stat_df['cohen_d'].dropna()
axes[1,1].hist(cohen_ds, bins=20, color='#4CAF50', edgecolor='black')
axes[1,1].axvline(0, color='black', linestyle='-')
axes[1,1].axvline(0.2, color='orange', linestyle='--', label='Small')
axes[1,1].axvline(0.5, color='red', linestyle='--', label='Medium')
axes[1,1].axvline(0.8, color='darkred', linestyle='--', label='Large')
axes[1,1].set_title('Effect Size (Cohen\'s d) Distribution')
axes[1,1].set_xlabel('Cohen\'s d')
axes[1,1].set_ylabel('Count')
axes[1,1].legend()

# 4. Top significant features
top_sig = sig_df.head(10)
top_sig['label'] = top_sig['channel'] + '_' + top_sig['band']
axes[1,1].clear()
top_sig.plot(kind='barh', x='label', y='cohen_d', ax=axes[1,1], color='#FF9800')
axes[1,1].set_title('Top 10 Significant Features (Cohen\'s d)')
axes[1,1].set_xlabel('Cohen\'s d (effect size)')
axes[1,1].set_ylabel('Feature')

plt.suptitle('Comprehensive EEG Statistical Analysis', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('/home/alpha/university/archive/eeg_comprehensive_results.png', dpi=150, bbox_inches='tight')
print("Comprehensive results plot saved")

# ============================================================
# Save final summary
# ============================================================
print(f"\n\n[7] Saving summary report...")
print("-"*50)

summary = {
    'total_subjects': len(df),
    'adhd_subjects': y.sum(),
    'control_subjects': len(y) - y.sum(),
    'total_features': X.shape[1],
    'significant_channel_band_pairs': len(sig_df),
    'most_significant_feature': sig_df.iloc[0]['channel'] + '_' + sig_df.iloc[0]['band'] if len(sig_df) > 0 else 'N/A',
    'most_significant_p': sig_df.iloc[0]['p_value'] if len(sig_df) > 0 else 'N/A',
    'most_significant_cohen_d': sig_df.iloc[0]['cohen_d'] if len(sig_df) > 0 else 'N/A',
}

for k, v in summary.items():
    print(f"  {k}: {v}")

print("\n" + "="*70)
print("Comprehensive analysis completed!")
print("="*70)
