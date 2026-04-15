# AI Coding Agent Guidelines

## Project Overview

**spring-boot-java-upgrade-openrewrite** is a skill for safely automating Spring Boot and Java version upgrades using OpenRewrite recipes.

**Scope:**
- Upgrades Spring Boot 3.5.x → 4.0.x
- Upgrades Java 17 → 21
- Supports both Maven and Gradle projects
- Handles single-module and multi-module projects

## Installation

Install this skill into your AI coding agent environment using:

```bash
npx skills add tainn03/spring-boot-java-upgrade-openrewrite
```

After installation, the skill will be available to your agent for automating Spring Boot and Java version upgrades.

## Key Conventions

### Build Tool Detection
The project supports both Maven and Gradle. Always detect the build tool first:
- Check for `pom.xml` → Maven
- Check for `build.gradle` or `build.gradle.kts` → Gradle
- Use `scripts/detect-build-tool.sh` to automate detection

### Maven Commands
```bash
./mvnw rewrite:dryRun    # Preview changes (always run first)
./mvnw rewrite:run       # Apply migration
./mvnw clean test        # Verify after upgrade
```

### Gradle Commands
```bash
./gradlew rewriteDryRun  # Preview changes (always run first)
./gradlew rewriteRun     # Apply migration
./gradlew clean test     # Verify after upgrade
```

## Essential Workflows

### 1. Adding OpenRewrite Plugin
See [references/pom-template.xml](references/pom-template.xml) for Maven pattern.
See [references/build-gradle-template.gradle](references/build-gradle-template.gradle) for Gradle pattern.

Key recipes (always use both together):
- `org.openrewrite.java.migrate.UpgradeToJava21` - Java version migration
- `org.openrewrite.java.spring.boot4.UpgradeSpringBoot_4_0` - Spring Boot version migration

### 2. Running Safe Migrations
1. **Always dry-run first** - `./mvnw rewrite:dryRun` or `./gradlew rewriteDryRun`
2. **Review changes** - Check `git diff` and `rewrite-datatables/` reports
3. **Run actual migration** - `./mvnw rewrite:run` or `./gradlew rewriteRun`
4. **Test thoroughly** - `./mvnw clean test` or `./gradlew clean test`

### 3. Handling Breaking Changes
See [references/BREAKING_CHANGES.md](references/BREAKING_CHANGES.md) for detailed reference.

Common changes OpenRewrite handles automatically:
- `javax.*` → `jakarta.*` imports (servlet, persistence, validation)
- Servlet 6.1 compatibility updates
- Property name renamings

**Manual follow-up:**
- Review uses of Java language features (records, sealed classes, pattern matching)
- Update IDE project SDK to JDK 21
- Fix third-party library incompatibilities (not handled by OpenRewrite)

## Critical Rules

### ✅ DO:
- Always commit clean git state before migrations
- Run dryRun before actual migration
- Test the full suite after migration
- Use separate branch for upgrades: `git checkout -b upgrade-spring-boot-4-java-21`
- Verify Java 21 is installed: `java -version`

### ❌ DON'T:
- Run Spring Boot recipe before upgrading to Java 21 (wrong order)
- Forget `activeRecipe()` in Gradle (singular, not `activeRecipes()`)
- Skip dry-run step
- Leave OpenRewrite plugin in build file permanently

## Common Pitfalls

| Pitfall | Issue | Fix |
|---------|-------|-----|
| Plugin version too old | Missing recipes or outdated transformations | Use `latest.release` or pin recent version |
| Wrong property syntax | Gradle build fails | Use `activeRecipe()` singular, not `activeRecipes()` |
| Missing dependencies | Plugin can't find recipes | Add `rewrite-migrate-java` and `rewrite-spring` dependencies |
| Running recipes in wrong order | Java 21 features incompatible with Spring Boot 3.5.x | Always run Java upgrade recipe first |
| Third-party incompatibility | Build fails after migration | Manual fix needed; check library compatibility with Spring Boot 4.0 |

## Repository Structure

```
.
├── SKILL.md                              # Detailed workflow guide
├── references/
│   ├── BREAKING_CHANGES.md              # What changes in Spring Boot 4.0 & Java 21
│   ├── pom-template.xml                 # Maven OpenRewrite plugin template
│   └── build-gradle-template.gradle     # Gradle OpenRewrite plugin template
└── scripts/
    ├── detect-build-tool.sh             # Auto-detect Maven vs Gradle
    └── migration-dryrun.sh              # Safe dry-run helper script
```

## When Helping Users

When users ask to upgrade their Spring Boot or Java project:

1. **First:** Verify prerequisites
   - Project is stable at Spring Boot 3.5.x + Java 17
   - Git state is clean
   - Java 21 is installed

2. **Second:** Use [SKILL.md](SKILL.md) workflow
   - Follow step-by-step order (Step 1-4)
   - Always emphasize dry-run safety

3. **Third:** Reference templates and breaking changes
   - Point to [build-gradle-template.gradle](references/build-gradle-template.gradle) or [pom-template.xml](references/pom-template.xml)
   - Link to [BREAKING_CHANGES.md](references/BREAKING_CHANGES.md) for manual follow-up items

4. **Finally:** Test and validate
   - Run full test suite
   - Check rewrite-datatables reports
   - Guide manual fixes if needed

## Relevant Documentation

- **SKILL.md** - Complete step-by-step migration workflow
- **BREAKING_CHANGES.md** - Detailed breaking changes and Jakarta EE migration
- **Build Templates** - Copy-paste ready plugin configurations
- **Helper Scripts** - Automation for build tool detection and dry-runs

## Notes for AI Agents

- This project is primarily a **documentation + template toolkit**, not a typical source code repo
- Focus on guiding users through the SKILL.md workflow correctly
- Emphasize safety: dry-run first, test after, use separate branch
- Use helper scripts to automate repetitive tasks
- Break down complex migrations into Step 1-4 sequence from SKILL.md
- Always reference the official OpenRewrite and Spring Boot 4.0 migration docs for edge cases
