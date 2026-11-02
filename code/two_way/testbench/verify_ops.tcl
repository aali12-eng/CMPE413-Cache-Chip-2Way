# Show and check the clocks of every chip_test request (read miss, write hit, read hit, write miss).
#
#   From the shell:  ./run_two_way.sh verify            (prints the table, log in testbench/verify.log)
#   In SimVision:    reset                              (in the Console: back to 0 ns)
#                    source verify_ops.tcl
#
# Runs the simulation to 360 ns in half clocks (10 ns clock, rising edges at 0, 10, 20 ... ns).
# Just after each rising edge it looks for start and the cache write pulse; just after each
# falling edge for busy, memory enable and output enable. Every event is printed with clk_count
# (the testbench clock number) and count (the chip's clock cycle of the request). At the end each request
# is checked: clocks = clk_count when busy goes low - clk_count at start
# (read miss 19, write hit 3, read hit 2, write miss 3).

proc sig_bit {name} {
    regsub -all {['"]} [value $name] {} v
    return [string index $v end]
}
proc sig_int {name} {
    regexp {(\d+)\s*$} [value $name] -> n
    return $n
}
proc sig_bin {name} {
    regsub -all {['"]} [value $name] {} v
    return $v
}
proc show {what} {
    puts [format "  clk_count %3d   count %-7s  %s" [sig_int :clk_count] [sig_bin :c1:count] $what]
}

array set expected {"read miss" 19 "write hit" 3 "read hit" 2 "write miss" 3}
array set prev {busy 0 mem_en 0 write 0 oe 0}
set ops {}
set pending 0
set kind ""

puts "time (clk_count = testbench clock, count = clock cycle of the request in binary)"
run 1 ns
for {set k 0} {$k < 36} {incr k} {
    # just after the rising edge: a new request, the cache write pulse
    set w [sig_bit :c1:write]
    if {[sig_bit :start] == 1 && [sig_bit :busy] == 0} {
        set t_start [sig_int :clk_count]
        set rw [sig_bit :cpu_rd_wrn]
        set pending 1
        puts ""
        show "start = 1   [expr {$rw == 1 ? {read} : {write}}]  cpu_add = [sig_bin :cpu_add]"
    }
    if {$w == 1 && $prev(write) != 1} { show "write = 1   (cache write, one clock)" }
    set prev(write) $w
    run 5 ns

    # just after the falling edge: hit/miss (first falling edge of a request), busy, enable, output enable
    if {$pending} {
        set kind [expr {$rw == 1 ? "read" : "write"}]
        append kind [expr {[sig_bit :c1:tag_hit] == 1 ? " hit" : " miss"}]
        set pending 0
    }
    set b [sig_bit :busy]
    set e [sig_bit :mem_en]
    set o [sig_bit :c1:output_enable]
    if {$b == 1 && $prev(busy) != 1} { show "busy  = 1   -> $kind" }
    if {$e == 1 && $prev(mem_en) != 1} { show "mem_en = 1  (block requested from memory)" }
    if {$o == 1 && $prev(oe) != 1} { show "output_enable = 1   cpu_data = [sig_bin :cpu_data]" }
    if {$b != 1 && $prev(busy) == 1} {
        set t_end [sig_int :clk_count]
        show "busy  = 0"
        lappend ops [list $kind $t_start $t_end]
    }
    array set prev [list busy $b mem_en $e oe $o]
    run 5 ns
}

puts ""
puts "request       start  busy low  clocks  expected"
set fails 0
foreach op $ops {
    lassign $op kind t0 t1
    set n [expr {$t1 - $t0}]
    set ok [expr {[info exists expected($kind)] && $expected($kind) == $n}]
    if {!$ok} { incr fails }
    puts [format "  %-11s %5d  %8d  %6d  %8s  %s" $kind $t0 $t1 $n \
          [expr {[info exists expected($kind)] ? $expected($kind) : "?"}] [expr {$ok ? "PASS" : "FAIL"}]]
}
puts [expr {$fails == 0 && [llength $ops] == 4 ? "VERIFY: ALL 4 OPERATIONS PASSED" : "VERIFY: FAILED"}]
