#!/usr/bin/env wish

#buttonize.tcl - Create simple GUI with buttons to run common commandsCreate simple GUI with buttons to run common commands
#Copyright (C) {2017}  {asterisk_man}
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

proc printUsageAndExit {} {
  puts "buttonize.tcl <button label> <button command>"
  puts "  Hold shift when pressing button to display command output."
  exit 1
}

proc getOptions {} {
  global argv
  global CONFIG

  if {[llength $argv] != 2} {
    puts "ERROR: You must supply exactly 2 arguments"
    printUsageAndExit
  }

  set CONFIG(label) [lindex $argv 0]
  set CONFIG(cmd) [lindex $argv 1]

}

proc initGui {} {
  global CONFIG

  wm title . $CONFIG(label)

  button .bCmd -text $CONFIG(label)
  bind .bCmd <Button-1> "executeCmd %s"
  place .bCmd -x 0 -y 0 -relwidth 1.0 -relheight 1.0
}

set outputWindow {}
proc showOutput {s} {
  global CONFIG
  global outputWindow


  if {$outputWindow == {}} {
    set outputWindow ".outputWindow"
    set t $outputWindow

    toplevel $t
    wm title $t "$CONFIG(label) output"
    wm geometry $t "600x400"
    wm protocol $t WM_DELETE_WINDOW "destroy $t; set outputWindow {}"

    text $t.txt
    place $t.txt -x 0 -y 0 -relwidth 1.0 -relheight 1.0
  } else {
    set t $outputWindow
    $t.txt delete 0.0 end
  }

  $t.txt insert end $s
}

proc hideOutput {} {
  global outputWindow
  if {$outputWindow != {}} {
    destroy $outputWindow
  }
  set outputWindow {}
}

proc executeCmd {state} {
  global CONFIG
  global env

  .bCmd configure -background #FF9933
  .bCmd configure -activebackground #FF9933
  update; update idletasks

  if {[catch {exec $env(SHELL) -c "$CONFIG(cmd)"} results options]} {
    .bCmd configure -background #fb5656
    .bCmd configure -activebackground #fb7474
  } else {
    .bCmd configure -background #a2e869
    .bCmd configure -activebackground #bbee91
    set results "SUCCESS"
  }

  if {$state == 1} {
    showOutput $results
  } else {
    hideOutput
  }
}

getOptions
initGui
