#!/bin/bash

# Script: detect-build-tool.sh
# Purpose: Auto-detect Maven vs Gradle and output appropriate commands
# Usage: ./detect-build-tool.sh
# Output: MAVEN or GRADLE

set -e

PROJECT_ROOT="${1:-.}"

# Check for Maven
if [ -f "$PROJECT_ROOT/pom.xml" ]; then
    echo "MAVEN"
    exit 0
fi

# Check for Gradle (Kotlin DSL)
if [ -f "$PROJECT_ROOT/build.gradle.kts" ]; then
    echo "GRADLE"
    exit 0
fi

# Check for Gradle (Groovy DSL)
if [ -f "$PROJECT_ROOT/build.gradle" ]; then
    echo "GRADLE"
    exit 0
fi

# Default fallback
echo "UNKNOWN"
exit 1
