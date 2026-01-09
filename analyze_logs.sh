#!/bin/bash

# Logide analüüsija
# Käivita: sudo /opt/analyze_logs.sh

LOG_FILE="/var/log/remote/syslog.log"

if [ ! -f "$LOG_FILE" ]; then
    echo "VIGA: $LOG_FILE ei eksisteeri!"
    exit 1
fi

echo "═══════════════════════════════════════════════════"
echo "        LOGIDE ANALÜÜS - $(date '+%Y-%m-%d %H:%M')"
echo "═══════════════════════════════════════════════════"
echo ""

# Üldstatistika
echo "📈 ÜLDSTATISTIKA:"
echo "   Ridu kokku:    $(wc -l < "$LOG_FILE")"
echo "   Faili suurus:  $(du -h "$LOG_FILE" | cut -f1)"
echo ""

# Logitasemed
echo "📊 LOGITASEMED:"
echo "   ERROR:   $(grep -ic 'error' "$LOG_FILE")"
echo "   WARNING: $(grep -ic 'warn' "$LOG_FILE")"
echo "   INFO:    $(grep -ic 'info' "$LOG_FILE")"
echo ""

# Top 10 kliendid
echo "🖥️  TOP 10 KLIENDID:"
awk '{print $4}' "$LOG_FILE" | sed 's/:$//' | \
    sort | uniq -c | sort -rn | head -10 | \
    while read count host; do
        printf "   %-30s %8d\n" "$host" "$count"
    done
echo ""

# Logid tunni kaupa (täna)
echo "⏰ LOGID TUNNI KAUPA (täna):"
TODAY=$(date '+%b %d')
for hour in $(seq -w 0 23); do
    count=$(grep "^$TODAY $hour:" "$LOG_FILE" 2>/dev/null | wc -l)
    if [ "$count" -gt 0 ]; then
        bar=$(printf '%*s' $((count / 10)) '' | tr ' ' '█')
        printf "   %s:00  %6d  %s\n" "$hour" "$count" "$bar"
    fi
done
echo ""

# Viimased 5 viga
echo "❌ VIIMASED 5 VIGA:"
grep -i "error" "$LOG_FILE" | tail -5 | \
    while read line; do
        echo "   ${line:0:70}"
    done
echo ""

echo "═══════════════════════════════════════════════════"
