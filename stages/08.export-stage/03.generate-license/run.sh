#!/bin/bash
# SPDX-License-Identifier: BSD-3-Clause
#
# kuiper2.0 - Embedded Linux for Analog Devices Products
#
# Copyright (c) 2025 Analog Devices, Inc.
# Author: Larisa Radu <larisa.radu@analog.com>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOL_BIN_DIR="/usr/local/bin"

install_anchore_tools() {
    echo "=== Checking/Installing Anchore SBOM tools ==="

    # Install syft
    if ! command -v syft &> /dev/null; then
        echo "Installing syft..."
        wget -qO- https://get.anchore.io/syft | sh -s -- -b "${TOOL_BIN_DIR}"
    else
        echo "syft already installed: $(syft version 2>/dev/null | head -1)"
    fi

    # Install grype
    if ! command -v grype &> /dev/null; then
        echo "Installing grype..."
        wget -qO- https://get.anchore.io/grype | sh -s -- -b "${TOOL_BIN_DIR}"
    else
        echo "grype already installed: $(grype version 2>/dev/null | head -1)"
    fi

    # Install grant
    if ! command -v grant &> /dev/null; then
        echo "Installing grant..."
        wget -qO- https://get.anchore.io/grant | sh -s -- -b "${TOOL_BIN_DIR}"
    else
        echo "grant already installed: $(grant version 2>/dev/null | head -1)"
    fi

    echo "=== Anchore tools ready ==="
}

generate_sboms() {
    echo "=== Generating SBOMs with syft ==="

    local output_dir="kuiper-volume/licensing"
    local sbom_spdx="${output_dir}/sbom.spdx.json"
    local sbom_cyclonedx="${output_dir}/sbom.cyclonedx.json"

    echo "Scanning ${BUILD_DIR} for packages..."
    echo "This may take a few minutes..."

    SYFT_FILE_METADATA_SELECTION=all syft dir:"${BUILD_DIR}" \
        --output spdx-json="${sbom_spdx}" \
        --output cyclonedx-json="${sbom_cyclonedx}" \
        --quiet

    echo "Generated: ${sbom_spdx}"
    echo "Generated: ${sbom_cyclonedx}"

    # Print summary
    local pkg_count
    pkg_count=$(jq '.packages | length' "${sbom_spdx}" 2>/dev/null || echo "unknown")
    echo "Total packages detected: ${pkg_count}"

    echo "=== SBOM generation complete ==="
}

run_grype_scan() {
    echo "=== Running Grype vulnerability scan ==="

    local output_dir="kuiper-volume/licensing"
    local sbom_spdx="${output_dir}/sbom.spdx.json"
    local vuln_report="${output_dir}/vulnerabilities.json"
    local vuln_summary="${output_dir}/vulnerabilities-summary.txt"

    if [[ ! -f "${sbom_spdx}" ]]; then
        echo "ERROR: SBOM not found at ${sbom_spdx}"
        return 1
    fi

    echo "Scanning SBOM for known vulnerabilities..."
    echo "(First run will download vulnerability database ~500MB)"

    # Run grype and output JSON report
    grype sbom:"${sbom_spdx}" \
        --output json \
        --file "${vuln_report}" \
        --quiet || true

    echo "Generated: ${vuln_report}"

    # Generate human-readable summary
    if [[ -f "${vuln_report}" ]]; then
        echo "=== Vulnerability Summary ===" > "${vuln_summary}"
        echo "Generated: $(date -Iseconds)" >> "${vuln_summary}"
        echo "" >> "${vuln_summary}"

        local critical high medium low
        critical=$(jq '[.matches[] | select(.vulnerability.severity == "Critical")] | length' "${vuln_report}" 2>/dev/null || echo 0)
        high=$(jq '[.matches[] | select(.vulnerability.severity == "High")] | length' "${vuln_report}" 2>/dev/null || echo 0)
        medium=$(jq '[.matches[] | select(.vulnerability.severity == "Medium")] | length' "${vuln_report}" 2>/dev/null || echo 0)
        low=$(jq '[.matches[] | select(.vulnerability.severity == "Low")] | length' "${vuln_report}" 2>/dev/null || echo 0)

        echo "Critical: ${critical}" >> "${vuln_summary}"
        echo "High:     ${high}" >> "${vuln_summary}"
        echo "Medium:   ${medium}" >> "${vuln_summary}"
        echo "Low:      ${low}" >> "${vuln_summary}"

        echo "Generated: ${vuln_summary}"
        echo "Vulnerabilities found - Critical: ${critical}, High: ${high}, Medium: ${medium}, Low: ${low}"
    fi

    echo "=== Grype scan complete ==="
}

run_grant_check() {
    echo "=== Running Grant license compliance check ==="

    local output_dir="kuiper-volume/licensing"
    local sbom_spdx="${output_dir}/sbom.spdx.json"
    local license_report="${output_dir}/licenses.json"
    local license_summary="${output_dir}/licenses-summary.txt"

    if [[ ! -f "${sbom_spdx}" ]]; then
        echo "ERROR: SBOM not found at ${sbom_spdx}"
        return 1
    fi

    echo "Analyzing licenses in SBOM..."

    # Run grant list to get all licenses (don't fail on policy violations)
    grant list "${sbom_spdx}" \
        --output json > "${license_report}" 2>/dev/null || true

    echo "Generated: ${license_report}"

    # Generate human-readable summary
    if [[ -f "${license_report}" ]]; then
        echo "=== License Summary ===" > "${license_summary}"
        echo "Generated: $(date -Iseconds)" >> "${license_summary}"
        echo "" >> "${license_summary}"

        # Extract unique licenses
        echo "Unique licenses found:" >> "${license_summary}"
        jq -r '.[].licenses[]?.name // .[].licenses[]?.id // "Unknown"' "${license_report}" 2>/dev/null | \
            sort | uniq -c | sort -rn >> "${license_summary}" || echo "  (unable to parse)" >> "${license_summary}"

        echo "Generated: ${license_summary}"
    fi

    echo "=== Grant check complete ==="
}

main() {
    echo "============================================================"
    echo "License Generation Stage"
    echo "============================================================"
    echo "BUILD_DIR: ${BUILD_DIR}"
    echo ""

    # Create output directories
    mkdir -p kuiper-volume/licensing
    mkdir -p "${BUILD_DIR}/licensing/copyright"

    # --- NEW: Anchore SBOM tools (runs on host) ---
    install_anchore_tools
    generate_sboms
    run_grype_scan
    run_grant_check

    # --- EXISTING: HTML license generation (runs in chroot) ---
    echo ""
    echo "=== Running existing HTML license generation (for comparison) ==="
    mount --bind kuiper-volume/licensing "${BUILD_DIR}/licensing"

    chroot "${BUILD_DIR}" << EOF
	bash stages/08.export-stage/03.generate-license/run-chroot.sh
EOF

    cp -r "${SCRIPT_DIR}/img/" kuiper-volume/licensing

    umount "${BUILD_DIR}/licensing"

    # Cleanup
    rm -rf "${BUILD_DIR}/stages"
    rm -rf "${BUILD_DIR}/licensing"
}

main "$@"
