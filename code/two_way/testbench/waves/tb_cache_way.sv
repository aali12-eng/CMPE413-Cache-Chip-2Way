# SimVision waveform window of tb_cache_way (dut: cache_way).
# Press = in the waveform window to fit the whole test.

catch {waveform clearall}
catch {waveform set -signalnames name}

proc tbw_add {sig dec} {
    foreach path [list simulator::tb_cache_way:$sig simulator::tb_cache_way.$sig :$sig tb_cache_way:$sig] {
        if {![catch {waveform add -signals [list $path]} id] && $id ne ""} {
            if {$dec} { catch {waveform format $id -radix %d} }
            catch {waveform format $id -name $sig}
            return $id
        }
    }
    puts "tb_cache_way.sv: could not add $sig"
    return ""
}

catch {waveform add -label {Clock / reset}}
tbw_add reset 0

catch {waveform add -label {Inputs}}
tbw_add block_select 1
tbw_add byte_select 1
tbw_add write 0
tbw_add fill 0
tbw_add write_data 1
tbw_add tag_in 1

catch {waveform add -label {Outputs}}
tbw_add read_data 1
tbw_add tag_out 1
tbw_add valid_out 0
