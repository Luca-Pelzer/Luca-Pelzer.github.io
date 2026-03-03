---
title: "Construyendo LearnTogether: Porque Estudiar Solo es Aburrido"
date: 2025-12-16
draft: false
tags: ["nextjs", "typescript", "socket.io", "multiplayer", "educacion", "proyecto", "preparacion-examenes"]
categories: ["Proyectos", "Desarrollo"]
description: "Cómo construí una plataforma de aprendizaje multijugador en tiempo real para la preparación de exámenes de TI alemanes, con duelos, carreras y demasiadas tarjetas."
---

# Construyendo LearnTogether: Porque Estudiar Solo es Aburrido

**TL;DR**: Me estoy preparando para el examen de formación profesional de TI alemán (Fachinformatiker IHK), me aburrí de los PDFs y construí una app de aprendizaje multijugador. Tiene tarjetas, quizzes, duelos, carreras y un simulador de examen realista. Procrastinación productiva en su máxima expresión. Pruébalo en [learn.engels.wtf](https://learn.engels.wtf).

---

## El Problema: Muerte por PDF

¿Saben qué es increíblemente aburrido? Leer el mismo PDF por 47ª vez para un examen.

Actualmente me estoy preparando para el examen de formación profesional de TI alemán (Fachinformatiker für Systemintegration), y déjenme decirles—los materiales de estudio oficiales son tan emocionantes como ver secar la pintura. En una pared beige. En una habitación sin ventanas.

Intenté:
- Leer PDFs (me dormí)
- Hacer tarjetas de papel (las perdí)
- Usar Anki (muy feo, peleen conmigo)
- Estudiar con amigos (terminamos hablando de todo menos del examen)

Entonces tuve una idea: **¿Y si estudiar fuera realmente... divertido?**

¿Y si pudiera competir con amigos en lugar de sufrir solo?

> **Consejo de productividad**: Si estás procrastinando en lugar de estudiar, simplemente construye una plataforma de aprendizaje completa. Eso cuenta como estudiar, ¿verdad? ¿Verdad?

---

## Lo Que Construí

**LearnTogether** es una app de aprendizaje multijugador full-stack con 5 modos de juego:

### 🃏 Tarjetas (Solo)
Tarjetas clásicas para voltear. Clic para revelar, marcar como "Lo sé" o "Necesito practicar". La app recuerda qué tarjetas te cuestan.

### ❓ Quiz (Solo)
Preguntas de opción múltiple con feedback inmediato. ¿Te equivocaste? Aquí está la explicación. ¿Acertaste? Golpe de dopamina.

### ⚔️ Duelo (Multijugador, 2-4 jugadores)
Aquí se pone interesante. Todos ven la misma pregunta, tienen 20 segundos para responder. Puntos por respuestas correctas, bonus por velocidad. Por turnos para que todos participen—no hay donde esconderse.

### 🏁 Carrera (Multijugador, 2-4 jugadores)
La primera respuesta correcta gana la ronda. Pero ojo: **si respondes mal, quedas bloqueado para esa pregunta.** Alto riesgo, alta recompensa. Amistades han sido puestas a prueba.

### 📝 Modo Examen (Solo)
La joya de la corona. Una simulación realista del examen IHK con:
- 7 tipos diferentes de preguntas (opción múltiple, emparejamiento, ordenar, completar, cálculos...)
- Temporizador de 90 minutos (como en el examen real)
- Sistema de calificación alemán (escala 1-6, donde 1 es lo mejor)
- Desglose detallado de resultados

Probablemente pasé más tiempo construyendo esto que estudiando. Sin arrepentimientos.

---

## El Stack Tecnológico

- **Next.js 14** con App Router
- **TypeScript** (porque prefiero mis errores en tiempo de compilación, no a las 2 AM)
- **Tailwind CSS** para estilos (modo oscuro por defecto, obviamente)
- **Socket.io** para multijugador en tiempo real
- **PM2** para gestión de procesos
- **Caddy** como reverse proxy

### ¿Por qué Socket.io?

Para que el multijugador se sienta fluido, necesitas comunicación bidireccional en tiempo real. Cuando el Jugador A responde, el Jugador B necesita verlo *instantáneamente*. HTTP polling se sentiría lento.

Socket.io maneja:
- Sesiones de juego basadas en salas (cada juego tiene su propia sala)
- Actualizaciones por eventos (respuesta enviada → broadcast a todos los jugadores)
- Reconexión automática (porque el WiFi es poco confiable)
- Fallback elegante a long-polling si WebSockets falla

¡El servidor es la fuente de verdad para el estado del juego. No se puede hacer trampa inspeccionando el cliente!

---

## Desafíos Interesantes que Resolví

### 1. Progreso Sincronizado con el Servidor

Quería que el progreso persistiera entre dispositivos. Iniciar sesión en el teléfono, continuar en la laptop.

Solución: Guardar el progreso en archivos JSON en el servidor, indexados por nombre de jugador.

```typescript
// Simple pero efectivo
const progressPath = path.join(DATA_DIR, `${playerName}.json`);
await fs.writeFile(progressPath, JSON.stringify(progress, null, 2));
```

No se necesita base de datos a esta escala. Solo archivos. A veces lo simple es mejor.

### 2. Seguimiento de Tarjetas Difíciles

La app rastrea las tarjetas que marcas como "Necesito practicar" y ofrece un modo de repaso dedicado. Es básicamente repetición espaciada lite—enfócate en lo que no sabes.

Tengo más "tarjetas difíciles" de las que me gustaría admitir.

### 3. Gestión de Estado Multijugador

Gestionar el estado del juego entre múltiples clientes es complicado. Las condiciones de carrera son reales cuando 4 personas responden simultáneamente.

Solución: Centralizar todo en el servidor.

```typescript
socket.on('answer', ({ answer }) => {
  const game = games.get(roomId);
  game.answers.set(socket.id, answer);
  
  // Solo proceder cuando todos hayan respondido
  if (game.answers.size === game.players.length) {
    const results = calculateScores(game);
    io.to(roomId).emit('roundResult', results);
  }
});
```

El servidor espera todas las respuestas, calcula puntuaciones, luego transmite los resultados. No es posible manipular puntuaciones del lado del cliente.

### 4. Siete Tipos de Preguntas para el Modo Examen

El examen IHK real tiene varios formatos de preguntas. Implementé:

| Tipo | Entrada | Puntuación |
|------|---------|------------|
| Opción Múltiple | Radio buttons | Todo o nada |
| Selección Múltiple | Checkboxes | Crédito parcial |
| Completar | Entrada de texto | Coincidencia difusa |
| Emparejamiento | Arrastrar y soltar pares | Por par |
| Ordenar | Arrastrar para reordenar | Coincidencia de secuencia |
| Cálculo | Entrada numérica | Basado en tolerancia |
| Texto Abierto | Textarea | Coincidencia de palabras clave |

Cada tipo tiene su propio componente React y lógica de puntuación. Los de emparejamiento y ordenar con drag-and-drop fueron particularmente divertidos de construir.

---

## Contenido: La Parte Real del Aprendizaje

Creé contenido para 3 temas relevantes para mi examen:

| Tema | Tarjetas | Quiz | Examen |
|------|----------|------|--------|
| 💾 Sistemas de Almacenamiento y Backup | 35 | 35 | 20 |
| ☁️ Cloud Computing | 32 | 24 | - |
| 🐳 Virtualización y Contenedores | 40 | 22 | - |

Eso son **107 tarjetas**, **81 preguntas de quiz** y **20 preguntas de examen** con explicaciones detalladas.

Escribir todo este contenido fue honestamente la parte más laboriosa. Pero oye, escribir explicaciones de por qué RAID 5 necesita al menos 3 discos definitivamente me ayudó a entenderlo mejor.

---

## Despliegue

La app corre en un contenedor LXC en mi homelab Proxmox:

```bash
# Construir la app Next.js
npm run build

# Iniciar con PM2 para gestión de procesos
pm2 start ecosystem.config.js

# Caddy maneja HTTPS en el host
# learn.engels.wtf → reverse proxy al contenedor
```

Ha estado corriendo estable por días. PM2 lo reinicia automáticamente si se cae (no lo ha hecho).

---

## Errores que Cometí (Para que No los Cometas)

### 1. Olvidé Reiniciar Puntuaciones en Revancha
Primera versión: Inicias un nuevo duelo, y tenías tu puntuación del juego anterior. Ups.

### 2. Mezcla del Lado del Cliente
Inicialmente mezclaba las preguntas en el cliente. Problema: En multijugador, cada uno tenía un orden diferente. Ahora el servidor mezcla una vez y envía el mismo orden a todos.

### 3. Progreso Solo se Guardaba al Completar
Los usuarios hacían 30 tarjetas, cerraban la pestaña, perdían todo. Ahora se guarda después de cada tarjeta/pregunta.

### 4. Sin Estados de Carga
Las conexiones Socket.io toman un momento. Sin estados de carga, los usuarios veían una pantalla en blanco y pensaban que estaba roto.

### 5. URLs de Localhost Hardcodeadas
Funcionaba genial en mi máquina. No funcionaba para nada en producción. Clásico.

---

## Lo que Aprendí

1. **Socket.io es poderoso pero necesita gestión de estado cuidadosa** — Las condiciones de carrera son reales cuando múltiples clientes interactúan simultáneamente.

2. **TypeScript ahorra tiempo de debugging** — Especialmente con objetos de estado de juego complejos. El compilador atrapa tantos errores.

3. **Los guardados incrementales son importantes** — No esperes hasta que el usuario termine para guardar. Guarda después de cada acción.

4. **Modo oscuro primero** — Estamos en 2024. Modo oscuro por defecto. Los ojos de tus usuarios te lo agradecerán.

5. **El multijugador es adictivo** — Mis amigos y yo hemos estado duelando mucho más de lo que deberíamos. ¿Es esto estudiar? Técnicamente sí.

---

## ¿Valió la Pena?

**Absolutamente.**

¿Pasé más tiempo construyendo esto de lo que habría pasado estudiando normalmente? Probablemente.

Pero ahora tengo:
- Una herramienta que realmente *quiero* usar
- Mejor comprensión del material (de escribir todas esas explicaciones)
- Una forma divertida de estudiar con amigos
- Otro proyecto para mi portafolio
- Este post de blog

¿Y honestamente? Los duelos son genuinamente divertidos. Nada te motiva más a aprender que la amenaza de perder contra tus amigos.

---

## Pruébalo

La app está en vivo en **[learn.engels.wtf](https://learn.engels.wtf)**

Solo ingresa un nombre y empieza a aprender. No se necesita cuenta, el progreso se guarda automáticamente.

Código fuente: [github.com/engelswtf/learn-together](https://github.com/engelswtf/learn-together)

---

*Ahora si me disculpan, tengo un examen para el que estudiar. O tal vez primero agregue una función más...*
