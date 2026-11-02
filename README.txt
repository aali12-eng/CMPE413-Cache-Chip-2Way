CMPE 413/640 Custom VLSI Design - Cache Chip Project (Extra Credit)
Two-way set associative cache with LRU replacement, 32 bytes, VHDL

Student: Asif Ali      Reg No: RE16458      aali12@umbc.edu
GitHub:  https://github.com/aali12-eng/CMPE413-Cache-Chip-2Way


1. Contents
-----------
  report/
      Cache_Chip_2Way_Report_Final1.2.pdf    the report
      Cache_Chip_2Way_Report_Final1.2.docx   the same report in Word format
  code/two_way/
      cache_pkg.vhd          shared constants (address, data, tag and counter widths)
      chip.vhd               top level: the cache chip
      primitives/            course primitives: dff, Dlatch, tx
      gates/                 basic gates (not, and, or, nand, nor, xor, xnor)
      blocks/                selector, cache cell, multiplexers, decoder, comparator,
                             registers, write-signal flip-flop, clock cycle counter
      cache/                 cache byte, block and way, hit/miss, way select, LRU, cache
      control/               state machine
      run_two_way.sh         compiles and runs everything in Cadence Xcelium
      testbench/
          chip_test.vhd      the course testbench (unchanged)
          chip_in.txt        the course input file read by chip_test.vhd
          chip_out.log       output of chip_test for this design (360 ns)
          tb_pkg.vhd         helper package of the testbenches
          primitives/ gates/ blocks/ cache/ control/ chip/
                             self-checking testbenches tb_*.vhd; each prints
                             "tb_NAME: ALL TESTS PASSED" or every failing check
          *.tcl, *.sv, waves/   SimVision waveform layouts used by run_two_way.sh


2. Running in the course lab (Cadence Xcelium / SimVision)
----------------------------------------------------------
The script uses ~/cadence1/cadence_setup/launch_cadence_xrun.sh if it exists, otherwise
xrun from the PATH (load the Cadence environment first). From the folder code/two_way:

    cd code/two_way
    chmod +x run_two_way.sh            (only needed once)

    ./run_two_way.sh                   compile, run chip_test and open SimVision with the
                                       waveforms (clock, CPU and memory interface, state,
                                       hit, write, count)
    ./run_two_way.sh text              compile and run chip_test for 360 ns without the GUI;
                                       the printed output is in testbench/xrun.log
    ./run_two_way.sh verify            compile, run chip_test and check the number of clocks
                                       of every request (testbench/verify.log)
    ./run_two_way.sh tests             compile and run every testbench tb_*.vhd;
                                       prints PASS / FAIL for each (logs in testbench/logs/)
    ./run_two_way.sh tb_counter        open one testbench in SimVision with its signals
                                       grouped, e.g. tb_cache, tb_state_machine, tb_chip
    ./run_two_way.sh compile           compile only

Every run starts from a clean library, so it always uses the current files.

Expected results:
  - chip_test: the output in testbench/xrun.log matches testbench/chip_out.log.
    Read miss 19 clocks, write hit 3 clocks, read hit 2 clocks, write miss 3 clocks.
  - tests: every testbench prints ALL TESTS PASSED.

In SimVision, zoom to 0 - 225 ns for the read miss and 225 - 340 ns for the write hit,
read hit and write miss.


3. The same steps by hand (Cadence Xcelium)
-------------------------------------------
This is what run_two_way.sh does. The design is compiled as VHDL-93; chip_test.vhd uses
VHDL-87 file declarations, so it is compiled without -v93. From code/two_way/testbench:

    cd code/two_way/testbench
    rm -rf xcelium.d                   (start from a clean library)

    # the design, in this order
    xrun -compile -v93 ../cache_pkg.vhd \
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
        ../control/state_machine.vhd ../chip.vhd

    # the course testbench (reads ./chip_in.txt): text output, compare with chip_out.log
    xrun -top chip_test chip_test.vhd -input run.ncsim -access +rwc -l xrun.log

    # the course testbench in SimVision, with the waveforms (clock, CPU and memory
    # interface, state, hit, write, count)
    xrun -top chip_test chip_test.vhd -gui -access +rwc -input waves.tcl

    # one self-checking testbench, e.g. the chip (prints "tb_chip: ALL TESTS PASSED")
    xrun -compile -v93 tb_pkg.vhd
    xrun -v93 -top tb_chip chip/tb_chip.vhd -input run_tb.ncsim -l tb_chip.log

run.ncsim runs chip_test for 360 ns and exits; run_tb.ncsim runs a testbench to its end.


4. Design summary
-----------------
  - 2 ways x 4 blocks x 4 bytes = 32 bytes, byte addressable, 6-bit address
    (2-bit tag, 2-bit block offset, 2-bit byte offset)
  - LRU replacement, one bit per block offset; an invalid way is filled first
  - write through with no write allocate
  - read hit 2 clocks, write hit / write miss 3 clocks, read miss 19 clocks
  - structural VHDL down to the course primitives (dff, Dlatch, tx) and basic gates
