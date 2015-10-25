// Ping-pong a counter between two processes.
// Only need to start one of these -- splits into two with fork.

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	envid_t who;
	//cprintf("the peid = %d\n", sys_getenvid());
	if ((who = fork()) != 0) {
		// get the ball rolling
		//cprintf("the father = %d\n", who);
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
		//cprintf("send is successful\n");
	}

	while (1) {
		//cprintf("children = 0\n");
		uint32_t i = ipc_recv(&who, 0, 0);
				//cprintf("i =1");
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
		if (i == 10)
			return;
		i++;
		ipc_send(who, i, 0, 0);
		
		if (i == 10)
			return;
	}

}

