---
title: "Por qué construí mi sitio personal: Más que otro blog técnico"
date: 2025-12-10
draft: false
tags: ["meta", "blogging", "homelab", "self-hosting", "hugo", "documentación"]
categories: ["Meta", "Homelab"]
description: "Por qué construí mi propio blog desde cero, cómo está configurado en mi homelab y por qué bloguear es el mejor sistema de gestión del conocimiento que he encontrado."
---

# Por qué construí mi sitio personal: Más que otro blog técnico

**TL;DR**: Construí mi propio blog usando Hugo, corriendo en un contenedor LXC en Proxmox, con Flatnotes como compañero de escritura. No se trata solo de compartir conocimiento—se trata de construir una base de conocimiento personal que realmente se quede en el cerebro.

---

## El Problema: "Espera, ¿cómo arreglé eso otra vez?"

¿Conoces esa sensación cuando resuelves un problema complicado a las 2 de la mañana, te sientes como un genio, y luego tres meses después encuentras exactamente el mismo problema y no tienes absolutamente ni idea de lo que hiciste?

Sí, yo también. Demasiado a menudo.

He estado jugando con mi homelab por un tiempo—configurando contenedores, rompiendo cosas, arreglándolas, rompiéndolas de nuevo. Resolvía algo, pensaba "oh, lo recordaré", y luego olvidaba todo excepto que fue doloroso.

Intenté mantener notas en archivos de texto aleatorios. Intenté guardar soluciones en marcadores. Incluso intenté buscar en Google mis propias preguntas de Stack Overflow (sí, he hecho esto). Nada se quedó.

Entonces me di cuenta: **Necesito escribir sobre ello como si se lo estuviera explicando a alguien más.**

## Por qué bloguear es realmente un superpoder

Aquí está lo que he aprendido sobre escribir posts de blog versus solo "tomar notas":

### 1. **Escribir te enseña dos veces**

Cuando escribes un post de blog, no puedes simplemente volcar comandos en un archivo. Tienes que:
- Explicar *por qué* estás haciendo algo
- Proporcionar contexto para tu yo futuro (o cualquier otro)
- Pensar en la lógica paso a paso
- Llenar vacíos que no sabías que tenías

He perdido la cuenta de cuántas veces pensé que entendía algo, empecé a escribir sobre ello y me di cuenta "espera, ¿por qué funciona esto?" Ahí es cuando ocurre el verdadero aprendizaje.

### 2. **Tu yo futuro te lo agradecerá**

Dentro de seis meses cuando mi servidor de correo tenga problemas (seamos honestos, los tendrá), no recordaré el selector DKIM exacto que usé o dónde puse ese registro DNS. Pero tendré un post de blog titulado "Configurando Stalwart Mail Server" con cada detalle documentado.

**El yo pasado está ayudando al yo futuro.** Es como dejarte paquetes de cuidado a ti mismo en el futuro.

### 3. **Ayudas a otros (y eso se siente bien)**

La cantidad de veces que me ha salvado el post de blog aleatorio de alguien de 2015 es ridícula. Alguna persona que nunca conoceré resolvió exactamente el problema que tenía y lo documentó.

Ahora puedo devolver el favor. ¿Y honestamente? Se siente bastante bien saber que mi sesión de debugging de las 2 AM podría salvar la sesión de debugging de las 2 AM de alguien más.

### 4. **La responsabilidad mantiene las cosas limpias**

Cuando sabes que podrías escribir sobre algo públicamente, tiendes a hacerlo correctamente. No más arreglos "temporales" que se vuelven permanentes. No más "lo arreglaré después" (narrador: no lo arregló después).

Escribir sobre mi configuración me obliga a entender y documentar mi infraestructura correctamente.

---

## La configuración técnica: Cómo funciona realmente este blog

Bien, suficiente filosofía. Hablemos de cómo está realmente construido este blog.

### El Stack

- **Generador de sitios estáticos**: Hugo (rápido, simple, y sin vulnerabilidades PHP de qué preocuparse)
- **Tema**: Hugo Noir (limpio, minimalista, rápido)
- **Hosting**: Contenedor LXC (ID: 106) en mi servidor Proxmox
- **Proxy inverso**: Caddy (en LXC 104) manejando SSL y enrutamiento
- **Entorno de escritura**: Flatnotes (una app de toma de notas autoalojada)
- **Multiidioma**: Soporte incorporado para inglés, alemán y español

### Descripción general de la arquitectura

```
Internet
    ↓
Cloudflare (DNS + CDN)
    ↓
Caddy Proxy (LXC 104, 10.10.20.10)
    ↓
Hugo Server (LXC 106, 10.10.20.106:1313)
```

### ¿Por qué LXC en lugar de Docker?

Lo sé, lo sé—todos usan Docker para todo. Pero la cosa es: **los contenedores LXC son perfectos para servicios de larga duración como este.**

- Ligero (1GB RAM, 2 núcleos CPU, 8GB almacenamiento)
- Se siente como una VM real pero usa muchos menos recursos
- Fácil de hacer snapshot y backup en Proxmox
- Sin overhead de Docker para una aplicación única
- Todavía puedo usar Docker dentro si quiero (lo hago para Flatnotes)

### El servicio del servidor Hugo

Configuré Hugo para ejecutarse como un servicio systemd, así se inicia automáticamente al arrancar:

```bash
[Unit]
Description=Hugo Server for Engels Blog
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/var/www/engels-blog
ExecStart=/usr/local/bin/hugo server \
  --bind 0.0.0.0 \
  --port 1313 \
  --baseURL https://engelswtf.github.io \
  --appendPort=false \
  --environment production \
  --disableLiveReload
Restart=always

[Install]
WantedBy=multi-user.target
```

El servidor incorporado de Hugo es sorprendentemente robusto para uso en producción. Sirve archivos estáticos rápidamente, maneja el enrutamiento multiidioma y se reconstruye automáticamente cuando agrego nuevo contenido.

> 💡 **Consejo**: Solía pensar que necesitabas nginx o Apache frente a Hugo. No. Proxy inverso Caddy + servidor Hugo = perfectamente bien para un blog personal.

### Caddy: El mejor proxy inverso que no estás usando

Mi configuración de Caddy para el blog es hermosamente simple:

```caddy
www.engels.wtf {
    header {
        X-Content-Type-Options "nosniff"
        X-Frame-Options "SAMEORIGIN"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "strict-origin-when-cross-origin"
        -Server
    }
    
    reverse_proxy 10.10.20.106:1313
}

engels.wtf {
    redir https://engelswtf.github.io{uri} permanent
}
```

Eso es todo. Caddy maneja:
- ✅ Certificados SSL automáticos de Let's Encrypt
- ✅ Redirección HTTP a HTTPS
- ✅ Redirección de apex a www
- ✅ Cabeceras de seguridad
- ✅ Proxy inverso al contenedor Hugo

Sin configuraciones crípticas de nginx. Sin pasar 3 horas debuggeando certificados SSL. Simplemente funciona.

### El arma secreta: Flatnotes

Aquí es donde se pone interesante. Ejecuto [Flatnotes](https://github.com/dullage/flatnotes) en un contenedor Docker en el mismo LXC que Hugo:

```
notes.engels.wtf → Interfaz Flatnotes protegida por contraseña
                 → Escribe directamente en /var/www/engels-blog/content/blogs/
                 → Hugo se reconstruye automáticamente cuando detecta archivos nuevos
```

Esto significa que puedo:
1. Abrir notes.engels.wtf en cualquier dispositivo
2. Escribir un post de blog en Markdown
3. Guardarlo
4. Hugo detecta automáticamente el archivo nuevo y se reconstruye
5. El nuevo post está en vivo en segundos

**Sin commits de Git. Sin SSH al servidor. Sin pipelines de build.** Solo escribir y guardar.

> ⚠️ **Nota de seguridad**: Flatnotes está detrás de autenticación básica. ¡No expongas apps de toma de notas sin autenticación!

---

## Multiidioma: ¿Por qué no?

Una cosa que quería desde el principio era soporte multiidioma. Mi configuración soporta:
- 🇬🇧 Inglés (primario)
- 🇩🇪 Alemán (mi idioma nativo)
- 🇪🇸 Español (para práctica y mayor alcance)

Hugo hace esto sorprendentemente fácil. Cada post de blog puede tener variantes de idioma:
- `post.md` (Inglés)
- `post.de.md` (Alemán)
- `post.es.md` (Español)

El tema genera automáticamente selectores de idioma, y los usuarios obtienen la versión correcta basada en su idioma del navegador.

¿Escribo todo en los tres idiomas? No siempre. Pero tener la infraestructura en su lugar significa que puedo cuando tiene sentido.

---

## Lo que aprendí construyendo esto

### Errores que cometí

**1. Sobrecomplicar la infraestructura**

Inicialmente planeé todo un pipeline CI/CD con webhooks de Git y despliegues automatizados. Luego me di cuenta: esto es un blog personal, no una aplicación corporativa. File watching incorporado de Hugo + Flatnotes = perfectamente suficiente.

**2. Pasar demasiado tiempo en el diseño**

Desperdicié horas ajustando CSS antes de tener cualquier contenido. Resulta que a nadie le importa tu esquema de colores perfecto si no hay nada que leer. Contenido primero, pulido después.

**3. Olvidar configurar backups inicialmente**

Sí, ejecuté el blog por unas horas antes de darme cuenta "espera, probablemente debería hacer backup de esto." Ahora tengo snapshots de Proxmox programados diariamente.

### Lo que haría diferente

- **Empezar con un tema simple**: Hugo Noir es genial, pero pasé demasiado tiempo comparando temas. Elige algo limpio y sigue adelante.
- **Escribir más, publicar antes**: El perfeccionismo mata blogs. Hecho es mejor que perfecto.
- **Configurar analytics desde el día uno**: Agregué esto después y ahora me faltan datos tempranos (no es que hubiera mucho tráfico de todos modos).

---

## El blog como sistema de gestión del conocimiento

Aquí está la razón real por la que todo esto existe: **mi cerebro no es confiable.**

No puedo recordar la regla específica de Shorewall que necesito para permitir SMTP, pero puedo recordar "oh sí, escribí sobre esa configuración del servidor de correo."

No puedo recordar los comandos exactos de LVM para extender un volumen lógico, pero puedo buscar en mi propio blog "LVM."

Este blog no es solo para otras personas—**es mi cerebro externo.**

Cada vez que resuelvo un problema, escribo sobre ello. Cada vez que configuro algo nuevo, lo documento. Cada vez que cometo un error (lo cual es a menudo), registro qué salió mal y cómo lo arreglé.

Dentro de seis meses cuando inevitablemente necesite hacer algo que hice antes, no empezaré desde cero. Tendré documentación paso a paso escrita por alguien que realmente pasó por el proceso—mi yo pasado.

---

## ¿Qué sigue?

Ahora que la infraestructura está funcionando, comienza el trabajo real: escribir regularmente.

Posts próximos que estoy planeando:
- **Configurando Stalwart Mail Server** (porque acabo de hacer esto hoy y fue una aventura)
- **Ajuste de red de Proxmox** (arreglando ese problema de IRQ que hacía que mi servidor se retrasara)
- **Autoalojando n8n para automatización** (mi configuración de automatización de flujos de trabajo)
- **Construyendo un blog Hugo multiidioma** (meta, pero útil para otros)

## ¿Quieres construir el tuyo propio?

Toda la configuración es bastante sencilla. Si tienes un servidor Proxmox (o cualquier caja Linux), puedes replicar esto en una tarde:

1. Crear un contenedor LXC
2. Instalar Hugo
3. Elegir un tema
4. Configurar Caddy como proxy inverso
5. (Opcional) Agregar Flatnotes para edición fácil
6. Empezar a escribir

La parte más difícil no es la configuración técnica—es realmente sentarse y escribir. Pero ese es un problema que ninguna cantidad de infraestructura puede resolver.

---

## Pensamientos finales

Construir este blog tomó quizás 4 horas de trabajo real. La mayor parte fue ajustar configuraciones y configurar Flatnotes.

¿Pero el valor? Invaluable.

Cada post que escribo es una inversión en la cordura de mi yo futuro. Cada tutorial que documento es un problema menos que tendré que resolver dos veces. Cada error que registro es una lección que no tendré que reaprender.

Si estás jugando con homelabs, autoalojamiento o infraestructura, **empieza a documentar.** Tu yo futuro te lo agradecerá. Y quién sabe—tal vez ayudes a alguien más a resolver exactamente el problema en el que están atascados a las 2 AM.

Por eso existe `engels.wtf`. No solo como un blog, sino como una base de conocimiento viva que crece cada vez que aprendo algo nuevo.

Ahora si me disculpas, tengo unas 47 cosas más sobre las que probablemente debería escribir antes de olvidarlas.
