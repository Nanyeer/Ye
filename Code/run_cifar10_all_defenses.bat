:: ============================================================
:: run_cifar10_all_defenses.bat
:: CIFAR-10: No defense, KSS, KFM, KSS+KFM, GC, PPDL, Lap, Multistep
:: For each: model accuracy, Direct attack, Passive MC, Active+MC
:: ============================================================

@echo off

:: ---------- 0. Common settings ----------
set DATA_PATH=./data/CIFAR10
set EPOCHS=100
set HALF=16
set N_LABELED=40

:: ============================================================
:: 1. Training: obtain models under different defenses
:: ============================================================

echo ==== 1) Train CIFAR10: No defense ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs %EPOCHS% --half %HALF%

echo ==== 2) Train CIFAR10: KSS only ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs %EPOCHS% --half %HALF% ^
  --kss --kss-pmin 0.2 --kss-pmax 0.8

echo ==== 3) Train CIFAR10: KFM only ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs %EPOCHS% --half %HALF% ^
  --kfm --kfm-beta 0.5

echo ==== 4) Train CIFAR10: KSS + KFM ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs %EPOCHS% --half %HALF% ^
  --kss --kss-pmin 0.2 --kss-pmax 0.8 --kfm --kfm-beta 0.5

echo ==== 5) Train CIFAR10: Baseline GC ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs %EPOCHS% --half %HALF% ^
  --gc True --gc-preserved-percent 0.25

echo ==== 6) Train CIFAR10: Baseline PPDL ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs %EPOCHS% --half %HALF% ^
  --ppdl True --ppdl-theta-u 0.75

echo ==== 7) Train CIFAR10: Baseline Lap Noise ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs %EPOCHS% --half %HALF% ^
  --lap-noise True --noise-scale 1e-3

echo ==== 8) Train CIFAR10: Baseline Multistep Grad ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs %EPOCHS% --half %HALF% ^
  --multistep_grad True --multistep_grad_bins 6

:: ============================================================
:: 2. Direct attack (no top model) under each defense
:: ============================================================

echo ==== 9) Direct attack: No defense ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs 1 --half %HALF% --use-top-model False

echo ==== 10) Direct attack: KSS ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs 1 --half %HALF% --use-top-model False ^
  --kss --kss-pmin 0.2 --kss-pmax 0.8

echo ==== 11) Direct attack: KFM ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs 1 --half %HALF% --use-top-model False ^
  --kfm --kfm-beta 0.5

echo ==== 12) Direct attack: KSS + KFM ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs 1 --half %HALF% --use-top-model False ^
  --kss --kss-pmin 0.2 --kss-pmax 0.8 --kfm --kfm-beta 0.5

echo ==== 13) Direct attack: GC ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs 1 --half %HALF% --use-top-model False ^
  --gc True --gc-preserved-percent 0.25

echo ==== 14) Direct attack: PPDL ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs 1 --half %HALF% --use-top-model False ^
  --ppdl True --ppdl-theta-u 0.75

echo ==== 15) Direct attack: Lap Noise ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs 1 --half %HALF% --use-top-model False ^
  --lap-noise True --noise-scale 1e-3

echo ==== 16) Direct attack: Multistep Grad ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs 1 --half %HALF% --use-top-model False ^
  --multistep_grad True --multistep_grad_bins 6

:: ============================================================
:: 3. Passive attack (Model Completion) under各防御
:: 注意: --resume-name 需与训练阶段生成的 .pth 文件名匹配
:: ============================================================

echo ==== 17) Passive MC: No defense ====
python model_completion.py --dataset-name CIFAR10 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 4 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR10_saved_framework_lr=0.1_normal_half=16.pth

echo ==== 18) Passive MC: KSS ====
python model_completion.py --dataset-name CIFAR10 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 4 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR10_saved_framework_lr=0.1_normal_KSS_half=16.pth

echo ==== 19) Passive MC: KFM ====
python model_completion.py --dataset-name CIFAR10 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 4 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR10_saved_framework_lr=0.1_normal_KFM_half=16.pth

echo ==== 20) Passive MC: KSS + KFM ====
python model_completion.py --dataset-name CIFAR10 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 4 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR10_saved_framework_lr=0.1_normal_KSS_KFM_half=16.pth

echo ==== 21) Passive MC: GC baseline ====
python model_completion.py --dataset-name CIFAR10 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 4 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR10_saved_framework_lr=0.1_normal_gc-preserved_percent=0.25_half=16.pth

echo ==== 22) Passive MC: PPDL baseline ====
python model_completion.py --dataset-name CIFAR10 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 4 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR10_saved_framework_lr=0.1_normal_ppdl-theta_u=0.75_half=16.pth

echo ==== 23) Passive MC: Lap Noise baseline ====
python model_completion.py --dataset-name CIFAR10 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 4 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR10_saved_framework_lr=0.1_normal_lap_noise-scale=0.001_half=16.pth

echo ==== 24) Passive MC: Multistep Grad baseline ====
python model_completion.py --dataset-name CIFAR10 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 4 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR10_saved_framework_lr=0.1_normal_multistep_grad_bins=6_half=16.pth

:: ============================================================
:: 4. Active attack (malicious optimizer) + MC
::    为每种防御再训练一版 (use-mal-optim=True)，再跑 MC
:: ============================================================

echo ==== 25) Active train: No defense (mal) ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs %EPOCHS% --half %HALF% ^
  --use-mal-optim True --use-mal-optim-all False

echo ==== 26) Active MC: No defense (mal) ====
python model_completion.py --dataset-name CIFAR10 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 4 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR10_saved_framework_lr=0.1_mal_half=16.pth

echo ==== 27) Active train: KSS + mal ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs %EPOCHS% --half %HALF% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --kss --kss-pmin 0.2 --kss-pmax 0.8

echo ==== 28) Active MC: KSS + mal ====
python model_completion.py --dataset-name CIFAR10 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 4 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR10_saved_framework_lr=0.1_mal_KSS_half=16.pth

echo ==== 29) Active train: KFM + mal ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs %EPOCHS% --half %HALF% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --kfm --kfm-beta 0.5

echo ==== 30) Active MC: KFM + mal ====
python model_completion.py --dataset-name CIFAR10 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 4 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR10_saved_framework_lr=0.1_mal_KFM_half=16.pth

echo ==== 31) Active train: KSS + KFM + mal ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs %EPOCHS% --half %HALF% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --kss --kss-pmin 0.2 --kss-pmax 0.8 --kfm --kfm-beta 0.5

echo ==== 32) Active MC: KSS + KFM + mal ====
python model_completion.py --dataset-name CIFAR10 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 4 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR10_saved_framework_lr=0.1_mal_KSS_KFM_half=16.pth

echo ==== 33) Active train: GC + mal ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs %EPOCHS% --half %HALF% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --gc True --gc-preserved-percent 0.25

echo ==== 34) Active MC: GC + mal ====
python model_completion.py --dataset-name CIFAR10 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 4 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR10_saved_framework_lr=0.1_mal_gc-preserved_percent=0.25_half=16.pth

echo ==== 35) Active train: PPDL + mal ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs %EPOCHS% --half %HALF% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --ppdl True --ppdl-theta-u 0.75

echo ==== 36) Active MC: PPDL + mal ====
python model_completion.py --dataset-name CIFAR10 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 4 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR10_saved_framework_lr=0.1_mal_ppdl-theta_u=0.75_half=16.pth

echo ==== 37) Active train: Lap Noise + mal ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs %EPOCHS% --half %HALF% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --lap-noise True --noise-scale 1e-3

echo ==== 38) Active MC: Lap Noise + mal ====
python model_completion.py --dataset-name CIFAR10 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 4 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR10_saved_framework_lr=0.1_mal_lap_noise-scale=0.001_half=16.pth

echo ==== 39) Active train: Multistep Grad + mal ====
python vfl_framework.py -d CIFAR10 --path-dataset %DATA_PATH% --k 4 --epochs %EPOCHS% --half %HALF% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --multistep_grad True --multistep_grad_bins 6

echo ==== 40) Active MC: Multistep Grad + mal ====
python model_completion.py --dataset-name CIFAR10 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 4 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR10_saved_framework_lr=0.1_mal_multistep_grad_bins=6_half=16.pth

echo ==== All CIFAR10 KSS/KFM + baseline defense experiments finished! ====
pause
