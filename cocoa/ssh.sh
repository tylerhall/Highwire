#!/usr/bin/expect -f

set arguments [lindex $argv 0]
set password [lindex $argv 1]
eval spawn $arguments
match_max 100000
set timeout -1

expect {
"?sh: Error*" { puts "HW_ERROR"; exit };
"*yes/no*" { send "yes\r"; exp_continue };
"*Connection refused*" { puts "HW_REFUSED"; exit };
"*timed out*" { puts "HW_REFUSED"; exit };
"*?assword:*" {	send "$password\r"; set timeout 4; expect "*?assword:*" { puts "HW_WRONG"; exit; } };
}

puts "HW_OK";
set timeout -1
expect eof;
