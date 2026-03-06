:: ============================================================
:: run_yahoo_all_defenses.bat
:: Yahoo: No defense, KSS, KFM, KSS+KFM, GC, PPDL, Lap, Multistep
:: For each: model accuracy, Direct attack, Passive MC, Active+MC
:: Note: Yahoo uses MixText model and model_completion_mixtext.py
:: ============================================================

@echo off

:: ---------- 0. Common settings ----------
set DATA_PATH=./data/yahoo_answers_csv/
set EPOCHS=25
set K=5
set LR=1e-3
set BATCH_SIZE=16
set STONE1=15
set STONE2=25
set N_LABELED=10
set MC_EPOCHS=10

:: ============================================================
:: 1. Training: obtain models under different defenses
:: ============================================================

echo ==== 1) Train Yahoo: No defense ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% --lr %LR% -b %BATCH_SIZE% --stone1 %STONE1% --stone2 %STONE2%

echo ==== 2) Train Yahoo: KSS only ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% --lr %LR% -b %BATCH_SIZE% --stone1 %STONE1% --stone2 %STONE2% ^
  --kss --kss-pmin 0.2 --kss-pmax 0.8

echo ==== 3) Train Yahoo: KFM only ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% --lr %LR% -b %BATCH_SIZE% --stone1 %STONE1% --stone2 %STONE2% ^
  --kfm --kfm-beta 0.5

echo ==== 4) Train Yahoo: KSS + KFM ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% --lr %LR% -b %BATCH_SIZE% --stone1 %STONE1% --stone2 %STONE2% ^
  --kss --kss-pmin 0.2 --kss-pmax 0.8 --kfm --kfm-beta 0.5

echo ==== 5) Train Yahoo: Baseline GC ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% --lr %LR% -b %BATCH_SIZE% --stone1 %STONE1% --stone2 %STONE2% ^
  --gc True --gc-preserved-percent 0.25

echo ==== 6) Train Yahoo: Baseline PPDL ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% --lr %LR% -b %BATCH_SIZE% --stone1 %STONE1% --stone2 %STONE2% ^
  --ppdl True --ppdl-theta-u 0.75

echo ==== 7) Train Yahoo: Baseline Lap Noise ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% --lr %LR% -b %BATCH_SIZE% --stone1 %STONE1% --stone2 %STONE2% ^
  --lap-noise True --noise-scale 1e-3

echo ==== 8) Train Yahoo: Baseline Multistep Grad ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% --lr %LR% -b %BATCH_SIZE% --stone1 %STONE1% --stone2 %STONE2% ^
  --multistep_grad True --multistep_grad_bins 6

:: ============================================================
:: 2. Direct attack (no top model) under each defense
:: ============================================================

echo ==== 9) Direct attack: No defense ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs 1 --lr %LR% -b %BATCH_SIZE% --use-top-model False

echo ==== 10) Direct attack: KSS ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs 1 --lr %LR% -b %BATCH_SIZE% --use-top-model False ^
  --kss --kss-pmin 0.2 --kss-pmax 0.8

echo ==== 11) Direct attack: KFM ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs 1 --lr %LR% -b %BATCH_SIZE% --use-top-model False ^
  --kfm --kfm-beta 0.5

echo ==== 12) Direct attack: KSS + KFM ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs 1 --lr %LR% -b %BATCH_SIZE% --use-top-model False ^
  --kss --kss-pmin 0.2 --kss-pmax 0.8 --kfm --kfm-beta 0.5

echo ==== 13) Direct attack: GC ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs 1 --lr %LR% -b %BATCH_SIZE% --use-top-model False ^
  --gc True --gc-preserved-percent 0.25

echo ==== 14) Direct attack: PPDL ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs 1 --lr %LR% -b %BATCH_SIZE% --use-top-model False ^
  --ppdl True --ppdl-theta-u 0.75

echo ==== 15) Direct attack: Lap Noise ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs 1 --lr %LR% -b %BATCH_SIZE% --use-top-model False ^
  --lap-noise True --noise-scale 1e-3

echo ==== 16) Direct attack: Multistep Grad ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs 1 --lr %LR% -b %BATCH_SIZE% --use-top-model False ^
  --multistep_grad True --multistep_grad_bins 6

:: ============================================================
:: 3. Passive attack (Model Completion with MixText)
:: Note: Yahoo uses model_completion_mixtext.py
:: n-labeled represents n-labeled-per-class for Yahoo
:: ============================================================

echo ==== 17) Passive MC: No defense ====
python model_completion_mixtext.py --n-labeled %N_LABELED% --epochs %MC_EPOCHS% ^
  --resume-name Yahoo_saved_framework_lr=0.001_normal_.pth

echo ==== 18) Passive MC: KSS ====
python model_completion_mixtext.py --n-labeled %N_LABELED% --epochs %MC_EPOCHS% ^
  --resume-name Yahoo_saved_framework_lr=0.001_normal_KSS_.pth

echo ==== 19) Passive MC: KFM ====
python model_completion_mixtext.py --n-labeled %N_LABELED% --epochs %MC_EPOCHS% ^
  --resume-name Yahoo_saved_framework_lr=0.001_normal_KFM_.pth

echo ==== 20) Passive MC: KSS + KFM ====
python model_completion_mixtext.py --n-labeled %N_LABELED% --epochs %MC_EPOCHS% ^
  --resume-name Yahoo_saved_framework_lr=0.001_normal_KSS_KFM_.pth

echo ==== 21) Passive MC: GC baseline ====
python model_completion_mixtext.py --n-labeled %N_LABELED% --epochs %MC_EPOCHS% ^
  --resume-name Yahoo_saved_framework_lr=0.001_normal_gc-preserved_percent=0.25_.pth

echo ==== 22) Passive MC: PPDL baseline ====
python model_completion_mixtext.py --n-labeled %N_LABELED% --epochs %MC_EPOCHS% ^
  --resume-name Yahoo_saved_framework_lr=0.001_normal_ppdl-theta_u=0.75_.pth

echo ==== 23) Passive MC: Lap Noise baseline ====
python model_completion_mixtext.py --n-labeled %N_LABELED% --epochs %MC_EPOCHS% ^
  --resume-name Yahoo_saved_framework_lr=0.001_normal_lap_noise-scale=0.001_.pth

echo ==== 24) Passive MC: Multistep Grad baseline ====
python model_completion_mixtext.py --n-labeled %N_LABELED% --epochs %MC_EPOCHS% ^
  --resume-name Yahoo_saved_framework_lr=0.001_normal_multistep_grad_bins=6_.pth

:: ============================================================
:: 4. Active attack (malicious optimizer) + MC
:: ============================================================

echo ==== 25) Active train: No defense (mal) ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% --lr %LR% -b %BATCH_SIZE% --stone1 %STONE1% --stone2 %STONE2% ^
  --use-mal-optim True --use-mal-optim-all False

echo ==== 26) Active MC: No defense (mal) ====
python model_completion_mixtext.py --n-labeled %N_LABELED% --epochs %MC_EPOCHS% ^
  --resume-name Yahoo_saved_framework_lr=0.001_mal_.pth

echo ==== 27) Active train: KSS + mal ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% --lr %LR% -b %BATCH_SIZE% --stone1 %STONE1% --stone2 %STONE2% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --kss --kss-pmin 0.2 --kss-pmax 0.8

echo ==== 28) Active MC: KSS + mal ====
python model_completion_mixtext.py --n-labeled %N_LABELED% --epochs %MC_EPOCHS% ^
  --resume-name Yahoo_saved_framework_lr=0.001_mal_KSS_.pth

echo ==== 29) Active train: KFM + mal ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% --lr %LR% -b %BATCH_SIZE% --stone1 %STONE1% --stone2 %STONE2% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --kfm --kfm-beta 0.5

echo ==== 30) Active MC: KFM + mal ====
python model_completion_mixtext.py --n-labeled %N_LABELED% --epochs %MC_EPOCHS% ^
  --resume-name Yahoo_saved_framework_lr=0.001_mal_KFM_.pth

echo ==== 31) Active train: KSS + KFM + mal ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% --lr %LR% -b %BATCH_SIZE% --stone1 %STONE1% --stone2 %STONE2% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --kss --kss-pmin 0.2 --kss-pmax 0.8 --kfm --kfm-beta 0.5

echo ==== 32) Active MC: KSS + KFM + mal ====
python model_completion_mixtext.py --n-labeled %N_LABELED% --epochs %MC_EPOCHS% ^
  --resume-name Yahoo_saved_framework_lr=0.001_mal_KSS_KFM_.pth

echo ==== 33) Active train: GC + mal ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% --lr %LR% -b %BATCH_SIZE% --stone1 %STONE1% --stone2 %STONE2% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --gc True --gc-preserved-percent 0.25

echo ==== 34) Active MC: GC + mal ====
python model_completion_mixtext.py --n-labeled %N_LABELED% --epochs %MC_EPOCHS% ^
  --resume-name Yahoo_saved_framework_lr=0.001_mal_gc-preserved_percent=0.25_.pth

echo ==== 35) Active train: PPDL + mal ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% --lr %LR% -b %BATCH_SIZE% --stone1 %STONE1% --stone2 %STONE2% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --ppdl True --ppdl-theta-u 0.75

echo ==== 36) Active MC: PPDL + mal ====
python model_completion_mixtext.py --n-labeled %N_LABELED% --epochs %MC_EPOCHS% ^
  --resume-name Yahoo_saved_framework_lr=0.001_mal_ppdl-theta_u=0.75_.pth

echo ==== 37) Active train: Lap Noise + mal ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% --lr %LR% -b %BATCH_SIZE% --stone1 %STONE1% --stone2 %STONE2% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --lap-noise True --noise-scale 1e-3

echo ==== 38) Active MC: Lap Noise + mal ====
python model_completion_mixtext.py --n-labeled %N_LABELED% --epochs %MC_EPOCHS% ^
  --resume-name Yahoo_saved_framework_lr=0.001_mal_lap_noise-scale=0.001_.pth

echo ==== 39) Active train: Multistep Grad + mal ====
python vfl_framework.py -d Yahoo --path-dataset %DATA_PATH% --k %K% --epochs %EPOCHS% --lr %LR% -b %BATCH_SIZE% --stone1 %STONE1% --stone2 %STONE2% ^
  --use-mal-optim True --use-mal-optim-all False ^
  --multistep_grad True --multistep_grad_bins 6

echo ==== 40) Active MC: Multistep Grad + mal ====
python model_completion_mixtext.py --n-labeled %N_LABELED% --epochs %MC_EPOCHS% ^
  --resume-name Yahoo_saved_framework_lr=0.001_mal_multistep_grad_bins=6_.pth

echo ==== All Yahoo KSS/KFM + baseline defense experiments finished! ====
pause
