
obj/user/testfile.debug：     文件格式 elf32-i386


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
  80002c:	e8 52 07 00 00       	call   800783 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 14             	sub    $0x14,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800040:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  800047:	e8 0b 0f 00 00       	call   800f57 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80004c:	89 1d 00 64 80 00    	mov    %ebx,0x806400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  800052:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800059:	e8 cf 16 00 00       	call   80172d <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80005e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800065:	00 
  800066:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  80006d:	00 
  80006e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800075:	00 
  800076:	89 04 24             	mov    %eax,(%esp)
  800079:	e8 00 16 00 00       	call   80167e <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  80007e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800085:	00 
  800086:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  80008d:	cc 
  80008e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800095:	e8 46 15 00 00       	call   8015e0 <ipc_recv>
}
  80009a:	83 c4 14             	add    $0x14,%esp
  80009d:	5b                   	pop    %ebx
  80009e:	5d                   	pop    %ebp
  80009f:	c3                   	ret    

008000a0 <umain>:

void
umain(int argc, char **argv)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	57                   	push   %edi
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	81 ec cc 02 00 00    	sub    $0x2cc,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8000ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b1:	b8 c0 27 80 00       	mov    $0x8027c0,%eax
  8000b6:	e8 78 ff ff ff       	call   800033 <xopen>
  8000bb:	85 c0                	test   %eax,%eax
  8000bd:	79 25                	jns    8000e4 <umain+0x44>
  8000bf:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000c2:	74 3c                	je     800100 <umain+0x60>
		panic("serve_open /not-found: %e", r);
  8000c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c8:	c7 44 24 08 cb 27 80 	movl   $0x8027cb,0x8(%esp)
  8000cf:	00 
  8000d0:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8000d7:	00 
  8000d8:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  8000df:	e8 fb 06 00 00       	call   8007df <_panic>
	else if (r >= 0)
		panic("serve_open /not-found succeeded!");
  8000e4:	c7 44 24 08 80 29 80 	movl   $0x802980,0x8(%esp)
  8000eb:	00 
  8000ec:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000f3:	00 
  8000f4:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  8000fb:	e8 df 06 00 00       	call   8007df <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  800100:	ba 00 00 00 00       	mov    $0x0,%edx
  800105:	b8 f5 27 80 00       	mov    $0x8027f5,%eax
  80010a:	e8 24 ff ff ff       	call   800033 <xopen>
  80010f:	85 c0                	test   %eax,%eax
  800111:	79 20                	jns    800133 <umain+0x93>
		panic("serve_open /newmotd: %e", r);
  800113:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800117:	c7 44 24 08 fe 27 80 	movl   $0x8027fe,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800126:	00 
  800127:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  80012e:	e8 ac 06 00 00       	call   8007df <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  800133:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  80013a:	75 12                	jne    80014e <umain+0xae>
  80013c:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800143:	75 09                	jne    80014e <umain+0xae>
  800145:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80014c:	74 1c                	je     80016a <umain+0xca>
		panic("serve_open did not fill struct Fd correctly\n");
  80014e:	c7 44 24 08 a4 29 80 	movl   $0x8029a4,0x8(%esp)
  800155:	00 
  800156:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80015d:	00 
  80015e:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  800165:	e8 75 06 00 00       	call   8007df <_panic>
	cprintf("serve_open is good\n");
  80016a:	c7 04 24 16 28 80 00 	movl   $0x802816,(%esp)
  800171:	e8 62 07 00 00       	call   8008d8 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800176:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80017c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800180:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800187:	ff 15 1c 40 80 00    	call   *0x80401c
  80018d:	85 c0                	test   %eax,%eax
  80018f:	79 20                	jns    8001b1 <umain+0x111>
		panic("file_stat: %e", r);
  800191:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800195:	c7 44 24 08 2a 28 80 	movl   $0x80282a,0x8(%esp)
  80019c:	00 
  80019d:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8001a4:	00 
  8001a5:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  8001ac:	e8 2e 06 00 00       	call   8007df <_panic>
	if (strlen(msg) != st.st_size)
  8001b1:	a1 00 40 80 00       	mov    0x804000,%eax
  8001b6:	89 04 24             	mov    %eax,(%esp)
  8001b9:	e8 62 0d 00 00       	call   800f20 <strlen>
  8001be:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  8001c1:	74 34                	je     8001f7 <umain+0x157>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8001c3:	a1 00 40 80 00       	mov    0x804000,%eax
  8001c8:	89 04 24             	mov    %eax,(%esp)
  8001cb:	e8 50 0d 00 00       	call   800f20 <strlen>
  8001d0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001d4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8001d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001db:	c7 44 24 08 d4 29 80 	movl   $0x8029d4,0x8(%esp)
  8001e2:	00 
  8001e3:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8001ea:	00 
  8001eb:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  8001f2:	e8 e8 05 00 00       	call   8007df <_panic>
	cprintf("file_stat is good\n");
  8001f7:	c7 04 24 38 28 80 00 	movl   $0x802838,(%esp)
  8001fe:	e8 d5 06 00 00       	call   8008d8 <cprintf>

	memset(buf, 0, sizeof buf);
  800203:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80020a:	00 
  80020b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800212:	00 
  800213:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800219:	89 1c 24             	mov    %ebx,(%esp)
  80021c:	e8 86 0e 00 00       	call   8010a7 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800221:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800228:	00 
  800229:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80022d:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800234:	ff 15 10 40 80 00    	call   *0x804010
  80023a:	85 c0                	test   %eax,%eax
  80023c:	79 20                	jns    80025e <umain+0x1be>
		panic("file_read: %e", r);
  80023e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800242:	c7 44 24 08 4b 28 80 	movl   $0x80284b,0x8(%esp)
  800249:	00 
  80024a:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  800251:	00 
  800252:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  800259:	e8 81 05 00 00       	call   8007df <_panic>
	if (strcmp(buf, msg) != 0)
  80025e:	a1 00 40 80 00       	mov    0x804000,%eax
  800263:	89 44 24 04          	mov    %eax,0x4(%esp)
  800267:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  80026d:	89 04 24             	mov    %eax,(%esp)
  800270:	e8 97 0d 00 00       	call   80100c <strcmp>
  800275:	85 c0                	test   %eax,%eax
  800277:	74 1c                	je     800295 <umain+0x1f5>
		panic("file_read returned wrong data");
  800279:	c7 44 24 08 59 28 80 	movl   $0x802859,0x8(%esp)
  800280:	00 
  800281:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800288:	00 
  800289:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  800290:	e8 4a 05 00 00       	call   8007df <_panic>
	cprintf("file_read is good\n");
  800295:	c7 04 24 77 28 80 00 	movl   $0x802877,(%esp)
  80029c:	e8 37 06 00 00       	call   8008d8 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  8002a1:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8002a8:	ff 15 18 40 80 00    	call   *0x804018
  8002ae:	85 c0                	test   %eax,%eax
  8002b0:	79 20                	jns    8002d2 <umain+0x232>
		panic("file_close: %e", r);
  8002b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b6:	c7 44 24 08 8a 28 80 	movl   $0x80288a,0x8(%esp)
  8002bd:	00 
  8002be:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  8002c5:	00 
  8002c6:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  8002cd:	e8 0d 05 00 00       	call   8007df <_panic>
	cprintf("file_close is good\n");
  8002d2:	c7 04 24 99 28 80 00 	movl   $0x802899,(%esp)
  8002d9:	e8 fa 05 00 00       	call   8008d8 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  8002de:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  8002e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e6:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  8002eb:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002ee:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  8002f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002f6:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  8002fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  8002fe:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  800305:	cc 
  800306:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80030d:	e8 08 11 00 00       	call   80141a <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  800312:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800319:	00 
  80031a:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800320:	89 44 24 04          	mov    %eax,0x4(%esp)
  800324:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800327:	89 04 24             	mov    %eax,(%esp)
  80032a:	ff 15 10 40 80 00    	call   *0x804010
  800330:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800333:	74 20                	je     800355 <umain+0x2b5>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  800335:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800339:	c7 44 24 08 fc 29 80 	movl   $0x8029fc,0x8(%esp)
  800340:	00 
  800341:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  800348:	00 
  800349:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  800350:	e8 8a 04 00 00       	call   8007df <_panic>
	cprintf("stale fileid is good\n");
  800355:	c7 04 24 ad 28 80 00 	movl   $0x8028ad,(%esp)
  80035c:	e8 77 05 00 00       	call   8008d8 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  800361:	ba 02 01 00 00       	mov    $0x102,%edx
  800366:	b8 c3 28 80 00       	mov    $0x8028c3,%eax
  80036b:	e8 c3 fc ff ff       	call   800033 <xopen>
  800370:	85 c0                	test   %eax,%eax
  800372:	79 20                	jns    800394 <umain+0x2f4>
		panic("serve_open /new-file: %e", r);
  800374:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800378:	c7 44 24 08 cd 28 80 	movl   $0x8028cd,0x8(%esp)
  80037f:	00 
  800380:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  800387:	00 
  800388:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  80038f:	e8 4b 04 00 00       	call   8007df <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  800394:	8b 1d 14 40 80 00    	mov    0x804014,%ebx
  80039a:	a1 00 40 80 00       	mov    0x804000,%eax
  80039f:	89 04 24             	mov    %eax,(%esp)
  8003a2:	e8 79 0b 00 00       	call   800f20 <strlen>
  8003a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ab:	a1 00 40 80 00       	mov    0x804000,%eax
  8003b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b4:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8003bb:	ff d3                	call   *%ebx
  8003bd:	89 c3                	mov    %eax,%ebx
  8003bf:	a1 00 40 80 00       	mov    0x804000,%eax
  8003c4:	89 04 24             	mov    %eax,(%esp)
  8003c7:	e8 54 0b 00 00       	call   800f20 <strlen>
  8003cc:	39 c3                	cmp    %eax,%ebx
  8003ce:	74 20                	je     8003f0 <umain+0x350>
		panic("file_write: %e", r);
  8003d0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003d4:	c7 44 24 08 e6 28 80 	movl   $0x8028e6,0x8(%esp)
  8003db:	00 
  8003dc:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  8003e3:	00 
  8003e4:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  8003eb:	e8 ef 03 00 00       	call   8007df <_panic>
	cprintf("file_write is good\n");
  8003f0:	c7 04 24 f5 28 80 00 	movl   $0x8028f5,(%esp)
  8003f7:	e8 dc 04 00 00       	call   8008d8 <cprintf>

	FVA->fd_offset = 0;
  8003fc:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800403:	00 00 00 
	memset(buf, 0, sizeof buf);
  800406:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80040d:	00 
  80040e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800415:	00 
  800416:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  80041c:	89 1c 24             	mov    %ebx,(%esp)
  80041f:	e8 83 0c 00 00       	call   8010a7 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800424:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80042b:	00 
  80042c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800430:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800437:	ff 15 10 40 80 00    	call   *0x804010
  80043d:	89 c3                	mov    %eax,%ebx
  80043f:	85 c0                	test   %eax,%eax
  800441:	79 20                	jns    800463 <umain+0x3c3>
		panic("file_read after file_write: %e", r);
  800443:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800447:	c7 44 24 08 34 2a 80 	movl   $0x802a34,0x8(%esp)
  80044e:	00 
  80044f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800456:	00 
  800457:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  80045e:	e8 7c 03 00 00       	call   8007df <_panic>
	if (r != strlen(msg))
  800463:	a1 00 40 80 00       	mov    0x804000,%eax
  800468:	89 04 24             	mov    %eax,(%esp)
  80046b:	e8 b0 0a 00 00       	call   800f20 <strlen>
  800470:	39 d8                	cmp    %ebx,%eax
  800472:	74 20                	je     800494 <umain+0x3f4>
		panic("file_read after file_write returned wrong length: %d", r);
  800474:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800478:	c7 44 24 08 54 2a 80 	movl   $0x802a54,0x8(%esp)
  80047f:	00 
  800480:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800487:	00 
  800488:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  80048f:	e8 4b 03 00 00       	call   8007df <_panic>
	if (strcmp(buf, msg) != 0)
  800494:	a1 00 40 80 00       	mov    0x804000,%eax
  800499:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049d:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004a3:	89 04 24             	mov    %eax,(%esp)
  8004a6:	e8 61 0b 00 00       	call   80100c <strcmp>
  8004ab:	85 c0                	test   %eax,%eax
  8004ad:	74 1c                	je     8004cb <umain+0x42b>
		panic("file_read after file_write returned wrong data");
  8004af:	c7 44 24 08 8c 2a 80 	movl   $0x802a8c,0x8(%esp)
  8004b6:	00 
  8004b7:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8004be:	00 
  8004bf:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  8004c6:	e8 14 03 00 00       	call   8007df <_panic>
	cprintf("file_read after file_write is good\n");
  8004cb:	c7 04 24 bc 2a 80 00 	movl   $0x802abc,(%esp)
  8004d2:	e8 01 04 00 00       	call   8008d8 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8004d7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004de:	00 
  8004df:	c7 04 24 c0 27 80 00 	movl   $0x8027c0,(%esp)
  8004e6:	e8 36 1a 00 00       	call   801f21 <open>
  8004eb:	85 c0                	test   %eax,%eax
  8004ed:	79 25                	jns    800514 <umain+0x474>
  8004ef:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8004f2:	74 3c                	je     800530 <umain+0x490>
		panic("open /not-found: %e", r);
  8004f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f8:	c7 44 24 08 d1 27 80 	movl   $0x8027d1,0x8(%esp)
  8004ff:	00 
  800500:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800507:	00 
  800508:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  80050f:	e8 cb 02 00 00       	call   8007df <_panic>
	else if (r >= 0)
		panic("open /not-found succeeded!");
  800514:	c7 44 24 08 09 29 80 	movl   $0x802909,0x8(%esp)
  80051b:	00 
  80051c:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800523:	00 
  800524:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  80052b:	e8 af 02 00 00       	call   8007df <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800530:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800537:	00 
  800538:	c7 04 24 f5 27 80 00 	movl   $0x8027f5,(%esp)
  80053f:	e8 dd 19 00 00       	call   801f21 <open>
  800544:	85 c0                	test   %eax,%eax
  800546:	79 20                	jns    800568 <umain+0x4c8>
		panic("open /newmotd: %e", r);
  800548:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80054c:	c7 44 24 08 04 28 80 	movl   $0x802804,0x8(%esp)
  800553:	00 
  800554:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  80055b:	00 
  80055c:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  800563:	e8 77 02 00 00       	call   8007df <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800568:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  80056b:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  800572:	75 12                	jne    800586 <umain+0x4e6>
  800574:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  80057b:	75 09                	jne    800586 <umain+0x4e6>
  80057d:	83 b8 08 00 00 d0 00 	cmpl   $0x0,-0x2ffffff8(%eax)
  800584:	74 1c                	je     8005a2 <umain+0x502>
		panic("open did not fill struct Fd correctly\n");
  800586:	c7 44 24 08 e0 2a 80 	movl   $0x802ae0,0x8(%esp)
  80058d:	00 
  80058e:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  800595:	00 
  800596:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  80059d:	e8 3d 02 00 00       	call   8007df <_panic>
	cprintf("open is good\n");
  8005a2:	c7 04 24 1c 28 80 00 	movl   $0x80281c,(%esp)
  8005a9:	e8 2a 03 00 00       	call   8008d8 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8005ae:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  8005b5:	00 
  8005b6:	c7 04 24 24 29 80 00 	movl   $0x802924,(%esp)
  8005bd:	e8 5f 19 00 00       	call   801f21 <open>
  8005c2:	89 c6                	mov    %eax,%esi
  8005c4:	85 c0                	test   %eax,%eax
  8005c6:	79 20                	jns    8005e8 <umain+0x548>
		panic("creat /big: %e", f);
  8005c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005cc:	c7 44 24 08 29 29 80 	movl   $0x802929,0x8(%esp)
  8005d3:	00 
  8005d4:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  8005db:	00 
  8005dc:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  8005e3:	e8 f7 01 00 00       	call   8007df <_panic>
	memset(buf, 0, sizeof(buf));
  8005e8:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8005ef:	00 
  8005f0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8005f7:	00 
  8005f8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8005fe:	89 04 24             	mov    %eax,(%esp)
  800601:	e8 a1 0a 00 00       	call   8010a7 <memset>
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800606:	bb 00 00 00 00       	mov    $0x0,%ebx
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  80060b:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800611:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800617:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80061e:	00 
  80061f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800623:	89 34 24             	mov    %esi,(%esp)
  800626:	e8 27 15 00 00       	call   801b52 <write>
  80062b:	85 c0                	test   %eax,%eax
  80062d:	79 24                	jns    800653 <umain+0x5b3>
			panic("write /big@%d: %e", i, r);
  80062f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800633:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800637:	c7 44 24 08 38 29 80 	movl   $0x802938,0x8(%esp)
  80063e:	00 
  80063f:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  800646:	00 
  800647:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  80064e:	e8 8c 01 00 00       	call   8007df <_panic>
  800653:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  800659:	89 c3                	mov    %eax,%ebx

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80065b:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800660:	75 af                	jne    800611 <umain+0x571>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800662:	89 34 24             	mov    %esi,(%esp)
  800665:	e8 a8 12 00 00       	call   801912 <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80066a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800671:	00 
  800672:	c7 04 24 24 29 80 00 	movl   $0x802924,(%esp)
  800679:	e8 a3 18 00 00       	call   801f21 <open>
  80067e:	89 c6                	mov    %eax,%esi
  800680:	85 c0                	test   %eax,%eax
  800682:	79 20                	jns    8006a4 <umain+0x604>
		panic("open /big: %e", f);
  800684:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800688:	c7 44 24 08 4a 29 80 	movl   $0x80294a,0x8(%esp)
  80068f:	00 
  800690:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  800697:	00 
  800698:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  80069f:	e8 3b 01 00 00       	call   8007df <_panic>
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
  8006a4:	bb 00 00 00 00       	mov    $0x0,%ebx
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  8006a9:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  8006af:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  8006b5:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8006bc:	00 
  8006bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c1:	89 34 24             	mov    %esi,(%esp)
  8006c4:	e8 3e 14 00 00       	call   801b07 <readn>
  8006c9:	85 c0                	test   %eax,%eax
  8006cb:	79 24                	jns    8006f1 <umain+0x651>
			panic("read /big@%d: %e", i, r);
  8006cd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006d1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006d5:	c7 44 24 08 58 29 80 	movl   $0x802958,0x8(%esp)
  8006dc:	00 
  8006dd:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
  8006e4:	00 
  8006e5:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  8006ec:	e8 ee 00 00 00       	call   8007df <_panic>
		if (r != sizeof(buf))
  8006f1:	3d 00 02 00 00       	cmp    $0x200,%eax
  8006f6:	74 2c                	je     800724 <umain+0x684>
			panic("read /big from %d returned %d < %d bytes",
  8006f8:	c7 44 24 14 00 02 00 	movl   $0x200,0x14(%esp)
  8006ff:	00 
  800700:	89 44 24 10          	mov    %eax,0x10(%esp)
  800704:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800708:	c7 44 24 08 08 2b 80 	movl   $0x802b08,0x8(%esp)
  80070f:	00 
  800710:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  800717:	00 
  800718:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  80071f:	e8 bb 00 00 00       	call   8007df <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  800724:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  80072a:	39 d8                	cmp    %ebx,%eax
  80072c:	74 24                	je     800752 <umain+0x6b2>
			panic("read /big from %d returned bad data %d",
  80072e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800732:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800736:	c7 44 24 08 34 2b 80 	movl   $0x802b34,0x8(%esp)
  80073d:	00 
  80073e:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  800745:	00 
  800746:	c7 04 24 e5 27 80 00 	movl   $0x8027e5,(%esp)
  80074d:	e8 8d 00 00 00       	call   8007df <_panic>
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800752:	8d 98 00 02 00 00    	lea    0x200(%eax),%ebx
  800758:	81 fb ff df 01 00    	cmp    $0x1dfff,%ebx
  80075e:	0f 8e 4b ff ff ff    	jle    8006af <umain+0x60f>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800764:	89 34 24             	mov    %esi,(%esp)
  800767:	e8 a6 11 00 00       	call   801912 <close>
	cprintf("large file is good\n");
  80076c:	c7 04 24 69 29 80 00 	movl   $0x802969,(%esp)
  800773:	e8 60 01 00 00       	call   8008d8 <cprintf>
}
  800778:	81 c4 cc 02 00 00    	add    $0x2cc,%esp
  80077e:	5b                   	pop    %ebx
  80077f:	5e                   	pop    %esi
  800780:	5f                   	pop    %edi
  800781:	5d                   	pop    %ebp
  800782:	c3                   	ret    

00800783 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	56                   	push   %esi
  800787:	53                   	push   %ebx
  800788:	83 ec 10             	sub    $0x10,%esp
  80078b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80078e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  800791:	e8 9f 0b 00 00       	call   801335 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800796:	25 ff 03 00 00       	and    $0x3ff,%eax
  80079b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80079e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8007a3:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8007a8:	85 db                	test   %ebx,%ebx
  8007aa:	7e 07                	jle    8007b3 <libmain+0x30>
		binaryname = argv[0];
  8007ac:	8b 06                	mov    (%esi),%eax
  8007ae:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  8007b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b7:	89 1c 24             	mov    %ebx,(%esp)
  8007ba:	e8 e1 f8 ff ff       	call   8000a0 <umain>

	// exit gracefully
	exit();
  8007bf:	e8 07 00 00 00       	call   8007cb <exit>
}
  8007c4:	83 c4 10             	add    $0x10,%esp
  8007c7:	5b                   	pop    %ebx
  8007c8:	5e                   	pop    %esi
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  8007d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007d8:	e8 06 0b 00 00       	call   8012e3 <sys_env_destroy>
}
  8007dd:	c9                   	leave  
  8007de:	c3                   	ret    

008007df <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	56                   	push   %esi
  8007e3:	53                   	push   %ebx
  8007e4:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8007e7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8007ea:	8b 35 04 40 80 00    	mov    0x804004,%esi
  8007f0:	e8 40 0b 00 00       	call   801335 <sys_getenvid>
  8007f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8007ff:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800803:	89 74 24 08          	mov    %esi,0x8(%esp)
  800807:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080b:	c7 04 24 8c 2b 80 00 	movl   $0x802b8c,(%esp)
  800812:	e8 c1 00 00 00       	call   8008d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800817:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80081b:	8b 45 10             	mov    0x10(%ebp),%eax
  80081e:	89 04 24             	mov    %eax,(%esp)
  800821:	e8 51 00 00 00       	call   800877 <vcprintf>
	cprintf("\n");
  800826:	c7 04 24 7d 30 80 00 	movl   $0x80307d,(%esp)
  80082d:	e8 a6 00 00 00       	call   8008d8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800832:	cc                   	int3   
  800833:	eb fd                	jmp    800832 <_panic+0x53>

00800835 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	53                   	push   %ebx
  800839:	83 ec 14             	sub    $0x14,%esp
  80083c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80083f:	8b 13                	mov    (%ebx),%edx
  800841:	8d 42 01             	lea    0x1(%edx),%eax
  800844:	89 03                	mov    %eax,(%ebx)
  800846:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800849:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80084d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800852:	75 19                	jne    80086d <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800854:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80085b:	00 
  80085c:	8d 43 08             	lea    0x8(%ebx),%eax
  80085f:	89 04 24             	mov    %eax,(%esp)
  800862:	e8 3f 0a 00 00       	call   8012a6 <sys_cputs>
		b->idx = 0;
  800867:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80086d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800871:	83 c4 14             	add    $0x14,%esp
  800874:	5b                   	pop    %ebx
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800880:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800887:	00 00 00 
	b.cnt = 0;
  80088a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800891:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800894:	8b 45 0c             	mov    0xc(%ebp),%eax
  800897:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8008a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ac:	c7 04 24 35 08 80 00 	movl   $0x800835,(%esp)
  8008b3:	e8 7c 01 00 00       	call   800a34 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8008b8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8008be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8008c8:	89 04 24             	mov    %eax,(%esp)
  8008cb:	e8 d6 09 00 00       	call   8012a6 <sys_cputs>

	return b.cnt;
}
  8008d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8008d6:	c9                   	leave  
  8008d7:	c3                   	ret    

008008d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8008de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8008e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	89 04 24             	mov    %eax,(%esp)
  8008eb:	e8 87 ff ff ff       	call   800877 <vcprintf>
	va_end(ap);

	return cnt;
}
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    
  8008f2:	66 90                	xchg   %ax,%ax
  8008f4:	66 90                	xchg   %ax,%ax
  8008f6:	66 90                	xchg   %ax,%ax
  8008f8:	66 90                	xchg   %ax,%ax
  8008fa:	66 90                	xchg   %ax,%ax
  8008fc:	66 90                	xchg   %ax,%ax
  8008fe:	66 90                	xchg   %ax,%ax

00800900 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	57                   	push   %edi
  800904:	56                   	push   %esi
  800905:	53                   	push   %ebx
  800906:	83 ec 3c             	sub    $0x3c,%esp
  800909:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80090c:	89 d7                	mov    %edx,%edi
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800914:	8b 45 0c             	mov    0xc(%ebp),%eax
  800917:	89 c3                	mov    %eax,%ebx
  800919:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80091c:	8b 45 10             	mov    0x10(%ebp),%eax
  80091f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800922:	b9 00 00 00 00       	mov    $0x0,%ecx
  800927:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80092a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80092d:	39 d9                	cmp    %ebx,%ecx
  80092f:	72 05                	jb     800936 <printnum+0x36>
  800931:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  800934:	77 69                	ja     80099f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800936:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800939:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80093d:	83 ee 01             	sub    $0x1,%esi
  800940:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800944:	89 44 24 08          	mov    %eax,0x8(%esp)
  800948:	8b 44 24 08          	mov    0x8(%esp),%eax
  80094c:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800950:	89 c3                	mov    %eax,%ebx
  800952:	89 d6                	mov    %edx,%esi
  800954:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800957:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80095a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80095e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800962:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800965:	89 04 24             	mov    %eax,(%esp)
  800968:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80096b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096f:	e8 bc 1b 00 00       	call   802530 <__udivdi3>
  800974:	89 d9                	mov    %ebx,%ecx
  800976:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80097a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80097e:	89 04 24             	mov    %eax,(%esp)
  800981:	89 54 24 04          	mov    %edx,0x4(%esp)
  800985:	89 fa                	mov    %edi,%edx
  800987:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80098a:	e8 71 ff ff ff       	call   800900 <printnum>
  80098f:	eb 1b                	jmp    8009ac <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800991:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800995:	8b 45 18             	mov    0x18(%ebp),%eax
  800998:	89 04 24             	mov    %eax,(%esp)
  80099b:	ff d3                	call   *%ebx
  80099d:	eb 03                	jmp    8009a2 <printnum+0xa2>
  80099f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8009a2:	83 ee 01             	sub    $0x1,%esi
  8009a5:	85 f6                	test   %esi,%esi
  8009a7:	7f e8                	jg     800991 <printnum+0x91>
  8009a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8009ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009b0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8009b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8009ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009be:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8009c5:	89 04 24             	mov    %eax,(%esp)
  8009c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8009cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009cf:	e8 8c 1c 00 00       	call   802660 <__umoddi3>
  8009d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009d8:	0f be 80 af 2b 80 00 	movsbl 0x802baf(%eax),%eax
  8009df:	89 04 24             	mov    %eax,(%esp)
  8009e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009e5:	ff d0                	call   *%eax
}
  8009e7:	83 c4 3c             	add    $0x3c,%esp
  8009ea:	5b                   	pop    %ebx
  8009eb:	5e                   	pop    %esi
  8009ec:	5f                   	pop    %edi
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8009f5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8009f9:	8b 10                	mov    (%eax),%edx
  8009fb:	3b 50 04             	cmp    0x4(%eax),%edx
  8009fe:	73 0a                	jae    800a0a <sprintputch+0x1b>
		*b->buf++ = ch;
  800a00:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a03:	89 08                	mov    %ecx,(%eax)
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	88 02                	mov    %al,(%edx)
}
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800a12:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800a15:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a19:	8b 45 10             	mov    0x10(%ebp),%eax
  800a1c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a23:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	89 04 24             	mov    %eax,(%esp)
  800a2d:	e8 02 00 00 00       	call   800a34 <vprintfmt>
	va_end(ap);
}
  800a32:	c9                   	leave  
  800a33:	c3                   	ret    

00800a34 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	53                   	push   %ebx
  800a3a:	83 ec 3c             	sub    $0x3c,%esp
  800a3d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a43:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a46:	eb 11                	jmp    800a59 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800a48:	85 c0                	test   %eax,%eax
  800a4a:	0f 84 48 04 00 00    	je     800e98 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  800a50:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a54:	89 04 24             	mov    %eax,(%esp)
  800a57:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a59:	83 c7 01             	add    $0x1,%edi
  800a5c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a60:	83 f8 25             	cmp    $0x25,%eax
  800a63:	75 e3                	jne    800a48 <vprintfmt+0x14>
  800a65:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800a69:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800a70:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800a77:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800a7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a83:	eb 1f                	jmp    800aa4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a85:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800a88:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800a8c:	eb 16                	jmp    800aa4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a8e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800a91:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800a95:	eb 0d                	jmp    800aa4 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800a97:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800a9a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a9d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aa4:	8d 47 01             	lea    0x1(%edi),%eax
  800aa7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800aaa:	0f b6 17             	movzbl (%edi),%edx
  800aad:	0f b6 c2             	movzbl %dl,%eax
  800ab0:	83 ea 23             	sub    $0x23,%edx
  800ab3:	80 fa 55             	cmp    $0x55,%dl
  800ab6:	0f 87 bf 03 00 00    	ja     800e7b <vprintfmt+0x447>
  800abc:	0f b6 d2             	movzbl %dl,%edx
  800abf:	ff 24 95 00 2d 80 00 	jmp    *0x802d00(,%edx,4)
  800ac6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ac9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ace:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800ad1:	8d 14 92             	lea    (%edx,%edx,4),%edx
  800ad4:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  800ad8:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  800adb:	8d 48 d0             	lea    -0x30(%eax),%ecx
  800ade:	83 f9 09             	cmp    $0x9,%ecx
  800ae1:	77 3c                	ja     800b1f <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800ae3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800ae6:	eb e9                	jmp    800ad1 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800ae8:	8b 45 14             	mov    0x14(%ebp),%eax
  800aeb:	8b 00                	mov    (%eax),%eax
  800aed:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800af0:	8b 45 14             	mov    0x14(%ebp),%eax
  800af3:	8d 40 04             	lea    0x4(%eax),%eax
  800af6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800af9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800afc:	eb 27                	jmp    800b25 <vprintfmt+0xf1>
  800afe:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800b01:	85 d2                	test   %edx,%edx
  800b03:	b8 00 00 00 00       	mov    $0x0,%eax
  800b08:	0f 49 c2             	cmovns %edx,%eax
  800b0b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b0e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b11:	eb 91                	jmp    800aa4 <vprintfmt+0x70>
  800b13:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800b16:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800b1d:	eb 85                	jmp    800aa4 <vprintfmt+0x70>
  800b1f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800b22:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800b25:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800b29:	0f 89 75 ff ff ff    	jns    800aa4 <vprintfmt+0x70>
  800b2f:	e9 63 ff ff ff       	jmp    800a97 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800b34:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b37:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800b3a:	e9 65 ff ff ff       	jmp    800aa4 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b3f:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800b42:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800b46:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b4a:	8b 00                	mov    (%eax),%eax
  800b4c:	89 04 24             	mov    %eax,(%esp)
  800b4f:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b51:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800b54:	e9 00 ff ff ff       	jmp    800a59 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b59:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800b5c:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800b60:	8b 00                	mov    (%eax),%eax
  800b62:	99                   	cltd   
  800b63:	31 d0                	xor    %edx,%eax
  800b65:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800b67:	83 f8 0f             	cmp    $0xf,%eax
  800b6a:	7f 0b                	jg     800b77 <vprintfmt+0x143>
  800b6c:	8b 14 85 60 2e 80 00 	mov    0x802e60(,%eax,4),%edx
  800b73:	85 d2                	test   %edx,%edx
  800b75:	75 20                	jne    800b97 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  800b77:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b7b:	c7 44 24 08 c7 2b 80 	movl   $0x802bc7,0x8(%esp)
  800b82:	00 
  800b83:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b87:	89 34 24             	mov    %esi,(%esp)
  800b8a:	e8 7d fe ff ff       	call   800a0c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b8f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800b92:	e9 c2 fe ff ff       	jmp    800a59 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  800b97:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b9b:	c7 44 24 08 56 30 80 	movl   $0x803056,0x8(%esp)
  800ba2:	00 
  800ba3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ba7:	89 34 24             	mov    %esi,(%esp)
  800baa:	e8 5d fe ff ff       	call   800a0c <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800baf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800bb2:	e9 a2 fe ff ff       	jmp    800a59 <vprintfmt+0x25>
  800bb7:	8b 45 14             	mov    0x14(%ebp),%eax
  800bba:	8b 55 d0             	mov    -0x30(%ebp),%edx
  800bbd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800bc0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800bc3:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  800bc7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800bc9:	85 ff                	test   %edi,%edi
  800bcb:	b8 c0 2b 80 00       	mov    $0x802bc0,%eax
  800bd0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800bd3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800bd7:	0f 84 92 00 00 00    	je     800c6f <vprintfmt+0x23b>
  800bdd:	85 c9                	test   %ecx,%ecx
  800bdf:	0f 8e 98 00 00 00    	jle    800c7d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  800be5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800be9:	89 3c 24             	mov    %edi,(%esp)
  800bec:	e8 47 03 00 00       	call   800f38 <strnlen>
  800bf1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800bf4:	29 c1                	sub    %eax,%ecx
  800bf6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  800bf9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800bfd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c00:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800c03:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800c05:	eb 0f                	jmp    800c16 <vprintfmt+0x1e2>
					putch(padc, putdat);
  800c07:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c0e:	89 04 24             	mov    %eax,(%esp)
  800c11:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800c13:	83 ef 01             	sub    $0x1,%edi
  800c16:	85 ff                	test   %edi,%edi
  800c18:	7f ed                	jg     800c07 <vprintfmt+0x1d3>
  800c1a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800c1d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800c20:	85 c9                	test   %ecx,%ecx
  800c22:	b8 00 00 00 00       	mov    $0x0,%eax
  800c27:	0f 49 c1             	cmovns %ecx,%eax
  800c2a:	29 c1                	sub    %eax,%ecx
  800c2c:	89 75 08             	mov    %esi,0x8(%ebp)
  800c2f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800c32:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800c35:	89 cb                	mov    %ecx,%ebx
  800c37:	eb 50                	jmp    800c89 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800c39:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800c3d:	74 1e                	je     800c5d <vprintfmt+0x229>
  800c3f:	0f be d2             	movsbl %dl,%edx
  800c42:	83 ea 20             	sub    $0x20,%edx
  800c45:	83 fa 5e             	cmp    $0x5e,%edx
  800c48:	76 13                	jbe    800c5d <vprintfmt+0x229>
					putch('?', putdat);
  800c4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c51:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800c58:	ff 55 08             	call   *0x8(%ebp)
  800c5b:	eb 0d                	jmp    800c6a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  800c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c60:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c64:	89 04 24             	mov    %eax,(%esp)
  800c67:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c6a:	83 eb 01             	sub    $0x1,%ebx
  800c6d:	eb 1a                	jmp    800c89 <vprintfmt+0x255>
  800c6f:	89 75 08             	mov    %esi,0x8(%ebp)
  800c72:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800c75:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800c78:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800c7b:	eb 0c                	jmp    800c89 <vprintfmt+0x255>
  800c7d:	89 75 08             	mov    %esi,0x8(%ebp)
  800c80:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800c83:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800c86:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800c89:	83 c7 01             	add    $0x1,%edi
  800c8c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800c90:	0f be c2             	movsbl %dl,%eax
  800c93:	85 c0                	test   %eax,%eax
  800c95:	74 25                	je     800cbc <vprintfmt+0x288>
  800c97:	85 f6                	test   %esi,%esi
  800c99:	78 9e                	js     800c39 <vprintfmt+0x205>
  800c9b:	83 ee 01             	sub    $0x1,%esi
  800c9e:	79 99                	jns    800c39 <vprintfmt+0x205>
  800ca0:	89 df                	mov    %ebx,%edi
  800ca2:	8b 75 08             	mov    0x8(%ebp),%esi
  800ca5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ca8:	eb 1a                	jmp    800cc4 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800caa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800cb5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800cb7:	83 ef 01             	sub    $0x1,%edi
  800cba:	eb 08                	jmp    800cc4 <vprintfmt+0x290>
  800cbc:	89 df                	mov    %ebx,%edi
  800cbe:	8b 75 08             	mov    0x8(%ebp),%esi
  800cc1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cc4:	85 ff                	test   %edi,%edi
  800cc6:	7f e2                	jg     800caa <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cc8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ccb:	e9 89 fd ff ff       	jmp    800a59 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800cd0:	83 f9 01             	cmp    $0x1,%ecx
  800cd3:	7e 19                	jle    800cee <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  800cd5:	8b 45 14             	mov    0x14(%ebp),%eax
  800cd8:	8b 50 04             	mov    0x4(%eax),%edx
  800cdb:	8b 00                	mov    (%eax),%eax
  800cdd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ce0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ce3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ce6:	8d 40 08             	lea    0x8(%eax),%eax
  800ce9:	89 45 14             	mov    %eax,0x14(%ebp)
  800cec:	eb 38                	jmp    800d26 <vprintfmt+0x2f2>
	else if (lflag)
  800cee:	85 c9                	test   %ecx,%ecx
  800cf0:	74 1b                	je     800d0d <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  800cf2:	8b 45 14             	mov    0x14(%ebp),%eax
  800cf5:	8b 00                	mov    (%eax),%eax
  800cf7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800cfa:	89 c1                	mov    %eax,%ecx
  800cfc:	c1 f9 1f             	sar    $0x1f,%ecx
  800cff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800d02:	8b 45 14             	mov    0x14(%ebp),%eax
  800d05:	8d 40 04             	lea    0x4(%eax),%eax
  800d08:	89 45 14             	mov    %eax,0x14(%ebp)
  800d0b:	eb 19                	jmp    800d26 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  800d0d:	8b 45 14             	mov    0x14(%ebp),%eax
  800d10:	8b 00                	mov    (%eax),%eax
  800d12:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d15:	89 c1                	mov    %eax,%ecx
  800d17:	c1 f9 1f             	sar    $0x1f,%ecx
  800d1a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800d1d:	8b 45 14             	mov    0x14(%ebp),%eax
  800d20:	8d 40 04             	lea    0x4(%eax),%eax
  800d23:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800d26:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800d29:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800d2c:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800d31:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800d35:	0f 89 04 01 00 00    	jns    800e3f <vprintfmt+0x40b>
				putch('-', putdat);
  800d3b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d3f:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800d46:	ff d6                	call   *%esi
				num = -(long long) num;
  800d48:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800d4b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800d4e:	f7 da                	neg    %edx
  800d50:	83 d1 00             	adc    $0x0,%ecx
  800d53:	f7 d9                	neg    %ecx
  800d55:	e9 e5 00 00 00       	jmp    800e3f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800d5a:	83 f9 01             	cmp    $0x1,%ecx
  800d5d:	7e 10                	jle    800d6f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  800d5f:	8b 45 14             	mov    0x14(%ebp),%eax
  800d62:	8b 10                	mov    (%eax),%edx
  800d64:	8b 48 04             	mov    0x4(%eax),%ecx
  800d67:	8d 40 08             	lea    0x8(%eax),%eax
  800d6a:	89 45 14             	mov    %eax,0x14(%ebp)
  800d6d:	eb 26                	jmp    800d95 <vprintfmt+0x361>
	else if (lflag)
  800d6f:	85 c9                	test   %ecx,%ecx
  800d71:	74 12                	je     800d85 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  800d73:	8b 45 14             	mov    0x14(%ebp),%eax
  800d76:	8b 10                	mov    (%eax),%edx
  800d78:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7d:	8d 40 04             	lea    0x4(%eax),%eax
  800d80:	89 45 14             	mov    %eax,0x14(%ebp)
  800d83:	eb 10                	jmp    800d95 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  800d85:	8b 45 14             	mov    0x14(%ebp),%eax
  800d88:	8b 10                	mov    (%eax),%edx
  800d8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8f:	8d 40 04             	lea    0x4(%eax),%eax
  800d92:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800d95:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  800d9a:	e9 a0 00 00 00       	jmp    800e3f <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800d9f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800da3:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800daa:	ff d6                	call   *%esi
			putch('X', putdat);
  800dac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800db0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800db7:	ff d6                	call   *%esi
			putch('X', putdat);
  800db9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dbd:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800dc4:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dc6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800dc9:	e9 8b fc ff ff       	jmp    800a59 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  800dce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dd2:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800dd9:	ff d6                	call   *%esi
			putch('x', putdat);
  800ddb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ddf:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800de6:	ff d6                	call   *%esi
			num = (unsigned long long)
  800de8:	8b 45 14             	mov    0x14(%ebp),%eax
  800deb:	8b 10                	mov    (%eax),%edx
  800ded:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  800df2:	8d 40 04             	lea    0x4(%eax),%eax
  800df5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800df8:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  800dfd:	eb 40                	jmp    800e3f <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800dff:	83 f9 01             	cmp    $0x1,%ecx
  800e02:	7e 10                	jle    800e14 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  800e04:	8b 45 14             	mov    0x14(%ebp),%eax
  800e07:	8b 10                	mov    (%eax),%edx
  800e09:	8b 48 04             	mov    0x4(%eax),%ecx
  800e0c:	8d 40 08             	lea    0x8(%eax),%eax
  800e0f:	89 45 14             	mov    %eax,0x14(%ebp)
  800e12:	eb 26                	jmp    800e3a <vprintfmt+0x406>
	else if (lflag)
  800e14:	85 c9                	test   %ecx,%ecx
  800e16:	74 12                	je     800e2a <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  800e18:	8b 45 14             	mov    0x14(%ebp),%eax
  800e1b:	8b 10                	mov    (%eax),%edx
  800e1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e22:	8d 40 04             	lea    0x4(%eax),%eax
  800e25:	89 45 14             	mov    %eax,0x14(%ebp)
  800e28:	eb 10                	jmp    800e3a <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  800e2a:	8b 45 14             	mov    0x14(%ebp),%eax
  800e2d:	8b 10                	mov    (%eax),%edx
  800e2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e34:	8d 40 04             	lea    0x4(%eax),%eax
  800e37:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800e3a:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  800e3f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800e43:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e47:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e4a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e4e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e52:	89 14 24             	mov    %edx,(%esp)
  800e55:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e59:	89 da                	mov    %ebx,%edx
  800e5b:	89 f0                	mov    %esi,%eax
  800e5d:	e8 9e fa ff ff       	call   800900 <printnum>
			break;
  800e62:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800e65:	e9 ef fb ff ff       	jmp    800a59 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800e6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e6e:	89 04 24             	mov    %eax,(%esp)
  800e71:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e73:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800e76:	e9 de fb ff ff       	jmp    800a59 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800e7b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e7f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800e86:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800e88:	eb 03                	jmp    800e8d <vprintfmt+0x459>
  800e8a:	83 ef 01             	sub    $0x1,%edi
  800e8d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800e91:	75 f7                	jne    800e8a <vprintfmt+0x456>
  800e93:	e9 c1 fb ff ff       	jmp    800a59 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  800e98:	83 c4 3c             	add    $0x3c,%esp
  800e9b:	5b                   	pop    %ebx
  800e9c:	5e                   	pop    %esi
  800e9d:	5f                   	pop    %edi
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	83 ec 28             	sub    $0x28,%esp
  800ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800eac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800eaf:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800eb3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800eb6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ebd:	85 c0                	test   %eax,%eax
  800ebf:	74 30                	je     800ef1 <vsnprintf+0x51>
  800ec1:	85 d2                	test   %edx,%edx
  800ec3:	7e 2c                	jle    800ef1 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ec5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ec8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ecc:	8b 45 10             	mov    0x10(%ebp),%eax
  800ecf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ed3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ed6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eda:	c7 04 24 ef 09 80 00 	movl   $0x8009ef,(%esp)
  800ee1:	e8 4e fb ff ff       	call   800a34 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ee6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ee9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800eec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eef:	eb 05                	jmp    800ef6 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800ef1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800ef6:	c9                   	leave  
  800ef7:	c3                   	ret    

00800ef8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800efe:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800f01:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f05:	8b 45 10             	mov    0x10(%ebp),%eax
  800f08:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f13:	8b 45 08             	mov    0x8(%ebp),%eax
  800f16:	89 04 24             	mov    %eax,(%esp)
  800f19:	e8 82 ff ff ff       	call   800ea0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800f1e:	c9                   	leave  
  800f1f:	c3                   	ret    

00800f20 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800f26:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2b:	eb 03                	jmp    800f30 <strlen+0x10>
		n++;
  800f2d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800f30:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800f34:	75 f7                	jne    800f2d <strlen+0xd>
		n++;
	return n;
}
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    

00800f38 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f3e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f41:	b8 00 00 00 00       	mov    $0x0,%eax
  800f46:	eb 03                	jmp    800f4b <strnlen+0x13>
		n++;
  800f48:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f4b:	39 d0                	cmp    %edx,%eax
  800f4d:	74 06                	je     800f55 <strnlen+0x1d>
  800f4f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800f53:	75 f3                	jne    800f48 <strnlen+0x10>
		n++;
	return n;
}
  800f55:	5d                   	pop    %ebp
  800f56:	c3                   	ret    

00800f57 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	53                   	push   %ebx
  800f5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800f61:	89 c2                	mov    %eax,%edx
  800f63:	83 c2 01             	add    $0x1,%edx
  800f66:	83 c1 01             	add    $0x1,%ecx
  800f69:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800f6d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800f70:	84 db                	test   %bl,%bl
  800f72:	75 ef                	jne    800f63 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800f74:	5b                   	pop    %ebx
  800f75:	5d                   	pop    %ebp
  800f76:	c3                   	ret    

00800f77 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	53                   	push   %ebx
  800f7b:	83 ec 08             	sub    $0x8,%esp
  800f7e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800f81:	89 1c 24             	mov    %ebx,(%esp)
  800f84:	e8 97 ff ff ff       	call   800f20 <strlen>
	strcpy(dst + len, src);
  800f89:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f90:	01 d8                	add    %ebx,%eax
  800f92:	89 04 24             	mov    %eax,(%esp)
  800f95:	e8 bd ff ff ff       	call   800f57 <strcpy>
	return dst;
}
  800f9a:	89 d8                	mov    %ebx,%eax
  800f9c:	83 c4 08             	add    $0x8,%esp
  800f9f:	5b                   	pop    %ebx
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    

00800fa2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	56                   	push   %esi
  800fa6:	53                   	push   %ebx
  800fa7:	8b 75 08             	mov    0x8(%ebp),%esi
  800faa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fad:	89 f3                	mov    %esi,%ebx
  800faf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800fb2:	89 f2                	mov    %esi,%edx
  800fb4:	eb 0f                	jmp    800fc5 <strncpy+0x23>
		*dst++ = *src;
  800fb6:	83 c2 01             	add    $0x1,%edx
  800fb9:	0f b6 01             	movzbl (%ecx),%eax
  800fbc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800fbf:	80 39 01             	cmpb   $0x1,(%ecx)
  800fc2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800fc5:	39 da                	cmp    %ebx,%edx
  800fc7:	75 ed                	jne    800fb6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800fc9:	89 f0                	mov    %esi,%eax
  800fcb:	5b                   	pop    %ebx
  800fcc:	5e                   	pop    %esi
  800fcd:	5d                   	pop    %ebp
  800fce:	c3                   	ret    

00800fcf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	56                   	push   %esi
  800fd3:	53                   	push   %ebx
  800fd4:	8b 75 08             	mov    0x8(%ebp),%esi
  800fd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fda:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fdd:	89 f0                	mov    %esi,%eax
  800fdf:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800fe3:	85 c9                	test   %ecx,%ecx
  800fe5:	75 0b                	jne    800ff2 <strlcpy+0x23>
  800fe7:	eb 1d                	jmp    801006 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800fe9:	83 c0 01             	add    $0x1,%eax
  800fec:	83 c2 01             	add    $0x1,%edx
  800fef:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ff2:	39 d8                	cmp    %ebx,%eax
  800ff4:	74 0b                	je     801001 <strlcpy+0x32>
  800ff6:	0f b6 0a             	movzbl (%edx),%ecx
  800ff9:	84 c9                	test   %cl,%cl
  800ffb:	75 ec                	jne    800fe9 <strlcpy+0x1a>
  800ffd:	89 c2                	mov    %eax,%edx
  800fff:	eb 02                	jmp    801003 <strlcpy+0x34>
  801001:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801003:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801006:	29 f0                	sub    %esi,%eax
}
  801008:	5b                   	pop    %ebx
  801009:	5e                   	pop    %esi
  80100a:	5d                   	pop    %ebp
  80100b:	c3                   	ret    

0080100c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801012:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801015:	eb 06                	jmp    80101d <strcmp+0x11>
		p++, q++;
  801017:	83 c1 01             	add    $0x1,%ecx
  80101a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80101d:	0f b6 01             	movzbl (%ecx),%eax
  801020:	84 c0                	test   %al,%al
  801022:	74 04                	je     801028 <strcmp+0x1c>
  801024:	3a 02                	cmp    (%edx),%al
  801026:	74 ef                	je     801017 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801028:	0f b6 c0             	movzbl %al,%eax
  80102b:	0f b6 12             	movzbl (%edx),%edx
  80102e:	29 d0                	sub    %edx,%eax
}
  801030:	5d                   	pop    %ebp
  801031:	c3                   	ret    

00801032 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
  801035:	53                   	push   %ebx
  801036:	8b 45 08             	mov    0x8(%ebp),%eax
  801039:	8b 55 0c             	mov    0xc(%ebp),%edx
  80103c:	89 c3                	mov    %eax,%ebx
  80103e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801041:	eb 06                	jmp    801049 <strncmp+0x17>
		n--, p++, q++;
  801043:	83 c0 01             	add    $0x1,%eax
  801046:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801049:	39 d8                	cmp    %ebx,%eax
  80104b:	74 15                	je     801062 <strncmp+0x30>
  80104d:	0f b6 08             	movzbl (%eax),%ecx
  801050:	84 c9                	test   %cl,%cl
  801052:	74 04                	je     801058 <strncmp+0x26>
  801054:	3a 0a                	cmp    (%edx),%cl
  801056:	74 eb                	je     801043 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801058:	0f b6 00             	movzbl (%eax),%eax
  80105b:	0f b6 12             	movzbl (%edx),%edx
  80105e:	29 d0                	sub    %edx,%eax
  801060:	eb 05                	jmp    801067 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801062:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801067:	5b                   	pop    %ebx
  801068:	5d                   	pop    %ebp
  801069:	c3                   	ret    

0080106a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	8b 45 08             	mov    0x8(%ebp),%eax
  801070:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801074:	eb 07                	jmp    80107d <strchr+0x13>
		if (*s == c)
  801076:	38 ca                	cmp    %cl,%dl
  801078:	74 0f                	je     801089 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80107a:	83 c0 01             	add    $0x1,%eax
  80107d:	0f b6 10             	movzbl (%eax),%edx
  801080:	84 d2                	test   %dl,%dl
  801082:	75 f2                	jne    801076 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801084:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801089:	5d                   	pop    %ebp
  80108a:	c3                   	ret    

0080108b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	8b 45 08             	mov    0x8(%ebp),%eax
  801091:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801095:	eb 07                	jmp    80109e <strfind+0x13>
		if (*s == c)
  801097:	38 ca                	cmp    %cl,%dl
  801099:	74 0a                	je     8010a5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80109b:	83 c0 01             	add    $0x1,%eax
  80109e:	0f b6 10             	movzbl (%eax),%edx
  8010a1:	84 d2                	test   %dl,%dl
  8010a3:	75 f2                	jne    801097 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8010a5:	5d                   	pop    %ebp
  8010a6:	c3                   	ret    

008010a7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8010a7:	55                   	push   %ebp
  8010a8:	89 e5                	mov    %esp,%ebp
  8010aa:	57                   	push   %edi
  8010ab:	56                   	push   %esi
  8010ac:	53                   	push   %ebx
  8010ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8010b3:	85 c9                	test   %ecx,%ecx
  8010b5:	74 36                	je     8010ed <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8010b7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8010bd:	75 28                	jne    8010e7 <memset+0x40>
  8010bf:	f6 c1 03             	test   $0x3,%cl
  8010c2:	75 23                	jne    8010e7 <memset+0x40>
		c &= 0xFF;
  8010c4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8010c8:	89 d3                	mov    %edx,%ebx
  8010ca:	c1 e3 08             	shl    $0x8,%ebx
  8010cd:	89 d6                	mov    %edx,%esi
  8010cf:	c1 e6 18             	shl    $0x18,%esi
  8010d2:	89 d0                	mov    %edx,%eax
  8010d4:	c1 e0 10             	shl    $0x10,%eax
  8010d7:	09 f0                	or     %esi,%eax
  8010d9:	09 c2                	or     %eax,%edx
  8010db:	89 d0                	mov    %edx,%eax
  8010dd:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8010df:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8010e2:	fc                   	cld    
  8010e3:	f3 ab                	rep stos %eax,%es:(%edi)
  8010e5:	eb 06                	jmp    8010ed <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8010e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010ea:	fc                   	cld    
  8010eb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8010ed:	89 f8                	mov    %edi,%eax
  8010ef:	5b                   	pop    %ebx
  8010f0:	5e                   	pop    %esi
  8010f1:	5f                   	pop    %edi
  8010f2:	5d                   	pop    %ebp
  8010f3:	c3                   	ret    

008010f4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	57                   	push   %edi
  8010f8:	56                   	push   %esi
  8010f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801102:	39 c6                	cmp    %eax,%esi
  801104:	73 35                	jae    80113b <memmove+0x47>
  801106:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801109:	39 d0                	cmp    %edx,%eax
  80110b:	73 2e                	jae    80113b <memmove+0x47>
		s += n;
		d += n;
  80110d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801110:	89 d6                	mov    %edx,%esi
  801112:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801114:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80111a:	75 13                	jne    80112f <memmove+0x3b>
  80111c:	f6 c1 03             	test   $0x3,%cl
  80111f:	75 0e                	jne    80112f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801121:	83 ef 04             	sub    $0x4,%edi
  801124:	8d 72 fc             	lea    -0x4(%edx),%esi
  801127:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80112a:	fd                   	std    
  80112b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80112d:	eb 09                	jmp    801138 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80112f:	83 ef 01             	sub    $0x1,%edi
  801132:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801135:	fd                   	std    
  801136:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801138:	fc                   	cld    
  801139:	eb 1d                	jmp    801158 <memmove+0x64>
  80113b:	89 f2                	mov    %esi,%edx
  80113d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80113f:	f6 c2 03             	test   $0x3,%dl
  801142:	75 0f                	jne    801153 <memmove+0x5f>
  801144:	f6 c1 03             	test   $0x3,%cl
  801147:	75 0a                	jne    801153 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801149:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80114c:	89 c7                	mov    %eax,%edi
  80114e:	fc                   	cld    
  80114f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801151:	eb 05                	jmp    801158 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801153:	89 c7                	mov    %eax,%edi
  801155:	fc                   	cld    
  801156:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801158:	5e                   	pop    %esi
  801159:	5f                   	pop    %edi
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    

0080115c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801162:	8b 45 10             	mov    0x10(%ebp),%eax
  801165:	89 44 24 08          	mov    %eax,0x8(%esp)
  801169:	8b 45 0c             	mov    0xc(%ebp),%eax
  80116c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801170:	8b 45 08             	mov    0x8(%ebp),%eax
  801173:	89 04 24             	mov    %eax,(%esp)
  801176:	e8 79 ff ff ff       	call   8010f4 <memmove>
}
  80117b:	c9                   	leave  
  80117c:	c3                   	ret    

0080117d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80117d:	55                   	push   %ebp
  80117e:	89 e5                	mov    %esp,%ebp
  801180:	56                   	push   %esi
  801181:	53                   	push   %ebx
  801182:	8b 55 08             	mov    0x8(%ebp),%edx
  801185:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801188:	89 d6                	mov    %edx,%esi
  80118a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80118d:	eb 1a                	jmp    8011a9 <memcmp+0x2c>
		if (*s1 != *s2)
  80118f:	0f b6 02             	movzbl (%edx),%eax
  801192:	0f b6 19             	movzbl (%ecx),%ebx
  801195:	38 d8                	cmp    %bl,%al
  801197:	74 0a                	je     8011a3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801199:	0f b6 c0             	movzbl %al,%eax
  80119c:	0f b6 db             	movzbl %bl,%ebx
  80119f:	29 d8                	sub    %ebx,%eax
  8011a1:	eb 0f                	jmp    8011b2 <memcmp+0x35>
		s1++, s2++;
  8011a3:	83 c2 01             	add    $0x1,%edx
  8011a6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011a9:	39 f2                	cmp    %esi,%edx
  8011ab:	75 e2                	jne    80118f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8011ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011b2:	5b                   	pop    %ebx
  8011b3:	5e                   	pop    %esi
  8011b4:	5d                   	pop    %ebp
  8011b5:	c3                   	ret    

008011b6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8011bf:	89 c2                	mov    %eax,%edx
  8011c1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8011c4:	eb 07                	jmp    8011cd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8011c6:	38 08                	cmp    %cl,(%eax)
  8011c8:	74 07                	je     8011d1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8011ca:	83 c0 01             	add    $0x1,%eax
  8011cd:	39 d0                	cmp    %edx,%eax
  8011cf:	72 f5                	jb     8011c6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8011d1:	5d                   	pop    %ebp
  8011d2:	c3                   	ret    

008011d3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	57                   	push   %edi
  8011d7:	56                   	push   %esi
  8011d8:	53                   	push   %ebx
  8011d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011dc:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8011df:	eb 03                	jmp    8011e4 <strtol+0x11>
		s++;
  8011e1:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8011e4:	0f b6 0a             	movzbl (%edx),%ecx
  8011e7:	80 f9 09             	cmp    $0x9,%cl
  8011ea:	74 f5                	je     8011e1 <strtol+0xe>
  8011ec:	80 f9 20             	cmp    $0x20,%cl
  8011ef:	74 f0                	je     8011e1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8011f1:	80 f9 2b             	cmp    $0x2b,%cl
  8011f4:	75 0a                	jne    801200 <strtol+0x2d>
		s++;
  8011f6:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8011f9:	bf 00 00 00 00       	mov    $0x0,%edi
  8011fe:	eb 11                	jmp    801211 <strtol+0x3e>
  801200:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801205:	80 f9 2d             	cmp    $0x2d,%cl
  801208:	75 07                	jne    801211 <strtol+0x3e>
		s++, neg = 1;
  80120a:	8d 52 01             	lea    0x1(%edx),%edx
  80120d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801211:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  801216:	75 15                	jne    80122d <strtol+0x5a>
  801218:	80 3a 30             	cmpb   $0x30,(%edx)
  80121b:	75 10                	jne    80122d <strtol+0x5a>
  80121d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801221:	75 0a                	jne    80122d <strtol+0x5a>
		s += 2, base = 16;
  801223:	83 c2 02             	add    $0x2,%edx
  801226:	b8 10 00 00 00       	mov    $0x10,%eax
  80122b:	eb 10                	jmp    80123d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80122d:	85 c0                	test   %eax,%eax
  80122f:	75 0c                	jne    80123d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801231:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801233:	80 3a 30             	cmpb   $0x30,(%edx)
  801236:	75 05                	jne    80123d <strtol+0x6a>
		s++, base = 8;
  801238:	83 c2 01             	add    $0x1,%edx
  80123b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80123d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801242:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801245:	0f b6 0a             	movzbl (%edx),%ecx
  801248:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80124b:	89 f0                	mov    %esi,%eax
  80124d:	3c 09                	cmp    $0x9,%al
  80124f:	77 08                	ja     801259 <strtol+0x86>
			dig = *s - '0';
  801251:	0f be c9             	movsbl %cl,%ecx
  801254:	83 e9 30             	sub    $0x30,%ecx
  801257:	eb 20                	jmp    801279 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  801259:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80125c:	89 f0                	mov    %esi,%eax
  80125e:	3c 19                	cmp    $0x19,%al
  801260:	77 08                	ja     80126a <strtol+0x97>
			dig = *s - 'a' + 10;
  801262:	0f be c9             	movsbl %cl,%ecx
  801265:	83 e9 57             	sub    $0x57,%ecx
  801268:	eb 0f                	jmp    801279 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80126a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80126d:	89 f0                	mov    %esi,%eax
  80126f:	3c 19                	cmp    $0x19,%al
  801271:	77 16                	ja     801289 <strtol+0xb6>
			dig = *s - 'A' + 10;
  801273:	0f be c9             	movsbl %cl,%ecx
  801276:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801279:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  80127c:	7d 0f                	jge    80128d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  80127e:	83 c2 01             	add    $0x1,%edx
  801281:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  801285:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  801287:	eb bc                	jmp    801245 <strtol+0x72>
  801289:	89 d8                	mov    %ebx,%eax
  80128b:	eb 02                	jmp    80128f <strtol+0xbc>
  80128d:	89 d8                	mov    %ebx,%eax

	if (endptr)
  80128f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801293:	74 05                	je     80129a <strtol+0xc7>
		*endptr = (char *) s;
  801295:	8b 75 0c             	mov    0xc(%ebp),%esi
  801298:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  80129a:	f7 d8                	neg    %eax
  80129c:	85 ff                	test   %edi,%edi
  80129e:	0f 44 c3             	cmove  %ebx,%eax
}
  8012a1:	5b                   	pop    %ebx
  8012a2:	5e                   	pop    %esi
  8012a3:	5f                   	pop    %edi
  8012a4:	5d                   	pop    %ebp
  8012a5:	c3                   	ret    

008012a6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
  8012a9:	57                   	push   %edi
  8012aa:	56                   	push   %esi
  8012ab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b7:	89 c3                	mov    %eax,%ebx
  8012b9:	89 c7                	mov    %eax,%edi
  8012bb:	89 c6                	mov    %eax,%esi
  8012bd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8012bf:	5b                   	pop    %ebx
  8012c0:	5e                   	pop    %esi
  8012c1:	5f                   	pop    %edi
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    

008012c4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	57                   	push   %edi
  8012c8:	56                   	push   %esi
  8012c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8012cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8012d4:	89 d1                	mov    %edx,%ecx
  8012d6:	89 d3                	mov    %edx,%ebx
  8012d8:	89 d7                	mov    %edx,%edi
  8012da:	89 d6                	mov    %edx,%esi
  8012dc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8012de:	5b                   	pop    %ebx
  8012df:	5e                   	pop    %esi
  8012e0:	5f                   	pop    %edi
  8012e1:	5d                   	pop    %ebp
  8012e2:	c3                   	ret    

008012e3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	57                   	push   %edi
  8012e7:	56                   	push   %esi
  8012e8:	53                   	push   %ebx
  8012e9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012f1:	b8 03 00 00 00       	mov    $0x3,%eax
  8012f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f9:	89 cb                	mov    %ecx,%ebx
  8012fb:	89 cf                	mov    %ecx,%edi
  8012fd:	89 ce                	mov    %ecx,%esi
  8012ff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801301:	85 c0                	test   %eax,%eax
  801303:	7e 28                	jle    80132d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801305:	89 44 24 10          	mov    %eax,0x10(%esp)
  801309:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801310:	00 
  801311:	c7 44 24 08 bf 2e 80 	movl   $0x802ebf,0x8(%esp)
  801318:	00 
  801319:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801320:	00 
  801321:	c7 04 24 dc 2e 80 00 	movl   $0x802edc,(%esp)
  801328:	e8 b2 f4 ff ff       	call   8007df <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80132d:	83 c4 2c             	add    $0x2c,%esp
  801330:	5b                   	pop    %ebx
  801331:	5e                   	pop    %esi
  801332:	5f                   	pop    %edi
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    

00801335 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	57                   	push   %edi
  801339:	56                   	push   %esi
  80133a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80133b:	ba 00 00 00 00       	mov    $0x0,%edx
  801340:	b8 02 00 00 00       	mov    $0x2,%eax
  801345:	89 d1                	mov    %edx,%ecx
  801347:	89 d3                	mov    %edx,%ebx
  801349:	89 d7                	mov    %edx,%edi
  80134b:	89 d6                	mov    %edx,%esi
  80134d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80134f:	5b                   	pop    %ebx
  801350:	5e                   	pop    %esi
  801351:	5f                   	pop    %edi
  801352:	5d                   	pop    %ebp
  801353:	c3                   	ret    

00801354 <sys_yield>:

void
sys_yield(void)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
  801357:	57                   	push   %edi
  801358:	56                   	push   %esi
  801359:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80135a:	ba 00 00 00 00       	mov    $0x0,%edx
  80135f:	b8 0b 00 00 00       	mov    $0xb,%eax
  801364:	89 d1                	mov    %edx,%ecx
  801366:	89 d3                	mov    %edx,%ebx
  801368:	89 d7                	mov    %edx,%edi
  80136a:	89 d6                	mov    %edx,%esi
  80136c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80136e:	5b                   	pop    %ebx
  80136f:	5e                   	pop    %esi
  801370:	5f                   	pop    %edi
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    

00801373 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	57                   	push   %edi
  801377:	56                   	push   %esi
  801378:	53                   	push   %ebx
  801379:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80137c:	be 00 00 00 00       	mov    $0x0,%esi
  801381:	b8 04 00 00 00       	mov    $0x4,%eax
  801386:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801389:	8b 55 08             	mov    0x8(%ebp),%edx
  80138c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80138f:	89 f7                	mov    %esi,%edi
  801391:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801393:	85 c0                	test   %eax,%eax
  801395:	7e 28                	jle    8013bf <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801397:	89 44 24 10          	mov    %eax,0x10(%esp)
  80139b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8013a2:	00 
  8013a3:	c7 44 24 08 bf 2e 80 	movl   $0x802ebf,0x8(%esp)
  8013aa:	00 
  8013ab:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013b2:	00 
  8013b3:	c7 04 24 dc 2e 80 00 	movl   $0x802edc,(%esp)
  8013ba:	e8 20 f4 ff ff       	call   8007df <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8013bf:	83 c4 2c             	add    $0x2c,%esp
  8013c2:	5b                   	pop    %ebx
  8013c3:	5e                   	pop    %esi
  8013c4:	5f                   	pop    %edi
  8013c5:	5d                   	pop    %ebp
  8013c6:	c3                   	ret    

008013c7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	57                   	push   %edi
  8013cb:	56                   	push   %esi
  8013cc:	53                   	push   %ebx
  8013cd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013d0:	b8 05 00 00 00       	mov    $0x5,%eax
  8013d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8013db:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013de:	8b 7d 14             	mov    0x14(%ebp),%edi
  8013e1:	8b 75 18             	mov    0x18(%ebp),%esi
  8013e4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	7e 28                	jle    801412 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013ea:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013ee:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8013f5:	00 
  8013f6:	c7 44 24 08 bf 2e 80 	movl   $0x802ebf,0x8(%esp)
  8013fd:	00 
  8013fe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801405:	00 
  801406:	c7 04 24 dc 2e 80 00 	movl   $0x802edc,(%esp)
  80140d:	e8 cd f3 ff ff       	call   8007df <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801412:	83 c4 2c             	add    $0x2c,%esp
  801415:	5b                   	pop    %ebx
  801416:	5e                   	pop    %esi
  801417:	5f                   	pop    %edi
  801418:	5d                   	pop    %ebp
  801419:	c3                   	ret    

0080141a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80141a:	55                   	push   %ebp
  80141b:	89 e5                	mov    %esp,%ebp
  80141d:	57                   	push   %edi
  80141e:	56                   	push   %esi
  80141f:	53                   	push   %ebx
  801420:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801423:	bb 00 00 00 00       	mov    $0x0,%ebx
  801428:	b8 06 00 00 00       	mov    $0x6,%eax
  80142d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801430:	8b 55 08             	mov    0x8(%ebp),%edx
  801433:	89 df                	mov    %ebx,%edi
  801435:	89 de                	mov    %ebx,%esi
  801437:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801439:	85 c0                	test   %eax,%eax
  80143b:	7e 28                	jle    801465 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80143d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801441:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801448:	00 
  801449:	c7 44 24 08 bf 2e 80 	movl   $0x802ebf,0x8(%esp)
  801450:	00 
  801451:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801458:	00 
  801459:	c7 04 24 dc 2e 80 00 	movl   $0x802edc,(%esp)
  801460:	e8 7a f3 ff ff       	call   8007df <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801465:	83 c4 2c             	add    $0x2c,%esp
  801468:	5b                   	pop    %ebx
  801469:	5e                   	pop    %esi
  80146a:	5f                   	pop    %edi
  80146b:	5d                   	pop    %ebp
  80146c:	c3                   	ret    

0080146d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80146d:	55                   	push   %ebp
  80146e:	89 e5                	mov    %esp,%ebp
  801470:	57                   	push   %edi
  801471:	56                   	push   %esi
  801472:	53                   	push   %ebx
  801473:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801476:	bb 00 00 00 00       	mov    $0x0,%ebx
  80147b:	b8 08 00 00 00       	mov    $0x8,%eax
  801480:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801483:	8b 55 08             	mov    0x8(%ebp),%edx
  801486:	89 df                	mov    %ebx,%edi
  801488:	89 de                	mov    %ebx,%esi
  80148a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80148c:	85 c0                	test   %eax,%eax
  80148e:	7e 28                	jle    8014b8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801490:	89 44 24 10          	mov    %eax,0x10(%esp)
  801494:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80149b:	00 
  80149c:	c7 44 24 08 bf 2e 80 	movl   $0x802ebf,0x8(%esp)
  8014a3:	00 
  8014a4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014ab:	00 
  8014ac:	c7 04 24 dc 2e 80 00 	movl   $0x802edc,(%esp)
  8014b3:	e8 27 f3 ff ff       	call   8007df <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8014b8:	83 c4 2c             	add    $0x2c,%esp
  8014bb:	5b                   	pop    %ebx
  8014bc:	5e                   	pop    %esi
  8014bd:	5f                   	pop    %edi
  8014be:	5d                   	pop    %ebp
  8014bf:	c3                   	ret    

008014c0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	57                   	push   %edi
  8014c4:	56                   	push   %esi
  8014c5:	53                   	push   %ebx
  8014c6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ce:	b8 09 00 00 00       	mov    $0x9,%eax
  8014d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8014d9:	89 df                	mov    %ebx,%edi
  8014db:	89 de                	mov    %ebx,%esi
  8014dd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	7e 28                	jle    80150b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014e3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014e7:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8014ee:	00 
  8014ef:	c7 44 24 08 bf 2e 80 	movl   $0x802ebf,0x8(%esp)
  8014f6:	00 
  8014f7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014fe:	00 
  8014ff:	c7 04 24 dc 2e 80 00 	movl   $0x802edc,(%esp)
  801506:	e8 d4 f2 ff ff       	call   8007df <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80150b:	83 c4 2c             	add    $0x2c,%esp
  80150e:	5b                   	pop    %ebx
  80150f:	5e                   	pop    %esi
  801510:	5f                   	pop    %edi
  801511:	5d                   	pop    %ebp
  801512:	c3                   	ret    

00801513 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801513:	55                   	push   %ebp
  801514:	89 e5                	mov    %esp,%ebp
  801516:	57                   	push   %edi
  801517:	56                   	push   %esi
  801518:	53                   	push   %ebx
  801519:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80151c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801521:	b8 0a 00 00 00       	mov    $0xa,%eax
  801526:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801529:	8b 55 08             	mov    0x8(%ebp),%edx
  80152c:	89 df                	mov    %ebx,%edi
  80152e:	89 de                	mov    %ebx,%esi
  801530:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801532:	85 c0                	test   %eax,%eax
  801534:	7e 28                	jle    80155e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801536:	89 44 24 10          	mov    %eax,0x10(%esp)
  80153a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801541:	00 
  801542:	c7 44 24 08 bf 2e 80 	movl   $0x802ebf,0x8(%esp)
  801549:	00 
  80154a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801551:	00 
  801552:	c7 04 24 dc 2e 80 00 	movl   $0x802edc,(%esp)
  801559:	e8 81 f2 ff ff       	call   8007df <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80155e:	83 c4 2c             	add    $0x2c,%esp
  801561:	5b                   	pop    %ebx
  801562:	5e                   	pop    %esi
  801563:	5f                   	pop    %edi
  801564:	5d                   	pop    %ebp
  801565:	c3                   	ret    

00801566 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	57                   	push   %edi
  80156a:	56                   	push   %esi
  80156b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80156c:	be 00 00 00 00       	mov    $0x0,%esi
  801571:	b8 0c 00 00 00       	mov    $0xc,%eax
  801576:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801579:	8b 55 08             	mov    0x8(%ebp),%edx
  80157c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80157f:	8b 7d 14             	mov    0x14(%ebp),%edi
  801582:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801584:	5b                   	pop    %ebx
  801585:	5e                   	pop    %esi
  801586:	5f                   	pop    %edi
  801587:	5d                   	pop    %ebp
  801588:	c3                   	ret    

00801589 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801589:	55                   	push   %ebp
  80158a:	89 e5                	mov    %esp,%ebp
  80158c:	57                   	push   %edi
  80158d:	56                   	push   %esi
  80158e:	53                   	push   %ebx
  80158f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801592:	b9 00 00 00 00       	mov    $0x0,%ecx
  801597:	b8 0d 00 00 00       	mov    $0xd,%eax
  80159c:	8b 55 08             	mov    0x8(%ebp),%edx
  80159f:	89 cb                	mov    %ecx,%ebx
  8015a1:	89 cf                	mov    %ecx,%edi
  8015a3:	89 ce                	mov    %ecx,%esi
  8015a5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	7e 28                	jle    8015d3 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015ab:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015af:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8015b6:	00 
  8015b7:	c7 44 24 08 bf 2e 80 	movl   $0x802ebf,0x8(%esp)
  8015be:	00 
  8015bf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8015c6:	00 
  8015c7:	c7 04 24 dc 2e 80 00 	movl   $0x802edc,(%esp)
  8015ce:	e8 0c f2 ff ff       	call   8007df <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8015d3:	83 c4 2c             	add    $0x2c,%esp
  8015d6:	5b                   	pop    %ebx
  8015d7:	5e                   	pop    %esi
  8015d8:	5f                   	pop    %edi
  8015d9:	5d                   	pop    %ebp
  8015da:	c3                   	ret    
  8015db:	66 90                	xchg   %ax,%ax
  8015dd:	66 90                	xchg   %ax,%ax
  8015df:	90                   	nop

008015e0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
  8015e3:	56                   	push   %esi
  8015e4:	53                   	push   %ebx
  8015e5:	83 ec 10             	sub    $0x10,%esp
  8015e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8015eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB : Your code here.
	int r =0;
	int a;
	if(pg == 0)
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	75 0e                	jne    801603 <ipc_recv+0x23>
		r= sys_ipc_recv( (void *)UTOP);
  8015f5:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8015fc:	e8 88 ff ff ff       	call   801589 <sys_ipc_recv>
  801601:	eb 08                	jmp    80160b <ipc_recv+0x2b>
	else
		r = sys_ipc_recv(pg);
  801603:	89 04 24             	mov    %eax,(%esp)
  801606:	e8 7e ff ff ff       	call   801589 <sys_ipc_recv>
	if(r == 0){
  80160b:	85 c0                	test   %eax,%eax
  80160d:	8d 76 00             	lea    0x0(%esi),%esi
  801610:	75 1e                	jne    801630 <ipc_recv+0x50>
		if( from_env_store != 0 )
  801612:	85 f6                	test   %esi,%esi
  801614:	74 0a                	je     801620 <ipc_recv+0x40>
			*from_env_store = thisenv->env_ipc_from;
  801616:	a1 04 50 80 00       	mov    0x805004,%eax
  80161b:	8b 40 74             	mov    0x74(%eax),%eax
  80161e:	89 06                	mov    %eax,(%esi)

		if(perm_store != 0 )
  801620:	85 db                	test   %ebx,%ebx
  801622:	74 2c                	je     801650 <ipc_recv+0x70>
			*perm_store = thisenv->env_ipc_perm;
  801624:	a1 04 50 80 00       	mov    0x805004,%eax
  801629:	8b 40 78             	mov    0x78(%eax),%eax
  80162c:	89 03                	mov    %eax,(%ebx)
  80162e:	eb 20                	jmp    801650 <ipc_recv+0x70>
	}
	else{
		panic("The ipc_recv is not right, and the errno is %d\n",r);
  801630:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801634:	c7 44 24 08 ec 2e 80 	movl   $0x802eec,0x8(%esp)
  80163b:	00 
  80163c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801643:	00 
  801644:	c7 04 24 68 2f 80 00 	movl   $0x802f68,(%esp)
  80164b:	e8 8f f1 ff ff       	call   8007df <_panic>

		if(perm_store != 0 )
			*perm_store = 0;
		return r;
	}
	if(thisenv->env_ipc_value == 0)
  801650:	a1 04 50 80 00       	mov    0x805004,%eax
  801655:	8b 50 70             	mov    0x70(%eax),%edx
  801658:	85 d2                	test   %edx,%edx
  80165a:	75 13                	jne    80166f <ipc_recv+0x8f>
		cprintf("the value is 0, the envid is %x\n", thisenv->env_id);
  80165c:	8b 40 48             	mov    0x48(%eax),%eax
  80165f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801663:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  80166a:	e8 69 f2 ff ff       	call   8008d8 <cprintf>
	return thisenv->env_ipc_value;
  80166f:	a1 04 50 80 00       	mov    0x805004,%eax
  801674:	8b 40 70             	mov    0x70(%eax),%eax
}
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	5b                   	pop    %ebx
  80167b:	5e                   	pop    %esi
  80167c:	5d                   	pop    %ebp
  80167d:	c3                   	ret    

0080167e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	57                   	push   %edi
  801682:	56                   	push   %esi
  801683:	53                   	push   %ebx
  801684:	83 ec 1c             	sub    $0x1c,%esp
  801687:	8b 7d 08             	mov    0x8(%ebp),%edi
  80168a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB : Your code here.
		int r =0;
	while(1){
		if(pg == 0)
  80168d:	85 f6                	test   %esi,%esi
  80168f:	75 22                	jne    8016b3 <ipc_send+0x35>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  801691:	8b 45 14             	mov    0x14(%ebp),%eax
  801694:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801698:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80169f:	ee 
  8016a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a7:	89 3c 24             	mov    %edi,(%esp)
  8016aa:	e8 b7 fe ff ff       	call   801566 <sys_ipc_try_send>
  8016af:	89 c3                	mov    %eax,%ebx
  8016b1:	eb 1c                	jmp    8016cf <ipc_send+0x51>
		else
			r = sys_ipc_try_send(to_env,  val, pg,  perm);
  8016b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8016b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016ba:	89 74 24 08          	mov    %esi,0x8(%esp)
  8016be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c5:	89 3c 24             	mov    %edi,(%esp)
  8016c8:	e8 99 fe ff ff       	call   801566 <sys_ipc_try_send>
  8016cd:	89 c3                	mov    %eax,%ebx

		if(r <0 && r != -E_IPC_NOT_RECV){
  8016cf:	83 fb f9             	cmp    $0xfffffff9,%ebx
  8016d2:	74 3e                	je     801712 <ipc_send+0x94>
  8016d4:	89 d8                	mov    %ebx,%eax
  8016d6:	c1 e8 1f             	shr    $0x1f,%eax
  8016d9:	84 c0                	test   %al,%al
  8016db:	74 35                	je     801712 <ipc_send+0x94>
			cprintf("the envid is %x\n", sys_getenvid());
  8016dd:	e8 53 fc ff ff       	call   801335 <sys_getenvid>
  8016e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e6:	c7 04 24 72 2f 80 00 	movl   $0x802f72,(%esp)
  8016ed:	e8 e6 f1 ff ff       	call   8008d8 <cprintf>
			panic("ipc_send is error, and the errno is %d\n", r);
  8016f2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8016f6:	c7 44 24 08 40 2f 80 	movl   $0x802f40,0x8(%esp)
  8016fd:	00 
  8016fe:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  801705:	00 
  801706:	c7 04 24 68 2f 80 00 	movl   $0x802f68,(%esp)
  80170d:	e8 cd f0 ff ff       	call   8007df <_panic>
		}
		else if(r == -E_IPC_NOT_RECV)
  801712:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801715:	75 0e                	jne    801725 <ipc_send+0xa7>
			sys_yield();
  801717:	e8 38 fc ff ff       	call   801354 <sys_yield>
		else break;
	}
  80171c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801720:	e9 68 ff ff ff       	jmp    80168d <ipc_send+0xf>
	
}
  801725:	83 c4 1c             	add    $0x1c,%esp
  801728:	5b                   	pop    %ebx
  801729:	5e                   	pop    %esi
  80172a:	5f                   	pop    %edi
  80172b:	5d                   	pop    %ebp
  80172c:	c3                   	ret    

0080172d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801733:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801738:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80173b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801741:	8b 52 50             	mov    0x50(%edx),%edx
  801744:	39 ca                	cmp    %ecx,%edx
  801746:	75 0d                	jne    801755 <ipc_find_env+0x28>
			return envs[i].env_id;
  801748:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80174b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801750:	8b 40 40             	mov    0x40(%eax),%eax
  801753:	eb 0e                	jmp    801763 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801755:	83 c0 01             	add    $0x1,%eax
  801758:	3d 00 04 00 00       	cmp    $0x400,%eax
  80175d:	75 d9                	jne    801738 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80175f:	66 b8 00 00          	mov    $0x0,%ax
}
  801763:	5d                   	pop    %ebp
  801764:	c3                   	ret    
  801765:	66 90                	xchg   %ax,%ax
  801767:	66 90                	xchg   %ax,%ax
  801769:	66 90                	xchg   %ax,%ax
  80176b:	66 90                	xchg   %ax,%ax
  80176d:	66 90                	xchg   %ax,%ax
  80176f:	90                   	nop

00801770 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801773:	8b 45 08             	mov    0x8(%ebp),%eax
  801776:	05 00 00 00 30       	add    $0x30000000,%eax
  80177b:	c1 e8 0c             	shr    $0xc,%eax
}
  80177e:	5d                   	pop    %ebp
  80177f:	c3                   	ret    

00801780 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801783:	8b 45 08             	mov    0x8(%ebp),%eax
  801786:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80178b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801790:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801795:	5d                   	pop    %ebp
  801796:	c3                   	ret    

00801797 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80179d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8017a2:	89 c2                	mov    %eax,%edx
  8017a4:	c1 ea 16             	shr    $0x16,%edx
  8017a7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8017ae:	f6 c2 01             	test   $0x1,%dl
  8017b1:	74 11                	je     8017c4 <fd_alloc+0x2d>
  8017b3:	89 c2                	mov    %eax,%edx
  8017b5:	c1 ea 0c             	shr    $0xc,%edx
  8017b8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017bf:	f6 c2 01             	test   $0x1,%dl
  8017c2:	75 09                	jne    8017cd <fd_alloc+0x36>
			*fd_store = fd;
  8017c4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8017c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8017cb:	eb 17                	jmp    8017e4 <fd_alloc+0x4d>
  8017cd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8017d2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8017d7:	75 c9                	jne    8017a2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8017d9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8017df:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8017e4:	5d                   	pop    %ebp
  8017e5:	c3                   	ret    

008017e6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8017e6:	55                   	push   %ebp
  8017e7:	89 e5                	mov    %esp,%ebp
  8017e9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8017ec:	83 f8 1f             	cmp    $0x1f,%eax
  8017ef:	77 36                	ja     801827 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8017f1:	c1 e0 0c             	shl    $0xc,%eax
  8017f4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8017f9:	89 c2                	mov    %eax,%edx
  8017fb:	c1 ea 16             	shr    $0x16,%edx
  8017fe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801805:	f6 c2 01             	test   $0x1,%dl
  801808:	74 24                	je     80182e <fd_lookup+0x48>
  80180a:	89 c2                	mov    %eax,%edx
  80180c:	c1 ea 0c             	shr    $0xc,%edx
  80180f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801816:	f6 c2 01             	test   $0x1,%dl
  801819:	74 1a                	je     801835 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80181b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80181e:	89 02                	mov    %eax,(%edx)
	return 0;
  801820:	b8 00 00 00 00       	mov    $0x0,%eax
  801825:	eb 13                	jmp    80183a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801827:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80182c:	eb 0c                	jmp    80183a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80182e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801833:	eb 05                	jmp    80183a <fd_lookup+0x54>
  801835:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80183a:	5d                   	pop    %ebp
  80183b:	c3                   	ret    

0080183c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	83 ec 18             	sub    $0x18,%esp
  801842:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801845:	ba 04 30 80 00       	mov    $0x803004,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80184a:	eb 13                	jmp    80185f <dev_lookup+0x23>
  80184c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80184f:	39 08                	cmp    %ecx,(%eax)
  801851:	75 0c                	jne    80185f <dev_lookup+0x23>
			*dev = devtab[i];
  801853:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801856:	89 01                	mov    %eax,(%ecx)
			return 0;
  801858:	b8 00 00 00 00       	mov    $0x0,%eax
  80185d:	eb 30                	jmp    80188f <dev_lookup+0x53>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80185f:	8b 02                	mov    (%edx),%eax
  801861:	85 c0                	test   %eax,%eax
  801863:	75 e7                	jne    80184c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801865:	a1 04 50 80 00       	mov    0x805004,%eax
  80186a:	8b 40 48             	mov    0x48(%eax),%eax
  80186d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801871:	89 44 24 04          	mov    %eax,0x4(%esp)
  801875:	c7 04 24 84 2f 80 00 	movl   $0x802f84,(%esp)
  80187c:	e8 57 f0 ff ff       	call   8008d8 <cprintf>
	*dev = 0;
  801881:	8b 45 0c             	mov    0xc(%ebp),%eax
  801884:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80188a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80188f:	c9                   	leave  
  801890:	c3                   	ret    

00801891 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801891:	55                   	push   %ebp
  801892:	89 e5                	mov    %esp,%ebp
  801894:	56                   	push   %esi
  801895:	53                   	push   %ebx
  801896:	83 ec 20             	sub    $0x20,%esp
  801899:	8b 75 08             	mov    0x8(%ebp),%esi
  80189c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80189f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a2:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8018a6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8018ac:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8018af:	89 04 24             	mov    %eax,(%esp)
  8018b2:	e8 2f ff ff ff       	call   8017e6 <fd_lookup>
  8018b7:	85 c0                	test   %eax,%eax
  8018b9:	78 05                	js     8018c0 <fd_close+0x2f>
	    || fd != fd2)
  8018bb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8018be:	74 0c                	je     8018cc <fd_close+0x3b>
		return (must_exist ? r : 0);
  8018c0:	84 db                	test   %bl,%bl
  8018c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c7:	0f 44 c2             	cmove  %edx,%eax
  8018ca:	eb 3f                	jmp    80190b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8018cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d3:	8b 06                	mov    (%esi),%eax
  8018d5:	89 04 24             	mov    %eax,(%esp)
  8018d8:	e8 5f ff ff ff       	call   80183c <dev_lookup>
  8018dd:	89 c3                	mov    %eax,%ebx
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	78 16                	js     8018f9 <fd_close+0x68>
		if (dev->dev_close)
  8018e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8018e9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8018ee:	85 c0                	test   %eax,%eax
  8018f0:	74 07                	je     8018f9 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  8018f2:	89 34 24             	mov    %esi,(%esp)
  8018f5:	ff d0                	call   *%eax
  8018f7:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8018f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801904:	e8 11 fb ff ff       	call   80141a <sys_page_unmap>
	return r;
  801909:	89 d8                	mov    %ebx,%eax
}
  80190b:	83 c4 20             	add    $0x20,%esp
  80190e:	5b                   	pop    %ebx
  80190f:	5e                   	pop    %esi
  801910:	5d                   	pop    %ebp
  801911:	c3                   	ret    

00801912 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801912:	55                   	push   %ebp
  801913:	89 e5                	mov    %esp,%ebp
  801915:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801918:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80191b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191f:	8b 45 08             	mov    0x8(%ebp),%eax
  801922:	89 04 24             	mov    %eax,(%esp)
  801925:	e8 bc fe ff ff       	call   8017e6 <fd_lookup>
  80192a:	89 c2                	mov    %eax,%edx
  80192c:	85 d2                	test   %edx,%edx
  80192e:	78 13                	js     801943 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  801930:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801937:	00 
  801938:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193b:	89 04 24             	mov    %eax,(%esp)
  80193e:	e8 4e ff ff ff       	call   801891 <fd_close>
}
  801943:	c9                   	leave  
  801944:	c3                   	ret    

00801945 <close_all>:

void
close_all(void)
{
  801945:	55                   	push   %ebp
  801946:	89 e5                	mov    %esp,%ebp
  801948:	53                   	push   %ebx
  801949:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80194c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801951:	89 1c 24             	mov    %ebx,(%esp)
  801954:	e8 b9 ff ff ff       	call   801912 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801959:	83 c3 01             	add    $0x1,%ebx
  80195c:	83 fb 20             	cmp    $0x20,%ebx
  80195f:	75 f0                	jne    801951 <close_all+0xc>
		close(i);
}
  801961:	83 c4 14             	add    $0x14,%esp
  801964:	5b                   	pop    %ebx
  801965:	5d                   	pop    %ebp
  801966:	c3                   	ret    

00801967 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	57                   	push   %edi
  80196b:	56                   	push   %esi
  80196c:	53                   	push   %ebx
  80196d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801970:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801973:	89 44 24 04          	mov    %eax,0x4(%esp)
  801977:	8b 45 08             	mov    0x8(%ebp),%eax
  80197a:	89 04 24             	mov    %eax,(%esp)
  80197d:	e8 64 fe ff ff       	call   8017e6 <fd_lookup>
  801982:	89 c2                	mov    %eax,%edx
  801984:	85 d2                	test   %edx,%edx
  801986:	0f 88 e1 00 00 00    	js     801a6d <dup+0x106>
		return r;
	close(newfdnum);
  80198c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80198f:	89 04 24             	mov    %eax,(%esp)
  801992:	e8 7b ff ff ff       	call   801912 <close>

	newfd = INDEX2FD(newfdnum);
  801997:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80199a:	c1 e3 0c             	shl    $0xc,%ebx
  80199d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8019a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019a6:	89 04 24             	mov    %eax,(%esp)
  8019a9:	e8 d2 fd ff ff       	call   801780 <fd2data>
  8019ae:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  8019b0:	89 1c 24             	mov    %ebx,(%esp)
  8019b3:	e8 c8 fd ff ff       	call   801780 <fd2data>
  8019b8:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8019ba:	89 f0                	mov    %esi,%eax
  8019bc:	c1 e8 16             	shr    $0x16,%eax
  8019bf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019c6:	a8 01                	test   $0x1,%al
  8019c8:	74 43                	je     801a0d <dup+0xa6>
  8019ca:	89 f0                	mov    %esi,%eax
  8019cc:	c1 e8 0c             	shr    $0xc,%eax
  8019cf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019d6:	f6 c2 01             	test   $0x1,%dl
  8019d9:	74 32                	je     801a0d <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8019db:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8019e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8019eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8019ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019f6:	00 
  8019f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a02:	e8 c0 f9 ff ff       	call   8013c7 <sys_page_map>
  801a07:	89 c6                	mov    %eax,%esi
  801a09:	85 c0                	test   %eax,%eax
  801a0b:	78 3e                	js     801a4b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801a0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a10:	89 c2                	mov    %eax,%edx
  801a12:	c1 ea 0c             	shr    $0xc,%edx
  801a15:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a1c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801a22:	89 54 24 10          	mov    %edx,0x10(%esp)
  801a26:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801a2a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a31:	00 
  801a32:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a36:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a3d:	e8 85 f9 ff ff       	call   8013c7 <sys_page_map>
  801a42:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  801a44:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801a47:	85 f6                	test   %esi,%esi
  801a49:	79 22                	jns    801a6d <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801a4b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a4f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a56:	e8 bf f9 ff ff       	call   80141a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801a5b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a66:	e8 af f9 ff ff       	call   80141a <sys_page_unmap>
	return r;
  801a6b:	89 f0                	mov    %esi,%eax
}
  801a6d:	83 c4 3c             	add    $0x3c,%esp
  801a70:	5b                   	pop    %ebx
  801a71:	5e                   	pop    %esi
  801a72:	5f                   	pop    %edi
  801a73:	5d                   	pop    %ebp
  801a74:	c3                   	ret    

00801a75 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	53                   	push   %ebx
  801a79:	83 ec 24             	sub    $0x24,%esp
  801a7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a7f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a86:	89 1c 24             	mov    %ebx,(%esp)
  801a89:	e8 58 fd ff ff       	call   8017e6 <fd_lookup>
  801a8e:	89 c2                	mov    %eax,%edx
  801a90:	85 d2                	test   %edx,%edx
  801a92:	78 6d                	js     801b01 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a97:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a9e:	8b 00                	mov    (%eax),%eax
  801aa0:	89 04 24             	mov    %eax,(%esp)
  801aa3:	e8 94 fd ff ff       	call   80183c <dev_lookup>
  801aa8:	85 c0                	test   %eax,%eax
  801aaa:	78 55                	js     801b01 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801aac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aaf:	8b 50 08             	mov    0x8(%eax),%edx
  801ab2:	83 e2 03             	and    $0x3,%edx
  801ab5:	83 fa 01             	cmp    $0x1,%edx
  801ab8:	75 23                	jne    801add <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801aba:	a1 04 50 80 00       	mov    0x805004,%eax
  801abf:	8b 40 48             	mov    0x48(%eax),%eax
  801ac2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ac6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aca:	c7 04 24 c8 2f 80 00 	movl   $0x802fc8,(%esp)
  801ad1:	e8 02 ee ff ff       	call   8008d8 <cprintf>
		return -E_INVAL;
  801ad6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801adb:	eb 24                	jmp    801b01 <read+0x8c>
	}
	if (!dev->dev_read)
  801add:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ae0:	8b 52 08             	mov    0x8(%edx),%edx
  801ae3:	85 d2                	test   %edx,%edx
  801ae5:	74 15                	je     801afc <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801ae7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801aea:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801aee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801af1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801af5:	89 04 24             	mov    %eax,(%esp)
  801af8:	ff d2                	call   *%edx
  801afa:	eb 05                	jmp    801b01 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801afc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801b01:	83 c4 24             	add    $0x24,%esp
  801b04:	5b                   	pop    %ebx
  801b05:	5d                   	pop    %ebp
  801b06:	c3                   	ret    

00801b07 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	57                   	push   %edi
  801b0b:	56                   	push   %esi
  801b0c:	53                   	push   %ebx
  801b0d:	83 ec 1c             	sub    $0x1c,%esp
  801b10:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b13:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b16:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b1b:	eb 23                	jmp    801b40 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801b1d:	89 f0                	mov    %esi,%eax
  801b1f:	29 d8                	sub    %ebx,%eax
  801b21:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b25:	89 d8                	mov    %ebx,%eax
  801b27:	03 45 0c             	add    0xc(%ebp),%eax
  801b2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b2e:	89 3c 24             	mov    %edi,(%esp)
  801b31:	e8 3f ff ff ff       	call   801a75 <read>
		if (m < 0)
  801b36:	85 c0                	test   %eax,%eax
  801b38:	78 10                	js     801b4a <readn+0x43>
			return m;
		if (m == 0)
  801b3a:	85 c0                	test   %eax,%eax
  801b3c:	74 0a                	je     801b48 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b3e:	01 c3                	add    %eax,%ebx
  801b40:	39 f3                	cmp    %esi,%ebx
  801b42:	72 d9                	jb     801b1d <readn+0x16>
  801b44:	89 d8                	mov    %ebx,%eax
  801b46:	eb 02                	jmp    801b4a <readn+0x43>
  801b48:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801b4a:	83 c4 1c             	add    $0x1c,%esp
  801b4d:	5b                   	pop    %ebx
  801b4e:	5e                   	pop    %esi
  801b4f:	5f                   	pop    %edi
  801b50:	5d                   	pop    %ebp
  801b51:	c3                   	ret    

00801b52 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	53                   	push   %ebx
  801b56:	83 ec 24             	sub    $0x24,%esp
  801b59:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b5c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b63:	89 1c 24             	mov    %ebx,(%esp)
  801b66:	e8 7b fc ff ff       	call   8017e6 <fd_lookup>
  801b6b:	89 c2                	mov    %eax,%edx
  801b6d:	85 d2                	test   %edx,%edx
  801b6f:	78 68                	js     801bd9 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b74:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b7b:	8b 00                	mov    (%eax),%eax
  801b7d:	89 04 24             	mov    %eax,(%esp)
  801b80:	e8 b7 fc ff ff       	call   80183c <dev_lookup>
  801b85:	85 c0                	test   %eax,%eax
  801b87:	78 50                	js     801bd9 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b8c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b90:	75 23                	jne    801bb5 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801b92:	a1 04 50 80 00       	mov    0x805004,%eax
  801b97:	8b 40 48             	mov    0x48(%eax),%eax
  801b9a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba2:	c7 04 24 e4 2f 80 00 	movl   $0x802fe4,(%esp)
  801ba9:	e8 2a ed ff ff       	call   8008d8 <cprintf>
		return -E_INVAL;
  801bae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801bb3:	eb 24                	jmp    801bd9 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801bb5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bb8:	8b 52 0c             	mov    0xc(%edx),%edx
  801bbb:	85 d2                	test   %edx,%edx
  801bbd:	74 15                	je     801bd4 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801bbf:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801bc2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801bc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801bcd:	89 04 24             	mov    %eax,(%esp)
  801bd0:	ff d2                	call   *%edx
  801bd2:	eb 05                	jmp    801bd9 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801bd4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801bd9:	83 c4 24             	add    $0x24,%esp
  801bdc:	5b                   	pop    %ebx
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    

00801bdf <seek>:

int
seek(int fdnum, off_t offset)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801be5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801be8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bec:	8b 45 08             	mov    0x8(%ebp),%eax
  801bef:	89 04 24             	mov    %eax,(%esp)
  801bf2:	e8 ef fb ff ff       	call   8017e6 <fd_lookup>
  801bf7:	85 c0                	test   %eax,%eax
  801bf9:	78 0e                	js     801c09 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801bfb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801bfe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c01:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801c04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c09:	c9                   	leave  
  801c0a:	c3                   	ret    

00801c0b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	53                   	push   %ebx
  801c0f:	83 ec 24             	sub    $0x24,%esp
  801c12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c15:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c18:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c1c:	89 1c 24             	mov    %ebx,(%esp)
  801c1f:	e8 c2 fb ff ff       	call   8017e6 <fd_lookup>
  801c24:	89 c2                	mov    %eax,%edx
  801c26:	85 d2                	test   %edx,%edx
  801c28:	78 61                	js     801c8b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c34:	8b 00                	mov    (%eax),%eax
  801c36:	89 04 24             	mov    %eax,(%esp)
  801c39:	e8 fe fb ff ff       	call   80183c <dev_lookup>
  801c3e:	85 c0                	test   %eax,%eax
  801c40:	78 49                	js     801c8b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801c42:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c45:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801c49:	75 23                	jne    801c6e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801c4b:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801c50:	8b 40 48             	mov    0x48(%eax),%eax
  801c53:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c57:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c5b:	c7 04 24 a4 2f 80 00 	movl   $0x802fa4,(%esp)
  801c62:	e8 71 ec ff ff       	call   8008d8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801c67:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c6c:	eb 1d                	jmp    801c8b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  801c6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c71:	8b 52 18             	mov    0x18(%edx),%edx
  801c74:	85 d2                	test   %edx,%edx
  801c76:	74 0e                	je     801c86 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c7b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801c7f:	89 04 24             	mov    %eax,(%esp)
  801c82:	ff d2                	call   *%edx
  801c84:	eb 05                	jmp    801c8b <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801c86:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801c8b:	83 c4 24             	add    $0x24,%esp
  801c8e:	5b                   	pop    %ebx
  801c8f:	5d                   	pop    %ebp
  801c90:	c3                   	ret    

00801c91 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	53                   	push   %ebx
  801c95:	83 ec 24             	sub    $0x24,%esp
  801c98:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c9b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca5:	89 04 24             	mov    %eax,(%esp)
  801ca8:	e8 39 fb ff ff       	call   8017e6 <fd_lookup>
  801cad:	89 c2                	mov    %eax,%edx
  801caf:	85 d2                	test   %edx,%edx
  801cb1:	78 52                	js     801d05 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801cb3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cbd:	8b 00                	mov    (%eax),%eax
  801cbf:	89 04 24             	mov    %eax,(%esp)
  801cc2:	e8 75 fb ff ff       	call   80183c <dev_lookup>
  801cc7:	85 c0                	test   %eax,%eax
  801cc9:	78 3a                	js     801d05 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  801ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cce:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801cd2:	74 2c                	je     801d00 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801cd4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801cd7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801cde:	00 00 00 
	stat->st_isdir = 0;
  801ce1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ce8:	00 00 00 
	stat->st_dev = dev;
  801ceb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801cf1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cf5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cf8:	89 14 24             	mov    %edx,(%esp)
  801cfb:	ff 50 14             	call   *0x14(%eax)
  801cfe:	eb 05                	jmp    801d05 <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801d00:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801d05:	83 c4 24             	add    $0x24,%esp
  801d08:	5b                   	pop    %ebx
  801d09:	5d                   	pop    %ebp
  801d0a:	c3                   	ret    

00801d0b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801d0b:	55                   	push   %ebp
  801d0c:	89 e5                	mov    %esp,%ebp
  801d0e:	56                   	push   %esi
  801d0f:	53                   	push   %ebx
  801d10:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801d13:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d1a:	00 
  801d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1e:	89 04 24             	mov    %eax,(%esp)
  801d21:	e8 fb 01 00 00       	call   801f21 <open>
  801d26:	89 c3                	mov    %eax,%ebx
  801d28:	85 db                	test   %ebx,%ebx
  801d2a:	78 1b                	js     801d47 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801d2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d33:	89 1c 24             	mov    %ebx,(%esp)
  801d36:	e8 56 ff ff ff       	call   801c91 <fstat>
  801d3b:	89 c6                	mov    %eax,%esi
	close(fd);
  801d3d:	89 1c 24             	mov    %ebx,(%esp)
  801d40:	e8 cd fb ff ff       	call   801912 <close>
	return r;
  801d45:	89 f0                	mov    %esi,%eax
}
  801d47:	83 c4 10             	add    $0x10,%esp
  801d4a:	5b                   	pop    %ebx
  801d4b:	5e                   	pop    %esi
  801d4c:	5d                   	pop    %ebp
  801d4d:	c3                   	ret    

00801d4e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	56                   	push   %esi
  801d52:	53                   	push   %ebx
  801d53:	83 ec 10             	sub    $0x10,%esp
  801d56:	89 c6                	mov    %eax,%esi
  801d58:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801d5a:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801d61:	75 11                	jne    801d74 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801d63:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801d6a:	e8 be f9 ff ff       	call   80172d <ipc_find_env>
  801d6f:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d74:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d7b:	00 
  801d7c:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801d83:	00 
  801d84:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d88:	a1 00 50 80 00       	mov    0x805000,%eax
  801d8d:	89 04 24             	mov    %eax,(%esp)
  801d90:	e8 e9 f8 ff ff       	call   80167e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801d95:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d9c:	00 
  801d9d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801da1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801da8:	e8 33 f8 ff ff       	call   8015e0 <ipc_recv>
}
  801dad:	83 c4 10             	add    $0x10,%esp
  801db0:	5b                   	pop    %ebx
  801db1:	5e                   	pop    %esi
  801db2:	5d                   	pop    %ebp
  801db3:	c3                   	ret    

00801db4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801dba:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbd:	8b 40 0c             	mov    0xc(%eax),%eax
  801dc0:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801dc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc8:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801dcd:	ba 00 00 00 00       	mov    $0x0,%edx
  801dd2:	b8 02 00 00 00       	mov    $0x2,%eax
  801dd7:	e8 72 ff ff ff       	call   801d4e <fsipc>
}
  801ddc:	c9                   	leave  
  801ddd:	c3                   	ret    

00801dde <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801dde:	55                   	push   %ebp
  801ddf:	89 e5                	mov    %esp,%ebp
  801de1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801de4:	8b 45 08             	mov    0x8(%ebp),%eax
  801de7:	8b 40 0c             	mov    0xc(%eax),%eax
  801dea:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801def:	ba 00 00 00 00       	mov    $0x0,%edx
  801df4:	b8 06 00 00 00       	mov    $0x6,%eax
  801df9:	e8 50 ff ff ff       	call   801d4e <fsipc>
}
  801dfe:	c9                   	leave  
  801dff:	c3                   	ret    

00801e00 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	53                   	push   %ebx
  801e04:	83 ec 14             	sub    $0x14,%esp
  801e07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801e0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0d:	8b 40 0c             	mov    0xc(%eax),%eax
  801e10:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801e15:	ba 00 00 00 00       	mov    $0x0,%edx
  801e1a:	b8 05 00 00 00       	mov    $0x5,%eax
  801e1f:	e8 2a ff ff ff       	call   801d4e <fsipc>
  801e24:	89 c2                	mov    %eax,%edx
  801e26:	85 d2                	test   %edx,%edx
  801e28:	78 2b                	js     801e55 <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801e2a:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e31:	00 
  801e32:	89 1c 24             	mov    %ebx,(%esp)
  801e35:	e8 1d f1 ff ff       	call   800f57 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801e3a:	a1 80 60 80 00       	mov    0x806080,%eax
  801e3f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801e45:	a1 84 60 80 00       	mov    0x806084,%eax
  801e4a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801e50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e55:	83 c4 14             	add    $0x14,%esp
  801e58:	5b                   	pop    %ebx
  801e59:	5d                   	pop    %ebp
  801e5a:	c3                   	ret    

00801e5b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801e5b:	55                   	push   %ebp
  801e5c:	89 e5                	mov    %esp,%ebp
  801e5e:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801e61:	c7 44 24 08 14 30 80 	movl   $0x803014,0x8(%esp)
  801e68:	00 
  801e69:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801e70:	00 
  801e71:	c7 04 24 32 30 80 00 	movl   $0x803032,(%esp)
  801e78:	e8 62 e9 ff ff       	call   8007df <_panic>

00801e7d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801e7d:	55                   	push   %ebp
  801e7e:	89 e5                	mov    %esp,%ebp
  801e80:	56                   	push   %esi
  801e81:	53                   	push   %ebx
  801e82:	83 ec 10             	sub    $0x10,%esp
  801e85:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801e88:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8b:	8b 40 0c             	mov    0xc(%eax),%eax
  801e8e:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801e93:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801e99:	ba 00 00 00 00       	mov    $0x0,%edx
  801e9e:	b8 03 00 00 00       	mov    $0x3,%eax
  801ea3:	e8 a6 fe ff ff       	call   801d4e <fsipc>
  801ea8:	89 c3                	mov    %eax,%ebx
  801eaa:	85 c0                	test   %eax,%eax
  801eac:	78 6a                	js     801f18 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801eae:	39 c6                	cmp    %eax,%esi
  801eb0:	73 24                	jae    801ed6 <devfile_read+0x59>
  801eb2:	c7 44 24 0c 3d 30 80 	movl   $0x80303d,0xc(%esp)
  801eb9:	00 
  801eba:	c7 44 24 08 44 30 80 	movl   $0x803044,0x8(%esp)
  801ec1:	00 
  801ec2:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801ec9:	00 
  801eca:	c7 04 24 32 30 80 00 	movl   $0x803032,(%esp)
  801ed1:	e8 09 e9 ff ff       	call   8007df <_panic>
	assert(r <= PGSIZE);
  801ed6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801edb:	7e 24                	jle    801f01 <devfile_read+0x84>
  801edd:	c7 44 24 0c 59 30 80 	movl   $0x803059,0xc(%esp)
  801ee4:	00 
  801ee5:	c7 44 24 08 44 30 80 	movl   $0x803044,0x8(%esp)
  801eec:	00 
  801eed:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801ef4:	00 
  801ef5:	c7 04 24 32 30 80 00 	movl   $0x803032,(%esp)
  801efc:	e8 de e8 ff ff       	call   8007df <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801f01:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f05:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f0c:	00 
  801f0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f10:	89 04 24             	mov    %eax,(%esp)
  801f13:	e8 dc f1 ff ff       	call   8010f4 <memmove>
	return r;
}
  801f18:	89 d8                	mov    %ebx,%eax
  801f1a:	83 c4 10             	add    $0x10,%esp
  801f1d:	5b                   	pop    %ebx
  801f1e:	5e                   	pop    %esi
  801f1f:	5d                   	pop    %ebp
  801f20:	c3                   	ret    

00801f21 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801f21:	55                   	push   %ebp
  801f22:	89 e5                	mov    %esp,%ebp
  801f24:	53                   	push   %ebx
  801f25:	83 ec 24             	sub    $0x24,%esp
  801f28:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801f2b:	89 1c 24             	mov    %ebx,(%esp)
  801f2e:	e8 ed ef ff ff       	call   800f20 <strlen>
  801f33:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801f38:	7f 60                	jg     801f9a <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801f3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f3d:	89 04 24             	mov    %eax,(%esp)
  801f40:	e8 52 f8 ff ff       	call   801797 <fd_alloc>
  801f45:	89 c2                	mov    %eax,%edx
  801f47:	85 d2                	test   %edx,%edx
  801f49:	78 54                	js     801f9f <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801f4b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f4f:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801f56:	e8 fc ef ff ff       	call   800f57 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801f5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f5e:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801f63:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f66:	b8 01 00 00 00       	mov    $0x1,%eax
  801f6b:	e8 de fd ff ff       	call   801d4e <fsipc>
  801f70:	89 c3                	mov    %eax,%ebx
  801f72:	85 c0                	test   %eax,%eax
  801f74:	79 17                	jns    801f8d <open+0x6c>
		fd_close(fd, 0);
  801f76:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f7d:	00 
  801f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f81:	89 04 24             	mov    %eax,(%esp)
  801f84:	e8 08 f9 ff ff       	call   801891 <fd_close>
		return r;
  801f89:	89 d8                	mov    %ebx,%eax
  801f8b:	eb 12                	jmp    801f9f <open+0x7e>
	}

	return fd2num(fd);
  801f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f90:	89 04 24             	mov    %eax,(%esp)
  801f93:	e8 d8 f7 ff ff       	call   801770 <fd2num>
  801f98:	eb 05                	jmp    801f9f <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801f9a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801f9f:	83 c4 24             	add    $0x24,%esp
  801fa2:	5b                   	pop    %ebx
  801fa3:	5d                   	pop    %ebp
  801fa4:	c3                   	ret    

00801fa5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801fa5:	55                   	push   %ebp
  801fa6:	89 e5                	mov    %esp,%ebp
  801fa8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801fab:	ba 00 00 00 00       	mov    $0x0,%edx
  801fb0:	b8 08 00 00 00       	mov    $0x8,%eax
  801fb5:	e8 94 fd ff ff       	call   801d4e <fsipc>
}
  801fba:	c9                   	leave  
  801fbb:	c3                   	ret    

00801fbc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801fbc:	55                   	push   %ebp
  801fbd:	89 e5                	mov    %esp,%ebp
  801fbf:	56                   	push   %esi
  801fc0:	53                   	push   %ebx
  801fc1:	83 ec 10             	sub    $0x10,%esp
  801fc4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801fc7:	8b 45 08             	mov    0x8(%ebp),%eax
  801fca:	89 04 24             	mov    %eax,(%esp)
  801fcd:	e8 ae f7 ff ff       	call   801780 <fd2data>
  801fd2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801fd4:	c7 44 24 04 65 30 80 	movl   $0x803065,0x4(%esp)
  801fdb:	00 
  801fdc:	89 1c 24             	mov    %ebx,(%esp)
  801fdf:	e8 73 ef ff ff       	call   800f57 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801fe4:	8b 46 04             	mov    0x4(%esi),%eax
  801fe7:	2b 06                	sub    (%esi),%eax
  801fe9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801fef:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ff6:	00 00 00 
	stat->st_dev = &devpipe;
  801ff9:	c7 83 88 00 00 00 24 	movl   $0x804024,0x88(%ebx)
  802000:	40 80 00 
	return 0;
}
  802003:	b8 00 00 00 00       	mov    $0x0,%eax
  802008:	83 c4 10             	add    $0x10,%esp
  80200b:	5b                   	pop    %ebx
  80200c:	5e                   	pop    %esi
  80200d:	5d                   	pop    %ebp
  80200e:	c3                   	ret    

0080200f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80200f:	55                   	push   %ebp
  802010:	89 e5                	mov    %esp,%ebp
  802012:	53                   	push   %ebx
  802013:	83 ec 14             	sub    $0x14,%esp
  802016:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802019:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80201d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802024:	e8 f1 f3 ff ff       	call   80141a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802029:	89 1c 24             	mov    %ebx,(%esp)
  80202c:	e8 4f f7 ff ff       	call   801780 <fd2data>
  802031:	89 44 24 04          	mov    %eax,0x4(%esp)
  802035:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80203c:	e8 d9 f3 ff ff       	call   80141a <sys_page_unmap>
}
  802041:	83 c4 14             	add    $0x14,%esp
  802044:	5b                   	pop    %ebx
  802045:	5d                   	pop    %ebp
  802046:	c3                   	ret    

00802047 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802047:	55                   	push   %ebp
  802048:	89 e5                	mov    %esp,%ebp
  80204a:	57                   	push   %edi
  80204b:	56                   	push   %esi
  80204c:	53                   	push   %ebx
  80204d:	83 ec 2c             	sub    $0x2c,%esp
  802050:	89 c6                	mov    %eax,%esi
  802052:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802055:	a1 04 50 80 00       	mov    0x805004,%eax
  80205a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80205d:	89 34 24             	mov    %esi,(%esp)
  802060:	e8 81 04 00 00       	call   8024e6 <pageref>
  802065:	89 c7                	mov    %eax,%edi
  802067:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80206a:	89 04 24             	mov    %eax,(%esp)
  80206d:	e8 74 04 00 00       	call   8024e6 <pageref>
  802072:	39 c7                	cmp    %eax,%edi
  802074:	0f 94 c2             	sete   %dl
  802077:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80207a:	8b 0d 04 50 80 00    	mov    0x805004,%ecx
  802080:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  802083:	39 fb                	cmp    %edi,%ebx
  802085:	74 21                	je     8020a8 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  802087:	84 d2                	test   %dl,%dl
  802089:	74 ca                	je     802055 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80208b:	8b 51 58             	mov    0x58(%ecx),%edx
  80208e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802092:	89 54 24 08          	mov    %edx,0x8(%esp)
  802096:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80209a:	c7 04 24 6c 30 80 00 	movl   $0x80306c,(%esp)
  8020a1:	e8 32 e8 ff ff       	call   8008d8 <cprintf>
  8020a6:	eb ad                	jmp    802055 <_pipeisclosed+0xe>
	}
}
  8020a8:	83 c4 2c             	add    $0x2c,%esp
  8020ab:	5b                   	pop    %ebx
  8020ac:	5e                   	pop    %esi
  8020ad:	5f                   	pop    %edi
  8020ae:	5d                   	pop    %ebp
  8020af:	c3                   	ret    

008020b0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020b0:	55                   	push   %ebp
  8020b1:	89 e5                	mov    %esp,%ebp
  8020b3:	57                   	push   %edi
  8020b4:	56                   	push   %esi
  8020b5:	53                   	push   %ebx
  8020b6:	83 ec 1c             	sub    $0x1c,%esp
  8020b9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8020bc:	89 34 24             	mov    %esi,(%esp)
  8020bf:	e8 bc f6 ff ff       	call   801780 <fd2data>
  8020c4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020c6:	bf 00 00 00 00       	mov    $0x0,%edi
  8020cb:	eb 45                	jmp    802112 <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8020cd:	89 da                	mov    %ebx,%edx
  8020cf:	89 f0                	mov    %esi,%eax
  8020d1:	e8 71 ff ff ff       	call   802047 <_pipeisclosed>
  8020d6:	85 c0                	test   %eax,%eax
  8020d8:	75 41                	jne    80211b <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8020da:	e8 75 f2 ff ff       	call   801354 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020df:	8b 43 04             	mov    0x4(%ebx),%eax
  8020e2:	8b 0b                	mov    (%ebx),%ecx
  8020e4:	8d 51 20             	lea    0x20(%ecx),%edx
  8020e7:	39 d0                	cmp    %edx,%eax
  8020e9:	73 e2                	jae    8020cd <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8020eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020ee:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8020f2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8020f5:	99                   	cltd   
  8020f6:	c1 ea 1b             	shr    $0x1b,%edx
  8020f9:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  8020fc:	83 e1 1f             	and    $0x1f,%ecx
  8020ff:	29 d1                	sub    %edx,%ecx
  802101:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  802105:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  802109:	83 c0 01             	add    $0x1,%eax
  80210c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80210f:	83 c7 01             	add    $0x1,%edi
  802112:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802115:	75 c8                	jne    8020df <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802117:	89 f8                	mov    %edi,%eax
  802119:	eb 05                	jmp    802120 <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80211b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802120:	83 c4 1c             	add    $0x1c,%esp
  802123:	5b                   	pop    %ebx
  802124:	5e                   	pop    %esi
  802125:	5f                   	pop    %edi
  802126:	5d                   	pop    %ebp
  802127:	c3                   	ret    

00802128 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802128:	55                   	push   %ebp
  802129:	89 e5                	mov    %esp,%ebp
  80212b:	57                   	push   %edi
  80212c:	56                   	push   %esi
  80212d:	53                   	push   %ebx
  80212e:	83 ec 1c             	sub    $0x1c,%esp
  802131:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802134:	89 3c 24             	mov    %edi,(%esp)
  802137:	e8 44 f6 ff ff       	call   801780 <fd2data>
  80213c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80213e:	be 00 00 00 00       	mov    $0x0,%esi
  802143:	eb 3d                	jmp    802182 <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802145:	85 f6                	test   %esi,%esi
  802147:	74 04                	je     80214d <devpipe_read+0x25>
				return i;
  802149:	89 f0                	mov    %esi,%eax
  80214b:	eb 43                	jmp    802190 <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80214d:	89 da                	mov    %ebx,%edx
  80214f:	89 f8                	mov    %edi,%eax
  802151:	e8 f1 fe ff ff       	call   802047 <_pipeisclosed>
  802156:	85 c0                	test   %eax,%eax
  802158:	75 31                	jne    80218b <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80215a:	e8 f5 f1 ff ff       	call   801354 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80215f:	8b 03                	mov    (%ebx),%eax
  802161:	3b 43 04             	cmp    0x4(%ebx),%eax
  802164:	74 df                	je     802145 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802166:	99                   	cltd   
  802167:	c1 ea 1b             	shr    $0x1b,%edx
  80216a:	01 d0                	add    %edx,%eax
  80216c:	83 e0 1f             	and    $0x1f,%eax
  80216f:	29 d0                	sub    %edx,%eax
  802171:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802179:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80217c:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80217f:	83 c6 01             	add    $0x1,%esi
  802182:	3b 75 10             	cmp    0x10(%ebp),%esi
  802185:	75 d8                	jne    80215f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802187:	89 f0                	mov    %esi,%eax
  802189:	eb 05                	jmp    802190 <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80218b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802190:	83 c4 1c             	add    $0x1c,%esp
  802193:	5b                   	pop    %ebx
  802194:	5e                   	pop    %esi
  802195:	5f                   	pop    %edi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    

00802198 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802198:	55                   	push   %ebp
  802199:	89 e5                	mov    %esp,%ebp
  80219b:	56                   	push   %esi
  80219c:	53                   	push   %ebx
  80219d:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8021a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021a3:	89 04 24             	mov    %eax,(%esp)
  8021a6:	e8 ec f5 ff ff       	call   801797 <fd_alloc>
  8021ab:	89 c2                	mov    %eax,%edx
  8021ad:	85 d2                	test   %edx,%edx
  8021af:	0f 88 4d 01 00 00    	js     802302 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021b5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021bc:	00 
  8021bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021cb:	e8 a3 f1 ff ff       	call   801373 <sys_page_alloc>
  8021d0:	89 c2                	mov    %eax,%edx
  8021d2:	85 d2                	test   %edx,%edx
  8021d4:	0f 88 28 01 00 00    	js     802302 <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8021da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021dd:	89 04 24             	mov    %eax,(%esp)
  8021e0:	e8 b2 f5 ff ff       	call   801797 <fd_alloc>
  8021e5:	89 c3                	mov    %eax,%ebx
  8021e7:	85 c0                	test   %eax,%eax
  8021e9:	0f 88 fe 00 00 00    	js     8022ed <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021ef:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8021f6:	00 
  8021f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802205:	e8 69 f1 ff ff       	call   801373 <sys_page_alloc>
  80220a:	89 c3                	mov    %eax,%ebx
  80220c:	85 c0                	test   %eax,%eax
  80220e:	0f 88 d9 00 00 00    	js     8022ed <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802214:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802217:	89 04 24             	mov    %eax,(%esp)
  80221a:	e8 61 f5 ff ff       	call   801780 <fd2data>
  80221f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802221:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802228:	00 
  802229:	89 44 24 04          	mov    %eax,0x4(%esp)
  80222d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802234:	e8 3a f1 ff ff       	call   801373 <sys_page_alloc>
  802239:	89 c3                	mov    %eax,%ebx
  80223b:	85 c0                	test   %eax,%eax
  80223d:	0f 88 97 00 00 00    	js     8022da <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802243:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802246:	89 04 24             	mov    %eax,(%esp)
  802249:	e8 32 f5 ff ff       	call   801780 <fd2data>
  80224e:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802255:	00 
  802256:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80225a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802261:	00 
  802262:	89 74 24 04          	mov    %esi,0x4(%esp)
  802266:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80226d:	e8 55 f1 ff ff       	call   8013c7 <sys_page_map>
  802272:	89 c3                	mov    %eax,%ebx
  802274:	85 c0                	test   %eax,%eax
  802276:	78 52                	js     8022ca <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802278:	8b 15 24 40 80 00    	mov    0x804024,%edx
  80227e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802281:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802283:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802286:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80228d:	8b 15 24 40 80 00    	mov    0x804024,%edx
  802293:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802296:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802298:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80229b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8022a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022a5:	89 04 24             	mov    %eax,(%esp)
  8022a8:	e8 c3 f4 ff ff       	call   801770 <fd2num>
  8022ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022b0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8022b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022b5:	89 04 24             	mov    %eax,(%esp)
  8022b8:	e8 b3 f4 ff ff       	call   801770 <fd2num>
  8022bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022c0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8022c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8022c8:	eb 38                	jmp    802302 <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  8022ca:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022d5:	e8 40 f1 ff ff       	call   80141a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8022da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022e8:	e8 2d f1 ff ff       	call   80141a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8022ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022fb:	e8 1a f1 ff ff       	call   80141a <sys_page_unmap>
  802300:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  802302:	83 c4 30             	add    $0x30,%esp
  802305:	5b                   	pop    %ebx
  802306:	5e                   	pop    %esi
  802307:	5d                   	pop    %ebp
  802308:	c3                   	ret    

00802309 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802309:	55                   	push   %ebp
  80230a:	89 e5                	mov    %esp,%ebp
  80230c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80230f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802312:	89 44 24 04          	mov    %eax,0x4(%esp)
  802316:	8b 45 08             	mov    0x8(%ebp),%eax
  802319:	89 04 24             	mov    %eax,(%esp)
  80231c:	e8 c5 f4 ff ff       	call   8017e6 <fd_lookup>
  802321:	89 c2                	mov    %eax,%edx
  802323:	85 d2                	test   %edx,%edx
  802325:	78 15                	js     80233c <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802327:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80232a:	89 04 24             	mov    %eax,(%esp)
  80232d:	e8 4e f4 ff ff       	call   801780 <fd2data>
	return _pipeisclosed(fd, p);
  802332:	89 c2                	mov    %eax,%edx
  802334:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802337:	e8 0b fd ff ff       	call   802047 <_pipeisclosed>
}
  80233c:	c9                   	leave  
  80233d:	c3                   	ret    
  80233e:	66 90                	xchg   %ax,%ax

00802340 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802340:	55                   	push   %ebp
  802341:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802343:	b8 00 00 00 00       	mov    $0x0,%eax
  802348:	5d                   	pop    %ebp
  802349:	c3                   	ret    

0080234a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80234a:	55                   	push   %ebp
  80234b:	89 e5                	mov    %esp,%ebp
  80234d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802350:	c7 44 24 04 84 30 80 	movl   $0x803084,0x4(%esp)
  802357:	00 
  802358:	8b 45 0c             	mov    0xc(%ebp),%eax
  80235b:	89 04 24             	mov    %eax,(%esp)
  80235e:	e8 f4 eb ff ff       	call   800f57 <strcpy>
	return 0;
}
  802363:	b8 00 00 00 00       	mov    $0x0,%eax
  802368:	c9                   	leave  
  802369:	c3                   	ret    

0080236a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80236a:	55                   	push   %ebp
  80236b:	89 e5                	mov    %esp,%ebp
  80236d:	57                   	push   %edi
  80236e:	56                   	push   %esi
  80236f:	53                   	push   %ebx
  802370:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802376:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80237b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802381:	eb 31                	jmp    8023b4 <devcons_write+0x4a>
		m = n - tot;
  802383:	8b 75 10             	mov    0x10(%ebp),%esi
  802386:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802388:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80238b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802390:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802393:	89 74 24 08          	mov    %esi,0x8(%esp)
  802397:	03 45 0c             	add    0xc(%ebp),%eax
  80239a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80239e:	89 3c 24             	mov    %edi,(%esp)
  8023a1:	e8 4e ed ff ff       	call   8010f4 <memmove>
		sys_cputs(buf, m);
  8023a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023aa:	89 3c 24             	mov    %edi,(%esp)
  8023ad:	e8 f4 ee ff ff       	call   8012a6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023b2:	01 f3                	add    %esi,%ebx
  8023b4:	89 d8                	mov    %ebx,%eax
  8023b6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8023b9:	72 c8                	jb     802383 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8023bb:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8023c1:	5b                   	pop    %ebx
  8023c2:	5e                   	pop    %esi
  8023c3:	5f                   	pop    %edi
  8023c4:	5d                   	pop    %ebp
  8023c5:	c3                   	ret    

008023c6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023c6:	55                   	push   %ebp
  8023c7:	89 e5                	mov    %esp,%ebp
  8023c9:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8023cc:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8023d1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023d5:	75 07                	jne    8023de <devcons_read+0x18>
  8023d7:	eb 2a                	jmp    802403 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8023d9:	e8 76 ef ff ff       	call   801354 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8023de:	66 90                	xchg   %ax,%ax
  8023e0:	e8 df ee ff ff       	call   8012c4 <sys_cgetc>
  8023e5:	85 c0                	test   %eax,%eax
  8023e7:	74 f0                	je     8023d9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8023e9:	85 c0                	test   %eax,%eax
  8023eb:	78 16                	js     802403 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8023ed:	83 f8 04             	cmp    $0x4,%eax
  8023f0:	74 0c                	je     8023fe <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  8023f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023f5:	88 02                	mov    %al,(%edx)
	return 1;
  8023f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8023fc:	eb 05                	jmp    802403 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8023fe:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802403:	c9                   	leave  
  802404:	c3                   	ret    

00802405 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802405:	55                   	push   %ebp
  802406:	89 e5                	mov    %esp,%ebp
  802408:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80240b:	8b 45 08             	mov    0x8(%ebp),%eax
  80240e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802411:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802418:	00 
  802419:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80241c:	89 04 24             	mov    %eax,(%esp)
  80241f:	e8 82 ee ff ff       	call   8012a6 <sys_cputs>
}
  802424:	c9                   	leave  
  802425:	c3                   	ret    

00802426 <getchar>:

int
getchar(void)
{
  802426:	55                   	push   %ebp
  802427:	89 e5                	mov    %esp,%ebp
  802429:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80242c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802433:	00 
  802434:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802437:	89 44 24 04          	mov    %eax,0x4(%esp)
  80243b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802442:	e8 2e f6 ff ff       	call   801a75 <read>
	if (r < 0)
  802447:	85 c0                	test   %eax,%eax
  802449:	78 0f                	js     80245a <getchar+0x34>
		return r;
	if (r < 1)
  80244b:	85 c0                	test   %eax,%eax
  80244d:	7e 06                	jle    802455 <getchar+0x2f>
		return -E_EOF;
	return c;
  80244f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802453:	eb 05                	jmp    80245a <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802455:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80245a:	c9                   	leave  
  80245b:	c3                   	ret    

0080245c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80245c:	55                   	push   %ebp
  80245d:	89 e5                	mov    %esp,%ebp
  80245f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802462:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802465:	89 44 24 04          	mov    %eax,0x4(%esp)
  802469:	8b 45 08             	mov    0x8(%ebp),%eax
  80246c:	89 04 24             	mov    %eax,(%esp)
  80246f:	e8 72 f3 ff ff       	call   8017e6 <fd_lookup>
  802474:	85 c0                	test   %eax,%eax
  802476:	78 11                	js     802489 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802478:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80247b:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802481:	39 10                	cmp    %edx,(%eax)
  802483:	0f 94 c0             	sete   %al
  802486:	0f b6 c0             	movzbl %al,%eax
}
  802489:	c9                   	leave  
  80248a:	c3                   	ret    

0080248b <opencons>:

int
opencons(void)
{
  80248b:	55                   	push   %ebp
  80248c:	89 e5                	mov    %esp,%ebp
  80248e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802491:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802494:	89 04 24             	mov    %eax,(%esp)
  802497:	e8 fb f2 ff ff       	call   801797 <fd_alloc>
		return r;
  80249c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80249e:	85 c0                	test   %eax,%eax
  8024a0:	78 40                	js     8024e2 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024a2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024a9:	00 
  8024aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024b8:	e8 b6 ee ff ff       	call   801373 <sys_page_alloc>
		return r;
  8024bd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024bf:	85 c0                	test   %eax,%eax
  8024c1:	78 1f                	js     8024e2 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8024c3:	8b 15 40 40 80 00    	mov    0x804040,%edx
  8024c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024cc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024d1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8024d8:	89 04 24             	mov    %eax,(%esp)
  8024db:	e8 90 f2 ff ff       	call   801770 <fd2num>
  8024e0:	89 c2                	mov    %eax,%edx
}
  8024e2:	89 d0                	mov    %edx,%eax
  8024e4:	c9                   	leave  
  8024e5:	c3                   	ret    

008024e6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024e6:	55                   	push   %ebp
  8024e7:	89 e5                	mov    %esp,%ebp
  8024e9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024ec:	89 d0                	mov    %edx,%eax
  8024ee:	c1 e8 16             	shr    $0x16,%eax
  8024f1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8024f8:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024fd:	f6 c1 01             	test   $0x1,%cl
  802500:	74 1d                	je     80251f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802502:	c1 ea 0c             	shr    $0xc,%edx
  802505:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80250c:	f6 c2 01             	test   $0x1,%dl
  80250f:	74 0e                	je     80251f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802511:	c1 ea 0c             	shr    $0xc,%edx
  802514:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80251b:	ef 
  80251c:	0f b7 c0             	movzwl %ax,%eax
}
  80251f:	5d                   	pop    %ebp
  802520:	c3                   	ret    
  802521:	66 90                	xchg   %ax,%ax
  802523:	66 90                	xchg   %ax,%ax
  802525:	66 90                	xchg   %ax,%ax
  802527:	66 90                	xchg   %ax,%ax
  802529:	66 90                	xchg   %ax,%ax
  80252b:	66 90                	xchg   %ax,%ax
  80252d:	66 90                	xchg   %ax,%ax
  80252f:	90                   	nop

00802530 <__udivdi3>:
  802530:	55                   	push   %ebp
  802531:	57                   	push   %edi
  802532:	56                   	push   %esi
  802533:	83 ec 0c             	sub    $0xc,%esp
  802536:	8b 44 24 28          	mov    0x28(%esp),%eax
  80253a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80253e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  802542:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  802546:	85 c0                	test   %eax,%eax
  802548:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80254c:	89 ea                	mov    %ebp,%edx
  80254e:	89 0c 24             	mov    %ecx,(%esp)
  802551:	75 2d                	jne    802580 <__udivdi3+0x50>
  802553:	39 e9                	cmp    %ebp,%ecx
  802555:	77 61                	ja     8025b8 <__udivdi3+0x88>
  802557:	85 c9                	test   %ecx,%ecx
  802559:	89 ce                	mov    %ecx,%esi
  80255b:	75 0b                	jne    802568 <__udivdi3+0x38>
  80255d:	b8 01 00 00 00       	mov    $0x1,%eax
  802562:	31 d2                	xor    %edx,%edx
  802564:	f7 f1                	div    %ecx
  802566:	89 c6                	mov    %eax,%esi
  802568:	31 d2                	xor    %edx,%edx
  80256a:	89 e8                	mov    %ebp,%eax
  80256c:	f7 f6                	div    %esi
  80256e:	89 c5                	mov    %eax,%ebp
  802570:	89 f8                	mov    %edi,%eax
  802572:	f7 f6                	div    %esi
  802574:	89 ea                	mov    %ebp,%edx
  802576:	83 c4 0c             	add    $0xc,%esp
  802579:	5e                   	pop    %esi
  80257a:	5f                   	pop    %edi
  80257b:	5d                   	pop    %ebp
  80257c:	c3                   	ret    
  80257d:	8d 76 00             	lea    0x0(%esi),%esi
  802580:	39 e8                	cmp    %ebp,%eax
  802582:	77 24                	ja     8025a8 <__udivdi3+0x78>
  802584:	0f bd e8             	bsr    %eax,%ebp
  802587:	83 f5 1f             	xor    $0x1f,%ebp
  80258a:	75 3c                	jne    8025c8 <__udivdi3+0x98>
  80258c:	8b 74 24 04          	mov    0x4(%esp),%esi
  802590:	39 34 24             	cmp    %esi,(%esp)
  802593:	0f 86 9f 00 00 00    	jbe    802638 <__udivdi3+0x108>
  802599:	39 d0                	cmp    %edx,%eax
  80259b:	0f 82 97 00 00 00    	jb     802638 <__udivdi3+0x108>
  8025a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025a8:	31 d2                	xor    %edx,%edx
  8025aa:	31 c0                	xor    %eax,%eax
  8025ac:	83 c4 0c             	add    $0xc,%esp
  8025af:	5e                   	pop    %esi
  8025b0:	5f                   	pop    %edi
  8025b1:	5d                   	pop    %ebp
  8025b2:	c3                   	ret    
  8025b3:	90                   	nop
  8025b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025b8:	89 f8                	mov    %edi,%eax
  8025ba:	f7 f1                	div    %ecx
  8025bc:	31 d2                	xor    %edx,%edx
  8025be:	83 c4 0c             	add    $0xc,%esp
  8025c1:	5e                   	pop    %esi
  8025c2:	5f                   	pop    %edi
  8025c3:	5d                   	pop    %ebp
  8025c4:	c3                   	ret    
  8025c5:	8d 76 00             	lea    0x0(%esi),%esi
  8025c8:	89 e9                	mov    %ebp,%ecx
  8025ca:	8b 3c 24             	mov    (%esp),%edi
  8025cd:	d3 e0                	shl    %cl,%eax
  8025cf:	89 c6                	mov    %eax,%esi
  8025d1:	b8 20 00 00 00       	mov    $0x20,%eax
  8025d6:	29 e8                	sub    %ebp,%eax
  8025d8:	89 c1                	mov    %eax,%ecx
  8025da:	d3 ef                	shr    %cl,%edi
  8025dc:	89 e9                	mov    %ebp,%ecx
  8025de:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8025e2:	8b 3c 24             	mov    (%esp),%edi
  8025e5:	09 74 24 08          	or     %esi,0x8(%esp)
  8025e9:	89 d6                	mov    %edx,%esi
  8025eb:	d3 e7                	shl    %cl,%edi
  8025ed:	89 c1                	mov    %eax,%ecx
  8025ef:	89 3c 24             	mov    %edi,(%esp)
  8025f2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8025f6:	d3 ee                	shr    %cl,%esi
  8025f8:	89 e9                	mov    %ebp,%ecx
  8025fa:	d3 e2                	shl    %cl,%edx
  8025fc:	89 c1                	mov    %eax,%ecx
  8025fe:	d3 ef                	shr    %cl,%edi
  802600:	09 d7                	or     %edx,%edi
  802602:	89 f2                	mov    %esi,%edx
  802604:	89 f8                	mov    %edi,%eax
  802606:	f7 74 24 08          	divl   0x8(%esp)
  80260a:	89 d6                	mov    %edx,%esi
  80260c:	89 c7                	mov    %eax,%edi
  80260e:	f7 24 24             	mull   (%esp)
  802611:	39 d6                	cmp    %edx,%esi
  802613:	89 14 24             	mov    %edx,(%esp)
  802616:	72 30                	jb     802648 <__udivdi3+0x118>
  802618:	8b 54 24 04          	mov    0x4(%esp),%edx
  80261c:	89 e9                	mov    %ebp,%ecx
  80261e:	d3 e2                	shl    %cl,%edx
  802620:	39 c2                	cmp    %eax,%edx
  802622:	73 05                	jae    802629 <__udivdi3+0xf9>
  802624:	3b 34 24             	cmp    (%esp),%esi
  802627:	74 1f                	je     802648 <__udivdi3+0x118>
  802629:	89 f8                	mov    %edi,%eax
  80262b:	31 d2                	xor    %edx,%edx
  80262d:	e9 7a ff ff ff       	jmp    8025ac <__udivdi3+0x7c>
  802632:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802638:	31 d2                	xor    %edx,%edx
  80263a:	b8 01 00 00 00       	mov    $0x1,%eax
  80263f:	e9 68 ff ff ff       	jmp    8025ac <__udivdi3+0x7c>
  802644:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802648:	8d 47 ff             	lea    -0x1(%edi),%eax
  80264b:	31 d2                	xor    %edx,%edx
  80264d:	83 c4 0c             	add    $0xc,%esp
  802650:	5e                   	pop    %esi
  802651:	5f                   	pop    %edi
  802652:	5d                   	pop    %ebp
  802653:	c3                   	ret    
  802654:	66 90                	xchg   %ax,%ax
  802656:	66 90                	xchg   %ax,%ax
  802658:	66 90                	xchg   %ax,%ax
  80265a:	66 90                	xchg   %ax,%ax
  80265c:	66 90                	xchg   %ax,%ax
  80265e:	66 90                	xchg   %ax,%ax

00802660 <__umoddi3>:
  802660:	55                   	push   %ebp
  802661:	57                   	push   %edi
  802662:	56                   	push   %esi
  802663:	83 ec 14             	sub    $0x14,%esp
  802666:	8b 44 24 28          	mov    0x28(%esp),%eax
  80266a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80266e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  802672:	89 c7                	mov    %eax,%edi
  802674:	89 44 24 04          	mov    %eax,0x4(%esp)
  802678:	8b 44 24 30          	mov    0x30(%esp),%eax
  80267c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802680:	89 34 24             	mov    %esi,(%esp)
  802683:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802687:	85 c0                	test   %eax,%eax
  802689:	89 c2                	mov    %eax,%edx
  80268b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80268f:	75 17                	jne    8026a8 <__umoddi3+0x48>
  802691:	39 fe                	cmp    %edi,%esi
  802693:	76 4b                	jbe    8026e0 <__umoddi3+0x80>
  802695:	89 c8                	mov    %ecx,%eax
  802697:	89 fa                	mov    %edi,%edx
  802699:	f7 f6                	div    %esi
  80269b:	89 d0                	mov    %edx,%eax
  80269d:	31 d2                	xor    %edx,%edx
  80269f:	83 c4 14             	add    $0x14,%esp
  8026a2:	5e                   	pop    %esi
  8026a3:	5f                   	pop    %edi
  8026a4:	5d                   	pop    %ebp
  8026a5:	c3                   	ret    
  8026a6:	66 90                	xchg   %ax,%ax
  8026a8:	39 f8                	cmp    %edi,%eax
  8026aa:	77 54                	ja     802700 <__umoddi3+0xa0>
  8026ac:	0f bd e8             	bsr    %eax,%ebp
  8026af:	83 f5 1f             	xor    $0x1f,%ebp
  8026b2:	75 5c                	jne    802710 <__umoddi3+0xb0>
  8026b4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8026b8:	39 3c 24             	cmp    %edi,(%esp)
  8026bb:	0f 87 e7 00 00 00    	ja     8027a8 <__umoddi3+0x148>
  8026c1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8026c5:	29 f1                	sub    %esi,%ecx
  8026c7:	19 c7                	sbb    %eax,%edi
  8026c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026cd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8026d1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026d5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8026d9:	83 c4 14             	add    $0x14,%esp
  8026dc:	5e                   	pop    %esi
  8026dd:	5f                   	pop    %edi
  8026de:	5d                   	pop    %ebp
  8026df:	c3                   	ret    
  8026e0:	85 f6                	test   %esi,%esi
  8026e2:	89 f5                	mov    %esi,%ebp
  8026e4:	75 0b                	jne    8026f1 <__umoddi3+0x91>
  8026e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8026eb:	31 d2                	xor    %edx,%edx
  8026ed:	f7 f6                	div    %esi
  8026ef:	89 c5                	mov    %eax,%ebp
  8026f1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8026f5:	31 d2                	xor    %edx,%edx
  8026f7:	f7 f5                	div    %ebp
  8026f9:	89 c8                	mov    %ecx,%eax
  8026fb:	f7 f5                	div    %ebp
  8026fd:	eb 9c                	jmp    80269b <__umoddi3+0x3b>
  8026ff:	90                   	nop
  802700:	89 c8                	mov    %ecx,%eax
  802702:	89 fa                	mov    %edi,%edx
  802704:	83 c4 14             	add    $0x14,%esp
  802707:	5e                   	pop    %esi
  802708:	5f                   	pop    %edi
  802709:	5d                   	pop    %ebp
  80270a:	c3                   	ret    
  80270b:	90                   	nop
  80270c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802710:	8b 04 24             	mov    (%esp),%eax
  802713:	be 20 00 00 00       	mov    $0x20,%esi
  802718:	89 e9                	mov    %ebp,%ecx
  80271a:	29 ee                	sub    %ebp,%esi
  80271c:	d3 e2                	shl    %cl,%edx
  80271e:	89 f1                	mov    %esi,%ecx
  802720:	d3 e8                	shr    %cl,%eax
  802722:	89 e9                	mov    %ebp,%ecx
  802724:	89 44 24 04          	mov    %eax,0x4(%esp)
  802728:	8b 04 24             	mov    (%esp),%eax
  80272b:	09 54 24 04          	or     %edx,0x4(%esp)
  80272f:	89 fa                	mov    %edi,%edx
  802731:	d3 e0                	shl    %cl,%eax
  802733:	89 f1                	mov    %esi,%ecx
  802735:	89 44 24 08          	mov    %eax,0x8(%esp)
  802739:	8b 44 24 10          	mov    0x10(%esp),%eax
  80273d:	d3 ea                	shr    %cl,%edx
  80273f:	89 e9                	mov    %ebp,%ecx
  802741:	d3 e7                	shl    %cl,%edi
  802743:	89 f1                	mov    %esi,%ecx
  802745:	d3 e8                	shr    %cl,%eax
  802747:	89 e9                	mov    %ebp,%ecx
  802749:	09 f8                	or     %edi,%eax
  80274b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80274f:	f7 74 24 04          	divl   0x4(%esp)
  802753:	d3 e7                	shl    %cl,%edi
  802755:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802759:	89 d7                	mov    %edx,%edi
  80275b:	f7 64 24 08          	mull   0x8(%esp)
  80275f:	39 d7                	cmp    %edx,%edi
  802761:	89 c1                	mov    %eax,%ecx
  802763:	89 14 24             	mov    %edx,(%esp)
  802766:	72 2c                	jb     802794 <__umoddi3+0x134>
  802768:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80276c:	72 22                	jb     802790 <__umoddi3+0x130>
  80276e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802772:	29 c8                	sub    %ecx,%eax
  802774:	19 d7                	sbb    %edx,%edi
  802776:	89 e9                	mov    %ebp,%ecx
  802778:	89 fa                	mov    %edi,%edx
  80277a:	d3 e8                	shr    %cl,%eax
  80277c:	89 f1                	mov    %esi,%ecx
  80277e:	d3 e2                	shl    %cl,%edx
  802780:	89 e9                	mov    %ebp,%ecx
  802782:	d3 ef                	shr    %cl,%edi
  802784:	09 d0                	or     %edx,%eax
  802786:	89 fa                	mov    %edi,%edx
  802788:	83 c4 14             	add    $0x14,%esp
  80278b:	5e                   	pop    %esi
  80278c:	5f                   	pop    %edi
  80278d:	5d                   	pop    %ebp
  80278e:	c3                   	ret    
  80278f:	90                   	nop
  802790:	39 d7                	cmp    %edx,%edi
  802792:	75 da                	jne    80276e <__umoddi3+0x10e>
  802794:	8b 14 24             	mov    (%esp),%edx
  802797:	89 c1                	mov    %eax,%ecx
  802799:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80279d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8027a1:	eb cb                	jmp    80276e <__umoddi3+0x10e>
  8027a3:	90                   	nop
  8027a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027a8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8027ac:	0f 82 0f ff ff ff    	jb     8026c1 <__umoddi3+0x61>
  8027b2:	e9 1a ff ff ff       	jmp    8026d1 <__umoddi3+0x71>
