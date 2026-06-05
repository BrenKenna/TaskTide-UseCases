

import sys
import time

if len( sys.argv ) != 2:
    print("Error, must supply the amount of seconds to sleep")
    sys.exit(1)


sleepTime = float(sys.argv[1])
print(f"Sleeping for '{sleepTime}' seconds")
time.sleep(sleepTime)
print("Process complete")
sys.exit(0)