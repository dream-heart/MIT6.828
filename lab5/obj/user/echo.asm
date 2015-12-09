
obj/user/echo.debug：     文件格式 elf32-i386


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
  80002c:	e8 c3 00 00 00       	call   8000f4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
  800042:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800049:	83 ff 01             	cmp    $0x1,%edi
  80004c:	7e 2b                	jle    800079 <umain+0x46>
  80004e:	c7 44 24 04 20 21 80 	movl   $0x802120,0x4(%esp)
  800055:	00 
  800056:	8b 46 04             	mov    0x4(%esi),%eax
  800059:	89 04 24             	mov    %eax,(%esp)
  80005c:	e8 db 01 00 00       	call   80023c <strcmp>
void
umain(int argc, char **argv)
{
	int i, nflag;

	nflag = 0;
  800061:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800068:	85 c0                	test   %eax,%eax
  80006a:	75 0d                	jne    800079 <umain+0x46>
		nflag = 1;
		argc--;
  80006c:	83 ef 01             	sub    $0x1,%edi
		argv++;
  80006f:	83 c6 04             	add    $0x4,%esi
{
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
  800072:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  800079:	bb 01 00 00 00       	mov    $0x1,%ebx
  80007e:	eb 46                	jmp    8000c6 <umain+0x93>
		if (i > 1)
  800080:	83 fb 01             	cmp    $0x1,%ebx
  800083:	7e 1c                	jle    8000a1 <umain+0x6e>
			write(1, " ", 1);
  800085:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 23 21 80 	movl   $0x802123,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80009c:	e8 51 0b 00 00       	call   800bf2 <write>
		write(1, argv[i], strlen(argv[i]));
  8000a1:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8000a4:	89 04 24             	mov    %eax,(%esp)
  8000a7:	e8 a4 00 00 00       	call   800150 <strlen>
  8000ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b0:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8000b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000be:	e8 2f 0b 00 00       	call   800bf2 <write>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  8000c3:	83 c3 01             	add    $0x1,%ebx
  8000c6:	39 df                	cmp    %ebx,%edi
  8000c8:	7f b6                	jg     800080 <umain+0x4d>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
  8000ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000ce:	75 1c                	jne    8000ec <umain+0xb9>
		write(1, "\n", 1);
  8000d0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8000d7:	00 
  8000d8:	c7 44 24 04 51 22 80 	movl   $0x802251,0x4(%esp)
  8000df:	00 
  8000e0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000e7:	e8 06 0b 00 00       	call   800bf2 <write>
}
  8000ec:	83 c4 1c             	add    $0x1c,%esp
  8000ef:	5b                   	pop    %ebx
  8000f0:	5e                   	pop    %esi
  8000f1:	5f                   	pop    %edi
  8000f2:	5d                   	pop    %ebp
  8000f3:	c3                   	ret    

008000f4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	56                   	push   %esi
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 10             	sub    $0x10,%esp
  8000fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ff:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB : Your code here.
	envid_t envid = sys_getenvid();
  800102:	e8 5e 04 00 00       	call   800565 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800107:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800114:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800119:	85 db                	test   %ebx,%ebx
  80011b:	7e 07                	jle    800124 <libmain+0x30>
		binaryname = argv[0];
  80011d:	8b 06                	mov    (%esi),%eax
  80011f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800124:	89 74 24 04          	mov    %esi,0x4(%esp)
  800128:	89 1c 24             	mov    %ebx,(%esp)
  80012b:	e8 03 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800130:	e8 07 00 00 00       	call   80013c <exit>
}
  800135:	83 c4 10             	add    $0x10,%esp
  800138:	5b                   	pop    %ebx
  800139:	5e                   	pop    %esi
  80013a:	5d                   	pop    %ebp
  80013b:	c3                   	ret    

0080013c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	83 ec 18             	sub    $0x18,%esp
	//close_all();
	sys_env_destroy(0);
  800142:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800149:	e8 c5 03 00 00       	call   800513 <sys_env_destroy>
}
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800156:	b8 00 00 00 00       	mov    $0x0,%eax
  80015b:	eb 03                	jmp    800160 <strlen+0x10>
		n++;
  80015d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800160:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800164:	75 f7                	jne    80015d <strlen+0xd>
		n++;
	return n;
}
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800171:	b8 00 00 00 00       	mov    $0x0,%eax
  800176:	eb 03                	jmp    80017b <strnlen+0x13>
		n++;
  800178:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80017b:	39 d0                	cmp    %edx,%eax
  80017d:	74 06                	je     800185 <strnlen+0x1d>
  80017f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800183:	75 f3                	jne    800178 <strnlen+0x10>
		n++;
	return n;
}
  800185:	5d                   	pop    %ebp
  800186:	c3                   	ret    

00800187 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	53                   	push   %ebx
  80018b:	8b 45 08             	mov    0x8(%ebp),%eax
  80018e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800191:	89 c2                	mov    %eax,%edx
  800193:	83 c2 01             	add    $0x1,%edx
  800196:	83 c1 01             	add    $0x1,%ecx
  800199:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80019d:	88 5a ff             	mov    %bl,-0x1(%edx)
  8001a0:	84 db                	test   %bl,%bl
  8001a2:	75 ef                	jne    800193 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8001a4:	5b                   	pop    %ebx
  8001a5:	5d                   	pop    %ebp
  8001a6:	c3                   	ret    

008001a7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 08             	sub    $0x8,%esp
  8001ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8001b1:	89 1c 24             	mov    %ebx,(%esp)
  8001b4:	e8 97 ff ff ff       	call   800150 <strlen>
	strcpy(dst + len, src);
  8001b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bc:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001c0:	01 d8                	add    %ebx,%eax
  8001c2:	89 04 24             	mov    %eax,(%esp)
  8001c5:	e8 bd ff ff ff       	call   800187 <strcpy>
	return dst;
}
  8001ca:	89 d8                	mov    %ebx,%eax
  8001cc:	83 c4 08             	add    $0x8,%esp
  8001cf:	5b                   	pop    %ebx
  8001d0:	5d                   	pop    %ebp
  8001d1:	c3                   	ret    

008001d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	56                   	push   %esi
  8001d6:	53                   	push   %ebx
  8001d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8001da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001dd:	89 f3                	mov    %esi,%ebx
  8001df:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001e2:	89 f2                	mov    %esi,%edx
  8001e4:	eb 0f                	jmp    8001f5 <strncpy+0x23>
		*dst++ = *src;
  8001e6:	83 c2 01             	add    $0x1,%edx
  8001e9:	0f b6 01             	movzbl (%ecx),%eax
  8001ec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001ef:	80 39 01             	cmpb   $0x1,(%ecx)
  8001f2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001f5:	39 da                	cmp    %ebx,%edx
  8001f7:	75 ed                	jne    8001e6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8001f9:	89 f0                	mov    %esi,%eax
  8001fb:	5b                   	pop    %ebx
  8001fc:	5e                   	pop    %esi
  8001fd:	5d                   	pop    %ebp
  8001fe:	c3                   	ret    

008001ff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	56                   	push   %esi
  800203:	53                   	push   %ebx
  800204:	8b 75 08             	mov    0x8(%ebp),%esi
  800207:	8b 55 0c             	mov    0xc(%ebp),%edx
  80020a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80020d:	89 f0                	mov    %esi,%eax
  80020f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800213:	85 c9                	test   %ecx,%ecx
  800215:	75 0b                	jne    800222 <strlcpy+0x23>
  800217:	eb 1d                	jmp    800236 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800219:	83 c0 01             	add    $0x1,%eax
  80021c:	83 c2 01             	add    $0x1,%edx
  80021f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800222:	39 d8                	cmp    %ebx,%eax
  800224:	74 0b                	je     800231 <strlcpy+0x32>
  800226:	0f b6 0a             	movzbl (%edx),%ecx
  800229:	84 c9                	test   %cl,%cl
  80022b:	75 ec                	jne    800219 <strlcpy+0x1a>
  80022d:	89 c2                	mov    %eax,%edx
  80022f:	eb 02                	jmp    800233 <strlcpy+0x34>
  800231:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800233:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800236:	29 f0                	sub    %esi,%eax
}
  800238:	5b                   	pop    %ebx
  800239:	5e                   	pop    %esi
  80023a:	5d                   	pop    %ebp
  80023b:	c3                   	ret    

0080023c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800242:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800245:	eb 06                	jmp    80024d <strcmp+0x11>
		p++, q++;
  800247:	83 c1 01             	add    $0x1,%ecx
  80024a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80024d:	0f b6 01             	movzbl (%ecx),%eax
  800250:	84 c0                	test   %al,%al
  800252:	74 04                	je     800258 <strcmp+0x1c>
  800254:	3a 02                	cmp    (%edx),%al
  800256:	74 ef                	je     800247 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800258:	0f b6 c0             	movzbl %al,%eax
  80025b:	0f b6 12             	movzbl (%edx),%edx
  80025e:	29 d0                	sub    %edx,%eax
}
  800260:	5d                   	pop    %ebp
  800261:	c3                   	ret    

00800262 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800262:	55                   	push   %ebp
  800263:	89 e5                	mov    %esp,%ebp
  800265:	53                   	push   %ebx
  800266:	8b 45 08             	mov    0x8(%ebp),%eax
  800269:	8b 55 0c             	mov    0xc(%ebp),%edx
  80026c:	89 c3                	mov    %eax,%ebx
  80026e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800271:	eb 06                	jmp    800279 <strncmp+0x17>
		n--, p++, q++;
  800273:	83 c0 01             	add    $0x1,%eax
  800276:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800279:	39 d8                	cmp    %ebx,%eax
  80027b:	74 15                	je     800292 <strncmp+0x30>
  80027d:	0f b6 08             	movzbl (%eax),%ecx
  800280:	84 c9                	test   %cl,%cl
  800282:	74 04                	je     800288 <strncmp+0x26>
  800284:	3a 0a                	cmp    (%edx),%cl
  800286:	74 eb                	je     800273 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800288:	0f b6 00             	movzbl (%eax),%eax
  80028b:	0f b6 12             	movzbl (%edx),%edx
  80028e:	29 d0                	sub    %edx,%eax
  800290:	eb 05                	jmp    800297 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800292:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800297:	5b                   	pop    %ebx
  800298:	5d                   	pop    %ebp
  800299:	c3                   	ret    

0080029a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002a4:	eb 07                	jmp    8002ad <strchr+0x13>
		if (*s == c)
  8002a6:	38 ca                	cmp    %cl,%dl
  8002a8:	74 0f                	je     8002b9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8002aa:	83 c0 01             	add    $0x1,%eax
  8002ad:	0f b6 10             	movzbl (%eax),%edx
  8002b0:	84 d2                	test   %dl,%dl
  8002b2:	75 f2                	jne    8002a6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8002b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002c5:	eb 07                	jmp    8002ce <strfind+0x13>
		if (*s == c)
  8002c7:	38 ca                	cmp    %cl,%dl
  8002c9:	74 0a                	je     8002d5 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8002cb:	83 c0 01             	add    $0x1,%eax
  8002ce:	0f b6 10             	movzbl (%eax),%edx
  8002d1:	84 d2                	test   %dl,%dl
  8002d3:	75 f2                	jne    8002c7 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8002d5:	5d                   	pop    %ebp
  8002d6:	c3                   	ret    

008002d7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002d7:	55                   	push   %ebp
  8002d8:	89 e5                	mov    %esp,%ebp
  8002da:	57                   	push   %edi
  8002db:	56                   	push   %esi
  8002dc:	53                   	push   %ebx
  8002dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8002e3:	85 c9                	test   %ecx,%ecx
  8002e5:	74 36                	je     80031d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002e7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002ed:	75 28                	jne    800317 <memset+0x40>
  8002ef:	f6 c1 03             	test   $0x3,%cl
  8002f2:	75 23                	jne    800317 <memset+0x40>
		c &= 0xFF;
  8002f4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8002f8:	89 d3                	mov    %edx,%ebx
  8002fa:	c1 e3 08             	shl    $0x8,%ebx
  8002fd:	89 d6                	mov    %edx,%esi
  8002ff:	c1 e6 18             	shl    $0x18,%esi
  800302:	89 d0                	mov    %edx,%eax
  800304:	c1 e0 10             	shl    $0x10,%eax
  800307:	09 f0                	or     %esi,%eax
  800309:	09 c2                	or     %eax,%edx
  80030b:	89 d0                	mov    %edx,%eax
  80030d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80030f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800312:	fc                   	cld    
  800313:	f3 ab                	rep stos %eax,%es:(%edi)
  800315:	eb 06                	jmp    80031d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800317:	8b 45 0c             	mov    0xc(%ebp),%eax
  80031a:	fc                   	cld    
  80031b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80031d:	89 f8                	mov    %edi,%eax
  80031f:	5b                   	pop    %ebx
  800320:	5e                   	pop    %esi
  800321:	5f                   	pop    %edi
  800322:	5d                   	pop    %ebp
  800323:	c3                   	ret    

00800324 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800324:	55                   	push   %ebp
  800325:	89 e5                	mov    %esp,%ebp
  800327:	57                   	push   %edi
  800328:	56                   	push   %esi
  800329:	8b 45 08             	mov    0x8(%ebp),%eax
  80032c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80032f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800332:	39 c6                	cmp    %eax,%esi
  800334:	73 35                	jae    80036b <memmove+0x47>
  800336:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800339:	39 d0                	cmp    %edx,%eax
  80033b:	73 2e                	jae    80036b <memmove+0x47>
		s += n;
		d += n;
  80033d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800340:	89 d6                	mov    %edx,%esi
  800342:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800344:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80034a:	75 13                	jne    80035f <memmove+0x3b>
  80034c:	f6 c1 03             	test   $0x3,%cl
  80034f:	75 0e                	jne    80035f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800351:	83 ef 04             	sub    $0x4,%edi
  800354:	8d 72 fc             	lea    -0x4(%edx),%esi
  800357:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80035a:	fd                   	std    
  80035b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80035d:	eb 09                	jmp    800368 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80035f:	83 ef 01             	sub    $0x1,%edi
  800362:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800365:	fd                   	std    
  800366:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800368:	fc                   	cld    
  800369:	eb 1d                	jmp    800388 <memmove+0x64>
  80036b:	89 f2                	mov    %esi,%edx
  80036d:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80036f:	f6 c2 03             	test   $0x3,%dl
  800372:	75 0f                	jne    800383 <memmove+0x5f>
  800374:	f6 c1 03             	test   $0x3,%cl
  800377:	75 0a                	jne    800383 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800379:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80037c:	89 c7                	mov    %eax,%edi
  80037e:	fc                   	cld    
  80037f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800381:	eb 05                	jmp    800388 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800383:	89 c7                	mov    %eax,%edi
  800385:	fc                   	cld    
  800386:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800388:	5e                   	pop    %esi
  800389:	5f                   	pop    %edi
  80038a:	5d                   	pop    %ebp
  80038b:	c3                   	ret    

0080038c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800392:	8b 45 10             	mov    0x10(%ebp),%eax
  800395:	89 44 24 08          	mov    %eax,0x8(%esp)
  800399:	8b 45 0c             	mov    0xc(%ebp),%eax
  80039c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a3:	89 04 24             	mov    %eax,(%esp)
  8003a6:	e8 79 ff ff ff       	call   800324 <memmove>
}
  8003ab:	c9                   	leave  
  8003ac:	c3                   	ret    

008003ad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8003ad:	55                   	push   %ebp
  8003ae:	89 e5                	mov    %esp,%ebp
  8003b0:	56                   	push   %esi
  8003b1:	53                   	push   %ebx
  8003b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003b8:	89 d6                	mov    %edx,%esi
  8003ba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003bd:	eb 1a                	jmp    8003d9 <memcmp+0x2c>
		if (*s1 != *s2)
  8003bf:	0f b6 02             	movzbl (%edx),%eax
  8003c2:	0f b6 19             	movzbl (%ecx),%ebx
  8003c5:	38 d8                	cmp    %bl,%al
  8003c7:	74 0a                	je     8003d3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8003c9:	0f b6 c0             	movzbl %al,%eax
  8003cc:	0f b6 db             	movzbl %bl,%ebx
  8003cf:	29 d8                	sub    %ebx,%eax
  8003d1:	eb 0f                	jmp    8003e2 <memcmp+0x35>
		s1++, s2++;
  8003d3:	83 c2 01             	add    $0x1,%edx
  8003d6:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003d9:	39 f2                	cmp    %esi,%edx
  8003db:	75 e2                	jne    8003bf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8003dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003e2:	5b                   	pop    %ebx
  8003e3:	5e                   	pop    %esi
  8003e4:	5d                   	pop    %ebp
  8003e5:	c3                   	ret    

008003e6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
  8003e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8003ef:	89 c2                	mov    %eax,%edx
  8003f1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8003f4:	eb 07                	jmp    8003fd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8003f6:	38 08                	cmp    %cl,(%eax)
  8003f8:	74 07                	je     800401 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003fa:	83 c0 01             	add    $0x1,%eax
  8003fd:	39 d0                	cmp    %edx,%eax
  8003ff:	72 f5                	jb     8003f6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800401:	5d                   	pop    %ebp
  800402:	c3                   	ret    

00800403 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	57                   	push   %edi
  800407:	56                   	push   %esi
  800408:	53                   	push   %ebx
  800409:	8b 55 08             	mov    0x8(%ebp),%edx
  80040c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80040f:	eb 03                	jmp    800414 <strtol+0x11>
		s++;
  800411:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800414:	0f b6 0a             	movzbl (%edx),%ecx
  800417:	80 f9 09             	cmp    $0x9,%cl
  80041a:	74 f5                	je     800411 <strtol+0xe>
  80041c:	80 f9 20             	cmp    $0x20,%cl
  80041f:	74 f0                	je     800411 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800421:	80 f9 2b             	cmp    $0x2b,%cl
  800424:	75 0a                	jne    800430 <strtol+0x2d>
		s++;
  800426:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800429:	bf 00 00 00 00       	mov    $0x0,%edi
  80042e:	eb 11                	jmp    800441 <strtol+0x3e>
  800430:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800435:	80 f9 2d             	cmp    $0x2d,%cl
  800438:	75 07                	jne    800441 <strtol+0x3e>
		s++, neg = 1;
  80043a:	8d 52 01             	lea    0x1(%edx),%edx
  80043d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800441:	a9 ef ff ff ff       	test   $0xffffffef,%eax
  800446:	75 15                	jne    80045d <strtol+0x5a>
  800448:	80 3a 30             	cmpb   $0x30,(%edx)
  80044b:	75 10                	jne    80045d <strtol+0x5a>
  80044d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800451:	75 0a                	jne    80045d <strtol+0x5a>
		s += 2, base = 16;
  800453:	83 c2 02             	add    $0x2,%edx
  800456:	b8 10 00 00 00       	mov    $0x10,%eax
  80045b:	eb 10                	jmp    80046d <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
  80045d:	85 c0                	test   %eax,%eax
  80045f:	75 0c                	jne    80046d <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800461:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800463:	80 3a 30             	cmpb   $0x30,(%edx)
  800466:	75 05                	jne    80046d <strtol+0x6a>
		s++, base = 8;
  800468:	83 c2 01             	add    $0x1,%edx
  80046b:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
  80046d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800472:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800475:	0f b6 0a             	movzbl (%edx),%ecx
  800478:	8d 71 d0             	lea    -0x30(%ecx),%esi
  80047b:	89 f0                	mov    %esi,%eax
  80047d:	3c 09                	cmp    $0x9,%al
  80047f:	77 08                	ja     800489 <strtol+0x86>
			dig = *s - '0';
  800481:	0f be c9             	movsbl %cl,%ecx
  800484:	83 e9 30             	sub    $0x30,%ecx
  800487:	eb 20                	jmp    8004a9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
  800489:	8d 71 9f             	lea    -0x61(%ecx),%esi
  80048c:	89 f0                	mov    %esi,%eax
  80048e:	3c 19                	cmp    $0x19,%al
  800490:	77 08                	ja     80049a <strtol+0x97>
			dig = *s - 'a' + 10;
  800492:	0f be c9             	movsbl %cl,%ecx
  800495:	83 e9 57             	sub    $0x57,%ecx
  800498:	eb 0f                	jmp    8004a9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
  80049a:	8d 71 bf             	lea    -0x41(%ecx),%esi
  80049d:	89 f0                	mov    %esi,%eax
  80049f:	3c 19                	cmp    $0x19,%al
  8004a1:	77 16                	ja     8004b9 <strtol+0xb6>
			dig = *s - 'A' + 10;
  8004a3:	0f be c9             	movsbl %cl,%ecx
  8004a6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8004a9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
  8004ac:	7d 0f                	jge    8004bd <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
  8004ae:	83 c2 01             	add    $0x1,%edx
  8004b1:	0f af 5d 10          	imul   0x10(%ebp),%ebx
  8004b5:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
  8004b7:	eb bc                	jmp    800475 <strtol+0x72>
  8004b9:	89 d8                	mov    %ebx,%eax
  8004bb:	eb 02                	jmp    8004bf <strtol+0xbc>
  8004bd:	89 d8                	mov    %ebx,%eax

	if (endptr)
  8004bf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004c3:	74 05                	je     8004ca <strtol+0xc7>
		*endptr = (char *) s;
  8004c5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004c8:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  8004ca:	f7 d8                	neg    %eax
  8004cc:	85 ff                	test   %edi,%edi
  8004ce:	0f 44 c3             	cmove  %ebx,%eax
}
  8004d1:	5b                   	pop    %ebx
  8004d2:	5e                   	pop    %esi
  8004d3:	5f                   	pop    %edi
  8004d4:	5d                   	pop    %ebp
  8004d5:	c3                   	ret    

008004d6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
  8004d9:	57                   	push   %edi
  8004da:	56                   	push   %esi
  8004db:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8004e7:	89 c3                	mov    %eax,%ebx
  8004e9:	89 c7                	mov    %eax,%edi
  8004eb:	89 c6                	mov    %eax,%esi
  8004ed:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004ef:	5b                   	pop    %ebx
  8004f0:	5e                   	pop    %esi
  8004f1:	5f                   	pop    %edi
  8004f2:	5d                   	pop    %ebp
  8004f3:	c3                   	ret    

008004f4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	57                   	push   %edi
  8004f8:	56                   	push   %esi
  8004f9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ff:	b8 01 00 00 00       	mov    $0x1,%eax
  800504:	89 d1                	mov    %edx,%ecx
  800506:	89 d3                	mov    %edx,%ebx
  800508:	89 d7                	mov    %edx,%edi
  80050a:	89 d6                	mov    %edx,%esi
  80050c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80050e:	5b                   	pop    %ebx
  80050f:	5e                   	pop    %esi
  800510:	5f                   	pop    %edi
  800511:	5d                   	pop    %ebp
  800512:	c3                   	ret    

00800513 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800513:	55                   	push   %ebp
  800514:	89 e5                	mov    %esp,%ebp
  800516:	57                   	push   %edi
  800517:	56                   	push   %esi
  800518:	53                   	push   %ebx
  800519:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80051c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800521:	b8 03 00 00 00       	mov    $0x3,%eax
  800526:	8b 55 08             	mov    0x8(%ebp),%edx
  800529:	89 cb                	mov    %ecx,%ebx
  80052b:	89 cf                	mov    %ecx,%edi
  80052d:	89 ce                	mov    %ecx,%esi
  80052f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800531:	85 c0                	test   %eax,%eax
  800533:	7e 28                	jle    80055d <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800535:	89 44 24 10          	mov    %eax,0x10(%esp)
  800539:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800540:	00 
  800541:	c7 44 24 08 2f 21 80 	movl   $0x80212f,0x8(%esp)
  800548:	00 
  800549:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800550:	00 
  800551:	c7 04 24 4c 21 80 00 	movl   $0x80214c,(%esp)
  800558:	e8 29 10 00 00       	call   801586 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80055d:	83 c4 2c             	add    $0x2c,%esp
  800560:	5b                   	pop    %ebx
  800561:	5e                   	pop    %esi
  800562:	5f                   	pop    %edi
  800563:	5d                   	pop    %ebp
  800564:	c3                   	ret    

00800565 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800565:	55                   	push   %ebp
  800566:	89 e5                	mov    %esp,%ebp
  800568:	57                   	push   %edi
  800569:	56                   	push   %esi
  80056a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80056b:	ba 00 00 00 00       	mov    $0x0,%edx
  800570:	b8 02 00 00 00       	mov    $0x2,%eax
  800575:	89 d1                	mov    %edx,%ecx
  800577:	89 d3                	mov    %edx,%ebx
  800579:	89 d7                	mov    %edx,%edi
  80057b:	89 d6                	mov    %edx,%esi
  80057d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80057f:	5b                   	pop    %ebx
  800580:	5e                   	pop    %esi
  800581:	5f                   	pop    %edi
  800582:	5d                   	pop    %ebp
  800583:	c3                   	ret    

00800584 <sys_yield>:

void
sys_yield(void)
{
  800584:	55                   	push   %ebp
  800585:	89 e5                	mov    %esp,%ebp
  800587:	57                   	push   %edi
  800588:	56                   	push   %esi
  800589:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80058a:	ba 00 00 00 00       	mov    $0x0,%edx
  80058f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800594:	89 d1                	mov    %edx,%ecx
  800596:	89 d3                	mov    %edx,%ebx
  800598:	89 d7                	mov    %edx,%edi
  80059a:	89 d6                	mov    %edx,%esi
  80059c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80059e:	5b                   	pop    %ebx
  80059f:	5e                   	pop    %esi
  8005a0:	5f                   	pop    %edi
  8005a1:	5d                   	pop    %ebp
  8005a2:	c3                   	ret    

008005a3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8005a3:	55                   	push   %ebp
  8005a4:	89 e5                	mov    %esp,%ebp
  8005a6:	57                   	push   %edi
  8005a7:	56                   	push   %esi
  8005a8:	53                   	push   %ebx
  8005a9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005ac:	be 00 00 00 00       	mov    $0x0,%esi
  8005b1:	b8 04 00 00 00       	mov    $0x4,%eax
  8005b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8005bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005bf:	89 f7                	mov    %esi,%edi
  8005c1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005c3:	85 c0                	test   %eax,%eax
  8005c5:	7e 28                	jle    8005ef <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005c7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005cb:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8005d2:	00 
  8005d3:	c7 44 24 08 2f 21 80 	movl   $0x80212f,0x8(%esp)
  8005da:	00 
  8005db:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005e2:	00 
  8005e3:	c7 04 24 4c 21 80 00 	movl   $0x80214c,(%esp)
  8005ea:	e8 97 0f 00 00       	call   801586 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8005ef:	83 c4 2c             	add    $0x2c,%esp
  8005f2:	5b                   	pop    %ebx
  8005f3:	5e                   	pop    %esi
  8005f4:	5f                   	pop    %edi
  8005f5:	5d                   	pop    %ebp
  8005f6:	c3                   	ret    

008005f7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8005f7:	55                   	push   %ebp
  8005f8:	89 e5                	mov    %esp,%ebp
  8005fa:	57                   	push   %edi
  8005fb:	56                   	push   %esi
  8005fc:	53                   	push   %ebx
  8005fd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800600:	b8 05 00 00 00       	mov    $0x5,%eax
  800605:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800608:	8b 55 08             	mov    0x8(%ebp),%edx
  80060b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80060e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800611:	8b 75 18             	mov    0x18(%ebp),%esi
  800614:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800616:	85 c0                	test   %eax,%eax
  800618:	7e 28                	jle    800642 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80061a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80061e:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800625:	00 
  800626:	c7 44 24 08 2f 21 80 	movl   $0x80212f,0x8(%esp)
  80062d:	00 
  80062e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800635:	00 
  800636:	c7 04 24 4c 21 80 00 	movl   $0x80214c,(%esp)
  80063d:	e8 44 0f 00 00       	call   801586 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800642:	83 c4 2c             	add    $0x2c,%esp
  800645:	5b                   	pop    %ebx
  800646:	5e                   	pop    %esi
  800647:	5f                   	pop    %edi
  800648:	5d                   	pop    %ebp
  800649:	c3                   	ret    

0080064a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80064a:	55                   	push   %ebp
  80064b:	89 e5                	mov    %esp,%ebp
  80064d:	57                   	push   %edi
  80064e:	56                   	push   %esi
  80064f:	53                   	push   %ebx
  800650:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800653:	bb 00 00 00 00       	mov    $0x0,%ebx
  800658:	b8 06 00 00 00       	mov    $0x6,%eax
  80065d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800660:	8b 55 08             	mov    0x8(%ebp),%edx
  800663:	89 df                	mov    %ebx,%edi
  800665:	89 de                	mov    %ebx,%esi
  800667:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800669:	85 c0                	test   %eax,%eax
  80066b:	7e 28                	jle    800695 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80066d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800671:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800678:	00 
  800679:	c7 44 24 08 2f 21 80 	movl   $0x80212f,0x8(%esp)
  800680:	00 
  800681:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800688:	00 
  800689:	c7 04 24 4c 21 80 00 	movl   $0x80214c,(%esp)
  800690:	e8 f1 0e 00 00       	call   801586 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800695:	83 c4 2c             	add    $0x2c,%esp
  800698:	5b                   	pop    %ebx
  800699:	5e                   	pop    %esi
  80069a:	5f                   	pop    %edi
  80069b:	5d                   	pop    %ebp
  80069c:	c3                   	ret    

0080069d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80069d:	55                   	push   %ebp
  80069e:	89 e5                	mov    %esp,%ebp
  8006a0:	57                   	push   %edi
  8006a1:	56                   	push   %esi
  8006a2:	53                   	push   %ebx
  8006a3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ab:	b8 08 00 00 00       	mov    $0x8,%eax
  8006b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8006b6:	89 df                	mov    %ebx,%edi
  8006b8:	89 de                	mov    %ebx,%esi
  8006ba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006bc:	85 c0                	test   %eax,%eax
  8006be:	7e 28                	jle    8006e8 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006c0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006c4:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8006cb:	00 
  8006cc:	c7 44 24 08 2f 21 80 	movl   $0x80212f,0x8(%esp)
  8006d3:	00 
  8006d4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8006db:	00 
  8006dc:	c7 04 24 4c 21 80 00 	movl   $0x80214c,(%esp)
  8006e3:	e8 9e 0e 00 00       	call   801586 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8006e8:	83 c4 2c             	add    $0x2c,%esp
  8006eb:	5b                   	pop    %ebx
  8006ec:	5e                   	pop    %esi
  8006ed:	5f                   	pop    %edi
  8006ee:	5d                   	pop    %ebp
  8006ef:	c3                   	ret    

008006f0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8006f0:	55                   	push   %ebp
  8006f1:	89 e5                	mov    %esp,%ebp
  8006f3:	57                   	push   %edi
  8006f4:	56                   	push   %esi
  8006f5:	53                   	push   %ebx
  8006f6:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006fe:	b8 09 00 00 00       	mov    $0x9,%eax
  800703:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800706:	8b 55 08             	mov    0x8(%ebp),%edx
  800709:	89 df                	mov    %ebx,%edi
  80070b:	89 de                	mov    %ebx,%esi
  80070d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80070f:	85 c0                	test   %eax,%eax
  800711:	7e 28                	jle    80073b <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800713:	89 44 24 10          	mov    %eax,0x10(%esp)
  800717:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80071e:	00 
  80071f:	c7 44 24 08 2f 21 80 	movl   $0x80212f,0x8(%esp)
  800726:	00 
  800727:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80072e:	00 
  80072f:	c7 04 24 4c 21 80 00 	movl   $0x80214c,(%esp)
  800736:	e8 4b 0e 00 00       	call   801586 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80073b:	83 c4 2c             	add    $0x2c,%esp
  80073e:	5b                   	pop    %ebx
  80073f:	5e                   	pop    %esi
  800740:	5f                   	pop    %edi
  800741:	5d                   	pop    %ebp
  800742:	c3                   	ret    

00800743 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	57                   	push   %edi
  800747:	56                   	push   %esi
  800748:	53                   	push   %ebx
  800749:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80074c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800751:	b8 0a 00 00 00       	mov    $0xa,%eax
  800756:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800759:	8b 55 08             	mov    0x8(%ebp),%edx
  80075c:	89 df                	mov    %ebx,%edi
  80075e:	89 de                	mov    %ebx,%esi
  800760:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800762:	85 c0                	test   %eax,%eax
  800764:	7e 28                	jle    80078e <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800766:	89 44 24 10          	mov    %eax,0x10(%esp)
  80076a:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800771:	00 
  800772:	c7 44 24 08 2f 21 80 	movl   $0x80212f,0x8(%esp)
  800779:	00 
  80077a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800781:	00 
  800782:	c7 04 24 4c 21 80 00 	movl   $0x80214c,(%esp)
  800789:	e8 f8 0d 00 00       	call   801586 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80078e:	83 c4 2c             	add    $0x2c,%esp
  800791:	5b                   	pop    %ebx
  800792:	5e                   	pop    %esi
  800793:	5f                   	pop    %edi
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	57                   	push   %edi
  80079a:	56                   	push   %esi
  80079b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80079c:	be 00 00 00 00       	mov    $0x0,%esi
  8007a1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8007a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8007ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8007af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8007b2:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8007b4:	5b                   	pop    %ebx
  8007b5:	5e                   	pop    %esi
  8007b6:	5f                   	pop    %edi
  8007b7:	5d                   	pop    %ebp
  8007b8:	c3                   	ret    

008007b9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	57                   	push   %edi
  8007bd:	56                   	push   %esi
  8007be:	53                   	push   %ebx
  8007bf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007c7:	b8 0d 00 00 00       	mov    $0xd,%eax
  8007cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8007cf:	89 cb                	mov    %ecx,%ebx
  8007d1:	89 cf                	mov    %ecx,%edi
  8007d3:	89 ce                	mov    %ecx,%esi
  8007d5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8007d7:	85 c0                	test   %eax,%eax
  8007d9:	7e 28                	jle    800803 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007db:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007df:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8007e6:	00 
  8007e7:	c7 44 24 08 2f 21 80 	movl   $0x80212f,0x8(%esp)
  8007ee:	00 
  8007ef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8007f6:	00 
  8007f7:	c7 04 24 4c 21 80 00 	movl   $0x80214c,(%esp)
  8007fe:	e8 83 0d 00 00       	call   801586 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800803:	83 c4 2c             	add    $0x2c,%esp
  800806:	5b                   	pop    %ebx
  800807:	5e                   	pop    %esi
  800808:	5f                   	pop    %edi
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    
  80080b:	66 90                	xchg   %ax,%ax
  80080d:	66 90                	xchg   %ax,%ax
  80080f:	90                   	nop

00800810 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	05 00 00 00 30       	add    $0x30000000,%eax
  80081b:	c1 e8 0c             	shr    $0xc,%eax
}
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800823:	8b 45 08             	mov    0x8(%ebp),%eax
  800826:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80082b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800830:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800842:	89 c2                	mov    %eax,%edx
  800844:	c1 ea 16             	shr    $0x16,%edx
  800847:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80084e:	f6 c2 01             	test   $0x1,%dl
  800851:	74 11                	je     800864 <fd_alloc+0x2d>
  800853:	89 c2                	mov    %eax,%edx
  800855:	c1 ea 0c             	shr    $0xc,%edx
  800858:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80085f:	f6 c2 01             	test   $0x1,%dl
  800862:	75 09                	jne    80086d <fd_alloc+0x36>
			*fd_store = fd;
  800864:	89 01                	mov    %eax,(%ecx)
			return 0;
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
  80086b:	eb 17                	jmp    800884 <fd_alloc+0x4d>
  80086d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800872:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800877:	75 c9                	jne    800842 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800879:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80087f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80088c:	83 f8 1f             	cmp    $0x1f,%eax
  80088f:	77 36                	ja     8008c7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800891:	c1 e0 0c             	shl    $0xc,%eax
  800894:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800899:	89 c2                	mov    %eax,%edx
  80089b:	c1 ea 16             	shr    $0x16,%edx
  80089e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8008a5:	f6 c2 01             	test   $0x1,%dl
  8008a8:	74 24                	je     8008ce <fd_lookup+0x48>
  8008aa:	89 c2                	mov    %eax,%edx
  8008ac:	c1 ea 0c             	shr    $0xc,%edx
  8008af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8008b6:	f6 c2 01             	test   $0x1,%dl
  8008b9:	74 1a                	je     8008d5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8008bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008be:	89 02                	mov    %eax,(%edx)
	return 0;
  8008c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c5:	eb 13                	jmp    8008da <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8008c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008cc:	eb 0c                	jmp    8008da <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8008ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d3:	eb 05                	jmp    8008da <fd_lookup+0x54>
  8008d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	83 ec 18             	sub    $0x18,%esp
  8008e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e5:	ba d8 21 80 00       	mov    $0x8021d8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8008ea:	eb 13                	jmp    8008ff <dev_lookup+0x23>
  8008ec:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8008ef:	39 08                	cmp    %ecx,(%eax)
  8008f1:	75 0c                	jne    8008ff <dev_lookup+0x23>
			*dev = devtab[i];
  8008f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8008f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fd:	eb 30                	jmp    80092f <dev_lookup+0x53>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8008ff:	8b 02                	mov    (%edx),%eax
  800901:	85 c0                	test   %eax,%eax
  800903:	75 e7                	jne    8008ec <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800905:	a1 04 40 80 00       	mov    0x804004,%eax
  80090a:	8b 40 48             	mov    0x48(%eax),%eax
  80090d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800911:	89 44 24 04          	mov    %eax,0x4(%esp)
  800915:	c7 04 24 5c 21 80 00 	movl   $0x80215c,(%esp)
  80091c:	e8 5e 0d 00 00       	call   80167f <cprintf>
	*dev = 0;
  800921:	8b 45 0c             	mov    0xc(%ebp),%eax
  800924:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80092a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80092f:	c9                   	leave  
  800930:	c3                   	ret    

00800931 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	56                   	push   %esi
  800935:	53                   	push   %ebx
  800936:	83 ec 20             	sub    $0x20,%esp
  800939:	8b 75 08             	mov    0x8(%ebp),%esi
  80093c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80093f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800942:	89 44 24 04          	mov    %eax,0x4(%esp)
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800946:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80094c:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80094f:	89 04 24             	mov    %eax,(%esp)
  800952:	e8 2f ff ff ff       	call   800886 <fd_lookup>
  800957:	85 c0                	test   %eax,%eax
  800959:	78 05                	js     800960 <fd_close+0x2f>
	    || fd != fd2)
  80095b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80095e:	74 0c                	je     80096c <fd_close+0x3b>
		return (must_exist ? r : 0);
  800960:	84 db                	test   %bl,%bl
  800962:	ba 00 00 00 00       	mov    $0x0,%edx
  800967:	0f 44 c2             	cmove  %edx,%eax
  80096a:	eb 3f                	jmp    8009ab <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80096c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80096f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800973:	8b 06                	mov    (%esi),%eax
  800975:	89 04 24             	mov    %eax,(%esp)
  800978:	e8 5f ff ff ff       	call   8008dc <dev_lookup>
  80097d:	89 c3                	mov    %eax,%ebx
  80097f:	85 c0                	test   %eax,%eax
  800981:	78 16                	js     800999 <fd_close+0x68>
		if (dev->dev_close)
  800983:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800986:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800989:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80098e:	85 c0                	test   %eax,%eax
  800990:	74 07                	je     800999 <fd_close+0x68>
			r = (*dev->dev_close)(fd);
  800992:	89 34 24             	mov    %esi,(%esp)
  800995:	ff d0                	call   *%eax
  800997:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800999:	89 74 24 04          	mov    %esi,0x4(%esp)
  80099d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009a4:	e8 a1 fc ff ff       	call   80064a <sys_page_unmap>
	return r;
  8009a9:	89 d8                	mov    %ebx,%eax
}
  8009ab:	83 c4 20             	add    $0x20,%esp
  8009ae:	5b                   	pop    %ebx
  8009af:	5e                   	pop    %esi
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8009b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c2:	89 04 24             	mov    %eax,(%esp)
  8009c5:	e8 bc fe ff ff       	call   800886 <fd_lookup>
  8009ca:	89 c2                	mov    %eax,%edx
  8009cc:	85 d2                	test   %edx,%edx
  8009ce:	78 13                	js     8009e3 <close+0x31>
		return r;
	else
		return fd_close(fd, 1);
  8009d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8009d7:	00 
  8009d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009db:	89 04 24             	mov    %eax,(%esp)
  8009de:	e8 4e ff ff ff       	call   800931 <fd_close>
}
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <close_all>:

void
close_all(void)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	53                   	push   %ebx
  8009e9:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8009ec:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8009f1:	89 1c 24             	mov    %ebx,(%esp)
  8009f4:	e8 b9 ff ff ff       	call   8009b2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8009f9:	83 c3 01             	add    $0x1,%ebx
  8009fc:	83 fb 20             	cmp    $0x20,%ebx
  8009ff:	75 f0                	jne    8009f1 <close_all+0xc>
		close(i);
}
  800a01:	83 c4 14             	add    $0x14,%esp
  800a04:	5b                   	pop    %ebx
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	57                   	push   %edi
  800a0b:	56                   	push   %esi
  800a0c:	53                   	push   %ebx
  800a0d:	83 ec 3c             	sub    $0x3c,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800a10:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800a13:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a17:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1a:	89 04 24             	mov    %eax,(%esp)
  800a1d:	e8 64 fe ff ff       	call   800886 <fd_lookup>
  800a22:	89 c2                	mov    %eax,%edx
  800a24:	85 d2                	test   %edx,%edx
  800a26:	0f 88 e1 00 00 00    	js     800b0d <dup+0x106>
		return r;
	close(newfdnum);
  800a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2f:	89 04 24             	mov    %eax,(%esp)
  800a32:	e8 7b ff ff ff       	call   8009b2 <close>

	newfd = INDEX2FD(newfdnum);
  800a37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a3a:	c1 e3 0c             	shl    $0xc,%ebx
  800a3d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800a43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a46:	89 04 24             	mov    %eax,(%esp)
  800a49:	e8 d2 fd ff ff       	call   800820 <fd2data>
  800a4e:	89 c6                	mov    %eax,%esi
	nva = fd2data(newfd);
  800a50:	89 1c 24             	mov    %ebx,(%esp)
  800a53:	e8 c8 fd ff ff       	call   800820 <fd2data>
  800a58:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800a5a:	89 f0                	mov    %esi,%eax
  800a5c:	c1 e8 16             	shr    $0x16,%eax
  800a5f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a66:	a8 01                	test   $0x1,%al
  800a68:	74 43                	je     800aad <dup+0xa6>
  800a6a:	89 f0                	mov    %esi,%eax
  800a6c:	c1 e8 0c             	shr    $0xc,%eax
  800a6f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800a76:	f6 c2 01             	test   $0x1,%dl
  800a79:	74 32                	je     800aad <dup+0xa6>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a7b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a82:	25 07 0e 00 00       	and    $0xe07,%eax
  800a87:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a8b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800a8f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a96:	00 
  800a97:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800aa2:	e8 50 fb ff ff       	call   8005f7 <sys_page_map>
  800aa7:	89 c6                	mov    %eax,%esi
  800aa9:	85 c0                	test   %eax,%eax
  800aab:	78 3e                	js     800aeb <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800aad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ab0:	89 c2                	mov    %eax,%edx
  800ab2:	c1 ea 0c             	shr    $0xc,%edx
  800ab5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800abc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800ac2:	89 54 24 10          	mov    %edx,0x10(%esp)
  800ac6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800aca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ad1:	00 
  800ad2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800add:	e8 15 fb ff ff       	call   8005f7 <sys_page_map>
  800ae2:	89 c6                	mov    %eax,%esi
		goto err;

	return newfdnum;
  800ae4:	8b 45 0c             	mov    0xc(%ebp),%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ae7:	85 f6                	test   %esi,%esi
  800ae9:	79 22                	jns    800b0d <dup+0x106>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800aeb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800af6:	e8 4f fb ff ff       	call   80064a <sys_page_unmap>
	sys_page_unmap(0, nva);
  800afb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b06:	e8 3f fb ff ff       	call   80064a <sys_page_unmap>
	return r;
  800b0b:	89 f0                	mov    %esi,%eax
}
  800b0d:	83 c4 3c             	add    $0x3c,%esp
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5f                   	pop    %edi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	53                   	push   %ebx
  800b19:	83 ec 24             	sub    $0x24,%esp
  800b1c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b1f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b22:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b26:	89 1c 24             	mov    %ebx,(%esp)
  800b29:	e8 58 fd ff ff       	call   800886 <fd_lookup>
  800b2e:	89 c2                	mov    %eax,%edx
  800b30:	85 d2                	test   %edx,%edx
  800b32:	78 6d                	js     800ba1 <read+0x8c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b37:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b3e:	8b 00                	mov    (%eax),%eax
  800b40:	89 04 24             	mov    %eax,(%esp)
  800b43:	e8 94 fd ff ff       	call   8008dc <dev_lookup>
  800b48:	85 c0                	test   %eax,%eax
  800b4a:	78 55                	js     800ba1 <read+0x8c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800b4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b4f:	8b 50 08             	mov    0x8(%eax),%edx
  800b52:	83 e2 03             	and    $0x3,%edx
  800b55:	83 fa 01             	cmp    $0x1,%edx
  800b58:	75 23                	jne    800b7d <read+0x68>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800b5a:	a1 04 40 80 00       	mov    0x804004,%eax
  800b5f:	8b 40 48             	mov    0x48(%eax),%eax
  800b62:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b66:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b6a:	c7 04 24 9d 21 80 00 	movl   $0x80219d,(%esp)
  800b71:	e8 09 0b 00 00       	call   80167f <cprintf>
		return -E_INVAL;
  800b76:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b7b:	eb 24                	jmp    800ba1 <read+0x8c>
	}
	if (!dev->dev_read)
  800b7d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b80:	8b 52 08             	mov    0x8(%edx),%edx
  800b83:	85 d2                	test   %edx,%edx
  800b85:	74 15                	je     800b9c <read+0x87>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800b87:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b8a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800b8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b91:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800b95:	89 04 24             	mov    %eax,(%esp)
  800b98:	ff d2                	call   *%edx
  800b9a:	eb 05                	jmp    800ba1 <read+0x8c>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800b9c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800ba1:	83 c4 24             	add    $0x24,%esp
  800ba4:	5b                   	pop    %ebx
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	57                   	push   %edi
  800bab:	56                   	push   %esi
  800bac:	53                   	push   %ebx
  800bad:	83 ec 1c             	sub    $0x1c,%esp
  800bb0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bb3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800bb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bbb:	eb 23                	jmp    800be0 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800bbd:	89 f0                	mov    %esi,%eax
  800bbf:	29 d8                	sub    %ebx,%eax
  800bc1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bc5:	89 d8                	mov    %ebx,%eax
  800bc7:	03 45 0c             	add    0xc(%ebp),%eax
  800bca:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bce:	89 3c 24             	mov    %edi,(%esp)
  800bd1:	e8 3f ff ff ff       	call   800b15 <read>
		if (m < 0)
  800bd6:	85 c0                	test   %eax,%eax
  800bd8:	78 10                	js     800bea <readn+0x43>
			return m;
		if (m == 0)
  800bda:	85 c0                	test   %eax,%eax
  800bdc:	74 0a                	je     800be8 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800bde:	01 c3                	add    %eax,%ebx
  800be0:	39 f3                	cmp    %esi,%ebx
  800be2:	72 d9                	jb     800bbd <readn+0x16>
  800be4:	89 d8                	mov    %ebx,%eax
  800be6:	eb 02                	jmp    800bea <readn+0x43>
  800be8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800bea:	83 c4 1c             	add    $0x1c,%esp
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    

00800bf2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	53                   	push   %ebx
  800bf6:	83 ec 24             	sub    $0x24,%esp
  800bf9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800bfc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800bff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c03:	89 1c 24             	mov    %ebx,(%esp)
  800c06:	e8 7b fc ff ff       	call   800886 <fd_lookup>
  800c0b:	89 c2                	mov    %eax,%edx
  800c0d:	85 d2                	test   %edx,%edx
  800c0f:	78 68                	js     800c79 <write+0x87>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c14:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c18:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c1b:	8b 00                	mov    (%eax),%eax
  800c1d:	89 04 24             	mov    %eax,(%esp)
  800c20:	e8 b7 fc ff ff       	call   8008dc <dev_lookup>
  800c25:	85 c0                	test   %eax,%eax
  800c27:	78 50                	js     800c79 <write+0x87>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c2c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c30:	75 23                	jne    800c55 <write+0x63>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800c32:	a1 04 40 80 00       	mov    0x804004,%eax
  800c37:	8b 40 48             	mov    0x48(%eax),%eax
  800c3a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800c3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c42:	c7 04 24 b9 21 80 00 	movl   $0x8021b9,(%esp)
  800c49:	e8 31 0a 00 00       	call   80167f <cprintf>
		return -E_INVAL;
  800c4e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c53:	eb 24                	jmp    800c79 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800c55:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c58:	8b 52 0c             	mov    0xc(%edx),%edx
  800c5b:	85 d2                	test   %edx,%edx
  800c5d:	74 15                	je     800c74 <write+0x82>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800c5f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c62:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c69:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c6d:	89 04 24             	mov    %eax,(%esp)
  800c70:	ff d2                	call   *%edx
  800c72:	eb 05                	jmp    800c79 <write+0x87>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800c74:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800c79:	83 c4 24             	add    $0x24,%esp
  800c7c:	5b                   	pop    %ebx
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <seek>:

int
seek(int fdnum, off_t offset)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800c85:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800c88:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8f:	89 04 24             	mov    %eax,(%esp)
  800c92:	e8 ef fb ff ff       	call   800886 <fd_lookup>
  800c97:	85 c0                	test   %eax,%eax
  800c99:	78 0e                	js     800ca9 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800c9b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ca1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800ca4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ca9:	c9                   	leave  
  800caa:	c3                   	ret    

00800cab <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	53                   	push   %ebx
  800caf:	83 ec 24             	sub    $0x24,%esp
  800cb2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800cb5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800cb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cbc:	89 1c 24             	mov    %ebx,(%esp)
  800cbf:	e8 c2 fb ff ff       	call   800886 <fd_lookup>
  800cc4:	89 c2                	mov    %eax,%edx
  800cc6:	85 d2                	test   %edx,%edx
  800cc8:	78 61                	js     800d2b <ftruncate+0x80>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ccd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cd4:	8b 00                	mov    (%eax),%eax
  800cd6:	89 04 24             	mov    %eax,(%esp)
  800cd9:	e8 fe fb ff ff       	call   8008dc <dev_lookup>
  800cde:	85 c0                	test   %eax,%eax
  800ce0:	78 49                	js     800d2b <ftruncate+0x80>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800ce2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ce5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800ce9:	75 23                	jne    800d0e <ftruncate+0x63>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800ceb:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800cf0:	8b 40 48             	mov    0x48(%eax),%eax
  800cf3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800cf7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cfb:	c7 04 24 7c 21 80 00 	movl   $0x80217c,(%esp)
  800d02:	e8 78 09 00 00       	call   80167f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800d07:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d0c:	eb 1d                	jmp    800d2b <ftruncate+0x80>
	}
	if (!dev->dev_trunc)
  800d0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d11:	8b 52 18             	mov    0x18(%edx),%edx
  800d14:	85 d2                	test   %edx,%edx
  800d16:	74 0e                	je     800d26 <ftruncate+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d1f:	89 04 24             	mov    %eax,(%esp)
  800d22:	ff d2                	call   *%edx
  800d24:	eb 05                	jmp    800d2b <ftruncate+0x80>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800d26:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800d2b:	83 c4 24             	add    $0x24,%esp
  800d2e:	5b                   	pop    %ebx
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    

00800d31 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	53                   	push   %ebx
  800d35:	83 ec 24             	sub    $0x24,%esp
  800d38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d3b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d42:	8b 45 08             	mov    0x8(%ebp),%eax
  800d45:	89 04 24             	mov    %eax,(%esp)
  800d48:	e8 39 fb ff ff       	call   800886 <fd_lookup>
  800d4d:	89 c2                	mov    %eax,%edx
  800d4f:	85 d2                	test   %edx,%edx
  800d51:	78 52                	js     800da5 <fstat+0x74>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d56:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d5d:	8b 00                	mov    (%eax),%eax
  800d5f:	89 04 24             	mov    %eax,(%esp)
  800d62:	e8 75 fb ff ff       	call   8008dc <dev_lookup>
  800d67:	85 c0                	test   %eax,%eax
  800d69:	78 3a                	js     800da5 <fstat+0x74>
		return r;
	if (!dev->dev_stat)
  800d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d6e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800d72:	74 2c                	je     800da0 <fstat+0x6f>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800d74:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800d77:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800d7e:	00 00 00 
	stat->st_isdir = 0;
  800d81:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800d88:	00 00 00 
	stat->st_dev = dev;
  800d8b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800d91:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d95:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800d98:	89 14 24             	mov    %edx,(%esp)
  800d9b:	ff 50 14             	call   *0x14(%eax)
  800d9e:	eb 05                	jmp    800da5 <fstat+0x74>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800da0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800da5:	83 c4 24             	add    $0x24,%esp
  800da8:	5b                   	pop    %ebx
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
  800db0:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800db3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800dba:	00 
  800dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbe:	89 04 24             	mov    %eax,(%esp)
  800dc1:	e8 fb 01 00 00       	call   800fc1 <open>
  800dc6:	89 c3                	mov    %eax,%ebx
  800dc8:	85 db                	test   %ebx,%ebx
  800dca:	78 1b                	js     800de7 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  800dcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dcf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dd3:	89 1c 24             	mov    %ebx,(%esp)
  800dd6:	e8 56 ff ff ff       	call   800d31 <fstat>
  800ddb:	89 c6                	mov    %eax,%esi
	close(fd);
  800ddd:	89 1c 24             	mov    %ebx,(%esp)
  800de0:	e8 cd fb ff ff       	call   8009b2 <close>
	return r;
  800de5:	89 f0                	mov    %esi,%eax
}
  800de7:	83 c4 10             	add    $0x10,%esp
  800dea:	5b                   	pop    %ebx
  800deb:	5e                   	pop    %esi
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    

00800dee <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	56                   	push   %esi
  800df2:	53                   	push   %ebx
  800df3:	83 ec 10             	sub    $0x10,%esp
  800df6:	89 c6                	mov    %eax,%esi
  800df8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800dfa:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800e01:	75 11                	jne    800e14 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800e03:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800e0a:	e8 fe 0f 00 00       	call   801e0d <ipc_find_env>
  800e0f:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800e14:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800e1b:	00 
  800e1c:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800e23:	00 
  800e24:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e28:	a1 00 40 80 00       	mov    0x804000,%eax
  800e2d:	89 04 24             	mov    %eax,(%esp)
  800e30:	e8 29 0f 00 00       	call   801d5e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800e35:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e3c:	00 
  800e3d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e48:	e8 73 0e 00 00       	call   801cc0 <ipc_recv>
}
  800e4d:	83 c4 10             	add    $0x10,%esp
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5d:	8b 40 0c             	mov    0xc(%eax),%eax
  800e60:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800e65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e68:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800e6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e72:	b8 02 00 00 00       	mov    $0x2,%eax
  800e77:	e8 72 ff ff ff       	call   800dee <fsipc>
}
  800e7c:	c9                   	leave  
  800e7d:	c3                   	ret    

00800e7e <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800e84:	8b 45 08             	mov    0x8(%ebp),%eax
  800e87:	8b 40 0c             	mov    0xc(%eax),%eax
  800e8a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800e8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e94:	b8 06 00 00 00       	mov    $0x6,%eax
  800e99:	e8 50 ff ff ff       	call   800dee <fsipc>
}
  800e9e:	c9                   	leave  
  800e9f:	c3                   	ret    

00800ea0 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	53                   	push   %ebx
  800ea4:	83 ec 14             	sub    $0x14,%esp
  800ea7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800eaa:	8b 45 08             	mov    0x8(%ebp),%eax
  800ead:	8b 40 0c             	mov    0xc(%eax),%eax
  800eb0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800eb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800eba:	b8 05 00 00 00       	mov    $0x5,%eax
  800ebf:	e8 2a ff ff ff       	call   800dee <fsipc>
  800ec4:	89 c2                	mov    %eax,%edx
  800ec6:	85 d2                	test   %edx,%edx
  800ec8:	78 2b                	js     800ef5 <devfile_stat+0x55>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800eca:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ed1:	00 
  800ed2:	89 1c 24             	mov    %ebx,(%esp)
  800ed5:	e8 ad f2 ff ff       	call   800187 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800eda:	a1 80 50 80 00       	mov    0x805080,%eax
  800edf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ee5:	a1 84 50 80 00       	mov    0x805084,%eax
  800eea:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800ef0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ef5:	83 c4 14             	add    $0x14,%esp
  800ef8:	5b                   	pop    %ebx
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  800f01:	c7 44 24 08 e8 21 80 	movl   $0x8021e8,0x8(%esp)
  800f08:	00 
  800f09:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  800f10:	00 
  800f11:	c7 04 24 06 22 80 00 	movl   $0x802206,(%esp)
  800f18:	e8 69 06 00 00       	call   801586 <_panic>

00800f1d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800f1d:	55                   	push   %ebp
  800f1e:	89 e5                	mov    %esp,%ebp
  800f20:	56                   	push   %esi
  800f21:	53                   	push   %ebx
  800f22:	83 ec 10             	sub    $0x10,%esp
  800f25:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800f28:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2b:	8b 40 0c             	mov    0xc(%eax),%eax
  800f2e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800f33:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800f39:	ba 00 00 00 00       	mov    $0x0,%edx
  800f3e:	b8 03 00 00 00       	mov    $0x3,%eax
  800f43:	e8 a6 fe ff ff       	call   800dee <fsipc>
  800f48:	89 c3                	mov    %eax,%ebx
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	78 6a                	js     800fb8 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800f4e:	39 c6                	cmp    %eax,%esi
  800f50:	73 24                	jae    800f76 <devfile_read+0x59>
  800f52:	c7 44 24 0c 11 22 80 	movl   $0x802211,0xc(%esp)
  800f59:	00 
  800f5a:	c7 44 24 08 18 22 80 	movl   $0x802218,0x8(%esp)
  800f61:	00 
  800f62:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800f69:	00 
  800f6a:	c7 04 24 06 22 80 00 	movl   $0x802206,(%esp)
  800f71:	e8 10 06 00 00       	call   801586 <_panic>
	assert(r <= PGSIZE);
  800f76:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800f7b:	7e 24                	jle    800fa1 <devfile_read+0x84>
  800f7d:	c7 44 24 0c 2d 22 80 	movl   $0x80222d,0xc(%esp)
  800f84:	00 
  800f85:	c7 44 24 08 18 22 80 	movl   $0x802218,0x8(%esp)
  800f8c:	00 
  800f8d:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800f94:	00 
  800f95:	c7 04 24 06 22 80 00 	movl   $0x802206,(%esp)
  800f9c:	e8 e5 05 00 00       	call   801586 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800fa1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fa5:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800fac:	00 
  800fad:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb0:	89 04 24             	mov    %eax,(%esp)
  800fb3:	e8 6c f3 ff ff       	call   800324 <memmove>
	return r;
}
  800fb8:	89 d8                	mov    %ebx,%eax
  800fba:	83 c4 10             	add    $0x10,%esp
  800fbd:	5b                   	pop    %ebx
  800fbe:	5e                   	pop    %esi
  800fbf:	5d                   	pop    %ebp
  800fc0:	c3                   	ret    

00800fc1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800fc1:	55                   	push   %ebp
  800fc2:	89 e5                	mov    %esp,%ebp
  800fc4:	53                   	push   %ebx
  800fc5:	83 ec 24             	sub    $0x24,%esp
  800fc8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800fcb:	89 1c 24             	mov    %ebx,(%esp)
  800fce:	e8 7d f1 ff ff       	call   800150 <strlen>
  800fd3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800fd8:	7f 60                	jg     80103a <open+0x79>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800fda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdd:	89 04 24             	mov    %eax,(%esp)
  800fe0:	e8 52 f8 ff ff       	call   800837 <fd_alloc>
  800fe5:	89 c2                	mov    %eax,%edx
  800fe7:	85 d2                	test   %edx,%edx
  800fe9:	78 54                	js     80103f <open+0x7e>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800feb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fef:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800ff6:	e8 8c f1 ff ff       	call   800187 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ffb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffe:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801003:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801006:	b8 01 00 00 00       	mov    $0x1,%eax
  80100b:	e8 de fd ff ff       	call   800dee <fsipc>
  801010:	89 c3                	mov    %eax,%ebx
  801012:	85 c0                	test   %eax,%eax
  801014:	79 17                	jns    80102d <open+0x6c>
		fd_close(fd, 0);
  801016:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80101d:	00 
  80101e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801021:	89 04 24             	mov    %eax,(%esp)
  801024:	e8 08 f9 ff ff       	call   800931 <fd_close>
		return r;
  801029:	89 d8                	mov    %ebx,%eax
  80102b:	eb 12                	jmp    80103f <open+0x7e>
	}

	return fd2num(fd);
  80102d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801030:	89 04 24             	mov    %eax,(%esp)
  801033:	e8 d8 f7 ff ff       	call   800810 <fd2num>
  801038:	eb 05                	jmp    80103f <open+0x7e>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80103a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80103f:	83 c4 24             	add    $0x24,%esp
  801042:	5b                   	pop    %ebx
  801043:	5d                   	pop    %ebp
  801044:	c3                   	ret    

00801045 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80104b:	ba 00 00 00 00       	mov    $0x0,%edx
  801050:	b8 08 00 00 00       	mov    $0x8,%eax
  801055:	e8 94 fd ff ff       	call   800dee <fsipc>
}
  80105a:	c9                   	leave  
  80105b:	c3                   	ret    

0080105c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	56                   	push   %esi
  801060:	53                   	push   %ebx
  801061:	83 ec 10             	sub    $0x10,%esp
  801064:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801067:	8b 45 08             	mov    0x8(%ebp),%eax
  80106a:	89 04 24             	mov    %eax,(%esp)
  80106d:	e8 ae f7 ff ff       	call   800820 <fd2data>
  801072:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801074:	c7 44 24 04 39 22 80 	movl   $0x802239,0x4(%esp)
  80107b:	00 
  80107c:	89 1c 24             	mov    %ebx,(%esp)
  80107f:	e8 03 f1 ff ff       	call   800187 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801084:	8b 46 04             	mov    0x4(%esi),%eax
  801087:	2b 06                	sub    (%esi),%eax
  801089:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80108f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801096:	00 00 00 
	stat->st_dev = &devpipe;
  801099:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8010a0:	30 80 00 
	return 0;
}
  8010a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a8:	83 c4 10             	add    $0x10,%esp
  8010ab:	5b                   	pop    %ebx
  8010ac:	5e                   	pop    %esi
  8010ad:	5d                   	pop    %ebp
  8010ae:	c3                   	ret    

008010af <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8010af:	55                   	push   %ebp
  8010b0:	89 e5                	mov    %esp,%ebp
  8010b2:	53                   	push   %ebx
  8010b3:	83 ec 14             	sub    $0x14,%esp
  8010b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8010b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010c4:	e8 81 f5 ff ff       	call   80064a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8010c9:	89 1c 24             	mov    %ebx,(%esp)
  8010cc:	e8 4f f7 ff ff       	call   800820 <fd2data>
  8010d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010dc:	e8 69 f5 ff ff       	call   80064a <sys_page_unmap>
}
  8010e1:	83 c4 14             	add    $0x14,%esp
  8010e4:	5b                   	pop    %ebx
  8010e5:	5d                   	pop    %ebp
  8010e6:	c3                   	ret    

008010e7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	57                   	push   %edi
  8010eb:	56                   	push   %esi
  8010ec:	53                   	push   %ebx
  8010ed:	83 ec 2c             	sub    $0x2c,%esp
  8010f0:	89 c6                	mov    %eax,%esi
  8010f2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8010f5:	a1 04 40 80 00       	mov    0x804004,%eax
  8010fa:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8010fd:	89 34 24             	mov    %esi,(%esp)
  801100:	e8 40 0d 00 00       	call   801e45 <pageref>
  801105:	89 c7                	mov    %eax,%edi
  801107:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80110a:	89 04 24             	mov    %eax,(%esp)
  80110d:	e8 33 0d 00 00       	call   801e45 <pageref>
  801112:	39 c7                	cmp    %eax,%edi
  801114:	0f 94 c2             	sete   %dl
  801117:	0f b6 c2             	movzbl %dl,%eax
		nn = thisenv->env_runs;
  80111a:	8b 0d 04 40 80 00    	mov    0x804004,%ecx
  801120:	8b 79 58             	mov    0x58(%ecx),%edi
		if (n == nn)
  801123:	39 fb                	cmp    %edi,%ebx
  801125:	74 21                	je     801148 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801127:	84 d2                	test   %dl,%dl
  801129:	74 ca                	je     8010f5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80112b:	8b 51 58             	mov    0x58(%ecx),%edx
  80112e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801132:	89 54 24 08          	mov    %edx,0x8(%esp)
  801136:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80113a:	c7 04 24 40 22 80 00 	movl   $0x802240,(%esp)
  801141:	e8 39 05 00 00       	call   80167f <cprintf>
  801146:	eb ad                	jmp    8010f5 <_pipeisclosed+0xe>
	}
}
  801148:	83 c4 2c             	add    $0x2c,%esp
  80114b:	5b                   	pop    %ebx
  80114c:	5e                   	pop    %esi
  80114d:	5f                   	pop    %edi
  80114e:	5d                   	pop    %ebp
  80114f:	c3                   	ret    

00801150 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	57                   	push   %edi
  801154:	56                   	push   %esi
  801155:	53                   	push   %ebx
  801156:	83 ec 1c             	sub    $0x1c,%esp
  801159:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80115c:	89 34 24             	mov    %esi,(%esp)
  80115f:	e8 bc f6 ff ff       	call   800820 <fd2data>
  801164:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801166:	bf 00 00 00 00       	mov    $0x0,%edi
  80116b:	eb 45                	jmp    8011b2 <devpipe_write+0x62>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80116d:	89 da                	mov    %ebx,%edx
  80116f:	89 f0                	mov    %esi,%eax
  801171:	e8 71 ff ff ff       	call   8010e7 <_pipeisclosed>
  801176:	85 c0                	test   %eax,%eax
  801178:	75 41                	jne    8011bb <devpipe_write+0x6b>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80117a:	e8 05 f4 ff ff       	call   800584 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80117f:	8b 43 04             	mov    0x4(%ebx),%eax
  801182:	8b 0b                	mov    (%ebx),%ecx
  801184:	8d 51 20             	lea    0x20(%ecx),%edx
  801187:	39 d0                	cmp    %edx,%eax
  801189:	73 e2                	jae    80116d <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80118b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80118e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801192:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801195:	99                   	cltd   
  801196:	c1 ea 1b             	shr    $0x1b,%edx
  801199:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
  80119c:	83 e1 1f             	and    $0x1f,%ecx
  80119f:	29 d1                	sub    %edx,%ecx
  8011a1:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
  8011a5:	88 54 0b 08          	mov    %dl,0x8(%ebx,%ecx,1)
		p->p_wpos++;
  8011a9:	83 c0 01             	add    $0x1,%eax
  8011ac:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011af:	83 c7 01             	add    $0x1,%edi
  8011b2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8011b5:	75 c8                	jne    80117f <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8011b7:	89 f8                	mov    %edi,%eax
  8011b9:	eb 05                	jmp    8011c0 <devpipe_write+0x70>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011bb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8011c0:	83 c4 1c             	add    $0x1c,%esp
  8011c3:	5b                   	pop    %ebx
  8011c4:	5e                   	pop    %esi
  8011c5:	5f                   	pop    %edi
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    

008011c8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	57                   	push   %edi
  8011cc:	56                   	push   %esi
  8011cd:	53                   	push   %ebx
  8011ce:	83 ec 1c             	sub    $0x1c,%esp
  8011d1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8011d4:	89 3c 24             	mov    %edi,(%esp)
  8011d7:	e8 44 f6 ff ff       	call   800820 <fd2data>
  8011dc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011de:	be 00 00 00 00       	mov    $0x0,%esi
  8011e3:	eb 3d                	jmp    801222 <devpipe_read+0x5a>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8011e5:	85 f6                	test   %esi,%esi
  8011e7:	74 04                	je     8011ed <devpipe_read+0x25>
				return i;
  8011e9:	89 f0                	mov    %esi,%eax
  8011eb:	eb 43                	jmp    801230 <devpipe_read+0x68>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8011ed:	89 da                	mov    %ebx,%edx
  8011ef:	89 f8                	mov    %edi,%eax
  8011f1:	e8 f1 fe ff ff       	call   8010e7 <_pipeisclosed>
  8011f6:	85 c0                	test   %eax,%eax
  8011f8:	75 31                	jne    80122b <devpipe_read+0x63>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011fa:	e8 85 f3 ff ff       	call   800584 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011ff:	8b 03                	mov    (%ebx),%eax
  801201:	3b 43 04             	cmp    0x4(%ebx),%eax
  801204:	74 df                	je     8011e5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801206:	99                   	cltd   
  801207:	c1 ea 1b             	shr    $0x1b,%edx
  80120a:	01 d0                	add    %edx,%eax
  80120c:	83 e0 1f             	and    $0x1f,%eax
  80120f:	29 d0                	sub    %edx,%eax
  801211:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801216:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801219:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80121c:	83 03 01             	addl   $0x1,(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80121f:	83 c6 01             	add    $0x1,%esi
  801222:	3b 75 10             	cmp    0x10(%ebp),%esi
  801225:	75 d8                	jne    8011ff <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801227:	89 f0                	mov    %esi,%eax
  801229:	eb 05                	jmp    801230 <devpipe_read+0x68>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80122b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801230:	83 c4 1c             	add    $0x1c,%esp
  801233:	5b                   	pop    %ebx
  801234:	5e                   	pop    %esi
  801235:	5f                   	pop    %edi
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    

00801238 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	56                   	push   %esi
  80123c:	53                   	push   %ebx
  80123d:	83 ec 30             	sub    $0x30,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801240:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801243:	89 04 24             	mov    %eax,(%esp)
  801246:	e8 ec f5 ff ff       	call   800837 <fd_alloc>
  80124b:	89 c2                	mov    %eax,%edx
  80124d:	85 d2                	test   %edx,%edx
  80124f:	0f 88 4d 01 00 00    	js     8013a2 <pipe+0x16a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801255:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80125c:	00 
  80125d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801260:	89 44 24 04          	mov    %eax,0x4(%esp)
  801264:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80126b:	e8 33 f3 ff ff       	call   8005a3 <sys_page_alloc>
  801270:	89 c2                	mov    %eax,%edx
  801272:	85 d2                	test   %edx,%edx
  801274:	0f 88 28 01 00 00    	js     8013a2 <pipe+0x16a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80127a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80127d:	89 04 24             	mov    %eax,(%esp)
  801280:	e8 b2 f5 ff ff       	call   800837 <fd_alloc>
  801285:	89 c3                	mov    %eax,%ebx
  801287:	85 c0                	test   %eax,%eax
  801289:	0f 88 fe 00 00 00    	js     80138d <pipe+0x155>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80128f:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801296:	00 
  801297:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012a5:	e8 f9 f2 ff ff       	call   8005a3 <sys_page_alloc>
  8012aa:	89 c3                	mov    %eax,%ebx
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	0f 88 d9 00 00 00    	js     80138d <pipe+0x155>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8012b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b7:	89 04 24             	mov    %eax,(%esp)
  8012ba:	e8 61 f5 ff ff       	call   800820 <fd2data>
  8012bf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012c1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8012c8:	00 
  8012c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012d4:	e8 ca f2 ff ff       	call   8005a3 <sys_page_alloc>
  8012d9:	89 c3                	mov    %eax,%ebx
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	0f 88 97 00 00 00    	js     80137a <pipe+0x142>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e6:	89 04 24             	mov    %eax,(%esp)
  8012e9:	e8 32 f5 ff ff       	call   800820 <fd2data>
  8012ee:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8012f5:	00 
  8012f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012fa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801301:	00 
  801302:	89 74 24 04          	mov    %esi,0x4(%esp)
  801306:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80130d:	e8 e5 f2 ff ff       	call   8005f7 <sys_page_map>
  801312:	89 c3                	mov    %eax,%ebx
  801314:	85 c0                	test   %eax,%eax
  801316:	78 52                	js     80136a <pipe+0x132>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801318:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80131e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801321:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801323:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801326:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80132d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801333:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801336:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801338:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801342:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801345:	89 04 24             	mov    %eax,(%esp)
  801348:	e8 c3 f4 ff ff       	call   800810 <fd2num>
  80134d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801350:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801352:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801355:	89 04 24             	mov    %eax,(%esp)
  801358:	e8 b3 f4 ff ff       	call   800810 <fd2num>
  80135d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801360:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801363:	b8 00 00 00 00       	mov    $0x0,%eax
  801368:	eb 38                	jmp    8013a2 <pipe+0x16a>

    err3:
	sys_page_unmap(0, va);
  80136a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80136e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801375:	e8 d0 f2 ff ff       	call   80064a <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80137a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801381:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801388:	e8 bd f2 ff ff       	call   80064a <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80138d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801390:	89 44 24 04          	mov    %eax,0x4(%esp)
  801394:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80139b:	e8 aa f2 ff ff       	call   80064a <sys_page_unmap>
  8013a0:	89 d8                	mov    %ebx,%eax
    err:
	return r;
}
  8013a2:	83 c4 30             	add    $0x30,%esp
  8013a5:	5b                   	pop    %ebx
  8013a6:	5e                   	pop    %esi
  8013a7:	5d                   	pop    %ebp
  8013a8:	c3                   	ret    

008013a9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8013a9:	55                   	push   %ebp
  8013aa:	89 e5                	mov    %esp,%ebp
  8013ac:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b9:	89 04 24             	mov    %eax,(%esp)
  8013bc:	e8 c5 f4 ff ff       	call   800886 <fd_lookup>
  8013c1:	89 c2                	mov    %eax,%edx
  8013c3:	85 d2                	test   %edx,%edx
  8013c5:	78 15                	js     8013dc <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8013c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ca:	89 04 24             	mov    %eax,(%esp)
  8013cd:	e8 4e f4 ff ff       	call   800820 <fd2data>
	return _pipeisclosed(fd, p);
  8013d2:	89 c2                	mov    %eax,%edx
  8013d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d7:	e8 0b fd ff ff       	call   8010e7 <_pipeisclosed>
}
  8013dc:	c9                   	leave  
  8013dd:	c3                   	ret    
  8013de:	66 90                	xchg   %ax,%ax

008013e0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8013e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8013e8:	5d                   	pop    %ebp
  8013e9:	c3                   	ret    

008013ea <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
  8013ed:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8013f0:	c7 44 24 04 58 22 80 	movl   $0x802258,0x4(%esp)
  8013f7:	00 
  8013f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013fb:	89 04 24             	mov    %eax,(%esp)
  8013fe:	e8 84 ed ff ff       	call   800187 <strcpy>
	return 0;
}
  801403:	b8 00 00 00 00       	mov    $0x0,%eax
  801408:	c9                   	leave  
  801409:	c3                   	ret    

0080140a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	57                   	push   %edi
  80140e:	56                   	push   %esi
  80140f:	53                   	push   %ebx
  801410:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801416:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80141b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801421:	eb 31                	jmp    801454 <devcons_write+0x4a>
		m = n - tot;
  801423:	8b 75 10             	mov    0x10(%ebp),%esi
  801426:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801428:	83 fe 7f             	cmp    $0x7f,%esi
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80142b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801430:	0f 47 f2             	cmova  %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801433:	89 74 24 08          	mov    %esi,0x8(%esp)
  801437:	03 45 0c             	add    0xc(%ebp),%eax
  80143a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80143e:	89 3c 24             	mov    %edi,(%esp)
  801441:	e8 de ee ff ff       	call   800324 <memmove>
		sys_cputs(buf, m);
  801446:	89 74 24 04          	mov    %esi,0x4(%esp)
  80144a:	89 3c 24             	mov    %edi,(%esp)
  80144d:	e8 84 f0 ff ff       	call   8004d6 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801452:	01 f3                	add    %esi,%ebx
  801454:	89 d8                	mov    %ebx,%eax
  801456:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801459:	72 c8                	jb     801423 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80145b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801461:	5b                   	pop    %ebx
  801462:	5e                   	pop    %esi
  801463:	5f                   	pop    %edi
  801464:	5d                   	pop    %ebp
  801465:	c3                   	ret    

00801466 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80146c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801471:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801475:	75 07                	jne    80147e <devcons_read+0x18>
  801477:	eb 2a                	jmp    8014a3 <devcons_read+0x3d>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801479:	e8 06 f1 ff ff       	call   800584 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80147e:	66 90                	xchg   %ax,%ax
  801480:	e8 6f f0 ff ff       	call   8004f4 <sys_cgetc>
  801485:	85 c0                	test   %eax,%eax
  801487:	74 f0                	je     801479 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801489:	85 c0                	test   %eax,%eax
  80148b:	78 16                	js     8014a3 <devcons_read+0x3d>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80148d:	83 f8 04             	cmp    $0x4,%eax
  801490:	74 0c                	je     80149e <devcons_read+0x38>
		return 0;
	*(char*)vbuf = c;
  801492:	8b 55 0c             	mov    0xc(%ebp),%edx
  801495:	88 02                	mov    %al,(%edx)
	return 1;
  801497:	b8 01 00 00 00       	mov    $0x1,%eax
  80149c:	eb 05                	jmp    8014a3 <devcons_read+0x3d>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80149e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8014a3:	c9                   	leave  
  8014a4:	c3                   	ret    

008014a5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8014a5:	55                   	push   %ebp
  8014a6:	89 e5                	mov    %esp,%ebp
  8014a8:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8014ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ae:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8014b1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014b8:	00 
  8014b9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014bc:	89 04 24             	mov    %eax,(%esp)
  8014bf:	e8 12 f0 ff ff       	call   8004d6 <sys_cputs>
}
  8014c4:	c9                   	leave  
  8014c5:	c3                   	ret    

008014c6 <getchar>:

int
getchar(void)
{
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
  8014c9:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8014cc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8014d3:	00 
  8014d4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8014d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014e2:	e8 2e f6 ff ff       	call   800b15 <read>
	if (r < 0)
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	78 0f                	js     8014fa <getchar+0x34>
		return r;
	if (r < 1)
  8014eb:	85 c0                	test   %eax,%eax
  8014ed:	7e 06                	jle    8014f5 <getchar+0x2f>
		return -E_EOF;
	return c;
  8014ef:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8014f3:	eb 05                	jmp    8014fa <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8014f5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8014fa:	c9                   	leave  
  8014fb:	c3                   	ret    

008014fc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801502:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801505:	89 44 24 04          	mov    %eax,0x4(%esp)
  801509:	8b 45 08             	mov    0x8(%ebp),%eax
  80150c:	89 04 24             	mov    %eax,(%esp)
  80150f:	e8 72 f3 ff ff       	call   800886 <fd_lookup>
  801514:	85 c0                	test   %eax,%eax
  801516:	78 11                	js     801529 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801518:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801521:	39 10                	cmp    %edx,(%eax)
  801523:	0f 94 c0             	sete   %al
  801526:	0f b6 c0             	movzbl %al,%eax
}
  801529:	c9                   	leave  
  80152a:	c3                   	ret    

0080152b <opencons>:

int
opencons(void)
{
  80152b:	55                   	push   %ebp
  80152c:	89 e5                	mov    %esp,%ebp
  80152e:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801531:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801534:	89 04 24             	mov    %eax,(%esp)
  801537:	e8 fb f2 ff ff       	call   800837 <fd_alloc>
		return r;
  80153c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80153e:	85 c0                	test   %eax,%eax
  801540:	78 40                	js     801582 <opencons+0x57>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801542:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801549:	00 
  80154a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801551:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801558:	e8 46 f0 ff ff       	call   8005a3 <sys_page_alloc>
		return r;
  80155d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80155f:	85 c0                	test   %eax,%eax
  801561:	78 1f                	js     801582 <opencons+0x57>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801563:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801569:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80156c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80156e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801571:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801578:	89 04 24             	mov    %eax,(%esp)
  80157b:	e8 90 f2 ff ff       	call   800810 <fd2num>
  801580:	89 c2                	mov    %eax,%edx
}
  801582:	89 d0                	mov    %edx,%eax
  801584:	c9                   	leave  
  801585:	c3                   	ret    

00801586 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801586:	55                   	push   %ebp
  801587:	89 e5                	mov    %esp,%ebp
  801589:	56                   	push   %esi
  80158a:	53                   	push   %ebx
  80158b:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80158e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801591:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801597:	e8 c9 ef ff ff       	call   800565 <sys_getenvid>
  80159c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80159f:	89 54 24 10          	mov    %edx,0x10(%esp)
  8015a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8015a6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8015aa:	89 74 24 08          	mov    %esi,0x8(%esp)
  8015ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b2:	c7 04 24 64 22 80 00 	movl   $0x802264,(%esp)
  8015b9:	e8 c1 00 00 00       	call   80167f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8015c5:	89 04 24             	mov    %eax,(%esp)
  8015c8:	e8 51 00 00 00       	call   80161e <vcprintf>
	cprintf("\n");
  8015cd:	c7 04 24 51 22 80 00 	movl   $0x802251,(%esp)
  8015d4:	e8 a6 00 00 00       	call   80167f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8015d9:	cc                   	int3   
  8015da:	eb fd                	jmp    8015d9 <_panic+0x53>

008015dc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	53                   	push   %ebx
  8015e0:	83 ec 14             	sub    $0x14,%esp
  8015e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8015e6:	8b 13                	mov    (%ebx),%edx
  8015e8:	8d 42 01             	lea    0x1(%edx),%eax
  8015eb:	89 03                	mov    %eax,(%ebx)
  8015ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015f0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8015f4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8015f9:	75 19                	jne    801614 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8015fb:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801602:	00 
  801603:	8d 43 08             	lea    0x8(%ebx),%eax
  801606:	89 04 24             	mov    %eax,(%esp)
  801609:	e8 c8 ee ff ff       	call   8004d6 <sys_cputs>
		b->idx = 0;
  80160e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801614:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801618:	83 c4 14             	add    $0x14,%esp
  80161b:	5b                   	pop    %ebx
  80161c:	5d                   	pop    %ebp
  80161d:	c3                   	ret    

0080161e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801627:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80162e:	00 00 00 
	b.cnt = 0;
  801631:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801638:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80163b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80163e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801642:	8b 45 08             	mov    0x8(%ebp),%eax
  801645:	89 44 24 08          	mov    %eax,0x8(%esp)
  801649:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80164f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801653:	c7 04 24 dc 15 80 00 	movl   $0x8015dc,(%esp)
  80165a:	e8 75 01 00 00       	call   8017d4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80165f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801665:	89 44 24 04          	mov    %eax,0x4(%esp)
  801669:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80166f:	89 04 24             	mov    %eax,(%esp)
  801672:	e8 5f ee ff ff       	call   8004d6 <sys_cputs>

	return b.cnt;
}
  801677:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80167d:	c9                   	leave  
  80167e:	c3                   	ret    

0080167f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801685:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801688:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168c:	8b 45 08             	mov    0x8(%ebp),%eax
  80168f:	89 04 24             	mov    %eax,(%esp)
  801692:	e8 87 ff ff ff       	call   80161e <vcprintf>
	va_end(ap);

	return cnt;
}
  801697:	c9                   	leave  
  801698:	c3                   	ret    
  801699:	66 90                	xchg   %ax,%ax
  80169b:	66 90                	xchg   %ax,%ax
  80169d:	66 90                	xchg   %ax,%ax
  80169f:	90                   	nop

008016a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	57                   	push   %edi
  8016a4:	56                   	push   %esi
  8016a5:	53                   	push   %ebx
  8016a6:	83 ec 3c             	sub    $0x3c,%esp
  8016a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016ac:	89 d7                	mov    %edx,%edi
  8016ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b7:	89 c3                	mov    %eax,%ebx
  8016b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8016bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8016bf:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8016ca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8016cd:	39 d9                	cmp    %ebx,%ecx
  8016cf:	72 05                	jb     8016d6 <printnum+0x36>
  8016d1:	3b 45 e0             	cmp    -0x20(%ebp),%eax
  8016d4:	77 69                	ja     80173f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8016d6:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8016d9:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8016dd:	83 ee 01             	sub    $0x1,%esi
  8016e0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8016e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016e8:	8b 44 24 08          	mov    0x8(%esp),%eax
  8016ec:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8016f0:	89 c3                	mov    %eax,%ebx
  8016f2:	89 d6                	mov    %edx,%esi
  8016f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8016f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8016fa:	89 54 24 08          	mov    %edx,0x8(%esp)
  8016fe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801702:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801705:	89 04 24             	mov    %eax,(%esp)
  801708:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80170b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170f:	e8 6c 07 00 00       	call   801e80 <__udivdi3>
  801714:	89 d9                	mov    %ebx,%ecx
  801716:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80171a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80171e:	89 04 24             	mov    %eax,(%esp)
  801721:	89 54 24 04          	mov    %edx,0x4(%esp)
  801725:	89 fa                	mov    %edi,%edx
  801727:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80172a:	e8 71 ff ff ff       	call   8016a0 <printnum>
  80172f:	eb 1b                	jmp    80174c <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801731:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801735:	8b 45 18             	mov    0x18(%ebp),%eax
  801738:	89 04 24             	mov    %eax,(%esp)
  80173b:	ff d3                	call   *%ebx
  80173d:	eb 03                	jmp    801742 <printnum+0xa2>
  80173f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801742:	83 ee 01             	sub    $0x1,%esi
  801745:	85 f6                	test   %esi,%esi
  801747:	7f e8                	jg     801731 <printnum+0x91>
  801749:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80174c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801750:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801754:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801757:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80175a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80175e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801762:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801765:	89 04 24             	mov    %eax,(%esp)
  801768:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80176b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80176f:	e8 3c 08 00 00       	call   801fb0 <__umoddi3>
  801774:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801778:	0f be 80 87 22 80 00 	movsbl 0x802287(%eax),%eax
  80177f:	89 04 24             	mov    %eax,(%esp)
  801782:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801785:	ff d0                	call   *%eax
}
  801787:	83 c4 3c             	add    $0x3c,%esp
  80178a:	5b                   	pop    %ebx
  80178b:	5e                   	pop    %esi
  80178c:	5f                   	pop    %edi
  80178d:	5d                   	pop    %ebp
  80178e:	c3                   	ret    

0080178f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801795:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801799:	8b 10                	mov    (%eax),%edx
  80179b:	3b 50 04             	cmp    0x4(%eax),%edx
  80179e:	73 0a                	jae    8017aa <sprintputch+0x1b>
		*b->buf++ = ch;
  8017a0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8017a3:	89 08                	mov    %ecx,(%eax)
  8017a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a8:	88 02                	mov    %al,(%edx)
}
  8017aa:	5d                   	pop    %ebp
  8017ab:	c3                   	ret    

008017ac <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017ac:	55                   	push   %ebp
  8017ad:	89 e5                	mov    %esp,%ebp
  8017af:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8017b2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8017bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ca:	89 04 24             	mov    %eax,(%esp)
  8017cd:	e8 02 00 00 00       	call   8017d4 <vprintfmt>
	va_end(ap);
}
  8017d2:	c9                   	leave  
  8017d3:	c3                   	ret    

008017d4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	57                   	push   %edi
  8017d8:	56                   	push   %esi
  8017d9:	53                   	push   %ebx
  8017da:	83 ec 3c             	sub    $0x3c,%esp
  8017dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8017e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8017e3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8017e6:	eb 11                	jmp    8017f9 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	0f 84 48 04 00 00    	je     801c38 <vprintfmt+0x464>
				return;
			putch(ch, putdat);
  8017f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017f4:	89 04 24             	mov    %eax,(%esp)
  8017f7:	ff d6                	call   *%esi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8017f9:	83 c7 01             	add    $0x1,%edi
  8017fc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801800:	83 f8 25             	cmp    $0x25,%eax
  801803:	75 e3                	jne    8017e8 <vprintfmt+0x14>
  801805:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801809:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801810:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801817:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80181e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801823:	eb 1f                	jmp    801844 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801825:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801828:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80182c:	eb 16                	jmp    801844 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80182e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801831:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801835:	eb 0d                	jmp    801844 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801837:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80183a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80183d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801844:	8d 47 01             	lea    0x1(%edi),%eax
  801847:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80184a:	0f b6 17             	movzbl (%edi),%edx
  80184d:	0f b6 c2             	movzbl %dl,%eax
  801850:	83 ea 23             	sub    $0x23,%edx
  801853:	80 fa 55             	cmp    $0x55,%dl
  801856:	0f 87 bf 03 00 00    	ja     801c1b <vprintfmt+0x447>
  80185c:	0f b6 d2             	movzbl %dl,%edx
  80185f:	ff 24 95 c0 23 80 00 	jmp    *0x8023c0(,%edx,4)
  801866:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801869:	ba 00 00 00 00       	mov    $0x0,%edx
  80186e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801871:	8d 14 92             	lea    (%edx,%edx,4),%edx
  801874:	8d 54 50 d0          	lea    -0x30(%eax,%edx,2),%edx
				ch = *fmt;
  801878:	0f be 07             	movsbl (%edi),%eax
				if (ch < '0' || ch > '9')
  80187b:	8d 48 d0             	lea    -0x30(%eax),%ecx
  80187e:	83 f9 09             	cmp    $0x9,%ecx
  801881:	77 3c                	ja     8018bf <vprintfmt+0xeb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801883:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801886:	eb e9                	jmp    801871 <vprintfmt+0x9d>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801888:	8b 45 14             	mov    0x14(%ebp),%eax
  80188b:	8b 00                	mov    (%eax),%eax
  80188d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801890:	8b 45 14             	mov    0x14(%ebp),%eax
  801893:	8d 40 04             	lea    0x4(%eax),%eax
  801896:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801899:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80189c:	eb 27                	jmp    8018c5 <vprintfmt+0xf1>
  80189e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8018a1:	85 d2                	test   %edx,%edx
  8018a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a8:	0f 49 c2             	cmovns %edx,%eax
  8018ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8018b1:	eb 91                	jmp    801844 <vprintfmt+0x70>
  8018b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8018b6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8018bd:	eb 85                	jmp    801844 <vprintfmt+0x70>
  8018bf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8018c2:	89 55 d0             	mov    %edx,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8018c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8018c9:	0f 89 75 ff ff ff    	jns    801844 <vprintfmt+0x70>
  8018cf:	e9 63 ff ff ff       	jmp    801837 <vprintfmt+0x63>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018d4:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8018da:	e9 65 ff ff ff       	jmp    801844 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018df:	8b 45 14             	mov    0x14(%ebp),%eax
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018e2:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  8018e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018ea:	8b 00                	mov    (%eax),%eax
  8018ec:	89 04 24             	mov    %eax,(%esp)
  8018ef:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8018f4:	e9 00 ff ff ff       	jmp    8017f9 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018f9:	8b 45 14             	mov    0x14(%ebp),%eax
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8018fc:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  801900:	8b 00                	mov    (%eax),%eax
  801902:	99                   	cltd   
  801903:	31 d0                	xor    %edx,%eax
  801905:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801907:	83 f8 0f             	cmp    $0xf,%eax
  80190a:	7f 0b                	jg     801917 <vprintfmt+0x143>
  80190c:	8b 14 85 20 25 80 00 	mov    0x802520(,%eax,4),%edx
  801913:	85 d2                	test   %edx,%edx
  801915:	75 20                	jne    801937 <vprintfmt+0x163>
				printfmt(putch, putdat, "error %d", err);
  801917:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80191b:	c7 44 24 08 9f 22 80 	movl   $0x80229f,0x8(%esp)
  801922:	00 
  801923:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801927:	89 34 24             	mov    %esi,(%esp)
  80192a:	e8 7d fe ff ff       	call   8017ac <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80192f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801932:	e9 c2 fe ff ff       	jmp    8017f9 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
  801937:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80193b:	c7 44 24 08 2a 22 80 	movl   $0x80222a,0x8(%esp)
  801942:	00 
  801943:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801947:	89 34 24             	mov    %esi,(%esp)
  80194a:	e8 5d fe ff ff       	call   8017ac <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80194f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801952:	e9 a2 fe ff ff       	jmp    8017f9 <vprintfmt+0x25>
  801957:	8b 45 14             	mov    0x14(%ebp),%eax
  80195a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  80195d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801960:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801963:	83 45 14 04          	addl   $0x4,0x14(%ebp)
  801967:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801969:	85 ff                	test   %edi,%edi
  80196b:	b8 98 22 80 00       	mov    $0x802298,%eax
  801970:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801973:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801977:	0f 84 92 00 00 00    	je     801a0f <vprintfmt+0x23b>
  80197d:	85 c9                	test   %ecx,%ecx
  80197f:	0f 8e 98 00 00 00    	jle    801a1d <vprintfmt+0x249>
				for (width -= strnlen(p, precision); width > 0; width--)
  801985:	89 54 24 04          	mov    %edx,0x4(%esp)
  801989:	89 3c 24             	mov    %edi,(%esp)
  80198c:	e8 d7 e7 ff ff       	call   800168 <strnlen>
  801991:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801994:	29 c1                	sub    %eax,%ecx
  801996:	89 4d cc             	mov    %ecx,-0x34(%ebp)
					putch(padc, putdat);
  801999:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80199d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019a0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8019a3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019a5:	eb 0f                	jmp    8019b6 <vprintfmt+0x1e2>
					putch(padc, putdat);
  8019a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8019ae:	89 04 24             	mov    %eax,(%esp)
  8019b1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019b3:	83 ef 01             	sub    $0x1,%edi
  8019b6:	85 ff                	test   %edi,%edi
  8019b8:	7f ed                	jg     8019a7 <vprintfmt+0x1d3>
  8019ba:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8019bd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8019c0:	85 c9                	test   %ecx,%ecx
  8019c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c7:	0f 49 c1             	cmovns %ecx,%eax
  8019ca:	29 c1                	sub    %eax,%ecx
  8019cc:	89 75 08             	mov    %esi,0x8(%ebp)
  8019cf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8019d2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8019d5:	89 cb                	mov    %ecx,%ebx
  8019d7:	eb 50                	jmp    801a29 <vprintfmt+0x255>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019d9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8019dd:	74 1e                	je     8019fd <vprintfmt+0x229>
  8019df:	0f be d2             	movsbl %dl,%edx
  8019e2:	83 ea 20             	sub    $0x20,%edx
  8019e5:	83 fa 5e             	cmp    $0x5e,%edx
  8019e8:	76 13                	jbe    8019fd <vprintfmt+0x229>
					putch('?', putdat);
  8019ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8019f8:	ff 55 08             	call   *0x8(%ebp)
  8019fb:	eb 0d                	jmp    801a0a <vprintfmt+0x236>
				else
					putch(ch, putdat);
  8019fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a00:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a04:	89 04 24             	mov    %eax,(%esp)
  801a07:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a0a:	83 eb 01             	sub    $0x1,%ebx
  801a0d:	eb 1a                	jmp    801a29 <vprintfmt+0x255>
  801a0f:	89 75 08             	mov    %esi,0x8(%ebp)
  801a12:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a15:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a18:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a1b:	eb 0c                	jmp    801a29 <vprintfmt+0x255>
  801a1d:	89 75 08             	mov    %esi,0x8(%ebp)
  801a20:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801a23:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801a26:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801a29:	83 c7 01             	add    $0x1,%edi
  801a2c:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  801a30:	0f be c2             	movsbl %dl,%eax
  801a33:	85 c0                	test   %eax,%eax
  801a35:	74 25                	je     801a5c <vprintfmt+0x288>
  801a37:	85 f6                	test   %esi,%esi
  801a39:	78 9e                	js     8019d9 <vprintfmt+0x205>
  801a3b:	83 ee 01             	sub    $0x1,%esi
  801a3e:	79 99                	jns    8019d9 <vprintfmt+0x205>
  801a40:	89 df                	mov    %ebx,%edi
  801a42:	8b 75 08             	mov    0x8(%ebp),%esi
  801a45:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a48:	eb 1a                	jmp    801a64 <vprintfmt+0x290>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a4a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a4e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801a55:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a57:	83 ef 01             	sub    $0x1,%edi
  801a5a:	eb 08                	jmp    801a64 <vprintfmt+0x290>
  801a5c:	89 df                	mov    %ebx,%edi
  801a5e:	8b 75 08             	mov    0x8(%ebp),%esi
  801a61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a64:	85 ff                	test   %edi,%edi
  801a66:	7f e2                	jg     801a4a <vprintfmt+0x276>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a68:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801a6b:	e9 89 fd ff ff       	jmp    8017f9 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a70:	83 f9 01             	cmp    $0x1,%ecx
  801a73:	7e 19                	jle    801a8e <vprintfmt+0x2ba>
		return va_arg(*ap, long long);
  801a75:	8b 45 14             	mov    0x14(%ebp),%eax
  801a78:	8b 50 04             	mov    0x4(%eax),%edx
  801a7b:	8b 00                	mov    (%eax),%eax
  801a7d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a80:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801a83:	8b 45 14             	mov    0x14(%ebp),%eax
  801a86:	8d 40 08             	lea    0x8(%eax),%eax
  801a89:	89 45 14             	mov    %eax,0x14(%ebp)
  801a8c:	eb 38                	jmp    801ac6 <vprintfmt+0x2f2>
	else if (lflag)
  801a8e:	85 c9                	test   %ecx,%ecx
  801a90:	74 1b                	je     801aad <vprintfmt+0x2d9>
		return va_arg(*ap, long);
  801a92:	8b 45 14             	mov    0x14(%ebp),%eax
  801a95:	8b 00                	mov    (%eax),%eax
  801a97:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a9a:	89 c1                	mov    %eax,%ecx
  801a9c:	c1 f9 1f             	sar    $0x1f,%ecx
  801a9f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801aa2:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa5:	8d 40 04             	lea    0x4(%eax),%eax
  801aa8:	89 45 14             	mov    %eax,0x14(%ebp)
  801aab:	eb 19                	jmp    801ac6 <vprintfmt+0x2f2>
	else
		return va_arg(*ap, int);
  801aad:	8b 45 14             	mov    0x14(%ebp),%eax
  801ab0:	8b 00                	mov    (%eax),%eax
  801ab2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801ab5:	89 c1                	mov    %eax,%ecx
  801ab7:	c1 f9 1f             	sar    $0x1f,%ecx
  801aba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801abd:	8b 45 14             	mov    0x14(%ebp),%eax
  801ac0:	8d 40 04             	lea    0x4(%eax),%eax
  801ac3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801ac6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801ac9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801acc:	bf 0a 00 00 00       	mov    $0xa,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801ad1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801ad5:	0f 89 04 01 00 00    	jns    801bdf <vprintfmt+0x40b>
				putch('-', putdat);
  801adb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801adf:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801ae6:	ff d6                	call   *%esi
				num = -(long long) num;
  801ae8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801aeb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801aee:	f7 da                	neg    %edx
  801af0:	83 d1 00             	adc    $0x0,%ecx
  801af3:	f7 d9                	neg    %ecx
  801af5:	e9 e5 00 00 00       	jmp    801bdf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801afa:	83 f9 01             	cmp    $0x1,%ecx
  801afd:	7e 10                	jle    801b0f <vprintfmt+0x33b>
		return va_arg(*ap, unsigned long long);
  801aff:	8b 45 14             	mov    0x14(%ebp),%eax
  801b02:	8b 10                	mov    (%eax),%edx
  801b04:	8b 48 04             	mov    0x4(%eax),%ecx
  801b07:	8d 40 08             	lea    0x8(%eax),%eax
  801b0a:	89 45 14             	mov    %eax,0x14(%ebp)
  801b0d:	eb 26                	jmp    801b35 <vprintfmt+0x361>
	else if (lflag)
  801b0f:	85 c9                	test   %ecx,%ecx
  801b11:	74 12                	je     801b25 <vprintfmt+0x351>
		return va_arg(*ap, unsigned long);
  801b13:	8b 45 14             	mov    0x14(%ebp),%eax
  801b16:	8b 10                	mov    (%eax),%edx
  801b18:	b9 00 00 00 00       	mov    $0x0,%ecx
  801b1d:	8d 40 04             	lea    0x4(%eax),%eax
  801b20:	89 45 14             	mov    %eax,0x14(%ebp)
  801b23:	eb 10                	jmp    801b35 <vprintfmt+0x361>
	else
		return va_arg(*ap, unsigned int);
  801b25:	8b 45 14             	mov    0x14(%ebp),%eax
  801b28:	8b 10                	mov    (%eax),%edx
  801b2a:	b9 00 00 00 00       	mov    $0x0,%ecx
  801b2f:	8d 40 04             	lea    0x4(%eax),%eax
  801b32:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801b35:	bf 0a 00 00 00       	mov    $0xa,%edi
			goto number;
  801b3a:	e9 a0 00 00 00       	jmp    801bdf <vprintfmt+0x40b>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801b3f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b43:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  801b4a:	ff d6                	call   *%esi
			putch('X', putdat);
  801b4c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b50:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  801b57:	ff d6                	call   *%esi
			putch('X', putdat);
  801b59:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b5d:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  801b64:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b66:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  801b69:	e9 8b fc ff ff       	jmp    8017f9 <vprintfmt+0x25>

		// pointer
		case 'p':
			putch('0', putdat);
  801b6e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b72:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801b79:	ff d6                	call   *%esi
			putch('x', putdat);
  801b7b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b7f:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801b86:	ff d6                	call   *%esi
			num = (unsigned long long)
  801b88:	8b 45 14             	mov    0x14(%ebp),%eax
  801b8b:	8b 10                	mov    (%eax),%edx
  801b8d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
  801b92:	8d 40 04             	lea    0x4(%eax),%eax
  801b95:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801b98:	bf 10 00 00 00       	mov    $0x10,%edi
			goto number;
  801b9d:	eb 40                	jmp    801bdf <vprintfmt+0x40b>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801b9f:	83 f9 01             	cmp    $0x1,%ecx
  801ba2:	7e 10                	jle    801bb4 <vprintfmt+0x3e0>
		return va_arg(*ap, unsigned long long);
  801ba4:	8b 45 14             	mov    0x14(%ebp),%eax
  801ba7:	8b 10                	mov    (%eax),%edx
  801ba9:	8b 48 04             	mov    0x4(%eax),%ecx
  801bac:	8d 40 08             	lea    0x8(%eax),%eax
  801baf:	89 45 14             	mov    %eax,0x14(%ebp)
  801bb2:	eb 26                	jmp    801bda <vprintfmt+0x406>
	else if (lflag)
  801bb4:	85 c9                	test   %ecx,%ecx
  801bb6:	74 12                	je     801bca <vprintfmt+0x3f6>
		return va_arg(*ap, unsigned long);
  801bb8:	8b 45 14             	mov    0x14(%ebp),%eax
  801bbb:	8b 10                	mov    (%eax),%edx
  801bbd:	b9 00 00 00 00       	mov    $0x0,%ecx
  801bc2:	8d 40 04             	lea    0x4(%eax),%eax
  801bc5:	89 45 14             	mov    %eax,0x14(%ebp)
  801bc8:	eb 10                	jmp    801bda <vprintfmt+0x406>
	else
		return va_arg(*ap, unsigned int);
  801bca:	8b 45 14             	mov    0x14(%ebp),%eax
  801bcd:	8b 10                	mov    (%eax),%edx
  801bcf:	b9 00 00 00 00       	mov    $0x0,%ecx
  801bd4:	8d 40 04             	lea    0x4(%eax),%eax
  801bd7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801bda:	bf 10 00 00 00       	mov    $0x10,%edi
		number:
			printnum(putch, putdat, num, base, width, padc);
  801bdf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801be3:	89 44 24 10          	mov    %eax,0x10(%esp)
  801be7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801bea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bee:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801bf2:	89 14 24             	mov    %edx,(%esp)
  801bf5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801bf9:	89 da                	mov    %ebx,%edx
  801bfb:	89 f0                	mov    %esi,%eax
  801bfd:	e8 9e fa ff ff       	call   8016a0 <printnum>
			break;
  801c02:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c05:	e9 ef fb ff ff       	jmp    8017f9 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801c0a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c0e:	89 04 24             	mov    %eax,(%esp)
  801c11:	ff d6                	call   *%esi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c13:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801c16:	e9 de fb ff ff       	jmp    8017f9 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801c1b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c1f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801c26:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801c28:	eb 03                	jmp    801c2d <vprintfmt+0x459>
  801c2a:	83 ef 01             	sub    $0x1,%edi
  801c2d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801c31:	75 f7                	jne    801c2a <vprintfmt+0x456>
  801c33:	e9 c1 fb ff ff       	jmp    8017f9 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
  801c38:	83 c4 3c             	add    $0x3c,%esp
  801c3b:	5b                   	pop    %ebx
  801c3c:	5e                   	pop    %esi
  801c3d:	5f                   	pop    %edi
  801c3e:	5d                   	pop    %ebp
  801c3f:	c3                   	ret    

00801c40 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	83 ec 28             	sub    $0x28,%esp
  801c46:	8b 45 08             	mov    0x8(%ebp),%eax
  801c49:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801c4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c4f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801c53:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801c56:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	74 30                	je     801c91 <vsnprintf+0x51>
  801c61:	85 d2                	test   %edx,%edx
  801c63:	7e 2c                	jle    801c91 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801c65:	8b 45 14             	mov    0x14(%ebp),%eax
  801c68:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c6c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c6f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c73:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801c76:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c7a:	c7 04 24 8f 17 80 00 	movl   $0x80178f,(%esp)
  801c81:	e8 4e fb ff ff       	call   8017d4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801c86:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c89:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8f:	eb 05                	jmp    801c96 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801c91:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801c96:	c9                   	leave  
  801c97:	c3                   	ret    

00801c98 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801c9e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801ca1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ca5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801caf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb6:	89 04 24             	mov    %eax,(%esp)
  801cb9:	e8 82 ff ff ff       	call   801c40 <vsnprintf>
	va_end(ap);

	return rc;
}
  801cbe:	c9                   	leave  
  801cbf:	c3                   	ret    

00801cc0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	56                   	push   %esi
  801cc4:	53                   	push   %ebx
  801cc5:	83 ec 10             	sub    $0x10,%esp
  801cc8:	8b 75 08             	mov    0x8(%ebp),%esi
  801ccb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB : Your code here.
	int r =0;
	int a;
	if(pg == 0)
  801cd1:	85 c0                	test   %eax,%eax
  801cd3:	75 0e                	jne    801ce3 <ipc_recv+0x23>
		r= sys_ipc_recv( (void *)UTOP);
  801cd5:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801cdc:	e8 d8 ea ff ff       	call   8007b9 <sys_ipc_recv>
  801ce1:	eb 08                	jmp    801ceb <ipc_recv+0x2b>
	else
		r = sys_ipc_recv(pg);
  801ce3:	89 04 24             	mov    %eax,(%esp)
  801ce6:	e8 ce ea ff ff       	call   8007b9 <sys_ipc_recv>
	if(r == 0){
  801ceb:	85 c0                	test   %eax,%eax
  801ced:	8d 76 00             	lea    0x0(%esi),%esi
  801cf0:	75 1e                	jne    801d10 <ipc_recv+0x50>
		if( from_env_store != 0 )
  801cf2:	85 f6                	test   %esi,%esi
  801cf4:	74 0a                	je     801d00 <ipc_recv+0x40>
			*from_env_store = thisenv->env_ipc_from;
  801cf6:	a1 04 40 80 00       	mov    0x804004,%eax
  801cfb:	8b 40 74             	mov    0x74(%eax),%eax
  801cfe:	89 06                	mov    %eax,(%esi)

		if(perm_store != 0 )
  801d00:	85 db                	test   %ebx,%ebx
  801d02:	74 2c                	je     801d30 <ipc_recv+0x70>
			*perm_store = thisenv->env_ipc_perm;
  801d04:	a1 04 40 80 00       	mov    0x804004,%eax
  801d09:	8b 40 78             	mov    0x78(%eax),%eax
  801d0c:	89 03                	mov    %eax,(%ebx)
  801d0e:	eb 20                	jmp    801d30 <ipc_recv+0x70>
	}
	else{
		panic("The ipc_recv is not right, and the errno is %d\n",r);
  801d10:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d14:	c7 44 24 08 80 25 80 	movl   $0x802580,0x8(%esp)
  801d1b:	00 
  801d1c:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801d23:	00 
  801d24:	c7 04 24 fc 25 80 00 	movl   $0x8025fc,(%esp)
  801d2b:	e8 56 f8 ff ff       	call   801586 <_panic>

		if(perm_store != 0 )
			*perm_store = 0;
		return r;
	}
	if(thisenv->env_ipc_value == 0)
  801d30:	a1 04 40 80 00       	mov    0x804004,%eax
  801d35:	8b 50 70             	mov    0x70(%eax),%edx
  801d38:	85 d2                	test   %edx,%edx
  801d3a:	75 13                	jne    801d4f <ipc_recv+0x8f>
		cprintf("the value is 0, the envid is %x\n", thisenv->env_id);
  801d3c:	8b 40 48             	mov    0x48(%eax),%eax
  801d3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d43:	c7 04 24 b0 25 80 00 	movl   $0x8025b0,(%esp)
  801d4a:	e8 30 f9 ff ff       	call   80167f <cprintf>
	return thisenv->env_ipc_value;
  801d4f:	a1 04 40 80 00       	mov    0x804004,%eax
  801d54:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d57:	83 c4 10             	add    $0x10,%esp
  801d5a:	5b                   	pop    %ebx
  801d5b:	5e                   	pop    %esi
  801d5c:	5d                   	pop    %ebp
  801d5d:	c3                   	ret    

00801d5e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	57                   	push   %edi
  801d62:	56                   	push   %esi
  801d63:	53                   	push   %ebx
  801d64:	83 ec 1c             	sub    $0x1c,%esp
  801d67:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d6a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB : Your code here.
		int r =0;
	while(1){
		if(pg == 0)
  801d6d:	85 f6                	test   %esi,%esi
  801d6f:	75 22                	jne    801d93 <ipc_send+0x35>
			r=sys_ipc_try_send(to_env,  val, (void*) UTOP,  perm);
  801d71:	8b 45 14             	mov    0x14(%ebp),%eax
  801d74:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d78:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801d7f:	ee 
  801d80:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d83:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d87:	89 3c 24             	mov    %edi,(%esp)
  801d8a:	e8 07 ea ff ff       	call   800796 <sys_ipc_try_send>
  801d8f:	89 c3                	mov    %eax,%ebx
  801d91:	eb 1c                	jmp    801daf <ipc_send+0x51>
		else
			r = sys_ipc_try_send(to_env,  val, pg,  perm);
  801d93:	8b 45 14             	mov    0x14(%ebp),%eax
  801d96:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d9a:	89 74 24 08          	mov    %esi,0x8(%esp)
  801d9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da5:	89 3c 24             	mov    %edi,(%esp)
  801da8:	e8 e9 e9 ff ff       	call   800796 <sys_ipc_try_send>
  801dad:	89 c3                	mov    %eax,%ebx

		if(r <0 && r != -E_IPC_NOT_RECV){
  801daf:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801db2:	74 3e                	je     801df2 <ipc_send+0x94>
  801db4:	89 d8                	mov    %ebx,%eax
  801db6:	c1 e8 1f             	shr    $0x1f,%eax
  801db9:	84 c0                	test   %al,%al
  801dbb:	74 35                	je     801df2 <ipc_send+0x94>
			cprintf("the envid is %x\n", sys_getenvid());
  801dbd:	e8 a3 e7 ff ff       	call   800565 <sys_getenvid>
  801dc2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dc6:	c7 04 24 06 26 80 00 	movl   $0x802606,(%esp)
  801dcd:	e8 ad f8 ff ff       	call   80167f <cprintf>
			panic("ipc_send is error, and the errno is %d\n", r);
  801dd2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801dd6:	c7 44 24 08 d4 25 80 	movl   $0x8025d4,0x8(%esp)
  801ddd:	00 
  801dde:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  801de5:	00 
  801de6:	c7 04 24 fc 25 80 00 	movl   $0x8025fc,(%esp)
  801ded:	e8 94 f7 ff ff       	call   801586 <_panic>
		}
		else if(r == -E_IPC_NOT_RECV)
  801df2:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801df5:	75 0e                	jne    801e05 <ipc_send+0xa7>
			sys_yield();
  801df7:	e8 88 e7 ff ff       	call   800584 <sys_yield>
		else break;
	}
  801dfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e00:	e9 68 ff ff ff       	jmp    801d6d <ipc_send+0xf>
	
}
  801e05:	83 c4 1c             	add    $0x1c,%esp
  801e08:	5b                   	pop    %ebx
  801e09:	5e                   	pop    %esi
  801e0a:	5f                   	pop    %edi
  801e0b:	5d                   	pop    %ebp
  801e0c:	c3                   	ret    

00801e0d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e0d:	55                   	push   %ebp
  801e0e:	89 e5                	mov    %esp,%ebp
  801e10:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e13:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e18:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801e1b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e21:	8b 52 50             	mov    0x50(%edx),%edx
  801e24:	39 ca                	cmp    %ecx,%edx
  801e26:	75 0d                	jne    801e35 <ipc_find_env+0x28>
			return envs[i].env_id;
  801e28:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e2b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801e30:	8b 40 40             	mov    0x40(%eax),%eax
  801e33:	eb 0e                	jmp    801e43 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e35:	83 c0 01             	add    $0x1,%eax
  801e38:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e3d:	75 d9                	jne    801e18 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e3f:	66 b8 00 00          	mov    $0x0,%ax
}
  801e43:	5d                   	pop    %ebp
  801e44:	c3                   	ret    

00801e45 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e45:	55                   	push   %ebp
  801e46:	89 e5                	mov    %esp,%ebp
  801e48:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e4b:	89 d0                	mov    %edx,%eax
  801e4d:	c1 e8 16             	shr    $0x16,%eax
  801e50:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e57:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e5c:	f6 c1 01             	test   $0x1,%cl
  801e5f:	74 1d                	je     801e7e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e61:	c1 ea 0c             	shr    $0xc,%edx
  801e64:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e6b:	f6 c2 01             	test   $0x1,%dl
  801e6e:	74 0e                	je     801e7e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e70:	c1 ea 0c             	shr    $0xc,%edx
  801e73:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e7a:	ef 
  801e7b:	0f b7 c0             	movzwl %ax,%eax
}
  801e7e:	5d                   	pop    %ebp
  801e7f:	c3                   	ret    

00801e80 <__udivdi3>:
  801e80:	55                   	push   %ebp
  801e81:	57                   	push   %edi
  801e82:	56                   	push   %esi
  801e83:	83 ec 0c             	sub    $0xc,%esp
  801e86:	8b 44 24 28          	mov    0x28(%esp),%eax
  801e8a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  801e8e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801e92:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801e96:	85 c0                	test   %eax,%eax
  801e98:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e9c:	89 ea                	mov    %ebp,%edx
  801e9e:	89 0c 24             	mov    %ecx,(%esp)
  801ea1:	75 2d                	jne    801ed0 <__udivdi3+0x50>
  801ea3:	39 e9                	cmp    %ebp,%ecx
  801ea5:	77 61                	ja     801f08 <__udivdi3+0x88>
  801ea7:	85 c9                	test   %ecx,%ecx
  801ea9:	89 ce                	mov    %ecx,%esi
  801eab:	75 0b                	jne    801eb8 <__udivdi3+0x38>
  801ead:	b8 01 00 00 00       	mov    $0x1,%eax
  801eb2:	31 d2                	xor    %edx,%edx
  801eb4:	f7 f1                	div    %ecx
  801eb6:	89 c6                	mov    %eax,%esi
  801eb8:	31 d2                	xor    %edx,%edx
  801eba:	89 e8                	mov    %ebp,%eax
  801ebc:	f7 f6                	div    %esi
  801ebe:	89 c5                	mov    %eax,%ebp
  801ec0:	89 f8                	mov    %edi,%eax
  801ec2:	f7 f6                	div    %esi
  801ec4:	89 ea                	mov    %ebp,%edx
  801ec6:	83 c4 0c             	add    $0xc,%esp
  801ec9:	5e                   	pop    %esi
  801eca:	5f                   	pop    %edi
  801ecb:	5d                   	pop    %ebp
  801ecc:	c3                   	ret    
  801ecd:	8d 76 00             	lea    0x0(%esi),%esi
  801ed0:	39 e8                	cmp    %ebp,%eax
  801ed2:	77 24                	ja     801ef8 <__udivdi3+0x78>
  801ed4:	0f bd e8             	bsr    %eax,%ebp
  801ed7:	83 f5 1f             	xor    $0x1f,%ebp
  801eda:	75 3c                	jne    801f18 <__udivdi3+0x98>
  801edc:	8b 74 24 04          	mov    0x4(%esp),%esi
  801ee0:	39 34 24             	cmp    %esi,(%esp)
  801ee3:	0f 86 9f 00 00 00    	jbe    801f88 <__udivdi3+0x108>
  801ee9:	39 d0                	cmp    %edx,%eax
  801eeb:	0f 82 97 00 00 00    	jb     801f88 <__udivdi3+0x108>
  801ef1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ef8:	31 d2                	xor    %edx,%edx
  801efa:	31 c0                	xor    %eax,%eax
  801efc:	83 c4 0c             	add    $0xc,%esp
  801eff:	5e                   	pop    %esi
  801f00:	5f                   	pop    %edi
  801f01:	5d                   	pop    %ebp
  801f02:	c3                   	ret    
  801f03:	90                   	nop
  801f04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f08:	89 f8                	mov    %edi,%eax
  801f0a:	f7 f1                	div    %ecx
  801f0c:	31 d2                	xor    %edx,%edx
  801f0e:	83 c4 0c             	add    $0xc,%esp
  801f11:	5e                   	pop    %esi
  801f12:	5f                   	pop    %edi
  801f13:	5d                   	pop    %ebp
  801f14:	c3                   	ret    
  801f15:	8d 76 00             	lea    0x0(%esi),%esi
  801f18:	89 e9                	mov    %ebp,%ecx
  801f1a:	8b 3c 24             	mov    (%esp),%edi
  801f1d:	d3 e0                	shl    %cl,%eax
  801f1f:	89 c6                	mov    %eax,%esi
  801f21:	b8 20 00 00 00       	mov    $0x20,%eax
  801f26:	29 e8                	sub    %ebp,%eax
  801f28:	89 c1                	mov    %eax,%ecx
  801f2a:	d3 ef                	shr    %cl,%edi
  801f2c:	89 e9                	mov    %ebp,%ecx
  801f2e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801f32:	8b 3c 24             	mov    (%esp),%edi
  801f35:	09 74 24 08          	or     %esi,0x8(%esp)
  801f39:	89 d6                	mov    %edx,%esi
  801f3b:	d3 e7                	shl    %cl,%edi
  801f3d:	89 c1                	mov    %eax,%ecx
  801f3f:	89 3c 24             	mov    %edi,(%esp)
  801f42:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801f46:	d3 ee                	shr    %cl,%esi
  801f48:	89 e9                	mov    %ebp,%ecx
  801f4a:	d3 e2                	shl    %cl,%edx
  801f4c:	89 c1                	mov    %eax,%ecx
  801f4e:	d3 ef                	shr    %cl,%edi
  801f50:	09 d7                	or     %edx,%edi
  801f52:	89 f2                	mov    %esi,%edx
  801f54:	89 f8                	mov    %edi,%eax
  801f56:	f7 74 24 08          	divl   0x8(%esp)
  801f5a:	89 d6                	mov    %edx,%esi
  801f5c:	89 c7                	mov    %eax,%edi
  801f5e:	f7 24 24             	mull   (%esp)
  801f61:	39 d6                	cmp    %edx,%esi
  801f63:	89 14 24             	mov    %edx,(%esp)
  801f66:	72 30                	jb     801f98 <__udivdi3+0x118>
  801f68:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f6c:	89 e9                	mov    %ebp,%ecx
  801f6e:	d3 e2                	shl    %cl,%edx
  801f70:	39 c2                	cmp    %eax,%edx
  801f72:	73 05                	jae    801f79 <__udivdi3+0xf9>
  801f74:	3b 34 24             	cmp    (%esp),%esi
  801f77:	74 1f                	je     801f98 <__udivdi3+0x118>
  801f79:	89 f8                	mov    %edi,%eax
  801f7b:	31 d2                	xor    %edx,%edx
  801f7d:	e9 7a ff ff ff       	jmp    801efc <__udivdi3+0x7c>
  801f82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f88:	31 d2                	xor    %edx,%edx
  801f8a:	b8 01 00 00 00       	mov    $0x1,%eax
  801f8f:	e9 68 ff ff ff       	jmp    801efc <__udivdi3+0x7c>
  801f94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f98:	8d 47 ff             	lea    -0x1(%edi),%eax
  801f9b:	31 d2                	xor    %edx,%edx
  801f9d:	83 c4 0c             	add    $0xc,%esp
  801fa0:	5e                   	pop    %esi
  801fa1:	5f                   	pop    %edi
  801fa2:	5d                   	pop    %ebp
  801fa3:	c3                   	ret    
  801fa4:	66 90                	xchg   %ax,%ax
  801fa6:	66 90                	xchg   %ax,%ax
  801fa8:	66 90                	xchg   %ax,%ax
  801faa:	66 90                	xchg   %ax,%ax
  801fac:	66 90                	xchg   %ax,%ax
  801fae:	66 90                	xchg   %ax,%ax

00801fb0 <__umoddi3>:
  801fb0:	55                   	push   %ebp
  801fb1:	57                   	push   %edi
  801fb2:	56                   	push   %esi
  801fb3:	83 ec 14             	sub    $0x14,%esp
  801fb6:	8b 44 24 28          	mov    0x28(%esp),%eax
  801fba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801fbe:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801fc2:	89 c7                	mov    %eax,%edi
  801fc4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc8:	8b 44 24 30          	mov    0x30(%esp),%eax
  801fcc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801fd0:	89 34 24             	mov    %esi,(%esp)
  801fd3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fd7:	85 c0                	test   %eax,%eax
  801fd9:	89 c2                	mov    %eax,%edx
  801fdb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801fdf:	75 17                	jne    801ff8 <__umoddi3+0x48>
  801fe1:	39 fe                	cmp    %edi,%esi
  801fe3:	76 4b                	jbe    802030 <__umoddi3+0x80>
  801fe5:	89 c8                	mov    %ecx,%eax
  801fe7:	89 fa                	mov    %edi,%edx
  801fe9:	f7 f6                	div    %esi
  801feb:	89 d0                	mov    %edx,%eax
  801fed:	31 d2                	xor    %edx,%edx
  801fef:	83 c4 14             	add    $0x14,%esp
  801ff2:	5e                   	pop    %esi
  801ff3:	5f                   	pop    %edi
  801ff4:	5d                   	pop    %ebp
  801ff5:	c3                   	ret    
  801ff6:	66 90                	xchg   %ax,%ax
  801ff8:	39 f8                	cmp    %edi,%eax
  801ffa:	77 54                	ja     802050 <__umoddi3+0xa0>
  801ffc:	0f bd e8             	bsr    %eax,%ebp
  801fff:	83 f5 1f             	xor    $0x1f,%ebp
  802002:	75 5c                	jne    802060 <__umoddi3+0xb0>
  802004:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802008:	39 3c 24             	cmp    %edi,(%esp)
  80200b:	0f 87 e7 00 00 00    	ja     8020f8 <__umoddi3+0x148>
  802011:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802015:	29 f1                	sub    %esi,%ecx
  802017:	19 c7                	sbb    %eax,%edi
  802019:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80201d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802021:	8b 44 24 08          	mov    0x8(%esp),%eax
  802025:	8b 54 24 0c          	mov    0xc(%esp),%edx
  802029:	83 c4 14             	add    $0x14,%esp
  80202c:	5e                   	pop    %esi
  80202d:	5f                   	pop    %edi
  80202e:	5d                   	pop    %ebp
  80202f:	c3                   	ret    
  802030:	85 f6                	test   %esi,%esi
  802032:	89 f5                	mov    %esi,%ebp
  802034:	75 0b                	jne    802041 <__umoddi3+0x91>
  802036:	b8 01 00 00 00       	mov    $0x1,%eax
  80203b:	31 d2                	xor    %edx,%edx
  80203d:	f7 f6                	div    %esi
  80203f:	89 c5                	mov    %eax,%ebp
  802041:	8b 44 24 04          	mov    0x4(%esp),%eax
  802045:	31 d2                	xor    %edx,%edx
  802047:	f7 f5                	div    %ebp
  802049:	89 c8                	mov    %ecx,%eax
  80204b:	f7 f5                	div    %ebp
  80204d:	eb 9c                	jmp    801feb <__umoddi3+0x3b>
  80204f:	90                   	nop
  802050:	89 c8                	mov    %ecx,%eax
  802052:	89 fa                	mov    %edi,%edx
  802054:	83 c4 14             	add    $0x14,%esp
  802057:	5e                   	pop    %esi
  802058:	5f                   	pop    %edi
  802059:	5d                   	pop    %ebp
  80205a:	c3                   	ret    
  80205b:	90                   	nop
  80205c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802060:	8b 04 24             	mov    (%esp),%eax
  802063:	be 20 00 00 00       	mov    $0x20,%esi
  802068:	89 e9                	mov    %ebp,%ecx
  80206a:	29 ee                	sub    %ebp,%esi
  80206c:	d3 e2                	shl    %cl,%edx
  80206e:	89 f1                	mov    %esi,%ecx
  802070:	d3 e8                	shr    %cl,%eax
  802072:	89 e9                	mov    %ebp,%ecx
  802074:	89 44 24 04          	mov    %eax,0x4(%esp)
  802078:	8b 04 24             	mov    (%esp),%eax
  80207b:	09 54 24 04          	or     %edx,0x4(%esp)
  80207f:	89 fa                	mov    %edi,%edx
  802081:	d3 e0                	shl    %cl,%eax
  802083:	89 f1                	mov    %esi,%ecx
  802085:	89 44 24 08          	mov    %eax,0x8(%esp)
  802089:	8b 44 24 10          	mov    0x10(%esp),%eax
  80208d:	d3 ea                	shr    %cl,%edx
  80208f:	89 e9                	mov    %ebp,%ecx
  802091:	d3 e7                	shl    %cl,%edi
  802093:	89 f1                	mov    %esi,%ecx
  802095:	d3 e8                	shr    %cl,%eax
  802097:	89 e9                	mov    %ebp,%ecx
  802099:	09 f8                	or     %edi,%eax
  80209b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80209f:	f7 74 24 04          	divl   0x4(%esp)
  8020a3:	d3 e7                	shl    %cl,%edi
  8020a5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8020a9:	89 d7                	mov    %edx,%edi
  8020ab:	f7 64 24 08          	mull   0x8(%esp)
  8020af:	39 d7                	cmp    %edx,%edi
  8020b1:	89 c1                	mov    %eax,%ecx
  8020b3:	89 14 24             	mov    %edx,(%esp)
  8020b6:	72 2c                	jb     8020e4 <__umoddi3+0x134>
  8020b8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8020bc:	72 22                	jb     8020e0 <__umoddi3+0x130>
  8020be:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8020c2:	29 c8                	sub    %ecx,%eax
  8020c4:	19 d7                	sbb    %edx,%edi
  8020c6:	89 e9                	mov    %ebp,%ecx
  8020c8:	89 fa                	mov    %edi,%edx
  8020ca:	d3 e8                	shr    %cl,%eax
  8020cc:	89 f1                	mov    %esi,%ecx
  8020ce:	d3 e2                	shl    %cl,%edx
  8020d0:	89 e9                	mov    %ebp,%ecx
  8020d2:	d3 ef                	shr    %cl,%edi
  8020d4:	09 d0                	or     %edx,%eax
  8020d6:	89 fa                	mov    %edi,%edx
  8020d8:	83 c4 14             	add    $0x14,%esp
  8020db:	5e                   	pop    %esi
  8020dc:	5f                   	pop    %edi
  8020dd:	5d                   	pop    %ebp
  8020de:	c3                   	ret    
  8020df:	90                   	nop
  8020e0:	39 d7                	cmp    %edx,%edi
  8020e2:	75 da                	jne    8020be <__umoddi3+0x10e>
  8020e4:	8b 14 24             	mov    (%esp),%edx
  8020e7:	89 c1                	mov    %eax,%ecx
  8020e9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8020ed:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8020f1:	eb cb                	jmp    8020be <__umoddi3+0x10e>
  8020f3:	90                   	nop
  8020f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8020fc:	0f 82 0f ff ff ff    	jb     802011 <__umoddi3+0x61>
  802102:	e9 1a ff ff ff       	jmp    802021 <__umoddi3+0x71>
