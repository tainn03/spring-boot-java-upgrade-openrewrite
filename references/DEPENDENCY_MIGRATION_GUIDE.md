# Dependency Migration Quick Reference

A practical guide for managing all dependency categories during Java/Spring Boot platform upgrades.

---

## 1. BOM-Managed Dependencies

BOMs centralize dependency version control. OpenRewrite handles Spring BOMs but **not** company/internal BOMs.

### Maven — Identify BOMs

```bash
# List all BOM imports
grep -A5 "<type>pom</type>" pom.xml | grep -E "groupId|artifactId|version"
```

### Gradle — Identify Platforms

```bash
# List all platform dependencies
grep -n "platform(" build.gradle build.gradle.kts
```

### Action Matrix

| BOM Type | Auto-updated? | Action |
|----------|--------------|--------|
| `spring-boot-dependencies` | ✅ OpenRewrite | Verify after migration |
| `spring-cloud-dependencies` | ✅ OpenRewrite | Check `UpgradeSpringCloud_2025_1` |
| `company-dependencies` | ❌ Manual | Update version property; review for compatibility |
| `jackson-bom` | ✅ (if public) | Verify Jackson 3 BOM coordinates |
| Third-party BOMs | ⚠️ Depends | Check if recipe exists; else manual |

### Verify BOM Resolution

```bash
# Maven: Check which version is actually resolved
./mvnw dependency:tree -Dincludes=com.fasterxml.jackson:jackson-databind

# Gradle: Check the resolved version
./gradlew dependencyInsight --dependency com.fasterxml.jackson:jackson-databind
```

---

## 2. Internal / Private Dependencies

These require **separate upgrade cycles**. OpenRewrite cannot update versions on private registries.

### Quick Audit Script

```bash
# List all dependencies with company groupIds (adjust pattern as needed)
./mvnw dependency:tree | grep -E "(com\.yourcompany|com\.internal)" | sort -u
```

### Upgrade Path

```
1. Identify all internal libs used in the project
2. For each: check compatibility with target Java/Spring version
3. If incompatible: upgrade the library project first (use OpenRewrite there too)
4. Publish new version to private registry (Nexus/Artifactory)
5. Update version in consuming project
```

### Multi-Module Projects

If internal dependencies are source modules in the same repo:

```bash
# OpenRewrite processes ALL modules when run from root
./mvnw rewrite:run
# → All source modules are migrated together
```

> ✅ **No extra action needed** — same-repo modules are fully covered by OpenRewrite.

---

## 3. External / Third-Party Dependencies

### Compatibility Scan

```bash
# Maven: Show all dependencies with their resolved versions
./mvnw dependency:tree -Dverbose > deps-before.txt

# After migration, compare
./mvnw dependency:tree -Dverbose > deps-after.txt
diff deps-before.txt deps-after.txt
```

### Known Incompatibilities by Library

| Library | Compatible Version | Notes |
|---------|-------------------|-------|
| Hibernate | 6.4+ | Required by Spring Boot 4.0 |
| Jackson | 3.x | Breaking API changes |
| Lombok | 1.18.30+ | Java 25 support |
| MapStruct | 1.5.5+ | Java 25 support |
| Spring Cloud | 2025.1.x | Required for Boot 4.0 |
| Mockito | 5.x | JUnit 6 compatibility |
| Testcontainers | 1.19+ | Java 25 support |

### Force Version Upgrade

```bash
# Maven: Upgrade all deps to latest release (use with caution!)
./mvnw rewrite:run -Drewrite.activeRecipes=org.openrewrite.maven.UpgradeDependencyVersion \
  -Drewrite.options.groupId="*" \
  -Drewrite.options.artifactId="*" \
  -Drewrite.options.newVersion=latest.release
```

---

## 4. Build Tools & Plugins

### Required Version Check

```bash
# Check Maven compiler plugin
./mvnw help:effective-pom | grep maven-compiler-plugin -A5

# Check Gradle Java version
grep "sourceCompatibility\|targetCompatibility\|languageVersion" build.gradle
```

### Plugin Compatibility Matrix

| Plugin | Minimum Version | Notes |
|--------|----------------|-------|
| `maven-compiler-plugin` | 3.11+ | For Java 25 `--release` flag |
| `maven-surefire-plugin` | 3.2+ | JUnit 6 compatibility |
| `maven-failsafe-plugin` | 3.2+ | Integration test compat |
| `jacoco-maven-plugin` | 0.8.11+ | Java 25 bytecode |
| `spotbugs-maven-plugin` | 4.8+ | Java 25 support |
| `lombok-maven-plugin` | 1.18.30+ | Java 25 annotation processing |
| Spring Boot Gradle plugin | 3.5+ (Gradle 8.x) | Boot 4.0 requires Gradle 8.5+ |

### Update All Plugins

```bash
# Maven: Display available plugin updates
./mvnw versions:display-plugin-updates

# Gradle: Check for plugin updates
./gradlew help --task :dependencyUpdates
```

---

## 5. Infrastructure & Platform

### CI/CD Runner Requirements

| Platform | JDK 25 Setup |
|----------|-------------|
| GitHub Actions | `actions/setup-java@v4` with `java-version: "25"` |
| Jenkins | Install JDK 25 via `jdk` tool or custom tool |
| GitLab CI | `image: eclipse-temurin:25-jdk` or `java: "25"` |
| CircleCI | `circleci/openjdk:25-jdk` |

### Docker Base Images

```dockerfile
# Recommended JDK 25 base images
FROM eclipse-temurin:25-jre          # Eclipse Temurin (recommended)
FROM amazoncorretto:25               # AWS Corretto
FROM azul/zulu-openjdk:25            # Azul Zulu
FROM ibm-semeru-runtimes:open-25-jre # IBM Semeru
```

### APM & Monitoring

| Tool | Java 25 Status |
|------|---------------|
| Datadog Java Agent | ✅ 1.29+ |
| New Relic Java Agent | ✅ 8.0+ |
| Dynatrace OneAgent | ✅ 1.267+ |
| Elastic APM | ✅ 1.45+ |
| OpenTelemetry Agent | ✅ 1.31+ |

---

## 6. Wrapper Version Compatibility

### Maven Wrapper

```bash
# Check current version
grep distributionUrl .mvn/wrapper/maven-wrapper.properties

# Update to version compatible with JDK 25
./mvnw -N wrapper:wrapper -Dmaven=3.9.9
```

| Maven | JDK 25 | Spring Boot 4.0 |
|-------|--------|-----------------|
| 3.8.x | ⚠️ Partial | ❌ |
| 3.9.0+ | ✅ | ✅ |
| 3.9.6+ | ✅✅ Recommended | ✅✅ Recommended |

### Gradle Wrapper

```bash
# Check current version
./gradlew --version | grep "Gradle "

# Update to version compatible with JDK 25
./gradlew wrapper --gradle-version=8.10

# Verify compatibility
./gradlew --version
```

| Gradle | JDK 25 | Spring Boot 4.0 |
|--------|--------|-----------------|
| 8.4 and below | ❌ | ❌ |
| 8.5+ | ✅ | ✅ |
| 8.10+ | ✅✅ Recommended | ✅✅ Recommended |

### Wrapper Update Strategy

```
git checkout -b upgrade/wrapper-jdk25
  → Update mvnw / gradlew
  → Commit: "chore: update build wrapper for JDK 25"  ← Separate PR
  → Run tests to verify wrapper works
  → Merge

git checkout -b upgrade/java25-springboot4
  → Run OpenRewrite migrations
  → Commit: "chore: migrate to Java 25 + Spring Boot 4.0"
  → Test and merge
```

> **Always update wrappers first, in a separate step.** This ensures the build tool itself can handle the migration.

---

## 7. Dependency Conflict Quick Diagnosis

```bash
# === Maven ===
# Full tree
./mvnw dependency:tree -Dverbose > tree.txt

# Search for specific artifact conflict
./mvnw dependency:tree -Dincludes=com.fasterxml.jackson*

# Display dependency convergence errors
./mvnw enforcer:enforce -Drules=dependencyConvergence

# === Gradle ===
# Full tree
./gradlew dependencies > deps.txt

# Inspect a specific dependency
./gradlew dependencyInsight --dependency jackson-databind

# Write dependency locks for reproducible builds
./gradlew dependencies --write-locks
```

### Common Conflict Patterns After Migration

| Conflict | Cause | Fix |
|----------|-------|-----|
| Jackson 2.x + 3.x on classpath | Library depends on old Jackson | Exclude transitive Jackson 2.x |
| `javax.servlet` vs `jakarta.servlet` | Old library not migrated | Exclude old transitive dep or upgrade lib |
| Multiple SLF4J bindings | Logging framework mismatch | Exclude one binding |
| Duplicate class: `javax.annotation.*` | Old Jakarta EE annotation | Add `--add-modules` or exclude old jar |

---

## Quick Decision Tree

```
Is the dependency in a BOM?
├── Yes → Is it a Spring/Cloud BOM?
│   ├── Yes → ✅ OpenRewrite handles it
│   └── No  → ⚠️ Manual update needed (company BOM, custom BOM)
└── No  → Is it an internal (company) library?
        ├── Yes → ❌ Upgrade library project separately
        └── No  → Is it a well-known OSS library?
                ├── Yes → ✅ Check if OpenRewrite recipe exists
                └── No  → ⚠️ Manual version bump + compatibility check
```

---

## Rollback Strategy

If dependency migration causes failures:

```bash
# 1. Revert all dependency changes
git checkout HEAD -- pom.xml build.gradle build.gradle.kts

# 2. Keep only OpenRewrite-generated code changes (safe imports)
git add -p  # Selectively stage non-dependency changes

# 3. Rebuild with old dependency versions but new code
./mvnw clean compile  # Verify code compiles

# 4. Fix dependency conflicts one-by-one
```

---

## Resources

- OpenRewrite UpgradeDependencyVersion: https://docs.openrewrite.org/recipes/maven/upgradedependencyversion
- Maven Versions Plugin: https://www.mojohaus.org/versions-maven-plugin/
- Gradle Versions Plugin: https://github.com/ben-manes/gradle-versions-plugin
- Spring Boot Dependency Versions: https://docs.spring.io/spring-boot/appendix/dependency-versions/
