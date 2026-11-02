# SimVision waveform window of tb_state_machine (dut: state_machine).
# Press = in the waveform window to fit the whole test.

catch {waveform clearall}
catch {waveform set -signalnames name}

proc tbw_add {sig dec} {
    foreach path [list simulator::tb_state_machine:$sig simulator::tb_state_machine.$sig :$sig tb_state_machine:$sig] {
        if {![catch {waveform add -signals [list $path]} id] && $id ne ""} {
            if {$dec} { catch {waveform format $id -radix %d} }
            catch {waveform format $id -name $sig}
            return $id
        }
    }
    puts "tb_state_machine.sv: could not add $sig"
    return ""
}

catch {waveform add -label {Clock / reset}}
tbw_add clk 0
tbw_add reset 0

catch {waveform add -label {Inputs}}
tbw_add start 0
tbw_add read_write 0
tbw_add hit 0
tbw_add count 1

catch {waveform add -label {Outputs}}
tbw_add busy 0
tbw_add enable 0
tbw_add output_enable 0
tbw_add latch_input 0
tbw_add latch_output 0
tbw_add count_enable 0
tbw_add count_restart 0
tbw_add fill_byte 1
tbw_add hit_result 0
tbw_add fill 0
tbw_add write 0
tbw_add latch_way 0
tbw_add lru_update 0
tbw_add state 1
