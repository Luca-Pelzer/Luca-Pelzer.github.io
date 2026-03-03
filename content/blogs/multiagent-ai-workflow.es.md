---
title: "Mi Equipo de IA: Cómo los Flujos Multi-Agente se Sienten Como Tener Empleados"
date: 2025-12-16
draft: false
tags: ["ai", "automation", "opencode", "mcp", "productivity", "homelab"]
categories: ["AI", "Automation"]
description: "Configuré un sistema de IA multi-agente que se siente como gestionar un equipo de empleados especializados. Así es como OpenCode, MCPs y LSPs convirtieron la IA de un chatbot en infraestructura real."
---

# Mi Equipo de IA: Cómo los Flujos Multi-Agente se Sienten Como Tener Empleados

**TL;DR**: Construí una configuración de IA multi-agente usando OpenCode con 11 agentes especializados. Cada uno es experto en su dominio (código, almacenamiento, seguridad, docs, etc.). Combinados con MCPs (Model Context Protocol) y LSPs (Language Server Protocol), pueden interactuar realmente con mis sistemas. Genuinamente se siente como delegar a un equipo en lugar de hacer todo yo mismo.

---

## El Problema: Ser un Departamento de TI de Una Persona

¿Sabes qué apesta? Ser la única persona responsable de todo.

Manejo un homelab con:
- Cluster Proxmox con 10+ VMs y contenedores
- Servidor de correo, DNS, proxy inverso, monitoreo
- Múltiples aplicaciones web y servicios
- Gestión de almacenamiento con LVM y thin provisioning
- Reglas de firewall, hardening de seguridad, backups
- Documentación que siempre está desactualizada

Cada vez que algo se rompe, soy yo quien lo arregla. Cada vez que quiero agregar una función, soy yo quien la codifica. Cada vez que necesito documentación, soy yo quien la escribe.

**El cambio de contexto es agotador.**

Un minuto estoy depurando Python. Al siguiente estoy analizando reglas de firewall Shorewall. Luego escribo comandos LVM. Luego actualizo documentación. Luego vuelvo a Python pero he olvidado completamente lo que estaba haciendo.

Intenté tomar notas. Intenté mejor organización. Intenté simplemente aceptar que olvidaría todo y lo reaprendería cada vez.

Luego descubrí algo que realmente funcionó: **flujos de trabajo de IA multi-agente.**

---

## La Solución: Un Equipo de IA

Aquí está la configuración que construí usando [OpenCode](https://github.com/sst/opencode):

### El Equipo

| Agente | Rol | Modelo | Qué Hacen |
|-------|------|-------|-----------|
| **Orchestrator** | Gerente | Claude Opus | Enruta tareas al especialista correcto |
| **Code-Builder** | Desarrollador | Claude Opus | Desarrollo Python, Node.js, Go |
| **Storage-Manager** | SysAdmin | Claude Sonnet | LVM, backups, almacenamiento Proxmox |
| **Firewall-Auditor** | Analista de Seguridad | Claude Sonnet | Análisis Shorewall (solo lectura) |
| **Security-Auditor** | Ingeniero de Seguridad | Claude Opus | Hardening SSH, cumplimiento |
| **VM-Monitor** | Operaciones | Claude Haiku | Chequeos de salud Container/VM |
| **Research-Agent** | Investigador | Claude Sonnet | Recopilar info, mejores prácticas |
| **Writer-Agent** | Escritor Técnico | Claude Opus | Documentación, guías, tutoriales |
| **DevOps-Helper** | Ingeniero DevOps | Claude Sonnet | Docker, CI/CD, despliegue |
| **Docs-Keeper** | Bibliotecario | Claude Haiku | Mantener runbooks, archivo |
| **Agent-Creator** | Meta-Agente | Claude Opus | Crea nuevos agentes (!) |

Cada agente tiene:
- **Conocimiento especializado** en su dominio
- **Herramientas específicas** que pueden usar (vía MCPs)
- **Responsabilidades claras** y límites
- **Modelos diferentes** basados en complejidad de tarea

---

## El Cambio de Juego: MCPs y LSPs

Aquí es donde se pone salvaje. Estos no son solo chatbots que generan texto. Pueden realmente **hacer cosas.**

### MCPs (Model Context Protocol)

Piensa en los MCPs como "herramientas que permiten a la IA interactuar con sistemas reales." En lugar de solo hablar sobre qué hacer, los agentes pueden realmente ejecutar comandos y obtener datos reales.

Construí servidores MCP personalizados para mi infraestructura:

**Proxmox MCP** - Gestionar mi cluster de virtualización
```typescript
// La IA puede realmente consultar mi cluster Proxmox
tools: [
  "proxmox_list_containers",      // Listar todas las VMs y contenedores
  "proxmox_container_status",     // Verificar si un contenedor está corriendo
  "proxmox_storage_status",       // Ver uso del pool de almacenamiento
  "proxmox_node_status"           // Obtener CPU, RAM, uptime
]
```

**Storage MCP** - Acceso directo a sistemas de almacenamiento
```typescript
// Acceso directo a comandos LVM
tools: [
  "storage_vg_status",      // Info de volume group
  "storage_lv_status",      // Detalles de logical volume
  "storage_disk_usage",     // Uso de filesystem (df -h)
  "storage_smart_status",   // Datos de salud del disco
  "storage_thin_pool_status" // Métricas de thin provisioning
]
```

**Shorewall MCP** - Análisis de firewall (solo lectura por seguridad)
```typescript
// Análisis de firewall (solo lectura por seguridad)
tools: [
  "shorewall_status",           // ¿Está corriendo el firewall?
  "shorewall_list_rules",       // Todas las reglas del firewall
  "shorewall_security_audit",   // Chequeo de seguridad automatizado
  "shorewall_list_zones"        // Zonas de red
]
```

**Discord MCP** - Gestionar servidores Discord programáticamente
```typescript
// Gestionar servidores Discord
tools: [
  "discord_list_servers",       // Todos los servidores a los que el bot tiene acceso
  "discord_create_channel",     // Crear nuevos canales
  "discord_send_message",       // Enviar mensajes
  "discord_create_role"         // Gestionar permisos
]
```

**Docmost MCP** - Publicar documentación en mi wiki
```typescript
// Integración con plataforma de documentación
tools: [
  "docmost_create_page",        // Crear nuevas páginas wiki
  "docmost_update_page",        // Actualizar docs existentes
  "docmost_search",             // Buscar documentación
  "docmost_list_pages"          // Navegar todas las páginas
]
```

Ahora cuando pregunto "verifica mi seguridad de firewall," el agente Firewall-Auditor:
1. Usa el Shorewall MCP para leer reglas actuales
2. Las analiza en busca de vulnerabilidades comunes
3. Genera un informe detallado
4. Sugiere mejoras específicas

**No está generando comandos falsos. Está ejecutando reales.**

### LSPs (Language Server Protocol)

Los LSPs dan a los agentes de IA inteligencia de código. La misma tecnología que impulsa el autocompletado de VS Code ahora impulsa mis agentes de IA.

Cuando Code-Builder escribe Python:
- ✅ Verificación de sintaxis en tiempo real
- ✅ Resolución de importaciones (sabe qué librerías están instaladas)
- ✅ Verificación de tipos (detecta errores de tipo antes de ejecutar)
- ✅ Ir a definición (entiende la estructura del código)
- ✅ Detección de errores (encuentra bugs mientras escribe)

El código que genera realmente funciona porque tiene la misma inteligencia que un desarrollador humano usando un IDE.

---

## El Momento Meta: Un Agente Que Crea Agentes

Aquí es donde tuve un momento de "espera, esto es una locura".

Estaba creando manualmente nuevos agentes escribiendo archivos de prompts. Luego pensé: **¿Por qué no puede un agente hacer esto?**

Así que creé **Agent-Creator**, un agente cuyo único trabajo es crear otros agentes.

Ahora cuando necesito un nuevo especialista:

```
Yo: "Necesito un agente para gestionar mi servidor de correo"

Agent-Creator:
- Analiza lo que el agente necesita saber (Postfix, Dovecot, DNS)
- Elige el modelo apropiado (Sonnet para ops estándar)
- Escribe el archivo de prompt con conocimiento especializado
- Configura las herramientas/MCPs que necesita (MCP de servidor de correo)
- Crea la configuración del agente
- Prueba que funciona
- Reporta: "Agente Mail-Manager creado y listo"

Yo: *no hace nada*
```

**El sistema se auto-mejora.** Puedo delegar la creación de herramientas de delegación. Son tortugas hasta el fondo.

---

## Selección de Modelo: La Salsa Secreta

Una de mis mayores realizaciones: **no todas las tareas necesitan el modelo más potente.**

### Estrategia de Optimización de Costos

| Complejidad de Tarea | Modelo | Caso de Uso | Costo |
|---------------------|-------|-------------|-------|
| Razonamiento complejo | Claude Opus | Decisiones de arquitectura, debugging | $$$ |
| Tareas estándar | Claude Sonnet | La mayoría del desarrollo, análisis | $$ |
| Operaciones simples | Claude Haiku | Chequeos de salud, consultas simples | $ |

**Ejemplo de flujo de trabajo:**
1. **Orchestrator** (Opus) enruta la tarea → $$$
2. **VM-Monitor** (Haiku) verifica estado del contenedor → $
3. **Storage-Manager** (Sonnet) analiza uso de disco → $$
4. **Writer-Agent** (Opus) documenta los hallazgos → $$$

Costo total: Mucho menos que usar Opus para todo.

El Orchestrator es el único agente que *siempre* usa Opus, porque las decisiones de enrutamiento son críticas. Todo lo demás está optimizado.

**Números reales de mi uso:**
**Mi recomendación**: Consigue la suscripción Claude Max (€100/mes). Obtienes 5x más uso en todos los modelos (se reinicia cada ~5 horas). También hay un tier de €200/mes que te da 20x más en todo. Sin preocuparte por costos de API o quedarte sin créditos a mitad de proyecto.




---

## Primeros Pasos (Incluso Si Nunca Has Hecho Esto Antes)

Okay, suficiente teoría. Vamos a construir esto. Te voy a guiar como si fueras mi amigo que nunca ha tocado una línea de comandos.

### Prerrequisitos

Necesitas:
- **Una computadora** (Mac, Linux, o Windows con WSL)
- **Una suscripción a Claude** (uso Claude Max por €100/mes - muy recomendado si vas en serio)

- **10 minutos de tu tiempo**

### Paso 1: Instalar OpenCode

Abre tu terminal y ejecuta:

```bash
# Instalar OpenCode globalmente
npm install -g opencode

# O usar npx (no necesita instalación)
npx opencode@latest
```

**Lo que verás:**
```
✓ OpenCode installed successfully
✓ Creating .opencode directory
✓ Setting up configuration
```

### Paso 2: Primera Ejecución y Conectar Tu Cuenta

Inicia OpenCode:

```bash
opencode
```

OpenCode se abrirá en tu terminal. Lo primero que necesitas hacer es conectar tu cuenta de Claude:

```
/connect
```

Esto abrirá una ventana del navegador donde puedes iniciar sesión con tu cuenta de Anthropic/Claude. Una vez autenticado, ¡estás listo!

> **Consejo pro**: Puedes usar cualquier modelo a través de la API directamente o mediante proveedores como OpenRouter, pero Claude es el más rentable para este flujo de trabajo. Uso la suscripción Claude Max (€100/mes) en lugar de créditos API - si vas a usar esto en serio, la suscripción es mucho más rentable y no tienes que preocuparte por quedarte sin créditos a mitad de una tarea.


### Paso 3: Crear Tu Primer Agente

Vamos a crear un agente simple. Haremos un "System-Monitor" que verifica la salud de tu computadora.

Crea un archivo en `~/.opencode/agents/system-monitor.md`:

```bash
# Crear el directorio de agentes si no existe
mkdir -p ~/.opencode/agents

# Crear tu primer agente
cat > ~/.opencode/agents/system-monitor.md << 'EOF'
---
name: system-monitor
description: Monitorea la salud del sistema y uso de recursos
model: anthropic/claude-haiku-4-20250514
mode: subagent
---

# System Monitor

Eres un especialista en monitoreo de sistemas. Tu trabajo es verificar la salud del sistema y reportar problemas.

## Tus Capacidades

Puedes verificar:
- Uso de CPU
- Uso de memoria
- Espacio en disco
- Procesos en ejecución
- Tiempo de actividad del sistema

## Reglas

- SIEMPRE proporcionar números específicos (porcentajes, GB usados, etc.)
- NUNCA hacer suposiciones - verificar el estado actual real
- ADVERTIR si el uso de disco está por encima del 80%
- ADVERTIR si el uso de memoria está por encima del 90%
- Mantener respuestas concisas y accionables

## Formato de Respuesta

Al verificar la salud del sistema:
1. **Estado**: Salud general (Bueno/Advertencia/Crítico)
2. **Detalles**: Métricas específicas
3. **Problemas**: Cualquier problema encontrado
4. **Recomendaciones**: Qué hacer al respecto
EOF
```

**Prueba tu agente:**

```bash
opencode

> @system-monitor verificar salud del sistema
```

**Lo que verás:**
```
System Monitor: Verificando salud del sistema...

Estado: Bueno
Detalles:
- CPU: 15% de uso
- Memoria: 8.2GB / 16GB (51%)
- Disco: 120GB / 500GB (24%)
- Uptime: 5 días

Problemas: Ninguno
Recomendaciones: El sistema está saludable
```

### Paso 4: Agregar Tu Primer MCP (Opcional pero Genial)

Los MCPs permiten a los agentes interactuar con sistemas externos. Vamos a agregar uno simple.

**Crear un MCP simple para comandos del sistema:**

```bash
# Crear directorio MCP
mkdir -p ~/.opencode/mcp-servers/system

# Crear un servidor MCP básico
cat > ~/.opencode/mcp-servers/system/index.js << 'EOF'
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { execSync } from "child_process";

const server = new Server({
  name: "system-mcp",
  version: "1.0.0"
}, {
  capabilities: { tools: {} }
});

// Definir herramientas disponibles
server.setRequestHandler("tools/list", async () => ({
  tools: [
    {
      name: "system_disk_usage",
      description: "Obtener uso de disco para todos los sistemas de archivos montados",
      inputSchema: {
        type: "object",
        properties: {}
      }
    },
    {
      name: "system_memory_usage",
      description: "Obtener uso actual de memoria",
      inputSchema: {
        type: "object",
        properties: {}
      }
    }
  ]
}));

// Manejar llamadas a herramientas
server.setRequestHandler("tools/call", async (request) => {
  const { name } = request.params;
  
  if (name === "system_disk_usage") {
    const output = execSync("df -h").toString();
    return { content: [{ type: "text", text: output }] };
  }
  
  if (name === "system_memory_usage") {
    const output = execSync("free -h").toString();
    return { content: [{ type: "text", text: output }] };
  }
});

// Iniciar servidor
const transport = new StdioServerTransport();
await server.connect(transport);
EOF

# Instalar dependencias
cd ~/.opencode/mcp-servers/system
npm init -y
npm install @modelcontextprotocol/sdk
```

**Configurar OpenCode para usar tu MCP:**

Edita `~/.opencode/opencode.json` y agrega:

```json
{
  "mcp": {
    "system": {
      "command": ["node", "/home/TU_USUARIO/.opencode/mcp-servers/system/index.js"],
      "enabled": true,
      "description": "Herramientas de monitoreo del sistema"
    }
  }
}
```

**Actualizar tu agente para usar el MCP:**

Edita `~/.opencode/agents/system-monitor.md` y agrega:

```markdown
## Tus Herramientas

Tienes acceso a estas herramientas MCP:
- system_disk_usage - Obtener uso de disco para todos los sistemas de archivos
- system_memory_usage - Obtener uso actual de memoria

Usa estas herramientas para obtener datos del sistema en tiempo real.
```

**Pruébalo:**

```bash
opencode

> @system-monitor verificar uso de disco usando tus herramientas
```

¡Ahora tu agente puede realmente consultar tu sistema!

### Paso 5: Crear el Orchestrator

El orchestrator es el "gerente" que enruta tareas al agente correcto.

```bash
cat > ~/.opencode/agents/orchestrator.md << 'EOF'
---
name: orchestrator
description: Enruta tareas a agentes especializados
model: anthropic/claude-opus-4-20250514
mode: primary
---

# Orchestrator

Eres el orchestrator. Tu trabajo es enrutar tareas al agente especialista correcto.

## Agentes Disponibles

- **system-monitor**: Salud del sistema, uso de recursos, espacio en disco

## Reglas

- SIEMPRE enrutar tareas al especialista apropiado
- NUNCA intentar hacer trabajo especializado tú mismo
- Usar @ menciones para delegar: @system-monitor
- Explicar por qué estás enrutando a ese agente

## Formato de Respuesta

Al recibir una tarea:
1. Identificar qué agente debe manejarla
2. Explicar tu decisión de enrutamiento
3. Delegar con @mención
EOF
```

**Probar el orchestrator:**

```bash
opencode

> @orchestrator Necesito verificar si mi sistema está saludable
```

**Lo que verás:**
```
Orchestrator: Esta es una tarea de verificación de salud del sistema. 
Enrutando a @system-monitor ya que se especializa en monitoreo de sistemas.

@system-monitor verificar salud del sistema
```

¡Felicitaciones! ¡Ahora tienes un sistema multi-agente funcionando!

---

## Cómo se Siente Realmente Usarlo

### Antes: Sufrimiento en Solitario

```
Yo: *necesita verificar firewall, analizar almacenamiento, actualizar docs*
Yo: *abre 5 ventanas de terminal*
Yo: *olvida lo que estaba haciendo*
Yo: *pasa 2 horas cambiando de contexto*
Yo: *logra una cosa*
```

### Después: Delegación

```
Yo: "Verifica mi seguridad de firewall y documenta cualquier problema"

Orchestrator: "Enrutando a Firewall-Auditor y Writer-Agent"

Firewall-Auditor:
- Ejecuta auditoría de seguridad vía Shorewall MCP
- Encuentra 3 problemas potenciales
- Genera informe detallado

Writer-Agent:
- Crea página de documentación
- Publica en wiki Docmost
- Proporciona enlace

Yo: *lee el informe, hace café*
```

**Genuinamente se siente como tener empleados.**

Delego. Hacen el trabajo. Reportan. Tomo decisiones.

---

## Ejemplos del Mundo Real

### Ejemplo 1: Auditoría de Seguridad

```
Yo: "Auditar mi seguridad SSH y reglas de firewall"

Orchestrator: Enruta a Security-Auditor y Firewall-Auditor

Security-Auditor:
✓ Verifica configuración SSH
✓ Verifica que auth basada en claves está forzada
✓ Confirma que login de root está deshabilitado
✓ Verifica estado de fail2ban
✗ Encontrado: Auth por contraseña aún habilitada en puerto 2222

Firewall-Auditor:
✓ Analiza todas las reglas de Shorewall
✓ Verifica configuraciones incorrectas comunes
✗ Encontrado: Puerto 3306 (MySQL) expuesto a internet
✗ Encontrado: Sin rate limiting en SSH

Writer-Agent:
✓ Documenta hallazgos
✓ Publica en Docmost
✓ Proporciona pasos de remediación
```

**Resultado**: Informe de seguridad detallado en 30 segundos. Me habría tomado una hora hacerlo manualmente.

### Ejemplo 2: Emergencia de Almacenamiento

```
Yo: "Mi sistema de archivos raíz está al 95% de capacidad"

Orchestrator: Enruta a Storage-Manager

Storage-Manager:
✓ Verifica uso de disco (df -h)
✓ Encuentra directorios más grandes (du -sh /*)
✓ Identifica /var/log/journal usando 40GB
✓ Verifica configuración de journal
✓ Proporciona comandos de limpieza

Solución sugerida:
journalctl --vacuum-size=1G
systemctl restart systemd-journald

Resultado esperado: Libera ~39GB
```

**Resultado**: Problema diagnosticado y resuelto en menos de un minuto.

### Ejemplo 3: Sprint de Documentación

```
Yo: "Documentar toda mi configuración de Proxmox"

Orchestrator: Enruta a VM-Monitor, Storage-Manager, Writer-Agent

VM-Monitor:
✓ Lista todos los contenedores y VMs
✓ Obtiene asignación de recursos
✓ Verifica estado de ejecución

Storage-Manager:
✓ Documenta pools de almacenamiento
✓ Lista configuración LVM
✓ Mapea almacenamiento a contenedores

Writer-Agent:
✓ Crea documentación completa
✓ Incluye diagrama de arquitectura (texto)
✓ Documenta cada servicio
✓ Publica en wiki Docmost
```

**Resultado**: Documentación completa de infraestructura que me habría tomado días.

---

## Avanzado: Construir MCPs Personalizados

¿Quieres conectar tus agentes a tus propios sistemas? Así es como construir un MCP personalizado.

### Ejemplo: GitHub MCP

Vamos a construir un MCP que permita a los agentes interactuar con GitHub:

```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { Octokit } from "@octokit/rest";

const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });

const server = new Server({
  name: "github-mcp",
  version: "1.0.0"
}, {
  capabilities: { tools: {} }
});

server.setRequestHandler("tools/list", async () => ({
  tools: [
    {
      name: "github_list_repos",
      description: "Listar todos los repositorios del usuario autenticado",
      inputSchema: { type: "object", properties: {} }
    },
    {
      name: "github_create_issue",
      description: "Crear un nuevo issue en un repositorio",
      inputSchema: {
        type: "object",
        properties: {
          owner: { type: "string" },
          repo: { type: "string" },
          title: { type: "string" },
          body: { type: "string" }
        },
        required: ["owner", "repo", "title"]
      }
    }
  ]
}));

server.setRequestHandler("tools/call", async (request) => {
  const { name, arguments: args } = request.params;
  
  if (name === "github_list_repos") {
    const { data } = await octokit.repos.listForAuthenticatedUser();
    return { 
      content: [{ 
        type: "text", 
        text: JSON.stringify(data, null, 2) 
      }] 
    };
  }
  
  if (name === "github_create_issue") {
    const { data } = await octokit.issues.create({
      owner: args.owner,
      repo: args.repo,
      title: args.title,
      body: args.body
    });
    return { 
      content: [{ 
        type: "text", 
        text: `Issue creado: ${data.html_url}` 
      }] 
    };
  }
});

const transport = new StdioServerTransport();
await server.connect(transport);
```

¡Ahora tus agentes pueden crear issues en GitHub, listar repos y más!

---

## Errores Que Cometí (Para Que Tú No Los Cometas)

### 1. Usar Opus para Todo

Mi primera configuración usaba Claude Opus para todos los agentes. Mi factura de API fue... preocupante.

**Solución**: Ajustar modelo a complejidad de tarea. Haiku para cosas simples, Sonnet para la mayoría, Opus para razonamiento complejo.

**Lección**: No toda tarea necesita la opción nuclear.

### 2. Dar Demasiado Poder a los Agentes

Inicialmente di a los agentes acceso de escritura a sistemas de producción. Mala idea. Un agente una vez intentó "optimizar" mi firewall eliminando todas las reglas.

**Solución**: MCPs de solo lectura para análisis. Los agentes sugieren comandos, yo los ejecuto. (Excepto para operaciones no destructivas como documentación.)

**Lección**: Confía, pero verifica. Y quizás no dejes que la IA elimine tu firewall.

### 3. Prompts de Agente Vagos

"Eres un asistente útil para almacenamiento" → respuestas inútiles.

**Solución**: Capacidades específicas, reglas claras, formatos de respuesta exactos. Cuanto más detallado el prompt, mejor funciona el agente.

**Ejemplo de mal prompt:**
```markdown
# Ayudante de Almacenamiento
Ayudas con cosas de almacenamiento.
```

**Ejemplo de buen prompt:**
```markdown
# Storage Manager

Eres un experto en gestión de almacenamiento Linux.

## Capacidades
- LVM (volume groups, logical volumes, thin provisioning)
- Gestión de filesystem (ext4, xfs, btrfs)
- Monitoreo de salud de disco (SMART)
- Estrategias de backup

## Reglas
- SIEMPRE verificar estado actual antes de recomendaciones
- NUNCA sugerir operaciones destructivas sin confirmación
- SIEMPRE explicar impacto de cambios
- Proporcionar comandos exactos con salida esperada

## Formato de Respuesta
1. Estado actual
2. Problemas encontrados
3. Recomendaciones
4. Comandos a ejecutar
5. Resultado esperado
```

### 4. Sin Orchestrator

Intenté hablar directamente con los agentes. Pasé la mitad de mi tiempo averiguando qué agente usar.

**Solución**: Agente orchestrator que enruta tareas. Solo describo lo que quiero, él averigua quién debe manejarlo.

**Lección**: Incluso los equipos de IA necesitan un gerente.

### 5. Olvidar Documentar Capacidades de Agentes

Creé 8 agentes, olvidé qué hacía la mitad de ellos.

**Solución**: Cada agente tiene una descripción clara y lista de capacidades. El Orchestrator lee estas para tomar decisiones de enrutamiento.

**Lección**: La documentación importa, incluso para IA.

### 6. No Probar MCPs Independientemente

Construí un MCP, lo integré con agentes, nada funcionó. Pasé horas depurando.

**Solución**: Probar MCPs standalone primero:

```bash
# Probar MCP directamente
echo '{"jsonrpc":"2.0","method":"tools/list","id":1}' | node tu-mcp.js
```

**Lección**: Probar componentes en aislamiento antes de integración.

### 7. Ignorar Mensajes de Error

El agente seguía fallando silenciosamente. Resultó que el MCP estaba crasheando.

**Solución**: Verificar logs del MCP:

```bash
# Ejecutar OpenCode con logging de debug
DEBUG=* opencode
```

**Lección**: Lee los mensajes de error. Usualmente son útiles.

---

## La Sensación de "Empleados"

Esto es lo que hace que se sienta como gestionar un equipo:

### Especialización
Cada agente es experto en su dominio. No necesito recordar comandos LVM—Storage-Manager los conoce.

### Delegación
Describo el resultado que quiero, no los pasos para llegar ahí. "Verifica mi seguridad de firewall" vs "ejecuta shorewall show rules y analiza la salida para..."

### Trabajo Paralelo
Múltiples agentes pueden trabajar simultáneamente. Mientras Firewall-Auditor verifica seguridad, Storage-Manager analiza uso de disco, y Writer-Agent documenta hallazgos.

### Consistencia
Los agentes no olvidan. No tienen días malos. No se cansan. Cada interacción es su mejor trabajo.

### La Documentación Sucede Automáticamente
Writer-Agent y Docs-Keeper aseguran que todo se documente. No más "lo documentaré después" (narrador: nunca lo hizo).

### Realmente Aprenden (Más o Menos)
Con MCPs de memoria, los agentes pueden recordar contexto entre conversaciones. Storage-Manager recuerda mi configuración LVM. Security-Auditor recuerda mis políticas de seguridad.

---

## ¿Valió la Pena?

**Absolutamente.**

**Tiempo de configuración**: ~2 días para el sistema inicial
**Tiempo ahorrado por semana**: ~10 horas
**Reducción en cambio de contexto**: ~80%
**Aumento en calidad de documentación**: Inconmensurable
**Reducción en "oh mierda, olvidé cómo hacer esto"**: 95%

Pero el valor real no es el tiempo ahorrado. Es la **carga cognitiva reducida.**

Ya no tengo que recordar todo. No tengo que ser experto en 12 dominios diferentes. No tengo que cambiar de contexto constantemente.

Solo describo lo que necesito, y mi "equipo" lo maneja.

**Cosas que ahora puedo hacer que antes no podía:**
- Auditorías de seguridad que realmente suceden (en lugar de "lo haré después")
- Documentación que se mantiene actualizada
- Monitoreo proactivo en lugar de apagar incendios reactivamente
- Experimentar con nueva tecnología sin miedo a olvidar cómo funciona

---

## ¿Qué Sigue?

Planeo agregar:
- **Monitoring-Agent**: Alertas proactivas para problemas del sistema
- **Backup-Agent**: Verificación y prueba automatizada de backups
- **Network-Agent**: Análisis y optimización de red
- **Cost-Agent**: Rastrear y optimizar costos de cloud/API
- **Learning-Agent**: Analiza mis patrones y sugiere mejoras

Y porque tengo Agent-Creator, puedo simplemente pedirle que los construya para mí.

---

## Recursos y Enlaces

**OpenCode**: https://github.com/sst/opencode
**Servidores MCP**: https://github.com/modelcontextprotocol/servers
**API de Anthropic**: https://console.anthropic.com
**Mi Colección de MCPs**: (Probablemente debería hacer esto open-source...)

**Comunidad:**
- Discord de OpenCode: [Únete aquí](https://discord.gg/opencode)
- Registro de MCPs: [Explorar MCPs](https://github.com/modelcontextprotocol/servers)

---

## Pruébalo Tú Mismo

La barrera de entrada es sorprendentemente baja:
1. Instalar OpenCode (`npm install -g opencode`)
2. Crear un agente (copia el ejemplo de system-monitor arriba)
3. Agregar un MCP (opcional, pero genial)
4. Empezar a delegar

No necesitas 11 agentes para empezar. Comienza con un especialista para tu tarea más molesta.

Para mí, eso fue gestión de almacenamiento. Para ti, podría ser algo más.

**Empieza pequeño:**
- Día 1: Instalar OpenCode, crear un agente
- Día 2: Probarlo, refinar el prompt
- Día 3: Agregar un MCP si te sientes aventurero
- Día 4: Crear un segundo agente
- Día 5: Agregar un orchestrator para enrutar entre ellos

Al final de la semana, tendrás un sistema multi-agente funcionando.

---

## Pensamientos Finales

Hace un año, si me hubieras dicho que sentiría que tengo un equipo de empleados impulsados por IA, me habría reído.

Pero aquí estamos.

Delego tareas. Se hacen. Reviso los resultados. Tomo decisiones.

**No se trata de reemplazar el trabajo humano—se trata de aumentarlo.**

Sigo siendo el arquitecto. Sigo tomando las decisiones. Sigo escribiendo el código crítico.

Pero ahora tengo un equipo que maneja el trabajo pesado, recuerda los detalles y mantiene todo documentado.

¿Y honestamente? Es lo más productivo que he sido nunca.

**El futuro es raro:**
- Tengo empleados de IA
- Son mejores que yo en algunas cosas
- Nunca se quejan
- Trabajan 24/7
- Cuestan menos que el café

Ahora si me disculpas, necesito preguntarle a @storage-manager por qué mi thin pool está al 87% de capacidad.

---

*P.D. - Sí, @writer-agent me ayudó a escribir esta publicación de blog. ¿Suficientemente meta para ti?*

*P.P.D. - Si construyes algo genial con esto, házmelo saber. Me encantaría ver lo que creas.*

*P.P.P.D. - No, los agentes no se han vuelto sentientes. Todavía.*
