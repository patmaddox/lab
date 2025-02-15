global commands
set commands [dict create]

proc main {argc argv} {
    eval $argv
}

proc command {name text args body} {
    global commands
    proc $name $args $body
    dict set commands $name $text
}

command help "" {} {
    global commands
    puts "Usage: tclsh build.tcl <cmd> ?args?"
    puts ""
    puts "Commands:"

    dict for {cmd helptext} $commands {
	if {$helptext == ""} {
	    puts "  $cmd"
	} else {
	    puts "  $cmd - $helptext"
	}
    }
}
