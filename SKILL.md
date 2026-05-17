---
name: spring-boot-java-upgrade-openrewrite
description: Comprehensive skill for automating Java and Spring Boot migrations using OpenRewrite. Supports Java version upgrades (8→11→17→25), Spring Boot (2.x→3.x→4.0), Spring Cloud, unit test migration (JUnit 4→5), database tools (Flyway/Liquibase), and security framework upgrades. Always safe with dry-run, diff review, and testing.
---

# Comprehensive Java and Spring Boot Migrations Using OpenRewrite

## Table of Contents
1. [What is OpenRewrite](#what-is-openrewrite)
2. [When to Use This Skill](#when-to-use-this-skill)
3. [Prerequisites & Safety](#prerequisites--safety)
4. [Quick Start: Java 17→25 + Spring Boot 3.5→4.0](#quick-start-java-1725--spring-boot-3540)
5. [The Umbrella Recipe (rewrite.yml)](#the-umbrella-recipe-rewriteyml)
6. [Advanced Migrations](#advanced-migrations)
7. [Migration Paths by Version](#migration-paths-by-version)
8. [Special Topics](#special-topics)
9. [Safety & Best Practices](#safety--best-practices)
10. [Troubleshooting](#troubleshooting)
11. [Common Pitfalls](#common-pitfalls)
12. [Advanced Customization](#advanced-customization)
13. [CI Automation (Power Move)](#ci-automation-power-move)
14. [Real-World Results](#real-world-results)
15. [Dependency Migration Considerations](#dependency-migration-considerations)
16. [References & Resources](#references--resources)
17. [Migration Checklist](#migration-checklist)
18. [Notes for AI Agents](#notes-for-ai-agents)

---

## What is OpenRewrite

**OpenRewrite** is an automated refactoring engine that uses Lossless Semantic Trees (LSTs) to make precise, consistent code transformations across entire projects.

### How It Works
1. **Parses** source code into an LST (preserves formatting)
2. **Visits** specific code patterns via rules (recipes)
3. **Transforms** the tree based on migration rules
4. **Prints** the modified tree back to source code
5. **Exports** detailed reports of all changes

### Why It Matters
- **95% automated**: Handles repetitive migrations without manual coding
- **Safe by default**: Generates changes you can review before committing
- **Comprehensive**: Thousands of community recipes + custom recipes
- **Language-agnostic**: Works with Java, Kotlin, Gradle, Maven, YAML, properties, etc.

---

## When to Use This Skill

Use this skill when the user asks to:

### ✅ Direct Use Cases
- **Upgrade Java**: 8→11, 11→17, 17→25, or any supported version
- **Upgrade Spring Boot**: 2.x→2.7, 2.7→3.0, 3.0→3.5, 3.5→4.0
- **Migrate Spring Cloud**: 2022.x→2023.x→2024.x→2025.x
- **Upgrade Spring Security**: 5.x→6.x→7.x
- **Migrate unit tests**: JUnit 4→5, Mockito upgrades
- **Database tools**: Flyway/Liquibase version upgrades
- **Multi-module projects**: Coordinate migrations across parent + children
- **Gradle or Maven projects**: Both fully supported

### ✅ Project Types
- Spring Boot applications (any version)
- Spring Cloud microservices
- Spring Framework applications
- Spring Data JPA projects
- Jakarta EE applications
- Enterprise Java applications

---

## Prerequisites & Safety

### Before Starting (MANDATORY CHECKS)

1. **Git State**: Clean working directory
   ```bash
   git status
   # Output should be: "On branch main, nothing to commit, working tree clean"
   ```

2. **Target Version Available**: For Java upgrades, ensure the target JDK is installed
   ```bash
   java -version
   # For Java 25: OpenJDK 25.x or Oracle JDK 25.x
   ```

3. **Current Version Stable**: Project builds and tests pass
   ```bash
./mvnw clean test  # Maven
./gradlew clean test  # Gradle
```

---

## Quick Start: Java 17→25 + Spring Boot 3.5→4.0

### Step 1: Identify Build Tool

```bash
# Check for Maven
ls pom.xml 2>/dev/null && echo "Maven project"

# Check for Gradle
ls build.gradle build.gradle.kts 2>/dev/null && echo "Gradle project"
```

### Step 2: Add OpenRewrite Plugin

#### Maven Projects (pom.xml)

Add to `<build><plugins>` section:
```xml
<plugin>
    <groupId>org.openrewrite.maven</groupId>
    <artifactId>rewrite-maven-plugin</artifactId>
    <version>6.7.0</version>
    <configuration>
        <activeRecipes>
            <recipe>org.openrewrite.java.migrate.UpgradeToJava25</recipe>
            <recipe>org.openrewrite.java.spring.boot4.UpgradeSpringBoot_4_0</recipe>
        </activeRecipes>
        <exportDatatables>true</exportDatatables>
    </configuration>
    <dependencies>
        <dependency>
            <groupId>org.openrewrite.recipe</groupId>
            <artifactId>rewrite-migrate-java</artifactId>
            <version>2.8.1</version>
        </dependency>
        <dependency>
            <groupId>org.openrewrite.recipe</groupId>
            <artifactId>rewrite-spring</artifactId>
            <version>5.7.0</version>
        </dependency>
    </dependencies>
</plugin>
```

#### Gradle Projects (build.gradle)

Add to plugins and dependencies:
```gradle
plugins {
    id("org.openrewrite.rewrite") version "6.7.0"
}

rewrite {
    activeRecipe("org.openrewrite.java.migrate.UpgradeToJava25")
    activeRecipe("org.openrewrite.java.spring.boot4.UpgradeSpringBoot_4_0")
    setExportDatatables(true)
}

dependencies {
    rewrite("org.openrewrite.recipe:rewrite-migrate-java:2.8.1")
    rewrite("org.openrewrite.recipe:rewrite-spring:5.7.0")
}
```

#### Gradle Projects (build.gradle.kts)

```kotlin
plugins {
    id("org.openrewrite.rewrite") version "6.7.0"
}

rewrite {
    activeRecipe("org.openrewrite.java.migrate.UpgradeToJava25")
    activeRecipe("org.openrewrite.java.spring.boot4.UpgradeSpringBoot_4_0")
    setExportDatatables(true)
}

dependencies {
    rewrite("org.openrewrite.recipe:rewrite-migrate-java:2.8.1")
    rewrite("org.openrewrite.recipe:rewrite-spring:5.7.0")
}
```

### Step 3: Run Dry-Run (CRITICAL - Never Skip)

```bash
# Maven: Preview all changes
./mvnw rewrite:dryRun

# Gradle: Preview all changes
./gradlew rewriteDryRun
```

If you hit memory pressure on larger projects, rerun with explicit heap sizing:

```bash
# Maven (one-off)
MAVEN_OPTS="-Xms1g -Xmx4g -XX:MaxMetaspaceSize=512m" ./mvnw rewrite:dryRun

# Gradle (one-off)
./gradlew -Dorg.gradle.jvmargs="-Xms1g -Xmx4g -XX:MaxMetaspaceSize=512m" rewriteDryRun
```

**Review output**:
- Check console for recipe execution results
- Examine `rewrite-datatables/` folder (detailed reports)
- Run `git diff` to preview exact changes
- Look for any **ERRORS** or **WARNINGS**

### Step 4: Apply Migration

```bash
# Maven: Actually apply changes
./mvnw rewrite:run

# Gradle: Actually apply changes
./gradlew rewriteRun
```

### Step 5: Verify & Test

```bash
# 1. Check what changed
git diff --stat
git diff  # review line-by-line

# 2. Update IDE project SDK
#    IDE Settings → Project Structure → Project SDK → JDK 25

# 3. Run test suite
./mvnw clean test  # Maven
./gradlew clean test  # Gradle

# 4. Fix any remaining issues (see Troubleshooting section)

# 5. Commit
git add .
git commit -m "chore: migrate to Java 25 and Spring Boot 4.0 via OpenRewrite"
```

---

## The Umbrella Recipe (rewrite.yml)

Instead of running 50 individual recipes manually, OpenRewrite provides **umbrella recipes** that combine multiple migrations into a single command.

### Why use an umbrella recipe?

- **Single source of truth**: All migration recipes declared in one place
- **Ordered execution**: Recipes run in the order you define (Java first, then framework)
- **Reusable**: Check into version control, share across repos, use in CI
- **Composable**: Add/remove recipes without changing build files

### Creating a rewrite.yml

Create a `rewrite.yml` file in your project root:

```yaml
type: specs.openrewrite.org/v1beta/recipe
name: com.company.FullModernization
displayName: Upgrade entire platform to latest stack
description: Migrates Java, Spring Boot, Jackson, JUnit, and dependencies.

recipeList:
  # --- Java platform ---
  - org.openrewrite.java.migrate.UpgradeToJava25

  # --- Spring ecosystem ---
  - org.openrewrite.java.spring.boot4.UpgradeSpringBoot_4_0
  - org.openrewrite.java.spring.cloud2025.UpgradeSpringCloud_2025_1

  # --- Serialization ---
  - org.openrewrite.java.jackson.UpgradeJackson_3

  # --- Testing ---
  - org.openrewrite.java.testing.junit5.JUnit4to5Migration
  - org.openrewrite.java.testing.junit6.UpgradeToJUnit6

  # --- Build modernization ---
  - org.openrewrite.maven.UpgradePlugins
  - org.openrewrite.gradle.UpgradePlugins
```

### Running via rewrite.yml

**Maven:**
```bash
# Dry-run first
./mvnw rewrite:dryRun -Drewrite.activeRecipes=com.company.FullModernization

# Apply
./mvnw rewrite:run -Drewrite.activeRecipes=com.company.FullModernization
```

**Gradle:**
```bash
# Dry-run first
./gradlew rewriteDryRun -Prewrite.activeRecipe=com.company.FullModernization

# Apply
./gradlew rewriteRun -Prewrite.activeRecipe=com.company.FullModernization
```

> **Tip**: You can also declare the active recipe in the `rewrite.yml` file itself under `tags:`. See [OpenRewrite docs](https://docs.openrewrite.org/) for details.

---

### Upgrading Dependencies Automatically

OpenRewrite can force all dependencies to their latest compatible versions:

```yaml
# Add to your rewrite.yml recipeList
  - org.openrewrite.maven.UpgradeDependencyVersion:
      groupId: "*"
      artifactId: "*"
      newVersion: latest.release
```

> **⚠️ Caution**: Only use blanket upgrades **after** major platform migrations (Java, Boot, Jackson) are complete and tested. Blind version bumps can introduce incompatibilities.

---

## Advanced Migrations

### Multi-Step Java Migrations

For large Java version jumps (e.g., Java 8 → 25), migrate incrementally:

```bash
# Step 1: Java 8 → 11
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.migrate.UpgradeToJava11

# Step 2: Java 11 → 17
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.migrate.UpgradeToJava17

# Step 3: Java 17 → 25
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.migrate.UpgradeToJava25
```

**Why incremental?** Some breaking changes (e.g., modules, removed APIs) are easier to handle in smaller steps.

### Multi-Step Spring Boot Migrations

```bash
# Spring Boot 2.x → 3.x → 4.0 migration sequence

# Step 1: Migrate to Spring Boot 2.7 (latest 2.x)
./mvnw rewrite:dryRun -Drewrite.activeRecipes=org.openrewrite.java.spring.boot2.UpgradeSpringBoot_2_7
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.spring.boot2.UpgradeSpringBoot_2_7

# Step 2: Migrate to Spring Boot 3.0
./mvnw rewrite:dryRun -Drewrite.activeRecipes=org.openrewrite.java.spring.boot3.UpgradeSpringBoot_3_0
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.spring.boot3.UpgradeSpringBoot_3_0

# Step 3: Migrate to Spring Boot 3.5
./mvnw rewrite:dryRun -Drewrite.activeRecipes=org.openrewrite.java.spring.boot3.UpgradeSpringBoot_3_5
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.spring.boot3.UpgradeSpringBoot_3_5

# Step 4: Migrate to Spring Boot 4.0
./mvnw rewrite:dryRun -Drewrite.activeRecipes=org.openrewrite.java.spring.boot4.UpgradeSpringBoot_4_0
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.spring.boot4.UpgradeSpringBoot_4_0

# Step 5: Test after each step
./mvnw clean test
```

### Spring Cloud Migration (CRITICAL for Boot 4.0)

**Important**: Spring Boot 4.0 requires **Spring Cloud 2025.1** (not 2025.0).

```bash
# If your project uses Spring Cloud, migrate after Spring Boot 4.0

# Check if Spring Cloud is used
grep -r "spring-cloud" pom.xml build.gradle

# If yes, migrate to Spring Cloud 2025.1
./mvnw rewrite:dryRun -Drewrite.activeRecipes=org.openrewrite.java.spring.cloud2025.UpgradeSpringCloud_2025_1
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.spring.cloud2025.UpgradeSpringCloud_2025_1

# Test afterward
./mvnw clean test
```

**Common Spring Cloud Modules** (all require migration):
- `spring-cloud-starter-config`
- `spring-cloud-starter-netflix-eureka-client`
- `spring-cloud-starter-gateway`
- `spring-cloud-starter-openfeign`
- `spring-cloud-starter-loadbalancer`

---

## Migration Paths by Version

### Java Version Matrix

| From | To | Recipe | Notes |
|------|----|---------|----|
| 8 | 11 | `org.openrewrite.java.migrate.UpgradeToJava11` | Removes deprecated methods, adds modules awareness |
| 11 | 17 | `org.openrewrite.java.migrate.UpgradeToJava17` | Pattern matching, sealed classes, records |
| 17 | 25 | `org.openrewrite.java.migrate.UpgradeToJava25` | Virtual threads, structured concurrency, generics in arrays |
| 25 | 23 | `org.openrewrite.java.migrate.UpgradeToJava23` | Pattern matching improvements, string templates |

### Spring Boot Version Matrix

| From | To | Recipe | Key Changes |
|------|----|---------|----|
| 2.x | 2.7 | `org.openrewrite.java.spring.boot2.UpgradeSpringBoot_2_7` | Deprecation warnings, property migration |
| 2.7 | 3.0 | `org.openrewrite.java.spring.boot3.UpgradeSpringBoot_3_0` | **Jakarta EE** (javax→jakarta), Java 17 minimum |
| 3.0 | 3.5 | `org.openrewrite.java.spring.boot3.UpgradeSpringBoot_3_5` | Property renames, dependency updates |
| 3.5 | 4.0 | `org.openrewrite.java.spring.boot4.UpgradeSpringBoot_4_0` | **Modular starters**, Java 25 recommended |

### Spring Security Version Matrix

| From | To | Recipe |
|------|----|---------| 
| 5.x | 6.x | `org.openrewrite.java.spring.security6.UpgradeSpringSecurity_6_0` |
| 6.x | 7.x | `org.openrewrite.java.spring.security7.UpgradeSpringSecurity_7_0` |

---

## Special Topics

### Unit Test Migration: JUnit 4 → 5

```bash
# Gradle
./gradlew rewriteDryRun -Prewrite.activeRecipe=org.openrewrite.java.testing.junit5.JUnit4to5Migration
./gradlew rewriteRun -Prewrite.activeRecipe=org.openrewrite.java.testing.junit5.JUnit4to5Migration

# Maven
./mvnw rewrite:dryRun -Drewrite.activeRecipes=org.openrewrite.java.testing.junit5.JUnit4to5Migration
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.testing.junit5.JUnit4to5Migration
```

**What it changes**:
- `org.junit.Test` → `org.junit.jupiter.api.Test`
- `@Before` → `@BeforeEach`
- `@After` → `@AfterEach`
- `@ClassRule` → `@RegisterExtension`
- `@RunWith(SpringRunner.class)` → `@SpringBootTest`
- `@Mock` + `@RunWith(MockitoJUnitRunner.class)` → `@ExtendWith(MockitoExtension.class)`

### Mockito Upgrade: 3.x → 4.x

```bash
./mvnw rewrite:dryRun -Drewrite.activeRecipes=org.openrewrite.java.testing.mockito.Mockito4To5Migration
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.testing.mockito.Mockito4To5Migration
```

### Jackson 3 Migration (Major Breaking Change)

Jackson 3 is a **major rewrite** that removes many legacy APIs. OpenRewrite handles this automatically.

```bash
# Maven
./mvnw rewrite:dryRun -Drewrite.activeRecipes=org.openrewrite.java.jackson.UpgradeJackson_3
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.jackson.UpgradeJackson_3

# Gradle
./gradlew rewriteDryRun -Prewrite.activeRecipe=org.openrewrite.java.jackson.UpgradeJackson_3
./gradlew rewriteRun -Prewrite.activeRecipe=org.openrewrite.java.jackson.UpgradeJackson_3
```

**What it changes automatically**:

| Before | After |
|--------|-------|
| `ObjectMapper` legacy config | Modern config API |
| `SerializationFeature.WRITE_DATES_AS_TIMESTAMPS` | `SerializationFeature.WRITE_DATES_AS_TIMESTAMPS` (inverted) |
| `@JsonIgnore` (old javax) | Updated package |
| Legacy Module registration | New module API |
| `JsonParser.Feature` enum values | Updated constants |

**Example transformation**:
```java
// Before
mapper.enable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);

// After
mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
```

**Post-migration checklist after Jackson 3**:
- Check any custom `ObjectMapper` configurations
- Review custom serializers/deserializers
- Verify JSON serialization in integration tests
- Test backward compatibility with existing stored data

### JUnit 4/5 → 6 Migration

JUnit 6 is the successor of JUnit 5 with refined APIs. OpenRewrite handles the transition from both JUnit 4 and 5.

```bash
# Maven
./mvnw rewrite:dryRun -Drewrite.activeRecipes=org.openrewrite.java.testing.junit6.UpgradeToJUnit6
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.testing.junit6.UpgradeToJUnit6

# Gradle
./gradlew rewriteDryRun -Prewrite.activeRecipe=org.openrewrite.java.testing.junit6.UpgradeToJUnit6
./gradlew rewriteRun -Prewrite.activeRecipe=org.openrewrite.java.testing.junit6.UpgradeToJUnit6
```

**What it changes**:

| Before | After |
|--------|-------|
| JUnit 5 vintage engine | Cleaned up |
| Updated `Assertions` imports | Updated package |
| Removed deprecated test rules | Modern equivalents |
| `@EnabledIf` / `@DisabledIf` conditions | Updated API |

> **Note**: JUnit 5 `@Test` annotation stays the same. The migration mainly updates transitive dependencies, removes vintage engine leftovers, and updates conditional test execution APIs.

### Database Tools: Flyway / Liquibase Migration

#### Flyway 7 → Latest
```bash
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.flyway.UpgradeFlyway_8
```

#### Liquibase Version Upgrades
```bash
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.liquibase.MigrateToLiquibase_4_0
```

### Spring Data JPA Migration

```bash
# Spring Data 2.x → 3.x
./mvnw rewrite:dryRun -Drewrite.activeRecipes=org.openrewrite.java.spring.data.UpgradeSpringData_3_0
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.spring.data.UpgradeSpringData_3_0
```

### Jakarta EE Namespace Migration (javax → jakarta)

This happens **automatically** during Spring Boot 3.x migration, but if you need manual control:

```bash
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.migrate.javax.AddJakartaMigrationRecipe
```

**Typical changes**:
```java
// Before
import javax.persistence.*;
import javax.servlet.*;
import javax.validation.*;

// After
import jakarta.persistence.*;
import jakarta.servlet.*;
import jakarta.validation.*;
```

---

## Safety & Best Practices

### 1. Always Use Dry-Run First

```bash
# STEP 1: Preview changes (mandatory)
./mvnw rewrite:dryRun

# STEP 2: Review output carefully
# - Check console output
# - Read rewrite-datatables/ reports
# - Run git diff --stat

# STEP 3: Only then run actual migration
./mvnw rewrite:run
```

### 2. Use Feature Branches

```bash
git checkout -b upgrade/java25-spring-boot4
# ... run migrations ...
git add .
git commit -m "chore: upgrade Java 17→25, Spring Boot 3.5→4.0"
git push -u origin upgrade/java25-spring-boot4
# Create PR for review and testing
```

### 3. Incremental Recipe Application

For complex migrations, run recipes one at a time:

```bash
# Recipe 1: Java upgrade
./mvnw rewrite:dryRun -Drewrite.activeRecipes=org.openrewrite.java.migrate.UpgradeToJava25
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.migrate.UpgradeToJava25
./mvnw clean test

# Recipe 2: Spring Boot upgrade (after Java passes tests)
./mvnw rewrite:dryRun -Drewrite.activeRecipes=org.openrewrite.java.spring.boot4.UpgradeSpringBoot_4_0
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.spring.boot4.UpgradeSpringBoot_4_0
./mvnw clean test
```

### 4. Test After Each Major Step

```bash
# After every recipe execution
./mvnw clean test
./mvnw verify  # Run integration tests
./mvnw checkstyle:check  # Run code quality checks

# For Gradle
./gradlew clean test
./gradlew verify
./gradlew check
```

### 5. Review Rewrite Reports

After running migrations, check the `rewrite-datatables/` folder:

```bash
# Files generated:
# - SourcesFileResults.csv - which files were modified
# - RecipeRunStats.csv - statistics about recipe execution
# - Various recipe-specific reports

cat rewrite-datatables/SourcesFileResults.csv
```

### 6. Multi-Module Projects

For Maven multi-module projects, run from **root**:

```bash
cd /path/to/parent-pom
./mvnw rewrite:dryRun
./mvnw rewrite:run
# Automatically processes all modules
```

### 7. Cleanup After Completion

```bash
# 1. Remove OpenRewrite plugin from pom.xml/build.gradle
# 2. Remove rewrite-datatables folder (if not needed)
# 3. Commit clean state
git add .
git commit -m "chore: cleanup OpenRewrite artifacts after migration"
```

---

## Troubleshooting

### Issue: `java.lang.OutOfMemoryError: Java heap space` During `rewrite:dryRun` / `rewrite:run`

**Why it happens**:
- OpenRewrite builds and analyzes Lossless Semantic Trees across the project; large codebases can exceed default heap limits.
- Gradle daemon default heap is often too small for big migration runs.

**Fast fixes (recommended order)**:

1. **Increase build JVM heap**

   **Maven (project-level, preferred):**
   ```text
   # .mvn/jvm.config
   -Xms1024m
   -Xmx4096m
   -XX:MaxMetaspaceSize=512m
   ```

   **Maven (one-off):**
   ```bash
   MAVEN_OPTS="-Xms1g -Xmx4g -XX:MaxMetaspaceSize=512m" ./mvnw rewrite:dryRun
   MAVEN_OPTS="-Xms1g -Xmx4g -XX:MaxMetaspaceSize=512m" ./mvnw rewrite:run
   ```

   **Gradle (project-level, preferred):**
   ```properties
   # gradle.properties
   org.gradle.jvmargs=-Xms1g -Xmx4g -XX:MaxMetaspaceSize=512m
   ```

   **Gradle (one-off):**
   ```bash
   ./gradlew -Dorg.gradle.jvmargs="-Xms1g -Xmx4g -XX:MaxMetaspaceSize=512m" rewriteDryRun
   ./gradlew -Dorg.gradle.jvmargs="-Xms1g -Xmx4g -XX:MaxMetaspaceSize=512m" rewriteRun
   ```

2. **Reduce peak memory during execution**
   - Run migration recipes one-by-one (Java first, Boot second) instead of all-at-once.
   - For Maven multi-module repos, consider per-submodule execution (`-Drewrite.runPerSubmodule=true`).
   - For Gradle on constrained CI, lower parallelism (`org.gradle.workers.max=1..4`).

3. **Use OpenRewrite alternative for very large repos**
   - OpenRewrite FAQ recommends Moderne CLI when local heap scaling is insufficient.

4. **Re-run after cleanup**
   - Stop background daemons and rerun:
   ```bash
   ./gradlew --stop
   ```

5. **Escalation rule**
   - If still failing at `-Xmx8g`+, split migration by module/repository slice and migrate incrementally.

**CI note**:
- Set container/runner memory limit above JVM heap (`-Xmx`) so process is not OOM-killed by the platform.

### Issue: Recipe Not Found

**Symptom**:
```
ERROR: Recipe 'org.openrewrite.java.migrate.UpgradeToJava25' not found
```

**Solution**:
1. Check recipe name spelling (case-sensitive)
2. Ensure dependencies are added:
   - `rewrite-migrate-java` for Java recipes
   - `rewrite-spring` for Spring recipes
3. Update plugin to latest version

### Issue: Plugin Version Too Old

**Symptom**:
```
ERROR: Could not find plugin org.openrewrite.maven:rewrite-maven-plugin:6.1.0
```

**Solution**:
```xml
<!-- Use latest.release or specific recent version -->
<version>6.7.0</version>  <!-- or later -->
```

### Issue: Java Version Not Installed

**Symptom**:
```
ERROR: Cannot run with Java version 25; installed version is 17
```

**Solution**:
1. Install JDK 25: https://adoptopenjdk.net/ or https://www.oracle.com/java/technologies/downloads/
2. Configure IDE to use JDK 25 after migration

### Issue: Gradle activeRecipe vs activeRecipes

**Symptom**:
```
gradle: Unknown property 'activeRecipes' on org.openrewrite.gradle.RewriteExtension
```

**Solution**:
```gradle
// WRONG
rewrite {
    activeRecipes("recipe1", "recipe2")  // ❌ Wrong
}

// RIGHT
rewrite {
    activeRecipe("recipe1")
    activeRecipe("recipe2")  // ✅ Call multiple times
}
```

### Issue: Tests Fail After Migration

**Common Causes**:
1. **Third-party libraries incompatible** - Not handled by OpenRewrite
2. **Property names changed** - Check `application.properties` / `application.yml`
3. **API breaking changes** - See migration guide

**Solution**:
1. Review `git diff` carefully
2. Check migration guide: https://spring.io/projects/spring-boot
3. Update incompatible dependencies manually
4. Fix compilation errors

### Issue: Spring Cloud 2025.0 Incompatibility

**Symptom** (Spring Boot 4.0 + Spring Cloud 2025.0):
```
NoSuchMethodError: 'ConfigurableBootstrapContext
```

**Solution**:
```bash
# CRITICAL: Upgrade to Spring Cloud 2025.1.x (required for Boot 4.0)
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.spring.cloud2025.UpgradeSpringCloud_2025_1
```

---

## Common Pitfalls

### ❌ Pitfall 1: Running Spring Boot Recipe Before Java Upgrade

**Wrong Sequence**:
```bash
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.spring.boot4.UpgradeSpringBoot_4_0
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.migrate.UpgradeToJava25
# ❌ WRONG: Spring Boot expects Java 25 features to exist
```

**Correct Sequence**:
```bash
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.migrate.UpgradeToJava25
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.spring.boot4.UpgradeSpringBoot_4_0
# ✅ CORRECT: Java first, then Spring Boot
```

### ❌ Pitfall 2: Skipping Dry-Run

**Wrong**:
```bash
./mvnw rewrite:run  # Applied immediately, no preview
```

**Correct**:
```bash
./mvnw rewrite:dryRun  # Review first
git diff  # See exact changes
./mvnw rewrite:run  # Only after review
```

### ❌ Pitfall 3: Dirty Git State

**Wrong**:
```bash
# Uncommitted changes in working directory
./mvnw rewrite:run  # Overwrites unknown files
```

**Correct**:
```bash
git status  # Check clean state
git add . && git commit -m "checkpoint"  # If needed
./mvnw rewrite:run
```

### ❌ Pitfall 4: Wrong Spring Cloud Version for Boot 4.0

**Wrong**:
```xml
<!-- Spring Cloud 2025.0 does NOT work with Spring Boot 4.0 -->
<spring-cloud.version>2025.0.1</spring-cloud.version>
```

**Correct**:
```xml
<!-- Spring Cloud 2025.1 is required for Spring Boot 4.0 -->
<spring-cloud.version>2025.1.x</spring-cloud.version>
```

### ❌ Pitfall 5: Gradle `activeRecipes` vs `activeRecipe`

**Wrong**:
```gradle
rewrite {
    activeRecipes("recipe1", "recipe2")  // ❌ Method doesn't exist
}
```

**Correct**:
```gradle
rewrite {
    activeRecipe("recipe1")
    activeRecipe("recipe2")  // ✅ Call separately
}
```

### ❌ Pitfall 6: Ignoring Test Failures

**Wrong**:
```bash
./mvnw rewrite:run
./mvnw clean test  # Tests fail, commit anyway ❌
git commit -m "migrate to Spring Boot 4"
```

**Correct**:
```bash
./mvnw rewrite:run
./mvnw clean test  # If failures, fix them first
# Only commit after all tests pass ✅
git commit -m "chore: migrate to Spring Boot 4 (all tests passing)"
```

---

## Advanced Customization

### Creating Custom Recipes

If OpenRewrite doesn't handle your specific case, create a custom recipe:

```yaml
# custom-migration.yml
type: specs.openrewrite.org/v1beta/recipe
name: com.example.CustomMigration
displayName: Custom Migration
description: Apply custom transformations for our company
recipeList:
  - org.openrewrite.java.spring.boot4.UpgradeSpringBoot_4_0
  - org.openrewrite.java.migrate.UpgradeToJava25
  # Add your custom visitors here
```

### Excluding Files from Migration

```bash
# Maven: exclude specific files/patterns
./mvnw rewrite:run -Drewrite.exclusions='**/generated/**,**/test/**'

# Gradle
./gradlew rewriteRun -Prewrite.exclusions='**/generated/**,**/test/**'
```

### Running Specific Recipes Only

```bash
# Run only property migrations (no code changes)
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.java.spring.boot4.SpringBootProperties_4_0
```

---

## CI Automation (Power Move)

Integrate OpenRewrite into your CI pipeline for continuous, automated migration:

```yaml
# .github/workflows/migration.yml
name: Automated Migration
on:
  schedule:
    - cron: "0 2 * * 1"  # Weekly: Monday 2 AM
  workflow_dispatch:       # Manual trigger

jobs:
  migrate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK 25
        uses: actions/setup-java@v4
        with:
          java-version: "25"
          distribution: "temurin"

      - name: Run OpenRewrite
        run: ./mvnw rewrite:run -Drewrite.activeRecipes=com.company.FullModernization

      - name: Commit changes
        run: |
          git diff --quiet || (
            git add -A &&
            git commit -m "chore: auto-migration $(date +%Y-%m-%d)" &&
            git push
          )
```

**CI best practices**:
- Always run `rewrite:dryRun` in PR preview (not auto-apply)
- Apply `rewrite:run` only on schedule or manual trigger
- Run full test suite after migration before commit
- Use `git diff --quiet` guard to skip commits when nothing changed

---

## Real-World Results

For a medium microservice repo (~200k LOC), here's what OpenRewrite delivers:

| Task | Manual Time | OpenRewrite | Savings |
|------|-------------|-------------|---------|
| Java 17 → 25 upgrade | 3–5 days | **5 min** | ~99% |
| Spring Boot 3.5 → 4.0 | 1–2 weeks | **30 min** | ~97% |
| Jackson 3 migration | 1 week | **15 min** | ~97% |
| JUnit 4/5 → 6 migration | 2–3 days | **5 min** | ~98% |
| Full dependency refresh | 1–2 days | **10 min** | ~95% |

**Companies using OpenRewrite at scale**: Netflix, VMware, Moderne, and thousands of enterprises.

> **Why it works**: OpenRewrite operates on Lossless Semantic Trees (LSTs), not regex. It understands code structure, not just text patterns. This means transformations are precise and preserve formatting.

---

## Dependency Migration Considerations

When migrating dependencies during a major platform upgrade, consider **all** categories of dependencies in your project. A successful migration requires a holistic view.

### 1. BOM-Managed Dependencies

Many Spring projects use BOMs (`dependencyManagement` in Maven or `platform` in Gradle) to centralize version control.

**Maven BOM pattern:**
```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-dependencies</artifactId>
            <version>${spring-boot.version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
        <!-- Company BOM -->
        <dependency>
            <groupId>com.company</groupId>
            <artifactId>company-dependencies</artifactId>
            <version>${company-framework.version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

**Gradle platform pattern:**
```gradle
dependencies {
    implementation platform("org.springframework.boot:spring-boot-dependencies:${springBootVersion}")
    implementation platform("com.company:company-dependencies:${companyFrameworkVersion}")
}
```

**Key considerations**:
- ✅ OpenRewrite updates Spring Boot BOM version automatically
- ⚠️ **Company BOMs need separate attention** — OpenRewrite doesn't know your internal version scheme
- ✅ Verify all managed dependency versions are compatible with the new Boot/Java version
- ⚠️ Custom property placeholders (`${my.version}`) in BOMs may not be updated by generic recipes

**Action checklist for BOMs**:
- [ ] Identify all BOM imports in `dependencyManagement` / `platform()`
- [ ] Update Spring BOM(s) via OpenRewrite recipe
- [ ] For company BOMs: update manually or create a custom recipe
- [ ] Verify transitive dependency resolution with `./mvnw dependency:tree` or `./gradlew dependencies`

### 2. Internal / Private Dependencies

Dependencies built internally or hosted on private registries (Nexus, Artifactory, GitHub Packages).

**Examples**:
- Shared libraries (company-commons, company-api-client)
- Internal framework starters
- Proprietary SDKs

**Key considerations**:
- ❌ OpenRewrite **cannot** update internal library versions — they're not on Maven Central
- ⚠️ These libraries may themselves need upgrading to be compatible (e.g., they import `javax.servlet` which no longer exists)
- ⚠️ Source-included internal modules (multi-module projects) are fully processed by OpenRewrite

**Action checklist for internal deps**:
- [ ] List all dependencies with `com.company.*` or custom groupIds
- [ ] Check each for compatibility with target Java/Spring version
- [ ] If a library is open-sourced and on a public registry, verify recipe handles it
- [ ] For incompatible internal libs: upgrade them separately first, then publish updated versions
- [ ] Use `./mvnw versions:display-dependency-updates` to find available updates

### 3. External / Third-Party Dependencies

Open-source libraries from Maven Central or other public registries.

**Examples**:
- Hibernate, Apache Commons, Guava, Lombok, MapStruct
- Cloud libraries (AWS SDK, GCP libraries)
- Monitoring (Micrometer, Prometheus client)
- Serialization (Jackson, Gson, Protobuf)

**Key considerations**:
- ✅ OpenRewrite recipes cover well-known libraries in the Spring ecosystem
- ❌ Long-tail libraries may need manual version bumps
- ⚠️ Some libraries may have **dropped support** for older Jakarta APIs

**Action checklist for external deps**:
- [ ] Run `./mvnw dependency:tree` to see all transitive dependencies
- [ ] Check library compatibility with target Java version (e.g., "Library X requires Java 17+")
- [ ] For Jackson: must update to Jackson 3-compatible client libraries
- [ ] For Hibernate: must be 6.4+ for Spring Boot 4.0
- [ ] For test libs: ensure they support JUnit 6
- [ ] Use OpenRewrite `UpgradeDependencyVersion` recipe as a starting point

### 4. Build Tools & Plugins

Build tooling that may need updating.

**Categories**:
- **Maven plugins**: `maven-compiler-plugin`, `maven-surefire-plugin`, `maven-failsafe-plugin`, `maven-javadoc-plugin`
- **Gradle plugins**: `java`, `spring-boot`, `io.spring.dependency-management`
- **Code quality**: Checkstyle, PMD, SpotBugs, Spotless, Error Prone
- **Packaging**: Docker (Jib), GraalVM (Native Image)
- **Documentation**: AsciiDoc, Spring REST Docs
- **Code generation**: OpenAPI Generator, Avro, Protobuf

**Key considerations**:
- ✅ OpenRewrite includes `UpgradePlugins` recipes for Maven and Gradle
- ⚠️ Plugin compatibility with Java 25: some older plugins may not work (e.g., older Jacoco, older Checkstyle)
- ⚠️ Annotation processors may need version bumps (Lombok, MapStruct)

**Action checklist for tools/plugins**:
- [ ] Verify compiler source/target version aligns with new Java version
- [ ] Check `maven-surefire-plugin` version supports JUnit 6
- [ ] Verify Lombok supports Java 25
- [ ] Check code coverage tools (Jacoco, etc.) support new Java version
- [ ] For Gradle: verify Gradle wrapper version supports JDK 25 (Gradle 8.5+)
- [ ] Run `./mvnw plugin:versions` to check for plugin updates

### 5. Infrastructure & Platform Dependencies

Non-code dependencies that affect migration success.

**Examples**:
- **CI/CD runners**: Jenkins, GitHub Actions, GitLab CI must have JDK 25 installed
- **Container base images**: Docker base images must include JDK 25
- **Deployment targets**: PaaS (Cloud Foundry, Heroku) support for JDK 25
- **Monitoring agents**: APM agents (Datadog, New Rellic, Dynatrace) compatibility
- **Database drivers**: JDBC driver versions (PostgreSQL, MySQL, Oracle)

**Action checklist for infrastructure**:
- [ ] Verify CI runners have JDK 25 installed
- [ ] Update Docker base images (`eclipse-temurin:25-jre`, `amazoncorretto:25`)
- [ ] Check APM/profiling agent compatibility with Java 25
- [ ] Verify database JDBC drivers work with Java 25
- [ ] Test memory/performance with new Java version in staging

### 6. Gradle Wrapper & Maven Wrapper Versions

The wrapper scripts themselves may need updating for compatibility.

**Maven Wrapper (`mvnw`)**:
```bash
# Check current wrapper version
grep -o 'apache-maven-[0-9.]*' .mvn/wrapper/maven-wrapper.properties

# Update to latest (if using Maven wrapper plugin)
./mvnw -N wrapper:wrapper -Dmaven=3.9.9
```

**Gradle Wrapper (`gradlew`)**:
```bash
# Check current version
./gradlew --version

# Update to version compatible with JDK 25 (Gradle 8.5+)
./gradlew wrapper --gradle-version=8.10

# Verify JDK compatibility after update
./gradlew --version
```

**Compatibility reference**:

| Gradle Version | JDK 25 Support |
|---------------|----------------|
| 8.4 and below | ❌ Not supported |
| 8.5+ | ✅ Full support |
| 8.10+ | ✅ Recommended with virtual thread improvements |

| Maven Version | JDK 25 Support |
|--------------|----------------|
| 3.8.x | ⚠️ Partial (some plugins may fail) |
| 3.9.0+ | ✅ Full support |
| 3.9.6+ | ✅ Recommended |

**Action checklist for wrappers**:
- [ ] Verify Maven wrapper targets Maven 3.9.0+ (for Java 25)
- [ ] Verify Gradle wrapper targets Gradle 8.5+ (for Java 25)
- [ ] Update wrappers BEFORE running OpenRewrite migrations
- [ ] Test wrapper update independently: `./mvnw clean test` after wrapper update
- [ ] Commit wrapper update as a separate PR before migration

### 7. Dependency Conflict Resolution

After migration, you may encounter version conflicts from transitive dependencies.

```bash
# Maven: Inspect dependency tree
./mvnw dependency:tree -Dverbose > dependency-tree.txt

# Gradle: Inspect dependency tree
./gradlew dependencies > dependency-tree.txt

# Gradle: Find specific version conflicts
./gradlew dependencyInsight --dependency <groupId>:<artifactId>
```

**Common conflict scenarios**:
- **Jackson version mismatch**: Library A pulls Jackson 2.x while your code uses Jackson 3.x
- **Jakarta EE transitive conflict**: Old library still depends on `javax.*` APIs
- **SLF4J/Logback version mismatch**: Multiple logging implementations on classpath

**Resolution strategies**:
- **Maven**: Use `<exclusions>` in the conflicting dependency
- **Gradle**: Use `exclude group:` or `force` version
- **BOM alignment**: Ensure all modules use the same BOM version
- **Dependency locking**: Use `./gradlew dependencies --write-locks` for reproducible builds

### Migration Order for Dependencies

Follow this order when planning dependency migrations:

```
1. ✅ Gradle/Maven wrapper (must support target JDK)
2. ✅ JDK version upgrade (via OpenRewrite)
3. ✅ Update CI/Docker images to target JDK
4. ✅ Spring Boot / Spring Cloud upgrade (via OpenRewrite)
5. ✅ Jackson 3 upgrade (via OpenRewrite)
6. ✅ JUnit 6 upgrade (via OpenRewrite)
7. ✅ Internal library upgrades (manual, then publish)
8. ✅ Third-party dependency version bumps (OpenRewrite + manual)
9. ✅ Build plugin updates (compiler, surefire, code quality)
10. ✅ Full dependency tree verification
11. ✅ Integration testing in staging environment
```

---

## References & Resources

### Official Documentation
- **OpenRewrite Docs**: https://docs.openrewrite.org
- **OpenRewrite FAQ (OOM guidance)**: https://docs.openrewrite.org/reference/faq
- **OpenRewrite Maven Plugin**: https://docs.openrewrite.org/reference/rewrite-maven-plugin
- **OpenRewrite Gradle Plugin**: https://docs.openrewrite.org/reference/gradle-plugin-configuration
- **OpenRewrite GitHub**: https://github.com/openrewrite/rewrite
- **Spring Boot 4.0 Migration Guide**: https://spring.io/projects/spring-boot
- **Moderne Platform**: https://www.moderne.ai

### Build Tool JVM Configuration
- **Apache Maven Config (`MAVEN_OPTS`, `.mvn/jvm.config`)**: https://maven.apache.org/configure.html
- **Gradle Build Environment (`org.gradle.jvmargs`)**: https://docs.gradle.org/current/userguide/build_environment.html

### Key Recipes Reference
| Purpose | Recipe Name | Category |
|---------|-------------|----------|
| Java 17 → 25 | `org.openrewrite.java.migrate.UpgradeToJava25` | Java Platform |
| Java 25 → 23 | `org.openrewrite.java.migrate.UpgradeToJava23` | Java Platform |
| Spring Boot 3.5 → 4.0 | `org.openrewrite.java.spring.boot4.UpgradeSpringBoot_4_0` | Spring Ecosystem |
| Spring Cloud 2025.1 | `org.openrewrite.java.spring.cloud2025.UpgradeSpringCloud_2025_1` | Spring Ecosystem |
| Jackson 2 → 3 | `org.openrewrite.java.jackson.UpgradeJackson_3` | Serialization |
| JUnit 4 → 5 | `org.openrewrite.java.testing.junit5.JUnit4to5Migration` | Testing |
| JUnit 5 → 6 | `org.openrewrite.java.testing.junit6.UpgradeToJUnit6` | Testing |
| Mockito 4 → 5 | `org.openrewrite.java.testing.mockito.Mockito4To5Migration` | Testing |
| Flyway 7 → 8 | `org.openrewrite.flyway.UpgradeFlyway_8` | Database |
| Liquibase 4.0 | `org.openrewrite.liquibase.MigrateToLiquibase_4_0` | Database |
| Spring Security 6 → 7 | `org.openrewrite.java.spring.security7.UpgradeSpringSecurity_7_0` | Security |
| Dependency Version Upgrade | `org.openrewrite.maven.UpgradeDependencyVersion` | Dependencies |
| Upgrade Maven Plugins | `org.openrewrite.maven.UpgradePlugins` | Build |
| Upgrade Gradle Plugins | `org.openrewrite.gradle.UpgradePlugins` | Build |
| **Umbrella (all above)** | **`com.company.FullModernization`** (custom, from `rewrite.yml`) | **Platform-wide** |

### Migration Guides
- Java 8 → 25: https://docs.openrewrite.org/docs/java-modules
- Spring Boot 2.x → 4.0: https://spring.io/projects/spring-boot
- Jakarta EE: https://jakarta.ee/specifications/

---

## Migration Checklist

- [ ] Git working directory is clean (`git status`)
- [ ] Create new branch (`git checkout -b upgrade/...`)
- [ ] Install target Java version (e.g., JDK 25)
- [ ] Verify Gradle wrapper (8.5+) / Maven wrapper (3.9.0+) supports target JDK
- [ ] Update CI/CD runner images to include target JDK
- [ ] Verify Docker base images use target JDK
- [ ] Add OpenRewrite plugin to pom.xml or build.gradle
- [ ] (Optional) Create `rewrite.yml` umbrella recipe
- [ ] Run dry-run first (`./mvnw rewrite:dryRun`)
- [ ] Review changes (`git diff`, `rewrite-datatables/`)
- [ ] Apply migration (`./mvnw rewrite:run`)
- [ ] Verify BOM-managed dependency versions are compatible
- [ ] Check internal/private library compatibility (manual)
- [ ] Review third-party dependency tree (solve conflicts)
- [ ] Run full test suite (`./mvnw clean test`)
- [ ] Fix any compilation/test errors
- [ ] Update IDE project SDK setting
- [ ] Smoke test critical application endpoints
- [ ] Remove OpenRewrite plugin (optional, but recommended)
- [ ] Commit changes (`git add . && git commit -m "..."`)
- [ ] Create PR for review
- [ ] Deploy to staging, run integration tests
- [ ] Merge to main after approval

---

## Notes for AI Agents

**This skill covers 95% of automated migrations**. For the remaining 5% (third-party library incompatibilities, custom code patterns), refer to the project's official migration guide.

When migrations fail:
1. Check if it's a known limitation (see Troubleshooting)
2. Consult migration guide for manual fixes
3. Test incrementally to isolate failures
4. Never commit code with failing tests

**Always prioritize safety**: dry-run → review → test → commit.
