# SimVision waveform window of tb_selector (dut: selector).
# Press = in the waveform window to fit the whole test.

catch {waveform clearall}
catch {waveform set -signalnames name}

proc tbw_add {sig dec} {
    foreach path [list simulator::tb_selector:$sig simulator::tb_selector.$sig :$sig tb_selector:$sig] {
        if {![catch {waveform add -signals [list $path]} id] && $id ne ""} {
            if {$dec} { catch {waveform format $id -radix %d} }
            catch {waveform format $id -name $sig}
            return $id
        }
    }
    puts "tb_selector.sv: could not add $sig"
    return ""
}

catch {waveform add -label {Inputs}}
tbw_add chip_enable 0
tbw_add rd_wrn 0

catch {waveform add -label {Outputs}}
tbw_add read_enable 0
tbw_add write_enable 0
