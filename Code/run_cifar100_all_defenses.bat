:: ============================================================
:: run_cifar100_all_defenses.bat
:: CIFAR-100: No defense, KSS, KFM, KSS+KFM, GC, PPDL, Lap, Multistep
:: ============================================================

@echo off

set DATA_PATH=./data/CIFAR100
set EPOCHS=150
set HALF=16
set N_LABELED=40

:: 1. Training
echo ==== 1) Train CIFAR100: No defense ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs %EPOCHS% --half %HALF%

echo ==== 2) Train CIFAR100: KSS only ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs %EPOCHS% --half %HALF% ^
  --kss --kss-pmin 0.5 --kss-pmax 0.8

echo ==== 3) Train CIFAR100: KFM only ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs %EPOCHS% --half %HALF% ^
  --kfm --kfm-beta 0.2

echo ==== 4) Train CIFAR100: KSS + KFM ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs %EPOCHS% --half %HALF% ^
  --kss --kss-pmin 0.5 --kss-pmax 0.8 --kfm --kfm-beta 0.2

echo ==== 5) Train CIFAR100: GC ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs %EPOCHS% --half %HALF% ^
  --gc True --gc-preserved-percent 0.25

echo ==== 6) Train CIFAR100: PPDL ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs %EPOCHS% --half %HALF% ^
  --ppdl True --ppdl-theta-u 0.75

echo ==== 7) Train CIFAR100: Lap Noise ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs %EPOCHS% --half %HALF% ^
  --lap-noise True --noise-scale 1e-3

echo ==== 8) Train CIFAR100: Multistep Grad ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs %EPOCHS% --half %HALF% ^
  --multistep_grad True --multistep_grad_bins 6

:: 2. Direct attack (No top model)
echo ==== 9) Direct attack: No defense ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs 1 --half %HALF% --use-top-model False

echo ==== 10) Direct attack: KSS ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs 1 --half %HALF% --use-top-model False ^
  --kss --kss-pmin 0.2 --kss-pmax 0.8

echo ==== 11) Direct attack: KFM ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs 1 --half %HALF% --use-top-model False ^
  --kfm --kfm-beta 0.5

echo ==== 12) Direct attack: KSS + KFM ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs 1 --half %HALF% --use-top-model False ^
  --kss --kss-pmin 0.2 --kss-pmax 0.8 --kfm --kfm-beta 0.5

echo ==== 13) Direct attack: GC ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs 1 --half %HALF% --use-top-model False ^
  --gc True --gc-preserved-percent 0.25

echo ==== 14) Direct attack: PPDL ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs 1 --half %HALF% --use-top-model False ^
  --ppdl True --ppdl-theta-u 0.75

echo ==== 15) Direct attack: Lap Noise ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs 1 --half %HALF% --use-top-model False ^
  --lap-noise True --noise-scale 1e-3

echo ==== 16) Direct attack: Multistep Grad ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs 1 --half %HALF% --use-top-model False ^
  --multistep_grad True --multistep_grad_bins 6

:: 3. Passive MC (注意修改 resume-name 为实际文件名)
echo ==== 17) Passive MC: No defense ====
python model_completion.py --dataset-name CIFAR100 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 5 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR100_saved_framework_lr=0.1_normal_half=16.pth

echo ==== 18) Passive MC: KSS ====
python model_completion.py --dataset-name CIFAR100 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 5 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR100_saved_framework_lr=0.1_normal_KSS_half=16.pth

echo ==== 19) Passive MC: KFM ====
python model_completion.py --dataset-name CIFAR100 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 5 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR100_saved_framework_lr=0.1_normal_KFM_half=16.pth

echo ==== 20) Passive MC: KSS + KFM ====
python model_completion.py --dataset-name CIFAR100 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 5 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR100_saved_framework_lr=0.1_normal_KSS_KFM_half=16.pth

echo ==== 21) Passive MC: GC ====
python model_completion.py --dataset-name CIFAR100 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 5 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR100_saved_framework_lr=0.1_normal_gc-preserved_percent=0.25_half=16.pth

echo ==== 22) Passive MC: PPDL ====
python model_completion.py --dataset-name CIFAR100 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 5 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR100_saved_framework_lr=0.1_normal_ppdl-theta_u=0.75_half=16.pth

echo ==== 23) Passive MC: Lap Noise ====
python model_completion.py --dataset-name CIFAR100 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 5 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR100_saved_framework_lr=0.1_normal_lap_noise-scale=0.001_half=16.pth

echo ==== 24) Passive MC: Multistep Grad ====
python model_completion.py --dataset-name CIFAR100 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 5 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR100_saved_framework_lr=0.1_normal_multistep_grad_bins=6_half=16.pth

:: 4. Active (malicious optimizer) + MC
echo ==== 25) Active train: No defense (mal) ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs %EPOCHS% --half %HALF% ^
  --use-mal-optim True --use-mal-optim-all False

echo ==== 26) Active MC: No defense (mal) ====
python model_completion.py --dataset-name CIFAR100 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 5 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR100_saved_framework_lr=0.1_mal_half=16.pth

echo ==== 27) Active train: KSS + mal ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs %EPOCHS% --half %HALF% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --kss --kss-pmin 0.2 --kss-pmax 0.8

echo ==== 28) Active MC: KSS + mal ====
python model_completion.py --dataset-name CIFAR100 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 5 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR100_saved_framework_lr=0.1_mal_KSS_half=16.pth

echo ==== 29) Active train: KFM + mal ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs %EPOCHS% --half %HALF% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --kfm --kfm-beta 0.5

echo ==== 30) Active MC: KFM + mal ====
python model_completion.py --dataset-name CIFAR100 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 5 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR100_saved_framework_lr=0.1_mal_KFM_half=16.pth

echo ==== 31) Active train: KSS + KFM + mal ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs %EPOCHS% --half %HALF% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --kss --kss-pmin 0.2 --kss-pmax 0.8 --kfm --kfm-beta 0.5

echo ==== 32) Active MC: KSS + KFM + mal ====
python model_completion.py --dataset-name CIFAR100 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 5 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR100_saved_framework_lr=0.1_mal_KSS_KFM_half=16.pth

echo ==== 33) Active train: GC + mal ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs %EPOCHS% --half %HALF% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --gc True --gc-preserved-percent 0.25

echo ==== 34) Active MC: GC + mal ====
python model_completion.py --dataset-name CIFAR100 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 5 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR100_saved_framework_lr=0.1_mal_gc-preserved_percent=0.25_half=16.pth

echo ==== 35) Active train: PPDL + mal ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs %EPOCHS% --half %HALF% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --ppdl True --ppdl-theta-u 0.75

echo ==== 36) Active MC: PPDL + mal ====
python model_completion.py --dataset-name CIFAR100 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 5 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR100_saved_framework_lr=0.1_mal_ppdl-theta_u=0.75_half=16.pth

echo ==== 37) Active train: Lap Noise + mal ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs %EPOCHS% --half %HALF% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --lap-noise True --noise-scale 1e-3

echo ==== 38) Active MC: Lap Noise + mal ====
python model_completion.py --dataset-name CIFAR100 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 5 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR100_saved_framework_lr=0.1_mal_lap_noise-scale=0.001_half=16.pth

echo ==== 39) Active train: Multistep Grad + mal ====
python vfl_framework.py -d CIFAR100 --path-dataset %DATA_PATH% --k 5 --epochs %EPOCHS% --half %HALF% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --multistep_grad True --multistep_grad_bins 6

echo ==== 40) Active MC: Multistep Grad + mal ====
python model_completion.py --dataset-name CIFAR100 --dataset-path %DATA_PATH% ^
  --n-labeled %N_LABELED% --party-num 2 --half %HALF% --k 5 --epochs 25 --print-to-txt 1 ^
  --resume-name CIFAR100_saved_framework_lr=0.1_mal_multistep_grad_bins=6_half=16.pth

echo ==== All CIFAR100 experiments finished! ====
pause
