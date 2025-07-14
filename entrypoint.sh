#!/bin/bash

exit_with_err() {
  local msg="${1?}"
  echo "ERROR: ${msg}"
  exit 1
}

function run_orca_container_scan() {
  cd "${GITHUB_WORKSPACE}" || exit_with_err "could not find GITHUB_WORKSPACE: ${GITHUB_WORKSPACE}"
  echo "Running Orca Container Image scan:"
  echo orca-cli "${GLOBAL_FLAGS[@]}" image scan "${SCAN_FLAGS[@]}"
  orca-cli "${GLOBAL_FLAGS[@]}" image scan "${SCAN_FLAGS[@]}"
  export ORCA_EXIT_CODE=$?

  echo "exit_code=${ORCA_EXIT_CODE}" >>"$GITHUB_OUTPUT"  
}

function set_global_flags() {
  GLOBAL_FLAGS=()
  if [ "${INPUT_EXIT_CODE}" ]; then
    GLOBAL_FLAGS+=(--exit-code "${INPUT_EXIT_CODE}")
  fi
  if [ "${INPUT_NO_COLOR}" == "true" ]; then
    GLOBAL_FLAGS+=(--no-color)
  fi
  if [ "${INPUT_PROJECT_KEY}" ]; then
    GLOBAL_FLAGS+=(--project-key "${INPUT_PROJECT_KEY}")
  fi
  if [ "${INPUT_SILENT}" == "true" ]; then
    GLOBAL_FLAGS+=(--silent)
  fi
  if [ "${INPUT_CONFIG}" ]; then
    GLOBAL_FLAGS+=(--config "${INPUT_CONFIG}")
  fi
  if [ "${INPUT_DISABLE_ERR_REPORT}" == "true" ]; then
    GLOBAL_FLAGS+=(--disable-err-report)
  fi
  if [ "${INPUT_DISPLAY_NAME}" ]; then
    GLOBAL_FLAGS+=(--display-name "${INPUT_DISPLAY_NAME}")
  fi
  if [ "${INPUT_DEBUG}" == "true" ]; then
    GLOBAL_FLAGS+=(--debug)
  fi
  if [ "${INPUT_DISABLE_ACTIVE_VERIFICATION}" == "true" ]; then
    GLOBAL_FLAGS+=(--disable-active-verification)
  fi
  if [ "${INPUT_LOG_PATH}" ]; then
    GLOBAL_FLAGS+=(--log-path "${INPUT_LOG_PATH}")
  fi
}

# Json format must be reported and be stored in a file for github annotations
function prepare_json_to_file_flags() {
  # Output directory must be provided to store the json results
  OUTPUT_FOR_JSON="${INPUT_OUTPUT}"
  CONSOLE_OUTPUT_FOR_JSON="${INPUT_CONSOLE_OUTPUT}"
  if [[ -z "${INPUT_OUTPUT}" ]]; then
    # Results should be printed to console in the selected format
    CONSOLE_OUTPUT_FOR_JSON="${INPUT_FORMAT:-table}"
    # Results should also be stored in a directory
    OUTPUT_FOR_JSON="orca_results/"
  fi

  if [[ -z "${INPUT_FORMAT}" ]]; then
    # The default format should be provided together with the one we are adding
    FORMATS_FOR_JSON="table,json"
  else
    if [[ "${INPUT_FORMAT}" == *"json"* ]]; then
      FORMATS_FOR_JSON="${INPUT_FORMAT}"
    else
      FORMATS_FOR_JSON="${INPUT_FORMAT},json"
    fi
  fi

  # Used during the annotation process
  export OUTPUT_FOR_JSON CONSOLE_OUTPUT_FOR_JSON FORMATS_FOR_JSON
}

function set_container_scan_flags() {
  SCAN_FLAGS=()
  if [ "${INPUT_IMAGE}" ]; then
    SCAN_FLAGS+=("${INPUT_IMAGE}")
  fi
  if [ "${INPUT_TAR_ARCHIVE}" ]; then
    SCAN_FLAGS+=(--tar-archive)
  fi
  if [ "${INPUT_TIMEOUT}" ]; then
    SCAN_FLAGS+=(--timeout "${INPUT_TIMEOUT}")
  fi
  if [ "${INPUT_IGNORE_FAILED_EXEC_CONTROLS}" == "true" ]; then
    SCAN_FLAGS+=(--ignore-failed-exec-controls)
  fi
  if [ "${INPUT_OCI}" == "true" ]; then
    SCAN_FLAGS+=(--oci)
  fi
  if [ "${INPUT_DISABLE_SECRET}" = "true" ]; then
    SCAN_FLAGS+=(--disable-secret)
  fi
  if [ "${INPUT_EXCEPTIONS_FILEPATH}" ]; then
    SCAN_FLAGS+=(--exceptions-filepath "${INPUT_EXCEPTIONS_FILEPATH}")
  fi
  if [ "${INPUT_HIDE_VULNERABILITIES}" = "true" ]; then
    SCAN_FLAGS+=(--hide-vulnerabilities)
  fi
  if [ "${INPUT_NUM_CPU}" ]; then
    SCAN_FLAGS+=(--num-cpu "${NUM_CPU}")
  fi
  if [ "${INPUT_SHOW_FAILED_ISSUES_ONLY}" = "true" ]; then
    SCAN_FLAGS+=(--show-failed-issues-only)
  fi
  if [ "${FORMATS_FOR_JSON}" ]; then
    SCAN_FLAGS+=(--format "${FORMATS_FOR_JSON}")
  fi
  if [ "${OUTPUT_FOR_JSON}" ]; then
    SCAN_FLAGS+=(--output "${OUTPUT_FOR_JSON}")
  fi
  if [ "${CONSOLE_OUTPUT_FOR_JSON}" ]; then
    SCAN_FLAGS+=(--console-output="${CONSOLE_OUTPUT_FOR_JSON}")
  fi
  if [ "${INPUT_SKIP_REMOTE_LOOKUP}" == "true" ]; then
    SCAN_FLAGS+=(--skip-remote-lookup)
  fi
  if [ "${INPUT_CUSTOM_SECRET_CONTROLS}" ]; then
    SCAN_FLAGS+=(--custom-secret-controls="${INPUT_CUSTOM_SECRET_CONTROLS}")
  fi
  if [ "${INPUT_HIDE_SKIPPED_VULNERABILITIES}" == "true"  ]; then
    SCAN_FLAGS+=(--hide-skipped-vulnerabilities)
  fi
  if [ "${INPUT_MAX_SECRET}" ]; then
    SCAN_FLAGS+=(--max-secret "${INPUT_MAX_SECRET}")
  fi
  if [ "${INPUT_EXCLUDE_PATHS}" ]; then
    SCAN_FLAGS+=(--exclude-paths "${INPUT_EXCLUDE_PATHS}")
  fi
  if [ "${INPUT_DEPENDENCY_TREE}" == "true" ]; then
    SCAN_FLAGS+=(--dependency-tree)
  fi
  if [ "${INPUT_IMAGE_CORRELATION_ID}" ]; then
    SCAN_FLAGS+=(--image-correlation-id "${INPUT_IMAGE_CORRELATION_ID}")
  fi
}

function set_env_vars() {
  if [ "${INPUT_API_TOKEN}" ]; then
    export ORCA_SECURITY_API_TOKEN="${INPUT_API_TOKEN}"
  fi
}

function validate_flags() {
  [[ -n "${INPUT_API_TOKEN}" ]] || exit_with_err "api_token must be provided"
  [[ -n "${INPUT_PROJECT_KEY}" ]] || exit_with_err "project_key must be provided"
  [[ -z "${INPUT_OUTPUT}" ]] || [[ "${INPUT_OUTPUT}" == */ ]] || [[ -d "${INPUT_OUTPUT}" ]] || exit_with_err "output must be a folder (end with /)"
}

function main() {
  validate_flags
  set_env_vars
  set_global_flags
  prepare_json_to_file_flags
  set_container_scan_flags
  run_orca_container_scan
  exit "${ORCA_EXIT_CODE}"
}

main "${@}"
