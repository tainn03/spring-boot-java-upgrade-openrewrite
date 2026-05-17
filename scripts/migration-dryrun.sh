#!/bin/bash

# Script: migration-dryrun.sh
# Purpose: Run OpenRewrite migration in DRY-RUN mode (safe, no changes)
# Usage: ./migration-dryrun.sh [PROJECT_DIR]
# 
# This script:
#   1. Detects build tool (Maven or Gradle)
#   2. Runs dryRun to see what will change
#   3. Outputs report (changes + statistics)
#   4. Does NOT modify any files

set -e

PROJECT_DIR="${1:-.}"

echo "=========================================="
echo "Spring Boot 4.0 + Java 25 Migration"
echo "DRY-RUN MODE (No changes will be made)"
echo "=========================================="
echo ""

# Detect build tool
TOOL_SCRIPT="$(dirname "$0")/detect-build-tool.sh"
if [ ! -f "$TOOL_SCRIPT" ]; then
    echo "ERROR: detect-build-tool.sh not found"
    exit 1
fi

BUILD_TOOL=$("$TOOL_SCRIPT" "$PROJECT_DIR")

if [ "$BUILD_TOOL" = "UNKNOWN" ]; then
    echo "❌ ERROR: No pom.xml or build.gradle found in $PROJECT_DIR"
    echo "Make sure you're running this from your project root"
    exit 1
fi

echo "✓ Detected build tool: $BUILD_TOOL"
echo ""

cd "$PROJECT_DIR"

if [ "$BUILD_TOOL" = "MAVEN" ]; then
    echo "Running Maven OpenRewrite DRY-RUN..."
    echo ""
    ./mvnw rewrite:dryRun 2>&1 || {
        echo "❌ Maven rewrite:dryRun failed"
        echo "Make sure OpenRewrite plugin is configured in pom.xml"
        exit 1
    }
    
elif [ "$BUILD_TOOL" = "GRADLE" ]; then
    echo "Running Gradle OpenRewrite DRY-RUN..."
    echo ""
    ./gradlew rewriteDryRun 2>&1 || {
        echo "❌ Gradle rewriteDryRun failed"
        echo "Make sure OpenRewrite plugin is configured in build.gradle"
        exit 1
    }
fi

echo ""
echo "=========================================="
echo "✅ DRY-RUN COMPLETE"
echo "=========================================="
echo ""
echo "📋 Changes preview:"
echo "   - See output above for file changes"
echo "   - Check 'rewrite-datatables/' for detailed reports"
echo ""
echo "Next steps:"
echo "  1. Review the changes shown above"
echo "  2. If satisfied, run: ./migration-run.sh"
echo "  3. If issues found, fix them first and re-run this script"
echo ""
