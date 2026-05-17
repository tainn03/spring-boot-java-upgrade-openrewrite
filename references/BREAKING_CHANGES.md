# Spring Boot 4.0 & Java 25 Breaking Changes Reference

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

// AFTER (Java 25, Spring Boot 4.0+)
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

### 7. Jackson 3 Migration (Major Breaking Change)

Jackson 3 is a **major rewrite** that removes many legacy APIs and changes defaults.

**What breaks**:
- `ObjectMapper` configuration API changed (fluent-style replacement)
- `SerializationFeature` / `DeserializationFeature` enum values renamed or removed
- `JsonParser.Feature` / `JsonGenerator.Feature` restructured
- `@JsonIgnore`, `@JsonProperty` semantics may differ
- Custom `JsonSerializer`/`JsonDeserializer` base classes changed
- Module registration API changed
- Mix-in annotations behavior may differ

**Example transformation**:
```java
// BEFORE (Jackson 2.x)
ObjectMapper mapper = new ObjectMapper();
mapper.enable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

// AFTER (Jackson 3.x)
ObjectMapper mapper = new ObjectMapper();
mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
```

**Status:** ✅ OpenRewrite handles this automatically

**Post-migration manual checks**:
- Review any custom `ObjectMapper` configuration in your codebase
- Check custom serializers/deserializers for API compatibility
- Verify JSON serialization in integration tests (edge cases)
- Test backward compatibility with stored serialized data
- Update any Jackson-dependent libraries (Feign, RestTemplate, etc.)

---

### 8. JUnit 4/5 → 6 Migration

JUnit 6 is the successor of JUnit 5, removing legacy JUnit 4 dependencies and updating test framework APIs.

**What breaks**:
- JUnit 4 vintage engine is removed (any remaining JUnit 4 tests will fail)
- `Assertions` and related classes may have updated method signatures
- Conditional test execution (`@EnabledIf`, `@DisabledIf`) APIs refined
- Test extensions from JUnit 5 may need updates

**Status:** ✅ OpenRewrite handles this automatically

**Migration notes**:
- Most `@Test` annotations remain unchanged
- The migration primarily cleans up transitive dependencies
- If you have custom JUnit 5 extensions, check compatibility

---

### 9. Dependency Version Conflicts (Post-Migration)

After major migration, you may encounter version conflicts.

**Jackson 2.x vs 3.x conflict**:
```xml
<!-- If a library pulls in Jackson 2.x, exclude it: -->
<dependency>
    <groupId>some.library</groupId>
    <artifactId>some-artifact</artifactId>
    <exclusions>
        <exclusion>
            <groupId>com.fasterxml.jackson</groupId>
            <artifactId>*</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```

**Jakarta EE conflict (javax.* vs jakarta.*)**:
```xml
<!-- Old libraries depending on javax.* may cause NoClassDefFoundError -->
<!-- Solution: upgrade the library or exclude the javax transitive dependency -->
```

**Spring Cloud BOM version mismatch**:
```xml
<!-- WRONG: Spring Cloud 2025.0 is NOT compatible with Boot 4.0 -->
<spring-cloud.version>2025.0.1</spring-cloud.version>

<!-- CORRECT: Spring Cloud 2025.1+ is required -->
<spring-cloud.version>2025.1.0</spring-cloud.version>
```

---

### 10. Configuration Processor Changes
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
- **Java 25 Features:** https://openjdk.java.net/
