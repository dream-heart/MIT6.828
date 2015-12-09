
obj/fs/fs：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 26 15 00 00       	call   801557 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
		return -1;
	return 0;
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 14             	sub    $0x14,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	b2 f7                	mov    $0xf7,%dl
  800082:	eb 0b                	jmp    80008f <ide_probe_disk1+0x30>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800084:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  800087:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  80008d:	74 05                	je     800094 <ide_probe_disk1+0x35>
  80008f:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800090:	a8 a1                	test   $0xa1,%al
  800092:	75 f0                	jne    800084 <ide_probe_disk1+0x25>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800094:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800099:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  80009e:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  80009f:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a5:	0f 9e c3             	setle  %bl
  8000a8:	0f b6 c3             	movzbl %bl,%eax
  8000ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000af:	c7 04 24 60 36 80 00 	movl   $0x803660,(%esp)
  8000b6:	e8 f1 15 00 00       	call   8016ac <cprintf>
	return (x < 1000);
}
  8000bb:	89 d8                	mov    %ebx,%eax
  8000bd:	83 c4 14             	add    $0x14,%esp
  8000c0:	5b                   	pop    %ebx
  8000c1:	5d                   	pop    %ebp
  8000c2:	c3                   	ret    

008000c3 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	83 ec 18             	sub    $0x18,%esp
  8000c9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000cc:	83 f8 01             	cmp    $0x1,%eax
  8000cf:	76 1c                	jbe    8000ed <ide_set_disk+0x2a>
		panic("bad disk number");
  8000d1:	c7 44 24 08 77 36 80 	movl   $0x803677,0x8(%esp)
  8000d8:	00 
  8000d9:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8000e0:	00 
  8000e1:	c7 04 24 87 36 80 00 	movl   $0x803687,(%esp)
  8000e8:	e8 c6 14 00 00       	call   8015b3 <_panic>
	diskno = d;
  8000ed:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000f2:	c9                   	leave  
  8000f3:	c3                   	ret    

008000f4 <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	57                   	push   %edi
  8000f8:	56                   	push   %esi
  8000f9:	53                   	push   %ebx
  8000fa:	83 ec 1c             	sub    $0x1c,%esp
  8000fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800100:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800103:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  800106:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  80010c:	76 24                	jbe    800132 <ide_read+0x3e>
  80010e:	c7 44 24 0c 90 36 80 	movl   $0x803690,0xc(%esp)
  800115:	00 
  800116:	c7 44 24 08 9d 36 80 	movl   $0x80369d,0x8(%esp)
  80011d:	00 
  80011e:	c7 44 24 04 44 00 00 	movl   $0x44,0x4(%esp)
  800125:	00 
  800126:	c7 04 24 87 36 80 00 	movl   $0x803687,(%esp)
  80012d:	e8 81 14 00 00       	call   8015b3 <_panic>

	ide_wait_ready(0);
  800132:	b8 00 00 00 00       	mov    $0x0,%eax
  800137:	e8 f7 fe ff ff       	call   800033 <ide_wait_ready>
  80013c:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800141:	89 f0                	mov    %esi,%eax
  800143:	ee                   	out    %al,(%dx)
  800144:	b2 f3                	mov    $0xf3,%dl
  800146:	89 f8                	mov    %edi,%eax
  800148:	ee                   	out    %al,(%dx)
  800149:	89 f8                	mov    %edi,%eax
  80014b:	0f b6 c4             	movzbl %ah,%eax
  80014e:	b2 f4                	mov    $0xf4,%dl
  800150:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
  800151:	89 f8                	mov    %edi,%eax
  800153:	c1 e8 10             	shr    $0x10,%eax
  800156:	b2 f5                	mov    $0xf5,%dl
  800158:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  800159:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800160:	83 e0 01             	and    $0x1,%eax
  800163:	c1 e0 04             	shl    $0x4,%eax
  800166:	83 c8 e0             	or     $0xffffffe0,%eax
  800169:	c1 ef 18             	shr    $0x18,%edi
  80016c:	83 e7 0f             	and    $0xf,%edi
  80016f:	09 f8                	or     %edi,%eax
  800171:	b2 f6                	mov    $0xf6,%dl
  800173:	ee                   	out    %al,(%dx)
  800174:	b2 f7                	mov    $0xf7,%dl
  800176:	b8 20 00 00 00       	mov    $0x20,%eax
  80017b:	ee                   	out    %al,(%dx)
  80017c:	c1 e6 09             	shl    $0x9,%esi
  80017f:	01 de                	add    %ebx,%esi
  800181:	eb 23                	jmp    8001a6 <ide_read+0xb2>
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800183:	b8 01 00 00 00       	mov    $0x1,%eax
  800188:	e8 a6 fe ff ff       	call   800033 <ide_wait_ready>
  80018d:	85 c0                	test   %eax,%eax
  80018f:	78 1e                	js     8001af <ide_read+0xbb>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  800191:	89 df                	mov    %ebx,%edi
  800193:	b9 80 00 00 00       	mov    $0x80,%ecx
  800198:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80019d:	fc                   	cld    
  80019e:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  8001a0:	81 c3 00 02 00 00    	add    $0x200,%ebx
  8001a6:	39 f3                	cmp    %esi,%ebx
  8001a8:	75 d9                	jne    800183 <ide_read+0x8f>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001af:	83 c4 1c             	add    $0x1c,%esp
  8001b2:	5b                   	pop    %ebx
  8001b3:	5e                   	pop    %esi
  8001b4:	5f                   	pop    %edi
  8001b5:	5d                   	pop    %ebp
  8001b6:	c3                   	ret    

008001b7 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	57                   	push   %edi
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	83 ec 1c             	sub    $0x1c,%esp
  8001c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001c6:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c9:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001cf:	76 24                	jbe    8001f5 <ide_write+0x3e>
  8001d1:	c7 44 24 0c 90 36 80 	movl   $0x803690,0xc(%esp)
  8001d8:	00 
  8001d9:	c7 44 24 08 9d 36 80 	movl   $0x80369d,0x8(%esp)
  8001e0:	00 
  8001e1:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8001e8:	00 
  8001e9:	c7 04 24 87 36 80 00 	movl   $0x803687,(%esp)
  8001f0:	e8 be 13 00 00       	call   8015b3 <_panic>

	ide_wait_ready(0);
  8001f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8001fa:	e8 34 fe ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ff:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800204:	89 f8                	mov    %edi,%eax
  800206:	ee                   	out    %al,(%dx)
  800207:	b2 f3                	mov    $0xf3,%dl
  800209:	89 f0                	mov    %esi,%eax
  80020b:	ee                   	out    %al,(%dx)
  80020c:	89 f0                	mov    %esi,%eax
  80020e:	0f b6 c4             	movzbl %ah,%eax
  800211:	b2 f4                	mov    $0xf4,%dl
  800213:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
  800214:	89 f0                	mov    %esi,%eax
  800216:	c1 e8 10             	shr    $0x10,%eax
  800219:	b2 f5                	mov    $0xf5,%dl
  80021b:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  80021c:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800223:	83 e0 01             	and    $0x1,%eax
  800226:	c1 e0 04             	shl    $0x4,%eax
  800229:	83 c8 e0             	or     $0xffffffe0,%eax
  80022c:	c1 ee 18             	shr    $0x18,%esi
  80022f:	83 e6 0f             	and    $0xf,%esi
  800232:	09 f0                	or     %esi,%eax
  800234:	b2 f6                	mov    $0xf6,%dl
  800236:	ee                   	out    %al,(%dx)
  800237:	b2 f7                	mov    $0xf7,%dl
  800239:	b8 30 00 00 00       	mov    $0x30,%eax
  80023e:	ee                   	out    %al,(%dx)
  80023f:	c1 e7 09             	shl    $0x9,%edi
  800242:	01 df                	add    %ebx,%edi
  800244:	eb 23                	jmp    800269 <ide_write+0xb2>
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800246:	b8 01 00 00 00       	mov    $0x1,%eax
  80024b:	e8 e3 fd ff ff       	call   800033 <ide_wait_ready>
  800250:	85 c0                	test   %eax,%eax
  800252:	78 1e                	js     800272 <ide_write+0xbb>
}

static __inline void
outsl(int port, const void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\toutsl"		:
  800254:	89 de                	mov    %ebx,%esi
  800256:	b9 80 00 00 00       	mov    $0x80,%ecx
  80025b:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800260:	fc                   	cld    
  800261:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800263:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800269:	39 fb                	cmp    %edi,%ebx
  80026b:	75 d9                	jne    800246 <ide_write+0x8f>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  80026d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800272:	83 c4 1c             	add    $0x1c,%esp
  800275:	5b                   	pop    %ebx
  800276:	5e                   	pop    %esi
  800277:	5f                   	pop    %edi
  800278:	5d                   	pop    %ebp
  800279:	c3                   	ret    

0080027a <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	53                   	push   %ebx
  80027e:	83 ec 24             	sub    $0x24,%esp
  800281:	8b 4d 08             	mov    0x8(%ebp),%ecx
	void *addr = (void *) utf->utf_fault_va;
  800284:	8b 01                	mov    (%ecx),%eax
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800286:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
  80028c:	89 d3                	mov    %edx,%ebx
  80028e:	c1 eb 0c             	shr    $0xc,%ebx
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800291:	81 fa ff ff ff bf    	cmp    $0xbfffffff,%edx
  800297:	76 2e                	jbe    8002c7 <bc_pgfault+0x4d>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800299:	8b 51 04             	mov    0x4(%ecx),%edx
  80029c:	89 54 24 14          	mov    %edx,0x14(%esp)
  8002a0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a4:	8b 41 28             	mov    0x28(%ecx),%eax
  8002a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ab:	c7 44 24 08 b4 36 80 	movl   $0x8036b4,0x8(%esp)
  8002b2:	00 
  8002b3:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8002ba:	00 
  8002bb:	c7 04 24 4a 37 80 00 	movl   $0x80374a,(%esp)
  8002c2:	e8 ec 12 00 00       	call   8015b3 <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002c7:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8002cd:	85 d2                	test   %edx,%edx
  8002cf:	74 25                	je     8002f6 <bc_pgfault+0x7c>
  8002d1:	3b 5a 04             	cmp    0x4(%edx),%ebx
  8002d4:	72 20                	jb     8002f6 <bc_pgfault+0x7c>
		panic("reading non-existent block %08x\n", blockno);
  8002d6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002da:	c7 44 24 08 e4 36 80 	movl   $0x8036e4,0x8(%esp)
  8002e1:	00 
  8002e2:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8002e9:	00 
  8002ea:	c7 04 24 4a 37 80 00 	movl   $0x80374a,(%esp)
  8002f1:	e8 bd 12 00 00       	call   8015b3 <_panic>
	//
	// LAB 5: you code here:

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  8002f6:	89 c2                	mov    %eax,%edx
  8002f8:	c1 ea 0c             	shr    $0xc,%edx
  8002fb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800302:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800308:	89 54 24 10          	mov    %edx,0x10(%esp)
  80030c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800310:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800317:	00 
  800318:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800323:	e8 6f 1e 00 00       	call   802197 <sys_page_map>
  800328:	85 c0                	test   %eax,%eax
  80032a:	79 20                	jns    80034c <bc_pgfault+0xd2>
		panic("in bc_pgfault, sys_page_map: %e", r);
  80032c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800330:	c7 44 24 08 08 37 80 	movl   $0x803708,0x8(%esp)
  800337:	00 
  800338:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  80033f:	00 
  800340:	c7 04 24 4a 37 80 00 	movl   $0x80374a,(%esp)
  800347:	e8 67 12 00 00       	call   8015b3 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  80034c:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  800353:	74 2c                	je     800381 <bc_pgfault+0x107>
  800355:	89 1c 24             	mov    %ebx,(%esp)
  800358:	e8 97 03 00 00       	call   8006f4 <block_is_free>
  80035d:	84 c0                	test   %al,%al
  80035f:	74 20                	je     800381 <bc_pgfault+0x107>
		panic("reading free block %08x\n", blockno);
  800361:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800365:	c7 44 24 08 52 37 80 	movl   $0x803752,0x8(%esp)
  80036c:	00 
  80036d:	c7 44 24 04 3d 00 00 	movl   $0x3d,0x4(%esp)
  800374:	00 
  800375:	c7 04 24 4a 37 80 00 	movl   $0x80374a,(%esp)
  80037c:	e8 32 12 00 00       	call   8015b3 <_panic>
}
  800381:	83 c4 24             	add    $0x24,%esp
  800384:	5b                   	pop    %ebx
  800385:	5d                   	pop    %ebp
  800386:	c3                   	ret    

00800387 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	83 ec 18             	sub    $0x18,%esp
  80038d:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  800390:	85 c0                	test   %eax,%eax
  800392:	74 0f                	je     8003a3 <diskaddr+0x1c>
  800394:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  80039a:	85 d2                	test   %edx,%edx
  80039c:	74 25                	je     8003c3 <diskaddr+0x3c>
  80039e:	3b 42 04             	cmp    0x4(%edx),%eax
  8003a1:	72 20                	jb     8003c3 <diskaddr+0x3c>
		panic("bad block number %08x in diskaddr", blockno);
  8003a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a7:	c7 44 24 08 28 37 80 	movl   $0x803728,0x8(%esp)
  8003ae:	00 
  8003af:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  8003b6:	00 
  8003b7:	c7 04 24 4a 37 80 00 	movl   $0x80374a,(%esp)
  8003be:	e8 f0 11 00 00       	call   8015b3 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003c3:	05 00 00 01 00       	add    $0x10000,%eax
  8003c8:	c1 e0 0c             	shl    $0xc,%eax
}
  8003cb:	c9                   	leave  
  8003cc:	c3                   	ret    

008003cd <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003d3:	89 d0                	mov    %edx,%eax
  8003d5:	c1 e8 16             	shr    $0x16,%eax
  8003d8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003df:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e4:	f6 c1 01             	test   $0x1,%cl
  8003e7:	74 0d                	je     8003f6 <va_is_mapped+0x29>
  8003e9:	c1 ea 0c             	shr    $0xc,%edx
  8003ec:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8003f3:	83 e0 01             	and    $0x1,%eax
  8003f6:	83 e0 01             	and    $0x1,%eax
}
  8003f9:	5d                   	pop    %ebp
  8003fa:	c3                   	ret    

008003fb <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800401:	c1 e8 0c             	shr    $0xc,%eax
  800404:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80040b:	c1 e8 06             	shr    $0x6,%eax
  80040e:	83 e0 01             	and    $0x1,%eax
}
  800411:	5d                   	pop    %ebp
  800412:	c3                   	ret    

00800413 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	83 ec 18             	sub    $0x18,%esp
  800419:	8b 45 08             	mov    0x8(%ebp),%eax
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80041c:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
  800422:	81 fa ff ff ff bf    	cmp    $0xbfffffff,%edx
  800428:	76 20                	jbe    80044a <flush_block+0x37>
		panic("flush_block of bad va %08x", addr);
  80042a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80042e:	c7 44 24 08 6b 37 80 	movl   $0x80376b,0x8(%esp)
  800435:	00 
  800436:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  80043d:	00 
  80043e:	c7 04 24 4a 37 80 00 	movl   $0x80374a,(%esp)
  800445:	e8 69 11 00 00       	call   8015b3 <_panic>

	// LAB 5: Your code here.
	panic("flush_block not implemented");
  80044a:	c7 44 24 08 86 37 80 	movl   $0x803786,0x8(%esp)
  800451:	00 
  800452:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  800459:	00 
  80045a:	c7 04 24 4a 37 80 00 	movl   $0x80374a,(%esp)
  800461:	e8 4d 11 00 00       	call   8015b3 <_panic>

00800466 <check_bc>:

// Test that the block cache works, by smashing the superblock and
// reading it back.
static void
check_bc(void)
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  80046f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800476:	e8 0c ff ff ff       	call   800387 <diskaddr>
  80047b:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  800482:	00 
  800483:	89 44 24 04          	mov    %eax,0x4(%esp)
  800487:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80048d:	89 04 24             	mov    %eax,(%esp)
  800490:	e8 2f 1a 00 00       	call   801ec4 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800495:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80049c:	e8 e6 fe ff ff       	call   800387 <diskaddr>
  8004a1:	c7 44 24 04 a2 37 80 	movl   $0x8037a2,0x4(%esp)
  8004a8:	00 
  8004a9:	89 04 24             	mov    %eax,(%esp)
  8004ac:	e8 76 18 00 00       	call   801d27 <strcpy>
	flush_block(diskaddr(1));
  8004b1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004b8:	e8 ca fe ff ff       	call   800387 <diskaddr>
  8004bd:	89 04 24             	mov    %eax,(%esp)
  8004c0:	e8 4e ff ff ff       	call   800413 <flush_block>

008004c5 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004c5:	55                   	push   %ebp
  8004c6:	89 e5                	mov    %esp,%ebp
  8004c8:	83 ec 18             	sub    $0x18,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004cb:	c7 04 24 7a 02 80 00 	movl   $0x80027a,(%esp)
  8004d2:	e8 d4 1e 00 00       	call   8023ab <set_pgfault_handler>
	check_bc();
  8004d7:	e8 8a ff ff ff       	call   800466 <check_bc>

008004dc <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	57                   	push   %edi
  8004e0:	56                   	push   %esi
  8004e1:	53                   	push   %ebx
  8004e2:	81 ec ac 00 00 00    	sub    $0xac,%esp
  8004e8:	89 c3                	mov    %eax,%ebx
  8004ea:	89 95 64 ff ff ff    	mov    %edx,-0x9c(%ebp)
  8004f0:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  8004f6:	eb 03                	jmp    8004fb <walk_path+0x1f>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  8004f8:	83 c3 01             	add    $0x1,%ebx

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  8004fb:	80 3b 2f             	cmpb   $0x2f,(%ebx)
  8004fe:	74 f8                	je     8004f8 <walk_path+0x1c>
  800500:	89 da                	mov    %ebx,%edx
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800502:	8b 3d 08 a0 80 00    	mov    0x80a008,%edi
  800508:	8d 47 08             	lea    0x8(%edi),%eax
  80050b:	89 85 5c ff ff ff    	mov    %eax,-0xa4(%ebp)
	dir = 0;
	name[0] = 0;
  800511:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800518:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  80051e:	85 c0                	test   %eax,%eax
  800520:	0f 84 4a 01 00 00    	je     800670 <walk_path+0x194>
		*pdir = 0;
  800526:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pf = 0;
  80052c:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  800532:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (*path != '\0') {
  800538:	80 3b 00             	cmpb   $0x0,(%ebx)
  80053b:	75 08                	jne    800545 <walk_path+0x69>
  80053d:	e9 ff 00 00 00       	jmp    800641 <walk_path+0x165>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800542:	83 c3 01             	add    $0x1,%ebx
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800545:	0f b6 03             	movzbl (%ebx),%eax
  800548:	84 c0                	test   %al,%al
  80054a:	74 04                	je     800550 <walk_path+0x74>
  80054c:	3c 2f                	cmp    $0x2f,%al
  80054e:	75 f2                	jne    800542 <walk_path+0x66>
			path++;
		if (path - p >= MAXNAMELEN)
  800550:	89 de                	mov    %ebx,%esi
  800552:	29 d6                	sub    %edx,%esi
  800554:	83 fe 7f             	cmp    $0x7f,%esi
  800557:	0f 8f 05 01 00 00    	jg     800662 <walk_path+0x186>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  80055d:	89 74 24 08          	mov    %esi,0x8(%esp)
  800561:	89 54 24 04          	mov    %edx,0x4(%esp)
  800565:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80056b:	89 04 24             	mov    %eax,(%esp)
  80056e:	e8 51 19 00 00       	call   801ec4 <memmove>
		name[path - p] = '\0';
  800573:	c6 84 35 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%esi,1)
  80057a:	00 
  80057b:	eb 03                	jmp    800580 <walk_path+0xa4>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  80057d:	83 c3 01             	add    $0x1,%ebx

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800580:	0f b6 13             	movzbl (%ebx),%edx
  800583:	80 fa 2f             	cmp    $0x2f,%dl
  800586:	74 f5                	je     80057d <walk_path+0xa1>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800588:	83 bf 8c 00 00 00 01 	cmpl   $0x1,0x8c(%edi)
  80058f:	0f 85 d4 00 00 00    	jne    800669 <walk_path+0x18d>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800595:	8b 87 88 00 00 00    	mov    0x88(%edi),%eax
  80059b:	a9 ff 0f 00 00       	test   $0xfff,%eax
  8005a0:	74 24                	je     8005c6 <walk_path+0xea>
  8005a2:	c7 44 24 0c a9 37 80 	movl   $0x8037a9,0xc(%esp)
  8005a9:	00 
  8005aa:	c7 44 24 08 9d 36 80 	movl   $0x80369d,0x8(%esp)
  8005b1:	00 
  8005b2:	c7 44 24 04 ab 00 00 	movl   $0xab,0x4(%esp)
  8005b9:	00 
  8005ba:	c7 04 24 c6 37 80 00 	movl   $0x8037c6,(%esp)
  8005c1:	e8 ed 0f 00 00       	call   8015b3 <_panic>
	nblock = dir->f_size / BLKSIZE;
  8005c6:	8d 88 ff 0f 00 00    	lea    0xfff(%eax),%ecx
  8005cc:	85 c0                	test   %eax,%eax
  8005ce:	0f 48 c1             	cmovs  %ecx,%eax
  8005d1:	c1 f8 0c             	sar    $0xc,%eax
	for (i = 0; i < nblock; i++) {
  8005d4:	85 c0                	test   %eax,%eax
  8005d6:	74 1c                	je     8005f4 <walk_path+0x118>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  8005d8:	c7 44 24 08 98 38 80 	movl   $0x803898,0x8(%esp)
  8005df:	00 
  8005e0:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  8005e7:	00 
  8005e8:	c7 04 24 c6 37 80 00 	movl   $0x8037c6,(%esp)
  8005ef:	e8 bf 0f 00 00       	call   8015b3 <_panic>
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  8005f4:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  8005f9:	84 d2                	test   %dl,%dl
  8005fb:	0f 85 86 00 00 00    	jne    800687 <walk_path+0x1ab>
				if (pdir)
  800601:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  800607:	85 c0                	test   %eax,%eax
  800609:	74 08                	je     800613 <walk_path+0x137>
					*pdir = dir;
  80060b:	8b 8d 5c ff ff ff    	mov    -0xa4(%ebp),%ecx
  800611:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800613:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800617:	74 15                	je     80062e <walk_path+0x152>
					strcpy(lastelem, name);
  800619:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80061f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800623:	8b 45 08             	mov    0x8(%ebp),%eax
  800626:	89 04 24             	mov    %eax,(%esp)
  800629:	e8 f9 16 00 00       	call   801d27 <strcpy>
				*pf = 0;
  80062e:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  800634:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  80063a:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  80063f:	eb 46                	jmp    800687 <walk_path+0x1ab>
		}
	}

	if (pdir)
		*pdir = dir;
  800641:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  800647:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pf = f;
  80064d:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  800653:	8b 8d 5c ff ff ff    	mov    -0xa4(%ebp),%ecx
  800659:	89 08                	mov    %ecx,(%eax)
	return 0;
  80065b:	b8 00 00 00 00       	mov    $0x0,%eax
  800660:	eb 25                	jmp    800687 <walk_path+0x1ab>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800662:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800667:	eb 1e                	jmp    800687 <walk_path+0x1ab>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800669:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  80066e:	eb 17                	jmp    800687 <walk_path+0x1ab>
	dir = 0;
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
  800670:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  800676:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (*path != '\0') {
  80067c:	80 3b 00             	cmpb   $0x0,(%ebx)
  80067f:	0f 85 c0 fe ff ff    	jne    800545 <walk_path+0x69>
  800685:	eb c6                	jmp    80064d <walk_path+0x171>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800687:	81 c4 ac 00 00 00    	add    $0xac,%esp
  80068d:	5b                   	pop    %ebx
  80068e:	5e                   	pop    %esi
  80068f:	5f                   	pop    %edi
  800690:	5d                   	pop    %ebp
  800691:	c3                   	ret    

00800692 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  800692:	55                   	push   %ebp
  800693:	89 e5                	mov    %esp,%ebp
  800695:	83 ec 18             	sub    $0x18,%esp
	if (super->s_magic != FS_MAGIC)
  800698:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80069d:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  8006a3:	74 1c                	je     8006c1 <check_super+0x2f>
		panic("bad file system magic number");
  8006a5:	c7 44 24 08 ce 37 80 	movl   $0x8037ce,0x8(%esp)
  8006ac:	00 
  8006ad:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8006b4:	00 
  8006b5:	c7 04 24 c6 37 80 00 	movl   $0x8037c6,(%esp)
  8006bc:	e8 f2 0e 00 00       	call   8015b3 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8006c1:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8006c8:	76 1c                	jbe    8006e6 <check_super+0x54>
		panic("file system is too large");
  8006ca:	c7 44 24 08 eb 37 80 	movl   $0x8037eb,0x8(%esp)
  8006d1:	00 
  8006d2:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  8006d9:	00 
  8006da:	c7 04 24 c6 37 80 00 	movl   $0x8037c6,(%esp)
  8006e1:	e8 cd 0e 00 00       	call   8015b3 <_panic>

	cprintf("superblock is good\n");
  8006e6:	c7 04 24 04 38 80 00 	movl   $0x803804,(%esp)
  8006ed:	e8 ba 0f 00 00       	call   8016ac <cprintf>
}
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  8006fa:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  800700:	85 d2                	test   %edx,%edx
  800702:	74 22                	je     800726 <block_is_free+0x32>
		return 0;
  800704:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  800709:	39 4a 04             	cmp    %ecx,0x4(%edx)
  80070c:	76 1d                	jbe    80072b <block_is_free+0x37>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  80070e:	b8 01 00 00 00       	mov    $0x1,%eax
  800713:	d3 e0                	shl    %cl,%eax
  800715:	c1 e9 05             	shr    $0x5,%ecx
  800718:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  80071e:	85 04 8a             	test   %eax,(%edx,%ecx,4)
		return 1;
  800721:	0f 95 c0             	setne  %al
  800724:	eb 05                	jmp    80072b <block_is_free+0x37>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  800726:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  80072b:	5d                   	pop    %ebp
  80072c:	c3                   	ret    

0080072d <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	53                   	push   %ebx
  800731:	83 ec 14             	sub    $0x14,%esp
  800734:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  800737:	85 c9                	test   %ecx,%ecx
  800739:	75 1c                	jne    800757 <free_block+0x2a>
		panic("attempt to free zero block");
  80073b:	c7 44 24 08 18 38 80 	movl   $0x803818,0x8(%esp)
  800742:	00 
  800743:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80074a:	00 
  80074b:	c7 04 24 c6 37 80 00 	movl   $0x8037c6,(%esp)
  800752:	e8 5c 0e 00 00       	call   8015b3 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800757:	89 ca                	mov    %ecx,%edx
  800759:	c1 ea 05             	shr    $0x5,%edx
  80075c:	a1 04 a0 80 00       	mov    0x80a004,%eax
  800761:	bb 01 00 00 00       	mov    $0x1,%ebx
  800766:	d3 e3                	shl    %cl,%ebx
  800768:	09 1c 90             	or     %ebx,(%eax,%edx,4)
}
  80076b:	83 c4 14             	add    $0x14,%esp
  80076e:	5b                   	pop    %ebx
  80076f:	5d                   	pop    %ebp
  800770:	c3                   	ret    

00800771 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	83 ec 18             	sub    $0x18,%esp
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	panic("alloc_block not implemented");
  800777:	c7 44 24 08 33 38 80 	movl   $0x803833,0x8(%esp)
  80077e:	00 
  80077f:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  800786:	00 
  800787:	c7 04 24 c6 37 80 00 	movl   $0x8037c6,(%esp)
  80078e:	e8 20 0e 00 00       	call   8015b3 <_panic>

00800793 <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	56                   	push   %esi
  800797:	53                   	push   %ebx
  800798:	83 ec 10             	sub    $0x10,%esp
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  80079b:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8007a0:	8b 70 04             	mov    0x4(%eax),%esi
  8007a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007a8:	eb 36                	jmp    8007e0 <check_bitmap+0x4d>
  8007aa:	8d 43 02             	lea    0x2(%ebx),%eax
		assert(!block_is_free(2+i));
  8007ad:	89 04 24             	mov    %eax,(%esp)
  8007b0:	e8 3f ff ff ff       	call   8006f4 <block_is_free>
  8007b5:	84 c0                	test   %al,%al
  8007b7:	74 24                	je     8007dd <check_bitmap+0x4a>
  8007b9:	c7 44 24 0c 4f 38 80 	movl   $0x80384f,0xc(%esp)
  8007c0:	00 
  8007c1:	c7 44 24 08 9d 36 80 	movl   $0x80369d,0x8(%esp)
  8007c8:	00 
  8007c9:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  8007d0:	00 
  8007d1:	c7 04 24 c6 37 80 00 	movl   $0x8037c6,(%esp)
  8007d8:	e8 d6 0d 00 00       	call   8015b3 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8007dd:	83 c3 01             	add    $0x1,%ebx
  8007e0:	89 d8                	mov    %ebx,%eax
  8007e2:	c1 e0 0f             	shl    $0xf,%eax
  8007e5:	39 c6                	cmp    %eax,%esi
  8007e7:	77 c1                	ja     8007aa <check_bitmap+0x17>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  8007e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007f0:	e8 ff fe ff ff       	call   8006f4 <block_is_free>
  8007f5:	84 c0                	test   %al,%al
  8007f7:	74 24                	je     80081d <check_bitmap+0x8a>
  8007f9:	c7 44 24 0c 63 38 80 	movl   $0x803863,0xc(%esp)
  800800:	00 
  800801:	c7 44 24 08 9d 36 80 	movl   $0x80369d,0x8(%esp)
  800808:	00 
  800809:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800810:	00 
  800811:	c7 04 24 c6 37 80 00 	movl   $0x8037c6,(%esp)
  800818:	e8 96 0d 00 00       	call   8015b3 <_panic>
	assert(!block_is_free(1));
  80081d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800824:	e8 cb fe ff ff       	call   8006f4 <block_is_free>
  800829:	84 c0                	test   %al,%al
  80082b:	74 24                	je     800851 <check_bitmap+0xbe>
  80082d:	c7 44 24 0c 75 38 80 	movl   $0x803875,0xc(%esp)
  800834:	00 
  800835:	c7 44 24 08 9d 36 80 	movl   $0x80369d,0x8(%esp)
  80083c:	00 
  80083d:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  800844:	00 
  800845:	c7 04 24 c6 37 80 00 	movl   $0x8037c6,(%esp)
  80084c:	e8 62 0d 00 00       	call   8015b3 <_panic>

	cprintf("bitmap is good\n");
  800851:	c7 04 24 87 38 80 00 	movl   $0x803887,(%esp)
  800858:	e8 4f 0e 00 00       	call   8016ac <cprintf>
}
  80085d:	83 c4 10             	add    $0x10,%esp
  800860:	5b                   	pop    %ebx
  800861:	5e                   	pop    %esi
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);

       // Find a JOS disk.  Use the second IDE disk (number 1) if availabl
       if (ide_probe_disk1())
  80086a:	e8 f0 f7 ff ff       	call   80005f <ide_probe_disk1>
  80086f:	84 c0                	test   %al,%al
  800871:	74 0e                	je     800881 <fs_init+0x1d>
               ide_set_disk(1);
  800873:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80087a:	e8 44 f8 ff ff       	call   8000c3 <ide_set_disk>
  80087f:	eb 0c                	jmp    80088d <fs_init+0x29>
       else
               ide_set_disk(0);
  800881:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800888:	e8 36 f8 ff ff       	call   8000c3 <ide_set_disk>
	bc_init();
  80088d:	e8 33 fc ff ff       	call   8004c5 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800892:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800899:	e8 e9 fa ff ff       	call   800387 <diskaddr>
  80089e:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  8008a3:	e8 ea fd ff ff       	call   800692 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  8008a8:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8008af:	e8 d3 fa ff ff       	call   800387 <diskaddr>
  8008b4:	a3 04 a0 80 00       	mov    %eax,0x80a004
	check_bitmap();
  8008b9:	e8 d5 fe ff ff       	call   800793 <check_bitmap>
	
}
  8008be:	c9                   	leave  
  8008bf:	c3                   	ret    

008008c0 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	83 ec 18             	sub    $0x18,%esp
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  8008c6:	c7 44 24 08 98 38 80 	movl   $0x803898,0x8(%esp)
  8008cd:	00 
  8008ce:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  8008d5:	00 
  8008d6:	c7 04 24 c6 37 80 00 	movl   $0x8037c6,(%esp)
  8008dd:	e8 d1 0c 00 00       	call   8015b3 <_panic>

008008e2 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	56                   	push   %esi
  8008e6:	53                   	push   %ebx
  8008e7:	81 ec a0 00 00 00    	sub    $0xa0,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  8008ed:	8d 85 78 ff ff ff    	lea    -0x88(%ebp),%eax
  8008f3:	89 04 24             	mov    %eax,(%esp)
  8008f6:	8d 8d 70 ff ff ff    	lea    -0x90(%ebp),%ecx
  8008fc:	8d 95 74 ff ff ff    	lea    -0x8c(%ebp),%edx
  800902:	8b 45 08             	mov    0x8(%ebp),%eax
  800905:	e8 d2 fb ff ff       	call   8004dc <walk_path>
  80090a:	89 c2                	mov    %eax,%edx
  80090c:	85 c0                	test   %eax,%eax
  80090e:	0f 84 9b 00 00 00    	je     8009af <file_create+0xcd>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  800914:	83 fa f5             	cmp    $0xfffffff5,%edx
  800917:	0f 85 9e 00 00 00    	jne    8009bb <file_create+0xd9>
  80091d:	8b 8d 74 ff ff ff    	mov    -0x8c(%ebp),%ecx
  800923:	85 c9                	test   %ecx,%ecx
  800925:	0f 84 8b 00 00 00    	je     8009b6 <file_create+0xd4>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  80092b:	8b 99 80 00 00 00    	mov    0x80(%ecx),%ebx
  800931:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
  800937:	74 24                	je     80095d <file_create+0x7b>
  800939:	c7 44 24 0c a9 37 80 	movl   $0x8037a9,0xc(%esp)
  800940:	00 
  800941:	c7 44 24 08 9d 36 80 	movl   $0x80369d,0x8(%esp)
  800948:	00 
  800949:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
  800950:	00 
  800951:	c7 04 24 c6 37 80 00 	movl   $0x8037c6,(%esp)
  800958:	e8 56 0c 00 00       	call   8015b3 <_panic>
	nblock = dir->f_size / BLKSIZE;
  80095d:	be 00 10 00 00       	mov    $0x1000,%esi
  800962:	89 d8                	mov    %ebx,%eax
  800964:	99                   	cltd   
  800965:	f7 fe                	idiv   %esi
	for (i = 0; i < nblock; i++) {
  800967:	85 c0                	test   %eax,%eax
  800969:	74 1c                	je     800987 <file_create+0xa5>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  80096b:	c7 44 24 08 98 38 80 	movl   $0x803898,0x8(%esp)
  800972:	00 
  800973:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  80097a:	00 
  80097b:	c7 04 24 c6 37 80 00 	movl   $0x8037c6,(%esp)
  800982:	e8 2c 0c 00 00       	call   8015b3 <_panic>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  800987:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80098d:	89 99 80 00 00 00    	mov    %ebx,0x80(%ecx)
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  800993:	c7 44 24 08 98 38 80 	movl   $0x803898,0x8(%esp)
  80099a:	00 
  80099b:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  8009a2:	00 
  8009a3:	c7 04 24 c6 37 80 00 	movl   $0x8037c6,(%esp)
  8009aa:	e8 04 0c 00 00       	call   8015b3 <_panic>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  8009af:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  8009b4:	eb 05                	jmp    8009bb <file_create+0xd9>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  8009b6:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

	strcpy(f->f_name, name);
	*pf = f;
	file_flush(dir);
	return 0;
}
  8009bb:	81 c4 a0 00 00 00    	add    $0xa0,%esp
  8009c1:	5b                   	pop    %ebx
  8009c2:	5e                   	pop    %esi
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	83 ec 18             	sub    $0x18,%esp
	return walk_path(path, 0, pf, 0);
  8009cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	e8 fa fa ff ff       	call   8004dc <walk_path>
}
  8009e2:	c9                   	leave  
  8009e3:	c3                   	ret    

008009e4 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	83 ec 18             	sub    $0x18,%esp
  8009ea:	8b 55 14             	mov    0x14(%ebp),%edx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  8009f6:	39 d0                	cmp    %edx,%eax
  8009f8:	7e 2c                	jle    800a26 <file_read+0x42>
		return 0;

	count = MIN(count, f->f_size - offset);
  8009fa:	29 d0                	sub    %edx,%eax
  8009fc:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009ff:	0f 47 45 10          	cmova  0x10(%ebp),%eax

	for (pos = offset; pos < offset + count; ) {
  800a03:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  800a06:	39 ca                	cmp    %ecx,%edx
  800a08:	73 21                	jae    800a2b <file_read+0x47>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  800a0a:	c7 44 24 08 98 38 80 	movl   $0x803898,0x8(%esp)
  800a11:	00 
  800a12:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  800a19:	00 
  800a1a:	c7 04 24 c6 37 80 00 	movl   $0x8037c6,(%esp)
  800a21:	e8 8d 0b 00 00       	call   8015b3 <_panic>
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
		return 0;
  800a26:	b8 00 00 00 00       	mov    $0x0,%eax
		pos += bn;
		buf += bn;
	}

	return count;
}
  800a2b:	c9                   	leave  
  800a2c:	c3                   	ret    

00800a2d <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	56                   	push   %esi
  800a31:	53                   	push   %ebx
  800a32:	83 ec 10             	sub    $0x10,%esp
  800a35:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a38:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (f->f_size > newsize)
  800a3b:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  800a41:	39 f0                	cmp    %esi,%eax
  800a43:	7e 66                	jle    800aab <file_set_size+0x7e>
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800a45:	8d 8e fe 1f 00 00    	lea    0x1ffe(%esi),%ecx
  800a4b:	89 f2                	mov    %esi,%edx
  800a4d:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800a53:	0f 48 d1             	cmovs  %ecx,%edx
  800a56:	c1 fa 0c             	sar    $0xc,%edx
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800a59:	8d 88 fe 1f 00 00    	lea    0x1ffe(%eax),%ecx
  800a5f:	05 ff 0f 00 00       	add    $0xfff,%eax
  800a64:	0f 48 c1             	cmovs  %ecx,%eax
  800a67:	c1 f8 0c             	sar    $0xc,%eax
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800a6a:	39 d0                	cmp    %edx,%eax
  800a6c:	76 1c                	jbe    800a8a <file_set_size+0x5d>
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
       // LAB 5: Your code here.
       panic("file_block_walk not implemented");
  800a6e:	c7 44 24 08 b8 38 80 	movl   $0x8038b8,0x8(%esp)
  800a75:	00 
  800a76:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
  800a7d:	00 
  800a7e:	c7 04 24 c6 37 80 00 	movl   $0x8037c6,(%esp)
  800a85:	e8 29 0b 00 00       	call   8015b3 <_panic>
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800a8a:	83 fa 0a             	cmp    $0xa,%edx
  800a8d:	77 1c                	ja     800aab <file_set_size+0x7e>
  800a8f:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  800a95:	85 c0                	test   %eax,%eax
  800a97:	74 12                	je     800aab <file_set_size+0x7e>
		free_block(f->f_indirect);
  800a99:	89 04 24             	mov    %eax,(%esp)
  800a9c:	e8 8c fc ff ff       	call   80072d <free_block>
		f->f_indirect = 0;
  800aa1:	c7 83 b0 00 00 00 00 	movl   $0x0,0xb0(%ebx)
  800aa8:	00 00 00 
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800aab:	89 b3 80 00 00 00    	mov    %esi,0x80(%ebx)
	flush_block(f);
  800ab1:	89 1c 24             	mov    %ebx,(%esp)
  800ab4:	e8 5a f9 ff ff       	call   800413 <flush_block>
	return 0;
}
  800ab9:	b8 00 00 00 00       	mov    $0x0,%eax
  800abe:	83 c4 10             	add    $0x10,%esp
  800ac1:	5b                   	pop    %ebx
  800ac2:	5e                   	pop    %esi
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	57                   	push   %edi
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
  800acb:	83 ec 1c             	sub    $0x1c,%esp
  800ace:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad1:	8b 75 10             	mov    0x10(%ebp),%esi
  800ad4:	8b 7d 14             	mov    0x14(%ebp),%edi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800ad7:	8d 1c 37             	lea    (%edi,%esi,1),%ebx
  800ada:	3b 98 80 00 00 00    	cmp    0x80(%eax),%ebx
  800ae0:	76 10                	jbe    800af2 <file_write+0x2d>
		if ((r = file_set_size(f, offset + count)) < 0)
  800ae2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ae6:	89 04 24             	mov    %eax,(%esp)
  800ae9:	e8 3f ff ff ff       	call   800a2d <file_set_size>
  800aee:	85 c0                	test   %eax,%eax
  800af0:	78 22                	js     800b14 <file_write+0x4f>
			return r;

	for (pos = offset; pos < offset + count; ) {
  800af2:	39 df                	cmp    %ebx,%edi
  800af4:	73 1c                	jae    800b12 <file_write+0x4d>
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  800af6:	c7 44 24 08 98 38 80 	movl   $0x803898,0x8(%esp)
  800afd:	00 
  800afe:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  800b05:	00 
  800b06:	c7 04 24 c6 37 80 00 	movl   $0x8037c6,(%esp)
  800b0d:	e8 a1 0a 00 00       	call   8015b3 <_panic>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800b12:	89 f0                	mov    %esi,%eax
}
  800b14:	83 c4 1c             	add    $0x1c,%esp
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	53                   	push   %ebx
  800b20:	83 ec 14             	sub    $0x14,%esp
  800b23:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800b26:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  800b2c:	05 ff 0f 00 00       	add    $0xfff,%eax
  800b31:	3d ff 0f 00 00       	cmp    $0xfff,%eax
  800b36:	7e 1c                	jle    800b54 <file_flush+0x38>
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
       // LAB 5: Your code here.
       panic("file_block_walk not implemented");
  800b38:	c7 44 24 08 b8 38 80 	movl   $0x8038b8,0x8(%esp)
  800b3f:	00 
  800b40:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
  800b47:	00 
  800b48:	c7 04 24 c6 37 80 00 	movl   $0x8037c6,(%esp)
  800b4f:	e8 5f 0a 00 00       	call   8015b3 <_panic>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800b54:	89 1c 24             	mov    %ebx,(%esp)
  800b57:	e8 b7 f8 ff ff       	call   800413 <flush_block>
	if (f->f_indirect)
  800b5c:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  800b62:	85 c0                	test   %eax,%eax
  800b64:	74 10                	je     800b76 <file_flush+0x5a>
		flush_block(diskaddr(f->f_indirect));
  800b66:	89 04 24             	mov    %eax,(%esp)
  800b69:	e8 19 f8 ff ff       	call   800387 <diskaddr>
  800b6e:	89 04 24             	mov    %eax,(%esp)
  800b71:	e8 9d f8 ff ff       	call   800413 <flush_block>
}
  800b76:	83 c4 14             	add    $0x14,%esp
  800b79:	5b                   	pop    %ebx
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	53                   	push   %ebx
  800b80:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800b83:	bb 01 00 00 00       	mov    $0x1,%ebx
  800b88:	eb 13                	jmp    800b9d <fs_sync+0x21>
		flush_block(diskaddr(i));
  800b8a:	89 1c 24             	mov    %ebx,(%esp)
  800b8d:	e8 f5 f7 ff ff       	call   800387 <diskaddr>
  800b92:	89 04 24             	mov    %eax,(%esp)
  800b95:	e8 79 f8 ff ff       	call   800413 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800b9a:	83 c3 01             	add    $0x1,%ebx
  800b9d:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800ba2:	3b 58 04             	cmp    0x4(%eax),%ebx
  800ba5:	72 e3                	jb     800b8a <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  800ba7:	83 c4 14             	add    $0x14,%esp
  800baa:	5b                   	pop    %ebx
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    
  800bad:	66 90                	xchg   %ax,%ax
  800baf:	90                   	nop

00800bb0 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
	if (debug)
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
	return 0;
}
  800bb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
	panic("serve_write not implemented");
  800bc0:	c7 44 24 08 d8 38 80 	movl   $0x8038d8,0x8(%esp)
  800bc7:	00 
  800bc8:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
  800bcf:	00 
  800bd0:	c7 04 24 f4 38 80 00 	movl   $0x8038f4,(%esp)
  800bd7:	e8 d7 09 00 00       	call   8015b3 <_panic>

00800bdc <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  800be2:	e8 95 ff ff ff       	call   800b7c <fs_sync>
	return 0;
}
  800be7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bec:	c9                   	leave  
  800bed:	c3                   	ret    

00800bee <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	ba 60 50 80 00       	mov    $0x805060,%edx
	int i;
	uintptr_t va = FILEVA;
  800bf6:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  800bfb:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  800c00:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  800c02:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  800c05:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  800c0b:	83 c0 01             	add    $0x1,%eax
  800c0e:	83 c2 10             	add    $0x10,%edx
  800c11:	3d 00 04 00 00       	cmp    $0x400,%eax
  800c16:	75 e8                	jne    800c00 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
  800c1f:	83 ec 10             	sub    $0x10,%esp
  800c22:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  800c25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2a:	89 d8                	mov    %ebx,%eax
  800c2c:	c1 e0 04             	shl    $0x4,%eax
		switch (pageref(opentab[i].o_fd)) {
  800c2f:	8b 80 6c 50 80 00    	mov    0x80506c(%eax),%eax
  800c35:	89 04 24             	mov    %eax,(%esp)
  800c38:	e8 36 1c 00 00       	call   802873 <pageref>
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	74 07                	je     800c48 <openfile_alloc+0x2e>
  800c41:	83 f8 01             	cmp    $0x1,%eax
  800c44:	74 2b                	je     800c71 <openfile_alloc+0x57>
  800c46:	eb 62                	jmp    800caa <openfile_alloc+0x90>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  800c48:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800c4f:	00 
  800c50:	89 d8                	mov    %ebx,%eax
  800c52:	c1 e0 04             	shl    $0x4,%eax
  800c55:	8b 80 6c 50 80 00    	mov    0x80506c(%eax),%eax
  800c5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c66:	e8 d8 14 00 00       	call   802143 <sys_page_alloc>
  800c6b:	89 c2                	mov    %eax,%edx
  800c6d:	85 d2                	test   %edx,%edx
  800c6f:	78 4d                	js     800cbe <openfile_alloc+0xa4>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  800c71:	c1 e3 04             	shl    $0x4,%ebx
  800c74:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  800c7a:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  800c81:	04 00 00 
			*o = &opentab[i];
  800c84:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  800c86:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800c8d:	00 
  800c8e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c95:	00 
  800c96:	8b 83 6c 50 80 00    	mov    0x80506c(%ebx),%eax
  800c9c:	89 04 24             	mov    %eax,(%esp)
  800c9f:	e8 d3 11 00 00       	call   801e77 <memset>
			return (*o)->o_fileid;
  800ca4:	8b 06                	mov    (%esi),%eax
  800ca6:	8b 00                	mov    (%eax),%eax
  800ca8:	eb 14                	jmp    800cbe <openfile_alloc+0xa4>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  800caa:	83 c3 01             	add    $0x1,%ebx
  800cad:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  800cb3:	0f 85 71 ff ff ff    	jne    800c2a <openfile_alloc+0x10>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  800cb9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800cbe:	83 c4 10             	add    $0x10,%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	83 ec 1c             	sub    $0x1c,%esp
  800cce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  800cd1:	89 de                	mov    %ebx,%esi
  800cd3:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800cd9:	c1 e6 04             	shl    $0x4,%esi
  800cdc:	8d be 60 50 80 00    	lea    0x805060(%esi),%edi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  800ce2:	8b 86 6c 50 80 00    	mov    0x80506c(%esi),%eax
  800ce8:	89 04 24             	mov    %eax,(%esp)
  800ceb:	e8 83 1b 00 00       	call   802873 <pageref>
  800cf0:	83 f8 01             	cmp    $0x1,%eax
  800cf3:	7e 14                	jle    800d09 <openfile_lookup+0x44>
  800cf5:	39 9e 60 50 80 00    	cmp    %ebx,0x805060(%esi)
  800cfb:	75 13                	jne    800d10 <openfile_lookup+0x4b>
		return -E_INVAL;
	*po = o;
  800cfd:	8b 45 10             	mov    0x10(%ebp),%eax
  800d00:	89 38                	mov    %edi,(%eax)
	return 0;
  800d02:	b8 00 00 00 00       	mov    $0x0,%eax
  800d07:	eb 0c                	jmp    800d15 <openfile_lookup+0x50>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  800d09:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d0e:	eb 05                	jmp    800d15 <openfile_lookup+0x50>
  800d10:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  800d15:	83 c4 1c             	add    $0x1c,%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    

00800d1d <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	53                   	push   %ebx
  800d21:	83 ec 24             	sub    $0x24,%esp
  800d24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800d27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d2e:	8b 03                	mov    (%ebx),%eax
  800d30:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d34:	8b 45 08             	mov    0x8(%ebp),%eax
  800d37:	89 04 24             	mov    %eax,(%esp)
  800d3a:	e8 86 ff ff ff       	call   800cc5 <openfile_lookup>
  800d3f:	89 c2                	mov    %eax,%edx
  800d41:	85 d2                	test   %edx,%edx
  800d43:	78 15                	js     800d5a <serve_set_size+0x3d>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  800d45:	8b 43 04             	mov    0x4(%ebx),%eax
  800d48:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d4f:	8b 40 04             	mov    0x4(%eax),%eax
  800d52:	89 04 24             	mov    %eax,(%esp)
  800d55:	e8 d3 fc ff ff       	call   800a2d <file_set_size>
}
  800d5a:	83 c4 24             	add    $0x24,%esp
  800d5d:	5b                   	pop    %ebx
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	53                   	push   %ebx
  800d64:	83 ec 24             	sub    $0x24,%esp
  800d67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800d6a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d6d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d71:	8b 03                	mov    (%ebx),%eax
  800d73:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d77:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7a:	89 04 24             	mov    %eax,(%esp)
  800d7d:	e8 43 ff ff ff       	call   800cc5 <openfile_lookup>
  800d82:	89 c2                	mov    %eax,%edx
  800d84:	85 d2                	test   %edx,%edx
  800d86:	78 3f                	js     800dc7 <serve_stat+0x67>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  800d88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d8b:	8b 40 04             	mov    0x4(%eax),%eax
  800d8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d92:	89 1c 24             	mov    %ebx,(%esp)
  800d95:	e8 8d 0f 00 00       	call   801d27 <strcpy>
	ret->ret_size = o->o_file->f_size;
  800d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d9d:	8b 50 04             	mov    0x4(%eax),%edx
  800da0:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  800da6:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  800dac:	8b 40 04             	mov    0x4(%eax),%eax
  800daf:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800db6:	0f 94 c0             	sete   %al
  800db9:	0f b6 c0             	movzbl %al,%eax
  800dbc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800dc2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dc7:	83 c4 24             	add    $0x24,%esp
  800dca:	5b                   	pop    %ebx
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    

00800dcd <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800dd3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dd6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ddd:	8b 00                	mov    (%eax),%eax
  800ddf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800de3:	8b 45 08             	mov    0x8(%ebp),%eax
  800de6:	89 04 24             	mov    %eax,(%esp)
  800de9:	e8 d7 fe ff ff       	call   800cc5 <openfile_lookup>
  800dee:	89 c2                	mov    %eax,%edx
  800df0:	85 d2                	test   %edx,%edx
  800df2:	78 13                	js     800e07 <serve_flush+0x3a>
		return r;
	file_flush(o->o_file);
  800df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df7:	8b 40 04             	mov    0x4(%eax),%eax
  800dfa:	89 04 24             	mov    %eax,(%esp)
  800dfd:	e8 1a fd ff ff       	call   800b1c <file_flush>
	return 0;
  800e02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e07:	c9                   	leave  
  800e08:	c3                   	ret    

00800e09 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	53                   	push   %ebx
  800e0d:	81 ec 24 04 00 00    	sub    $0x424,%esp
  800e13:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  800e16:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  800e1d:	00 
  800e1e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e22:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800e28:	89 04 24             	mov    %eax,(%esp)
  800e2b:	e8 94 10 00 00       	call   801ec4 <memmove>
	path[MAXPATHLEN-1] = 0;
  800e30:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  800e34:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  800e3a:	89 04 24             	mov    %eax,(%esp)
  800e3d:	e8 d8 fd ff ff       	call   800c1a <openfile_alloc>
  800e42:	85 c0                	test   %eax,%eax
  800e44:	0f 88 f2 00 00 00    	js     800f3c <serve_open+0x133>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  800e4a:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  800e51:	74 34                	je     800e87 <serve_open+0x7e>
		if ((r = file_create(path, &f)) < 0) {
  800e53:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  800e59:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e5d:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800e63:	89 04 24             	mov    %eax,(%esp)
  800e66:	e8 77 fa ff ff       	call   8008e2 <file_create>
  800e6b:	89 c2                	mov    %eax,%edx
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	79 36                	jns    800ea7 <serve_open+0x9e>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  800e71:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  800e78:	0f 85 be 00 00 00    	jne    800f3c <serve_open+0x133>
  800e7e:	83 fa f3             	cmp    $0xfffffff3,%edx
  800e81:	0f 85 b5 00 00 00    	jne    800f3c <serve_open+0x133>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  800e87:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  800e8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e91:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800e97:	89 04 24             	mov    %eax,(%esp)
  800e9a:	e8 26 fb ff ff       	call   8009c5 <file_open>
  800e9f:	85 c0                	test   %eax,%eax
  800ea1:	0f 88 95 00 00 00    	js     800f3c <serve_open+0x133>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  800ea7:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  800eae:	74 1a                	je     800eca <serve_open+0xc1>
		if ((r = file_set_size(f, 0)) < 0) {
  800eb0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800eb7:	00 
  800eb8:	8b 85 f4 fb ff ff    	mov    -0x40c(%ebp),%eax
  800ebe:	89 04 24             	mov    %eax,(%esp)
  800ec1:	e8 67 fb ff ff       	call   800a2d <file_set_size>
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	78 72                	js     800f3c <serve_open+0x133>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  800eca:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  800ed0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ed4:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800eda:	89 04 24             	mov    %eax,(%esp)
  800edd:	e8 e3 fa ff ff       	call   8009c5 <file_open>
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	78 56                	js     800f3c <serve_open+0x133>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  800ee6:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  800eec:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  800ef2:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  800ef5:	8b 50 0c             	mov    0xc(%eax),%edx
  800ef8:	8b 08                	mov    (%eax),%ecx
  800efa:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  800efd:	8b 50 0c             	mov    0xc(%eax),%edx
  800f00:	8b 8b 00 04 00 00    	mov    0x400(%ebx),%ecx
  800f06:	83 e1 03             	and    $0x3,%ecx
  800f09:	89 4a 08             	mov    %ecx,0x8(%edx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  800f0c:	8b 40 0c             	mov    0xc(%eax),%eax
  800f0f:	8b 15 64 90 80 00    	mov    0x809064,%edx
  800f15:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  800f17:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  800f1d:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  800f23:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  800f26:	8b 50 0c             	mov    0xc(%eax),%edx
  800f29:	8b 45 10             	mov    0x10(%ebp),%eax
  800f2c:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  800f2e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f31:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  800f37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f3c:	81 c4 24 04 00 00    	add    $0x424,%esp
  800f42:	5b                   	pop    %ebx
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	56                   	push   %esi
  800f49:	53                   	push   %ebx
  800f4a:	83 ec 20             	sub    $0x20,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  800f4d:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  800f50:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  800f53:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  800f5a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f5e:	a1 44 50 80 00       	mov    0x805044,%eax
  800f63:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f67:	89 34 24             	mov    %esi,(%esp)
  800f6a:	e8 11 15 00 00       	call   802480 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  800f6f:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  800f73:	75 15                	jne    800f8a <serve+0x45>
			cprintf("Invalid request from %08x: no argument page\n",
  800f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f78:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f7c:	c7 04 24 20 39 80 00 	movl   $0x803920,(%esp)
  800f83:	e8 24 07 00 00       	call   8016ac <cprintf>
				whom);
			continue; // just leave it hanging...
  800f88:	eb c9                	jmp    800f53 <serve+0xe>
		}

		pg = NULL;
  800f8a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  800f91:	83 f8 01             	cmp    $0x1,%eax
  800f94:	75 21                	jne    800fb7 <serve+0x72>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  800f96:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f9a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f9d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fa1:	a1 44 50 80 00       	mov    0x805044,%eax
  800fa6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fad:	89 04 24             	mov    %eax,(%esp)
  800fb0:	e8 54 fe ff ff       	call   800e09 <serve_open>
  800fb5:	eb 3f                	jmp    800ff6 <serve+0xb1>
		} else if (req < NHANDLERS && handlers[req]) {
  800fb7:	83 f8 08             	cmp    $0x8,%eax
  800fba:	77 1e                	ja     800fda <serve+0x95>
  800fbc:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  800fc3:	85 d2                	test   %edx,%edx
  800fc5:	74 13                	je     800fda <serve+0x95>
			r = handlers[req](whom, fsreq);
  800fc7:	a1 44 50 80 00       	mov    0x805044,%eax
  800fcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd3:	89 04 24             	mov    %eax,(%esp)
  800fd6:	ff d2                	call   *%edx
  800fd8:	eb 1c                	jmp    800ff6 <serve+0xb1>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  800fda:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800fdd:	89 54 24 08          	mov    %edx,0x8(%esp)
  800fe1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe5:	c7 04 24 50 39 80 00 	movl   $0x803950,(%esp)
  800fec:	e8 bb 06 00 00       	call   8016ac <cprintf>
			r = -E_INVAL;
  800ff1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  800ff6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ff9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ffd:	8b 55 ec             	mov    -0x14(%ebp),%edx
  801000:	89 54 24 08          	mov    %edx,0x8(%esp)
  801004:	89 44 24 04          	mov    %eax,0x4(%esp)
  801008:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100b:	89 04 24             	mov    %eax,(%esp)
  80100e:	e8 0b 15 00 00       	call   80251e <ipc_send>
		sys_page_unmap(0, fsreq);
  801013:	a1 44 50 80 00       	mov    0x805044,%eax
  801018:	89 44 24 04          	mov    %eax,0x4(%esp)
  80101c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801023:	e8 c2 11 00 00       	call   8021ea <sys_page_unmap>
  801028:	e9 26 ff ff ff       	jmp    800f53 <serve+0xe>

0080102d <umain>:
	}
}

void
umain(int argc, char **argv)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801033:	c7 05 60 90 80 00 fe 	movl   $0x8038fe,0x809060
  80103a:	38 80 00 
	cprintf("FS is running\n");
  80103d:	c7 04 24 01 39 80 00 	movl   $0x803901,(%esp)
  801044:	e8 63 06 00 00       	call   8016ac <cprintf>
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  801049:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  80104e:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801053:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801055:	c7 04 24 10 39 80 00 	movl   $0x803910,(%esp)
  80105c:	e8 4b 06 00 00       	call   8016ac <cprintf>

	serve_init();
  801061:	e8 88 fb ff ff       	call   800bee <serve_init>
	fs_init();
  801066:	e8 f9 f7 ff ff       	call   800864 <fs_init>
        fs_test();
  80106b:	90                   	nop
  80106c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801070:	e8 05 00 00 00       	call   80107a <fs_test>
	serve();
  801075:	e8 cb fe ff ff       	call   800f45 <serve>

0080107a <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  80107a:	55                   	push   %ebp
  80107b:	89 e5                	mov    %esp,%ebp
  80107d:	53                   	push   %ebx
  80107e:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  801081:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801088:	00 
  801089:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  801090:	00 
  801091:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801098:	e8 a6 10 00 00       	call   802143 <sys_page_alloc>
  80109d:	85 c0                	test   %eax,%eax
  80109f:	79 20                	jns    8010c1 <fs_test+0x47>
		panic("sys_page_alloc: %e", r);
  8010a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010a5:	c7 44 24 08 73 39 80 	movl   $0x803973,0x8(%esp)
  8010ac:	00 
  8010ad:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  8010b4:	00 
  8010b5:	c7 04 24 86 39 80 00 	movl   $0x803986,(%esp)
  8010bc:	e8 f2 04 00 00       	call   8015b3 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  8010c1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8010c8:	00 
  8010c9:	a1 04 a0 80 00       	mov    0x80a004,%eax
  8010ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d2:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  8010d9:	e8 e6 0d 00 00       	call   801ec4 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8010de:	e8 8e f6 ff ff       	call   800771 <alloc_block>
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	79 20                	jns    801107 <fs_test+0x8d>
		panic("alloc_block: %e", r);
  8010e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010eb:	c7 44 24 08 90 39 80 	movl   $0x803990,0x8(%esp)
  8010f2:	00 
  8010f3:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  8010fa:	00 
  8010fb:	c7 04 24 86 39 80 00 	movl   $0x803986,(%esp)
  801102:	e8 ac 04 00 00       	call   8015b3 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  801107:	8d 58 1f             	lea    0x1f(%eax),%ebx
  80110a:	85 c0                	test   %eax,%eax
  80110c:	0f 49 d8             	cmovns %eax,%ebx
  80110f:	c1 fb 05             	sar    $0x5,%ebx
  801112:	99                   	cltd   
  801113:	c1 ea 1b             	shr    $0x1b,%edx
  801116:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  801119:	83 e1 1f             	and    $0x1f,%ecx
  80111c:	29 d1                	sub    %edx,%ecx
  80111e:	ba 01 00 00 00       	mov    $0x1,%edx
  801123:	d3 e2                	shl    %cl,%edx
  801125:	85 14 9d 00 10 00 00 	test   %edx,0x1000(,%ebx,4)
  80112c:	75 24                	jne    801152 <fs_test+0xd8>
  80112e:	c7 44 24 0c a0 39 80 	movl   $0x8039a0,0xc(%esp)
  801135:	00 
  801136:	c7 44 24 08 9d 36 80 	movl   $0x80369d,0x8(%esp)
  80113d:	00 
  80113e:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  801145:	00 
  801146:	c7 04 24 86 39 80 00 	movl   $0x803986,(%esp)
  80114d:	e8 61 04 00 00       	call   8015b3 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801152:	a1 04 a0 80 00       	mov    0x80a004,%eax
  801157:	85 14 98             	test   %edx,(%eax,%ebx,4)
  80115a:	74 24                	je     801180 <fs_test+0x106>
  80115c:	c7 44 24 0c 18 3b 80 	movl   $0x803b18,0xc(%esp)
  801163:	00 
  801164:	c7 44 24 08 9d 36 80 	movl   $0x80369d,0x8(%esp)
  80116b:	00 
  80116c:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  801173:	00 
  801174:	c7 04 24 86 39 80 00 	movl   $0x803986,(%esp)
  80117b:	e8 33 04 00 00       	call   8015b3 <_panic>
	cprintf("alloc_block is good\n");
  801180:	c7 04 24 bb 39 80 00 	movl   $0x8039bb,(%esp)
  801187:	e8 20 05 00 00       	call   8016ac <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  80118c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801193:	c7 04 24 d0 39 80 00 	movl   $0x8039d0,(%esp)
  80119a:	e8 26 f8 ff ff       	call   8009c5 <file_open>
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	79 25                	jns    8011c8 <fs_test+0x14e>
  8011a3:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8011a6:	74 40                	je     8011e8 <fs_test+0x16e>
		panic("file_open /not-found: %e", r);
  8011a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ac:	c7 44 24 08 db 39 80 	movl   $0x8039db,0x8(%esp)
  8011b3:	00 
  8011b4:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  8011bb:	00 
  8011bc:	c7 04 24 86 39 80 00 	movl   $0x803986,(%esp)
  8011c3:	e8 eb 03 00 00       	call   8015b3 <_panic>
	else if (r == 0)
  8011c8:	85 c0                	test   %eax,%eax
  8011ca:	75 1c                	jne    8011e8 <fs_test+0x16e>
		panic("file_open /not-found succeeded!");
  8011cc:	c7 44 24 08 38 3b 80 	movl   $0x803b38,0x8(%esp)
  8011d3:	00 
  8011d4:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8011db:	00 
  8011dc:	c7 04 24 86 39 80 00 	movl   $0x803986,(%esp)
  8011e3:	e8 cb 03 00 00       	call   8015b3 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  8011e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ef:	c7 04 24 f4 39 80 00 	movl   $0x8039f4,(%esp)
  8011f6:	e8 ca f7 ff ff       	call   8009c5 <file_open>
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	79 20                	jns    80121f <fs_test+0x1a5>
		panic("file_open /newmotd: %e", r);
  8011ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801203:	c7 44 24 08 fd 39 80 	movl   $0x8039fd,0x8(%esp)
  80120a:	00 
  80120b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801212:	00 
  801213:	c7 04 24 86 39 80 00 	movl   $0x803986,(%esp)
  80121a:	e8 94 03 00 00       	call   8015b3 <_panic>
	cprintf("file_open is good\n");
  80121f:	c7 04 24 14 3a 80 00 	movl   $0x803a14,(%esp)
  801226:	e8 81 04 00 00       	call   8016ac <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  80122b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80122e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801232:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801239:	00 
  80123a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80123d:	89 04 24             	mov    %eax,(%esp)
  801240:	e8 7b f6 ff ff       	call   8008c0 <file_get_block>
  801245:	85 c0                	test   %eax,%eax
  801247:	79 20                	jns    801269 <fs_test+0x1ef>
		panic("file_get_block: %e", r);
  801249:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80124d:	c7 44 24 08 27 3a 80 	movl   $0x803a27,0x8(%esp)
  801254:	00 
  801255:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80125c:	00 
  80125d:	c7 04 24 86 39 80 00 	movl   $0x803986,(%esp)
  801264:	e8 4a 03 00 00       	call   8015b3 <_panic>
	if (strcmp(blk, msg) != 0)
  801269:	c7 44 24 04 58 3b 80 	movl   $0x803b58,0x4(%esp)
  801270:	00 
  801271:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801274:	89 04 24             	mov    %eax,(%esp)
  801277:	e8 60 0b 00 00       	call   801ddc <strcmp>
  80127c:	85 c0                	test   %eax,%eax
  80127e:	74 1c                	je     80129c <fs_test+0x222>
		panic("file_get_block returned wrong data");
  801280:	c7 44 24 08 80 3b 80 	movl   $0x803b80,0x8(%esp)
  801287:	00 
  801288:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  80128f:	00 
  801290:	c7 04 24 86 39 80 00 	movl   $0x803986,(%esp)
  801297:	e8 17 03 00 00       	call   8015b3 <_panic>
	cprintf("file_get_block is good\n");
  80129c:	c7 04 24 3a 3a 80 00 	movl   $0x803a3a,(%esp)
  8012a3:	e8 04 04 00 00       	call   8016ac <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  8012a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ab:	0f b6 10             	movzbl (%eax),%edx
  8012ae:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8012b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b3:	c1 e8 0c             	shr    $0xc,%eax
  8012b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012bd:	a8 40                	test   $0x40,%al
  8012bf:	75 24                	jne    8012e5 <fs_test+0x26b>
  8012c1:	c7 44 24 0c 53 3a 80 	movl   $0x803a53,0xc(%esp)
  8012c8:	00 
  8012c9:	c7 44 24 08 9d 36 80 	movl   $0x80369d,0x8(%esp)
  8012d0:	00 
  8012d1:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8012d8:	00 
  8012d9:	c7 04 24 86 39 80 00 	movl   $0x803986,(%esp)
  8012e0:	e8 ce 02 00 00       	call   8015b3 <_panic>
	file_flush(f);
  8012e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e8:	89 04 24             	mov    %eax,(%esp)
  8012eb:	e8 2c f8 ff ff       	call   800b1c <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8012f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f3:	c1 e8 0c             	shr    $0xc,%eax
  8012f6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012fd:	a8 40                	test   $0x40,%al
  8012ff:	74 24                	je     801325 <fs_test+0x2ab>
  801301:	c7 44 24 0c 52 3a 80 	movl   $0x803a52,0xc(%esp)
  801308:	00 
  801309:	c7 44 24 08 9d 36 80 	movl   $0x80369d,0x8(%esp)
  801310:	00 
  801311:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  801318:	00 
  801319:	c7 04 24 86 39 80 00 	movl   $0x803986,(%esp)
  801320:	e8 8e 02 00 00       	call   8015b3 <_panic>
	cprintf("file_flush is good\n");
  801325:	c7 04 24 6e 3a 80 00 	movl   $0x803a6e,(%esp)
  80132c:	e8 7b 03 00 00       	call   8016ac <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801331:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801338:	00 
  801339:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133c:	89 04 24             	mov    %eax,(%esp)
  80133f:	e8 e9 f6 ff ff       	call   800a2d <file_set_size>
  801344:	85 c0                	test   %eax,%eax
  801346:	79 20                	jns    801368 <fs_test+0x2ee>
		panic("file_set_size: %e", r);
  801348:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80134c:	c7 44 24 08 82 3a 80 	movl   $0x803a82,0x8(%esp)
  801353:	00 
  801354:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  80135b:	00 
  80135c:	c7 04 24 86 39 80 00 	movl   $0x803986,(%esp)
  801363:	e8 4b 02 00 00       	call   8015b3 <_panic>
	assert(f->f_direct[0] == 0);
  801368:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136b:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801372:	74 24                	je     801398 <fs_test+0x31e>
  801374:	c7 44 24 0c 94 3a 80 	movl   $0x803a94,0xc(%esp)
  80137b:	00 
  80137c:	c7 44 24 08 9d 36 80 	movl   $0x80369d,0x8(%esp)
  801383:	00 
  801384:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  80138b:	00 
  80138c:	c7 04 24 86 39 80 00 	movl   $0x803986,(%esp)
  801393:	e8 1b 02 00 00       	call   8015b3 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801398:	c1 e8 0c             	shr    $0xc,%eax
  80139b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a2:	a8 40                	test   $0x40,%al
  8013a4:	74 24                	je     8013ca <fs_test+0x350>
  8013a6:	c7 44 24 0c a8 3a 80 	movl   $0x803aa8,0xc(%esp)
  8013ad:	00 
  8013ae:	c7 44 24 08 9d 36 80 	movl   $0x80369d,0x8(%esp)
  8013b5:	00 
  8013b6:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  8013bd:	00 
  8013be:	c7 04 24 86 39 80 00 	movl   $0x803986,(%esp)
  8013c5:	e8 e9 01 00 00       	call   8015b3 <_panic>
	cprintf("file_truncate is good\n");
  8013ca:	c7 04 24 c2 3a 80 00 	movl   $0x803ac2,(%esp)
  8013d1:	e8 d6 02 00 00       	call   8016ac <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8013d6:	c7 04 24 58 3b 80 00 	movl   $0x803b58,(%esp)
  8013dd:	e8 0e 09 00 00       	call   801cf0 <strlen>
  8013e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013e9:	89 04 24             	mov    %eax,(%esp)
  8013ec:	e8 3c f6 ff ff       	call   800a2d <file_set_size>
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	79 20                	jns    801415 <fs_test+0x39b>
		panic("file_set_size 2: %e", r);
  8013f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013f9:	c7 44 24 08 d9 3a 80 	movl   $0x803ad9,0x8(%esp)
  801400:	00 
  801401:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801408:	00 
  801409:	c7 04 24 86 39 80 00 	movl   $0x803986,(%esp)
  801410:	e8 9e 01 00 00       	call   8015b3 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801415:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801418:	89 c2                	mov    %eax,%edx
  80141a:	c1 ea 0c             	shr    $0xc,%edx
  80141d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801424:	f6 c2 40             	test   $0x40,%dl
  801427:	74 24                	je     80144d <fs_test+0x3d3>
  801429:	c7 44 24 0c a8 3a 80 	movl   $0x803aa8,0xc(%esp)
  801430:	00 
  801431:	c7 44 24 08 9d 36 80 	movl   $0x80369d,0x8(%esp)
  801438:	00 
  801439:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  801440:	00 
  801441:	c7 04 24 86 39 80 00 	movl   $0x803986,(%esp)
  801448:	e8 66 01 00 00       	call   8015b3 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  80144d:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801450:	89 54 24 08          	mov    %edx,0x8(%esp)
  801454:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80145b:	00 
  80145c:	89 04 24             	mov    %eax,(%esp)
  80145f:	e8 5c f4 ff ff       	call   8008c0 <file_get_block>
  801464:	85 c0                	test   %eax,%eax
  801466:	79 20                	jns    801488 <fs_test+0x40e>
		panic("file_get_block 2: %e", r);
  801468:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80146c:	c7 44 24 08 ed 3a 80 	movl   $0x803aed,0x8(%esp)
  801473:	00 
  801474:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  80147b:	00 
  80147c:	c7 04 24 86 39 80 00 	movl   $0x803986,(%esp)
  801483:	e8 2b 01 00 00       	call   8015b3 <_panic>
	strcpy(blk, msg);
  801488:	c7 44 24 04 58 3b 80 	movl   $0x803b58,0x4(%esp)
  80148f:	00 
  801490:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801493:	89 04 24             	mov    %eax,(%esp)
  801496:	e8 8c 08 00 00       	call   801d27 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  80149b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149e:	c1 e8 0c             	shr    $0xc,%eax
  8014a1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014a8:	a8 40                	test   $0x40,%al
  8014aa:	75 24                	jne    8014d0 <fs_test+0x456>
  8014ac:	c7 44 24 0c 53 3a 80 	movl   $0x803a53,0xc(%esp)
  8014b3:	00 
  8014b4:	c7 44 24 08 9d 36 80 	movl   $0x80369d,0x8(%esp)
  8014bb:	00 
  8014bc:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8014c3:	00 
  8014c4:	c7 04 24 86 39 80 00 	movl   $0x803986,(%esp)
  8014cb:	e8 e3 00 00 00       	call   8015b3 <_panic>
	file_flush(f);
  8014d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d3:	89 04 24             	mov    %eax,(%esp)
  8014d6:	e8 41 f6 ff ff       	call   800b1c <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8014db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014de:	c1 e8 0c             	shr    $0xc,%eax
  8014e1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014e8:	a8 40                	test   $0x40,%al
  8014ea:	74 24                	je     801510 <fs_test+0x496>
  8014ec:	c7 44 24 0c 52 3a 80 	movl   $0x803a52,0xc(%esp)
  8014f3:	00 
  8014f4:	c7 44 24 08 9d 36 80 	movl   $0x80369d,0x8(%esp)
  8014fb:	00 
  8014fc:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801503:	00 
  801504:	c7 04 24 86 39 80 00 	movl   $0x803986,(%esp)
  80150b:	e8 a3 00 00 00       	call   8015b3 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801510:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801513:	c1 e8 0c             	shr    $0xc,%eax
  801516:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80151d:	a8 40                	test   $0x40,%al
  80151f:	74 24                	je     801545 <fs_test+0x4cb>
  801521:	c7 44 24 0c a8 3a 80 	movl   $0x803aa8,0xc(%esp)
  801528:	00 
  801529:	c7 44 24 08 9d 36 80 	movl   $0x80369d,0x8(%esp)
  801530:	00 
  801531:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801538:	00 
  801539:	c7 04 24 86 39 80 00 	movl   $0x803986,(%esp)
  801540:	e8 6e 00 00 00       	call   8015b3 <_panic>
	cprintf("file rewrite is good\n");
  801545:	c7 04 24 02 3b 80 00 	movl   $0x803b02,(%esp)
  80154c:	e8 5b 01 00 00       	call   8016ac <cprintf>
}
  801551:	83 c4 24             	add    $0x24,%esp
  801554:	5b                   	pop    %ebx
  801555:	5d                   	pop    %ebp
  801556:	c3                   	ret    

00801557 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	56                   	push   %esi
  80155b:	53                   	push   %ebx
  80155c:	83 ec 10             	sub    $0x10,%esp
  80155f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801562:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  801565:	e8 9b 0b 00 00       	call   802105 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80156a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80156f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801572:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801577:	a3 0c a0 80 00       	mov    %eax,0x80a00c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80157c:	85 db                	test   %ebx,%ebx
  80157e:	7e 07                	jle    801587 <libmain+0x30>
		binaryname = argv[0];
  801580:	8b 06                	mov    (%esi),%eax
  801582:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801587:	89 74 24 04          	mov    %esi,0x4(%esp)
  80158b:	89 1c 24             	mov    %ebx,(%esp)
  80158e:	e8 9a fa ff ff       	call   80102d <umain>

	// exit gracefully
	exit();
  801593:	e8 07 00 00 00       	call   80159f <exit>
}
  801598:	83 c4 10             	add    $0x10,%esp
  80159b:	5b                   	pop    %ebx
  80159c:	5e                   	pop    %esi
  80159d:	5d                   	pop    %ebp
  80159e:	c3                   	ret    

0080159f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80159f:	55                   	push   %ebp
  8015a0:	89 e5                	mov    %esp,%ebp
  8015a2:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8015a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ac:	e8 02 0b 00 00       	call   8020b3 <sys_env_destroy>
}
  8015b1:	c9                   	leave  
  8015b2:	c3                   	ret    

008015b3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	56                   	push   %esi
  8015b7:	53                   	push   %ebx
  8015b8:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8015bb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8015be:	8b 35 60 90 80 00    	mov    0x809060,%esi
  8015c4:	e8 3c 0b 00 00       	call   802105 <sys_getenvid>
  8015c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015cc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8015d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8015d3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8015d7:	89 74 24 08          	mov    %esi,0x8(%esp)
  8015db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015df:	c7 04 24 b0 3b 80 00 	movl   $0x803bb0,(%esp)
  8015e6:	e8 c1 00 00 00       	call   8016ac <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8015f2:	89 04 24             	mov    %eax,(%esp)
  8015f5:	e8 51 00 00 00       	call   80164b <vcprintf>
	cprintf("\n");
  8015fa:	c7 04 24 a7 37 80 00 	movl   $0x8037a7,(%esp)
  801601:	e8 a6 00 00 00       	call   8016ac <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801606:	cc                   	int3   
  801607:	eb fd                	jmp    801606 <_panic+0x53>

00801609 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801609:	55                   	push   %ebp
  80160a:	89 e5                	mov    %esp,%ebp
  80160c:	53                   	push   %ebx
  80160d:	83 ec 14             	sub    $0x14,%esp
  801610:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801613:	8b 13                	mov    (%ebx),%edx
  801615:	8d 42 01             	lea    0x1(%edx),%eax
  801618:	89 03                	mov    %eax,(%ebx)
  80161a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80161d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801621:	3d ff 00 00 00       	cmp    $0xff,%eax
  801626:	75 19                	jne    801641 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801628:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80162f:	00 
  801630:	8d 43 08             	lea    0x8(%ebx),%eax
  801633:	89 04 24             	mov    %eax,(%esp)
  801636:	e8 3b 0a 00 00       	call   802076 <sys_cputs>
		b->idx = 0;
  80163b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801641:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801645:	83 c4 14             	add    $0x14,%esp
  801648:	5b                   	pop    %ebx
  801649:	5d                   	pop    %ebp
  80164a:	c3                   	ret    

0080164b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801654:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80165b:	00 00 00 
	b.cnt = 0;
  80165e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801665:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801668:	8b 45 0c             	mov    0xc(%ebp),%eax
  80166b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80166f:	8b 45 08             	mov    0x8(%ebp),%eax
  801672:	89 44 24 08          	mov    %eax,0x8(%esp)
  801676:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80167c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801680:	c7 04 24 09 16 80 00 	movl   $0x801609,(%esp)
  801687:	e8 78 01 00 00       	call   801804 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80168c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801692:	89 44 24 04          	mov    %eax,0x4(%esp)
  801696:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80169c:	89 04 24             	mov    %eax,(%esp)
  80169f:	e8 d2 09 00 00       	call   802076 <sys_cputs>

	return b.cnt;
}
  8016a4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8016aa:	c9                   	leave  
  8016ab:	c3                   	ret    

008016ac <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016b2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8016b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bc:	89 04 24             	mov    %eax,(%esp)
  8016bf:	e8 87 ff ff ff       	call   80164b <vcprintf>
	va_end(ap);

	return cnt;
}
  8016c4:	c9                   	leave  
  8016c5:	c3                   	ret    
  8016c6:	66 90                	xchg   %ax,%ax
  8016c8:	66 90                	xchg   %ax,%ax
  8016ca:	66 90                	xchg   %ax,%ax
  8016cc:	66 90                	xchg   %ax,%ax
  8016ce:	66 90                	xchg   %ax,%ax

008016d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	57                   	push   %edi
  8016d4:	56                   	push   %esi
  8016d5:	53                   	push   %ebx
  8016d6:	83 ec 3c             	sub    $0x3c,%esp
  8016d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016dc:	89 d7                	mov    %edx,%edi
  8016de:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e7:	89 c3                	mov    %eax,%ebx
  8016e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8016ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8016ef:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8016fd:	39 d9                	cmp    %ebx,%ecx
  8016ff:	72 05                	jb     801706 <printnum+0x36>
  801701:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  801704:	77 69                	ja     80176f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801706:	8b 4d 18             	mov    0x18(%ebp),%ecx
  801709:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80170d:	83 ee 01             	sub    $0x1,%esi
  801710:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801714:	89 44 24 08          	mov    %eax,0x8(%esp)
  801718:	8b 44 24 08          	mov    0x8(%esp),%eax
  80171c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801720:	89 c3                	mov    %eax,%ebx
  801722:	89 d6                	mov    %edx,%esi
  801724:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801727:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80172a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80172e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801732:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801735:	89 04 24             	mov    %eax,(%esp)
  801738:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80173b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173f:	e8 7c 1c 00 00       	call   8033c0 <__udivdi3>
  801744:	89 d9                	mov    %ebx,%ecx
  801746:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80174a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80174e:	89 04 24             	mov    %eax,(%esp)
  801751:	89 54 24 04          	mov    %edx,0x4(%esp)
  801755:	89 fa                	mov    %edi,%edx
  801757:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80175a:	e8 71 ff ff ff       	call   8016d0 <printnum>
  80175f:	eb 1b                	jmp    80177c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801761:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801765:	8b 45 18             	mov    0x18(%ebp),%eax
  801768:	89 04 24             	mov    %eax,(%esp)
  80176b:	ff d3                	call   *%ebx
  80176d:	eb 03                	jmp    801772 <printnum+0xa2>
  80176f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801772:	83 ee 01             	sub    $0x1,%esi
  801775:	85 f6                	test   %esi,%esi
  801777:	7f e8                	jg     801761 <printnum+0x91>
  801779:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80177c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801780:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801784:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801787:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80178a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80178e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801792:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801795:	89 04 24             	mov    %eax,(%esp)
  801798:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80179b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179f:	e8 4c 1d 00 00       	call   8034f0 <__umoddi3>
  8017a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017a8:	0f be 80 d3 3b 80 00 	movsbl 0x803bd3(%eax),%eax
  8017af:	89 04 24             	mov    %eax,(%esp)
  8017b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017b5:	ff d0                	call   *%eax
}
  8017b7:	83 c4 3c             	add    $0x3c,%esp
  8017ba:	5b                   	pop    %ebx
  8017bb:	5e                   	pop    %esi
  8017bc:	5f                   	pop    %edi
  8017bd:	5d                   	pop    %ebp
  8017be:	c3                   	ret    

008017bf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8017c5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8017c9:	8b 10                	mov    (%eax),%edx
  8017cb:	3b 50 04             	cmp    0x4(%eax),%edx
  8017ce:	73 0a                	jae    8017da <sprintputch+0x1b>
		*b->buf++ = ch;
  8017d0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8017d3:	89 08                	mov    %ecx,(%eax)
  8017d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d8:	88 02                	mov    %al,(%edx)
}
  8017da:	5d                   	pop    %ebp
  8017db:	c3                   	ret    

008017dc <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017dc:	55                   	push   %ebp
  8017dd:	89 e5                	mov    %esp,%ebp
  8017df:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8017e2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8017ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fa:	89 04 24             	mov    %eax,(%esp)
  8017fd:	e8 02 00 00 00       	call   801804 <vprintfmt>
	va_end(ap);
}
  801802:	c9                   	leave  
  801803:	c3                   	ret    

00801804 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	57                   	push   %edi
  801808:	56                   	push   %esi
  801809:	53                   	push   %ebx
  80180a:	83 ec 3c             	sub    $0x3c,%esp
  80180d:	8b 75 08             	mov    0x8(%ebp),%esi
  801810:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801813:	8b 7d 10             	mov    0x10(%ebp),%edi
  801816:	eb 11                	jmp    801829 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801818:	85 c0                	test   %eax,%eax
  80181a:	0f 84 48 04 00 00    	je     801c68 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  801820:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801824:	89 04 24             	mov    %eax,(%esp)
  801827:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801829:	83 c7 01             	add    $0x1,%edi
  80182c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801830:	83 f8 25             	cmp    $0x25,%eax
  801833:	75 e3                	jne    801818 <vprintfmt+0x14>
  801835:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801839:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801840:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801847:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80184e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801853:	eb 1f                	jmp    801874 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801855:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801858:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80185c:	eb 16                	jmp    801874 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80185e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801861:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801865:	eb 0d                	jmp    801874 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801867:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80186a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80186d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801874:	8d 47 01             	lea    0x1(%edi),%eax
  801877:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80187a:	0f b6 17             	movzbl (%edi),%edx
  80187d:	0f b6 c2             	movzbl %dl,%eax
  801880:	83 ea 23             	sub    $0x23,%edx
  801883:	80 fa 55             	cmp    $0x55,%dl
  801886:	0f 87 bf 03 00 00    	ja     801c4b <vprintfmt+0x447>
  80188c:	0f b6 d2             	movzbl %dl,%edx
  80188f:	ff 24 95 20 3d 80 00 	jmp    *0x803d20(,%edx,4)
  801896:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801899:	ba 00 00 00 00       	mov    $0x0,%edx
  80189e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8018a1:	8d 14 92             	lea    (%edx,%edx,4),%edx
  8018a4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  8018a8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  8018ab:	8d 48 d0             	lea    -0x30(%eax),%ecx
  8018ae:	83 f9 09             	cmp    $0x9,%ecx
  8018b1:	77 3c                	ja     8018ef <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8018b3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8018b6:	eb e9                	jmp    8018a1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8018b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8018bb:	8b 00                	mov    (%eax),%eax
  8018bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8018c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8018c3:	8d 40 04             	lea    0x4(%eax),%eax
  8018c6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8018cc:	eb 27                	jmp    8018f5 <vprintfmt+0xf1>
  8018ce:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8018d1:	85 d2                	test   %edx,%edx
  8018d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d8:	0f 49 c2             	cmovns %edx,%eax
  8018db:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018e1:	eb 91                	jmp    801874 <vprintfmt+0x70>
  8018e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8018e6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8018ed:	eb 85                	jmp    801874 <vprintfmt+0x70>
  8018ef:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8018f2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8018f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018f9:	0f 89 75 ff ff ff    	jns    801874 <vprintfmt+0x70>
  8018ff:	e9 63 ff ff ff       	jmp    801867 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801904:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801907:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80190a:	e9 65 ff ff ff       	jmp    801874 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80190f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801912:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  801916:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80191a:	8b 00                	mov    (%eax),%eax
  80191c:	89 04 24             	mov    %eax,(%esp)
  80191f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801921:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801924:	e9 00 ff ff ff       	jmp    801829 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801929:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80192c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  801930:	8b 00                	mov    (%eax),%eax
  801932:	99                   	cltd   
  801933:	31 d0                	xor    %edx,%eax
  801935:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801937:	83 f8 0f             	cmp    $0xf,%eax
  80193a:	7f 0b                	jg     801947 <vprintfmt+0x143>
  80193c:	8b 14 85 80 3e 80 00 	mov    0x803e80(,%eax,4),%edx
  801943:	85 d2                	test   %edx,%edx
  801945:	75 20                	jne    801967 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  801947:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80194b:	c7 44 24 08 eb 3b 80 	movl   $0x803beb,0x8(%esp)
  801952:	00 
  801953:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801957:	89 34 24             	mov    %esi,(%esp)
  80195a:	e8 7d fe ff ff       	call   8017dc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80195f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801962:	e9 c2 fe ff ff       	jmp    801829 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  801967:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80196b:	c7 44 24 08 af 36 80 	movl   $0x8036af,0x8(%esp)
  801972:	00 
  801973:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801977:	89 34 24             	mov    %esi,(%esp)
  80197a:	e8 5d fe ff ff       	call   8017dc <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80197f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801982:	e9 a2 fe ff ff       	jmp    801829 <vprintfmt+0x25>
  801987:	8b 45 14             	mov    0x14(%ebp),%eax
  80198a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80198d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801990:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801993:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  801997:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801999:	85 ff                	test   %edi,%edi
  80199b:	b8 e4 3b 80 00       	mov    $0x803be4,%eax
  8019a0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8019a3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8019a7:	0f 84 92 00 00 00    	je     801a3f <vprintfmt+0x23b>
  8019ad:	85 c9                	test   %ecx,%ecx
  8019af:	0f 8e 98 00 00 00    	jle    801a4d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  8019b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019b9:	89 3c 24             	mov    %edi,(%esp)
  8019bc:	e8 47 03 00 00       	call   801d08 <strnlen>
  8019c1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8019c4:	29 c1                	sub    %eax,%ecx
  8019c6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  8019c9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8019cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019d0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8019d3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019d5:	eb 0f                	jmp    8019e6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8019d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019de:	89 04 24             	mov    %eax,(%esp)
  8019e1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019e3:	83 ef 01             	sub    $0x1,%edi
  8019e6:	85 ff                	test   %edi,%edi
  8019e8:	7f ed                	jg     8019d7 <vprintfmt+0x1d3>
  8019ea:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8019ed:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8019f0:	85 c9                	test   %ecx,%ecx
  8019f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f7:	0f 49 c1             	cmovns %ecx,%eax
  8019fa:	29 c1                	sub    %eax,%ecx
  8019fc:	89 75 08             	mov    %esi,0x8(%ebp)
  8019ff:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a02:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a05:	89 cb                	mov    %ecx,%ebx
  801a07:	eb 50                	jmp    801a59 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801a09:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801a0d:	74 1e                	je     801a2d <vprintfmt+0x229>
  801a0f:	0f be d2             	movsbl %dl,%edx
  801a12:	83 ea 20             	sub    $0x20,%edx
  801a15:	83 fa 5e             	cmp    $0x5e,%edx
  801a18:	76 13                	jbe    801a2d <vprintfmt+0x229>
					putch('?', putdat);
  801a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a21:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801a28:	ff 55 08             	call   *0x8(%ebp)
  801a2b:	eb 0d                	jmp    801a3a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  801a2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a30:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a34:	89 04 24             	mov    %eax,(%esp)
  801a37:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a3a:	83 eb 01             	sub    $0x1,%ebx
  801a3d:	eb 1a                	jmp    801a59 <vprintfmt+0x255>
  801a3f:	89 75 08             	mov    %esi,0x8(%ebp)
  801a42:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a45:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a48:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a4b:	eb 0c                	jmp    801a59 <vprintfmt+0x255>
  801a4d:	89 75 08             	mov    %esi,0x8(%ebp)
  801a50:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a53:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a56:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a59:	83 c7 01             	add    $0x1,%edi
  801a5c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  801a60:	0f be c2             	movsbl %dl,%eax
  801a63:	85 c0                	test   %eax,%eax
  801a65:	74 25                	je     801a8c <vprintfmt+0x288>
  801a67:	85 f6                	test   %esi,%esi
  801a69:	78 9e                	js     801a09 <vprintfmt+0x205>
  801a6b:	83 ee 01             	sub    $0x1,%esi
  801a6e:	79 99                	jns    801a09 <vprintfmt+0x205>
  801a70:	89 df                	mov    %ebx,%edi
  801a72:	8b 75 08             	mov    0x8(%ebp),%esi
  801a75:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a78:	eb 1a                	jmp    801a94 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a7a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a7e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801a85:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a87:	83 ef 01             	sub    $0x1,%edi
  801a8a:	eb 08                	jmp    801a94 <vprintfmt+0x290>
  801a8c:	89 df                	mov    %ebx,%edi
  801a8e:	8b 75 08             	mov    0x8(%ebp),%esi
  801a91:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a94:	85 ff                	test   %edi,%edi
  801a96:	7f e2                	jg     801a7a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a98:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a9b:	e9 89 fd ff ff       	jmp    801829 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801aa0:	83 f9 01             	cmp    $0x1,%ecx
  801aa3:	7e 19                	jle    801abe <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  801aa5:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa8:	8b 50 04             	mov    0x4(%eax),%edx
  801aab:	8b 00                	mov    (%eax),%eax
  801aad:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801ab0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801ab3:	8b 45 14             	mov    0x14(%ebp),%eax
  801ab6:	8d 40 08             	lea    0x8(%eax),%eax
  801ab9:	89 45 14             	mov    %eax,0x14(%ebp)
  801abc:	eb 38                	jmp    801af6 <vprintfmt+0x2f2>
	else if (lflag)
  801abe:	85 c9                	test   %ecx,%ecx
  801ac0:	74 1b                	je     801add <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  801ac2:	8b 45 14             	mov    0x14(%ebp),%eax
  801ac5:	8b 00                	mov    (%eax),%eax
  801ac7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801aca:	89 c1                	mov    %eax,%ecx
  801acc:	c1 f9 1f             	sar    $0x1f,%ecx
  801acf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801ad2:	8b 45 14             	mov    0x14(%ebp),%eax
  801ad5:	8d 40 04             	lea    0x4(%eax),%eax
  801ad8:	89 45 14             	mov    %eax,0x14(%ebp)
  801adb:	eb 19                	jmp    801af6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  801add:	8b 45 14             	mov    0x14(%ebp),%eax
  801ae0:	8b 00                	mov    (%eax),%eax
  801ae2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801ae5:	89 c1                	mov    %eax,%ecx
  801ae7:	c1 f9 1f             	sar    $0x1f,%ecx
  801aea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801aed:	8b 45 14             	mov    0x14(%ebp),%eax
  801af0:	8d 40 04             	lea    0x4(%eax),%eax
  801af3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801af6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801af9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801afc:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801b01:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801b05:	0f 89 04 01 00 00    	jns    801c0f <vprintfmt+0x40b>
				putch('-', putdat);
  801b0b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b0f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801b16:	ff d6                	call   *%esi
				num = -(long long) num;
  801b18:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801b1b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801b1e:	f7 da                	neg    %edx
  801b20:	83 d1 00             	adc    $0x0,%ecx
  801b23:	f7 d9                	neg    %ecx
  801b25:	e9 e5 00 00 00       	jmp    801c0f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801b2a:	83 f9 01             	cmp    $0x1,%ecx
  801b2d:	7e 10                	jle    801b3f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  801b2f:	8b 45 14             	mov    0x14(%ebp),%eax
  801b32:	8b 10                	mov    (%eax),%edx
  801b34:	8b 48 04             	mov    0x4(%eax),%ecx
  801b37:	8d 40 08             	lea    0x8(%eax),%eax
  801b3a:	89 45 14             	mov    %eax,0x14(%ebp)
  801b3d:	eb 26                	jmp    801b65 <vprintfmt+0x361>
	else if (lflag)
  801b3f:	85 c9                	test   %ecx,%ecx
  801b41:	74 12                	je     801b55 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  801b43:	8b 45 14             	mov    0x14(%ebp),%eax
  801b46:	8b 10                	mov    (%eax),%edx
  801b48:	b9 00 00 00 00       	mov    $0x0,%ecx
  801b4d:	8d 40 04             	lea    0x4(%eax),%eax
  801b50:	89 45 14             	mov    %eax,0x14(%ebp)
  801b53:	eb 10                	jmp    801b65 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  801b55:	8b 45 14             	mov    0x14(%ebp),%eax
  801b58:	8b 10                	mov    (%eax),%edx
  801b5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  801b5f:	8d 40 04             	lea    0x4(%eax),%eax
  801b62:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801b65:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  801b6a:	e9 a0 00 00 00       	jmp    801c0f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801b6f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b73:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  801b7a:	ff d6                	call   *%esi
			putch('X', putdat);
  801b7c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b80:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  801b87:	ff d6                	call   *%esi
			putch('X', putdat);
  801b89:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b8d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  801b94:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b96:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  801b99:	e9 8b fc ff ff       	jmp    801829 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  801b9e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ba2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801ba9:	ff d6                	call   *%esi
			putch('x', putdat);
  801bab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801baf:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801bb6:	ff d6                	call   *%esi
			num = (unsigned long long)
  801bb8:	8b 45 14             	mov    0x14(%ebp),%eax
  801bbb:	8b 10                	mov    (%eax),%edx
  801bbd:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  801bc2:	8d 40 04             	lea    0x4(%eax),%eax
  801bc5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801bc8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  801bcd:	eb 40                	jmp    801c0f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801bcf:	83 f9 01             	cmp    $0x1,%ecx
  801bd2:	7e 10                	jle    801be4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  801bd4:	8b 45 14             	mov    0x14(%ebp),%eax
  801bd7:	8b 10                	mov    (%eax),%edx
  801bd9:	8b 48 04             	mov    0x4(%eax),%ecx
  801bdc:	8d 40 08             	lea    0x8(%eax),%eax
  801bdf:	89 45 14             	mov    %eax,0x14(%ebp)
  801be2:	eb 26                	jmp    801c0a <vprintfmt+0x406>
	else if (lflag)
  801be4:	85 c9                	test   %ecx,%ecx
  801be6:	74 12                	je     801bfa <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  801be8:	8b 45 14             	mov    0x14(%ebp),%eax
  801beb:	8b 10                	mov    (%eax),%edx
  801bed:	b9 00 00 00 00       	mov    $0x0,%ecx
  801bf2:	8d 40 04             	lea    0x4(%eax),%eax
  801bf5:	89 45 14             	mov    %eax,0x14(%ebp)
  801bf8:	eb 10                	jmp    801c0a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  801bfa:	8b 45 14             	mov    0x14(%ebp),%eax
  801bfd:	8b 10                	mov    (%eax),%edx
  801bff:	b9 00 00 00 00       	mov    $0x0,%ecx
  801c04:	8d 40 04             	lea    0x4(%eax),%eax
  801c07:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801c0a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  801c0f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801c13:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c17:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c1a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c1e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801c22:	89 14 24             	mov    %edx,(%esp)
  801c25:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801c29:	89 da                	mov    %ebx,%edx
  801c2b:	89 f0                	mov    %esi,%eax
  801c2d:	e8 9e fa ff ff       	call   8016d0 <printnum>
			break;
  801c32:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c35:	e9 ef fb ff ff       	jmp    801829 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801c3a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c3e:	89 04 24             	mov    %eax,(%esp)
  801c41:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c43:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801c46:	e9 de fb ff ff       	jmp    801829 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801c4b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c4f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801c56:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801c58:	eb 03                	jmp    801c5d <vprintfmt+0x459>
  801c5a:	83 ef 01             	sub    $0x1,%edi
  801c5d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801c61:	75 f7                	jne    801c5a <vprintfmt+0x456>
  801c63:	e9 c1 fb ff ff       	jmp    801829 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  801c68:	83 c4 3c             	add    $0x3c,%esp
  801c6b:	5b                   	pop    %ebx
  801c6c:	5e                   	pop    %esi
  801c6d:	5f                   	pop    %edi
  801c6e:	5d                   	pop    %ebp
  801c6f:	c3                   	ret    

00801c70 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	83 ec 28             	sub    $0x28,%esp
  801c76:	8b 45 08             	mov    0x8(%ebp),%eax
  801c79:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801c7c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c7f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801c83:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801c86:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801c8d:	85 c0                	test   %eax,%eax
  801c8f:	74 30                	je     801cc1 <vsnprintf+0x51>
  801c91:	85 d2                	test   %edx,%edx
  801c93:	7e 2c                	jle    801cc1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801c95:	8b 45 14             	mov    0x14(%ebp),%eax
  801c98:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c9c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c9f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ca3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801ca6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801caa:	c7 04 24 bf 17 80 00 	movl   $0x8017bf,(%esp)
  801cb1:	e8 4e fb ff ff       	call   801804 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801cb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801cb9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cbf:	eb 05                	jmp    801cc6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801cc1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801cc6:	c9                   	leave  
  801cc7:	c3                   	ret    

00801cc8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801cc8:	55                   	push   %ebp
  801cc9:	89 e5                	mov    %esp,%ebp
  801ccb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801cce:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801cd1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cd5:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cdc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cdf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce6:	89 04 24             	mov    %eax,(%esp)
  801ce9:	e8 82 ff ff ff       	call   801c70 <vsnprintf>
	va_end(ap);

	return rc;
}
  801cee:	c9                   	leave  
  801cef:	c3                   	ret    

00801cf0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801cf6:	b8 00 00 00 00       	mov    $0x0,%eax
  801cfb:	eb 03                	jmp    801d00 <strlen+0x10>
		n++;
  801cfd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801d00:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801d04:	75 f7                	jne    801cfd <strlen+0xd>
		n++;
	return n;
}
  801d06:	5d                   	pop    %ebp
  801d07:	c3                   	ret    

00801d08 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801d08:	55                   	push   %ebp
  801d09:	89 e5                	mov    %esp,%ebp
  801d0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d0e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801d11:	b8 00 00 00 00       	mov    $0x0,%eax
  801d16:	eb 03                	jmp    801d1b <strnlen+0x13>
		n++;
  801d18:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801d1b:	39 d0                	cmp    %edx,%eax
  801d1d:	74 06                	je     801d25 <strnlen+0x1d>
  801d1f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801d23:	75 f3                	jne    801d18 <strnlen+0x10>
		n++;
	return n;
}
  801d25:	5d                   	pop    %ebp
  801d26:	c3                   	ret    

00801d27 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801d27:	55                   	push   %ebp
  801d28:	89 e5                	mov    %esp,%ebp
  801d2a:	53                   	push   %ebx
  801d2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801d31:	89 c2                	mov    %eax,%edx
  801d33:	83 c2 01             	add    $0x1,%edx
  801d36:	83 c1 01             	add    $0x1,%ecx
  801d39:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801d3d:	88 5a ff             	mov    %bl,-0x1(%edx)
  801d40:	84 db                	test   %bl,%bl
  801d42:	75 ef                	jne    801d33 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801d44:	5b                   	pop    %ebx
  801d45:	5d                   	pop    %ebp
  801d46:	c3                   	ret    

00801d47 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801d47:	55                   	push   %ebp
  801d48:	89 e5                	mov    %esp,%ebp
  801d4a:	53                   	push   %ebx
  801d4b:	83 ec 08             	sub    $0x8,%esp
  801d4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801d51:	89 1c 24             	mov    %ebx,(%esp)
  801d54:	e8 97 ff ff ff       	call   801cf0 <strlen>
	strcpy(dst + len, src);
  801d59:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d5c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d60:	01 d8                	add    %ebx,%eax
  801d62:	89 04 24             	mov    %eax,(%esp)
  801d65:	e8 bd ff ff ff       	call   801d27 <strcpy>
	return dst;
}
  801d6a:	89 d8                	mov    %ebx,%eax
  801d6c:	83 c4 08             	add    $0x8,%esp
  801d6f:	5b                   	pop    %ebx
  801d70:	5d                   	pop    %ebp
  801d71:	c3                   	ret    

00801d72 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801d72:	55                   	push   %ebp
  801d73:	89 e5                	mov    %esp,%ebp
  801d75:	56                   	push   %esi
  801d76:	53                   	push   %ebx
  801d77:	8b 75 08             	mov    0x8(%ebp),%esi
  801d7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d7d:	89 f3                	mov    %esi,%ebx
  801d7f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801d82:	89 f2                	mov    %esi,%edx
  801d84:	eb 0f                	jmp    801d95 <strncpy+0x23>
		*dst++ = *src;
  801d86:	83 c2 01             	add    $0x1,%edx
  801d89:	0f b6 01             	movzbl (%ecx),%eax
  801d8c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801d8f:	80 39 01             	cmpb   $0x1,(%ecx)
  801d92:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801d95:	39 da                	cmp    %ebx,%edx
  801d97:	75 ed                	jne    801d86 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801d99:	89 f0                	mov    %esi,%eax
  801d9b:	5b                   	pop    %ebx
  801d9c:	5e                   	pop    %esi
  801d9d:	5d                   	pop    %ebp
  801d9e:	c3                   	ret    

00801d9f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801d9f:	55                   	push   %ebp
  801da0:	89 e5                	mov    %esp,%ebp
  801da2:	56                   	push   %esi
  801da3:	53                   	push   %ebx
  801da4:	8b 75 08             	mov    0x8(%ebp),%esi
  801da7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801daa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801dad:	89 f0                	mov    %esi,%eax
  801daf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801db3:	85 c9                	test   %ecx,%ecx
  801db5:	75 0b                	jne    801dc2 <strlcpy+0x23>
  801db7:	eb 1d                	jmp    801dd6 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801db9:	83 c0 01             	add    $0x1,%eax
  801dbc:	83 c2 01             	add    $0x1,%edx
  801dbf:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801dc2:	39 d8                	cmp    %ebx,%eax
  801dc4:	74 0b                	je     801dd1 <strlcpy+0x32>
  801dc6:	0f b6 0a             	movzbl (%edx),%ecx
  801dc9:	84 c9                	test   %cl,%cl
  801dcb:	75 ec                	jne    801db9 <strlcpy+0x1a>
  801dcd:	89 c2                	mov    %eax,%edx
  801dcf:	eb 02                	jmp    801dd3 <strlcpy+0x34>
  801dd1:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801dd3:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801dd6:	29 f0                	sub    %esi,%eax
}
  801dd8:	5b                   	pop    %ebx
  801dd9:	5e                   	pop    %esi
  801dda:	5d                   	pop    %ebp
  801ddb:	c3                   	ret    

00801ddc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801ddc:	55                   	push   %ebp
  801ddd:	89 e5                	mov    %esp,%ebp
  801ddf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801de2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801de5:	eb 06                	jmp    801ded <strcmp+0x11>
		p++, q++;
  801de7:	83 c1 01             	add    $0x1,%ecx
  801dea:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801ded:	0f b6 01             	movzbl (%ecx),%eax
  801df0:	84 c0                	test   %al,%al
  801df2:	74 04                	je     801df8 <strcmp+0x1c>
  801df4:	3a 02                	cmp    (%edx),%al
  801df6:	74 ef                	je     801de7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801df8:	0f b6 c0             	movzbl %al,%eax
  801dfb:	0f b6 12             	movzbl (%edx),%edx
  801dfe:	29 d0                	sub    %edx,%eax
}
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    

00801e02 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	53                   	push   %ebx
  801e06:	8b 45 08             	mov    0x8(%ebp),%eax
  801e09:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e0c:	89 c3                	mov    %eax,%ebx
  801e0e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801e11:	eb 06                	jmp    801e19 <strncmp+0x17>
		n--, p++, q++;
  801e13:	83 c0 01             	add    $0x1,%eax
  801e16:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801e19:	39 d8                	cmp    %ebx,%eax
  801e1b:	74 15                	je     801e32 <strncmp+0x30>
  801e1d:	0f b6 08             	movzbl (%eax),%ecx
  801e20:	84 c9                	test   %cl,%cl
  801e22:	74 04                	je     801e28 <strncmp+0x26>
  801e24:	3a 0a                	cmp    (%edx),%cl
  801e26:	74 eb                	je     801e13 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801e28:	0f b6 00             	movzbl (%eax),%eax
  801e2b:	0f b6 12             	movzbl (%edx),%edx
  801e2e:	29 d0                	sub    %edx,%eax
  801e30:	eb 05                	jmp    801e37 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801e32:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801e37:	5b                   	pop    %ebx
  801e38:	5d                   	pop    %ebp
  801e39:	c3                   	ret    

00801e3a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801e3a:	55                   	push   %ebp
  801e3b:	89 e5                	mov    %esp,%ebp
  801e3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e40:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801e44:	eb 07                	jmp    801e4d <strchr+0x13>
		if (*s == c)
  801e46:	38 ca                	cmp    %cl,%dl
  801e48:	74 0f                	je     801e59 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801e4a:	83 c0 01             	add    $0x1,%eax
  801e4d:	0f b6 10             	movzbl (%eax),%edx
  801e50:	84 d2                	test   %dl,%dl
  801e52:	75 f2                	jne    801e46 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801e54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e59:	5d                   	pop    %ebp
  801e5a:	c3                   	ret    

00801e5b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801e5b:	55                   	push   %ebp
  801e5c:	89 e5                	mov    %esp,%ebp
  801e5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801e65:	eb 07                	jmp    801e6e <strfind+0x13>
		if (*s == c)
  801e67:	38 ca                	cmp    %cl,%dl
  801e69:	74 0a                	je     801e75 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801e6b:	83 c0 01             	add    $0x1,%eax
  801e6e:	0f b6 10             	movzbl (%eax),%edx
  801e71:	84 d2                	test   %dl,%dl
  801e73:	75 f2                	jne    801e67 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  801e75:	5d                   	pop    %ebp
  801e76:	c3                   	ret    

00801e77 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801e77:	55                   	push   %ebp
  801e78:	89 e5                	mov    %esp,%ebp
  801e7a:	57                   	push   %edi
  801e7b:	56                   	push   %esi
  801e7c:	53                   	push   %ebx
  801e7d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e80:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801e83:	85 c9                	test   %ecx,%ecx
  801e85:	74 36                	je     801ebd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801e87:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801e8d:	75 28                	jne    801eb7 <memset+0x40>
  801e8f:	f6 c1 03             	test   $0x3,%cl
  801e92:	75 23                	jne    801eb7 <memset+0x40>
		c &= 0xFF;
  801e94:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801e98:	89 d3                	mov    %edx,%ebx
  801e9a:	c1 e3 08             	shl    $0x8,%ebx
  801e9d:	89 d6                	mov    %edx,%esi
  801e9f:	c1 e6 18             	shl    $0x18,%esi
  801ea2:	89 d0                	mov    %edx,%eax
  801ea4:	c1 e0 10             	shl    $0x10,%eax
  801ea7:	09 f0                	or     %esi,%eax
  801ea9:	09 c2                	or     %eax,%edx
  801eab:	89 d0                	mov    %edx,%eax
  801ead:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801eaf:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801eb2:	fc                   	cld    
  801eb3:	f3 ab                	rep stos %eax,%es:(%edi)
  801eb5:	eb 06                	jmp    801ebd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801eb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eba:	fc                   	cld    
  801ebb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801ebd:	89 f8                	mov    %edi,%eax
  801ebf:	5b                   	pop    %ebx
  801ec0:	5e                   	pop    %esi
  801ec1:	5f                   	pop    %edi
  801ec2:	5d                   	pop    %ebp
  801ec3:	c3                   	ret    

00801ec4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	57                   	push   %edi
  801ec8:	56                   	push   %esi
  801ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecc:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ecf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801ed2:	39 c6                	cmp    %eax,%esi
  801ed4:	73 35                	jae    801f0b <memmove+0x47>
  801ed6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801ed9:	39 d0                	cmp    %edx,%eax
  801edb:	73 2e                	jae    801f0b <memmove+0x47>
		s += n;
		d += n;
  801edd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801ee0:	89 d6                	mov    %edx,%esi
  801ee2:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ee4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801eea:	75 13                	jne    801eff <memmove+0x3b>
  801eec:	f6 c1 03             	test   $0x3,%cl
  801eef:	75 0e                	jne    801eff <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801ef1:	83 ef 04             	sub    $0x4,%edi
  801ef4:	8d 72 fc             	lea    -0x4(%edx),%esi
  801ef7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801efa:	fd                   	std    
  801efb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801efd:	eb 09                	jmp    801f08 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801eff:	83 ef 01             	sub    $0x1,%edi
  801f02:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801f05:	fd                   	std    
  801f06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801f08:	fc                   	cld    
  801f09:	eb 1d                	jmp    801f28 <memmove+0x64>
  801f0b:	89 f2                	mov    %esi,%edx
  801f0d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801f0f:	f6 c2 03             	test   $0x3,%dl
  801f12:	75 0f                	jne    801f23 <memmove+0x5f>
  801f14:	f6 c1 03             	test   $0x3,%cl
  801f17:	75 0a                	jne    801f23 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801f19:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801f1c:	89 c7                	mov    %eax,%edi
  801f1e:	fc                   	cld    
  801f1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801f21:	eb 05                	jmp    801f28 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801f23:	89 c7                	mov    %eax,%edi
  801f25:	fc                   	cld    
  801f26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801f28:	5e                   	pop    %esi
  801f29:	5f                   	pop    %edi
  801f2a:	5d                   	pop    %ebp
  801f2b:	c3                   	ret    

00801f2c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801f2c:	55                   	push   %ebp
  801f2d:	89 e5                	mov    %esp,%ebp
  801f2f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801f32:	8b 45 10             	mov    0x10(%ebp),%eax
  801f35:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f39:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f40:	8b 45 08             	mov    0x8(%ebp),%eax
  801f43:	89 04 24             	mov    %eax,(%esp)
  801f46:	e8 79 ff ff ff       	call   801ec4 <memmove>
}
  801f4b:	c9                   	leave  
  801f4c:	c3                   	ret    

00801f4d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801f4d:	55                   	push   %ebp
  801f4e:	89 e5                	mov    %esp,%ebp
  801f50:	56                   	push   %esi
  801f51:	53                   	push   %ebx
  801f52:	8b 55 08             	mov    0x8(%ebp),%edx
  801f55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f58:	89 d6                	mov    %edx,%esi
  801f5a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801f5d:	eb 1a                	jmp    801f79 <memcmp+0x2c>
		if (*s1 != *s2)
  801f5f:	0f b6 02             	movzbl (%edx),%eax
  801f62:	0f b6 19             	movzbl (%ecx),%ebx
  801f65:	38 d8                	cmp    %bl,%al
  801f67:	74 0a                	je     801f73 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801f69:	0f b6 c0             	movzbl %al,%eax
  801f6c:	0f b6 db             	movzbl %bl,%ebx
  801f6f:	29 d8                	sub    %ebx,%eax
  801f71:	eb 0f                	jmp    801f82 <memcmp+0x35>
		s1++, s2++;
  801f73:	83 c2 01             	add    $0x1,%edx
  801f76:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801f79:	39 f2                	cmp    %esi,%edx
  801f7b:	75 e2                	jne    801f5f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801f7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f82:	5b                   	pop    %ebx
  801f83:	5e                   	pop    %esi
  801f84:	5d                   	pop    %ebp
  801f85:	c3                   	ret    

00801f86 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801f86:	55                   	push   %ebp
  801f87:	89 e5                	mov    %esp,%ebp
  801f89:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801f8f:	89 c2                	mov    %eax,%edx
  801f91:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801f94:	eb 07                	jmp    801f9d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801f96:	38 08                	cmp    %cl,(%eax)
  801f98:	74 07                	je     801fa1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801f9a:	83 c0 01             	add    $0x1,%eax
  801f9d:	39 d0                	cmp    %edx,%eax
  801f9f:	72 f5                	jb     801f96 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801fa1:	5d                   	pop    %ebp
  801fa2:	c3                   	ret    

00801fa3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801fa3:	55                   	push   %ebp
  801fa4:	89 e5                	mov    %esp,%ebp
  801fa6:	57                   	push   %edi
  801fa7:	56                   	push   %esi
  801fa8:	53                   	push   %ebx
  801fa9:	8b 55 08             	mov    0x8(%ebp),%edx
  801fac:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801faf:	eb 03                	jmp    801fb4 <strtol+0x11>
		s++;
  801fb1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801fb4:	0f b6 0a             	movzbl (%edx),%ecx
  801fb7:	80 f9 09             	cmp    $0x9,%cl
  801fba:	74 f5                	je     801fb1 <strtol+0xe>
  801fbc:	80 f9 20             	cmp    $0x20,%cl
  801fbf:	74 f0                	je     801fb1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801fc1:	80 f9 2b             	cmp    $0x2b,%cl
  801fc4:	75 0a                	jne    801fd0 <strtol+0x2d>
		s++;
  801fc6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801fc9:	bf 00 00 00 00       	mov    $0x0,%edi
  801fce:	eb 11                	jmp    801fe1 <strtol+0x3e>
  801fd0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801fd5:	80 f9 2d             	cmp    $0x2d,%cl
  801fd8:	75 07                	jne    801fe1 <strtol+0x3e>
		s++, neg = 1;
  801fda:	8d 52 01             	lea    0x1(%edx),%edx
  801fdd:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801fe1:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801fe6:	75 15                	jne    801ffd <strtol+0x5a>
  801fe8:	80 3a 30             	cmpb   $0x30,(%edx)
  801feb:	75 10                	jne    801ffd <strtol+0x5a>
  801fed:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801ff1:	75 0a                	jne    801ffd <strtol+0x5a>
		s += 2, base = 16;
  801ff3:	83 c2 02             	add    $0x2,%edx
  801ff6:	b8 10 00 00 00       	mov    $0x10,%eax
  801ffb:	eb 10                	jmp    80200d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  801ffd:	85 c0                	test   %eax,%eax
  801fff:	75 0c                	jne    80200d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  802001:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802003:	80 3a 30             	cmpb   $0x30,(%edx)
  802006:	75 05                	jne    80200d <strtol+0x6a>
		s++, base = 8;
  802008:	83 c2 01             	add    $0x1,%edx
  80200b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80200d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802012:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802015:	0f b6 0a             	movzbl (%edx),%ecx
  802018:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80201b:	89 f0                	mov    %esi,%eax
  80201d:	3c 09                	cmp    $0x9,%al
  80201f:	77 08                	ja     802029 <strtol+0x86>
			dig = *s - '0';
  802021:	0f be c9             	movsbl %cl,%ecx
  802024:	83 e9 30             	sub    $0x30,%ecx
  802027:	eb 20                	jmp    802049 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  802029:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80202c:	89 f0                	mov    %esi,%eax
  80202e:	3c 19                	cmp    $0x19,%al
  802030:	77 08                	ja     80203a <strtol+0x97>
			dig = *s - 'a' + 10;
  802032:	0f be c9             	movsbl %cl,%ecx
  802035:	83 e9 57             	sub    $0x57,%ecx
  802038:	eb 0f                	jmp    802049 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80203a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80203d:	89 f0                	mov    %esi,%eax
  80203f:	3c 19                	cmp    $0x19,%al
  802041:	77 16                	ja     802059 <strtol+0xb6>
			dig = *s - 'A' + 10;
  802043:	0f be c9             	movsbl %cl,%ecx
  802046:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  802049:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80204c:	7d 0f                	jge    80205d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80204e:	83 c2 01             	add    $0x1,%edx
  802051:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  802055:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  802057:	eb bc                	jmp    802015 <strtol+0x72>
  802059:	89 d8                	mov    %ebx,%eax
  80205b:	eb 02                	jmp    80205f <strtol+0xbc>
  80205d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  80205f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802063:	74 05                	je     80206a <strtol+0xc7>
		*endptr = (char *) s;
  802065:	8b 75 0c             	mov    0xc(%ebp),%esi
  802068:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80206a:	f7 d8                	neg    %eax
  80206c:	85 ff                	test   %edi,%edi
  80206e:	0f 44 c3             	cmove  %ebx,%eax
}
  802071:	5b                   	pop    %ebx
  802072:	5e                   	pop    %esi
  802073:	5f                   	pop    %edi
  802074:	5d                   	pop    %ebp
  802075:	c3                   	ret    

00802076 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802076:	55                   	push   %ebp
  802077:	89 e5                	mov    %esp,%ebp
  802079:	57                   	push   %edi
  80207a:	56                   	push   %esi
  80207b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80207c:	b8 00 00 00 00       	mov    $0x0,%eax
  802081:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802084:	8b 55 08             	mov    0x8(%ebp),%edx
  802087:	89 c3                	mov    %eax,%ebx
  802089:	89 c7                	mov    %eax,%edi
  80208b:	89 c6                	mov    %eax,%esi
  80208d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80208f:	5b                   	pop    %ebx
  802090:	5e                   	pop    %esi
  802091:	5f                   	pop    %edi
  802092:	5d                   	pop    %ebp
  802093:	c3                   	ret    

00802094 <sys_cgetc>:

int
sys_cgetc(void)
{
  802094:	55                   	push   %ebp
  802095:	89 e5                	mov    %esp,%ebp
  802097:	57                   	push   %edi
  802098:	56                   	push   %esi
  802099:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80209a:	ba 00 00 00 00       	mov    $0x0,%edx
  80209f:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a4:	89 d1                	mov    %edx,%ecx
  8020a6:	89 d3                	mov    %edx,%ebx
  8020a8:	89 d7                	mov    %edx,%edi
  8020aa:	89 d6                	mov    %edx,%esi
  8020ac:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8020ae:	5b                   	pop    %ebx
  8020af:	5e                   	pop    %esi
  8020b0:	5f                   	pop    %edi
  8020b1:	5d                   	pop    %ebp
  8020b2:	c3                   	ret    

008020b3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8020b3:	55                   	push   %ebp
  8020b4:	89 e5                	mov    %esp,%ebp
  8020b6:	57                   	push   %edi
  8020b7:	56                   	push   %esi
  8020b8:	53                   	push   %ebx
  8020b9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8020bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8020c1:	b8 03 00 00 00       	mov    $0x3,%eax
  8020c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8020c9:	89 cb                	mov    %ecx,%ebx
  8020cb:	89 cf                	mov    %ecx,%edi
  8020cd:	89 ce                	mov    %ecx,%esi
  8020cf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8020d1:	85 c0                	test   %eax,%eax
  8020d3:	7e 28                	jle    8020fd <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8020d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8020d9:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8020e0:	00 
  8020e1:	c7 44 24 08 df 3e 80 	movl   $0x803edf,0x8(%esp)
  8020e8:	00 
  8020e9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8020f0:	00 
  8020f1:	c7 04 24 fc 3e 80 00 	movl   $0x803efc,(%esp)
  8020f8:	e8 b6 f4 ff ff       	call   8015b3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8020fd:	83 c4 2c             	add    $0x2c,%esp
  802100:	5b                   	pop    %ebx
  802101:	5e                   	pop    %esi
  802102:	5f                   	pop    %edi
  802103:	5d                   	pop    %ebp
  802104:	c3                   	ret    

00802105 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  802105:	55                   	push   %ebp
  802106:	89 e5                	mov    %esp,%ebp
  802108:	57                   	push   %edi
  802109:	56                   	push   %esi
  80210a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80210b:	ba 00 00 00 00       	mov    $0x0,%edx
  802110:	b8 02 00 00 00       	mov    $0x2,%eax
  802115:	89 d1                	mov    %edx,%ecx
  802117:	89 d3                	mov    %edx,%ebx
  802119:	89 d7                	mov    %edx,%edi
  80211b:	89 d6                	mov    %edx,%esi
  80211d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80211f:	5b                   	pop    %ebx
  802120:	5e                   	pop    %esi
  802121:	5f                   	pop    %edi
  802122:	5d                   	pop    %ebp
  802123:	c3                   	ret    

00802124 <sys_yield>:

void
sys_yield(void)
{
  802124:	55                   	push   %ebp
  802125:	89 e5                	mov    %esp,%ebp
  802127:	57                   	push   %edi
  802128:	56                   	push   %esi
  802129:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80212a:	ba 00 00 00 00       	mov    $0x0,%edx
  80212f:	b8 0b 00 00 00       	mov    $0xb,%eax
  802134:	89 d1                	mov    %edx,%ecx
  802136:	89 d3                	mov    %edx,%ebx
  802138:	89 d7                	mov    %edx,%edi
  80213a:	89 d6                	mov    %edx,%esi
  80213c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80213e:	5b                   	pop    %ebx
  80213f:	5e                   	pop    %esi
  802140:	5f                   	pop    %edi
  802141:	5d                   	pop    %ebp
  802142:	c3                   	ret    

00802143 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802143:	55                   	push   %ebp
  802144:	89 e5                	mov    %esp,%ebp
  802146:	57                   	push   %edi
  802147:	56                   	push   %esi
  802148:	53                   	push   %ebx
  802149:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80214c:	be 00 00 00 00       	mov    $0x0,%esi
  802151:	b8 04 00 00 00       	mov    $0x4,%eax
  802156:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802159:	8b 55 08             	mov    0x8(%ebp),%edx
  80215c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80215f:	89 f7                	mov    %esi,%edi
  802161:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802163:	85 c0                	test   %eax,%eax
  802165:	7e 28                	jle    80218f <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  802167:	89 44 24 10          	mov    %eax,0x10(%esp)
  80216b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  802172:	00 
  802173:	c7 44 24 08 df 3e 80 	movl   $0x803edf,0x8(%esp)
  80217a:	00 
  80217b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802182:	00 
  802183:	c7 04 24 fc 3e 80 00 	movl   $0x803efc,(%esp)
  80218a:	e8 24 f4 ff ff       	call   8015b3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80218f:	83 c4 2c             	add    $0x2c,%esp
  802192:	5b                   	pop    %ebx
  802193:	5e                   	pop    %esi
  802194:	5f                   	pop    %edi
  802195:	5d                   	pop    %ebp
  802196:	c3                   	ret    

00802197 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802197:	55                   	push   %ebp
  802198:	89 e5                	mov    %esp,%ebp
  80219a:	57                   	push   %edi
  80219b:	56                   	push   %esi
  80219c:	53                   	push   %ebx
  80219d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8021a0:	b8 05 00 00 00       	mov    $0x5,%eax
  8021a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8021ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021ae:	8b 7d 14             	mov    0x14(%ebp),%edi
  8021b1:	8b 75 18             	mov    0x18(%ebp),%esi
  8021b4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8021b6:	85 c0                	test   %eax,%eax
  8021b8:	7e 28                	jle    8021e2 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8021ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8021be:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8021c5:	00 
  8021c6:	c7 44 24 08 df 3e 80 	movl   $0x803edf,0x8(%esp)
  8021cd:	00 
  8021ce:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8021d5:	00 
  8021d6:	c7 04 24 fc 3e 80 00 	movl   $0x803efc,(%esp)
  8021dd:	e8 d1 f3 ff ff       	call   8015b3 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8021e2:	83 c4 2c             	add    $0x2c,%esp
  8021e5:	5b                   	pop    %ebx
  8021e6:	5e                   	pop    %esi
  8021e7:	5f                   	pop    %edi
  8021e8:	5d                   	pop    %ebp
  8021e9:	c3                   	ret    

008021ea <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8021ea:	55                   	push   %ebp
  8021eb:	89 e5                	mov    %esp,%ebp
  8021ed:	57                   	push   %edi
  8021ee:	56                   	push   %esi
  8021ef:	53                   	push   %ebx
  8021f0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8021f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021f8:	b8 06 00 00 00       	mov    $0x6,%eax
  8021fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802200:	8b 55 08             	mov    0x8(%ebp),%edx
  802203:	89 df                	mov    %ebx,%edi
  802205:	89 de                	mov    %ebx,%esi
  802207:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802209:	85 c0                	test   %eax,%eax
  80220b:	7e 28                	jle    802235 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80220d:	89 44 24 10          	mov    %eax,0x10(%esp)
  802211:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  802218:	00 
  802219:	c7 44 24 08 df 3e 80 	movl   $0x803edf,0x8(%esp)
  802220:	00 
  802221:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802228:	00 
  802229:	c7 04 24 fc 3e 80 00 	movl   $0x803efc,(%esp)
  802230:	e8 7e f3 ff ff       	call   8015b3 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  802235:	83 c4 2c             	add    $0x2c,%esp
  802238:	5b                   	pop    %ebx
  802239:	5e                   	pop    %esi
  80223a:	5f                   	pop    %edi
  80223b:	5d                   	pop    %ebp
  80223c:	c3                   	ret    

0080223d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80223d:	55                   	push   %ebp
  80223e:	89 e5                	mov    %esp,%ebp
  802240:	57                   	push   %edi
  802241:	56                   	push   %esi
  802242:	53                   	push   %ebx
  802243:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802246:	bb 00 00 00 00       	mov    $0x0,%ebx
  80224b:	b8 08 00 00 00       	mov    $0x8,%eax
  802250:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802253:	8b 55 08             	mov    0x8(%ebp),%edx
  802256:	89 df                	mov    %ebx,%edi
  802258:	89 de                	mov    %ebx,%esi
  80225a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80225c:	85 c0                	test   %eax,%eax
  80225e:	7e 28                	jle    802288 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802260:	89 44 24 10          	mov    %eax,0x10(%esp)
  802264:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80226b:	00 
  80226c:	c7 44 24 08 df 3e 80 	movl   $0x803edf,0x8(%esp)
  802273:	00 
  802274:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80227b:	00 
  80227c:	c7 04 24 fc 3e 80 00 	movl   $0x803efc,(%esp)
  802283:	e8 2b f3 ff ff       	call   8015b3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802288:	83 c4 2c             	add    $0x2c,%esp
  80228b:	5b                   	pop    %ebx
  80228c:	5e                   	pop    %esi
  80228d:	5f                   	pop    %edi
  80228e:	5d                   	pop    %ebp
  80228f:	c3                   	ret    

00802290 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802290:	55                   	push   %ebp
  802291:	89 e5                	mov    %esp,%ebp
  802293:	57                   	push   %edi
  802294:	56                   	push   %esi
  802295:	53                   	push   %ebx
  802296:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802299:	bb 00 00 00 00       	mov    $0x0,%ebx
  80229e:	b8 09 00 00 00       	mov    $0x9,%eax
  8022a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8022a9:	89 df                	mov    %ebx,%edi
  8022ab:	89 de                	mov    %ebx,%esi
  8022ad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8022af:	85 c0                	test   %eax,%eax
  8022b1:	7e 28                	jle    8022db <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8022b3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8022b7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8022be:	00 
  8022bf:	c7 44 24 08 df 3e 80 	movl   $0x803edf,0x8(%esp)
  8022c6:	00 
  8022c7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8022ce:	00 
  8022cf:	c7 04 24 fc 3e 80 00 	movl   $0x803efc,(%esp)
  8022d6:	e8 d8 f2 ff ff       	call   8015b3 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8022db:	83 c4 2c             	add    $0x2c,%esp
  8022de:	5b                   	pop    %ebx
  8022df:	5e                   	pop    %esi
  8022e0:	5f                   	pop    %edi
  8022e1:	5d                   	pop    %ebp
  8022e2:	c3                   	ret    

008022e3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8022e3:	55                   	push   %ebp
  8022e4:	89 e5                	mov    %esp,%ebp
  8022e6:	57                   	push   %edi
  8022e7:	56                   	push   %esi
  8022e8:	53                   	push   %ebx
  8022e9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8022ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8022f1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8022f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8022fc:	89 df                	mov    %ebx,%edi
  8022fe:	89 de                	mov    %ebx,%esi
  802300:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802302:	85 c0                	test   %eax,%eax
  802304:	7e 28                	jle    80232e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802306:	89 44 24 10          	mov    %eax,0x10(%esp)
  80230a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  802311:	00 
  802312:	c7 44 24 08 df 3e 80 	movl   $0x803edf,0x8(%esp)
  802319:	00 
  80231a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802321:	00 
  802322:	c7 04 24 fc 3e 80 00 	movl   $0x803efc,(%esp)
  802329:	e8 85 f2 ff ff       	call   8015b3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80232e:	83 c4 2c             	add    $0x2c,%esp
  802331:	5b                   	pop    %ebx
  802332:	5e                   	pop    %esi
  802333:	5f                   	pop    %edi
  802334:	5d                   	pop    %ebp
  802335:	c3                   	ret    

00802336 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802336:	55                   	push   %ebp
  802337:	89 e5                	mov    %esp,%ebp
  802339:	57                   	push   %edi
  80233a:	56                   	push   %esi
  80233b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80233c:	be 00 00 00 00       	mov    $0x0,%esi
  802341:	b8 0c 00 00 00       	mov    $0xc,%eax
  802346:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802349:	8b 55 08             	mov    0x8(%ebp),%edx
  80234c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80234f:	8b 7d 14             	mov    0x14(%ebp),%edi
  802352:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  802354:	5b                   	pop    %ebx
  802355:	5e                   	pop    %esi
  802356:	5f                   	pop    %edi
  802357:	5d                   	pop    %ebp
  802358:	c3                   	ret    

00802359 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  802359:	55                   	push   %ebp
  80235a:	89 e5                	mov    %esp,%ebp
  80235c:	57                   	push   %edi
  80235d:	56                   	push   %esi
  80235e:	53                   	push   %ebx
  80235f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802362:	b9 00 00 00 00       	mov    $0x0,%ecx
  802367:	b8 0d 00 00 00       	mov    $0xd,%eax
  80236c:	8b 55 08             	mov    0x8(%ebp),%edx
  80236f:	89 cb                	mov    %ecx,%ebx
  802371:	89 cf                	mov    %ecx,%edi
  802373:	89 ce                	mov    %ecx,%esi
  802375:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802377:	85 c0                	test   %eax,%eax
  802379:	7e 28                	jle    8023a3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80237b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80237f:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  802386:	00 
  802387:	c7 44 24 08 df 3e 80 	movl   $0x803edf,0x8(%esp)
  80238e:	00 
  80238f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802396:	00 
  802397:	c7 04 24 fc 3e 80 00 	movl   $0x803efc,(%esp)
  80239e:	e8 10 f2 ff ff       	call   8015b3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8023a3:	83 c4 2c             	add    $0x2c,%esp
  8023a6:	5b                   	pop    %ebx
  8023a7:	5e                   	pop    %esi
  8023a8:	5f                   	pop    %edi
  8023a9:	5d                   	pop    %ebp
  8023aa:	c3                   	ret    

008023ab <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023ab:	55                   	push   %ebp
  8023ac:	89 e5                	mov    %esp,%ebp
  8023ae:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023b1:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  8023b8:	75 44                	jne    8023fe <set_pgfault_handler+0x53>
		// First time through!
		// LAB 4: Your code here.
		void* addr = (void*) (UXSTACKTOP-PGSIZE);
		r=sys_page_alloc(thisenv->env_id, addr, PTE_W|PTE_U|PTE_P);
  8023ba:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8023bf:	8b 40 48             	mov    0x48(%eax),%eax
  8023c2:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8023c9:	00 
  8023ca:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8023d1:	ee 
  8023d2:	89 04 24             	mov    %eax,(%esp)
  8023d5:	e8 69 fd ff ff       	call   802143 <sys_page_alloc>
		if( r < 0)
  8023da:	85 c0                	test   %eax,%eax
  8023dc:	79 20                	jns    8023fe <set_pgfault_handler+0x53>
			panic("No memory for the UxStack, the mistake is %d\n",r);
  8023de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023e2:	c7 44 24 08 0c 3f 80 	movl   $0x803f0c,0x8(%esp)
  8023e9:	00 
  8023ea:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8023f1:	00 
  8023f2:	c7 04 24 68 3f 80 00 	movl   $0x803f68,(%esp)
  8023f9:	e8 b5 f1 ff ff       	call   8015b3 <_panic>
		//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802401:	a3 10 a0 80 00       	mov    %eax,0x80a010
	if(( r= sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall))<0)
  802406:	e8 fa fc ff ff       	call   802105 <sys_getenvid>
  80240b:	c7 44 24 04 41 24 80 	movl   $0x802441,0x4(%esp)
  802412:	00 
  802413:	89 04 24             	mov    %eax,(%esp)
  802416:	e8 c8 fe ff ff       	call   8022e3 <sys_env_set_pgfault_upcall>
  80241b:	85 c0                	test   %eax,%eax
  80241d:	79 20                	jns    80243f <set_pgfault_handler+0x94>
		panic("sys_env_set_pgfault_upcall is not right %d\n", r);
  80241f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802423:	c7 44 24 08 3c 3f 80 	movl   $0x803f3c,0x8(%esp)
  80242a:	00 
  80242b:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  802432:	00 
  802433:	c7 04 24 68 3f 80 00 	movl   $0x803f68,(%esp)
  80243a:	e8 74 f1 ff ff       	call   8015b3 <_panic>


}
  80243f:	c9                   	leave  
  802440:	c3                   	ret    

00802441 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802441:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802442:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  802447:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802449:	83 c4 04             	add    $0x4,%esp

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB : Your code here.
	//	trap-eip -> eax
		movl 0x28(%esp), %eax
  80244c:	8b 44 24 28          	mov    0x28(%esp),%eax
	//	trap-ebp-> ebx		
		movl 0x10(%esp), %ebx
  802450:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	//  trap->esp -> ecx 
		movl 0x30(%esp), %ecx
  802454:	8b 4c 24 30          	mov    0x30(%esp),%ecx

		movl %eax, -0x4(%ecx)
  802458:	89 41 fc             	mov    %eax,-0x4(%ecx)
		movl %ebx, -0x8(%ecx)
  80245b:	89 59 f8             	mov    %ebx,-0x8(%ecx)

		leal -0x8(%ecx), %ebp
  80245e:	8d 69 f8             	lea    -0x8(%ecx),%ebp

		movl 0x8(%esp), %edi
  802461:	8b 7c 24 08          	mov    0x8(%esp),%edi
		movl 0xc(%esp),	%esi
  802465:	8b 74 24 0c          	mov    0xc(%esp),%esi
		movl 0x18(%esp),%ebx
  802469:	8b 5c 24 18          	mov    0x18(%esp),%ebx
		movl 0x1c(%esp),%edx
  80246d:	8b 54 24 1c          	mov    0x1c(%esp),%edx
		movl 0x20(%esp),%ecx
  802471:	8b 4c 24 20          	mov    0x20(%esp),%ecx
		movl 0x24(%esp),%eax
  802475:	8b 44 24 24          	mov    0x24(%esp),%eax

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB : Your code here.
		leal 0x2c(%esp), %esp
  802479:	8d 64 24 2c          	lea    0x2c(%esp),%esp
		popf
  80247d:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB : Your code here.
		leave
  80247e:	c9                   	leave  
	// Return to re-execute the instruction that faulted.
	// LAB : Your code here.
  80247f:	c3                   	ret    

00802480 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802480:	55                   	push   %ebp
  802481:	89 e5                	mov    %esp,%ebp
  802483:	56                   	push   %esi
  802484:	53                   	push   %ebx
  802485:	83 ec 10             	sub    $0x10,%esp
  802488:	8b 75 08             	mov    0x8(%ebp),%esi
  80248b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80248e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB : Your code here.
	int r =0;
	int a;
	if(pg == 0)
  802491:	85 c0                	test   %eax,%eax
  802493:	75 0e                	jne    8024a3 <ipc_recv+0x23>
		r= sys_ipc_recv( (void *)UTOP);
  802495:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  80249c:	e8 b8 fe ff ff       	call   802359 <sys_ipc_recv>
  8024a1:	eb 08                	jmp    8024ab <ipc_recv+0x2b>
	else
		r = sys_ipc_recv(pg);
  8024a3:	89 04 24             	mov    %eax,(%esp)
  8024a6:	e8 ae fe ff ff       	call   802359 <sys_ipc_recv>
	if(r == 0){
  8024ab:	85 c0                	test   %eax,%eax
  8024ad:	8d 76 00             	lea    0x0(%esi),%esi
  8024b0:	75 1e                	jne    8024d0 <ipc_recv+0x50>
		if( from_env_store != 0 )
  8024b2:	85 f6                	test   %esi,%esi
  8024b4:	74 0a                	je     8024c0 <ipc_recv+0x40>
			*from_env_store = thisenv->env_ipc_from;
  8024b6:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8024bb:	8b 40 74             	mov    0x74(%eax),%eax
  8024be:	89 06                	mov    %eax,(%esi)

		if(perm_store != 0 )
  8024c0:	85 db                	test   %ebx,%ebx
  8024c2:	74 2c                	je     8024f0 <ipc_recv+0x70>
			*perm_store = thisenv->env_ipc_perm;
  8024c4:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8024c9:	8b 40 78             	mov    0x78(%eax),%eax
  8024cc:	89 03                	mov    %eax,(%ebx)
  8024ce:	eb 20                	jmp    8024f0 <ipc_recv+0x70>
	}
	else{
		panic("The ipc_recv is not right, and the errno is %d\n",r);
  8024d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024d4:	c7 44 24 08 78 3f 80 	movl   $0x803f78,0x8(%esp)
  8024db:	00 
  8024dc:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8024e3:	00 
  8024e4:	c7 04 24 f4 3f 80 00 	movl   $0x803ff4,(%esp)
  8024eb:	e8 c3 f0 ff ff       	call   8015b3 <_panic>

		if(perm_store != 0 )
			*perm_store = 0;
		return r;
	}
	if(thisenv->env_ipc_value == 0)
  8024f0:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8024f5:	8b 50 70             	mov    0x70(%eax),%edx
  8024f8:	85 d2                	test   %edx,%edx
  8024fa:	75 13                	jne    80250f <ipc_recv+0x8f>
		cprintf("the value is 0, the envid is %x\n", thisenv->env_id);
  8024fc:	8b 40 48             	mov    0x48(%eax),%eax
  8024ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  802503:	c7 04 24 a8 3f 80 00 	movl   $0x803fa8,(%esp)
  80250a:	e8 9d f1 ff ff       	call   8016ac <cprintf>
	return thisenv->env_ipc_value;
  80250f:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802514:	8b 40 70             	mov    0x70(%eax),%eax
}
  802517:	83 c4 10             	add    $0x10,%esp
  80251a:	5b                   	pop    %ebx
  80251b:	5e                   	pop    %esi
  80251c:	5d                   	pop    %ebp
  80251d:	c3                   	ret    

0080251e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80251e:	55                   	push   %ebp
  80251f:	89 e5                	mov    %esp,%ebp
  802521:	57                   	push   %edi
  802522:	56                   	push   %esi
  802523:	53                   	push   %ebx
  802524:	83 ec 1c             	sub    $0x1c,%esp
  802527:	8b 7d 08             	mov    0x8(%ebp),%edi
  80252a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB : Your code here.
		int r =0;
	while(1){
		if(pg == 0)
  80252d:	85 f6                	test   %esi,%esi
  80252f:	75 22                	jne    802553 <ipc_send+0x35>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  802531:	8b 45 14             	mov    0x14(%ebp),%eax
  802534:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802538:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80253f:	ee 
  802540:	8b 45 0c             	mov    0xc(%ebp),%eax
  802543:	89 44 24 04          	mov    %eax,0x4(%esp)
  802547:	89 3c 24             	mov    %edi,(%esp)
  80254a:	e8 e7 fd ff ff       	call   802336 <sys_ipc_try_send>
  80254f:	89 c3                	mov    %eax,%ebx
  802551:	eb 1c                	jmp    80256f <ipc_send+0x51>
		else
			r = sys_ipc_try_send(to_env,  val, pg,  perm);
  802553:	8b 45 14             	mov    0x14(%ebp),%eax
  802556:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80255a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80255e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802561:	89 44 24 04          	mov    %eax,0x4(%esp)
  802565:	89 3c 24             	mov    %edi,(%esp)
  802568:	e8 c9 fd ff ff       	call   802336 <sys_ipc_try_send>
  80256d:	89 c3                	mov    %eax,%ebx

		if(r <0 && r != -E_IPC_NOT_RECV){
  80256f:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802572:	74 3e                	je     8025b2 <ipc_send+0x94>
  802574:	89 d8                	mov    %ebx,%eax
  802576:	c1 e8 1f             	shr    $0x1f,%eax
  802579:	84 c0                	test   %al,%al
  80257b:	74 35                	je     8025b2 <ipc_send+0x94>
			cprintf("the envid is %x\n", sys_getenvid());
  80257d:	e8 83 fb ff ff       	call   802105 <sys_getenvid>
  802582:	89 44 24 04          	mov    %eax,0x4(%esp)
  802586:	c7 04 24 fe 3f 80 00 	movl   $0x803ffe,(%esp)
  80258d:	e8 1a f1 ff ff       	call   8016ac <cprintf>
			panic("ipc_send is error, and the errno is %d\n", r);
  802592:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802596:	c7 44 24 08 cc 3f 80 	movl   $0x803fcc,0x8(%esp)
  80259d:	00 
  80259e:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8025a5:	00 
  8025a6:	c7 04 24 f4 3f 80 00 	movl   $0x803ff4,(%esp)
  8025ad:	e8 01 f0 ff ff       	call   8015b3 <_panic>
		}
		else if(r == -E_IPC_NOT_RECV)
  8025b2:	83 fb f9             	cmp    $0xfffffff9,%ebx
  8025b5:	75 0e                	jne    8025c5 <ipc_send+0xa7>
			sys_yield();
  8025b7:	e8 68 fb ff ff       	call   802124 <sys_yield>
		else break;
	}
  8025bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025c0:	e9 68 ff ff ff       	jmp    80252d <ipc_send+0xf>
	
}
  8025c5:	83 c4 1c             	add    $0x1c,%esp
  8025c8:	5b                   	pop    %ebx
  8025c9:	5e                   	pop    %esi
  8025ca:	5f                   	pop    %edi
  8025cb:	5d                   	pop    %ebp
  8025cc:	c3                   	ret    

008025cd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025cd:	55                   	push   %ebp
  8025ce:	89 e5                	mov    %esp,%ebp
  8025d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8025d3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8025d8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8025db:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8025e1:	8b 52 50             	mov    0x50(%edx),%edx
  8025e4:	39 ca                	cmp    %ecx,%edx
  8025e6:	75 0d                	jne    8025f5 <ipc_find_env+0x28>
			return envs[i].env_id;
  8025e8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8025eb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8025f0:	8b 40 40             	mov    0x40(%eax),%eax
  8025f3:	eb 0e                	jmp    802603 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025f5:	83 c0 01             	add    $0x1,%eax
  8025f8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025fd:	75 d9                	jne    8025d8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8025ff:	66 b8 00 00          	mov    $0x0,%ax
}
  802603:	5d                   	pop    %ebp
  802604:	c3                   	ret    

00802605 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802605:	55                   	push   %ebp
  802606:	89 e5                	mov    %esp,%ebp
  802608:	56                   	push   %esi
  802609:	53                   	push   %ebx
  80260a:	83 ec 10             	sub    $0x10,%esp
  80260d:	89 c6                	mov    %eax,%esi
  80260f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802611:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802618:	75 11                	jne    80262b <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80261a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  802621:	e8 a7 ff ff ff       	call   8025cd <ipc_find_env>
  802626:	a3 00 a0 80 00       	mov    %eax,0x80a000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80262b:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802632:	00 
  802633:	c7 44 24 08 00 b0 80 	movl   $0x80b000,0x8(%esp)
  80263a:	00 
  80263b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80263f:	a1 00 a0 80 00       	mov    0x80a000,%eax
  802644:	89 04 24             	mov    %eax,(%esp)
  802647:	e8 d2 fe ff ff       	call   80251e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80264c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802653:	00 
  802654:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802658:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80265f:	e8 1c fe ff ff       	call   802480 <ipc_recv>
}
  802664:	83 c4 10             	add    $0x10,%esp
  802667:	5b                   	pop    %ebx
  802668:	5e                   	pop    %esi
  802669:	5d                   	pop    %ebp
  80266a:	c3                   	ret    

0080266b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80266b:	55                   	push   %ebp
  80266c:	89 e5                	mov    %esp,%ebp
  80266e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802671:	8b 45 08             	mov    0x8(%ebp),%eax
  802674:	8b 40 0c             	mov    0xc(%eax),%eax
  802677:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  80267c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80267f:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802684:	ba 00 00 00 00       	mov    $0x0,%edx
  802689:	b8 02 00 00 00       	mov    $0x2,%eax
  80268e:	e8 72 ff ff ff       	call   802605 <fsipc>
}
  802693:	c9                   	leave  
  802694:	c3                   	ret    

00802695 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802695:	55                   	push   %ebp
  802696:	89 e5                	mov    %esp,%ebp
  802698:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80269b:	8b 45 08             	mov    0x8(%ebp),%eax
  80269e:	8b 40 0c             	mov    0xc(%eax),%eax
  8026a1:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  8026a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8026ab:	b8 06 00 00 00       	mov    $0x6,%eax
  8026b0:	e8 50 ff ff ff       	call   802605 <fsipc>
}
  8026b5:	c9                   	leave  
  8026b6:	c3                   	ret    

008026b7 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8026b7:	55                   	push   %ebp
  8026b8:	89 e5                	mov    %esp,%ebp
  8026ba:	53                   	push   %ebx
  8026bb:	83 ec 14             	sub    $0x14,%esp
  8026be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8026c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8026c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8026c7:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8026cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8026d1:	b8 05 00 00 00       	mov    $0x5,%eax
  8026d6:	e8 2a ff ff ff       	call   802605 <fsipc>
  8026db:	89 c2                	mov    %eax,%edx
  8026dd:	85 d2                	test   %edx,%edx
  8026df:	78 2b                	js     80270c <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8026e1:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  8026e8:	00 
  8026e9:	89 1c 24             	mov    %ebx,(%esp)
  8026ec:	e8 36 f6 ff ff       	call   801d27 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8026f1:	a1 80 b0 80 00       	mov    0x80b080,%eax
  8026f6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8026fc:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802701:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802707:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80270c:	83 c4 14             	add    $0x14,%esp
  80270f:	5b                   	pop    %ebx
  802710:	5d                   	pop    %ebp
  802711:	c3                   	ret    

00802712 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802712:	55                   	push   %ebp
  802713:	89 e5                	mov    %esp,%ebp
  802715:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  802718:	c7 44 24 08 0f 40 80 	movl   $0x80400f,0x8(%esp)
  80271f:	00 
  802720:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  802727:	00 
  802728:	c7 04 24 2d 40 80 00 	movl   $0x80402d,(%esp)
  80272f:	e8 7f ee ff ff       	call   8015b3 <_panic>

00802734 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802734:	55                   	push   %ebp
  802735:	89 e5                	mov    %esp,%ebp
  802737:	56                   	push   %esi
  802738:	53                   	push   %ebx
  802739:	83 ec 10             	sub    $0x10,%esp
  80273c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80273f:	8b 45 08             	mov    0x8(%ebp),%eax
  802742:	8b 40 0c             	mov    0xc(%eax),%eax
  802745:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  80274a:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802750:	ba 00 00 00 00       	mov    $0x0,%edx
  802755:	b8 03 00 00 00       	mov    $0x3,%eax
  80275a:	e8 a6 fe ff ff       	call   802605 <fsipc>
  80275f:	89 c3                	mov    %eax,%ebx
  802761:	85 c0                	test   %eax,%eax
  802763:	78 6a                	js     8027cf <devfile_read+0x9b>
		return r;
	assert(r <= n);
  802765:	39 c6                	cmp    %eax,%esi
  802767:	73 24                	jae    80278d <devfile_read+0x59>
  802769:	c7 44 24 0c 38 40 80 	movl   $0x804038,0xc(%esp)
  802770:	00 
  802771:	c7 44 24 08 9d 36 80 	movl   $0x80369d,0x8(%esp)
  802778:	00 
  802779:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  802780:	00 
  802781:	c7 04 24 2d 40 80 00 	movl   $0x80402d,(%esp)
  802788:	e8 26 ee ff ff       	call   8015b3 <_panic>
	assert(r <= PGSIZE);
  80278d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802792:	7e 24                	jle    8027b8 <devfile_read+0x84>
  802794:	c7 44 24 0c 3f 40 80 	movl   $0x80403f,0xc(%esp)
  80279b:	00 
  80279c:	c7 44 24 08 9d 36 80 	movl   $0x80369d,0x8(%esp)
  8027a3:	00 
  8027a4:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8027ab:	00 
  8027ac:	c7 04 24 2d 40 80 00 	movl   $0x80402d,(%esp)
  8027b3:	e8 fb ed ff ff       	call   8015b3 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8027b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8027bc:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  8027c3:	00 
  8027c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027c7:	89 04 24             	mov    %eax,(%esp)
  8027ca:	e8 f5 f6 ff ff       	call   801ec4 <memmove>
	return r;
}
  8027cf:	89 d8                	mov    %ebx,%eax
  8027d1:	83 c4 10             	add    $0x10,%esp
  8027d4:	5b                   	pop    %ebx
  8027d5:	5e                   	pop    %esi
  8027d6:	5d                   	pop    %ebp
  8027d7:	c3                   	ret    

008027d8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8027d8:	55                   	push   %ebp
  8027d9:	89 e5                	mov    %esp,%ebp
  8027db:	53                   	push   %ebx
  8027dc:	83 ec 24             	sub    $0x24,%esp
  8027df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8027e2:	89 1c 24             	mov    %ebx,(%esp)
  8027e5:	e8 06 f5 ff ff       	call   801cf0 <strlen>
  8027ea:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8027ef:	7f 60                	jg     802851 <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8027f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027f4:	89 04 24             	mov    %eax,(%esp)
  8027f7:	e8 db 00 00 00       	call   8028d7 <fd_alloc>
  8027fc:	89 c2                	mov    %eax,%edx
  8027fe:	85 d2                	test   %edx,%edx
  802800:	78 54                	js     802856 <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802802:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802806:	c7 04 24 00 b0 80 00 	movl   $0x80b000,(%esp)
  80280d:	e8 15 f5 ff ff       	call   801d27 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802812:	8b 45 0c             	mov    0xc(%ebp),%eax
  802815:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80281a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80281d:	b8 01 00 00 00       	mov    $0x1,%eax
  802822:	e8 de fd ff ff       	call   802605 <fsipc>
  802827:	89 c3                	mov    %eax,%ebx
  802829:	85 c0                	test   %eax,%eax
  80282b:	79 17                	jns    802844 <open+0x6c>
		fd_close(fd, 0);
  80282d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802834:	00 
  802835:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802838:	89 04 24             	mov    %eax,(%esp)
  80283b:	e8 91 01 00 00       	call   8029d1 <fd_close>
		return r;
  802840:	89 d8                	mov    %ebx,%eax
  802842:	eb 12                	jmp    802856 <open+0x7e>
	}

	return fd2num(fd);
  802844:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802847:	89 04 24             	mov    %eax,(%esp)
  80284a:	e8 61 00 00 00       	call   8028b0 <fd2num>
  80284f:	eb 05                	jmp    802856 <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802851:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802856:	83 c4 24             	add    $0x24,%esp
  802859:	5b                   	pop    %ebx
  80285a:	5d                   	pop    %ebp
  80285b:	c3                   	ret    

0080285c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80285c:	55                   	push   %ebp
  80285d:	89 e5                	mov    %esp,%ebp
  80285f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802862:	ba 00 00 00 00       	mov    $0x0,%edx
  802867:	b8 08 00 00 00       	mov    $0x8,%eax
  80286c:	e8 94 fd ff ff       	call   802605 <fsipc>
}
  802871:	c9                   	leave  
  802872:	c3                   	ret    

00802873 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802873:	55                   	push   %ebp
  802874:	89 e5                	mov    %esp,%ebp
  802876:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802879:	89 d0                	mov    %edx,%eax
  80287b:	c1 e8 16             	shr    $0x16,%eax
  80287e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802885:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80288a:	f6 c1 01             	test   $0x1,%cl
  80288d:	74 1d                	je     8028ac <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80288f:	c1 ea 0c             	shr    $0xc,%edx
  802892:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802899:	f6 c2 01             	test   $0x1,%dl
  80289c:	74 0e                	je     8028ac <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80289e:	c1 ea 0c             	shr    $0xc,%edx
  8028a1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8028a8:	ef 
  8028a9:	0f b7 c0             	movzwl %ax,%eax
}
  8028ac:	5d                   	pop    %ebp
  8028ad:	c3                   	ret    
  8028ae:	66 90                	xchg   %ax,%ax

008028b0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8028b0:	55                   	push   %ebp
  8028b1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8028b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8028b6:	05 00 00 00 30       	add    $0x30000000,%eax
  8028bb:	c1 e8 0c             	shr    $0xc,%eax
}
  8028be:	5d                   	pop    %ebp
  8028bf:	c3                   	ret    

008028c0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8028c0:	55                   	push   %ebp
  8028c1:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8028c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8028c6:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8028cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8028d0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8028d5:	5d                   	pop    %ebp
  8028d6:	c3                   	ret    

008028d7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8028d7:	55                   	push   %ebp
  8028d8:	89 e5                	mov    %esp,%ebp
  8028da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8028dd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8028e2:	89 c2                	mov    %eax,%edx
  8028e4:	c1 ea 16             	shr    $0x16,%edx
  8028e7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8028ee:	f6 c2 01             	test   $0x1,%dl
  8028f1:	74 11                	je     802904 <fd_alloc+0x2d>
  8028f3:	89 c2                	mov    %eax,%edx
  8028f5:	c1 ea 0c             	shr    $0xc,%edx
  8028f8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8028ff:	f6 c2 01             	test   $0x1,%dl
  802902:	75 09                	jne    80290d <fd_alloc+0x36>
			*fd_store = fd;
  802904:	89 01                	mov    %eax,(%ecx)
			return 0;
  802906:	b8 00 00 00 00       	mov    $0x0,%eax
  80290b:	eb 17                	jmp    802924 <fd_alloc+0x4d>
  80290d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802912:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802917:	75 c9                	jne    8028e2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802919:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80291f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802924:	5d                   	pop    %ebp
  802925:	c3                   	ret    

00802926 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802926:	55                   	push   %ebp
  802927:	89 e5                	mov    %esp,%ebp
  802929:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80292c:	83 f8 1f             	cmp    $0x1f,%eax
  80292f:	77 36                	ja     802967 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802931:	c1 e0 0c             	shl    $0xc,%eax
  802934:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802939:	89 c2                	mov    %eax,%edx
  80293b:	c1 ea 16             	shr    $0x16,%edx
  80293e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802945:	f6 c2 01             	test   $0x1,%dl
  802948:	74 24                	je     80296e <fd_lookup+0x48>
  80294a:	89 c2                	mov    %eax,%edx
  80294c:	c1 ea 0c             	shr    $0xc,%edx
  80294f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802956:	f6 c2 01             	test   $0x1,%dl
  802959:	74 1a                	je     802975 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80295b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80295e:	89 02                	mov    %eax,(%edx)
	return 0;
  802960:	b8 00 00 00 00       	mov    $0x0,%eax
  802965:	eb 13                	jmp    80297a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802967:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80296c:	eb 0c                	jmp    80297a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80296e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802973:	eb 05                	jmp    80297a <fd_lookup+0x54>
  802975:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80297a:	5d                   	pop    %ebp
  80297b:	c3                   	ret    

0080297c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80297c:	55                   	push   %ebp
  80297d:	89 e5                	mov    %esp,%ebp
  80297f:	83 ec 18             	sub    $0x18,%esp
  802982:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802985:	ba cc 40 80 00       	mov    $0x8040cc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80298a:	eb 13                	jmp    80299f <dev_lookup+0x23>
  80298c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80298f:	39 08                	cmp    %ecx,(%eax)
  802991:	75 0c                	jne    80299f <dev_lookup+0x23>
			*dev = devtab[i];
  802993:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802996:	89 01                	mov    %eax,(%ecx)
			return 0;
  802998:	b8 00 00 00 00       	mov    $0x0,%eax
  80299d:	eb 30                	jmp    8029cf <dev_lookup+0x53>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80299f:	8b 02                	mov    (%edx),%eax
  8029a1:	85 c0                	test   %eax,%eax
  8029a3:	75 e7                	jne    80298c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8029a5:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8029aa:	8b 40 48             	mov    0x48(%eax),%eax
  8029ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8029b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029b5:	c7 04 24 4c 40 80 00 	movl   $0x80404c,(%esp)
  8029bc:	e8 eb ec ff ff       	call   8016ac <cprintf>
	*dev = 0;
  8029c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8029ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8029cf:	c9                   	leave  
  8029d0:	c3                   	ret    

008029d1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8029d1:	55                   	push   %ebp
  8029d2:	89 e5                	mov    %esp,%ebp
  8029d4:	56                   	push   %esi
  8029d5:	53                   	push   %ebx
  8029d6:	83 ec 20             	sub    $0x20,%esp
  8029d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8029dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8029df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8029e2:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8029e6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8029ec:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8029ef:	89 04 24             	mov    %eax,(%esp)
  8029f2:	e8 2f ff ff ff       	call   802926 <fd_lookup>
  8029f7:	85 c0                	test   %eax,%eax
  8029f9:	78 05                	js     802a00 <fd_close+0x2f>
	    || fd != fd2)
  8029fb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8029fe:	74 0c                	je     802a0c <fd_close+0x3b>
		return (must_exist ? r : 0);
  802a00:	84 db                	test   %bl,%bl
  802a02:	ba 00 00 00 00       	mov    $0x0,%edx
  802a07:	0f 44 c2             	cmove  %edx,%eax
  802a0a:	eb 3f                	jmp    802a4b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802a0c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802a0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a13:	8b 06                	mov    (%esi),%eax
  802a15:	89 04 24             	mov    %eax,(%esp)
  802a18:	e8 5f ff ff ff       	call   80297c <dev_lookup>
  802a1d:	89 c3                	mov    %eax,%ebx
  802a1f:	85 c0                	test   %eax,%eax
  802a21:	78 16                	js     802a39 <fd_close+0x68>
		if (dev->dev_close)
  802a23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a26:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  802a29:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802a2e:	85 c0                	test   %eax,%eax
  802a30:	74 07                	je     802a39 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  802a32:	89 34 24             	mov    %esi,(%esp)
  802a35:	ff d0                	call   *%eax
  802a37:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802a39:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a3d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a44:	e8 a1 f7 ff ff       	call   8021ea <sys_page_unmap>
	return r;
  802a49:	89 d8                	mov    %ebx,%eax
}
  802a4b:	83 c4 20             	add    $0x20,%esp
  802a4e:	5b                   	pop    %ebx
  802a4f:	5e                   	pop    %esi
  802a50:	5d                   	pop    %ebp
  802a51:	c3                   	ret    

00802a52 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802a52:	55                   	push   %ebp
  802a53:	89 e5                	mov    %esp,%ebp
  802a55:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802a58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  802a62:	89 04 24             	mov    %eax,(%esp)
  802a65:	e8 bc fe ff ff       	call   802926 <fd_lookup>
  802a6a:	89 c2                	mov    %eax,%edx
  802a6c:	85 d2                	test   %edx,%edx
  802a6e:	78 13                	js     802a83 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  802a70:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802a77:	00 
  802a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a7b:	89 04 24             	mov    %eax,(%esp)
  802a7e:	e8 4e ff ff ff       	call   8029d1 <fd_close>
}
  802a83:	c9                   	leave  
  802a84:	c3                   	ret    

00802a85 <close_all>:

void
close_all(void)
{
  802a85:	55                   	push   %ebp
  802a86:	89 e5                	mov    %esp,%ebp
  802a88:	53                   	push   %ebx
  802a89:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802a8c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802a91:	89 1c 24             	mov    %ebx,(%esp)
  802a94:	e8 b9 ff ff ff       	call   802a52 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802a99:	83 c3 01             	add    $0x1,%ebx
  802a9c:	83 fb 20             	cmp    $0x20,%ebx
  802a9f:	75 f0                	jne    802a91 <close_all+0xc>
		close(i);
}
  802aa1:	83 c4 14             	add    $0x14,%esp
  802aa4:	5b                   	pop    %ebx
  802aa5:	5d                   	pop    %ebp
  802aa6:	c3                   	ret    

00802aa7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802aa7:	55                   	push   %ebp
  802aa8:	89 e5                	mov    %esp,%ebp
  802aaa:	57                   	push   %edi
  802aab:	56                   	push   %esi
  802aac:	53                   	push   %ebx
  802aad:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802ab0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802ab3:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  802aba:	89 04 24             	mov    %eax,(%esp)
  802abd:	e8 64 fe ff ff       	call   802926 <fd_lookup>
  802ac2:	89 c2                	mov    %eax,%edx
  802ac4:	85 d2                	test   %edx,%edx
  802ac6:	0f 88 e1 00 00 00    	js     802bad <dup+0x106>
		return r;
	close(newfdnum);
  802acc:	8b 45 0c             	mov    0xc(%ebp),%eax
  802acf:	89 04 24             	mov    %eax,(%esp)
  802ad2:	e8 7b ff ff ff       	call   802a52 <close>

	newfd = INDEX2FD(newfdnum);
  802ad7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802ada:	c1 e3 0c             	shl    $0xc,%ebx
  802add:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802ae3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802ae6:	89 04 24             	mov    %eax,(%esp)
  802ae9:	e8 d2 fd ff ff       	call   8028c0 <fd2data>
  802aee:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  802af0:	89 1c 24             	mov    %ebx,(%esp)
  802af3:	e8 c8 fd ff ff       	call   8028c0 <fd2data>
  802af8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802afa:	89 f0                	mov    %esi,%eax
  802afc:	c1 e8 16             	shr    $0x16,%eax
  802aff:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802b06:	a8 01                	test   $0x1,%al
  802b08:	74 43                	je     802b4d <dup+0xa6>
  802b0a:	89 f0                	mov    %esi,%eax
  802b0c:	c1 e8 0c             	shr    $0xc,%eax
  802b0f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802b16:	f6 c2 01             	test   $0x1,%dl
  802b19:	74 32                	je     802b4d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802b1b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802b22:	25 07 0e 00 00       	and    $0xe07,%eax
  802b27:	89 44 24 10          	mov    %eax,0x10(%esp)
  802b2b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802b2f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802b36:	00 
  802b37:	89 74 24 04          	mov    %esi,0x4(%esp)
  802b3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b42:	e8 50 f6 ff ff       	call   802197 <sys_page_map>
  802b47:	89 c6                	mov    %eax,%esi
  802b49:	85 c0                	test   %eax,%eax
  802b4b:	78 3e                	js     802b8b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802b4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802b50:	89 c2                	mov    %eax,%edx
  802b52:	c1 ea 0c             	shr    $0xc,%edx
  802b55:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802b5c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  802b62:	89 54 24 10          	mov    %edx,0x10(%esp)
  802b66:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802b6a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802b71:	00 
  802b72:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b76:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b7d:	e8 15 f6 ff ff       	call   802197 <sys_page_map>
  802b82:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  802b84:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802b87:	85 f6                	test   %esi,%esi
  802b89:	79 22                	jns    802bad <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802b8b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802b8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b96:	e8 4f f6 ff ff       	call   8021ea <sys_page_unmap>
	sys_page_unmap(0, nva);
  802b9b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802b9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ba6:	e8 3f f6 ff ff       	call   8021ea <sys_page_unmap>
	return r;
  802bab:	89 f0                	mov    %esi,%eax
}
  802bad:	83 c4 3c             	add    $0x3c,%esp
  802bb0:	5b                   	pop    %ebx
  802bb1:	5e                   	pop    %esi
  802bb2:	5f                   	pop    %edi
  802bb3:	5d                   	pop    %ebp
  802bb4:	c3                   	ret    

00802bb5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802bb5:	55                   	push   %ebp
  802bb6:	89 e5                	mov    %esp,%ebp
  802bb8:	53                   	push   %ebx
  802bb9:	83 ec 24             	sub    $0x24,%esp
  802bbc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802bbf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802bc2:	89 44 24 04          	mov    %eax,0x4(%esp)
  802bc6:	89 1c 24             	mov    %ebx,(%esp)
  802bc9:	e8 58 fd ff ff       	call   802926 <fd_lookup>
  802bce:	89 c2                	mov    %eax,%edx
  802bd0:	85 d2                	test   %edx,%edx
  802bd2:	78 6d                	js     802c41 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802bd4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  802bdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bde:	8b 00                	mov    (%eax),%eax
  802be0:	89 04 24             	mov    %eax,(%esp)
  802be3:	e8 94 fd ff ff       	call   80297c <dev_lookup>
  802be8:	85 c0                	test   %eax,%eax
  802bea:	78 55                	js     802c41 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802bec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bef:	8b 50 08             	mov    0x8(%eax),%edx
  802bf2:	83 e2 03             	and    $0x3,%edx
  802bf5:	83 fa 01             	cmp    $0x1,%edx
  802bf8:	75 23                	jne    802c1d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802bfa:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802bff:	8b 40 48             	mov    0x48(%eax),%eax
  802c02:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802c06:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c0a:	c7 04 24 90 40 80 00 	movl   $0x804090,(%esp)
  802c11:	e8 96 ea ff ff       	call   8016ac <cprintf>
		return -E_INVAL;
  802c16:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802c1b:	eb 24                	jmp    802c41 <read+0x8c>
	}
	if (!dev->dev_read)
  802c1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802c20:	8b 52 08             	mov    0x8(%edx),%edx
  802c23:	85 d2                	test   %edx,%edx
  802c25:	74 15                	je     802c3c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802c27:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802c2a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802c2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c31:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802c35:	89 04 24             	mov    %eax,(%esp)
  802c38:	ff d2                	call   *%edx
  802c3a:	eb 05                	jmp    802c41 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802c3c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  802c41:	83 c4 24             	add    $0x24,%esp
  802c44:	5b                   	pop    %ebx
  802c45:	5d                   	pop    %ebp
  802c46:	c3                   	ret    

00802c47 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802c47:	55                   	push   %ebp
  802c48:	89 e5                	mov    %esp,%ebp
  802c4a:	57                   	push   %edi
  802c4b:	56                   	push   %esi
  802c4c:	53                   	push   %ebx
  802c4d:	83 ec 1c             	sub    $0x1c,%esp
  802c50:	8b 7d 08             	mov    0x8(%ebp),%edi
  802c53:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802c56:	bb 00 00 00 00       	mov    $0x0,%ebx
  802c5b:	eb 23                	jmp    802c80 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802c5d:	89 f0                	mov    %esi,%eax
  802c5f:	29 d8                	sub    %ebx,%eax
  802c61:	89 44 24 08          	mov    %eax,0x8(%esp)
  802c65:	89 d8                	mov    %ebx,%eax
  802c67:	03 45 0c             	add    0xc(%ebp),%eax
  802c6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c6e:	89 3c 24             	mov    %edi,(%esp)
  802c71:	e8 3f ff ff ff       	call   802bb5 <read>
		if (m < 0)
  802c76:	85 c0                	test   %eax,%eax
  802c78:	78 10                	js     802c8a <readn+0x43>
			return m;
		if (m == 0)
  802c7a:	85 c0                	test   %eax,%eax
  802c7c:	74 0a                	je     802c88 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802c7e:	01 c3                	add    %eax,%ebx
  802c80:	39 f3                	cmp    %esi,%ebx
  802c82:	72 d9                	jb     802c5d <readn+0x16>
  802c84:	89 d8                	mov    %ebx,%eax
  802c86:	eb 02                	jmp    802c8a <readn+0x43>
  802c88:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802c8a:	83 c4 1c             	add    $0x1c,%esp
  802c8d:	5b                   	pop    %ebx
  802c8e:	5e                   	pop    %esi
  802c8f:	5f                   	pop    %edi
  802c90:	5d                   	pop    %ebp
  802c91:	c3                   	ret    

00802c92 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802c92:	55                   	push   %ebp
  802c93:	89 e5                	mov    %esp,%ebp
  802c95:	53                   	push   %ebx
  802c96:	83 ec 24             	sub    $0x24,%esp
  802c99:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c9c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ca3:	89 1c 24             	mov    %ebx,(%esp)
  802ca6:	e8 7b fc ff ff       	call   802926 <fd_lookup>
  802cab:	89 c2                	mov    %eax,%edx
  802cad:	85 d2                	test   %edx,%edx
  802caf:	78 68                	js     802d19 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802cb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802cb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  802cb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cbb:	8b 00                	mov    (%eax),%eax
  802cbd:	89 04 24             	mov    %eax,(%esp)
  802cc0:	e8 b7 fc ff ff       	call   80297c <dev_lookup>
  802cc5:	85 c0                	test   %eax,%eax
  802cc7:	78 50                	js     802d19 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802cc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ccc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802cd0:	75 23                	jne    802cf5 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802cd2:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802cd7:	8b 40 48             	mov    0x48(%eax),%eax
  802cda:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802cde:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ce2:	c7 04 24 ac 40 80 00 	movl   $0x8040ac,(%esp)
  802ce9:	e8 be e9 ff ff       	call   8016ac <cprintf>
		return -E_INVAL;
  802cee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802cf3:	eb 24                	jmp    802d19 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802cf5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802cf8:	8b 52 0c             	mov    0xc(%edx),%edx
  802cfb:	85 d2                	test   %edx,%edx
  802cfd:	74 15                	je     802d14 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802cff:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802d02:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802d06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802d09:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802d0d:	89 04 24             	mov    %eax,(%esp)
  802d10:	ff d2                	call   *%edx
  802d12:	eb 05                	jmp    802d19 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802d14:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  802d19:	83 c4 24             	add    $0x24,%esp
  802d1c:	5b                   	pop    %ebx
  802d1d:	5d                   	pop    %ebp
  802d1e:	c3                   	ret    

00802d1f <seek>:

int
seek(int fdnum, off_t offset)
{
  802d1f:	55                   	push   %ebp
  802d20:	89 e5                	mov    %esp,%ebp
  802d22:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802d25:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802d28:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d2c:	8b 45 08             	mov    0x8(%ebp),%eax
  802d2f:	89 04 24             	mov    %eax,(%esp)
  802d32:	e8 ef fb ff ff       	call   802926 <fd_lookup>
  802d37:	85 c0                	test   %eax,%eax
  802d39:	78 0e                	js     802d49 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  802d3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802d3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802d41:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802d44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802d49:	c9                   	leave  
  802d4a:	c3                   	ret    

00802d4b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802d4b:	55                   	push   %ebp
  802d4c:	89 e5                	mov    %esp,%ebp
  802d4e:	53                   	push   %ebx
  802d4f:	83 ec 24             	sub    $0x24,%esp
  802d52:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802d55:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d58:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d5c:	89 1c 24             	mov    %ebx,(%esp)
  802d5f:	e8 c2 fb ff ff       	call   802926 <fd_lookup>
  802d64:	89 c2                	mov    %eax,%edx
  802d66:	85 d2                	test   %edx,%edx
  802d68:	78 61                	js     802dcb <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d6a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d74:	8b 00                	mov    (%eax),%eax
  802d76:	89 04 24             	mov    %eax,(%esp)
  802d79:	e8 fe fb ff ff       	call   80297c <dev_lookup>
  802d7e:	85 c0                	test   %eax,%eax
  802d80:	78 49                	js     802dcb <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802d82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d85:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802d89:	75 23                	jne    802dae <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802d8b:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802d90:	8b 40 48             	mov    0x48(%eax),%eax
  802d93:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802d97:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d9b:	c7 04 24 6c 40 80 00 	movl   $0x80406c,(%esp)
  802da2:	e8 05 e9 ff ff       	call   8016ac <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802da7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802dac:	eb 1d                	jmp    802dcb <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  802dae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802db1:	8b 52 18             	mov    0x18(%edx),%edx
  802db4:	85 d2                	test   %edx,%edx
  802db6:	74 0e                	je     802dc6 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802db8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802dbb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802dbf:	89 04 24             	mov    %eax,(%esp)
  802dc2:	ff d2                	call   *%edx
  802dc4:	eb 05                	jmp    802dcb <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802dc6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  802dcb:	83 c4 24             	add    $0x24,%esp
  802dce:	5b                   	pop    %ebx
  802dcf:	5d                   	pop    %ebp
  802dd0:	c3                   	ret    

00802dd1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802dd1:	55                   	push   %ebp
  802dd2:	89 e5                	mov    %esp,%ebp
  802dd4:	53                   	push   %ebx
  802dd5:	83 ec 24             	sub    $0x24,%esp
  802dd8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802ddb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802dde:	89 44 24 04          	mov    %eax,0x4(%esp)
  802de2:	8b 45 08             	mov    0x8(%ebp),%eax
  802de5:	89 04 24             	mov    %eax,(%esp)
  802de8:	e8 39 fb ff ff       	call   802926 <fd_lookup>
  802ded:	89 c2                	mov    %eax,%edx
  802def:	85 d2                	test   %edx,%edx
  802df1:	78 52                	js     802e45 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802df3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802df6:	89 44 24 04          	mov    %eax,0x4(%esp)
  802dfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802dfd:	8b 00                	mov    (%eax),%eax
  802dff:	89 04 24             	mov    %eax,(%esp)
  802e02:	e8 75 fb ff ff       	call   80297c <dev_lookup>
  802e07:	85 c0                	test   %eax,%eax
  802e09:	78 3a                	js     802e45 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  802e0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e0e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802e12:	74 2c                	je     802e40 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802e14:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802e17:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802e1e:	00 00 00 
	stat->st_isdir = 0;
  802e21:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802e28:	00 00 00 
	stat->st_dev = dev;
  802e2b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802e31:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802e35:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802e38:	89 14 24             	mov    %edx,(%esp)
  802e3b:	ff 50 14             	call   *0x14(%eax)
  802e3e:	eb 05                	jmp    802e45 <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802e40:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802e45:	83 c4 24             	add    $0x24,%esp
  802e48:	5b                   	pop    %ebx
  802e49:	5d                   	pop    %ebp
  802e4a:	c3                   	ret    

00802e4b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802e4b:	55                   	push   %ebp
  802e4c:	89 e5                	mov    %esp,%ebp
  802e4e:	56                   	push   %esi
  802e4f:	53                   	push   %ebx
  802e50:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802e53:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802e5a:	00 
  802e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  802e5e:	89 04 24             	mov    %eax,(%esp)
  802e61:	e8 72 f9 ff ff       	call   8027d8 <open>
  802e66:	89 c3                	mov    %eax,%ebx
  802e68:	85 db                	test   %ebx,%ebx
  802e6a:	78 1b                	js     802e87 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  802e6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e73:	89 1c 24             	mov    %ebx,(%esp)
  802e76:	e8 56 ff ff ff       	call   802dd1 <fstat>
  802e7b:	89 c6                	mov    %eax,%esi
	close(fd);
  802e7d:	89 1c 24             	mov    %ebx,(%esp)
  802e80:	e8 cd fb ff ff       	call   802a52 <close>
	return r;
  802e85:	89 f0                	mov    %esi,%eax
}
  802e87:	83 c4 10             	add    $0x10,%esp
  802e8a:	5b                   	pop    %ebx
  802e8b:	5e                   	pop    %esi
  802e8c:	5d                   	pop    %ebp
  802e8d:	c3                   	ret    

00802e8e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802e8e:	55                   	push   %ebp
  802e8f:	89 e5                	mov    %esp,%ebp
  802e91:	56                   	push   %esi
  802e92:	53                   	push   %ebx
  802e93:	83 ec 10             	sub    $0x10,%esp
  802e96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802e99:	8b 45 08             	mov    0x8(%ebp),%eax
  802e9c:	89 04 24             	mov    %eax,(%esp)
  802e9f:	e8 1c fa ff ff       	call   8028c0 <fd2data>
  802ea4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802ea6:	c7 44 24 04 dc 40 80 	movl   $0x8040dc,0x4(%esp)
  802ead:	00 
  802eae:	89 1c 24             	mov    %ebx,(%esp)
  802eb1:	e8 71 ee ff ff       	call   801d27 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802eb6:	8b 46 04             	mov    0x4(%esi),%eax
  802eb9:	2b 06                	sub    (%esi),%eax
  802ebb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802ec1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802ec8:	00 00 00 
	stat->st_dev = &devpipe;
  802ecb:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  802ed2:	90 80 00 
	return 0;
}
  802ed5:	b8 00 00 00 00       	mov    $0x0,%eax
  802eda:	83 c4 10             	add    $0x10,%esp
  802edd:	5b                   	pop    %ebx
  802ede:	5e                   	pop    %esi
  802edf:	5d                   	pop    %ebp
  802ee0:	c3                   	ret    

00802ee1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802ee1:	55                   	push   %ebp
  802ee2:	89 e5                	mov    %esp,%ebp
  802ee4:	53                   	push   %ebx
  802ee5:	83 ec 14             	sub    $0x14,%esp
  802ee8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802eeb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802eef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ef6:	e8 ef f2 ff ff       	call   8021ea <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802efb:	89 1c 24             	mov    %ebx,(%esp)
  802efe:	e8 bd f9 ff ff       	call   8028c0 <fd2data>
  802f03:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f0e:	e8 d7 f2 ff ff       	call   8021ea <sys_page_unmap>
}
  802f13:	83 c4 14             	add    $0x14,%esp
  802f16:	5b                   	pop    %ebx
  802f17:	5d                   	pop    %ebp
  802f18:	c3                   	ret    

00802f19 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802f19:	55                   	push   %ebp
  802f1a:	89 e5                	mov    %esp,%ebp
  802f1c:	57                   	push   %edi
  802f1d:	56                   	push   %esi
  802f1e:	53                   	push   %ebx
  802f1f:	83 ec 2c             	sub    $0x2c,%esp
  802f22:	89 c6                	mov    %eax,%esi
  802f24:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802f27:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802f2c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802f2f:	89 34 24             	mov    %esi,(%esp)
  802f32:	e8 3c f9 ff ff       	call   802873 <pageref>
  802f37:	89 c7                	mov    %eax,%edi
  802f39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802f3c:	89 04 24             	mov    %eax,(%esp)
  802f3f:	e8 2f f9 ff ff       	call   802873 <pageref>
  802f44:	39 c7                	cmp    %eax,%edi
  802f46:	0f 94 c2             	sete   %dl
  802f49:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  802f4c:	8b 0d 0c a0 80 00    	mov    0x80a00c,%ecx
  802f52:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  802f55:	39 fb                	cmp    %edi,%ebx
  802f57:	74 21                	je     802f7a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802f59:	84 d2                	test   %dl,%dl
  802f5b:	74 ca                	je     802f27 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802f5d:	8b 51 58             	mov    0x58(%ecx),%edx
  802f60:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802f64:	89 54 24 08          	mov    %edx,0x8(%esp)
  802f68:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802f6c:	c7 04 24 e3 40 80 00 	movl   $0x8040e3,(%esp)
  802f73:	e8 34 e7 ff ff       	call   8016ac <cprintf>
  802f78:	eb ad                	jmp    802f27 <_pipeisclosed+0xe>
	}
}
  802f7a:	83 c4 2c             	add    $0x2c,%esp
  802f7d:	5b                   	pop    %ebx
  802f7e:	5e                   	pop    %esi
  802f7f:	5f                   	pop    %edi
  802f80:	5d                   	pop    %ebp
  802f81:	c3                   	ret    

00802f82 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802f82:	55                   	push   %ebp
  802f83:	89 e5                	mov    %esp,%ebp
  802f85:	57                   	push   %edi
  802f86:	56                   	push   %esi
  802f87:	53                   	push   %ebx
  802f88:	83 ec 1c             	sub    $0x1c,%esp
  802f8b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802f8e:	89 34 24             	mov    %esi,(%esp)
  802f91:	e8 2a f9 ff ff       	call   8028c0 <fd2data>
  802f96:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802f98:	bf 00 00 00 00       	mov    $0x0,%edi
  802f9d:	eb 45                	jmp    802fe4 <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802f9f:	89 da                	mov    %ebx,%edx
  802fa1:	89 f0                	mov    %esi,%eax
  802fa3:	e8 71 ff ff ff       	call   802f19 <_pipeisclosed>
  802fa8:	85 c0                	test   %eax,%eax
  802faa:	75 41                	jne    802fed <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802fac:	e8 73 f1 ff ff       	call   802124 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802fb1:	8b 43 04             	mov    0x4(%ebx),%eax
  802fb4:	8b 0b                	mov    (%ebx),%ecx
  802fb6:	8d 51 20             	lea    0x20(%ecx),%edx
  802fb9:	39 d0                	cmp    %edx,%eax
  802fbb:	73 e2                	jae    802f9f <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802fbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802fc0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802fc4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802fc7:	99                   	cltd   
  802fc8:	c1 ea 1b             	shr    $0x1b,%edx
  802fcb:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  802fce:	83 e1 1f             	and    $0x1f,%ecx
  802fd1:	29 d1                	sub    %edx,%ecx
  802fd3:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802fd7:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802fdb:	83 c0 01             	add    $0x1,%eax
  802fde:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802fe1:	83 c7 01             	add    $0x1,%edi
  802fe4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802fe7:	75 c8                	jne    802fb1 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802fe9:	89 f8                	mov    %edi,%eax
  802feb:	eb 05                	jmp    802ff2 <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802fed:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802ff2:	83 c4 1c             	add    $0x1c,%esp
  802ff5:	5b                   	pop    %ebx
  802ff6:	5e                   	pop    %esi
  802ff7:	5f                   	pop    %edi
  802ff8:	5d                   	pop    %ebp
  802ff9:	c3                   	ret    

00802ffa <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802ffa:	55                   	push   %ebp
  802ffb:	89 e5                	mov    %esp,%ebp
  802ffd:	57                   	push   %edi
  802ffe:	56                   	push   %esi
  802fff:	53                   	push   %ebx
  803000:	83 ec 1c             	sub    $0x1c,%esp
  803003:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  803006:	89 3c 24             	mov    %edi,(%esp)
  803009:	e8 b2 f8 ff ff       	call   8028c0 <fd2data>
  80300e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803010:	be 00 00 00 00       	mov    $0x0,%esi
  803015:	eb 3d                	jmp    803054 <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  803017:	85 f6                	test   %esi,%esi
  803019:	74 04                	je     80301f <devpipe_read+0x25>
				return i;
  80301b:	89 f0                	mov    %esi,%eax
  80301d:	eb 43                	jmp    803062 <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80301f:	89 da                	mov    %ebx,%edx
  803021:	89 f8                	mov    %edi,%eax
  803023:	e8 f1 fe ff ff       	call   802f19 <_pipeisclosed>
  803028:	85 c0                	test   %eax,%eax
  80302a:	75 31                	jne    80305d <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80302c:	e8 f3 f0 ff ff       	call   802124 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  803031:	8b 03                	mov    (%ebx),%eax
  803033:	3b 43 04             	cmp    0x4(%ebx),%eax
  803036:	74 df                	je     803017 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803038:	99                   	cltd   
  803039:	c1 ea 1b             	shr    $0x1b,%edx
  80303c:	01 d0                	add    %edx,%eax
  80303e:	83 e0 1f             	and    $0x1f,%eax
  803041:	29 d0                	sub    %edx,%eax
  803043:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  803048:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80304b:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80304e:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803051:	83 c6 01             	add    $0x1,%esi
  803054:	3b 75 10             	cmp    0x10(%ebp),%esi
  803057:	75 d8                	jne    803031 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803059:	89 f0                	mov    %esi,%eax
  80305b:	eb 05                	jmp    803062 <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80305d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  803062:	83 c4 1c             	add    $0x1c,%esp
  803065:	5b                   	pop    %ebx
  803066:	5e                   	pop    %esi
  803067:	5f                   	pop    %edi
  803068:	5d                   	pop    %ebp
  803069:	c3                   	ret    

0080306a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80306a:	55                   	push   %ebp
  80306b:	89 e5                	mov    %esp,%ebp
  80306d:	56                   	push   %esi
  80306e:	53                   	push   %ebx
  80306f:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  803072:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803075:	89 04 24             	mov    %eax,(%esp)
  803078:	e8 5a f8 ff ff       	call   8028d7 <fd_alloc>
  80307d:	89 c2                	mov    %eax,%edx
  80307f:	85 d2                	test   %edx,%edx
  803081:	0f 88 4d 01 00 00    	js     8031d4 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803087:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80308e:	00 
  80308f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803092:	89 44 24 04          	mov    %eax,0x4(%esp)
  803096:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80309d:	e8 a1 f0 ff ff       	call   802143 <sys_page_alloc>
  8030a2:	89 c2                	mov    %eax,%edx
  8030a4:	85 d2                	test   %edx,%edx
  8030a6:	0f 88 28 01 00 00    	js     8031d4 <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8030ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8030af:	89 04 24             	mov    %eax,(%esp)
  8030b2:	e8 20 f8 ff ff       	call   8028d7 <fd_alloc>
  8030b7:	89 c3                	mov    %eax,%ebx
  8030b9:	85 c0                	test   %eax,%eax
  8030bb:	0f 88 fe 00 00 00    	js     8031bf <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8030c1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8030c8:	00 
  8030c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8030cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8030d7:	e8 67 f0 ff ff       	call   802143 <sys_page_alloc>
  8030dc:	89 c3                	mov    %eax,%ebx
  8030de:	85 c0                	test   %eax,%eax
  8030e0:	0f 88 d9 00 00 00    	js     8031bf <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8030e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8030e9:	89 04 24             	mov    %eax,(%esp)
  8030ec:	e8 cf f7 ff ff       	call   8028c0 <fd2data>
  8030f1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8030f3:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8030fa:	00 
  8030fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803106:	e8 38 f0 ff ff       	call   802143 <sys_page_alloc>
  80310b:	89 c3                	mov    %eax,%ebx
  80310d:	85 c0                	test   %eax,%eax
  80310f:	0f 88 97 00 00 00    	js     8031ac <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803115:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803118:	89 04 24             	mov    %eax,(%esp)
  80311b:	e8 a0 f7 ff ff       	call   8028c0 <fd2data>
  803120:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  803127:	00 
  803128:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80312c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803133:	00 
  803134:	89 74 24 04          	mov    %esi,0x4(%esp)
  803138:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80313f:	e8 53 f0 ff ff       	call   802197 <sys_page_map>
  803144:	89 c3                	mov    %eax,%ebx
  803146:	85 c0                	test   %eax,%eax
  803148:	78 52                	js     80319c <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80314a:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803150:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803153:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803155:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803158:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80315f:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803165:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803168:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80316a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80316d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803174:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803177:	89 04 24             	mov    %eax,(%esp)
  80317a:	e8 31 f7 ff ff       	call   8028b0 <fd2num>
  80317f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803182:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  803184:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803187:	89 04 24             	mov    %eax,(%esp)
  80318a:	e8 21 f7 ff ff       	call   8028b0 <fd2num>
  80318f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803192:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803195:	b8 00 00 00 00       	mov    $0x0,%eax
  80319a:	eb 38                	jmp    8031d4 <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  80319c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8031a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8031a7:	e8 3e f0 ff ff       	call   8021ea <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8031ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8031af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8031ba:	e8 2b f0 ff ff       	call   8021ea <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8031bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8031c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8031cd:	e8 18 f0 ff ff       	call   8021ea <sys_page_unmap>
  8031d2:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  8031d4:	83 c4 30             	add    $0x30,%esp
  8031d7:	5b                   	pop    %ebx
  8031d8:	5e                   	pop    %esi
  8031d9:	5d                   	pop    %ebp
  8031da:	c3                   	ret    

008031db <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8031db:	55                   	push   %ebp
  8031dc:	89 e5                	mov    %esp,%ebp
  8031de:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8031e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8031e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8031eb:	89 04 24             	mov    %eax,(%esp)
  8031ee:	e8 33 f7 ff ff       	call   802926 <fd_lookup>
  8031f3:	89 c2                	mov    %eax,%edx
  8031f5:	85 d2                	test   %edx,%edx
  8031f7:	78 15                	js     80320e <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8031f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8031fc:	89 04 24             	mov    %eax,(%esp)
  8031ff:	e8 bc f6 ff ff       	call   8028c0 <fd2data>
	return _pipeisclosed(fd, p);
  803204:	89 c2                	mov    %eax,%edx
  803206:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803209:	e8 0b fd ff ff       	call   802f19 <_pipeisclosed>
}
  80320e:	c9                   	leave  
  80320f:	c3                   	ret    

00803210 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  803210:	55                   	push   %ebp
  803211:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  803213:	b8 00 00 00 00       	mov    $0x0,%eax
  803218:	5d                   	pop    %ebp
  803219:	c3                   	ret    

0080321a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80321a:	55                   	push   %ebp
  80321b:	89 e5                	mov    %esp,%ebp
  80321d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  803220:	c7 44 24 04 fb 40 80 	movl   $0x8040fb,0x4(%esp)
  803227:	00 
  803228:	8b 45 0c             	mov    0xc(%ebp),%eax
  80322b:	89 04 24             	mov    %eax,(%esp)
  80322e:	e8 f4 ea ff ff       	call   801d27 <strcpy>
	return 0;
}
  803233:	b8 00 00 00 00       	mov    $0x0,%eax
  803238:	c9                   	leave  
  803239:	c3                   	ret    

0080323a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80323a:	55                   	push   %ebp
  80323b:	89 e5                	mov    %esp,%ebp
  80323d:	57                   	push   %edi
  80323e:	56                   	push   %esi
  80323f:	53                   	push   %ebx
  803240:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803246:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80324b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803251:	eb 31                	jmp    803284 <devcons_write+0x4a>
		m = n - tot;
  803253:	8b 75 10             	mov    0x10(%ebp),%esi
  803256:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  803258:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80325b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  803260:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803263:	89 74 24 08          	mov    %esi,0x8(%esp)
  803267:	03 45 0c             	add    0xc(%ebp),%eax
  80326a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80326e:	89 3c 24             	mov    %edi,(%esp)
  803271:	e8 4e ec ff ff       	call   801ec4 <memmove>
		sys_cputs(buf, m);
  803276:	89 74 24 04          	mov    %esi,0x4(%esp)
  80327a:	89 3c 24             	mov    %edi,(%esp)
  80327d:	e8 f4 ed ff ff       	call   802076 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803282:	01 f3                	add    %esi,%ebx
  803284:	89 d8                	mov    %ebx,%eax
  803286:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803289:	72 c8                	jb     803253 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80328b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  803291:	5b                   	pop    %ebx
  803292:	5e                   	pop    %esi
  803293:	5f                   	pop    %edi
  803294:	5d                   	pop    %ebp
  803295:	c3                   	ret    

00803296 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  803296:	55                   	push   %ebp
  803297:	89 e5                	mov    %esp,%ebp
  803299:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80329c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8032a1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8032a5:	75 07                	jne    8032ae <devcons_read+0x18>
  8032a7:	eb 2a                	jmp    8032d3 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8032a9:	e8 76 ee ff ff       	call   802124 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8032ae:	66 90                	xchg   %ax,%ax
  8032b0:	e8 df ed ff ff       	call   802094 <sys_cgetc>
  8032b5:	85 c0                	test   %eax,%eax
  8032b7:	74 f0                	je     8032a9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8032b9:	85 c0                	test   %eax,%eax
  8032bb:	78 16                	js     8032d3 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8032bd:	83 f8 04             	cmp    $0x4,%eax
  8032c0:	74 0c                	je     8032ce <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  8032c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8032c5:	88 02                	mov    %al,(%edx)
	return 1;
  8032c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8032cc:	eb 05                	jmp    8032d3 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8032ce:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8032d3:	c9                   	leave  
  8032d4:	c3                   	ret    

008032d5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8032d5:	55                   	push   %ebp
  8032d6:	89 e5                	mov    %esp,%ebp
  8032d8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8032db:	8b 45 08             	mov    0x8(%ebp),%eax
  8032de:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8032e1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8032e8:	00 
  8032e9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8032ec:	89 04 24             	mov    %eax,(%esp)
  8032ef:	e8 82 ed ff ff       	call   802076 <sys_cputs>
}
  8032f4:	c9                   	leave  
  8032f5:	c3                   	ret    

008032f6 <getchar>:

int
getchar(void)
{
  8032f6:	55                   	push   %ebp
  8032f7:	89 e5                	mov    %esp,%ebp
  8032f9:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8032fc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  803303:	00 
  803304:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803307:	89 44 24 04          	mov    %eax,0x4(%esp)
  80330b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803312:	e8 9e f8 ff ff       	call   802bb5 <read>
	if (r < 0)
  803317:	85 c0                	test   %eax,%eax
  803319:	78 0f                	js     80332a <getchar+0x34>
		return r;
	if (r < 1)
  80331b:	85 c0                	test   %eax,%eax
  80331d:	7e 06                	jle    803325 <getchar+0x2f>
		return -E_EOF;
	return c;
  80331f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  803323:	eb 05                	jmp    80332a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  803325:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80332a:	c9                   	leave  
  80332b:	c3                   	ret    

0080332c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80332c:	55                   	push   %ebp
  80332d:	89 e5                	mov    %esp,%ebp
  80332f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803332:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803335:	89 44 24 04          	mov    %eax,0x4(%esp)
  803339:	8b 45 08             	mov    0x8(%ebp),%eax
  80333c:	89 04 24             	mov    %eax,(%esp)
  80333f:	e8 e2 f5 ff ff       	call   802926 <fd_lookup>
  803344:	85 c0                	test   %eax,%eax
  803346:	78 11                	js     803359 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  803348:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80334b:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803351:	39 10                	cmp    %edx,(%eax)
  803353:	0f 94 c0             	sete   %al
  803356:	0f b6 c0             	movzbl %al,%eax
}
  803359:	c9                   	leave  
  80335a:	c3                   	ret    

0080335b <opencons>:

int
opencons(void)
{
  80335b:	55                   	push   %ebp
  80335c:	89 e5                	mov    %esp,%ebp
  80335e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803361:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803364:	89 04 24             	mov    %eax,(%esp)
  803367:	e8 6b f5 ff ff       	call   8028d7 <fd_alloc>
		return r;
  80336c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80336e:	85 c0                	test   %eax,%eax
  803370:	78 40                	js     8033b2 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803372:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803379:	00 
  80337a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80337d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803381:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803388:	e8 b6 ed ff ff       	call   802143 <sys_page_alloc>
		return r;
  80338d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80338f:	85 c0                	test   %eax,%eax
  803391:	78 1f                	js     8033b2 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  803393:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803399:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80339c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80339e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033a1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8033a8:	89 04 24             	mov    %eax,(%esp)
  8033ab:	e8 00 f5 ff ff       	call   8028b0 <fd2num>
  8033b0:	89 c2                	mov    %eax,%edx
}
  8033b2:	89 d0                	mov    %edx,%eax
  8033b4:	c9                   	leave  
  8033b5:	c3                   	ret    
  8033b6:	66 90                	xchg   %ax,%ax
  8033b8:	66 90                	xchg   %ax,%ax
  8033ba:	66 90                	xchg   %ax,%ax
  8033bc:	66 90                	xchg   %ax,%ax
  8033be:	66 90                	xchg   %ax,%ax

008033c0 <__udivdi3>:
  8033c0:	55                   	push   %ebp
  8033c1:	57                   	push   %edi
  8033c2:	56                   	push   %esi
  8033c3:	83 ec 0c             	sub    $0xc,%esp
  8033c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8033ca:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8033ce:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8033d2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8033d6:	85 c0                	test   %eax,%eax
  8033d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8033dc:	89 ea                	mov    %ebp,%edx
  8033de:	89 0c 24             	mov    %ecx,(%esp)
  8033e1:	75 2d                	jne    803410 <__udivdi3+0x50>
  8033e3:	39 e9                	cmp    %ebp,%ecx
  8033e5:	77 61                	ja     803448 <__udivdi3+0x88>
  8033e7:	85 c9                	test   %ecx,%ecx
  8033e9:	89 ce                	mov    %ecx,%esi
  8033eb:	75 0b                	jne    8033f8 <__udivdi3+0x38>
  8033ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8033f2:	31 d2                	xor    %edx,%edx
  8033f4:	f7 f1                	div    %ecx
  8033f6:	89 c6                	mov    %eax,%esi
  8033f8:	31 d2                	xor    %edx,%edx
  8033fa:	89 e8                	mov    %ebp,%eax
  8033fc:	f7 f6                	div    %esi
  8033fe:	89 c5                	mov    %eax,%ebp
  803400:	89 f8                	mov    %edi,%eax
  803402:	f7 f6                	div    %esi
  803404:	89 ea                	mov    %ebp,%edx
  803406:	83 c4 0c             	add    $0xc,%esp
  803409:	5e                   	pop    %esi
  80340a:	5f                   	pop    %edi
  80340b:	5d                   	pop    %ebp
  80340c:	c3                   	ret    
  80340d:	8d 76 00             	lea    0x0(%esi),%esi
  803410:	39 e8                	cmp    %ebp,%eax
  803412:	77 24                	ja     803438 <__udivdi3+0x78>
  803414:	0f bd e8             	bsr    %eax,%ebp
  803417:	83 f5 1f             	xor    $0x1f,%ebp
  80341a:	75 3c                	jne    803458 <__udivdi3+0x98>
  80341c:	8b 74 24 04          	mov    0x4(%esp),%esi
  803420:	39 34 24             	cmp    %esi,(%esp)
  803423:	0f 86 9f 00 00 00    	jbe    8034c8 <__udivdi3+0x108>
  803429:	39 d0                	cmp    %edx,%eax
  80342b:	0f 82 97 00 00 00    	jb     8034c8 <__udivdi3+0x108>
  803431:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803438:	31 d2                	xor    %edx,%edx
  80343a:	31 c0                	xor    %eax,%eax
  80343c:	83 c4 0c             	add    $0xc,%esp
  80343f:	5e                   	pop    %esi
  803440:	5f                   	pop    %edi
  803441:	5d                   	pop    %ebp
  803442:	c3                   	ret    
  803443:	90                   	nop
  803444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803448:	89 f8                	mov    %edi,%eax
  80344a:	f7 f1                	div    %ecx
  80344c:	31 d2                	xor    %edx,%edx
  80344e:	83 c4 0c             	add    $0xc,%esp
  803451:	5e                   	pop    %esi
  803452:	5f                   	pop    %edi
  803453:	5d                   	pop    %ebp
  803454:	c3                   	ret    
  803455:	8d 76 00             	lea    0x0(%esi),%esi
  803458:	89 e9                	mov    %ebp,%ecx
  80345a:	8b 3c 24             	mov    (%esp),%edi
  80345d:	d3 e0                	shl    %cl,%eax
  80345f:	89 c6                	mov    %eax,%esi
  803461:	b8 20 00 00 00       	mov    $0x20,%eax
  803466:	29 e8                	sub    %ebp,%eax
  803468:	89 c1                	mov    %eax,%ecx
  80346a:	d3 ef                	shr    %cl,%edi
  80346c:	89 e9                	mov    %ebp,%ecx
  80346e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  803472:	8b 3c 24             	mov    (%esp),%edi
  803475:	09 74 24 08          	or     %esi,0x8(%esp)
  803479:	89 d6                	mov    %edx,%esi
  80347b:	d3 e7                	shl    %cl,%edi
  80347d:	89 c1                	mov    %eax,%ecx
  80347f:	89 3c 24             	mov    %edi,(%esp)
  803482:	8b 7c 24 04          	mov    0x4(%esp),%edi
  803486:	d3 ee                	shr    %cl,%esi
  803488:	89 e9                	mov    %ebp,%ecx
  80348a:	d3 e2                	shl    %cl,%edx
  80348c:	89 c1                	mov    %eax,%ecx
  80348e:	d3 ef                	shr    %cl,%edi
  803490:	09 d7                	or     %edx,%edi
  803492:	89 f2                	mov    %esi,%edx
  803494:	89 f8                	mov    %edi,%eax
  803496:	f7 74 24 08          	divl   0x8(%esp)
  80349a:	89 d6                	mov    %edx,%esi
  80349c:	89 c7                	mov    %eax,%edi
  80349e:	f7 24 24             	mull   (%esp)
  8034a1:	39 d6                	cmp    %edx,%esi
  8034a3:	89 14 24             	mov    %edx,(%esp)
  8034a6:	72 30                	jb     8034d8 <__udivdi3+0x118>
  8034a8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8034ac:	89 e9                	mov    %ebp,%ecx
  8034ae:	d3 e2                	shl    %cl,%edx
  8034b0:	39 c2                	cmp    %eax,%edx
  8034b2:	73 05                	jae    8034b9 <__udivdi3+0xf9>
  8034b4:	3b 34 24             	cmp    (%esp),%esi
  8034b7:	74 1f                	je     8034d8 <__udivdi3+0x118>
  8034b9:	89 f8                	mov    %edi,%eax
  8034bb:	31 d2                	xor    %edx,%edx
  8034bd:	e9 7a ff ff ff       	jmp    80343c <__udivdi3+0x7c>
  8034c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8034c8:	31 d2                	xor    %edx,%edx
  8034ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8034cf:	e9 68 ff ff ff       	jmp    80343c <__udivdi3+0x7c>
  8034d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8034d8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8034db:	31 d2                	xor    %edx,%edx
  8034dd:	83 c4 0c             	add    $0xc,%esp
  8034e0:	5e                   	pop    %esi
  8034e1:	5f                   	pop    %edi
  8034e2:	5d                   	pop    %ebp
  8034e3:	c3                   	ret    
  8034e4:	66 90                	xchg   %ax,%ax
  8034e6:	66 90                	xchg   %ax,%ax
  8034e8:	66 90                	xchg   %ax,%ax
  8034ea:	66 90                	xchg   %ax,%ax
  8034ec:	66 90                	xchg   %ax,%ax
  8034ee:	66 90                	xchg   %ax,%ax

008034f0 <__umoddi3>:
  8034f0:	55                   	push   %ebp
  8034f1:	57                   	push   %edi
  8034f2:	56                   	push   %esi
  8034f3:	83 ec 14             	sub    $0x14,%esp
  8034f6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8034fa:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8034fe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  803502:	89 c7                	mov    %eax,%edi
  803504:	89 44 24 04          	mov    %eax,0x4(%esp)
  803508:	8b 44 24 30          	mov    0x30(%esp),%eax
  80350c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  803510:	89 34 24             	mov    %esi,(%esp)
  803513:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803517:	85 c0                	test   %eax,%eax
  803519:	89 c2                	mov    %eax,%edx
  80351b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80351f:	75 17                	jne    803538 <__umoddi3+0x48>
  803521:	39 fe                	cmp    %edi,%esi
  803523:	76 4b                	jbe    803570 <__umoddi3+0x80>
  803525:	89 c8                	mov    %ecx,%eax
  803527:	89 fa                	mov    %edi,%edx
  803529:	f7 f6                	div    %esi
  80352b:	89 d0                	mov    %edx,%eax
  80352d:	31 d2                	xor    %edx,%edx
  80352f:	83 c4 14             	add    $0x14,%esp
  803532:	5e                   	pop    %esi
  803533:	5f                   	pop    %edi
  803534:	5d                   	pop    %ebp
  803535:	c3                   	ret    
  803536:	66 90                	xchg   %ax,%ax
  803538:	39 f8                	cmp    %edi,%eax
  80353a:	77 54                	ja     803590 <__umoddi3+0xa0>
  80353c:	0f bd e8             	bsr    %eax,%ebp
  80353f:	83 f5 1f             	xor    $0x1f,%ebp
  803542:	75 5c                	jne    8035a0 <__umoddi3+0xb0>
  803544:	8b 7c 24 08          	mov    0x8(%esp),%edi
  803548:	39 3c 24             	cmp    %edi,(%esp)
  80354b:	0f 87 e7 00 00 00    	ja     803638 <__umoddi3+0x148>
  803551:	8b 7c 24 04          	mov    0x4(%esp),%edi
  803555:	29 f1                	sub    %esi,%ecx
  803557:	19 c7                	sbb    %eax,%edi
  803559:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80355d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803561:	8b 44 24 08          	mov    0x8(%esp),%eax
  803565:	8b 54 24 0c          	mov    0xc(%esp),%edx
  803569:	83 c4 14             	add    $0x14,%esp
  80356c:	5e                   	pop    %esi
  80356d:	5f                   	pop    %edi
  80356e:	5d                   	pop    %ebp
  80356f:	c3                   	ret    
  803570:	85 f6                	test   %esi,%esi
  803572:	89 f5                	mov    %esi,%ebp
  803574:	75 0b                	jne    803581 <__umoddi3+0x91>
  803576:	b8 01 00 00 00       	mov    $0x1,%eax
  80357b:	31 d2                	xor    %edx,%edx
  80357d:	f7 f6                	div    %esi
  80357f:	89 c5                	mov    %eax,%ebp
  803581:	8b 44 24 04          	mov    0x4(%esp),%eax
  803585:	31 d2                	xor    %edx,%edx
  803587:	f7 f5                	div    %ebp
  803589:	89 c8                	mov    %ecx,%eax
  80358b:	f7 f5                	div    %ebp
  80358d:	eb 9c                	jmp    80352b <__umoddi3+0x3b>
  80358f:	90                   	nop
  803590:	89 c8                	mov    %ecx,%eax
  803592:	89 fa                	mov    %edi,%edx
  803594:	83 c4 14             	add    $0x14,%esp
  803597:	5e                   	pop    %esi
  803598:	5f                   	pop    %edi
  803599:	5d                   	pop    %ebp
  80359a:	c3                   	ret    
  80359b:	90                   	nop
  80359c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8035a0:	8b 04 24             	mov    (%esp),%eax
  8035a3:	be 20 00 00 00       	mov    $0x20,%esi
  8035a8:	89 e9                	mov    %ebp,%ecx
  8035aa:	29 ee                	sub    %ebp,%esi
  8035ac:	d3 e2                	shl    %cl,%edx
  8035ae:	89 f1                	mov    %esi,%ecx
  8035b0:	d3 e8                	shr    %cl,%eax
  8035b2:	89 e9                	mov    %ebp,%ecx
  8035b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8035b8:	8b 04 24             	mov    (%esp),%eax
  8035bb:	09 54 24 04          	or     %edx,0x4(%esp)
  8035bf:	89 fa                	mov    %edi,%edx
  8035c1:	d3 e0                	shl    %cl,%eax
  8035c3:	89 f1                	mov    %esi,%ecx
  8035c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8035c9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8035cd:	d3 ea                	shr    %cl,%edx
  8035cf:	89 e9                	mov    %ebp,%ecx
  8035d1:	d3 e7                	shl    %cl,%edi
  8035d3:	89 f1                	mov    %esi,%ecx
  8035d5:	d3 e8                	shr    %cl,%eax
  8035d7:	89 e9                	mov    %ebp,%ecx
  8035d9:	09 f8                	or     %edi,%eax
  8035db:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8035df:	f7 74 24 04          	divl   0x4(%esp)
  8035e3:	d3 e7                	shl    %cl,%edi
  8035e5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8035e9:	89 d7                	mov    %edx,%edi
  8035eb:	f7 64 24 08          	mull   0x8(%esp)
  8035ef:	39 d7                	cmp    %edx,%edi
  8035f1:	89 c1                	mov    %eax,%ecx
  8035f3:	89 14 24             	mov    %edx,(%esp)
  8035f6:	72 2c                	jb     803624 <__umoddi3+0x134>
  8035f8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8035fc:	72 22                	jb     803620 <__umoddi3+0x130>
  8035fe:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803602:	29 c8                	sub    %ecx,%eax
  803604:	19 d7                	sbb    %edx,%edi
  803606:	89 e9                	mov    %ebp,%ecx
  803608:	89 fa                	mov    %edi,%edx
  80360a:	d3 e8                	shr    %cl,%eax
  80360c:	89 f1                	mov    %esi,%ecx
  80360e:	d3 e2                	shl    %cl,%edx
  803610:	89 e9                	mov    %ebp,%ecx
  803612:	d3 ef                	shr    %cl,%edi
  803614:	09 d0                	or     %edx,%eax
  803616:	89 fa                	mov    %edi,%edx
  803618:	83 c4 14             	add    $0x14,%esp
  80361b:	5e                   	pop    %esi
  80361c:	5f                   	pop    %edi
  80361d:	5d                   	pop    %ebp
  80361e:	c3                   	ret    
  80361f:	90                   	nop
  803620:	39 d7                	cmp    %edx,%edi
  803622:	75 da                	jne    8035fe <__umoddi3+0x10e>
  803624:	8b 14 24             	mov    (%esp),%edx
  803627:	89 c1                	mov    %eax,%ecx
  803629:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80362d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  803631:	eb cb                	jmp    8035fe <__umoddi3+0x10e>
  803633:	90                   	nop
  803634:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803638:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80363c:	0f 82 0f ff ff ff    	jb     803551 <__umoddi3+0x61>
  803642:	e9 1a ff ff ff       	jmp    803561 <__umoddi3+0x71>
