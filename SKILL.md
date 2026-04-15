---
name: spring-boot-java-upgrade-openrewrite
description: Use this skill when the user asks to upgrade Java from 17 to 21 and Spring Boot from 3.5.x to 4.0.x for Maven or Gradle projects using OpenRewrite. Always safe with dry-run, diff review, and testing.
---

# Upgrade Spring Boot 4.0 + Java 21 Using OpenRewrite

## When to use this skill
Use this skill when the user asks to:
- Upgrade Spring Boot 3.5.x → 4.0.x
- Upgrade Java 17 → 21
- Migrate a Maven or Gradle project automatically and safely
- Handle both single-module and multi-module projects

## Prerequisites (required checks before starting)
1. Project is running stable with Spring Boot 3.5.x + Java 17
2. Clean git state (git status must be clean)
3. Java 21 is installed and available (JDK 21+)
4. Internet connection to download OpenRewrite plugin

## Step-by-step workflow (exact order)

### Step 1: Identify build tool
- If you have `pom.xml` → Maven
- If you have `build.gradle` or `build.gradle.kts` → Gradle

### Step 2: Add OpenRewrite plugin (run once only)

**Maven (pom.xml):**
```xml
<plugin>
    <groupId>org.openrewrite.maven</groupId>
    <artifactId>rewrite-maven-plugin</artifactId>
    <version>latest.release</version>
    <!-- Optional: pin specific version like 6.7.0 -->
    <configuration>
        <activeRecipes>
            <recipe>org.openrewrite.java.migrate.UpgradeToJava21</recipe>
            <recipe>org.openrewrite.java.spring.boot4.UpgradeSpringBoot_4_0</recipe>
        </activeRecipes>
        <exportDatatables>true</exportDatatables>
    </configuration>
    <dependencies>
        <dependency>
            <groupId>org.openrewrite.recipe</groupId>
            <artifactId>rewrite-migrate-java</artifactId>
            <version>latest.release</version>
        </dependency>
        <dependency>
            <groupId>org.openrewrite.recipe</groupId>
            <artifactId>rewrite-spring</artifactId>
            <version>latest.release</version>
        </dependency>
    </dependencies>
</plugin>
```

**Gradle (build.gradle or build.gradle.kts):**
```gradle
plugins {
    id("org.openrewrite.rewrite") version "latest.release"
}

rewrite {
    activeRecipe("org.openrewrite.java.migrate.UpgradeToJava21")
    activeRecipe("org.openrewrite.java.spring.boot4.UpgradeSpringBoot_4_0")
    setExportDatatables(true)
}

repositories {
    mavenCentral()
}

dependencies {
    rewrite("org.openrewrite.recipe:rewrite-migrate-java:latest.release")
    rewrite("org.openrewrite.recipe:rewrite-spring:latest.release")
}
```

### Step 3: Run migration (recommended order)

**Recommended: Run separately for easier debugging:**
```bash
# 1. Dry-run first (very important)
./mvnw rewrite:dryRun          # Maven
# or
./gradlew rewriteDryRun        # Gradle

# 2. Run actual migration
./mvnw rewrite:run             # Maven
# or
./gradlew rewriteRun           # Gradle
```

**Alternative: Run both recipes in one command:**
```bash
# Maven
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.migrate.UpgradeToJava21,org.openrewrite.java.spring.boot4.UpgradeSpringBoot_4_0

# Gradle
./gradlew rewriteRun -Prewrite.activeRecipe=org.openrewrite.java.migrate.UpgradeToJava21,org.openrewrite.java.spring.boot4.UpgradeSpringBoot_4_0
```

### Step 4: Review & Finish
1. View changes with `git diff` and `git status`
2. Check `rewrite-datatables/` folder for detailed reports
3. Update IDE: Project SDK → JDK 21
4. Run full test suite: `./mvnw clean test` or `./gradlew clean test`
5. Fix manually if needed:
   - Breaking changes: Jakarta EE, Servlet 6.1, modular starters
   - Third-party libraries not yet compatible
   - Property names that changed

## Safety & Best Practices
- Always backup or commit before running
- Run on a separate branch (`git checkout -b upgrade-spring-boot-4-java-21`)
- For multi-module projects: run from root
- After completion, you can remove OpenRewrite plugin from build file
- Always read the official Spring Boot 4.0 Migration Guide

## Common Pitfalls (avoid these)
- Do NOT run Spring Boot recipe before upgrading to Java 21
- Forget to use `activeRecipe()` (singular) in Gradle instead of `activeRecipes()`
- Using old plugin versions
- Skipping the dry-run step

## References
- OpenRewrite Spring Boot 4.0 recipe: `org.openrewrite.java.spring.boot4.UpgradeSpringBoot_4_0`
- Java 21 upgrade recipe: `org.openrewrite.java.migrate.UpgradeToJava21`
- Official docs: https://docs.openrewrite.org

**This skill is designed to enable AI to safely and consistently execute 95% of the migration work automatically.**
