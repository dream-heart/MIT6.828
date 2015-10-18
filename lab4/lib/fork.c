// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800

//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.

	panic("pgfault not implemented");
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	struct Env *childEnv =0;
	struct Env* pEnv = curenv;
	if((r = envid2env(envid, &childEnv, 1)) < 0)
		return r;

	pte_t * PTE=0;
	struct PageInfo * page = page_lookup(pEnv->env_pgdir, (void*)(pn*PGSIZE),&PTE);

	r = ((*PTE) & PTE_W) || ((*PTE) & PTE_COW);
	if(!r)
		return 0;
	r = (*PTE) & PTE_P;
	if(page == NULL || (!r) )	//va not mapped
		return 0;
	if( (	r =page_insert(childEnv->env_pgdir, page, (void *)(pn*PGSIZE), PTE_COW|PTE_U|PTE_P))
						<0)  
		return r;

	return 0;

	// LAB 4: Your code here.
	//panic("duppage not implemented");
	//return 0;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use uvpd, uvpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
	// LAB 4: Your code here.
	int r = sys_env_set_pgfault_upcall(curenv->env_id, pgfault);
	if(r < 0)
		panic("sys_env_set_pgfault_upcall is not right ,and the errno is %d\n", r);

	int childEid = sys_exofork();
	if(childEid < 0)
		panic("sys_exofork() is not right, and the errno is  %d\n" childEid);
	int pn =0;
	for(pn=0; pn*PGSIZE < UTOP ; pn++){
		if(pn*PGSIZE == UXSTACKTOP -PGSIZE){
			struct Env *childEnv =0;
			if((r = envid2env(childEid, &childEnv, 1)) < 0)
				panic("envid2env is wrong, the errno is %d\n", r);
			struct PageInfo* page = page_alloc(1);
			if(page == 0)
				panic("there is no memory for the child exception stack\n");
			if( (r =page_insert(childEnv->env_pgdir, page, (void *)(pn*PGSIZE), PTE_W|PTE_U|PTE_P))<0 )
				panic("fork page_insert is wrong, the errno is %d\n", r);
		}
		else
			r = duppage(childEid, pn);
		if(r <0)
			panic("fork() is wrong, and the errno is %d\n", r) );
	}

	//panic("fork not implemented");
}

// Challenge!
int
sfork(void)
{
	panic("sfork not implemented");
	return -E_INVAL;
}
