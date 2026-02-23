#!/usr/bin/env bash
set -euo pipefail

EXP_NAME="train_scared"
BASE_DIR="./logs"
LOG_DIR="${BASE_DIR}/${EXP_NAME}"
LOG_FILE="${LOG_DIR}/train.log"
NOTIFY_SCRIPT="./scripts/feishu_notify.py"
START_TS="$(date '+%F %T')"

mkdir -p "${LOG_DIR}"

notify() {
  local message="$1"
  if [ -n "${FEISHU_WEBHOOK:-}" ] && [ -f "${NOTIFY_SCRIPT}" ]; then
    python "${NOTIFY_SCRIPT}" "${message}" || true
  fi
}

classify_error() {
  if [ ! -f "${LOG_FILE}" ]; then
    echo "未知错误"
    return
  fi

  if grep -q "CUDA out of memory" "${LOG_FILE}"; then
    echo "显存不足(CUDA OOM)"
  elif grep -q "No such file or directory" "${LOG_FILE}"; then
    echo "路径/文件不存在"
  elif grep -q "ModuleNotFoundError" "${LOG_FILE}"; then
    echo "Python依赖缺失(ModuleNotFoundError)"
  elif grep -q "RuntimeError" "${LOG_FILE}"; then
    echo "运行时错误(RuntimeError)"
  elif grep -q "Traceback (most recent call last)" "${LOG_FILE}"; then
    echo "Python异常(见Traceback)"
  else
    echo "未知错误"
  fi
}

on_exit() {
  local exit_code="$1"
  local end_ts
  end_ts="$(date '+%F %T')"

  if [ "${exit_code}" -eq 0 ]; then
    notify "✅ [${EXP_NAME}] 实验结束\n开始时间: ${START_TS}\n结束时间: ${end_ts}\n日志: ${LOG_FILE}"
  else
    local err_type
    err_type="$(classify_error)"
    notify "❌ [${EXP_NAME}] 实验报错\n开始时间: ${START_TS}\n结束时间: ${end_ts}\n报错类别: ${err_type}\n退出码: ${exit_code}\n日志: ${LOG_FILE}"
  fi
}

trap 'on_exit $?' EXIT

notify "🚀 [${EXP_NAME}] 实验开始\n开始时间: ${START_TS}\n日志: ${LOG_FILE}"

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
