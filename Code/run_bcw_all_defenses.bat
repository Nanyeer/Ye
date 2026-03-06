:: ============================================================
:: run_bcw_all_defenses.bat
:: ============================================================

@echo off
cd /d E:\hjl\label-inference-attacks-main\Code

:: ---------- 0. Common settings ----------
set DATA_PATH=./data/BreastCancerWisconsin/wisconsin.csv
set EPOCHS=30
set HALF=14
set N_LABELED=20
set LR=1e-2
set BATCH_SIZE=16
set K=2

:: ============================================================
:: 第一部分: 训练阶段 (正常优化器)
:: ============================================================

echo.
echo ==== 1) Train BCW: No defense ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE%

echo.
echo ==== 2) Train BCW: Baseline GC (preserved=0.25) ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% ^
  --gc True --gc-preserved-percent 0.25

echo.
echo ==== 3) Train BCW: Baseline PPDL (theta-u=0.75) ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% ^
  --ppdl True --ppdl-theta-u 0.75

echo.
echo ==== 4) Train BCW: Baseline Lap Noise (scale=1e-3) ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% ^
  --lap-noise True --noise-scale 1e-3

echo.
echo ==== 5) Train BCW: Baseline Multistep Grad (bins=6) ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% ^
  --multistep_grad True --multistep_grad_bins 6

echo.
echo ==== 6) Train BCW: Baseline DP (noise=0.1) ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% ^
  --lap-noise True --noise-scale 0.1

echo.
echo ==== 7) Train BCW: KSS only (pmin=0.5, pmax=0.8) ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% ^
  --kss --kss-pmin 0.5 --kss-pmax 0.8

echo.
echo ==== 8) Train BCW: KFM only (beta=0.15) ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% ^
  --kfm --kfm-beta 0.15

echo.
echo ==== 9) Train BCW: KSS + KFM (pmin=0.5, pmax=0.8, beta=0.15) ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% ^
  --kss --kss-pmin 0.5 --kss-pmax 0.8 --kfm --kfm-beta 0.15

:: ============================================================
:: 第二部分: 直接攻击 (Direct Attack, no top model)
:: ============================================================

echo.
echo ==== 10) Direct attack: No defense ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs 1 ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% --use-top-model False

echo.
echo ==== 11) Direct attack: GC ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs 1 ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% --use-top-model False ^
  --gc True --gc-preserved-percent 0.25

echo.
echo ==== 12) Direct attack: PPDL ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs 1 ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% --use-top-model False ^
  --ppdl True --ppdl-theta-u 0.75

echo.
echo ==== 13) Direct attack: Lap Noise ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs 1 ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% --use-top-model False ^
  --lap-noise True --noise-scale 1e-3

echo.
echo ==== 14) Direct attack: Multistep Grad ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs 1 ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% --use-top-model False ^
  --multistep_grad True --multistep_grad_bins 6

echo.
echo ==== 15) Direct attack: DP ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs 1 ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% --use-top-model False ^
  --lap-noise True --noise-scale 0.1

echo.
echo ==== 16) Direct attack: KSS ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs 1 ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% --use-top-model False ^
  --kss --kss-pmin 0.5 --kss-pmax 0.8

echo.
echo ==== 17) Direct attack: KFM ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs 1 ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% --use-top-model False ^
  --kfm --kfm-beta 0.15

echo.
echo ==== 18) Direct attack: KSS + KFM ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs 1 ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% --use-top-model False ^
  --kss --kss-pmin 0.5 --kss-pmax 0.8 --kfm --kfm-beta 0.15

:: ============================================================
:: 第三部分: 被动攻击 (Passive Model Completion)
:: ============================================================

echo.
echo ==== 19) Passive MC: No defense ====
python model_completion.py --dataset-name BCW --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k %K% --epochs 5 --print-to-txt 1 ^
  --resume-name BCW_saved_framework_lr=0.01_normal_half=14.pth

echo.
echo ==== 20) Passive MC: GC ====
python model_completion.py --dataset-name BCW --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k %K% --epochs 5 --print-to-txt 1 ^
  --resume-name BCW_saved_framework_lr=0.01_normal_gc-preserved_percent=0.25_half=14.pth

echo.
echo ==== 21) Passive MC: PPDL ====
python model_completion.py --dataset-name BCW --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k %K% --epochs 5 --print-to-txt 1 ^
  --resume-name BCW_saved_framework_lr=0.01_normal_ppdl-theta_u=0.75_half=14.pth

echo.
echo ==== 22) Passive MC: Lap Noise ====
python model_completion.py --dataset-name BCW --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k %K% --epochs 5 --print-to-txt 1 ^
  --resume-name BCW_saved_framework_lr=0.01_normal_lap_noise-scale=0.001_half=14.pth

echo.
echo ==== 23) Passive MC: Multistep Grad ====
python model_completion.py --dataset-name BCW --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k %K% --epochs 5 --print-to-txt 1 ^
  --resume-name BCW_saved_framework_lr=0.01_normal_multistep_grad_bins=6_half=14.pth

echo.
echo ==== 24) Passive MC: DP ====
python model_completion.py --dataset-name BCW --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k %K% --epochs 5 --print-to-txt 1 ^
  --resume-name BCW_saved_framework_lr=0.01_normal_lap_noise-scale=0.1_half=14.pth

echo.
echo ==== 25) Passive MC: KSS ====
python model_completion.py --dataset-name BCW --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k %K% --epochs 5 --print-to-txt 1 ^
  --resume-name BCW_saved_framework_lr=0.01_normal_KSS_half=14.pth

echo.
echo ==== 26) Passive MC: KFM ====
python model_completion.py --dataset-name BCW --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k %K% --epochs 5 --print-to-txt 1 ^
  --resume-name BCW_saved_framework_lr=0.01_normal_KFM_half=14.pth

echo.
echo ==== 27) Passive MC: KSS + KFM ====
python model_completion.py --dataset-name BCW --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k %K% --epochs 5 --print-to-txt 1 ^
  --resume-name BCW_saved_framework_lr=0.01_normal_KSS_KFM_half=14.pth

:: ============================================================
:: 第四部分: 主动攻击训练阶段 (Active: malicious optimizer)
:: ============================================================

echo.
echo ==== 28) Active train: No defense + mal ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% ^
  --use-mal-optim True --use-mal-optim-all False

echo.
echo ==== 29) Active train: GC + mal ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --gc True --gc-preserved-percent 0.25

echo.
echo ==== 30) Active train: PPDL + mal ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --ppdl True --ppdl-theta-u 0.75

echo.
echo ==== 31) Active train: Lap Noise + mal ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --lap-noise True --noise-scale 1e-3

echo.
echo ==== 32) Active train: Multistep Grad + mal ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --multistep_grad True --multistep_grad_bins 6

echo.
echo ==== 33) Active train: DP + mal ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --lap-noise True --noise-scale 0.1

echo.
echo ==== 34) Active train: KSS + mal ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --kss --kss-pmin 0.5 --kss-pmax 0.8

echo.
echo ==== 35) Active train: KFM + mal ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --kfm --kfm-beta 0.15

echo.
echo ==== 36) Active train: KSS + KFM + mal ====
python vfl_framework.py -d BCW --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% ^
  --half %HALF% --lr %LR% -b %BATCH_SIZE% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --kss --kss-pmin 0.5 --kss-pmax 0.8 --kfm --kfm-beta 0.15

:: ============================================================
:: 第五部分: 主动攻击MC阶段 (Active MC)
:: ============================================================

echo.
echo ==== 37) Active MC: No defense + mal ====
python model_completion.py --dataset-name BCW --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k %K% --epochs 5 --print-to-txt 1 ^
  --resume-name BCW_saved_framework_lr=0.01_mal_half=14.pth

echo.
echo ==== 38) Active MC: GC + mal ====
python model_completion.py --dataset-name BCW --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k %K% --epochs 5 --print-to-txt 1 ^
  --resume-name BCW_saved_framework_lr=0.01_mal_gc-preserved_percent=0.25_half=14.pth

echo.
echo ==== 39) Active MC: PPDL + mal ====
python model_completion.py --dataset-name BCW --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k %K% --epochs 5 --print-to-txt 1 ^
  --resume-name BCW_saved_framework_lr=0.01_mal_ppdl-theta_u=0.75_half=14.pth

echo.
echo ==== 40) Active MC: Lap Noise + mal ====
python model_completion.py --dataset-name BCW --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k %K% --epochs 5 --print-to-txt 1 ^
  --resume-name BCW_saved_framework_lr=0.01_mal_lap_noise-scale=0.001_half=14.pth

echo.
echo ==== 41) Active MC: Multistep Grad + mal ====
python model_completion.py --dataset-name BCW --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k %K% --epochs 5 --print-to-txt 1 ^
  --resume-name BCW_saved_framework_lr=0.01_mal_multistep_grad_bins=6_half=14.pth

echo.
echo ==== 42) Active MC: DP + mal ====
python model_completion.py --dataset-name BCW --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k %K% --epochs 5 --print-to-txt 1 ^
  --resume-name BCW_saved_framework_lr=0.01_mal_lap_noise-scale=0.1_half=14.pth

echo.
echo ==== 43) Active MC: KSS + mal ====
python model_completion.py --dataset-name BCW --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k %K% --epochs 5 --print-to-txt 1 ^
  --resume-name BCW_saved_framework_lr=0.01_mal_KSS_half=14.pth

echo.
echo ==== 44) Active MC: KFM + mal ====
python model_completion.py --dataset-name BCW --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k %K% --epochs 5 --print-to-txt 1 ^
  --resume-name BCW_saved_framework_lr=0.01_mal_KFM_half=14.pth

echo.
echo ==== 45) Active MC: KSS + KFM + mal ====
python model_completion.py --dataset-name BCW --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k %K% --epochs 5 --print-to-txt 1 ^
  --resume-name BCW_saved_framework_lr=0.01_mal_KSS_KFM_half=14.pth

echo.
echo ==== All BCW experiments finished! ====
echo.
echo Results saved in:
echo - saved_experiment_results/saved_models/BCW_saved_models/*.pth
echo - saved_experiment_results/saved_models/BCW_saved_models/*.txt
echo.
pause
