echo "===== CPU Info ====="
lscpu | grep -E 'Architecture|Socket|Core|Thread|CPU\(s\)'

echo "===== RAM Info ====="
free -h | awk '/^Mem:/ {print "Total RAM:", $2, "Used:", $3, "Free:", $4}'