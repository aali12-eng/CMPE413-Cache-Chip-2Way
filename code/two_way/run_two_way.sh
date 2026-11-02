#!/bin/bash
# Two-way set-associative cache: compile and simulate in Cadence Xcelium.
#
#   ./run_two_way.sh          compile, then open SimVision with the waveforms (testbench/waves.tcl)
#   ./run_two_way.sh course   compile, then open SimVision with only the course figures' signals (testbench/waves_course.tcl)
#   ./run_two_way.sh pdf      the same, laid out like the PDF: headings, hex, PDF names; then type page1 or page2 (testbench/waves_pdf.tcl)
#   ./run_two_way.sh text     compile, then run to 360 ns in text mode (output in testbench/xrun.log)
#   ./run_two_way.sh compile  compile only
#   ./run_two_way.sh verify   compile, run chip_test and check every request's clocks (log in testbench/verify.log)
#   ./run_two_way.sh tests    compile, then run every testbench tb_*.vhd in testbench/ (logs in testbench/logs/)
#   ./run_two_way.sh vcd      compile, run every block/cache/control/chip testbench in batch, signals into
#                             testbench/vcd/tb_NAME.vcd
#   ./run_two_way.sh tb_NAME  compile, then open one testbench in SimVision, e.g. ./run_two_way.sh tb_counter;
#                             blocks, cache parts, state machine and chip come up with their signals
#                             grouped (clock/reset, inputs, outputs; buses in hex) and the test run
#                             (testbench/waves/tb_NAME.tcl, .sv)
#
# The design files stay in their folders (primitives/, gates/, blocks/, cache/, control/);
# xrun runs in testbench/, where chip_test.vhd reads ./chip_in.txt. The build output
# (xcelium.d, xrun.log, waves.shm) goes in testbench/ too.
# Testbenches: testbench/{primitives,gates,blocks,cache,control,chip}/tb_*.vhd, using tb_pkg.vhd;
# each one prints "tb_NAME: ALL TESTS PASSED" or reports every failing check.

cd "$(dirname "$0")/testbench" || exit 1

if [ -x ~/cadence1/cadence_setup/launch_cadence_xrun.sh ]; then
    XRUN=~/cadence1/cadence_setup/launch_cadence_xrun.sh
elif command -v xrun >/dev/null 2>&1; then
    XRUN=xrun
else
    echo "launch_cadence_xrun.sh not found in ~/cadence1/cadence_setup/ and xrun not on PATH" >&2
    exit 1
fi

MODE=${1:-gui}

# start from a clean library
rm -rf xcelium.d xrun.history xrun.log verify.log waves.shm logs

# step 1: the design, in dependency order (VHDL-93)
$XRUN -compile -v93 \
    ../cache_pkg.vhd \
    ../primitives/dff.vhd ../primitives/Dlatch.vhd ../primitives/tx.vhd \
    ../gates/not_gate.vhd ../gates/and2_gate.vhd ../gates/or2_gate.vhd \
    ../gates/nand2_gate.vhd ../gates/nor2_gate.vhd ../gates/xor2_gate.vhd \
    ../gates/xnor2_gate.vhd ../gates/and3_gate.vhd ../gates/or3_gate.vhd ../gates/or4_gate.vhd \
    ../blocks/mux2.vhd ../blocks/mux2_n.vhd ../blocks/mux4_n.vhd ../blocks/decoder2to4.vhd \
    ../blocks/and_reduce_n.vhd ../blocks/comparator_n.vhd ../blocks/selector.vhd \
    ../blocks/cache_cell.vhd ../blocks/dff_en.vhd ../blocks/register_n.vhd \
    ../blocks/pos_dff.vhd ../blocks/half_adder.vhd ../blocks/counter.vhd \
    ../cache/cache_byte.vhd ../cache/cache_block.vhd ../cache/cache_way.vhd \
    ../cache/hit_miss.vhd ../cache/way_select.vhd ../cache/lru.vhd ../cache/cache.vhd \
    ../control/state_machine.vhd ../chip.vhd \
    || { echo "Compile failed" >&2; exit 1; }

# step 2: the testbenches (VHDL-93) or the course testbench (VHDL-87 file declarations, so no -v93)
TBS=$(find primitives gates blocks cache control chip -name 'tb_*.vhd' 2>/dev/null | sort)

case "$MODE" in
    compile) ;;
    text)    $XRUN -top chip_test chip_test.vhd -input run.ncsim -access +rwc -l xrun.log ;;
    gui)     $XRUN -top chip_test chip_test.vhd -gui -access +rwc -input waves.tcl ;;
    course)  $XRUN -top chip_test chip_test.vhd -gui -access +rwc -input waves_course.tcl ;;
    pdf)     $XRUN -top chip_test chip_test.vhd -gui -access +rwc -input waves_pdf.tcl ;;
    verify)  $XRUN -top chip_test chip_test.vhd -input verify_batch.tcl -access +rwc -l verify.log ;;
    tests)
        $XRUN -compile -v93 tb_pkg.vhd || { echo "tb_pkg.vhd failed to compile" >&2; exit 1; }
        mkdir -p logs
        pass=0; fail=0; failed=""
        for f in $TBS; do
            tb=$(basename "$f" .vhd)
            $XRUN -v93 -top "$tb" "$f" -input run_tb.ncsim -l "logs/$tb.log" >/dev/null 2>&1
            if grep -q "ALL TESTS PASSED" "logs/$tb.log"; then
                echo "PASS  $tb"; pass=$((pass + 1))
            else
                echo "FAIL  $tb   (see testbench/logs/$tb.log)"; fail=$((fail + 1)); failed="$failed $tb"
            fi
        done
        echo
        echo "$pass passed, $fail failed"
        [ "$fail" -eq 0 ] || { echo "failed:$failed"; exit 1; }
        ;;
    vcd)
        # every higher-level testbench in batch, its signals into testbench/vcd/tb_NAME.vcd
        $XRUN -compile -v93 tb_pkg.vhd || { echo "tb_pkg.vhd failed to compile" >&2; exit 1; }
        rm -rf vcd; mkdir -p vcd logs
        for t in waves/tb_*.vcd.tcl; do
            tb=$(basename "$t" .vcd.tcl)
            f=$(echo "$TBS" | grep "/$tb\.vhd$")
            $XRUN -v93 -top "$tb" "$f" -access +r -input "$t" -l "logs/$tb.vcd.log" >/dev/null 2>&1
            if [ -s "vcd/$tb.vcd" ]; then echo "vcd  $tb"; else echo "NO VCD  $tb   (see testbench/logs/$tb.vcd.log)"; fi
        done
        echo
        ;;
    tb_*)
        f=$(echo "$TBS" | grep "/$MODE\.vhd$")
        [ -n "$f" ] || { echo "no testbench $MODE.vhd in testbench/" >&2; exit 1; }
        $XRUN -compile -v93 tb_pkg.vhd || exit 1
        if [ -f "waves/$MODE.tcl" ]; then
            # the testbench's waveform layout (waves/tb_NAME.tcl): runs the test, signals grouped
            $XRUN -v93 -top "$MODE" "$f" -gui -access +rwc -input "waves/$MODE.tcl"
        else
            $XRUN -v93 -top "$MODE" "$f" -gui -access +rwc
        fi
        ;;
    *)       echo "usage: $0 [gui|course|pdf|text|compile|verify|tests|vcd|tb_NAME]" >&2; exit 1 ;;
esac
