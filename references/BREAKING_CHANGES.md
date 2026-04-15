# Spring Boot 4.0 & Java 21 Breaking Changes Reference

## Key Breaking Changes to Watch For

### 1. Jakarta EE Migration (Spring Boot 3.0+)
- **javax.* → jakarta.***
- All servlet APIs changed
- All JPA/persistence APIs changed
- All validation APIs changed

**Example:**
```java
// BEFORE (Java <= 17, Spring Boot < 4.0)
import javax.servlet.http.HttpServletRequest;
import javax.persistence.Entity;
import javax.validation.Valid;

// AFTER (Java 21, Spring Boot 4.0+)
import jakarta.servlet.http.HttpServletRequest;
import jakarta.persistence.Entity;
import jakarta.validation.Valid;
```

**Status:** ✅ OpenRewrite handles this automatically

---

### 2. Servlet 6.1 Compatibility
- Requires `jakarta.servlet` >= 6.1
- Response header handling changed
- Cookie APIs updated

**Status:** ✅ OpenRewrite handles this automatically

---

### 3. Java Language Features
- Records - stable API now
- Sealed classes - stable
- Pattern matching - expanding
- Virtual threads (Project Loom) - new capability

**Your action:** Review code using older patterns, consider modernizing

---

### 4. Properties File Changes
Common property renamings in Spring Boot 4.0:

| Old Property | New Property | Spring Boot 4.0 |
|---|---|---|
| `management.metrics.enable.*` | `management.metrics.enable` | Unified |
| `spring.jpa.hibernate.use-new-id-generator-mappings` | Removed | Use `spring.jpa.hibernate.id.new_generator_mappings` |
| `server.servlet.path` | `spring.webservlet.servlet.path` | Check migration docs |

**Your action:** Check your `application.properties` or `application.yml` against [official migration guide](https://spring.io/projects/spring-boot)

---

### 5. Third-Party Library Compatibility
NOT automatically migrated - requires manual review:

- **Hibernate** - Must be 6.4+
- **Spring Data** - Specific versions only
- **Spring Security** - Must align with Spring Boot 4.0
- **Spring Cloud** - Check compatibility matrix
- **Custom libraries** - May need code updates

**Your action:** 
1. Run `./mvnw dependency-check` or similar
2. Check Maven Central for compatible versions
3. Update `pom.xml` manually or via OpenRewrite custom recipes

---

### 6. Modular Starters Removal
Spring Boot 4.0 removed some combined starters:

- `spring-boot-starter-web-services` → use individual starters
- Check [Spring Boot 4.0 docs](https://spring.io/projects/spring-boot) for full list

**Your action:** If using removed starters, replace with equivalent explicit dependencies

---

### 7. Configuration Processor Changes
The annotation processor may have breaking changes:

```xml
<!-- Ensure you have this for IDE autocomplete in application.properties -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-configuration-processor</artifactId>
    <optional>true</optional>
</dependency>
```

---

## Testing After Migration

```bash
# 1. Full compile check
./mvnw clean compile

# 2. Run all tests
./mvnw clean test

# 3. Start application
./mvnw spring-boot:run

# 4. Check logs for deprecation warnings
# Look for: "WARN ... is deprecated"

# 5. Smoke test critical endpoints
curl http://localhost:8080/health
```

---

## Common Post-Migration Issues

### 🔴 Issue: Import not found `javax.servlet.*`
**Cause:** Old servlet import still in code
**Fix:** Replace with `jakarta.servlet.*`
**Prevention:** OpenRewrite should catch this, but manual imports may slip through

### 🔴 Issue: Test fails with `ClassNotFoundException: jakarta.*`
**Cause:** Test dependencies not updated
**Fix:** Update test-scoped Spring dependencies
**Check:** `pom.xml` or `build.gradle` test dependencies

### 🔴 Issue: Hibernate errors about sequence generation
**Cause:** Old ID generator config incompatible
**Fix:** Update `spring.jpa.hibernate.id-new-generator-mappings = true`

### 🔴 Issue: Custom properties not recognized
**Cause:** Property names changed or moved
**Fix:** Check official Spring Boot 4.0 migration guide

---

## Resources

- **Official Migration Guide:** https://spring.io/projects/spring-boot
- **OpenRewrite Spring Recipes:** https://docs.openrewrite.org/recipes/java/spring
- **Jakarta EE Guide:** https://jakarta.ee/
- **Java 21 Features:** https://openjdk.java.net/
