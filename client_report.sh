#!/bin/bash

# Klientide raport
# Käivita: sudo /opt/client_report.sh [kliendi_nimi]

LOG_FILE="/var/log/remote/syslog.log"

if [ ! -f "$LOG_FILE" ]; then
    echo "VIGA: $LOG_FILE ei eksisteeri!"
    exit 1
fi

# Kui anti kliendi nimi, näita ainult selle kliendi logisid
if [ -n "$1" ]; then
    CLIENT="$1"
    echo "═══════════════════════════════════════════════════"
    echo "        KLIENDI RAPORT: $CLIENT"
    echo "═══════════════════════════════════════════════════"
    echo ""
    
    COUNT=$(grep " $CLIENT " "$LOG_FILE" | wc -l)
    ERRORS=$(grep " $CLIENT " "$LOG_FILE" | grep -ic "error")
    
    echo "📊 STATISTIKA:"
    echo "   Logisid kokku: $COUNT"
    echo "   Vigu:          $ERRORS"
    echo ""
    
    echo "📝 VIIMASED 10 LOGI:"
    grep " $CLIENT " "$LOG_FILE" | tail -10 | \
        while read line; do
            echo "   ${line:0:70}"
        done
    
    exit 0
fi

# Muidu näita kõiki kliente
echo "═══════════════════════════════════════════════════"
echo "        KÕIK KLIENDID - $(date '+%Y-%m-%d %H:%M')"
echo "═══════════════════════════════════════════════════"
echo ""

echo "🖥️  KLIENDID:"
printf "   %-30s %10s %10s\n" "KLIENT" "LOGID" "VEAD"
echo "   ─────────────────────────────────────────────────"

awk '{print $4}' "$LOG_FILE" | sed 's/:$//' | sort -u | \
    while read client; do
        total=$(grep " $client " "$LOG_FILE" | wc -l)
        errors=$(grep " $client " "$LOG_FILE" | grep -ic "error" || echo "0")
        printf "   %-30s %10d %10d\n" "$client" "$total" "$errors"
    done

echo ""
echo "   Kokku kliente: $(awk '{print $4}' "$LOG_FILE" | sed 's/:$//' | sort -u | wc -l)"
echo ""
