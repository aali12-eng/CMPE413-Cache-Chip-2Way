# SimVision waveform window of tb_cache_cell (dut: cache_cell).
# Press = in the waveform window to fit the whole test.

catch {waveform clearall}
catch {waveform set -signalnames name}

proc tbw_add {sig dec} {
    foreach path [list simulator::tb_cache_cell:$sig simulator::tb_cache_cell.$sig :$sig tb_cache_cell:$sig] {
        if {![catch {waveform add -signals [list $path]} id] && $id ne ""} {
            if {$dec} { catch {waveform format $id -radix %d} }
            catch {waveform format $id -name $sig}
            return $id
        }
    }
    puts "tb_cache_cell.sv: could not add $sig"
    return ""
}

catch {waveform add -label {Inputs}}
tbw_add write_data 0
tbw_add chip_enable 0
tbw_add rd_wrn 0

catch {waveform add -label {Outputs}}
tbw_add read_data 0
