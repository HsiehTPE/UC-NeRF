#!/usr/bin/env bash
set -euo pipefail

EXP_NAME="train_scared"
BASE_DIR="./logs"
LOG_DIR="${BASE_DIR}/${EXP_NAME}"
LOG_FILE="${LOG_DIR}/train.log"

mkdir -p "${LOG_DIR}"

CUDA_VISIBLE_DEVICES=0 python train.py \
   --expname "${EXP_NAME}" \
   --basedir "${BASE_DIR}" \
   --use_viewdirs True \
   --dataset_name scared \
   --datadir <your_scared_data_folder> \
   --view_num 7 \
   --num_epochs 30 \
   --lrate 2e-4 \
   --patch_size 6 \
   --patch_num 50 \
   --ckpt ./pretrained_weights/ucnerf.tar \
   2>&1 | tee -a "${LOG_FILE}"
