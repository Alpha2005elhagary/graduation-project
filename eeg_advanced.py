"""
Advanced EEG Classification Pipeline for ADHD vs Control
- Per-window features with sliding window approach
- Functional connectivity features (coherence, correlation)
- Multiple classifiers with cross-validation
- Detailed statistical analysis
"""
import pandas as pd
import numpy as np
import warnings
warnings.filterwarnings('ignore')

from sklearn.model_selection import GroupKFold
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier, ExtraTreesClassifier, GradientBoostingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score, roc_auc_score
from scipy import stats
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

print("="*70)
print("Advanced EEG Classification Pipeline")
print("="*70)

# ============================================================
# Step 1: Load and prepare data
# ============================================================
print("\n[1] Loading data...")
df = pd.read_csv('/home/alpha/university/archive/adhdata.csv')
print(f"Total rows: {len(df):,}, Subjects: {df['ID'].nunique()}")

eeg_channels = ['Fp1', 'Fp2', 'F3', 'F4', 'C3', 'C4', 'P3', 'P4',
                'O1', 'O2', 'F7', 'F8', 'T7', 'T8', 'P7', 'P8', 'Fz', 'Cz', 'Pz']

# ============================================================
# Step 2: Sliding window feature extraction
# ============================================================
print("\n[2] Extracting sliding window features...")
WINDOW_SIZE = 500  # samples per window (~4 seconds at 128Hz)
STEP = 250  # 50% overlap

window_features = []

for subject_id, group in df.groupby('ID'):
    cls = 1 if group['Class'].iloc[0] == 'ADHD' else 0
    n_samples = len(group)
    
    for start in range(0, n_samples - WINDOW_SIZE, STEP):
        window = group.iloc[start:start+WINDOW_SIZE]
        
        row = {'ID': subject_id, 'Class': cls, 'window': start}
        
        for ch in eeg_channels:
            sig = window[ch].values
            
            # Time domain
            row[f'{ch}_mean'] = np.mean(sig)
            row[f'{ch}_std'] = np.std(sig)
            row[f'{ch}_max'] = np.max(sig)
            row[f'{ch}_min'] = np.min(sig)
            row[f'{ch}_range'] = np.ptp(sig)
            row[f'{ch}_skew'] = pd.Series(sig).skew()
            row[f'{ch}_kurt'] = pd.Series(sig).kurtosis()
            row[f'{ch}_ptp'] = np.ptp(sig)
            row[f'{ch}_rms'] = np.sqrt(np.mean(sig**2))
            row[f'{ch}_zero_cross'] = np.sum(np.diff(np.sign(sig)) != 0)
            
            # Frequency domain
            fft_vals = np.abs(np.fft.rfft(sig)) ** 2
            freqs = np.fft.rfftfreq(len(sig), d=1/128)
            total_power = np.sum(fft_vals) + 1e-10
            
            for band_name, fmin, fmax in [
                ('delta', 0.5, 4), ('theta', 4, 8), ('alpha', 8, 13),
                ('beta', 13, 30), ('gamma', 30, 50)
            ]:
                band_power = np.sum(fft_vals[(freqs >= fmin) & (freqs < fmax)])
                row[f'{ch}_{band_name}_rel'] = band_power / total_power
                row[f'{ch}_{band_name}_abs'] = np.log(band_power + 1e-10)
            
            # Theta/Beta ratio
            row[f'{ch}_tb_ratio'] = row[f'{ch}_theta_rel'] / (row[f'{ch}_beta_rel'] + 1e-10)
        
        # Inter-channel connectivity (within window)
        ch_data = window[eeg_channels].values
        corr = np.corrcoef(ch_data.T)
        row['avg_abs_corr'] = np.mean(np.abs(corr[np.triu_indices(len(eeg_channels), k=1)]))
        upper = corr[np.triu_indices(len(eeg_channels), k=1)]
        row['max_corr'] = np.max(upper)
        row['min_corr'] = np.min(upper)
        
        # Hemispheric asymmetry (left-right pairs)
        left_channels = ['Fp1', 'F3', 'C3', 'P3', 'F7', 'T7', 'P7', 'Fz', 'Cz']
        right_channels = ['Fp2', 'F4', 'C4', 'P4', 'F8', 'T8', 'P8', 'Pz']
        asym = []
        for l_ch, r_ch in zip(left_channels, right_channels):
            asym.append(np.mean(window[l_ch]) - np.mean(window[r_ch]))
        row['hemi_asym_mean'] = np.mean(asym)
        row['hemi_asym_std'] = np.std(asym)
        
        window_features.append(row)

windows_df = pd.DataFrame(window_features)
print(f"Window feature matrix: {windows_df.shape}")
print(f"Windows per subject: mean={windows_df.groupby('ID').size().mean():.1f}, "
      f"min={windows_df.groupby('ID').size().min()}, max={windows_df.groupby('ID').size().max()}")

# ============================================================
# Step 3: Subject-level aggregation
# ============================================================
print("\n[3] Aggregating to subject level...")

id_col = windows_df[['ID', 'Class']].copy()
agg_cols = [c for c in windows_df.columns if c not in ['ID', 'Class', 'window']]
agg_dict = {c: ['mean', 'std', 'min', 'max', 'median'] for c in agg_cols}

subject_features = windows_df.groupby('ID')[agg_cols].agg(agg_dict).reset_index()
subject_features.columns = ['_'.join(col).strip('_') if isinstance(col, tuple) else col for col in subject_features.columns]
subject_features = subject_features.merge(id_col.drop_duplicates('ID'), on='ID')

for col in ['avg_abs_corr', 'max_corr', 'hemi_asym_mean']:
    var = windows_df.groupby('ID')[col].std().reset_index()
    var.columns = ['ID', f'{col}_within_var']
    subject_features = subject_features.merge(var, on='ID', how='left')

print(f"Subject feature matrix: {subject_features.shape}")

# ============================================================
# Step 4: Feature selection
# ============================================================
print("\n[4] Feature selection...")

X = subject_features.drop(columns=['ID', 'Class'])
y = subject_features['Class'].values

corr_matrix = X.corr().abs()
upper = corr_matrix.where(np.triu(np.ones(corr_matrix.shape), k=1).astype(bool))
to_drop = [column for column in upper.columns if any(upper[column] > 0.95)]
X = X.drop(columns=to_drop)
print(f"Dropped {len(to_drop)} highly correlated features")
print(f"Remaining features: {X.shape[1]}")

# ============================================================
# Step 5: Cross-validation
# ============================================================
print("\n[5] Cross-validation (GroupKFold)...")

groups = subject_features['ID'].values
gkf = GroupKFold(n_splits=5)

cv_results = {}

models = {
    'Random Forest (100)': RandomForestClassifier(n_estimators=100, max_depth=10, random_state=42),
    'Random Forest (200)': RandomForestClassifier(n_estimators=200, max_depth=15, random_state=42),
    'Extra Trees': ExtraTreesClassifier(n_estimators=200, random_state=42),
    'Gradient Boosting': GradientBoostingClassifier(n_estimators=100, random_state=42),
    'Logistic Regression': LogisticRegression(max_iter=2000, random_state=42),
    'SVM (RBF)': SVC(kernel='rbf', C=1.0, gamma='scale', probability=True, random_state=42),
}

for name, model in models.items():
    scores = []
    auc_scores = []
    for train_idx, test_idx in gkf.split(X, y, groups=groups):
        X_train, X_test = X.iloc[train_idx], X.iloc[test_idx]
        y_train, y_test = y[train_idx], y[test_idx]
        
        scaler = StandardScaler()
        X_train_s = scaler.fit_transform(X_train)
        X_test_s = scaler.transform(X_test)
        
        model.fit(X_train_s, y_train)
        y_pred = model.predict(X_test_s)
        acc = accuracy_score(y_test, y_pred)
        scores.append(acc)
        
        if hasattr(model, 'predict_proba'):
            y_proba = model.predict_proba(X_test_s)[:, 1]
            auc_scores.append(roc_auc_score(y_test, y_proba))
    
    cv_results[name] = {
        'accuracy_mean': np.mean(scores),
        'accuracy_std': np.std(scores),
        'accuracy_folds': scores,
        'auc_mean': np.mean(auc_scores) if auc_scores else 0,
    }
    print(f"  {name}: Acc={np.mean(scores):.4f}±{np.std(scores):.4f}, "
          f"AUC={np.mean(auc_scores):.4f}" if auc_scores else f"  {name}: Acc={np.mean(scores):.4f}±{np.std(scores):.4f}")

# ============================================================
# Step 6: Best model detailed analysis
# ============================================================
print("\n[6] Detailed analysis of best model...")

best_model_name = max(cv_results, key=lambda x: cv_results[x]['accuracy_mean'])
print(f"Best model: {best_model_name}")

best_model = models[best_model_name]
best_model.fit(X, y)

importances = None
top_features = None
ch_imp_series = None

if hasattr(best_model, 'feature_importances_'):
    importances = pd.Series(best_model.feature_importances_, index=X.columns)
    top_features = importances.nlargest(25)
    
    print("\n  Top 25 features:")
    for i, (feat, imp) in enumerate(top_features.items()):
        print(f"    {i+1:2d}. {feat:40s} {imp:.4f}")
    
    fig, ax = plt.subplots(figsize=(10, 8))
    top_features.plot(kind='barh', ax=ax, color='#2196F3')
    ax.set_xlabel('Feature Importance')
    ax.set_title(f'Top 25 Feature Importances ({best_model_name})')
    ax.set_yticklabels(top_features.index, fontsize=8)
    plt.tight_layout()
    plt.savefig('/home/alpha/university/archive/feature_importance.png', dpi=150, bbox_inches='tight')
    print("\n  Feature importance plot saved")

# ============================================================
# Step 7: Channel-wise analysis
# ============================================================
print("\n[7] Channel-wise analysis...")

if importances is not None:
    channel_importances = {}
    for ch in eeg_channels:
        ch_features = [col for col in X.columns if ch in col]
        ch_imp = importances[ch_features].sum()
        channel_importances[ch] = ch_imp
    
    ch_imp_series = pd.Series(channel_importances).sort_values(ascending=False)
    print("  Channel importance ranking:")
    for ch, imp in ch_imp_series.items():
        print(f"    {ch}: {imp:.4f}")
    
    fig, ax = plt.subplots(figsize=(10, 5))
    ch_imp_series.plot(kind='bar', ax=ax, color='#4CAF50')
    ax.set_title('Total Feature Importance per EEG Channel')
    ax.set_ylabel('Sum of Feature Importances')
    ax.set_xlabel('EEG Channel')
    plt.tight_layout()
    plt.savefig('/home/alpha/university/archive/channel_importance.png', dpi=150, bbox_inches='tight')
    print("  Channel importance plot saved")
else:
    print("  Skipping channel-wise analysis (model has no feature_importances_)")

# ============================================================
# Step 8: ADHD vs Control statistical comparison
# ============================================================
print("\n[8] Statistical comparison: ADHD vs Control...")

key_features = ['avg_abs_corr', 'max_corr', 'hemi_asym_mean', 'hemi_asym_std']
for ch in ['Fz', 'Cz', 'Pz', 'C3', 'C4']:
    key_features.append(f'{ch}_theta_rel')
    key_features.append(f'{ch}_beta_rel')
    key_features.append(f'{ch}_tb_ratio')

stat_results = []
for feat in key_features:
    if feat not in X.columns:
        continue
    adhd_vals = X.loc[y == 1, feat]
    control_vals = X.loc[y == 0, feat]
    
    t_stat, p_val = stats.ttest_ind(adhd_vals, control_vals)
    
    stat_results.append({
        'feature': feat,
        'adhd_mean': adhd_vals.mean(),
        'control_mean': control_vals.mean(),
        'difference': adhd_vals.mean() - control_vals.mean(),
        't_stat': t_stat,
        'p_value': p_val,
        'significant': p_val < 0.05
    })

stat_df = pd.DataFrame(stat_results)
print(stat_df.to_string(index=False))

# ============================================================
# Step 9: Save all results
# ============================================================
print("\n[9] Saving all results...")

windows_df.to_csv('/home/alpha/university/archive/eeg_windows.csv', index=False)
print(f"  Window features saved: {windows_df.shape}")

subject_features.to_csv('/home/alpha/university/archive/eeg_subject_features.csv', index=False)
print(f"  Subject features saved: {subject_features.shape}")

cv_df = pd.DataFrame([{
    'Model': name,
    'Accuracy_Mean': result['accuracy_mean'],
    'Accuracy_Std': result['accuracy_std'],
    'AUC_Mean': result['auc_mean']
} for name, result in cv_results.items()])
cv_df.to_csv('/home/alpha/university/archive/eeg_cv_results.csv', index=False)

stat_df.to_csv('/home/alpha/university/archive/eeg_stats.csv', index=False)

# ============================================================
# Step 10: Final summary plots
# ============================================================
print("\n[10] Generating summary plots...")

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

cv_df_sorted = cv_df.sort_values('Accuracy_Mean', ascending=True)
axes[0,0].barh(cv_df_sorted['Model'], cv_df_sorted['Accuracy_Mean'],
               xerr=cv_df_sorted['Accuracy_Std'], color='#2196F3')
axes[0,0].set_xlim(0.5, 1.0)
axes[0,0].set_title('Model Comparison (5-fold CV)')
axes[0,0].set_xlabel('Accuracy')

if ch_imp_series is not None:
    ch_imp_series.plot(kind='barh', ax=axes[0,1], color='#4CAF50')
    axes[0,1].set_title('EEG Channel Importance')
    axes[0,1].set_xlabel('Sum of Importances')
else:
    axes[0,1].text(0.5, 0.5, 'No channel importance available', ha='center', va='center')

if top_features is not None:
    top_features.plot(kind='barh', ax=axes[1,0], color='#FF9800')
    axes[1,0].set_title('Top 25 Features')
    axes[1,0].set_xlabel('Feature Importance')
else:
    axes[1,0].text(0.5, 0.5, 'No feature importance available', ha='center', va='center')

tb_cols = [c for c in X.columns if 'tb_ratio' in c]
tb_means = [X.loc[y==1, c].mean() for c in tb_cols]
tb_stds = [X.loc[y==0, c].mean() for c in tb_cols]
ch_names = [c.replace('_tb_ratio', '') for c in tb_cols]
x_pos = np.arange(len(ch_names))
axes[1,1].bar(x_pos - 0.2, tb_means, 0.4, label='ADHD', color='#F44336')
axes[1,1].bar(x_pos + 0.2, tb_stds, 0.4, label='Control', color='#4CAF50')
axes[1,1].set_xticks(x_pos)
axes[1,1].set_xticklabels(ch_names, rotation=45, fontsize=7)
axes[1,1].set_title('Theta/Beta Ratio: ADHD vs Control')
axes[1,1].set_ylabel('Mean T/B Ratio')
axes[1,1].legend()

plt.suptitle('Advanced EEG Analysis Results', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('/home/alpha/university/archive/eeg_advanced_results.png', dpi=150, bbox_inches='tight')
print("  Summary plot saved")

print("\n" + "="*70)
print("Advanced analysis completed!")
print("="*70)
