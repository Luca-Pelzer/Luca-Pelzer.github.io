---
title: "De CLI a SDK: Haciendo Invisible al Agente Interno de Sleepless-OpenCode"
date: 2025-01-12
draft: false
tags: ["opencode", "sdk", "agents", "automation", "typescript", "sleepless-opencode"]
categories: ["AI", "Technical"]
description: "Cómo migramos de ejecución por línea de comandos a llamadas programáticas del SDK para ocultar un agente interno de la UI, resolviendo un problema de arquitectura complicado en sleepless-opencode."
---

Estaba construyendo [sleepless-opencode](https://github.com/Luca-Pelzer/sleepless-opencode), un daemon de agente IA 24/7 que procesa tareas de programación en segundo plano. Piensa en ello como una cola de tareas donde envías trabajo a través de Discord, y un agente IA lo ejecuta mientras duermes.

El daemon usa un agente especializado llamado `sleepless-executor` para ejecutar tareas. Este agente es puramente interno—no está pensado para interacción directa del usuario. Los usuarios nunca deberían seleccionarlo manualmente desde el selector de agentes.

Pero había un problema: **para funcionar con la CLI de OpenCode, el agente tenía que estar configurado como `mode: primary`, lo que lo hacía visible en la UI.**

Esto era molesto. Cada vez que los usuarios abrían el selector de agentes, veían este detalle de implementación interna desordenando su interfaz. No era ideal.

## El Desafío: Limitaciones de la CLI

El daemon originalmente iniciaba sesiones de OpenCode usando la CLI:

```bash
opencode run --agent sleepless-executor --session <id> -- "<prompt>"
```

Esto funcionaba bien, pero la CLI de OpenCode tiene una limitación: **solo reconoce agentes en modo `primary`**. Los agentes configurados como `subagent` (que están ocultos de la UI) simplemente no funcionan con invocaciones de CLI.

Así que estábamos atrapados:
- Usar `mode: primary` → El agente funciona pero aparece en la UI ❌
- Usar `mode: subagent` → El agente está oculto pero la CLI falla ❌

Ninguna opción era aceptable.

## La Investigación: ¿Cómo lo Hacen los Plugins?

Comencé a investigar cómo otros plugins de OpenCode inician agentes programáticamente. Específicamente, miré el código fuente del plugin [oh-my-opencode](https://github.com/opencode-ai/oh-my-opencode).

Fue entonces cuando descubrí el secreto: **OpenCode tiene un SDK oficial** (`@opencode-ai/sdk`) que proporciona acceso directo a la API para gestión de sesiones, evitando completamente la CLI.

Al SDK no le importan los modos de agente. Puede iniciar cualquier agente—primary o subagent—porque habla directamente con las APIs internas de OpenCode.

¡Perfecto! Esto era exactamente lo que necesitábamos.

## La Solución: Adoptar el SDK

Migré el daemon de ejecución basada en CLI a ejecución basada en SDK. Así es como funciona:

### 1. Inicializar el Servidor SDK

Al iniciar el daemon, creamos un servidor SDK de OpenCode:

```typescript
import { createOpencode, type OpencodeClient } from "@opencode-ai/sdk";

this.abortController = new AbortController();
const opencode = await createOpencode({
  signal: this.abortController.signal,
  timeout: 30000,
});
this.client = opencode.client;
this.server = opencode.server;

console.log(`OpenCode SDK server started at ${this.server.url}`);
```

### 2. Crear Sesiones Programáticamente

En lugar de generar procesos CLI, usamos la API `session.create()` del SDK:

```typescript
const createResult = await client.session.create({
  body: {
    title: `Sleepless Task #${task.id}`,
  },
  query: { directory: workDir },
});

const sessionId = createResult.data.id;
```

### 3. Enviar Prompts a Cualquier Agente

Aquí está la magia: `session.prompt()` funciona con **cualquier agente**, independientemente del modo:

```typescript
const promptResult = await client.session.prompt({
  path: { id: sessionId },
  body: {
    agent: "sleepless-executor",  // ¡Funciona incluso como subagent!
    parts: [{ type: "text", text: prompt }],
  },
  query: { directory: workDir },
});
```

### 4. Esperar la Finalización

Hacemos polling del estado de la sesión hasta que quede idle:

```typescript
while (Date.now() - startTime < timeoutMs) {
  await this.sleep(2000);
  
  const statusResult = await client.session.status({
    query: { directory: workDir },
  });
  
  if (statusResult.data?.[sessionId]?.type === "idle") {
    const messagesResult = await client.session.messages({
      path: { id: sessionId },
      query: { directory: workDir },
    });
    return extractOutputFromMessages(messagesResult.data);
  }
}
```

### 5. Actualizar la Configuración del Agente

Finalmente, cambiamos el modo del agente a `subagent`:

```yaml
---
description: Internal daemon worker - do not use directly
mode: subagent  # Cambiado de 'primary'
model: anthropic/claude-sonnet-4-5
---
```

¡Listo! El agente ahora está oculto de la UI pero completamente funcional.

## Los Beneficios

Esta migración nos dio varias victorias:

1. **Oculto de la UI**: `sleepless-executor` ya no desordena el selector de agentes
2. **Control programático**: Acceso completo a la API de gestión de sesiones
3. **Mejor integración**: Comunicación directa sin overhead de CLI
4. **Compatible hacia atrás**: Fallback a CLI si la inicialización del SDK falla
5. **Arquitectura más limpia**: Ya no hay que generar procesos shell y parsear stdout

## Profundización Técnica

El SDK proporciona estas APIs clave:

| API | Propósito |
|-----|-----------|
| `session.create()` | Crear nuevas sesiones de agente |
| `session.prompt()` | Enviar prompts a sesiones (funciona con cualquier modo de agente) |
| `session.status()` | Verificar si la sesión está idle/activa |
| `session.messages()` | Obtener mensajes y salida de la sesión |

El flujo de ejecución del daemon ahora se ve así:

```
1. Daemon inicia → Inicializar servidor SDK
2. Tarea en cola → Crear sesión vía SDK
3. Enviar prompt → session.prompt() con nombre del agente
4. Polling de estado → Esperar hasta que session.status() === "idle"
5. Extraer salida → session.messages() para obtener resultados
6. Notificar usuario → Enviar notificación por Discord/Slack
```

## Lecciones Aprendidas

1. **Lee el código fuente de los plugins**: Cuando la documentación no cubre tu caso de uso, investiga cómo los plugins existentes resuelven problemas similares.

2. **SDK > CLI para uso programático**: Si estás construyendo automatización o integraciones, el SDK te da mucho más control y flexibilidad que ejecutar comandos en la CLI.

3. **Los modos de agente importan**: Entender la diferencia entre `primary` (orientado al usuario) y `subagent` (interno) es crucial para construir UIs limpias.

4. **Siempre ten un fallback**: Mantener la ruta de ejecución CLI como fallback asegura robustez incluso si el SDK tiene problemas.

## Conclusión

Esta migración demuestra el poder del SDK de OpenCode para construir integraciones programáticas. Al movernos de CLI a SDK, logramos una arquitectura más limpia donde los agentes internos pueden permanecer ocultos mientras siguen siendo completamente funcionales.

Si estás construyendo integraciones de OpenCode y necesitas control programático de agentes, sáltate la CLI y ve directo al SDK. Tu yo futuro (y tus usuarios) te lo agradecerán.

---

**¿Quieres probar sleepless-opencode?**

Échale un vistazo en [GitHub](https://github.com/Luca-Pelzer/sleepless-opencode).
