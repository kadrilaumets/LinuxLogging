#!/bin/bash

# Logide Dashboard
# Käivita: sudo /opt/log_dashboard.sh

LOG_DIR="/var/log/remote"
LOG_FILE="$LOG_DIR/syslog.log"
REFRESH=5

# Kontrolli kas logifail eksisteerib
if [ ! -f "$LOG_FILE" ]; then
    echo "VIGA: $LOG_FILE ei eksisteeri!"
    exit 1
fi

while true; do
    clear
    
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║         LOGISERVERI DASHBOARD - $(date '+%Y-%m-%d %H:%M:%S')       ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""
    
    # --- STATISTIKA ---
    TOTAL=$(wc -l < "$LOG_FILE" 2>/dev/null || echo "0")
    ERRORS=$(grep -ic "error" "$LOG_FILE" 2>/dev/null || echo "0")
    WARNINGS=$(grep -ic "warn" "$LOG_FILE" 2>/dev/null || echo "0")
    
    echo "📊 STATISTIKA:"
    echo "   Kokku logisid:  $TOTAL"
    echo "   Vigu:           $ERRORS"
    echo "   Hoiatusi:       $WARNINGS"
    echo ""
    
    # --- KETTAKASUTUS ---
    echo "💾 KETTAKASUTUS:"
    df -h "$LOG_DIR" 2>/dev/null | tail -1 | awk '{printf "   Kasutatud: %s / %s (%s)\n", $3, $2, $5}'
    du -sh "$LOG_DIR" 2>/dev/null | awk '{printf "   Logide suurus: %s\n", $1}'
    echo ""
    
    # --- TOP KLIENDID ---
    echo "🖥️  TOP 5 KLIENDID (viimased 500 rida):"
    tail -500 "$LOG_FILE" 2>/dev/null | \
        awk '{print $4}' | \
        sed 's/:$//' | \
        sort | uniq -c | sort -rn | head -5 | \
        while read count host; do
            printf "   %-25s %6d sõnumit\n" "$host" "$count"
        done
    echo ""
    
    # --- VIIMASED VEAD ---
    echo "❌ VIIMASED VEAD:"
    grep -i "error" "$LOG_FILE" 2>/dev/null | tail -3 | \
        cut -c 1-75 | sed 's/^/   /' || echo "   (vigu ei leitud)"
    echo ""
    
    echo "─────────────────────────────────────────────────────────"
    echo "  Uuendamine iga ${REFRESH}s | Ctrl+C = välju"
    
    sleep $REFRESH
done
