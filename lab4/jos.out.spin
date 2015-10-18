+ ld obj/kern/kernel
+ mk obj/kern/kernel.img
6828 decimal is XXX octal!
Physical memory: 66556K available, base = 640K, extended = 65532K
check_page_alloc() succeeded!
check_page() succeeded!
check_kern_pgdir() succeeded!
check_page_installed_pgdir() succeeded!
cpu_id == 0
SMP: CPU 0 found 1 CPU(s)
enabled interrupts: 1 2
[00000000] new env 00001000
let me see
let me see
I am the parent.  Forking the child...
let me see
let me see
[00001000] user panic in <unknown> at lib/fork.c:81: let me see
let me see
fork not implementedlet me see
let me see

Welcome to the JOS kernel monitor!
Type 'help' for a list of commands.
TRAP frame at 0xf0291000 from CPU 0
  edi  0x00000000
  esi  0x00801236
  ebp  0xeebfdf90
  oesp 0xefffffdc
  ebx  0xeebfdfa4
  edx  0xeebfde38
  ecx  0x00000001
  eax  0x00000001
  es   0x----0023
  ds   0x----0023
  trap 0x00000003 Breakpoint
  err  0x00000000
  eip  0x00800f00
  cs   0x----001b
  flag 0x00000092
  esp  0xeebfdf68
  ss   0x----0023
qemu: terminating on signal 15 from pid 5195
