using TDAC
using TimerOutputs
TDAC.tdac("warmup.yaml")
TimerOutputs.enable_debug_timings(TDAC)
TDAC.tdac("input_weak_scaling.yaml")
