---
title: "Cuando Tu Servidor Hace Lag Solo Cuando No Lo Miras: Arreglando el Desbalance de IRQ"
date: 2025-12-11
draft: false
tags: ["proxmox", "redes", "ajuste-rendimiento", "depuración", "linux", "balance-irq", "homelab"]
categories: ["Homelab", "Rendimiento", "Tutoriales"]
description: "¿Lag de red misterioso que desaparecía al iniciar monitoreo? Era desbalance de IRQ - todas las interrupciones de red en un núcleo de CPU. Aquí está cómo diagnosticarlo y arreglarlo."
---

# Cuando Tu Servidor Hace Lag Solo Cuando No Lo Miras: Arreglando el Desbalance de IRQ

**TL;DR**: Mi servidor Proxmox tenía lag de red misterioso que desaparecía en el momento en que abría `htop` para investigar. Resultó que todas las interrupciones de red estaban siendo manejadas por un solo núcleo de CPU. Después de habilitar `irqbalance`, ajustar RPS y modificar los buffers de red, el lag desapareció para siempre. Aquí te muestro cómo diagnosticar y arreglar el desbalance de IRQ en tu propio servidor.

---

## El Bug del Efecto Observador

¿Conoces esa sensación cuando tu auto hace un ruido raro durante semanas, pero en el momento en que lo llevas al mecánico, funciona perfectamente? Así estaba mi servidor Proxmox el mes pasado.

**Los síntomas:**
- Picos aleatorios de lag de red (saltos de ping de 200-500ms)
- Servicios web de contenedores ocasionalmente con timeout
- Sesiones SSH congelándose aleatoriamente durante 2-3 segundos
- **Lo mejor:** En el momento en que entraba por SSH y ejecutaba `htop` o abría Netdata, todo funcionaba suavemente

> 💡 **Consejo**: Esto no es magia. Cuando ejecutas herramientas de monitoreo, generan procesos en diferentes núcleos de CPU, lo que temporalmente cambia la carga de trabajo y le da al núcleo sobrecargado un momento para ponerse al día.

## Prerequisitos

- Un servidor Linux (yo uso Proxmox, pero esto aplica a cualquier sistema basado en Debian/Ubuntu)
- Acceso root
- Familiaridad básica con la línea de comandos
- Unos 30 minutos para diagnósticos y arreglos

---

## Paso 1: Verificación de Seguridad Primero

Cuando aparecen problemas de rendimiento raros, mi primer pensamiento siempre es: **"¿Alguien se metió?"**

```bash
# Buscar procesos sospechosos
ps aux | grep -iE 'xmr|crypto|mine' 

# Buscar claves SSH no autorizadas
cat ~/.ssh/authorized_keys

# Verificar rootkits
apt install -y chkrootkit rkhunter
chkrootkit
rkhunter --check --skip-keypress

# Revisar conexiones de red activas
netstat -tulpn | grep ESTABLISHED
```

Todo salió limpio. Sin mineros de crypto, sin procesos sospechosos.

> ⚠️ **Advertencia**: Nunca omitas este paso. Los problemas de rendimiento pueden ser síntomas de compromiso.

---

## Paso 2: Descubriendo el Desbalance de IRQ

### ¿Qué son los IRQs?

**IRQ (Interrupt Request)** es cómo los dispositivos de hardware (como tu tarjeta de red) obtienen la atención de la CPU. Cuando llega un paquete de red, la NIC dice "¡Hey CPU, tengo algo para ti!" vía una interrupción.

```bash
# Ver distribución de interrupciones en tiempo real
watch -n 2 'cat /proc/interrupts | grep -E "CPU|eth0|eno1|enp"'
```

> 💡 **Consejo**: Reemplaza `eth0` o `eno1` con el nombre real de tu interfaz de red. Encuéntralo con `ip link show`.

Esto es lo que vi:

```
           CPU0   CPU1   CPU2   CPU3   CPU4   CPU5   ...
eth0-TxRx  3301245    0      0      0      0      0   ...
```

**Auch.** Todas las 3.3 millones de interrupciones solo en CPU0.

### Verificando softirqs

```bash
watch -n 2 'cat /proc/softirqs | grep -E "CPU|NET_RX"'
```

CPU0 estaba manejando **10x más** softirqs de recepción que otros núcleos. Esta era la pistola humeante.

---

## Paso 3: El Arreglo (Múltiples Capas)

### Capa 1: Instalar irqbalance

```bash
apt install -y irqbalance
systemctl enable --now irqbalance
systemctl status irqbalance
```

### Capa 2: Habilitar RPS (Receive Packet Steering)

```bash
# Encontrar el nombre de tu interfaz
ip link show

# Habilitar RPS para todas las CPUs (ajusta el valor hex según tu cuenta de CPUs)
# fff = 12 CPUs en hex, f = 4 CPUs, ff = 8 CPUs, ffff = 16 CPUs
echo "fff" > /sys/class/net/eth0/queues/rx-0/rps_cpus
```

**Cómo calcular tu máscara RPS:**
- Cuenta tus núcleos de CPU: `nproc`
- Convierte a hex: 4 CPUs = `f`, 8 = `ff`, 12 = `fff`, 16 = `ffff`

### Capa 3: Aumentar Buffers de Anillo de NIC

```bash
# Verificar tamaño actual
ethtool -g eth0

# Aumentar al máximo
ethtool -G eth0 rx 4096 tx 4096
```

### Capa 4: Ajustar Stack de Red (sysctl)

Crea `/etc/sysctl.d/99-network-tuning.conf`:

```bash
# Aumentar tamaños de buffer de socket (128MB)
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728

# Auto-ajuste de buffer TCP
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864

# Aumentar cola de backlog de dispositivo de red
net.core.netdev_max_backlog = 5000

# Aumentar presupuesto de procesamiento de softirq
net.core.netdev_budget = 600
```

Aplicar:

```bash
sysctl -p /etc/sysctl.d/99-network-tuning.conf
```

---

## Paso 4: Hacerlo Persistente

Crea `/etc/systemd/system/network-tuning.service`:

```ini
[Unit]
Description=Network Performance Tuning
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
# Reemplaza eth0 con el nombre de tu interfaz y fff con tu máscara de CPU
ExecStart=/bin/bash -c 'echo "fff" > /sys/class/net/eth0/queues/rx-0/rps_cpus'
ExecStart=/usr/sbin/ethtool -G eth0 rx 4096 tx 4096

[Install]
WantedBy=multi-user.target
```

Habilitarlo:

```bash
systemctl daemon-reload
systemctl enable network-tuning.service
systemctl start network-tuning.service
```

---

## Paso 5: Verificar el Arreglo

```bash
# Monitorear distribución de interrupciones
watch -n 2 'cat /proc/interrupts | grep -E "CPU|eth0"'

# Verificar drops de paquetes
netstat -s | grep -iE 'drop|prune|collapse'

# Ver distribución de softirq
watch -n 2 'cat /proc/softirqs | grep -E "CPU|NET_RX"'
```

---

## Errores que Cometí

1. **No verifiqué seguridad primero**: Siempre verifica seguridad primero.
2. **Usé máscara RPS incorrecta**: ¡Verifica con `nproc`!
3. **Olvidé persistir configuraciones**: Siempre crea el servicio systemd.
4. **No monitorée antes/después**: Siempre documenta tu estado "antes".

---

## Lo que Aprendí

- **irqbalance debería ser estándar** en cualquier servidor manejando tráfico real
- **El "efecto observador" no es paranormal** - es el planificador bajo carga
- **El ajuste de red es una pila** - IRQs de hardware, RPS, buffers, sysctl trabajando juntos
- **Las NICs modernas necesitan configuraciones modernas** - 256 paquetes de buffer es muy pequeño para gigabit

---

## Rollback (Si es Necesario)

```bash
systemctl stop network-tuning.service
systemctl disable network-tuning.service
ethtool -G eth0 rx 256 tx 256
rm /etc/sysctl.d/99-network-tuning.conf
sysctl -p
systemctl stop irqbalance
systemctl disable irqbalance
reboot
```

---

## Recursos

- [Linux Kernel Documentation: Scaling](https://www.kernel.org/doc/Documentation/networking/scaling.txt)
- [irqbalance en GitHub](https://github.com/Irqbalance/irqbalance)

---

*Actualización 2025-12-11: Publicación inicial*
