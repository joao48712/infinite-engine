#!/bin/bash
# container-info.sh - Exibe informações reais do container Docker (memória alocada via cgroups)
# Uso: copie para dentro do container e execute: bash container-info.sh

echo ""
echo "  _   _      _ _        __        __         _     _ _ _"
echo " | \ | | ___| | | ___   \ \      / /__ _ __ | |__ (_) (_)_ __   __ _"
echo " |  \| |/ _ \ | |/ _ \   \ \ /\ / / _ \ '_ \| '_ \| | | | '_ \ / _' |"
echo " | |\  |  __/ | | (_) |   \ V  V /  __/ | | | |_) | | | | | | | (_| |"
echo " |_| \_|\___|_|_|\___/     \_/\_/ \___|_| |_|_.__/|_|_|_|_| |_|\__, |"
echo "                                                                 |___/"
echo ""
echo "  Sistema: $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d= -f2 | tr -d '\"' || echo 'Linux')"
echo "  Kernel:  $(uname -r)"

# Detecta cgroup v1 ou v2
if [ -f /sys/fs/cgroup/memory/memory.limit_in_bytes ]; then
  LIMIT=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes 2>/dev/null)
  USAGE=$(cat /sys/fs/cgroup/memory/memory.usage_in_bytes 2>/dev/null)
elif [ -f /sys/fs/cgroup/memory.max ]; then
  LIMIT=$(cat /sys/fs/cgroup/memory.max 2>/dev/null)
  USAGE=$(cat /sys/fs/cgroup/memory.current 2>/dev/null)
else
  LIMIT=""
  USAGE=""
fi

if [ -n "$LIMIT" ] && [ "$LIMIT" != "max" ] && [ "$LIMIT" != "" ]; then
  LIMIT_MB=$((LIMIT / 1024 / 1024))
  echo "  RAM do container: ${LIMIT_MB} MB (limite alocado)"
else
  echo "  RAM do host:      $(free -m 2>/dev/null | awk '/Mem:/ {print $2 " MB"}' || echo 'indisponível') (kernel do host)"
  echo "  Aviso: container compartilha kernel do host. Use cgroups para ver o limite real."
fi

if [ -n "$USAGE" ]; then
  USAGE_MB=$((USAGE / 1024 / 1024))
  echo "  RAM em uso:       ${USAGE_MB} MB"
fi

echo "  CPU do host:      $(nproc) nucleos"
echo ""
echo "  Para ver a memoria real alocada ao container, use:"
echo "  docker stats <container_id>"
echo ""
