import pandas as pd

# UCI BCW 数据集的列名（来自wdbc.names文件）
column_names = [
    'id', 'diagnosis',
    'radius_mean', 'texture_mean', 'perimeter_mean', 'area_mean',
    'smoothness_mean', 'compactness_mean', 'concavity_mean',
    'concave_points_mean', 'symmetry_mean', 'fractal_dimension_mean',
    'radius_se', 'texture_se', 'perimeter_se', 'area_se',
    'smoothness_se', 'compactness_se', 'concavity_se',
    'concave_points_se', 'symmetry_se', 'fractal_dimension_se',
    'radius_worst', 'texture_worst', 'perimeter_worst', 'area_worst',
    'smoothness_worst', 'compactness_worst', 'concavity_worst',
    'concave_points_worst', 'symmetry_worst', 'fractal_dimension_worst'
]

# 读取wdbc.data文件（无表头）
input_path = 'E:/hjl/label-inference-attacks-main/Code/data/BreastCancerWisconsin/wdbc.data'
output_path = 'E:/hjl/label-inference-attacks-main/Code/data/BreastCancerWisconsin/wisconsin.csv'

# 读取数据并添加列名
df = pd.read_csv(input_path, header=None, names=column_names)

# 添加空列'Unnamed: 32'（代码会drop这一列）
df['Unnamed: 32'] = None

# 保存为CSV
df.to_csv(output_path, index=False)

print(f"✓ 转换完成: {output_path}")
print(f"  - 样本数: {len(df)}")
print(f"  - 列数: {len(df.columns)}")
print(f"  - 前5行:\n{df.head()}")
