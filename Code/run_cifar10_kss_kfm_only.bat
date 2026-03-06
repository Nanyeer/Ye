:: ============================================================
:: run_cifar10_kss_kfm_only.bat
:: CIFAR-10: KSS, KFM, KSS+KFM 防御效果完整测试
:: 包括: Direct Attack, Passive MC, Active MC
:: ============================================================

@echo off
cd /d E:\hjl\label-inference-attacks-main\Code

:: ---------- 0. Common settings ----------
set DATA_PATH=./data/CIFAR10
set EPOCHS=100
set HALF=16
set N_LABELED=40

:: ============================================================
:: 1. 训练阶段: 正常优化器 (normal)
:: ============================================================

echo.
echo ==== 1) Train CIFAR10: KSS only (pmin=0.8, pmax=0.99) ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs %EPOCHS% --half %HALF% ^
  --kss --kss-pmin 0.8 --kss-pmax 0.99

echo.
echo ==== 2) Train CIFAR10: KFM only (beta=0.05) ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs %EPOCHS% --half %HALF% ^
  --kfm --kfm-beta 0.05

echo.
echo ==== 3) Train CIFAR10: KSS + KFM (pmin=0.8, pmax=0.99, beta=0.05) ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs %EPOCHS% --half %HALF% ^
  --kss --kss-pmin 0.8 --kss-pmax 0.99 --kfm --kfm-beta 0.05

:: ============================================================
:: 2. 直接攻击 (Direct Attack, no top model)
:: ============================================================

echo.
echo ==== 4) Direct attack: KSS only ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs 1 --half %HALF% --use-top-model False ^
  --kss --kss-pmin 0.8 --kss-pmax 0.99

echo.
echo ==== 5) Direct attack: KFM only ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs 1 --half %HALF% --use-top-model False ^
  --kfm --kfm-beta 0.05

echo.
echo ==== 6) Direct attack: KSS + KFM ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs 1 --half %HALF% --use-top-model False ^
  --kss --kss-pmin 0.8 --kss-pmax 0.99 --kfm --kfm-beta 0.05

:: ============================================================
:: 3. 被动攻击 (Passive Model Completion)
:: ============================================================

echo.
echo ==== 7) Passive MC: KSS only ====
python model_completion.py --dataset-name CIFAR10 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 4 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR10_saved_framework_lr=0.1_normal_KSS_half=16.pth

echo.
echo ==== 8) Passive MC: KFM only ====
python model_completion.py --dataset-name CIFAR10 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 4 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR10_saved_framework_lr=0.1_normal_KFM_half=16.pth

echo.
echo ==== 9) Passive MC: KSS + KFM ====
python model_completion.py --dataset-name CIFAR10 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 4 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR10_saved_framework_lr=0.1_normal_KSS_KFM_half=16.pth

:: ============================================================
:: 4. 主动攻击训练阶段 (Active: malicious optimizer)
:: ============================================================

echo.
echo ==== 10) Active train: KSS + mal ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs %EPOCHS% --half %HALF% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --kss --kss-pmin 0.8 --kss-pmax 0.99

echo.
echo ==== 11) Active train: KFM + mal ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs %EPOCHS% --half %HALF% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --kfm --kfm-beta 0.05

echo.
echo ==== 12) Active train: KSS + KFM + mal ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs %EPOCHS% --half %HALF% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --kss --kss-pmin 0.8 --kss-pmax 0.99 --kfm --kfm-beta 0.05

:: ============================================================
:: 5. 主动攻击MC阶段 (Active MC)
:: ============================================================

echo.
echo ==== 13) Active MC: KSS + mal ====
python model_completion.py --dataset-name CIFAR10 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 4 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR10_saved_framework_lr=0.1_mal_KSS_half=16.pth

echo.
echo ==== 14) Active MC: KFM + mal ====
python model_completion.py --dataset-name CIFAR10 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 4 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR10_saved_framework_lr=0.1_mal_KFM_half=16.pth

echo.
echo ==== 15) Active MC: KSS + KFM + mal ====
python model_completion.py --dataset-name CIFAR10 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 4 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR10_saved_framework_lr=0.1_mal_KSS_KFM_half=16.pth

echo.
echo ==== All KSS/KFM experiments finished! ====
echo.
echo Check results in:
echo - saved_experiment_results/saved_models/CIFAR10_saved_models/*.txt
echo.
pause
