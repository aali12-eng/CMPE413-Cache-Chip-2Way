# SimVision waveform window of tb_cache (dut: cache).
# Press = in the waveform window to fit the whole test.

catch {waveform clearall}
catch {waveform set -signalnames name}

proc tbw_add {sig dec} {
    foreach path [list simulator::tb_cache:$sig simulator::tb_cache.$sig :$sig tb_cache:$sig] {
        if {![catch {waveform add -signals [list $path]} id] && $id ne ""} {
            if {$dec} { catch {waveform format $id -radix %d} }
            catch {waveform format $id -name $sig}
            return $id
        }
    }
    puts "tb_cache.sv: could not add $sig"
    return ""
}

catch {waveform add -label {Clock / reset}}
tbw_add clk 0
tbw_add reset 0

catch {waveform add -label {Inputs}}
tbw_add address 1
tbw_add fill 0
tbw_add fill_byte 1
tbw_add write 0
tbw_add latch_way 0
tbw_add lru_update 0
tbw_add write_data 1

catch {waveform add -label {Outputs}}
tbw_add read_data 1
tbw_add hit 0
tbw_add miss 0
tbw_add way 0
