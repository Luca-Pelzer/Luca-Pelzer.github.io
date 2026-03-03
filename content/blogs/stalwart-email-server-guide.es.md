---
title: "Construyendo Mi Propio Servidor de Email con Stalwart: Un Viaje a 10/10 (Excepto Microsoft)"
date: 2025-12-11
draft: false
tags: ["email", "stalwart", "self-hosting", "proxmox", "lxc", "dns", "smtp", "homelab"]
categories: ["Self-Hosting", "Homelab", "Tutorials"]
description: "Una guía completa para configurar un servidor de correo auto-alojado con Stalwart Mail Server, webmail Snappymail y todos los registros DNS necesarios. Más la saga continua de Microsoft bloqueando mi servidor perfectamente configurado."
---

# Construyendo Mi Propio Servidor de Email con Stalwart: Un Viaje a 10/10 (Excepto Microsoft)

**Resumen**: Pasé mucho tiempo configurando mi propio servidor de correo usando Stalwart en un contenedor LXC en Proxmox. Obtuve una puntuación perfecta de 10/10 en mail-tester.com, todos los proveedores principales aceptan mis correos... excepto Microsoft, que decidió que mi IP de Hetzner es culpable por asociación.

---

## ¿Por Qué Ejecutar Tu Propio Servidor de Email en 2025?

Empecemos con la verdad: ejecutar tu propio servidor de correo en 2025 se considera ampliamente una mala idea. Gmail y Outlook son gratuitos, confiables y "simplemente funcionan."

¿Por qué lo hice de todos modos?

1. **Aprender** - Quería entender la infraestructura de correo desde cero
2. **Control** - Mis correos, mi servidor, mis reglas
3. **Experiencia Profesional** - Los servidores de correo están en todas partes en entornos empresariales
4. **Porque Puedo** - Tengo un homelab Proxmox y un dominio

> ⚠️ **Chequeo de Realidad**: Si solo quieres correo que funcione, usa Fastmail, Migadu o ProtonMail.

## Requisitos Previos

### Hardware
- Servidor con IP pública estática (Hetzner Dedicated Server con Proxmox VE)
- Al menos 1GB de RAM (asigné 2GB)
- Almacenamiento para correos (32GB para empezar)

### Software/Servicios
- **Nombre de dominio** con control DNS
- Capacidad de **DNS Inverso**
- Capacidad de **LXC o VM**
- **Conocimientos básicos de Linux**

---

## Parte 1: Configurando el Contenedor LXC

```bash
VMID: 107
Hostname: mail.engels.wtf
Template: Debian 12 (bookworm)
Núcleos: 2
RAM: 2048 MB
Almacenamiento: 32 GB
Red: 10.10.10.107/24 (interna)
```

### Instalando Stalwart

```bash
apt update && apt upgrade -y
curl -sSL https://get.stalw.art | sh
```

> 💡 **Importante**: Stalwart almacena la mayoría de la configuración en su base de datos, no en config.toml.

---

## Parte 2: Configuración del Firewall (Shorewall)

```bash
DNAT    net     loc:10.10.10.107:25     tcp     25      -       49.12.126.61
DNAT    net     loc:10.10.10.107:587    tcp     587     -       49.12.126.61
DNAT    net     loc:10.10.10.107:465    tcp     465     -       49.12.126.61
DNAT    net     loc:10.10.10.107:993    tcp     993     -       49.12.126.61
```

---

## Parte 3: La Configuración DNS

| Tipo | Nombre | Valor |
|------|--------|-------|
| A | mail | 49.12.126.61 |
| MX | @ | 10 mail.engels.wtf |
| TXT | @ | v=spf1 mx a:mail.engels.wtf -all |
| TXT | _dmarc | v=DMARC1; p=reject; rua=mailto:postmaster@engels.wtf |
| PTR | 49.12.126.61 | mail.engels.wtf |

> ⚠️ **Importante**: ¡Crea una cuenta postmaster@engels.wtf!

---

## Parte 4: Agregando Webmail (Snappymail)

```bash
apt install nginx php8.2-fpm php8.2-curl php8.2-xml php8.2-zip -y
```

> ⚠️ **Problema Crítico**: En la config de dominio de Snappymail, "type": 1 debe ser un INTEGER, ¡no un string "1"!

---

## Parte 5: Pruebas & Victoria (Casi)

### Resultado Mail-Tester: 10/10 🎉

- ✅ Gmail - Entregado
- ✅ ProtonMail - Entregado
- ❌ Outlook.com/Hotmail - **RECHAZADO**

---

## Parte 6: La Saga de Microsoft

```
550 5.7.1 Service unavailable; Client host [49.12.126.61] blocked using S3140
```

Microsoft bloquea rangos IP completos de Hetzner de manera proactiva.

### Estado Actual
- Gmail, ProtonMail: ✅ Funcionando
- Microsoft: ❌ Todavía bloqueado

---

## Parte 7: Errores Que Cometí

1. **Pensar que config.toml era todo** - Stalwart usa una base de datos
2. **Error de tipo JSON de Snappymail** - Integer vs string me costó una hora
3. **Olvidar postmaster@** - Requerido por RFC
4. **Esperar que Microsoft fuera razonable** - No esperes lógica

---

## Conclusión: ¿Valió la Pena?

### Lo Bueno ✅
- Puntuación 10/10 en mail-tester
- Control total
- Aprendizaje profundo
- Funciona con 95% de proveedores

### Lo Malo ❌
- Microsoft me bloquea
- Responsabilidad de mantenimiento
- Complejidad

**¿Lo haría otra vez?** Sí, pero solo porque disfruto el trasteo.

---

## Recursos

- [Documentación de Stalwart](https://stalw.art/docs)
- [Snappymail](https://snappymail.eu/)
- [Mail-tester](https://mail-tester.com)
- [MXToolbox](https://mxtoolbox.com)

---

¿Preguntas? Contáctame en luca@engels.wtf (sí, funciona... mayormente).

**Actualización 2025-12-11**: Todavía bloqueado por Microsoft. La saga continúa.
