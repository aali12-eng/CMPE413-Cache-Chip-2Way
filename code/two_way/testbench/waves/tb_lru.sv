# SimVision waveform window of tb_lru (dut: lru).
# Press = in the waveform window to fit the whole test.

catch {waveform clearall}
catch {waveform set -signalnames name}

proc tbw_add {sig dec} {
    foreach path [list simulator::tb_lru:$sig simulator::tb_lru.$sig :$sig tb_lru:$sig] {
        if {![catch {waveform add -signals [list $path]} id] && $id ne ""} {
            if {$dec} { catch {waveform format $id -radix %d} }
            catch {waveform format $id -name $sig}
            return $id
        }
    }
    puts "tb_lru.sv: could not add $sig"
    return ""
}

catch {waveform add -label {Clock / reset}}
tbw_add clk 0
tbw_add reset 0

catch {waveform add -label {Inputs}}
tbw_add block_offset 1
tbw_add update 0
tbw_add used_way 0

catch {waveform add -label {Outputs}}
tbw_add lru_way 0
