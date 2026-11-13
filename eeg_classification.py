"""
EEG Classification Pipeline for ADHD vs Control
Feature extraction + ML classification
"""
import pandas as pd
import numpy as np
import warnings
warnings.filterwarnings('ignore')

from sklearn.model_selection import GroupShuffleSplit
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

print("="*60)
print("EEG Classification Pipeline")
print("="*60)

# Step 1: Load data
print("\n[1] Loading data...")
df = pd.read_csv('/home/alpha/university/archive/adhdata.csv')
print(f"Total rows: {len(df):,}")
print(f"Classes: {dict(df['Class'].value_counts())}")
print(f"Subjects: {df['ID'].nunique()}")

# Step 2: Feature extraction per subject
print("\n[2] Extracting features per subject...")

eeg_channels = ['Fp1', 'Fp2', 'F3', 'F4', 'C3', 'C4', 'P3', 'P4',
                'O1', 'O2', 'F7', 'F8', 'T7', 'T8', 'P7', 'P8', 'Fz', 'Cz', 'Pz']

features_list = []

for subject_id, group in df.groupby('ID'):
    cls = group['Class'].iloc[0]
    
    # Time-domain features per channel
    row_features = {'ID': subject_id, 'Class': cls}
    
    for ch in eeg_channels:
        signal = group[ch].values
        
        # Statistical features
        row_features[f'{ch}_mean'] = np.mean(signal)
        row_features[f'{ch}_std'] = np.std(signal)
        row_features[f'{ch}_skew'] = pd.Series(signal).skew()
        row_features[f'{ch}_kurt'] = pd.Series(signal).kurtosis()
        
        # Percentile-based features
        row_features[f'{ch}_p25'] = np.percentile(signal, 25)
        row_features[f'{ch}_p75'] = np.percentile(signal, 75)
        row_features[f'{ch}_range'] = np.percentile(signal, 95) - np.percentile(signal, 5)
        
        # Frequency-domain features (power spectrum)
        freqs = np.fft.rfftfreq(len(signal), d=1/128)  # assume 128Hz sampling
        spectrum = np.abs(np.fft.rfft(signal)) ** 2
        total_power = np.sum(spectrum) + 1e-10
        
        # EEG bands
        delta = np.sum(spectrum[(freqs >= 0.5) & (freqs < 4)]) / total_power
        theta = np.sum(spectrum[(freqs >= 4) & (freqs < 8)]) / total_power
        alpha = np.sum(spectrum[(freqs >= 8) & (freqs < 13)]) / total_power
        beta = np.sum(spectrum[(freqs >= 13) & (freqs < 30)]) / total_power
        gamma = np.sum(spectrum[(freqs >= 30) & (freqs < 50)]) / total_power
        
        row_features[f'{ch}_delta'] = delta
        row_features[f'{ch}_theta'] = theta
        row_features[f'{ch}_alpha'] = alpha
        row_features[f'{ch}_beta'] = beta
        row_features[f'{ch}_gamma'] = gamma
        
        # Theta/Beta ratio (commonly used for ADHD)
        row_features[f'{ch}_tb_ratio'] = theta / (beta + 1e-10)
    
    features_list.append(row_features)

features_df = pd.DataFrame(features_list)
print(f"Feature matrix shape: {features_df.shape}")
print(f"Features per subject: {len(features_df.columns) - 2}")

# Step 3: Train/test split
print("\n[3] Splitting data...")
X = features_df.drop(columns=['ID', 'Class'])
y = (features_df['Class'] == 'ADHD').astype(int)  # Binary: 1=ADHD, 0=Control

# Group-aware split
gss = GroupShuffleSplit(n_splits=1, test_size=0.2, random_state=42)
train_idx, test_idx = next(gss.split(X, y, groups=features_df['ID']))

X_train, X_test = X.iloc[train_idx], X.iloc[test_idx]
y_train, y_test = y.iloc[train_idx], y.iloc[test_idx]

print(f"Train subjects: {len(set(features_df.iloc[train_idx]['ID']))}")
print(f"Test subjects: {len(set(features_df.iloc[test_idx]['ID']))}")

# Step 4: Train models
print("\n[4] Training classifiers...")

scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

models = {
    'Random Forest': RandomForestClassifier(n_estimators=100, random_state=42),
    'Logistic Regression': LogisticRegression(max_iter=1000, random_state=42),
}

results = {}
for name, model in models.items():
    print(f"\n  Training {name}...")
    if name == 'Random Forest':
        model.fit(X_train, y_train)
        y_pred = model.predict(X_test)
    else:
        model.fit(X_train_scaled, y_train)
        y_pred = model.predict(X_test_scaled)
    
    acc = accuracy_score(y_test, y_pred)
    results[name] = acc
    print(f"  Accuracy: {acc:.4f}")
    print(f"  Classification report:\n{classification_report(y_test, y_pred, target_names=['Control', 'ADHD'])}")

# Feature importance from Random Forest
print("\n[5] Top 15 most important features (Random Forest):")
rf_model = models['Random Forest']
importances = pd.Series(rf_model.feature_importances_, index=X.columns)
top_features = importances.nlargest(15)
for feat, imp in top_features.items():
    print(f"  {feat}: {imp:.4f}")

# Save results
print("\n[6] Saving results...")
features_df.to_csv('/home/alpha/university/archive/eeg_features.csv', index=False)
print("Features saved to eeg_features.csv")

# Plot results
fig, axes = plt.subplots(1, 3, figsize=(15, 4))
axes[0].bar(list(results.keys()), list(results.values()), color=['#2196F3', '#4CAF50'])
axes[0].set_ylim(0.5, 1.0)
axes[0].set_title('Model Accuracy')
axes[0].set_ylabel('Accuracy')
for i, (name, acc) in enumerate(results.items()):
    axes[0].text(i, acc + 0.02, f'{acc:.3f}', ha='center', fontweight='bold')

top_features.plot(kind='barh', ax=axes[1], color='#FF9800')
axes[1].set_title('Top 15 Feature Importances')
axes[1].set_xlabel('Importance')

axes[2].bar(['ADHD', 'Control'], [y_test.sum(), len(y_test) - y_test.sum()], color=['#F44336', '#4CAF50'])
axes[2].set_title('Test Set Class Distribution')

plt.tight_layout()
plt.savefig('/home/alpha/university/archive/eeg_results.png', dpi=150, bbox_inches='tight')
print("Plot saved to eeg_results.png")

print("\n" + "="*60)
print("Pipeline completed successfully!")
print("="*60)
