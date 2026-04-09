---
description: "Ejecutar code review estructurado con checklist de seguridad, funcionalidad, calidad y performance"
agent: "full-cycle-developer"
argument-hint: "Ticket o archivos a revisar (ej: TICKET-WP-001)"
---

# Code Review Estructurado

Realiza una revisión de código completa para {{PROJECT_NAME}}.

## Checklist

### Seguridad
- [ ] No hay credenciales hardcodeadas
- [ ] Input sanitizado (`sanitize_text_field()`, `absint()`)
- [ ] Output escapado (`esc_html()`, `esc_attr()`, `esc_url()`)
- [ ] SQL usa `$wpdb->prepare()`
- [ ] Nonces en formularios
- [ ] Sin funciones peligrosas (`eval`, `exec`, `system`)

### Funcionalidad
- [ ] Cumple criterios de aceptación del ticket
- [ ] Responsive (mobile + desktop)
- [ ] Manejo de errores
- [ ] No rompe funcionalidad existente

### Calidad
- [ ] Convenciones del proyecto (WPCS, prefijo `{{TABLE_PREFIX}}_`)
- [ ] Sin código muerto
- [ ] Sin debug output (`console.log`, `var_dump`)
- [ ] DRY — sin duplicación

### Performance
- [ ] Sin queries en loops (N+1)
- [ ] Lazy loading en imágenes
- [ ] Cache Redis utilizado
- [ ] Assets optimizados

### Bilingüe
- [ ] Strings con `__()` / `_e()`
- [ ] Text domain `{{TEXT_DOMAIN}}`

## Output
Tabla de hallazgos con severidad + resultado global (✅ / ⚠️ / ❌)
