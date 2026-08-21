#!/usr/bin/env python3
import sys, struct, math
bars = int(sys.argv[1])
sens = max(1, int(sys.argv[2])) / 25.0
chunk = 1024
while True:
    b = sys.stdin.buffer.read(chunk * 2)
    if not b:
        break
    n = len(b) // 2
    samp = struct.unpack("<" + str(n) + "h", b[: n * 2])
    step = max(1, n // bars)
    vals = []
    for i in range(bars):
        sl = samp[i * step : (i + 1) * step]
        if not sl:
            vals.append(0.0)
            continue
        rms = math.sqrt(sum(x * x for x in sl) / len(sl)) / 32768.0
        vals.append(min(1.0, rms * sens))
    sys.stdout.write(" ".join("%.3f" % v for v in vals) + "\n")
    sys.stdout.flush()
