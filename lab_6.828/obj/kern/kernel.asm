
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0
	

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 6c 00 00 00       	call   f01000aa <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	f3 0f 1e fb          	endbr32 
f0100044:	55                   	push   %ebp
f0100045:	89 e5                	mov    %esp,%ebp
f0100047:	56                   	push   %esi
f0100048:	53                   	push   %ebx
f0100049:	e8 8c 01 00 00       	call   f01001da <__x86.get_pc_thunk.bx>
f010004e:	81 c3 ba 12 01 00    	add    $0x112ba,%ebx
f0100054:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100057:	83 ec 08             	sub    $0x8,%esp
f010005a:	56                   	push   %esi
f010005b:	8d 83 78 09 ff ff    	lea    -0xf688(%ebx),%eax
f0100061:	50                   	push   %eax
f0100062:	e8 30 0b 00 00       	call   f0100b97 <cprintf>
	if (x > 0)
f0100067:	83 c4 10             	add    $0x10,%esp
f010006a:	85 f6                	test   %esi,%esi
f010006c:	7e 29                	jle    f0100097 <test_backtrace+0x57>
		test_backtrace(x-1);
f010006e:	83 ec 0c             	sub    $0xc,%esp
f0100071:	8d 46 ff             	lea    -0x1(%esi),%eax
f0100074:	50                   	push   %eax
f0100075:	e8 c6 ff ff ff       	call   f0100040 <test_backtrace>
f010007a:	83 c4 10             	add    $0x10,%esp
	else
		mon_backtrace(0, 0, 0);
	cprintf("leaving test_backtrace %d\n", x);
f010007d:	83 ec 08             	sub    $0x8,%esp
f0100080:	56                   	push   %esi
f0100081:	8d 83 94 09 ff ff    	lea    -0xf66c(%ebx),%eax
f0100087:	50                   	push   %eax
f0100088:	e8 0a 0b 00 00       	call   f0100b97 <cprintf>
}
f010008d:	83 c4 10             	add    $0x10,%esp
f0100090:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100093:	5b                   	pop    %ebx
f0100094:	5e                   	pop    %esi
f0100095:	5d                   	pop    %ebp
f0100096:	c3                   	ret    
		mon_backtrace(0, 0, 0);
f0100097:	83 ec 04             	sub    $0x4,%esp
f010009a:	6a 00                	push   $0x0
f010009c:	6a 00                	push   $0x0
f010009e:	6a 00                	push   $0x0
f01000a0:	e8 3e 08 00 00       	call   f01008e3 <mon_backtrace>
f01000a5:	83 c4 10             	add    $0x10,%esp
f01000a8:	eb d3                	jmp    f010007d <test_backtrace+0x3d>

f01000aa <i386_init>:

void
i386_init(void)
{
f01000aa:	f3 0f 1e fb          	endbr32 
f01000ae:	55                   	push   %ebp
f01000af:	89 e5                	mov    %esp,%ebp
f01000b1:	53                   	push   %ebx
f01000b2:	83 ec 08             	sub    $0x8,%esp
f01000b5:	e8 20 01 00 00       	call   f01001da <__x86.get_pc_thunk.bx>
f01000ba:	81 c3 4e 12 01 00    	add    $0x1124e,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000c0:	c7 c2 60 30 11 f0    	mov    $0xf0113060,%edx
f01000c6:	c7 c0 c0 36 11 f0    	mov    $0xf01136c0,%eax
f01000cc:	29 d0                	sub    %edx,%eax
f01000ce:	50                   	push   %eax
f01000cf:	6a 00                	push   $0x0
f01000d1:	52                   	push   %edx
f01000d2:	e8 3b 17 00 00       	call   f0101812 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000d7:	e8 69 05 00 00       	call   f0100645 <cons_init>

	cprintf("Lab1_Exercise_8:\n");
f01000dc:	8d 83 af 09 ff ff    	lea    -0xf651(%ebx),%eax
f01000e2:	89 04 24             	mov    %eax,(%esp)
f01000e5:	e8 ad 0a 00 00       	call   f0100b97 <cprintf>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ea:	83 c4 08             	add    $0x8,%esp
f01000ed:	68 ac 1a 00 00       	push   $0x1aac
f01000f2:	8d 83 c1 09 ff ff    	lea    -0xf63f(%ebx),%eax
f01000f8:	50                   	push   %eax
f01000f9:	e8 99 0a 00 00       	call   f0100b97 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000fe:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100105:	e8 36 ff ff ff       	call   f0100040 <test_backtrace>
f010010a:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010010d:	83 ec 0c             	sub    $0xc,%esp
f0100110:	6a 00                	push   $0x0
f0100112:	e8 bb 08 00 00       	call   f01009d2 <monitor>
f0100117:	83 c4 10             	add    $0x10,%esp
f010011a:	eb f1                	jmp    f010010d <i386_init+0x63>

f010011c <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010011c:	f3 0f 1e fb          	endbr32 
f0100120:	55                   	push   %ebp
f0100121:	89 e5                	mov    %esp,%ebp
f0100123:	56                   	push   %esi
f0100124:	53                   	push   %ebx
f0100125:	e8 b0 00 00 00       	call   f01001da <__x86.get_pc_thunk.bx>
f010012a:	81 c3 de 11 01 00    	add    $0x111de,%ebx
	va_list ap;

	if (panicstr)
f0100130:	83 bb 58 1d 00 00 00 	cmpl   $0x0,0x1d58(%ebx)
f0100137:	74 0f                	je     f0100148 <_panic+0x2c>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100139:	83 ec 0c             	sub    $0xc,%esp
f010013c:	6a 00                	push   $0x0
f010013e:	e8 8f 08 00 00       	call   f01009d2 <monitor>
f0100143:	83 c4 10             	add    $0x10,%esp
f0100146:	eb f1                	jmp    f0100139 <_panic+0x1d>
	panicstr = fmt;
f0100148:	8b 45 10             	mov    0x10(%ebp),%eax
f010014b:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	asm volatile("cli; cld");
f0100151:	fa                   	cli    
f0100152:	fc                   	cld    
	va_start(ap, fmt);
f0100153:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f0100156:	83 ec 04             	sub    $0x4,%esp
f0100159:	ff 75 0c             	pushl  0xc(%ebp)
f010015c:	ff 75 08             	pushl  0x8(%ebp)
f010015f:	8d 83 dc 09 ff ff    	lea    -0xf624(%ebx),%eax
f0100165:	50                   	push   %eax
f0100166:	e8 2c 0a 00 00       	call   f0100b97 <cprintf>
	vcprintf(fmt, ap);
f010016b:	83 c4 08             	add    $0x8,%esp
f010016e:	56                   	push   %esi
f010016f:	ff 75 10             	pushl  0x10(%ebp)
f0100172:	e8 e5 09 00 00       	call   f0100b5c <vcprintf>
	cprintf("\n");
f0100177:	8d 83 18 0a ff ff    	lea    -0xf5e8(%ebx),%eax
f010017d:	89 04 24             	mov    %eax,(%esp)
f0100180:	e8 12 0a 00 00       	call   f0100b97 <cprintf>
f0100185:	83 c4 10             	add    $0x10,%esp
f0100188:	eb af                	jmp    f0100139 <_panic+0x1d>

f010018a <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010018a:	f3 0f 1e fb          	endbr32 
f010018e:	55                   	push   %ebp
f010018f:	89 e5                	mov    %esp,%ebp
f0100191:	56                   	push   %esi
f0100192:	53                   	push   %ebx
f0100193:	e8 42 00 00 00       	call   f01001da <__x86.get_pc_thunk.bx>
f0100198:	81 c3 70 11 01 00    	add    $0x11170,%ebx
	va_list ap;

	va_start(ap, fmt);
f010019e:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f01001a1:	83 ec 04             	sub    $0x4,%esp
f01001a4:	ff 75 0c             	pushl  0xc(%ebp)
f01001a7:	ff 75 08             	pushl  0x8(%ebp)
f01001aa:	8d 83 f4 09 ff ff    	lea    -0xf60c(%ebx),%eax
f01001b0:	50                   	push   %eax
f01001b1:	e8 e1 09 00 00       	call   f0100b97 <cprintf>
	vcprintf(fmt, ap);
f01001b6:	83 c4 08             	add    $0x8,%esp
f01001b9:	56                   	push   %esi
f01001ba:	ff 75 10             	pushl  0x10(%ebp)
f01001bd:	e8 9a 09 00 00       	call   f0100b5c <vcprintf>
	cprintf("\n");
f01001c2:	8d 83 18 0a ff ff    	lea    -0xf5e8(%ebx),%eax
f01001c8:	89 04 24             	mov    %eax,(%esp)
f01001cb:	e8 c7 09 00 00       	call   f0100b97 <cprintf>
	va_end(ap);
}
f01001d0:	83 c4 10             	add    $0x10,%esp
f01001d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001d6:	5b                   	pop    %ebx
f01001d7:	5e                   	pop    %esi
f01001d8:	5d                   	pop    %ebp
f01001d9:	c3                   	ret    

f01001da <__x86.get_pc_thunk.bx>:
f01001da:	8b 1c 24             	mov    (%esp),%ebx
f01001dd:	c3                   	ret    

f01001de <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001de:	f3 0f 1e fb          	endbr32 

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001e2:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001e7:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001e8:	a8 01                	test   $0x1,%al
f01001ea:	74 0a                	je     f01001f6 <serial_proc_data+0x18>
f01001ec:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001f1:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001f2:	0f b6 c0             	movzbl %al,%eax
f01001f5:	c3                   	ret    
		return -1;
f01001f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01001fb:	c3                   	ret    

f01001fc <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001fc:	55                   	push   %ebp
f01001fd:	89 e5                	mov    %esp,%ebp
f01001ff:	57                   	push   %edi
f0100200:	56                   	push   %esi
f0100201:	53                   	push   %ebx
f0100202:	83 ec 1c             	sub    $0x1c,%esp
f0100205:	e8 95 05 00 00       	call   f010079f <__x86.get_pc_thunk.si>
f010020a:	81 c6 fe 10 01 00    	add    $0x110fe,%esi
f0100210:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100212:	8d 1d 98 1d 00 00    	lea    0x1d98,%ebx
f0100218:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f010021b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010021e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f0100221:	eb 25                	jmp    f0100248 <cons_intr+0x4c>
		cons.buf[cons.wpos++] = c;
f0100223:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f010022a:	8d 51 01             	lea    0x1(%ecx),%edx
f010022d:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100230:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100233:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100239:	b8 00 00 00 00       	mov    $0x0,%eax
f010023e:	0f 44 d0             	cmove  %eax,%edx
f0100241:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
	while ((c = (*proc)()) != -1) {
f0100248:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010024b:	ff d0                	call   *%eax
f010024d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100250:	74 06                	je     f0100258 <cons_intr+0x5c>
		if (c == 0)
f0100252:	85 c0                	test   %eax,%eax
f0100254:	75 cd                	jne    f0100223 <cons_intr+0x27>
f0100256:	eb f0                	jmp    f0100248 <cons_intr+0x4c>
	}
}
f0100258:	83 c4 1c             	add    $0x1c,%esp
f010025b:	5b                   	pop    %ebx
f010025c:	5e                   	pop    %esi
f010025d:	5f                   	pop    %edi
f010025e:	5d                   	pop    %ebp
f010025f:	c3                   	ret    

f0100260 <kbd_proc_data>:
{
f0100260:	f3 0f 1e fb          	endbr32 
f0100264:	55                   	push   %ebp
f0100265:	89 e5                	mov    %esp,%ebp
f0100267:	56                   	push   %esi
f0100268:	53                   	push   %ebx
f0100269:	e8 6c ff ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f010026e:	81 c3 9a 10 01 00    	add    $0x1109a,%ebx
f0100274:	ba 64 00 00 00       	mov    $0x64,%edx
f0100279:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f010027a:	a8 01                	test   $0x1,%al
f010027c:	0f 84 f7 00 00 00    	je     f0100379 <kbd_proc_data+0x119>
	if (stat & KBS_TERR)
f0100282:	a8 20                	test   $0x20,%al
f0100284:	0f 85 f6 00 00 00    	jne    f0100380 <kbd_proc_data+0x120>
f010028a:	ba 60 00 00 00       	mov    $0x60,%edx
f010028f:	ec                   	in     (%dx),%al
f0100290:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100292:	3c e0                	cmp    $0xe0,%al
f0100294:	74 64                	je     f01002fa <kbd_proc_data+0x9a>
	} else if (data & 0x80) {
f0100296:	84 c0                	test   %al,%al
f0100298:	78 75                	js     f010030f <kbd_proc_data+0xaf>
	} else if (shift & E0ESC) {
f010029a:	8b 8b 78 1d 00 00    	mov    0x1d78(%ebx),%ecx
f01002a0:	f6 c1 40             	test   $0x40,%cl
f01002a3:	74 0e                	je     f01002b3 <kbd_proc_data+0x53>
		data |= 0x80;
f01002a5:	83 c8 80             	or     $0xffffff80,%eax
f01002a8:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01002aa:	83 e1 bf             	and    $0xffffffbf,%ecx
f01002ad:	89 8b 78 1d 00 00    	mov    %ecx,0x1d78(%ebx)
	shift |= shiftcode[data];
f01002b3:	0f b6 d2             	movzbl %dl,%edx
f01002b6:	0f b6 84 13 38 0b ff 	movzbl -0xf4c8(%ebx,%edx,1),%eax
f01002bd:	ff 
f01002be:	0b 83 78 1d 00 00    	or     0x1d78(%ebx),%eax
	shift ^= togglecode[data];
f01002c4:	0f b6 8c 13 38 0a ff 	movzbl -0xf5c8(%ebx,%edx,1),%ecx
f01002cb:	ff 
f01002cc:	31 c8                	xor    %ecx,%eax
f01002ce:	89 83 78 1d 00 00    	mov    %eax,0x1d78(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002d4:	89 c1                	mov    %eax,%ecx
f01002d6:	83 e1 03             	and    $0x3,%ecx
f01002d9:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002e0:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002e4:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002e7:	a8 08                	test   $0x8,%al
f01002e9:	74 61                	je     f010034c <kbd_proc_data+0xec>
		if ('a' <= c && c <= 'z')
f01002eb:	89 f2                	mov    %esi,%edx
f01002ed:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002f0:	83 f9 19             	cmp    $0x19,%ecx
f01002f3:	77 4b                	ja     f0100340 <kbd_proc_data+0xe0>
			c += 'A' - 'a';
f01002f5:	83 ee 20             	sub    $0x20,%esi
f01002f8:	eb 0c                	jmp    f0100306 <kbd_proc_data+0xa6>
		shift |= E0ESC;
f01002fa:	83 8b 78 1d 00 00 40 	orl    $0x40,0x1d78(%ebx)
		return 0;
f0100301:	be 00 00 00 00       	mov    $0x0,%esi
}
f0100306:	89 f0                	mov    %esi,%eax
f0100308:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010030b:	5b                   	pop    %ebx
f010030c:	5e                   	pop    %esi
f010030d:	5d                   	pop    %ebp
f010030e:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010030f:	8b 8b 78 1d 00 00    	mov    0x1d78(%ebx),%ecx
f0100315:	83 e0 7f             	and    $0x7f,%eax
f0100318:	f6 c1 40             	test   $0x40,%cl
f010031b:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010031e:	0f b6 d2             	movzbl %dl,%edx
f0100321:	0f b6 84 13 38 0b ff 	movzbl -0xf4c8(%ebx,%edx,1),%eax
f0100328:	ff 
f0100329:	83 c8 40             	or     $0x40,%eax
f010032c:	0f b6 c0             	movzbl %al,%eax
f010032f:	f7 d0                	not    %eax
f0100331:	21 c8                	and    %ecx,%eax
f0100333:	89 83 78 1d 00 00    	mov    %eax,0x1d78(%ebx)
		return 0;
f0100339:	be 00 00 00 00       	mov    $0x0,%esi
f010033e:	eb c6                	jmp    f0100306 <kbd_proc_data+0xa6>
		else if ('A' <= c && c <= 'Z')
f0100340:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100343:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100346:	83 fa 1a             	cmp    $0x1a,%edx
f0100349:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010034c:	f7 d0                	not    %eax
f010034e:	a8 06                	test   $0x6,%al
f0100350:	75 b4                	jne    f0100306 <kbd_proc_data+0xa6>
f0100352:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f0100358:	75 ac                	jne    f0100306 <kbd_proc_data+0xa6>
		cprintf("Rebooting!\n");
f010035a:	83 ec 0c             	sub    $0xc,%esp
f010035d:	8d 83 0e 0a ff ff    	lea    -0xf5f2(%ebx),%eax
f0100363:	50                   	push   %eax
f0100364:	e8 2e 08 00 00       	call   f0100b97 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100369:	b8 03 00 00 00       	mov    $0x3,%eax
f010036e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100373:	ee                   	out    %al,(%dx)
}
f0100374:	83 c4 10             	add    $0x10,%esp
f0100377:	eb 8d                	jmp    f0100306 <kbd_proc_data+0xa6>
		return -1;
f0100379:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010037e:	eb 86                	jmp    f0100306 <kbd_proc_data+0xa6>
		return -1;
f0100380:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100385:	e9 7c ff ff ff       	jmp    f0100306 <kbd_proc_data+0xa6>

f010038a <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010038a:	55                   	push   %ebp
f010038b:	89 e5                	mov    %esp,%ebp
f010038d:	57                   	push   %edi
f010038e:	56                   	push   %esi
f010038f:	53                   	push   %ebx
f0100390:	83 ec 1c             	sub    $0x1c,%esp
f0100393:	e8 42 fe ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f0100398:	81 c3 70 0f 01 00    	add    $0x10f70,%ebx
f010039e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f01003a1:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003a6:	bf fd 03 00 00       	mov    $0x3fd,%edi
f01003ab:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003b0:	89 fa                	mov    %edi,%edx
f01003b2:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003b3:	a8 20                	test   $0x20,%al
f01003b5:	75 13                	jne    f01003ca <cons_putc+0x40>
f01003b7:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003bd:	7f 0b                	jg     f01003ca <cons_putc+0x40>
f01003bf:	89 ca                	mov    %ecx,%edx
f01003c1:	ec                   	in     (%dx),%al
f01003c2:	ec                   	in     (%dx),%al
f01003c3:	ec                   	in     (%dx),%al
f01003c4:	ec                   	in     (%dx),%al
	     i++)
f01003c5:	83 c6 01             	add    $0x1,%esi
f01003c8:	eb e6                	jmp    f01003b0 <cons_putc+0x26>
	outb(COM1 + COM_TX, c);
f01003ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003cd:	89 f8                	mov    %edi,%eax
f01003cf:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003d2:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003d7:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003d8:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003dd:	bf 79 03 00 00       	mov    $0x379,%edi
f01003e2:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003e7:	89 fa                	mov    %edi,%edx
f01003e9:	ec                   	in     (%dx),%al
f01003ea:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003f0:	7f 0f                	jg     f0100401 <cons_putc+0x77>
f01003f2:	84 c0                	test   %al,%al
f01003f4:	78 0b                	js     f0100401 <cons_putc+0x77>
f01003f6:	89 ca                	mov    %ecx,%edx
f01003f8:	ec                   	in     (%dx),%al
f01003f9:	ec                   	in     (%dx),%al
f01003fa:	ec                   	in     (%dx),%al
f01003fb:	ec                   	in     (%dx),%al
f01003fc:	83 c6 01             	add    $0x1,%esi
f01003ff:	eb e6                	jmp    f01003e7 <cons_putc+0x5d>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100401:	ba 78 03 00 00       	mov    $0x378,%edx
f0100406:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f010040a:	ee                   	out    %al,(%dx)
f010040b:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100410:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100415:	ee                   	out    %al,(%dx)
f0100416:	b8 08 00 00 00       	mov    $0x8,%eax
f010041b:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f010041c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010041f:	89 f8                	mov    %edi,%eax
f0100421:	80 cc 07             	or     $0x7,%ah
f0100424:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f010042a:	0f 45 c7             	cmovne %edi,%eax
f010042d:	89 c7                	mov    %eax,%edi
f010042f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f0100432:	0f b6 c0             	movzbl %al,%eax
f0100435:	89 f9                	mov    %edi,%ecx
f0100437:	80 f9 0a             	cmp    $0xa,%cl
f010043a:	0f 84 e4 00 00 00    	je     f0100524 <cons_putc+0x19a>
f0100440:	83 f8 0a             	cmp    $0xa,%eax
f0100443:	7f 46                	jg     f010048b <cons_putc+0x101>
f0100445:	83 f8 08             	cmp    $0x8,%eax
f0100448:	0f 84 a8 00 00 00    	je     f01004f6 <cons_putc+0x16c>
f010044e:	83 f8 09             	cmp    $0x9,%eax
f0100451:	0f 85 da 00 00 00    	jne    f0100531 <cons_putc+0x1a7>
		cons_putc(' ');
f0100457:	b8 20 00 00 00       	mov    $0x20,%eax
f010045c:	e8 29 ff ff ff       	call   f010038a <cons_putc>
		cons_putc(' ');
f0100461:	b8 20 00 00 00       	mov    $0x20,%eax
f0100466:	e8 1f ff ff ff       	call   f010038a <cons_putc>
		cons_putc(' ');
f010046b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100470:	e8 15 ff ff ff       	call   f010038a <cons_putc>
		cons_putc(' ');
f0100475:	b8 20 00 00 00       	mov    $0x20,%eax
f010047a:	e8 0b ff ff ff       	call   f010038a <cons_putc>
		cons_putc(' ');
f010047f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100484:	e8 01 ff ff ff       	call   f010038a <cons_putc>
		break;
f0100489:	eb 26                	jmp    f01004b1 <cons_putc+0x127>
	switch (c & 0xff) {
f010048b:	83 f8 0d             	cmp    $0xd,%eax
f010048e:	0f 85 9d 00 00 00    	jne    f0100531 <cons_putc+0x1a7>
		crt_pos -= (crt_pos % CRT_COLS);
f0100494:	0f b7 83 a0 1f 00 00 	movzwl 0x1fa0(%ebx),%eax
f010049b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004a1:	c1 e8 16             	shr    $0x16,%eax
f01004a4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004a7:	c1 e0 04             	shl    $0x4,%eax
f01004aa:	66 89 83 a0 1f 00 00 	mov    %ax,0x1fa0(%ebx)
	if (crt_pos >= CRT_SIZE) {
f01004b1:	66 81 bb a0 1f 00 00 	cmpw   $0x7cf,0x1fa0(%ebx)
f01004b8:	cf 07 
f01004ba:	0f 87 98 00 00 00    	ja     f0100558 <cons_putc+0x1ce>
	outb(addr_6845, 14);
f01004c0:	8b 8b a8 1f 00 00    	mov    0x1fa8(%ebx),%ecx
f01004c6:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004cb:	89 ca                	mov    %ecx,%edx
f01004cd:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004ce:	0f b7 9b a0 1f 00 00 	movzwl 0x1fa0(%ebx),%ebx
f01004d5:	8d 71 01             	lea    0x1(%ecx),%esi
f01004d8:	89 d8                	mov    %ebx,%eax
f01004da:	66 c1 e8 08          	shr    $0x8,%ax
f01004de:	89 f2                	mov    %esi,%edx
f01004e0:	ee                   	out    %al,(%dx)
f01004e1:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004e6:	89 ca                	mov    %ecx,%edx
f01004e8:	ee                   	out    %al,(%dx)
f01004e9:	89 d8                	mov    %ebx,%eax
f01004eb:	89 f2                	mov    %esi,%edx
f01004ed:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004f1:	5b                   	pop    %ebx
f01004f2:	5e                   	pop    %esi
f01004f3:	5f                   	pop    %edi
f01004f4:	5d                   	pop    %ebp
f01004f5:	c3                   	ret    
		if (crt_pos > 0) {
f01004f6:	0f b7 83 a0 1f 00 00 	movzwl 0x1fa0(%ebx),%eax
f01004fd:	66 85 c0             	test   %ax,%ax
f0100500:	74 be                	je     f01004c0 <cons_putc+0x136>
			crt_pos--;
f0100502:	83 e8 01             	sub    $0x1,%eax
f0100505:	66 89 83 a0 1f 00 00 	mov    %ax,0x1fa0(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010050c:	0f b7 c0             	movzwl %ax,%eax
f010050f:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f0100513:	b2 00                	mov    $0x0,%dl
f0100515:	83 ca 20             	or     $0x20,%edx
f0100518:	8b 8b a4 1f 00 00    	mov    0x1fa4(%ebx),%ecx
f010051e:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f0100522:	eb 8d                	jmp    f01004b1 <cons_putc+0x127>
		crt_pos += CRT_COLS;
f0100524:	66 83 83 a0 1f 00 00 	addw   $0x50,0x1fa0(%ebx)
f010052b:	50 
f010052c:	e9 63 ff ff ff       	jmp    f0100494 <cons_putc+0x10a>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100531:	0f b7 83 a0 1f 00 00 	movzwl 0x1fa0(%ebx),%eax
f0100538:	8d 50 01             	lea    0x1(%eax),%edx
f010053b:	66 89 93 a0 1f 00 00 	mov    %dx,0x1fa0(%ebx)
f0100542:	0f b7 c0             	movzwl %ax,%eax
f0100545:	8b 93 a4 1f 00 00    	mov    0x1fa4(%ebx),%edx
f010054b:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f010054f:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f0100553:	e9 59 ff ff ff       	jmp    f01004b1 <cons_putc+0x127>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100558:	8b 83 a4 1f 00 00    	mov    0x1fa4(%ebx),%eax
f010055e:	83 ec 04             	sub    $0x4,%esp
f0100561:	68 00 0f 00 00       	push   $0xf00
f0100566:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010056c:	52                   	push   %edx
f010056d:	50                   	push   %eax
f010056e:	e8 eb 12 00 00       	call   f010185e <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100573:	8b 93 a4 1f 00 00    	mov    0x1fa4(%ebx),%edx
f0100579:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010057f:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100585:	83 c4 10             	add    $0x10,%esp
f0100588:	66 c7 00 20 07       	movw   $0x720,(%eax)
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010058d:	83 c0 02             	add    $0x2,%eax
f0100590:	39 d0                	cmp    %edx,%eax
f0100592:	75 f4                	jne    f0100588 <cons_putc+0x1fe>
		crt_pos -= CRT_COLS;
f0100594:	66 83 ab a0 1f 00 00 	subw   $0x50,0x1fa0(%ebx)
f010059b:	50 
f010059c:	e9 1f ff ff ff       	jmp    f01004c0 <cons_putc+0x136>

f01005a1 <serial_intr>:
{
f01005a1:	f3 0f 1e fb          	endbr32 
f01005a5:	e8 f1 01 00 00       	call   f010079b <__x86.get_pc_thunk.ax>
f01005aa:	05 5e 0d 01 00       	add    $0x10d5e,%eax
	if (serial_exists)
f01005af:	80 b8 ac 1f 00 00 00 	cmpb   $0x0,0x1fac(%eax)
f01005b6:	75 01                	jne    f01005b9 <serial_intr+0x18>
f01005b8:	c3                   	ret    
{
f01005b9:	55                   	push   %ebp
f01005ba:	89 e5                	mov    %esp,%ebp
f01005bc:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005bf:	8d 80 d6 ee fe ff    	lea    -0x1112a(%eax),%eax
f01005c5:	e8 32 fc ff ff       	call   f01001fc <cons_intr>
}
f01005ca:	c9                   	leave  
f01005cb:	c3                   	ret    

f01005cc <kbd_intr>:
{
f01005cc:	f3 0f 1e fb          	endbr32 
f01005d0:	55                   	push   %ebp
f01005d1:	89 e5                	mov    %esp,%ebp
f01005d3:	83 ec 08             	sub    $0x8,%esp
f01005d6:	e8 c0 01 00 00       	call   f010079b <__x86.get_pc_thunk.ax>
f01005db:	05 2d 0d 01 00       	add    $0x10d2d,%eax
	cons_intr(kbd_proc_data);
f01005e0:	8d 80 58 ef fe ff    	lea    -0x110a8(%eax),%eax
f01005e6:	e8 11 fc ff ff       	call   f01001fc <cons_intr>
}
f01005eb:	c9                   	leave  
f01005ec:	c3                   	ret    

f01005ed <cons_getc>:
{
f01005ed:	f3 0f 1e fb          	endbr32 
f01005f1:	55                   	push   %ebp
f01005f2:	89 e5                	mov    %esp,%ebp
f01005f4:	53                   	push   %ebx
f01005f5:	83 ec 04             	sub    $0x4,%esp
f01005f8:	e8 dd fb ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f01005fd:	81 c3 0b 0d 01 00    	add    $0x10d0b,%ebx
	serial_intr();
f0100603:	e8 99 ff ff ff       	call   f01005a1 <serial_intr>
	kbd_intr();
f0100608:	e8 bf ff ff ff       	call   f01005cc <kbd_intr>
	if (cons.rpos != cons.wpos) {
f010060d:	8b 83 98 1f 00 00    	mov    0x1f98(%ebx),%eax
	return 0;
f0100613:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f0100618:	3b 83 9c 1f 00 00    	cmp    0x1f9c(%ebx),%eax
f010061e:	74 1e                	je     f010063e <cons_getc+0x51>
		c = cons.buf[cons.rpos++];
f0100620:	8d 48 01             	lea    0x1(%eax),%ecx
f0100623:	0f b6 94 03 98 1d 00 	movzbl 0x1d98(%ebx,%eax,1),%edx
f010062a:	00 
			cons.rpos = 0;
f010062b:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f0100630:	b8 00 00 00 00       	mov    $0x0,%eax
f0100635:	0f 45 c1             	cmovne %ecx,%eax
f0100638:	89 83 98 1f 00 00    	mov    %eax,0x1f98(%ebx)
}
f010063e:	89 d0                	mov    %edx,%eax
f0100640:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100643:	c9                   	leave  
f0100644:	c3                   	ret    

f0100645 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100645:	f3 0f 1e fb          	endbr32 
f0100649:	55                   	push   %ebp
f010064a:	89 e5                	mov    %esp,%ebp
f010064c:	57                   	push   %edi
f010064d:	56                   	push   %esi
f010064e:	53                   	push   %ebx
f010064f:	83 ec 1c             	sub    $0x1c,%esp
f0100652:	e8 83 fb ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f0100657:	81 c3 b1 0c 01 00    	add    $0x10cb1,%ebx
	was = *cp;
f010065d:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100664:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010066b:	5a a5 
	if (*cp != 0xA55A) {
f010066d:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100674:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100678:	0f 84 bb 00 00 00    	je     f0100739 <cons_init+0xf4>
		addr_6845 = MONO_BASE;
f010067e:	c7 83 a8 1f 00 00 b4 	movl   $0x3b4,0x1fa8(%ebx)
f0100685:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100688:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
	outb(addr_6845, 14);
f010068d:	8b 8b a8 1f 00 00    	mov    0x1fa8(%ebx),%ecx
f0100693:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100698:	89 ca                	mov    %ecx,%edx
f010069a:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010069b:	8d 71 01             	lea    0x1(%ecx),%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010069e:	89 f2                	mov    %esi,%edx
f01006a0:	ec                   	in     (%dx),%al
f01006a1:	0f b6 c0             	movzbl %al,%eax
f01006a4:	c1 e0 08             	shl    $0x8,%eax
f01006a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006aa:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006af:	89 ca                	mov    %ecx,%edx
f01006b1:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006b2:	89 f2                	mov    %esi,%edx
f01006b4:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01006b5:	89 bb a4 1f 00 00    	mov    %edi,0x1fa4(%ebx)
	pos |= inb(addr_6845 + 1);
f01006bb:	0f b6 c0             	movzbl %al,%eax
f01006be:	0b 45 e4             	or     -0x1c(%ebp),%eax
	crt_pos = pos;
f01006c1:	66 89 83 a0 1f 00 00 	mov    %ax,0x1fa0(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006c8:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006cd:	89 c8                	mov    %ecx,%eax
f01006cf:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006d4:	ee                   	out    %al,(%dx)
f01006d5:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006da:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006df:	89 fa                	mov    %edi,%edx
f01006e1:	ee                   	out    %al,(%dx)
f01006e2:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006e7:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006ec:	ee                   	out    %al,(%dx)
f01006ed:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006f2:	89 c8                	mov    %ecx,%eax
f01006f4:	89 f2                	mov    %esi,%edx
f01006f6:	ee                   	out    %al,(%dx)
f01006f7:	b8 03 00 00 00       	mov    $0x3,%eax
f01006fc:	89 fa                	mov    %edi,%edx
f01006fe:	ee                   	out    %al,(%dx)
f01006ff:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100704:	89 c8                	mov    %ecx,%eax
f0100706:	ee                   	out    %al,(%dx)
f0100707:	b8 01 00 00 00       	mov    $0x1,%eax
f010070c:	89 f2                	mov    %esi,%edx
f010070e:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010070f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100714:	ec                   	in     (%dx),%al
f0100715:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100717:	3c ff                	cmp    $0xff,%al
f0100719:	0f 95 83 ac 1f 00 00 	setne  0x1fac(%ebx)
f0100720:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100725:	ec                   	in     (%dx),%al
f0100726:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010072b:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010072c:	80 f9 ff             	cmp    $0xff,%cl
f010072f:	74 23                	je     f0100754 <cons_init+0x10f>
		cprintf("Serial port does not exist!\n");
}
f0100731:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100734:	5b                   	pop    %ebx
f0100735:	5e                   	pop    %esi
f0100736:	5f                   	pop    %edi
f0100737:	5d                   	pop    %ebp
f0100738:	c3                   	ret    
		*cp = was;
f0100739:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100740:	c7 83 a8 1f 00 00 d4 	movl   $0x3d4,0x1fa8(%ebx)
f0100747:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010074a:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
f010074f:	e9 39 ff ff ff       	jmp    f010068d <cons_init+0x48>
		cprintf("Serial port does not exist!\n");
f0100754:	83 ec 0c             	sub    $0xc,%esp
f0100757:	8d 83 1a 0a ff ff    	lea    -0xf5e6(%ebx),%eax
f010075d:	50                   	push   %eax
f010075e:	e8 34 04 00 00       	call   f0100b97 <cprintf>
f0100763:	83 c4 10             	add    $0x10,%esp
}
f0100766:	eb c9                	jmp    f0100731 <cons_init+0xec>

f0100768 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100768:	f3 0f 1e fb          	endbr32 
f010076c:	55                   	push   %ebp
f010076d:	89 e5                	mov    %esp,%ebp
f010076f:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100772:	8b 45 08             	mov    0x8(%ebp),%eax
f0100775:	e8 10 fc ff ff       	call   f010038a <cons_putc>
}
f010077a:	c9                   	leave  
f010077b:	c3                   	ret    

f010077c <getchar>:

int
getchar(void)
{
f010077c:	f3 0f 1e fb          	endbr32 
f0100780:	55                   	push   %ebp
f0100781:	89 e5                	mov    %esp,%ebp
f0100783:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100786:	e8 62 fe ff ff       	call   f01005ed <cons_getc>
f010078b:	85 c0                	test   %eax,%eax
f010078d:	74 f7                	je     f0100786 <getchar+0xa>
		/* do nothing */;
	return c;
}
f010078f:	c9                   	leave  
f0100790:	c3                   	ret    

f0100791 <iscons>:

int
iscons(int fdnum)
{
f0100791:	f3 0f 1e fb          	endbr32 
	// used by readline
	return 1;
}
f0100795:	b8 01 00 00 00       	mov    $0x1,%eax
f010079a:	c3                   	ret    

f010079b <__x86.get_pc_thunk.ax>:
f010079b:	8b 04 24             	mov    (%esp),%eax
f010079e:	c3                   	ret    

f010079f <__x86.get_pc_thunk.si>:
f010079f:	8b 34 24             	mov    (%esp),%esi
f01007a2:	c3                   	ret    

f01007a3 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007a3:	f3 0f 1e fb          	endbr32 
f01007a7:	55                   	push   %ebp
f01007a8:	89 e5                	mov    %esp,%ebp
f01007aa:	56                   	push   %esi
f01007ab:	53                   	push   %ebx
f01007ac:	e8 29 fa ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f01007b1:	81 c3 57 0b 01 00    	add    $0x10b57,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007b7:	83 ec 04             	sub    $0x4,%esp
f01007ba:	8d 83 38 0c ff ff    	lea    -0xf3c8(%ebx),%eax
f01007c0:	50                   	push   %eax
f01007c1:	8d 83 56 0c ff ff    	lea    -0xf3aa(%ebx),%eax
f01007c7:	50                   	push   %eax
f01007c8:	8d b3 5b 0c ff ff    	lea    -0xf3a5(%ebx),%esi
f01007ce:	56                   	push   %esi
f01007cf:	e8 c3 03 00 00       	call   f0100b97 <cprintf>
f01007d4:	83 c4 0c             	add    $0xc,%esp
f01007d7:	8d 83 24 0d ff ff    	lea    -0xf2dc(%ebx),%eax
f01007dd:	50                   	push   %eax
f01007de:	8d 83 64 0c ff ff    	lea    -0xf39c(%ebx),%eax
f01007e4:	50                   	push   %eax
f01007e5:	56                   	push   %esi
f01007e6:	e8 ac 03 00 00       	call   f0100b97 <cprintf>
f01007eb:	83 c4 0c             	add    $0xc,%esp
f01007ee:	8d 83 6d 0c ff ff    	lea    -0xf393(%ebx),%eax
f01007f4:	50                   	push   %eax
f01007f5:	8d 83 83 0c ff ff    	lea    -0xf37d(%ebx),%eax
f01007fb:	50                   	push   %eax
f01007fc:	56                   	push   %esi
f01007fd:	e8 95 03 00 00       	call   f0100b97 <cprintf>
	return 0;
}
f0100802:	b8 00 00 00 00       	mov    $0x0,%eax
f0100807:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010080a:	5b                   	pop    %ebx
f010080b:	5e                   	pop    %esi
f010080c:	5d                   	pop    %ebp
f010080d:	c3                   	ret    

f010080e <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010080e:	f3 0f 1e fb          	endbr32 
f0100812:	55                   	push   %ebp
f0100813:	89 e5                	mov    %esp,%ebp
f0100815:	57                   	push   %edi
f0100816:	56                   	push   %esi
f0100817:	53                   	push   %ebx
f0100818:	83 ec 18             	sub    $0x18,%esp
f010081b:	e8 ba f9 ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f0100820:	81 c3 e8 0a 01 00    	add    $0x10ae8,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100826:	8d 83 8d 0c ff ff    	lea    -0xf373(%ebx),%eax
f010082c:	50                   	push   %eax
f010082d:	e8 65 03 00 00       	call   f0100b97 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100832:	83 c4 08             	add    $0x8,%esp
f0100835:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f010083b:	8d 83 4c 0d ff ff    	lea    -0xf2b4(%ebx),%eax
f0100841:	50                   	push   %eax
f0100842:	e8 50 03 00 00       	call   f0100b97 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100847:	83 c4 0c             	add    $0xc,%esp
f010084a:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f0100850:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100856:	50                   	push   %eax
f0100857:	57                   	push   %edi
f0100858:	8d 83 74 0d ff ff    	lea    -0xf28c(%ebx),%eax
f010085e:	50                   	push   %eax
f010085f:	e8 33 03 00 00       	call   f0100b97 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100864:	83 c4 0c             	add    $0xc,%esp
f0100867:	c7 c0 7d 1c 10 f0    	mov    $0xf0101c7d,%eax
f010086d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100873:	52                   	push   %edx
f0100874:	50                   	push   %eax
f0100875:	8d 83 98 0d ff ff    	lea    -0xf268(%ebx),%eax
f010087b:	50                   	push   %eax
f010087c:	e8 16 03 00 00       	call   f0100b97 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100881:	83 c4 0c             	add    $0xc,%esp
f0100884:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f010088a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100890:	52                   	push   %edx
f0100891:	50                   	push   %eax
f0100892:	8d 83 bc 0d ff ff    	lea    -0xf244(%ebx),%eax
f0100898:	50                   	push   %eax
f0100899:	e8 f9 02 00 00       	call   f0100b97 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010089e:	83 c4 0c             	add    $0xc,%esp
f01008a1:	c7 c6 c0 36 11 f0    	mov    $0xf01136c0,%esi
f01008a7:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01008ad:	50                   	push   %eax
f01008ae:	56                   	push   %esi
f01008af:	8d 83 e0 0d ff ff    	lea    -0xf220(%ebx),%eax
f01008b5:	50                   	push   %eax
f01008b6:	e8 dc 02 00 00       	call   f0100b97 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008bb:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01008be:	29 fe                	sub    %edi,%esi
f01008c0:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008c6:	c1 fe 0a             	sar    $0xa,%esi
f01008c9:	56                   	push   %esi
f01008ca:	8d 83 04 0e ff ff    	lea    -0xf1fc(%ebx),%eax
f01008d0:	50                   	push   %eax
f01008d1:	e8 c1 02 00 00       	call   f0100b97 <cprintf>
	return 0;
}
f01008d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01008db:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008de:	5b                   	pop    %ebx
f01008df:	5e                   	pop    %esi
f01008e0:	5f                   	pop    %edi
f01008e1:	5d                   	pop    %ebp
f01008e2:	c3                   	ret    

f01008e3 <mon_backtrace>:
		//        |            |   |
		// %esp-> +------------+   /

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008e3:	f3 0f 1e fb          	endbr32 
f01008e7:	55                   	push   %ebp
f01008e8:	89 e5                	mov    %esp,%ebp
f01008ea:	57                   	push   %edi
f01008eb:	56                   	push   %esi
f01008ec:	53                   	push   %ebx
f01008ed:	83 ec 48             	sub    $0x48,%esp
f01008f0:	e8 e5 f8 ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f01008f5:	81 c3 13 0a 01 00    	add    $0x10a13,%ebx
	cprintf("Stack backtrace:\n");
f01008fb:	8d 83 a6 0c ff ff    	lea    -0xf35a(%ebx),%eax
f0100901:	50                   	push   %eax
f0100902:	e8 90 02 00 00       	call   f0100b97 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100907:	89 e8                	mov    %ebp,%eax
	uint32_t *ebp;
	struct Eipdebuginfo info;
	int ret;

	ebp = (uint32_t *)read_ebp();
f0100909:	89 c7                	mov    %eax,%edi
	while (ebp != 0) {
f010090b:	83 c4 10             	add    $0x10,%esp
		cprintf("  ebp %08x", ebp);
f010090e:	8d 83 b8 0c ff ff    	lea    -0xf348(%ebx),%eax
f0100914:	89 45 bc             	mov    %eax,-0x44(%ebp)
		cprintf(" eip %08x  args", *(ebp+1));
f0100917:	8d 83 c3 0c ff ff    	lea    -0xf33d(%ebx),%eax
f010091d:	89 45 b8             	mov    %eax,-0x48(%ebp)
	while (ebp != 0) {
f0100920:	eb 02                	jmp    f0100924 <mon_backtrace+0x41>

		ret = debuginfo_eip(*(ebp+1), &info);

		if (ret == 0)
			cprintf("    %s: %d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, *(ebp+1) - info.eip_fn_addr);
		ebp = (uint32_t *)*ebp;
f0100922:	8b 3f                	mov    (%edi),%edi
	while (ebp != 0) {
f0100924:	85 ff                	test   %edi,%edi
f0100926:	0f 84 99 00 00 00    	je     f01009c5 <mon_backtrace+0xe2>
		cprintf("  ebp %08x", ebp);
f010092c:	83 ec 08             	sub    $0x8,%esp
f010092f:	57                   	push   %edi
f0100930:	ff 75 bc             	pushl  -0x44(%ebp)
f0100933:	e8 5f 02 00 00       	call   f0100b97 <cprintf>
		cprintf(" eip %08x  args", *(ebp+1));
f0100938:	83 c4 08             	add    $0x8,%esp
f010093b:	ff 77 04             	pushl  0x4(%edi)
f010093e:	ff 75 b8             	pushl  -0x48(%ebp)
f0100941:	e8 51 02 00 00       	call   f0100b97 <cprintf>
f0100946:	8d 77 08             	lea    0x8(%edi),%esi
f0100949:	8d 47 1c             	lea    0x1c(%edi),%eax
f010094c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010094f:	83 c4 10             	add    $0x10,%esp
			cprintf(" %08x", *(ebp+i));
f0100952:	8d 83 bd 0c ff ff    	lea    -0xf343(%ebx),%eax
f0100958:	89 7d c0             	mov    %edi,-0x40(%ebp)
f010095b:	89 c7                	mov    %eax,%edi
f010095d:	83 ec 08             	sub    $0x8,%esp
f0100960:	ff 36                	pushl  (%esi)
f0100962:	57                   	push   %edi
f0100963:	e8 2f 02 00 00       	call   f0100b97 <cprintf>
		for (int i = 2; i < 7; ++i)
f0100968:	83 c6 04             	add    $0x4,%esi
f010096b:	83 c4 10             	add    $0x10,%esp
f010096e:	3b 75 c4             	cmp    -0x3c(%ebp),%esi
f0100971:	75 ea                	jne    f010095d <mon_backtrace+0x7a>
		cprintf("\n");
f0100973:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0100976:	83 ec 0c             	sub    $0xc,%esp
f0100979:	8d 83 18 0a ff ff    	lea    -0xf5e8(%ebx),%eax
f010097f:	50                   	push   %eax
f0100980:	e8 12 02 00 00       	call   f0100b97 <cprintf>
		ret = debuginfo_eip(*(ebp+1), &info);
f0100985:	83 c4 08             	add    $0x8,%esp
f0100988:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010098b:	50                   	push   %eax
f010098c:	ff 77 04             	pushl  0x4(%edi)
f010098f:	e8 10 03 00 00       	call   f0100ca4 <debuginfo_eip>
		if (ret == 0)
f0100994:	83 c4 10             	add    $0x10,%esp
f0100997:	85 c0                	test   %eax,%eax
f0100999:	75 87                	jne    f0100922 <mon_backtrace+0x3f>
			cprintf("    %s: %d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, *(ebp+1) - info.eip_fn_addr);
f010099b:	83 ec 08             	sub    $0x8,%esp
f010099e:	8b 47 04             	mov    0x4(%edi),%eax
f01009a1:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01009a4:	50                   	push   %eax
f01009a5:	ff 75 d8             	pushl  -0x28(%ebp)
f01009a8:	ff 75 dc             	pushl  -0x24(%ebp)
f01009ab:	ff 75 d4             	pushl  -0x2c(%ebp)
f01009ae:	ff 75 d0             	pushl  -0x30(%ebp)
f01009b1:	8d 83 d3 0c ff ff    	lea    -0xf32d(%ebx),%eax
f01009b7:	50                   	push   %eax
f01009b8:	e8 da 01 00 00       	call   f0100b97 <cprintf>
f01009bd:	83 c4 20             	add    $0x20,%esp
f01009c0:	e9 5d ff ff ff       	jmp    f0100922 <mon_backtrace+0x3f>

	}
	return 0;
}
f01009c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01009ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009cd:	5b                   	pop    %ebx
f01009ce:	5e                   	pop    %esi
f01009cf:	5f                   	pop    %edi
f01009d0:	5d                   	pop    %ebp
f01009d1:	c3                   	ret    

f01009d2 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009d2:	f3 0f 1e fb          	endbr32 
f01009d6:	55                   	push   %ebp
f01009d7:	89 e5                	mov    %esp,%ebp
f01009d9:	57                   	push   %edi
f01009da:	56                   	push   %esi
f01009db:	53                   	push   %ebx
f01009dc:	83 ec 68             	sub    $0x68,%esp
f01009df:	e8 f6 f7 ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f01009e4:	81 c3 24 09 01 00    	add    $0x10924,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009ea:	8d 83 30 0e ff ff    	lea    -0xf1d0(%ebx),%eax
f01009f0:	50                   	push   %eax
f01009f1:	e8 a1 01 00 00       	call   f0100b97 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009f6:	8d 83 54 0e ff ff    	lea    -0xf1ac(%ebx),%eax
f01009fc:	89 04 24             	mov    %eax,(%esp)
f01009ff:	e8 93 01 00 00       	call   f0100b97 <cprintf>
f0100a04:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100a07:	8d bb ec 0c ff ff    	lea    -0xf314(%ebx),%edi
f0100a0d:	eb 4a                	jmp    f0100a59 <monitor+0x87>
f0100a0f:	83 ec 08             	sub    $0x8,%esp
f0100a12:	0f be c0             	movsbl %al,%eax
f0100a15:	50                   	push   %eax
f0100a16:	57                   	push   %edi
f0100a17:	e8 af 0d 00 00       	call   f01017cb <strchr>
f0100a1c:	83 c4 10             	add    $0x10,%esp
f0100a1f:	85 c0                	test   %eax,%eax
f0100a21:	74 08                	je     f0100a2b <monitor+0x59>
			*buf++ = 0;
f0100a23:	c6 06 00             	movb   $0x0,(%esi)
f0100a26:	8d 76 01             	lea    0x1(%esi),%esi
f0100a29:	eb 76                	jmp    f0100aa1 <monitor+0xcf>
		if (*buf == 0)
f0100a2b:	80 3e 00             	cmpb   $0x0,(%esi)
f0100a2e:	74 7c                	je     f0100aac <monitor+0xda>
		if (argc == MAXARGS-1) {
f0100a30:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f0100a34:	74 0f                	je     f0100a45 <monitor+0x73>
		argv[argc++] = buf;
f0100a36:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a39:	8d 48 01             	lea    0x1(%eax),%ecx
f0100a3c:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f0100a3f:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a43:	eb 41                	jmp    f0100a86 <monitor+0xb4>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a45:	83 ec 08             	sub    $0x8,%esp
f0100a48:	6a 10                	push   $0x10
f0100a4a:	8d 83 f1 0c ff ff    	lea    -0xf30f(%ebx),%eax
f0100a50:	50                   	push   %eax
f0100a51:	e8 41 01 00 00       	call   f0100b97 <cprintf>
			return 0;
f0100a56:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100a59:	8d 83 e8 0c ff ff    	lea    -0xf318(%ebx),%eax
f0100a5f:	89 c6                	mov    %eax,%esi
f0100a61:	83 ec 0c             	sub    $0xc,%esp
f0100a64:	56                   	push   %esi
f0100a65:	e8 ea 0a 00 00       	call   f0101554 <readline>
		if (buf != NULL)
f0100a6a:	83 c4 10             	add    $0x10,%esp
f0100a6d:	85 c0                	test   %eax,%eax
f0100a6f:	74 f0                	je     f0100a61 <monitor+0x8f>
	argv[argc] = 0;
f0100a71:	89 c6                	mov    %eax,%esi
f0100a73:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a7a:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0100a81:	eb 1e                	jmp    f0100aa1 <monitor+0xcf>
			buf++;
f0100a83:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a86:	0f b6 06             	movzbl (%esi),%eax
f0100a89:	84 c0                	test   %al,%al
f0100a8b:	74 14                	je     f0100aa1 <monitor+0xcf>
f0100a8d:	83 ec 08             	sub    $0x8,%esp
f0100a90:	0f be c0             	movsbl %al,%eax
f0100a93:	50                   	push   %eax
f0100a94:	57                   	push   %edi
f0100a95:	e8 31 0d 00 00       	call   f01017cb <strchr>
f0100a9a:	83 c4 10             	add    $0x10,%esp
f0100a9d:	85 c0                	test   %eax,%eax
f0100a9f:	74 e2                	je     f0100a83 <monitor+0xb1>
		while (*buf && strchr(WHITESPACE, *buf))
f0100aa1:	0f b6 06             	movzbl (%esi),%eax
f0100aa4:	84 c0                	test   %al,%al
f0100aa6:	0f 85 63 ff ff ff    	jne    f0100a0f <monitor+0x3d>
	argv[argc] = 0;
f0100aac:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100aaf:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100ab6:	00 
	if (argc == 0)
f0100ab7:	85 c0                	test   %eax,%eax
f0100ab9:	74 9e                	je     f0100a59 <monitor+0x87>
f0100abb:	8d b3 18 1d 00 00    	lea    0x1d18(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100ac1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ac6:	89 7d a0             	mov    %edi,-0x60(%ebp)
f0100ac9:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f0100acb:	83 ec 08             	sub    $0x8,%esp
f0100ace:	ff 36                	pushl  (%esi)
f0100ad0:	ff 75 a8             	pushl  -0x58(%ebp)
f0100ad3:	e8 8b 0c 00 00       	call   f0101763 <strcmp>
f0100ad8:	83 c4 10             	add    $0x10,%esp
f0100adb:	85 c0                	test   %eax,%eax
f0100add:	74 28                	je     f0100b07 <monitor+0x135>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100adf:	83 c7 01             	add    $0x1,%edi
f0100ae2:	83 c6 0c             	add    $0xc,%esi
f0100ae5:	83 ff 03             	cmp    $0x3,%edi
f0100ae8:	75 e1                	jne    f0100acb <monitor+0xf9>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100aea:	8b 7d a0             	mov    -0x60(%ebp),%edi
f0100aed:	83 ec 08             	sub    $0x8,%esp
f0100af0:	ff 75 a8             	pushl  -0x58(%ebp)
f0100af3:	8d 83 0e 0d ff ff    	lea    -0xf2f2(%ebx),%eax
f0100af9:	50                   	push   %eax
f0100afa:	e8 98 00 00 00       	call   f0100b97 <cprintf>
	return 0;
f0100aff:	83 c4 10             	add    $0x10,%esp
f0100b02:	e9 52 ff ff ff       	jmp    f0100a59 <monitor+0x87>
			return commands[i].func(argc, argv, tf);
f0100b07:	89 f8                	mov    %edi,%eax
f0100b09:	8b 7d a0             	mov    -0x60(%ebp),%edi
f0100b0c:	83 ec 04             	sub    $0x4,%esp
f0100b0f:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100b12:	ff 75 08             	pushl  0x8(%ebp)
f0100b15:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100b18:	52                   	push   %edx
f0100b19:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100b1c:	ff 94 83 20 1d 00 00 	call   *0x1d20(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100b23:	83 c4 10             	add    $0x10,%esp
f0100b26:	85 c0                	test   %eax,%eax
f0100b28:	0f 89 2b ff ff ff    	jns    f0100a59 <monitor+0x87>
				break;
	}
}
f0100b2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b31:	5b                   	pop    %ebx
f0100b32:	5e                   	pop    %esi
f0100b33:	5f                   	pop    %edi
f0100b34:	5d                   	pop    %ebp
f0100b35:	c3                   	ret    

f0100b36 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100b36:	f3 0f 1e fb          	endbr32 
f0100b3a:	55                   	push   %ebp
f0100b3b:	89 e5                	mov    %esp,%ebp
f0100b3d:	53                   	push   %ebx
f0100b3e:	83 ec 10             	sub    $0x10,%esp
f0100b41:	e8 94 f6 ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f0100b46:	81 c3 c2 07 01 00    	add    $0x107c2,%ebx
	cputchar(ch);
f0100b4c:	ff 75 08             	pushl  0x8(%ebp)
f0100b4f:	e8 14 fc ff ff       	call   f0100768 <cputchar>
	*cnt++;
}
f0100b54:	83 c4 10             	add    $0x10,%esp
f0100b57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b5a:	c9                   	leave  
f0100b5b:	c3                   	ret    

f0100b5c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100b5c:	f3 0f 1e fb          	endbr32 
f0100b60:	55                   	push   %ebp
f0100b61:	89 e5                	mov    %esp,%ebp
f0100b63:	53                   	push   %ebx
f0100b64:	83 ec 14             	sub    $0x14,%esp
f0100b67:	e8 6e f6 ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f0100b6c:	81 c3 9c 07 01 00    	add    $0x1079c,%ebx
	int cnt = 0;
f0100b72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100b79:	ff 75 0c             	pushl  0xc(%ebp)
f0100b7c:	ff 75 08             	pushl  0x8(%ebp)
f0100b7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100b82:	50                   	push   %eax
f0100b83:	8d 83 2e f8 fe ff    	lea    -0x107d2(%ebx),%eax
f0100b89:	50                   	push   %eax
f0100b8a:	e8 99 04 00 00       	call   f0101028 <vprintfmt>
	return cnt;
}
f0100b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b95:	c9                   	leave  
f0100b96:	c3                   	ret    

f0100b97 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100b97:	f3 0f 1e fb          	endbr32 
f0100b9b:	55                   	push   %ebp
f0100b9c:	89 e5                	mov    %esp,%ebp
f0100b9e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100ba1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100ba4:	50                   	push   %eax
f0100ba5:	ff 75 08             	pushl  0x8(%ebp)
f0100ba8:	e8 af ff ff ff       	call   f0100b5c <vcprintf>
	va_end(ap);

	return cnt;
}
f0100bad:	c9                   	leave  
f0100bae:	c3                   	ret    

f0100baf <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100baf:	55                   	push   %ebp
f0100bb0:	89 e5                	mov    %esp,%ebp
f0100bb2:	57                   	push   %edi
f0100bb3:	56                   	push   %esi
f0100bb4:	53                   	push   %ebx
f0100bb5:	83 ec 14             	sub    $0x14,%esp
f0100bb8:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100bbb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100bbe:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100bc1:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100bc4:	8b 1a                	mov    (%edx),%ebx
f0100bc6:	8b 01                	mov    (%ecx),%eax
f0100bc8:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100bcb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100bd2:	eb 2f                	jmp    f0100c03 <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100bd4:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0100bd7:	39 c3                	cmp    %eax,%ebx
f0100bd9:	7f 4e                	jg     f0100c29 <stab_binsearch+0x7a>
f0100bdb:	0f b6 0a             	movzbl (%edx),%ecx
f0100bde:	83 ea 0c             	sub    $0xc,%edx
f0100be1:	39 f1                	cmp    %esi,%ecx
f0100be3:	75 ef                	jne    f0100bd4 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100be5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100be8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100beb:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100bef:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100bf2:	73 3a                	jae    f0100c2e <stab_binsearch+0x7f>
			*region_left = m;
f0100bf4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100bf7:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100bf9:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0100bfc:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100c03:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100c06:	7f 53                	jg     f0100c5b <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0100c08:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100c0b:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0100c0e:	89 d0                	mov    %edx,%eax
f0100c10:	c1 e8 1f             	shr    $0x1f,%eax
f0100c13:	01 d0                	add    %edx,%eax
f0100c15:	89 c7                	mov    %eax,%edi
f0100c17:	d1 ff                	sar    %edi
f0100c19:	83 e0 fe             	and    $0xfffffffe,%eax
f0100c1c:	01 f8                	add    %edi,%eax
f0100c1e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100c21:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100c25:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0100c27:	eb ae                	jmp    f0100bd7 <stab_binsearch+0x28>
			l = true_m + 1;
f0100c29:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100c2c:	eb d5                	jmp    f0100c03 <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100c2e:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100c31:	76 14                	jbe    f0100c47 <stab_binsearch+0x98>
			*region_right = m - 1;
f0100c33:	83 e8 01             	sub    $0x1,%eax
f0100c36:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100c39:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100c3c:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0100c3e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100c45:	eb bc                	jmp    f0100c03 <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100c47:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c4a:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0100c4c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100c50:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0100c52:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100c59:	eb a8                	jmp    f0100c03 <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100c5b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100c5f:	75 15                	jne    f0100c76 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0100c61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c64:	8b 00                	mov    (%eax),%eax
f0100c66:	83 e8 01             	sub    $0x1,%eax
f0100c69:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100c6c:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100c6e:	83 c4 14             	add    $0x14,%esp
f0100c71:	5b                   	pop    %ebx
f0100c72:	5e                   	pop    %esi
f0100c73:	5f                   	pop    %edi
f0100c74:	5d                   	pop    %ebp
f0100c75:	c3                   	ret    
		for (l = *region_right;
f0100c76:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c79:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100c7b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c7e:	8b 0f                	mov    (%edi),%ecx
f0100c80:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c83:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100c86:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0100c8a:	39 c1                	cmp    %eax,%ecx
f0100c8c:	7d 0f                	jge    f0100c9d <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f0100c8e:	0f b6 1a             	movzbl (%edx),%ebx
f0100c91:	83 ea 0c             	sub    $0xc,%edx
f0100c94:	39 f3                	cmp    %esi,%ebx
f0100c96:	74 05                	je     f0100c9d <stab_binsearch+0xee>
		     l--)
f0100c98:	83 e8 01             	sub    $0x1,%eax
f0100c9b:	eb ed                	jmp    f0100c8a <stab_binsearch+0xdb>
		*region_left = l;
f0100c9d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100ca0:	89 07                	mov    %eax,(%edi)
}
f0100ca2:	eb ca                	jmp    f0100c6e <stab_binsearch+0xbf>

f0100ca4 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100ca4:	f3 0f 1e fb          	endbr32 
f0100ca8:	55                   	push   %ebp
f0100ca9:	89 e5                	mov    %esp,%ebp
f0100cab:	57                   	push   %edi
f0100cac:	56                   	push   %esi
f0100cad:	53                   	push   %ebx
f0100cae:	83 ec 3c             	sub    $0x3c,%esp
f0100cb1:	e8 24 f5 ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f0100cb6:	81 c3 52 06 01 00    	add    $0x10652,%ebx
f0100cbc:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100cbf:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100cc2:	8d 83 79 0e ff ff    	lea    -0xf187(%ebx),%eax
f0100cc8:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0100cca:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100cd1:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100cd4:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100cdb:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100cde:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100ce5:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100ceb:	0f 86 5a 01 00 00    	jbe    f0100e4b <debuginfo_eip+0x1a7>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100cf1:	c7 c0 15 5d 10 f0    	mov    $0xf0105d15,%eax
f0100cf7:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100cfd:	0f 86 03 02 00 00    	jbe    f0100f06 <debuginfo_eip+0x262>
f0100d03:	c7 c0 49 73 10 f0    	mov    $0xf0107349,%eax
f0100d09:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100d0d:	0f 85 fa 01 00 00    	jne    f0100f0d <debuginfo_eip+0x269>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100d13:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100d1a:	c7 c0 9c 23 10 f0    	mov    $0xf010239c,%eax
f0100d20:	c7 c2 14 5d 10 f0    	mov    $0xf0105d14,%edx
f0100d26:	29 c2                	sub    %eax,%edx
f0100d28:	c1 fa 02             	sar    $0x2,%edx
f0100d2b:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100d31:	83 ea 01             	sub    $0x1,%edx
f0100d34:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100d37:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100d3a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100d3d:	83 ec 08             	sub    $0x8,%esp
f0100d40:	57                   	push   %edi
f0100d41:	6a 64                	push   $0x64
f0100d43:	e8 67 fe ff ff       	call   f0100baf <stab_binsearch>
	if (lfile == 0)
f0100d48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d4b:	83 c4 10             	add    $0x10,%esp
f0100d4e:	85 c0                	test   %eax,%eax
f0100d50:	0f 84 be 01 00 00    	je     f0100f14 <debuginfo_eip+0x270>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100d56:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100d59:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d5c:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100d5f:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100d62:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100d65:	83 ec 08             	sub    $0x8,%esp
f0100d68:	57                   	push   %edi
f0100d69:	6a 24                	push   $0x24
f0100d6b:	c7 c0 9c 23 10 f0    	mov    $0xf010239c,%eax
f0100d71:	e8 39 fe ff ff       	call   f0100baf <stab_binsearch>

	if (lfun <= rfun) {
f0100d76:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100d79:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100d7c:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0100d7f:	83 c4 10             	add    $0x10,%esp
f0100d82:	39 c8                	cmp    %ecx,%eax
f0100d84:	0f 8f d9 00 00 00    	jg     f0100e63 <debuginfo_eip+0x1bf>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100d8a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100d8d:	c7 c1 9c 23 10 f0    	mov    $0xf010239c,%ecx
f0100d93:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0100d96:	8b 11                	mov    (%ecx),%edx
f0100d98:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0100d9b:	c7 c2 49 73 10 f0    	mov    $0xf0107349,%edx
f0100da1:	81 ea 15 5d 10 f0    	sub    $0xf0105d15,%edx
f0100da7:	39 55 c0             	cmp    %edx,-0x40(%ebp)
f0100daa:	73 0c                	jae    f0100db8 <debuginfo_eip+0x114>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100dac:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0100daf:	81 c2 15 5d 10 f0    	add    $0xf0105d15,%edx
f0100db5:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100db8:	8b 51 08             	mov    0x8(%ecx),%edx
f0100dbb:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0100dbe:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0100dc0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100dc3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100dc6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100dc9:	83 ec 08             	sub    $0x8,%esp
f0100dcc:	6a 3a                	push   $0x3a
f0100dce:	ff 76 08             	pushl  0x8(%esi)
f0100dd1:	e8 1c 0a 00 00       	call   f01017f2 <strfind>
f0100dd6:	2b 46 08             	sub    0x8(%esi),%eax
f0100dd9:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100ddc:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100ddf:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100de2:	83 c4 08             	add    $0x8,%esp
f0100de5:	57                   	push   %edi
f0100de6:	6a 44                	push   $0x44
f0100de8:	c7 c0 9c 23 10 f0    	mov    $0xf010239c,%eax
f0100dee:	e8 bc fd ff ff       	call   f0100baf <stab_binsearch>
	if (lline <= rline) {
f0100df3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100df6:	83 c4 10             	add    $0x10,%esp
f0100df9:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0100dfc:	7f 79                	jg     f0100e77 <debuginfo_eip+0x1d3>
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100dfe:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100e01:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0100e04:	c7 c2 49 73 10 f0    	mov    $0xf0107349,%edx
f0100e0a:	89 d7                	mov    %edx,%edi
f0100e0c:	81 ef 15 5d 10 f0    	sub    $0xf0105d15,%edi
f0100e12:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0100e15:	8d 0c 49             	lea    (%ecx,%ecx,2),%ecx
f0100e18:	c7 c2 9c 23 10 f0    	mov    $0xf010239c,%edx
f0100e1e:	39 3c 8a             	cmp    %edi,(%edx,%ecx,4)
f0100e21:	73 11                	jae    f0100e34 <debuginfo_eip+0x190>
			info->eip_line = stabs[lline].n_desc;
f0100e23:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100e26:	c7 c1 9c 23 10 f0    	mov    $0xf010239c,%ecx
f0100e2c:	0f b7 54 91 06       	movzwl 0x6(%ecx,%edx,4),%edx
f0100e31:	89 56 04             	mov    %edx,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100e34:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e37:	89 c2                	mov    %eax,%edx
f0100e39:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100e3c:	c7 c0 9c 23 10 f0    	mov    $0xf010239c,%eax
f0100e42:	8d 44 88 04          	lea    0x4(%eax,%ecx,4),%eax
f0100e46:	89 75 0c             	mov    %esi,0xc(%ebp)
f0100e49:	eb 43                	jmp    f0100e8e <debuginfo_eip+0x1ea>
  	        panic("User address");
f0100e4b:	83 ec 04             	sub    $0x4,%esp
f0100e4e:	8d 83 83 0e ff ff    	lea    -0xf17d(%ebx),%eax
f0100e54:	50                   	push   %eax
f0100e55:	6a 7f                	push   $0x7f
f0100e57:	8d 83 90 0e ff ff    	lea    -0xf170(%ebx),%eax
f0100e5d:	50                   	push   %eax
f0100e5e:	e8 b9 f2 ff ff       	call   f010011c <_panic>
		info->eip_fn_addr = addr;
f0100e63:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100e66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e69:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100e6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e6f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100e72:	e9 52 ff ff ff       	jmp    f0100dc9 <debuginfo_eip+0x125>
		info->eip_line = 0;
f0100e77:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
		return -1;
f0100e7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e83:	e9 98 00 00 00       	jmp    f0100f20 <debuginfo_eip+0x27c>
f0100e88:	83 ea 01             	sub    $0x1,%edx
f0100e8b:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0100e8e:	39 d7                	cmp    %edx,%edi
f0100e90:	7f 31                	jg     f0100ec3 <debuginfo_eip+0x21f>
	       && stabs[lline].n_type != N_SOL
f0100e92:	0f b6 08             	movzbl (%eax),%ecx
f0100e95:	80 f9 84             	cmp    $0x84,%cl
f0100e98:	74 0b                	je     f0100ea5 <debuginfo_eip+0x201>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100e9a:	80 f9 64             	cmp    $0x64,%cl
f0100e9d:	75 e9                	jne    f0100e88 <debuginfo_eip+0x1e4>
f0100e9f:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100ea3:	74 e3                	je     f0100e88 <debuginfo_eip+0x1e4>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100ea5:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100ea8:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100eab:	c7 c0 9c 23 10 f0    	mov    $0xf010239c,%eax
f0100eb1:	8b 04 90             	mov    (%eax,%edx,4),%eax
f0100eb4:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f0100eb7:	76 0d                	jbe    f0100ec6 <debuginfo_eip+0x222>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100eb9:	81 c0 15 5d 10 f0    	add    $0xf0105d15,%eax
f0100ebf:	89 06                	mov    %eax,(%esi)
f0100ec1:	eb 03                	jmp    f0100ec6 <debuginfo_eip+0x222>
f0100ec3:	8b 75 0c             	mov    0xc(%ebp),%esi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100ec6:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100ec9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100ece:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100ed1:	39 cf                	cmp    %ecx,%edi
f0100ed3:	7d 4b                	jge    f0100f20 <debuginfo_eip+0x27c>
		for (lline = lfun + 1;
f0100ed5:	89 f8                	mov    %edi,%eax
f0100ed7:	83 c0 01             	add    $0x1,%eax
f0100eda:	8d 3c 40             	lea    (%eax,%eax,2),%edi
f0100edd:	c7 c2 9c 23 10 f0    	mov    $0xf010239c,%edx
f0100ee3:	8d 54 ba 04          	lea    0x4(%edx,%edi,4),%edx
f0100ee7:	eb 04                	jmp    f0100eed <debuginfo_eip+0x249>
			info->eip_fn_narg++;
f0100ee9:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0100eed:	39 c1                	cmp    %eax,%ecx
f0100eef:	7e 2a                	jle    f0100f1b <debuginfo_eip+0x277>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100ef1:	0f b6 1a             	movzbl (%edx),%ebx
f0100ef4:	83 c0 01             	add    $0x1,%eax
f0100ef7:	83 c2 0c             	add    $0xc,%edx
f0100efa:	80 fb a0             	cmp    $0xa0,%bl
f0100efd:	74 ea                	je     f0100ee9 <debuginfo_eip+0x245>
	return 0;
f0100eff:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f04:	eb 1a                	jmp    f0100f20 <debuginfo_eip+0x27c>
		return -1;
f0100f06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100f0b:	eb 13                	jmp    f0100f20 <debuginfo_eip+0x27c>
f0100f0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100f12:	eb 0c                	jmp    f0100f20 <debuginfo_eip+0x27c>
		return -1;
f0100f14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100f19:	eb 05                	jmp    f0100f20 <debuginfo_eip+0x27c>
	return 0;
f0100f1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100f20:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f23:	5b                   	pop    %ebx
f0100f24:	5e                   	pop    %esi
f0100f25:	5f                   	pop    %edi
f0100f26:	5d                   	pop    %ebp
f0100f27:	c3                   	ret    

f0100f28 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100f28:	55                   	push   %ebp
f0100f29:	89 e5                	mov    %esp,%ebp
f0100f2b:	57                   	push   %edi
f0100f2c:	56                   	push   %esi
f0100f2d:	53                   	push   %ebx
f0100f2e:	83 ec 2c             	sub    $0x2c,%esp
f0100f31:	e8 1a 06 00 00       	call   f0101550 <__x86.get_pc_thunk.cx>
f0100f36:	81 c1 d2 03 01 00    	add    $0x103d2,%ecx
f0100f3c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100f3f:	89 c7                	mov    %eax,%edi
f0100f41:	89 d6                	mov    %edx,%esi
f0100f43:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f46:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100f49:	89 d1                	mov    %edx,%ecx
f0100f4b:	89 c2                	mov    %eax,%edx
f0100f4d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100f50:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100f53:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f56:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100f59:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f5c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100f63:	39 c2                	cmp    %eax,%edx
f0100f65:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0100f68:	72 41                	jb     f0100fab <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100f6a:	83 ec 0c             	sub    $0xc,%esp
f0100f6d:	ff 75 18             	pushl  0x18(%ebp)
f0100f70:	83 eb 01             	sub    $0x1,%ebx
f0100f73:	53                   	push   %ebx
f0100f74:	50                   	push   %eax
f0100f75:	83 ec 08             	sub    $0x8,%esp
f0100f78:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100f7b:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f7e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100f81:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f84:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100f87:	e8 94 0a 00 00       	call   f0101a20 <__udivdi3>
f0100f8c:	83 c4 18             	add    $0x18,%esp
f0100f8f:	52                   	push   %edx
f0100f90:	50                   	push   %eax
f0100f91:	89 f2                	mov    %esi,%edx
f0100f93:	89 f8                	mov    %edi,%eax
f0100f95:	e8 8e ff ff ff       	call   f0100f28 <printnum>
f0100f9a:	83 c4 20             	add    $0x20,%esp
f0100f9d:	eb 13                	jmp    f0100fb2 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100f9f:	83 ec 08             	sub    $0x8,%esp
f0100fa2:	56                   	push   %esi
f0100fa3:	ff 75 18             	pushl  0x18(%ebp)
f0100fa6:	ff d7                	call   *%edi
f0100fa8:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100fab:	83 eb 01             	sub    $0x1,%ebx
f0100fae:	85 db                	test   %ebx,%ebx
f0100fb0:	7f ed                	jg     f0100f9f <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100fb2:	83 ec 08             	sub    $0x8,%esp
f0100fb5:	56                   	push   %esi
f0100fb6:	83 ec 04             	sub    $0x4,%esp
f0100fb9:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100fbc:	ff 75 e0             	pushl  -0x20(%ebp)
f0100fbf:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100fc2:	ff 75 d0             	pushl  -0x30(%ebp)
f0100fc5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100fc8:	e8 63 0b 00 00       	call   f0101b30 <__umoddi3>
f0100fcd:	83 c4 14             	add    $0x14,%esp
f0100fd0:	0f be 84 03 9e 0e ff 	movsbl -0xf162(%ebx,%eax,1),%eax
f0100fd7:	ff 
f0100fd8:	50                   	push   %eax
f0100fd9:	ff d7                	call   *%edi
}
f0100fdb:	83 c4 10             	add    $0x10,%esp
f0100fde:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fe1:	5b                   	pop    %ebx
f0100fe2:	5e                   	pop    %esi
f0100fe3:	5f                   	pop    %edi
f0100fe4:	5d                   	pop    %ebp
f0100fe5:	c3                   	ret    

f0100fe6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100fe6:	f3 0f 1e fb          	endbr32 
f0100fea:	55                   	push   %ebp
f0100feb:	89 e5                	mov    %esp,%ebp
f0100fed:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100ff0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100ff4:	8b 10                	mov    (%eax),%edx
f0100ff6:	3b 50 04             	cmp    0x4(%eax),%edx
f0100ff9:	73 0a                	jae    f0101005 <sprintputch+0x1f>
		*b->buf++ = ch;
f0100ffb:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100ffe:	89 08                	mov    %ecx,(%eax)
f0101000:	8b 45 08             	mov    0x8(%ebp),%eax
f0101003:	88 02                	mov    %al,(%edx)
}
f0101005:	5d                   	pop    %ebp
f0101006:	c3                   	ret    

f0101007 <printfmt>:
{
f0101007:	f3 0f 1e fb          	endbr32 
f010100b:	55                   	push   %ebp
f010100c:	89 e5                	mov    %esp,%ebp
f010100e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0101011:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0101014:	50                   	push   %eax
f0101015:	ff 75 10             	pushl  0x10(%ebp)
f0101018:	ff 75 0c             	pushl  0xc(%ebp)
f010101b:	ff 75 08             	pushl  0x8(%ebp)
f010101e:	e8 05 00 00 00       	call   f0101028 <vprintfmt>
}
f0101023:	83 c4 10             	add    $0x10,%esp
f0101026:	c9                   	leave  
f0101027:	c3                   	ret    

f0101028 <vprintfmt>:
{
f0101028:	f3 0f 1e fb          	endbr32 
f010102c:	55                   	push   %ebp
f010102d:	89 e5                	mov    %esp,%ebp
f010102f:	57                   	push   %edi
f0101030:	56                   	push   %esi
f0101031:	53                   	push   %ebx
f0101032:	83 ec 3c             	sub    $0x3c,%esp
f0101035:	e8 61 f7 ff ff       	call   f010079b <__x86.get_pc_thunk.ax>
f010103a:	05 ce 02 01 00       	add    $0x102ce,%eax
f010103f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101042:	8b 75 08             	mov    0x8(%ebp),%esi
f0101045:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101048:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010104b:	8d 80 3c 1d 00 00    	lea    0x1d3c(%eax),%eax
f0101051:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101054:	eb 0a                	jmp    f0101060 <vprintfmt+0x38>
			putch(ch, putdat);
f0101056:	83 ec 08             	sub    $0x8,%esp
f0101059:	57                   	push   %edi
f010105a:	50                   	push   %eax
f010105b:	ff d6                	call   *%esi
f010105d:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101060:	83 c3 01             	add    $0x1,%ebx
f0101063:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0101067:	83 f8 25             	cmp    $0x25,%eax
f010106a:	74 0c                	je     f0101078 <vprintfmt+0x50>
			if (ch == '\0')
f010106c:	85 c0                	test   %eax,%eax
f010106e:	75 e6                	jne    f0101056 <vprintfmt+0x2e>
}
f0101070:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101073:	5b                   	pop    %ebx
f0101074:	5e                   	pop    %esi
f0101075:	5f                   	pop    %edi
f0101076:	5d                   	pop    %ebp
f0101077:	c3                   	ret    
		padc = ' ';
f0101078:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f010107c:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
f0101083:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f010108a:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f0101091:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101096:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0101099:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010109c:	8d 43 01             	lea    0x1(%ebx),%eax
f010109f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01010a2:	0f b6 13             	movzbl (%ebx),%edx
f01010a5:	8d 42 dd             	lea    -0x23(%edx),%eax
f01010a8:	3c 55                	cmp    $0x55,%al
f01010aa:	0f 87 fc 03 00 00    	ja     f01014ac <.L20>
f01010b0:	0f b6 c0             	movzbl %al,%eax
f01010b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01010b6:	89 ce                	mov    %ecx,%esi
f01010b8:	03 b4 81 2c 0f ff ff 	add    -0xf0d4(%ecx,%eax,4),%esi
f01010bf:	3e ff e6             	notrack jmp *%esi

f01010c2 <.L68>:
f01010c2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f01010c5:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f01010c9:	eb d1                	jmp    f010109c <vprintfmt+0x74>

f01010cb <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f01010cb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01010ce:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f01010d2:	eb c8                	jmp    f010109c <vprintfmt+0x74>

f01010d4 <.L31>:
f01010d4:	0f b6 d2             	movzbl %dl,%edx
f01010d7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f01010da:	b8 00 00 00 00       	mov    $0x0,%eax
f01010df:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f01010e2:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01010e5:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f01010e9:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f01010ec:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01010ef:	83 f9 09             	cmp    $0x9,%ecx
f01010f2:	77 58                	ja     f010114c <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f01010f4:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f01010f7:	eb e9                	jmp    f01010e2 <.L31+0xe>

f01010f9 <.L34>:
			precision = va_arg(ap, int);
f01010f9:	8b 45 14             	mov    0x14(%ebp),%eax
f01010fc:	8b 00                	mov    (%eax),%eax
f01010fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101101:	8b 45 14             	mov    0x14(%ebp),%eax
f0101104:	8d 40 04             	lea    0x4(%eax),%eax
f0101107:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010110a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f010110d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101111:	79 89                	jns    f010109c <vprintfmt+0x74>
				width = precision, precision = -1;
f0101113:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101116:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101119:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0101120:	e9 77 ff ff ff       	jmp    f010109c <vprintfmt+0x74>

f0101125 <.L33>:
f0101125:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101128:	85 c0                	test   %eax,%eax
f010112a:	ba 00 00 00 00       	mov    $0x0,%edx
f010112f:	0f 49 d0             	cmovns %eax,%edx
f0101132:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101135:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0101138:	e9 5f ff ff ff       	jmp    f010109c <vprintfmt+0x74>

f010113d <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f010113d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f0101140:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f0101147:	e9 50 ff ff ff       	jmp    f010109c <vprintfmt+0x74>
f010114c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010114f:	89 75 08             	mov    %esi,0x8(%ebp)
f0101152:	eb b9                	jmp    f010110d <.L34+0x14>

f0101154 <.L27>:
			lflag++;
f0101154:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101158:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f010115b:	e9 3c ff ff ff       	jmp    f010109c <vprintfmt+0x74>

f0101160 <.L30>:
			putch(va_arg(ap, int), putdat);
f0101160:	8b 75 08             	mov    0x8(%ebp),%esi
f0101163:	8b 45 14             	mov    0x14(%ebp),%eax
f0101166:	8d 58 04             	lea    0x4(%eax),%ebx
f0101169:	83 ec 08             	sub    $0x8,%esp
f010116c:	57                   	push   %edi
f010116d:	ff 30                	pushl  (%eax)
f010116f:	ff d6                	call   *%esi
			break;
f0101171:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0101174:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f0101177:	e9 c6 02 00 00       	jmp    f0101442 <.L25+0x45>

f010117c <.L28>:
			err = va_arg(ap, int);
f010117c:	8b 75 08             	mov    0x8(%ebp),%esi
f010117f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101182:	8d 58 04             	lea    0x4(%eax),%ebx
f0101185:	8b 00                	mov    (%eax),%eax
f0101187:	99                   	cltd   
f0101188:	31 d0                	xor    %edx,%eax
f010118a:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010118c:	83 f8 06             	cmp    $0x6,%eax
f010118f:	7f 27                	jg     f01011b8 <.L28+0x3c>
f0101191:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0101194:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0101197:	85 d2                	test   %edx,%edx
f0101199:	74 1d                	je     f01011b8 <.L28+0x3c>
				printfmt(putch, putdat, "%s", p);
f010119b:	52                   	push   %edx
f010119c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010119f:	8d 80 bf 0e ff ff    	lea    -0xf141(%eax),%eax
f01011a5:	50                   	push   %eax
f01011a6:	57                   	push   %edi
f01011a7:	56                   	push   %esi
f01011a8:	e8 5a fe ff ff       	call   f0101007 <printfmt>
f01011ad:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01011b0:	89 5d 14             	mov    %ebx,0x14(%ebp)
f01011b3:	e9 8a 02 00 00       	jmp    f0101442 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f01011b8:	50                   	push   %eax
f01011b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01011bc:	8d 80 b6 0e ff ff    	lea    -0xf14a(%eax),%eax
f01011c2:	50                   	push   %eax
f01011c3:	57                   	push   %edi
f01011c4:	56                   	push   %esi
f01011c5:	e8 3d fe ff ff       	call   f0101007 <printfmt>
f01011ca:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01011cd:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01011d0:	e9 6d 02 00 00       	jmp    f0101442 <.L25+0x45>

f01011d5 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
f01011d5:	8b 75 08             	mov    0x8(%ebp),%esi
f01011d8:	8b 45 14             	mov    0x14(%ebp),%eax
f01011db:	83 c0 04             	add    $0x4,%eax
f01011de:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01011e1:	8b 45 14             	mov    0x14(%ebp),%eax
f01011e4:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f01011e6:	85 d2                	test   %edx,%edx
f01011e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01011eb:	8d 80 af 0e ff ff    	lea    -0xf151(%eax),%eax
f01011f1:	0f 45 c2             	cmovne %edx,%eax
f01011f4:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f01011f7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01011fb:	7e 06                	jle    f0101203 <.L24+0x2e>
f01011fd:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f0101201:	75 0d                	jne    f0101210 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101203:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0101206:	89 c3                	mov    %eax,%ebx
f0101208:	03 45 d4             	add    -0x2c(%ebp),%eax
f010120b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010120e:	eb 58                	jmp    f0101268 <.L24+0x93>
f0101210:	83 ec 08             	sub    $0x8,%esp
f0101213:	ff 75 d8             	pushl  -0x28(%ebp)
f0101216:	ff 75 c8             	pushl  -0x38(%ebp)
f0101219:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010121c:	e8 58 04 00 00       	call   f0101679 <strnlen>
f0101221:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101224:	29 c2                	sub    %eax,%edx
f0101226:	89 55 bc             	mov    %edx,-0x44(%ebp)
f0101229:	83 c4 10             	add    $0x10,%esp
f010122c:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f010122e:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0101232:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0101235:	eb 0f                	jmp    f0101246 <.L24+0x71>
					putch(padc, putdat);
f0101237:	83 ec 08             	sub    $0x8,%esp
f010123a:	57                   	push   %edi
f010123b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010123e:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0101240:	83 eb 01             	sub    $0x1,%ebx
f0101243:	83 c4 10             	add    $0x10,%esp
f0101246:	85 db                	test   %ebx,%ebx
f0101248:	7f ed                	jg     f0101237 <.L24+0x62>
f010124a:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010124d:	85 d2                	test   %edx,%edx
f010124f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101254:	0f 49 c2             	cmovns %edx,%eax
f0101257:	29 c2                	sub    %eax,%edx
f0101259:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010125c:	eb a5                	jmp    f0101203 <.L24+0x2e>
					putch(ch, putdat);
f010125e:	83 ec 08             	sub    $0x8,%esp
f0101261:	57                   	push   %edi
f0101262:	52                   	push   %edx
f0101263:	ff d6                	call   *%esi
f0101265:	83 c4 10             	add    $0x10,%esp
f0101268:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010126b:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010126d:	83 c3 01             	add    $0x1,%ebx
f0101270:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0101274:	0f be d0             	movsbl %al,%edx
f0101277:	85 d2                	test   %edx,%edx
f0101279:	74 4b                	je     f01012c6 <.L24+0xf1>
f010127b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010127f:	78 06                	js     f0101287 <.L24+0xb2>
f0101281:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0101285:	78 1e                	js     f01012a5 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f0101287:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f010128b:	74 d1                	je     f010125e <.L24+0x89>
f010128d:	0f be c0             	movsbl %al,%eax
f0101290:	83 e8 20             	sub    $0x20,%eax
f0101293:	83 f8 5e             	cmp    $0x5e,%eax
f0101296:	76 c6                	jbe    f010125e <.L24+0x89>
					putch('?', putdat);
f0101298:	83 ec 08             	sub    $0x8,%esp
f010129b:	57                   	push   %edi
f010129c:	6a 3f                	push   $0x3f
f010129e:	ff d6                	call   *%esi
f01012a0:	83 c4 10             	add    $0x10,%esp
f01012a3:	eb c3                	jmp    f0101268 <.L24+0x93>
f01012a5:	89 cb                	mov    %ecx,%ebx
f01012a7:	eb 0e                	jmp    f01012b7 <.L24+0xe2>
				putch(' ', putdat);
f01012a9:	83 ec 08             	sub    $0x8,%esp
f01012ac:	57                   	push   %edi
f01012ad:	6a 20                	push   $0x20
f01012af:	ff d6                	call   *%esi
			for (; width > 0; width--)
f01012b1:	83 eb 01             	sub    $0x1,%ebx
f01012b4:	83 c4 10             	add    $0x10,%esp
f01012b7:	85 db                	test   %ebx,%ebx
f01012b9:	7f ee                	jg     f01012a9 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f01012bb:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01012be:	89 45 14             	mov    %eax,0x14(%ebp)
f01012c1:	e9 7c 01 00 00       	jmp    f0101442 <.L25+0x45>
f01012c6:	89 cb                	mov    %ecx,%ebx
f01012c8:	eb ed                	jmp    f01012b7 <.L24+0xe2>

f01012ca <.L29>:
	if (lflag >= 2)
f01012ca:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01012cd:	8b 75 08             	mov    0x8(%ebp),%esi
f01012d0:	83 f9 01             	cmp    $0x1,%ecx
f01012d3:	7f 1b                	jg     f01012f0 <.L29+0x26>
	else if (lflag)
f01012d5:	85 c9                	test   %ecx,%ecx
f01012d7:	74 63                	je     f010133c <.L29+0x72>
		return va_arg(*ap, long);
f01012d9:	8b 45 14             	mov    0x14(%ebp),%eax
f01012dc:	8b 00                	mov    (%eax),%eax
f01012de:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012e1:	99                   	cltd   
f01012e2:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01012e5:	8b 45 14             	mov    0x14(%ebp),%eax
f01012e8:	8d 40 04             	lea    0x4(%eax),%eax
f01012eb:	89 45 14             	mov    %eax,0x14(%ebp)
f01012ee:	eb 17                	jmp    f0101307 <.L29+0x3d>
		return va_arg(*ap, long long);
f01012f0:	8b 45 14             	mov    0x14(%ebp),%eax
f01012f3:	8b 50 04             	mov    0x4(%eax),%edx
f01012f6:	8b 00                	mov    (%eax),%eax
f01012f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012fb:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01012fe:	8b 45 14             	mov    0x14(%ebp),%eax
f0101301:	8d 40 08             	lea    0x8(%eax),%eax
f0101304:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0101307:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010130a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f010130d:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0101312:	85 c9                	test   %ecx,%ecx
f0101314:	0f 89 0e 01 00 00    	jns    f0101428 <.L25+0x2b>
				putch('-', putdat);
f010131a:	83 ec 08             	sub    $0x8,%esp
f010131d:	57                   	push   %edi
f010131e:	6a 2d                	push   $0x2d
f0101320:	ff d6                	call   *%esi
				num = -(long long) num;
f0101322:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101325:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101328:	f7 da                	neg    %edx
f010132a:	83 d1 00             	adc    $0x0,%ecx
f010132d:	f7 d9                	neg    %ecx
f010132f:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0101332:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101337:	e9 ec 00 00 00       	jmp    f0101428 <.L25+0x2b>
		return va_arg(*ap, int);
f010133c:	8b 45 14             	mov    0x14(%ebp),%eax
f010133f:	8b 00                	mov    (%eax),%eax
f0101341:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101344:	99                   	cltd   
f0101345:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101348:	8b 45 14             	mov    0x14(%ebp),%eax
f010134b:	8d 40 04             	lea    0x4(%eax),%eax
f010134e:	89 45 14             	mov    %eax,0x14(%ebp)
f0101351:	eb b4                	jmp    f0101307 <.L29+0x3d>

f0101353 <.L23>:
	if (lflag >= 2)
f0101353:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101356:	8b 75 08             	mov    0x8(%ebp),%esi
f0101359:	83 f9 01             	cmp    $0x1,%ecx
f010135c:	7f 1e                	jg     f010137c <.L23+0x29>
	else if (lflag)
f010135e:	85 c9                	test   %ecx,%ecx
f0101360:	74 32                	je     f0101394 <.L23+0x41>
		return va_arg(*ap, unsigned long);
f0101362:	8b 45 14             	mov    0x14(%ebp),%eax
f0101365:	8b 10                	mov    (%eax),%edx
f0101367:	b9 00 00 00 00       	mov    $0x0,%ecx
f010136c:	8d 40 04             	lea    0x4(%eax),%eax
f010136f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101372:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f0101377:	e9 ac 00 00 00       	jmp    f0101428 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010137c:	8b 45 14             	mov    0x14(%ebp),%eax
f010137f:	8b 10                	mov    (%eax),%edx
f0101381:	8b 48 04             	mov    0x4(%eax),%ecx
f0101384:	8d 40 08             	lea    0x8(%eax),%eax
f0101387:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010138a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f010138f:	e9 94 00 00 00       	jmp    f0101428 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101394:	8b 45 14             	mov    0x14(%ebp),%eax
f0101397:	8b 10                	mov    (%eax),%edx
f0101399:	b9 00 00 00 00       	mov    $0x0,%ecx
f010139e:	8d 40 04             	lea    0x4(%eax),%eax
f01013a1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01013a4:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f01013a9:	eb 7d                	jmp    f0101428 <.L25+0x2b>

f01013ab <.L26>:
	if (lflag >= 2)
f01013ab:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01013ae:	8b 75 08             	mov    0x8(%ebp),%esi
f01013b1:	83 f9 01             	cmp    $0x1,%ecx
f01013b4:	7f 1b                	jg     f01013d1 <.L26+0x26>
	else if (lflag)
f01013b6:	85 c9                	test   %ecx,%ecx
f01013b8:	74 2c                	je     f01013e6 <.L26+0x3b>
		return va_arg(*ap, unsigned long);
f01013ba:	8b 45 14             	mov    0x14(%ebp),%eax
f01013bd:	8b 10                	mov    (%eax),%edx
f01013bf:	b9 00 00 00 00       	mov    $0x0,%ecx
f01013c4:	8d 40 04             	lea    0x4(%eax),%eax
f01013c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01013ca:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
f01013cf:	eb 57                	jmp    f0101428 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f01013d1:	8b 45 14             	mov    0x14(%ebp),%eax
f01013d4:	8b 10                	mov    (%eax),%edx
f01013d6:	8b 48 04             	mov    0x4(%eax),%ecx
f01013d9:	8d 40 08             	lea    0x8(%eax),%eax
f01013dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01013df:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
f01013e4:	eb 42                	jmp    f0101428 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f01013e6:	8b 45 14             	mov    0x14(%ebp),%eax
f01013e9:	8b 10                	mov    (%eax),%edx
f01013eb:	b9 00 00 00 00       	mov    $0x0,%ecx
f01013f0:	8d 40 04             	lea    0x4(%eax),%eax
f01013f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01013f6:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
f01013fb:	eb 2b                	jmp    f0101428 <.L25+0x2b>

f01013fd <.L25>:
			putch('0', putdat);
f01013fd:	8b 75 08             	mov    0x8(%ebp),%esi
f0101400:	83 ec 08             	sub    $0x8,%esp
f0101403:	57                   	push   %edi
f0101404:	6a 30                	push   $0x30
f0101406:	ff d6                	call   *%esi
			putch('x', putdat);
f0101408:	83 c4 08             	add    $0x8,%esp
f010140b:	57                   	push   %edi
f010140c:	6a 78                	push   $0x78
f010140e:	ff d6                	call   *%esi
			num = (unsigned long long)
f0101410:	8b 45 14             	mov    0x14(%ebp),%eax
f0101413:	8b 10                	mov    (%eax),%edx
f0101415:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010141a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010141d:	8d 40 04             	lea    0x4(%eax),%eax
f0101420:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101423:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0101428:	83 ec 0c             	sub    $0xc,%esp
f010142b:	0f be 5d cf          	movsbl -0x31(%ebp),%ebx
f010142f:	53                   	push   %ebx
f0101430:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101433:	50                   	push   %eax
f0101434:	51                   	push   %ecx
f0101435:	52                   	push   %edx
f0101436:	89 fa                	mov    %edi,%edx
f0101438:	89 f0                	mov    %esi,%eax
f010143a:	e8 e9 fa ff ff       	call   f0100f28 <printnum>
			break;
f010143f:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f0101442:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101445:	e9 16 fc ff ff       	jmp    f0101060 <vprintfmt+0x38>

f010144a <.L21>:
	if (lflag >= 2)
f010144a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010144d:	8b 75 08             	mov    0x8(%ebp),%esi
f0101450:	83 f9 01             	cmp    $0x1,%ecx
f0101453:	7f 1b                	jg     f0101470 <.L21+0x26>
	else if (lflag)
f0101455:	85 c9                	test   %ecx,%ecx
f0101457:	74 2c                	je     f0101485 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f0101459:	8b 45 14             	mov    0x14(%ebp),%eax
f010145c:	8b 10                	mov    (%eax),%edx
f010145e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101463:	8d 40 04             	lea    0x4(%eax),%eax
f0101466:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101469:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f010146e:	eb b8                	jmp    f0101428 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0101470:	8b 45 14             	mov    0x14(%ebp),%eax
f0101473:	8b 10                	mov    (%eax),%edx
f0101475:	8b 48 04             	mov    0x4(%eax),%ecx
f0101478:	8d 40 08             	lea    0x8(%eax),%eax
f010147b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010147e:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f0101483:	eb a3                	jmp    f0101428 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101485:	8b 45 14             	mov    0x14(%ebp),%eax
f0101488:	8b 10                	mov    (%eax),%edx
f010148a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010148f:	8d 40 04             	lea    0x4(%eax),%eax
f0101492:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101495:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f010149a:	eb 8c                	jmp    f0101428 <.L25+0x2b>

f010149c <.L35>:
			putch(ch, putdat);
f010149c:	8b 75 08             	mov    0x8(%ebp),%esi
f010149f:	83 ec 08             	sub    $0x8,%esp
f01014a2:	57                   	push   %edi
f01014a3:	6a 25                	push   $0x25
f01014a5:	ff d6                	call   *%esi
			break;
f01014a7:	83 c4 10             	add    $0x10,%esp
f01014aa:	eb 96                	jmp    f0101442 <.L25+0x45>

f01014ac <.L20>:
			putch('%', putdat);
f01014ac:	8b 75 08             	mov    0x8(%ebp),%esi
f01014af:	83 ec 08             	sub    $0x8,%esp
f01014b2:	57                   	push   %edi
f01014b3:	6a 25                	push   $0x25
f01014b5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01014b7:	83 c4 10             	add    $0x10,%esp
f01014ba:	89 d8                	mov    %ebx,%eax
f01014bc:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01014c0:	74 05                	je     f01014c7 <.L20+0x1b>
f01014c2:	83 e8 01             	sub    $0x1,%eax
f01014c5:	eb f5                	jmp    f01014bc <.L20+0x10>
f01014c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01014ca:	e9 73 ff ff ff       	jmp    f0101442 <.L25+0x45>

f01014cf <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01014cf:	f3 0f 1e fb          	endbr32 
f01014d3:	55                   	push   %ebp
f01014d4:	89 e5                	mov    %esp,%ebp
f01014d6:	53                   	push   %ebx
f01014d7:	83 ec 14             	sub    $0x14,%esp
f01014da:	e8 fb ec ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f01014df:	81 c3 29 fe 00 00    	add    $0xfe29,%ebx
f01014e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01014e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01014eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01014ee:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01014f2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01014f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01014fc:	85 c0                	test   %eax,%eax
f01014fe:	74 2b                	je     f010152b <vsnprintf+0x5c>
f0101500:	85 d2                	test   %edx,%edx
f0101502:	7e 27                	jle    f010152b <vsnprintf+0x5c>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101504:	ff 75 14             	pushl  0x14(%ebp)
f0101507:	ff 75 10             	pushl  0x10(%ebp)
f010150a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010150d:	50                   	push   %eax
f010150e:	8d 83 de fc fe ff    	lea    -0x10322(%ebx),%eax
f0101514:	50                   	push   %eax
f0101515:	e8 0e fb ff ff       	call   f0101028 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010151a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010151d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101520:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101523:	83 c4 10             	add    $0x10,%esp
}
f0101526:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101529:	c9                   	leave  
f010152a:	c3                   	ret    
		return -E_INVAL;
f010152b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101530:	eb f4                	jmp    f0101526 <vsnprintf+0x57>

f0101532 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101532:	f3 0f 1e fb          	endbr32 
f0101536:	55                   	push   %ebp
f0101537:	89 e5                	mov    %esp,%ebp
f0101539:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010153c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010153f:	50                   	push   %eax
f0101540:	ff 75 10             	pushl  0x10(%ebp)
f0101543:	ff 75 0c             	pushl  0xc(%ebp)
f0101546:	ff 75 08             	pushl  0x8(%ebp)
f0101549:	e8 81 ff ff ff       	call   f01014cf <vsnprintf>
	va_end(ap);

	return rc;
}
f010154e:	c9                   	leave  
f010154f:	c3                   	ret    

f0101550 <__x86.get_pc_thunk.cx>:
f0101550:	8b 0c 24             	mov    (%esp),%ecx
f0101553:	c3                   	ret    

f0101554 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101554:	f3 0f 1e fb          	endbr32 
f0101558:	55                   	push   %ebp
f0101559:	89 e5                	mov    %esp,%ebp
f010155b:	57                   	push   %edi
f010155c:	56                   	push   %esi
f010155d:	53                   	push   %ebx
f010155e:	83 ec 1c             	sub    $0x1c,%esp
f0101561:	e8 74 ec ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f0101566:	81 c3 a2 fd 00 00    	add    $0xfda2,%ebx
f010156c:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010156f:	85 c0                	test   %eax,%eax
f0101571:	74 13                	je     f0101586 <readline+0x32>
		cprintf("%s", prompt);
f0101573:	83 ec 08             	sub    $0x8,%esp
f0101576:	50                   	push   %eax
f0101577:	8d 83 bf 0e ff ff    	lea    -0xf141(%ebx),%eax
f010157d:	50                   	push   %eax
f010157e:	e8 14 f6 ff ff       	call   f0100b97 <cprintf>
f0101583:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101586:	83 ec 0c             	sub    $0xc,%esp
f0101589:	6a 00                	push   $0x0
f010158b:	e8 01 f2 ff ff       	call   f0100791 <iscons>
f0101590:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101593:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0101596:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f010159b:	8d 83 b8 1f 00 00    	lea    0x1fb8(%ebx),%eax
f01015a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01015a4:	eb 45                	jmp    f01015eb <readline+0x97>
			cprintf("read error: %e\n", c);
f01015a6:	83 ec 08             	sub    $0x8,%esp
f01015a9:	50                   	push   %eax
f01015aa:	8d 83 84 10 ff ff    	lea    -0xef7c(%ebx),%eax
f01015b0:	50                   	push   %eax
f01015b1:	e8 e1 f5 ff ff       	call   f0100b97 <cprintf>
			return NULL;
f01015b6:	83 c4 10             	add    $0x10,%esp
f01015b9:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01015be:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01015c1:	5b                   	pop    %ebx
f01015c2:	5e                   	pop    %esi
f01015c3:	5f                   	pop    %edi
f01015c4:	5d                   	pop    %ebp
f01015c5:	c3                   	ret    
			if (echoing)
f01015c6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01015ca:	75 05                	jne    f01015d1 <readline+0x7d>
			i--;
f01015cc:	83 ef 01             	sub    $0x1,%edi
f01015cf:	eb 1a                	jmp    f01015eb <readline+0x97>
				cputchar('\b');
f01015d1:	83 ec 0c             	sub    $0xc,%esp
f01015d4:	6a 08                	push   $0x8
f01015d6:	e8 8d f1 ff ff       	call   f0100768 <cputchar>
f01015db:	83 c4 10             	add    $0x10,%esp
f01015de:	eb ec                	jmp    f01015cc <readline+0x78>
			buf[i++] = c;
f01015e0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01015e3:	89 f0                	mov    %esi,%eax
f01015e5:	88 04 39             	mov    %al,(%ecx,%edi,1)
f01015e8:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f01015eb:	e8 8c f1 ff ff       	call   f010077c <getchar>
f01015f0:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f01015f2:	85 c0                	test   %eax,%eax
f01015f4:	78 b0                	js     f01015a6 <readline+0x52>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01015f6:	83 f8 08             	cmp    $0x8,%eax
f01015f9:	0f 94 c2             	sete   %dl
f01015fc:	83 f8 7f             	cmp    $0x7f,%eax
f01015ff:	0f 94 c0             	sete   %al
f0101602:	08 c2                	or     %al,%dl
f0101604:	74 04                	je     f010160a <readline+0xb6>
f0101606:	85 ff                	test   %edi,%edi
f0101608:	7f bc                	jg     f01015c6 <readline+0x72>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010160a:	83 fe 1f             	cmp    $0x1f,%esi
f010160d:	7e 1c                	jle    f010162b <readline+0xd7>
f010160f:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0101615:	7f 14                	jg     f010162b <readline+0xd7>
			if (echoing)
f0101617:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010161b:	74 c3                	je     f01015e0 <readline+0x8c>
				cputchar(c);
f010161d:	83 ec 0c             	sub    $0xc,%esp
f0101620:	56                   	push   %esi
f0101621:	e8 42 f1 ff ff       	call   f0100768 <cputchar>
f0101626:	83 c4 10             	add    $0x10,%esp
f0101629:	eb b5                	jmp    f01015e0 <readline+0x8c>
		} else if (c == '\n' || c == '\r') {
f010162b:	83 fe 0a             	cmp    $0xa,%esi
f010162e:	74 05                	je     f0101635 <readline+0xe1>
f0101630:	83 fe 0d             	cmp    $0xd,%esi
f0101633:	75 b6                	jne    f01015eb <readline+0x97>
			if (echoing)
f0101635:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101639:	75 13                	jne    f010164e <readline+0xfa>
			buf[i] = 0;
f010163b:	c6 84 3b b8 1f 00 00 	movb   $0x0,0x1fb8(%ebx,%edi,1)
f0101642:	00 
			return buf;
f0101643:	8d 83 b8 1f 00 00    	lea    0x1fb8(%ebx),%eax
f0101649:	e9 70 ff ff ff       	jmp    f01015be <readline+0x6a>
				cputchar('\n');
f010164e:	83 ec 0c             	sub    $0xc,%esp
f0101651:	6a 0a                	push   $0xa
f0101653:	e8 10 f1 ff ff       	call   f0100768 <cputchar>
f0101658:	83 c4 10             	add    $0x10,%esp
f010165b:	eb de                	jmp    f010163b <readline+0xe7>

f010165d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010165d:	f3 0f 1e fb          	endbr32 
f0101661:	55                   	push   %ebp
f0101662:	89 e5                	mov    %esp,%ebp
f0101664:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101667:	b8 00 00 00 00       	mov    $0x0,%eax
f010166c:	eb 03                	jmp    f0101671 <strlen+0x14>
		n++;
f010166e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0101671:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101675:	75 f7                	jne    f010166e <strlen+0x11>
	return n;
}
f0101677:	5d                   	pop    %ebp
f0101678:	c3                   	ret    

f0101679 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101679:	f3 0f 1e fb          	endbr32 
f010167d:	55                   	push   %ebp
f010167e:	89 e5                	mov    %esp,%ebp
f0101680:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101683:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101686:	b8 00 00 00 00       	mov    $0x0,%eax
f010168b:	eb 03                	jmp    f0101690 <strnlen+0x17>
		n++;
f010168d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101690:	39 d0                	cmp    %edx,%eax
f0101692:	74 08                	je     f010169c <strnlen+0x23>
f0101694:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101698:	75 f3                	jne    f010168d <strnlen+0x14>
f010169a:	89 c2                	mov    %eax,%edx
	return n;
}
f010169c:	89 d0                	mov    %edx,%eax
f010169e:	5d                   	pop    %ebp
f010169f:	c3                   	ret    

f01016a0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01016a0:	f3 0f 1e fb          	endbr32 
f01016a4:	55                   	push   %ebp
f01016a5:	89 e5                	mov    %esp,%ebp
f01016a7:	53                   	push   %ebx
f01016a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01016ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01016ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01016b3:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f01016b7:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f01016ba:	83 c0 01             	add    $0x1,%eax
f01016bd:	84 d2                	test   %dl,%dl
f01016bf:	75 f2                	jne    f01016b3 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f01016c1:	89 c8                	mov    %ecx,%eax
f01016c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01016c6:	c9                   	leave  
f01016c7:	c3                   	ret    

f01016c8 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01016c8:	f3 0f 1e fb          	endbr32 
f01016cc:	55                   	push   %ebp
f01016cd:	89 e5                	mov    %esp,%ebp
f01016cf:	53                   	push   %ebx
f01016d0:	83 ec 10             	sub    $0x10,%esp
f01016d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01016d6:	53                   	push   %ebx
f01016d7:	e8 81 ff ff ff       	call   f010165d <strlen>
f01016dc:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01016df:	ff 75 0c             	pushl  0xc(%ebp)
f01016e2:	01 d8                	add    %ebx,%eax
f01016e4:	50                   	push   %eax
f01016e5:	e8 b6 ff ff ff       	call   f01016a0 <strcpy>
	return dst;
}
f01016ea:	89 d8                	mov    %ebx,%eax
f01016ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01016ef:	c9                   	leave  
f01016f0:	c3                   	ret    

f01016f1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01016f1:	f3 0f 1e fb          	endbr32 
f01016f5:	55                   	push   %ebp
f01016f6:	89 e5                	mov    %esp,%ebp
f01016f8:	56                   	push   %esi
f01016f9:	53                   	push   %ebx
f01016fa:	8b 75 08             	mov    0x8(%ebp),%esi
f01016fd:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101700:	89 f3                	mov    %esi,%ebx
f0101702:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101705:	89 f0                	mov    %esi,%eax
f0101707:	eb 0f                	jmp    f0101718 <strncpy+0x27>
		*dst++ = *src;
f0101709:	83 c0 01             	add    $0x1,%eax
f010170c:	0f b6 0a             	movzbl (%edx),%ecx
f010170f:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101712:	80 f9 01             	cmp    $0x1,%cl
f0101715:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
f0101718:	39 d8                	cmp    %ebx,%eax
f010171a:	75 ed                	jne    f0101709 <strncpy+0x18>
	}
	return ret;
}
f010171c:	89 f0                	mov    %esi,%eax
f010171e:	5b                   	pop    %ebx
f010171f:	5e                   	pop    %esi
f0101720:	5d                   	pop    %ebp
f0101721:	c3                   	ret    

f0101722 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101722:	f3 0f 1e fb          	endbr32 
f0101726:	55                   	push   %ebp
f0101727:	89 e5                	mov    %esp,%ebp
f0101729:	56                   	push   %esi
f010172a:	53                   	push   %ebx
f010172b:	8b 75 08             	mov    0x8(%ebp),%esi
f010172e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101731:	8b 45 10             	mov    0x10(%ebp),%eax
f0101734:	89 f3                	mov    %esi,%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101736:	85 c0                	test   %eax,%eax
f0101738:	74 21                	je     f010175b <strlcpy+0x39>
f010173a:	8d 5c 06 ff          	lea    -0x1(%esi,%eax,1),%ebx
f010173e:	89 f0                	mov    %esi,%eax
f0101740:	eb 09                	jmp    f010174b <strlcpy+0x29>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101742:	83 c2 01             	add    $0x1,%edx
f0101745:	83 c0 01             	add    $0x1,%eax
f0101748:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f010174b:	39 d8                	cmp    %ebx,%eax
f010174d:	74 09                	je     f0101758 <strlcpy+0x36>
f010174f:	0f b6 0a             	movzbl (%edx),%ecx
f0101752:	84 c9                	test   %cl,%cl
f0101754:	75 ec                	jne    f0101742 <strlcpy+0x20>
f0101756:	89 c3                	mov    %eax,%ebx
		*dst = '\0';
f0101758:	c6 03 00             	movb   $0x0,(%ebx)
	}
	return dst - dst_in;
f010175b:	89 d8                	mov    %ebx,%eax
f010175d:	29 f0                	sub    %esi,%eax
}
f010175f:	5b                   	pop    %ebx
f0101760:	5e                   	pop    %esi
f0101761:	5d                   	pop    %ebp
f0101762:	c3                   	ret    

f0101763 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101763:	f3 0f 1e fb          	endbr32 
f0101767:	55                   	push   %ebp
f0101768:	89 e5                	mov    %esp,%ebp
f010176a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010176d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101770:	eb 06                	jmp    f0101778 <strcmp+0x15>
		p++, q++;
f0101772:	83 c1 01             	add    $0x1,%ecx
f0101775:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0101778:	0f b6 01             	movzbl (%ecx),%eax
f010177b:	84 c0                	test   %al,%al
f010177d:	74 04                	je     f0101783 <strcmp+0x20>
f010177f:	3a 02                	cmp    (%edx),%al
f0101781:	74 ef                	je     f0101772 <strcmp+0xf>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101783:	0f b6 c0             	movzbl %al,%eax
f0101786:	0f b6 12             	movzbl (%edx),%edx
f0101789:	29 d0                	sub    %edx,%eax
}
f010178b:	5d                   	pop    %ebp
f010178c:	c3                   	ret    

f010178d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010178d:	f3 0f 1e fb          	endbr32 
f0101791:	55                   	push   %ebp
f0101792:	89 e5                	mov    %esp,%ebp
f0101794:	53                   	push   %ebx
f0101795:	8b 45 08             	mov    0x8(%ebp),%eax
f0101798:	8b 55 0c             	mov    0xc(%ebp),%edx
f010179b:	89 c3                	mov    %eax,%ebx
f010179d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01017a0:	eb 06                	jmp    f01017a8 <strncmp+0x1b>
		n--, p++, q++;
f01017a2:	83 c0 01             	add    $0x1,%eax
f01017a5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01017a8:	39 d8                	cmp    %ebx,%eax
f01017aa:	74 18                	je     f01017c4 <strncmp+0x37>
f01017ac:	0f b6 08             	movzbl (%eax),%ecx
f01017af:	84 c9                	test   %cl,%cl
f01017b1:	74 04                	je     f01017b7 <strncmp+0x2a>
f01017b3:	3a 0a                	cmp    (%edx),%cl
f01017b5:	74 eb                	je     f01017a2 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01017b7:	0f b6 00             	movzbl (%eax),%eax
f01017ba:	0f b6 12             	movzbl (%edx),%edx
f01017bd:	29 d0                	sub    %edx,%eax
}
f01017bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01017c2:	c9                   	leave  
f01017c3:	c3                   	ret    
		return 0;
f01017c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01017c9:	eb f4                	jmp    f01017bf <strncmp+0x32>

f01017cb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01017cb:	f3 0f 1e fb          	endbr32 
f01017cf:	55                   	push   %ebp
f01017d0:	89 e5                	mov    %esp,%ebp
f01017d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01017d5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01017d9:	eb 03                	jmp    f01017de <strchr+0x13>
f01017db:	83 c0 01             	add    $0x1,%eax
f01017de:	0f b6 10             	movzbl (%eax),%edx
f01017e1:	84 d2                	test   %dl,%dl
f01017e3:	74 06                	je     f01017eb <strchr+0x20>
		if (*s == c)
f01017e5:	38 ca                	cmp    %cl,%dl
f01017e7:	75 f2                	jne    f01017db <strchr+0x10>
f01017e9:	eb 05                	jmp    f01017f0 <strchr+0x25>
			return (char *) s;
	return 0;
f01017eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01017f0:	5d                   	pop    %ebp
f01017f1:	c3                   	ret    

f01017f2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01017f2:	f3 0f 1e fb          	endbr32 
f01017f6:	55                   	push   %ebp
f01017f7:	89 e5                	mov    %esp,%ebp
f01017f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01017fc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101800:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101803:	38 ca                	cmp    %cl,%dl
f0101805:	74 09                	je     f0101810 <strfind+0x1e>
f0101807:	84 d2                	test   %dl,%dl
f0101809:	74 05                	je     f0101810 <strfind+0x1e>
	for (; *s; s++)
f010180b:	83 c0 01             	add    $0x1,%eax
f010180e:	eb f0                	jmp    f0101800 <strfind+0xe>
			break;
	return (char *) s;
}
f0101810:	5d                   	pop    %ebp
f0101811:	c3                   	ret    

f0101812 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101812:	f3 0f 1e fb          	endbr32 
f0101816:	55                   	push   %ebp
f0101817:	89 e5                	mov    %esp,%ebp
f0101819:	57                   	push   %edi
f010181a:	56                   	push   %esi
f010181b:	53                   	push   %ebx
f010181c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010181f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101822:	85 c9                	test   %ecx,%ecx
f0101824:	74 31                	je     f0101857 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101826:	89 f8                	mov    %edi,%eax
f0101828:	09 c8                	or     %ecx,%eax
f010182a:	a8 03                	test   $0x3,%al
f010182c:	75 23                	jne    f0101851 <memset+0x3f>
		c &= 0xFF;
f010182e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101832:	89 d3                	mov    %edx,%ebx
f0101834:	c1 e3 08             	shl    $0x8,%ebx
f0101837:	89 d0                	mov    %edx,%eax
f0101839:	c1 e0 18             	shl    $0x18,%eax
f010183c:	89 d6                	mov    %edx,%esi
f010183e:	c1 e6 10             	shl    $0x10,%esi
f0101841:	09 f0                	or     %esi,%eax
f0101843:	09 c2                	or     %eax,%edx
f0101845:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0101847:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010184a:	89 d0                	mov    %edx,%eax
f010184c:	fc                   	cld    
f010184d:	f3 ab                	rep stos %eax,%es:(%edi)
f010184f:	eb 06                	jmp    f0101857 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101851:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101854:	fc                   	cld    
f0101855:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101857:	89 f8                	mov    %edi,%eax
f0101859:	5b                   	pop    %ebx
f010185a:	5e                   	pop    %esi
f010185b:	5f                   	pop    %edi
f010185c:	5d                   	pop    %ebp
f010185d:	c3                   	ret    

f010185e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010185e:	f3 0f 1e fb          	endbr32 
f0101862:	55                   	push   %ebp
f0101863:	89 e5                	mov    %esp,%ebp
f0101865:	57                   	push   %edi
f0101866:	56                   	push   %esi
f0101867:	8b 45 08             	mov    0x8(%ebp),%eax
f010186a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010186d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101870:	39 c6                	cmp    %eax,%esi
f0101872:	73 32                	jae    f01018a6 <memmove+0x48>
f0101874:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101877:	39 c2                	cmp    %eax,%edx
f0101879:	76 2b                	jbe    f01018a6 <memmove+0x48>
		s += n;
		d += n;
f010187b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010187e:	89 fe                	mov    %edi,%esi
f0101880:	09 ce                	or     %ecx,%esi
f0101882:	09 d6                	or     %edx,%esi
f0101884:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010188a:	75 0e                	jne    f010189a <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010188c:	83 ef 04             	sub    $0x4,%edi
f010188f:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101892:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0101895:	fd                   	std    
f0101896:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101898:	eb 09                	jmp    f01018a3 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010189a:	83 ef 01             	sub    $0x1,%edi
f010189d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01018a0:	fd                   	std    
f01018a1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01018a3:	fc                   	cld    
f01018a4:	eb 1a                	jmp    f01018c0 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01018a6:	89 c2                	mov    %eax,%edx
f01018a8:	09 ca                	or     %ecx,%edx
f01018aa:	09 f2                	or     %esi,%edx
f01018ac:	f6 c2 03             	test   $0x3,%dl
f01018af:	75 0a                	jne    f01018bb <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01018b1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01018b4:	89 c7                	mov    %eax,%edi
f01018b6:	fc                   	cld    
f01018b7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01018b9:	eb 05                	jmp    f01018c0 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f01018bb:	89 c7                	mov    %eax,%edi
f01018bd:	fc                   	cld    
f01018be:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01018c0:	5e                   	pop    %esi
f01018c1:	5f                   	pop    %edi
f01018c2:	5d                   	pop    %ebp
f01018c3:	c3                   	ret    

f01018c4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01018c4:	f3 0f 1e fb          	endbr32 
f01018c8:	55                   	push   %ebp
f01018c9:	89 e5                	mov    %esp,%ebp
f01018cb:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01018ce:	ff 75 10             	pushl  0x10(%ebp)
f01018d1:	ff 75 0c             	pushl  0xc(%ebp)
f01018d4:	ff 75 08             	pushl  0x8(%ebp)
f01018d7:	e8 82 ff ff ff       	call   f010185e <memmove>
}
f01018dc:	c9                   	leave  
f01018dd:	c3                   	ret    

f01018de <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01018de:	f3 0f 1e fb          	endbr32 
f01018e2:	55                   	push   %ebp
f01018e3:	89 e5                	mov    %esp,%ebp
f01018e5:	56                   	push   %esi
f01018e6:	53                   	push   %ebx
f01018e7:	8b 45 08             	mov    0x8(%ebp),%eax
f01018ea:	8b 55 0c             	mov    0xc(%ebp),%edx
f01018ed:	89 c6                	mov    %eax,%esi
f01018ef:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01018f2:	eb 06                	jmp    f01018fa <memcmp+0x1c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01018f4:	83 c0 01             	add    $0x1,%eax
f01018f7:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
f01018fa:	39 f0                	cmp    %esi,%eax
f01018fc:	74 14                	je     f0101912 <memcmp+0x34>
		if (*s1 != *s2)
f01018fe:	0f b6 08             	movzbl (%eax),%ecx
f0101901:	0f b6 1a             	movzbl (%edx),%ebx
f0101904:	38 d9                	cmp    %bl,%cl
f0101906:	74 ec                	je     f01018f4 <memcmp+0x16>
			return (int) *s1 - (int) *s2;
f0101908:	0f b6 c1             	movzbl %cl,%eax
f010190b:	0f b6 db             	movzbl %bl,%ebx
f010190e:	29 d8                	sub    %ebx,%eax
f0101910:	eb 05                	jmp    f0101917 <memcmp+0x39>
	}

	return 0;
f0101912:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101917:	5b                   	pop    %ebx
f0101918:	5e                   	pop    %esi
f0101919:	5d                   	pop    %ebp
f010191a:	c3                   	ret    

f010191b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010191b:	f3 0f 1e fb          	endbr32 
f010191f:	55                   	push   %ebp
f0101920:	89 e5                	mov    %esp,%ebp
f0101922:	8b 45 08             	mov    0x8(%ebp),%eax
f0101925:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101928:	89 c2                	mov    %eax,%edx
f010192a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010192d:	eb 03                	jmp    f0101932 <memfind+0x17>
f010192f:	83 c0 01             	add    $0x1,%eax
f0101932:	39 d0                	cmp    %edx,%eax
f0101934:	73 04                	jae    f010193a <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101936:	38 08                	cmp    %cl,(%eax)
f0101938:	75 f5                	jne    f010192f <memfind+0x14>
			break;
	return (void *) s;
}
f010193a:	5d                   	pop    %ebp
f010193b:	c3                   	ret    

f010193c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010193c:	f3 0f 1e fb          	endbr32 
f0101940:	55                   	push   %ebp
f0101941:	89 e5                	mov    %esp,%ebp
f0101943:	57                   	push   %edi
f0101944:	56                   	push   %esi
f0101945:	53                   	push   %ebx
f0101946:	8b 55 08             	mov    0x8(%ebp),%edx
f0101949:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010194c:	eb 03                	jmp    f0101951 <strtol+0x15>
		s++;
f010194e:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
f0101951:	0f b6 02             	movzbl (%edx),%eax
f0101954:	3c 20                	cmp    $0x20,%al
f0101956:	74 f6                	je     f010194e <strtol+0x12>
f0101958:	3c 09                	cmp    $0x9,%al
f010195a:	74 f2                	je     f010194e <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f010195c:	3c 2b                	cmp    $0x2b,%al
f010195e:	74 2a                	je     f010198a <strtol+0x4e>
	int neg = 0;
f0101960:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101965:	3c 2d                	cmp    $0x2d,%al
f0101967:	74 2b                	je     f0101994 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101969:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010196f:	75 0f                	jne    f0101980 <strtol+0x44>
f0101971:	80 3a 30             	cmpb   $0x30,(%edx)
f0101974:	74 28                	je     f010199e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101976:	85 db                	test   %ebx,%ebx
f0101978:	b8 0a 00 00 00       	mov    $0xa,%eax
f010197d:	0f 44 d8             	cmove  %eax,%ebx
f0101980:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101985:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101988:	eb 46                	jmp    f01019d0 <strtol+0x94>
		s++;
f010198a:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
f010198d:	bf 00 00 00 00       	mov    $0x0,%edi
f0101992:	eb d5                	jmp    f0101969 <strtol+0x2d>
		s++, neg = 1;
f0101994:	83 c2 01             	add    $0x1,%edx
f0101997:	bf 01 00 00 00       	mov    $0x1,%edi
f010199c:	eb cb                	jmp    f0101969 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010199e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01019a2:	74 0e                	je     f01019b2 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01019a4:	85 db                	test   %ebx,%ebx
f01019a6:	75 d8                	jne    f0101980 <strtol+0x44>
		s++, base = 8;
f01019a8:	83 c2 01             	add    $0x1,%edx
f01019ab:	bb 08 00 00 00       	mov    $0x8,%ebx
f01019b0:	eb ce                	jmp    f0101980 <strtol+0x44>
		s += 2, base = 16;
f01019b2:	83 c2 02             	add    $0x2,%edx
f01019b5:	bb 10 00 00 00       	mov    $0x10,%ebx
f01019ba:	eb c4                	jmp    f0101980 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f01019bc:	0f be c0             	movsbl %al,%eax
f01019bf:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01019c2:	3b 45 10             	cmp    0x10(%ebp),%eax
f01019c5:	7d 3a                	jge    f0101a01 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f01019c7:	83 c2 01             	add    $0x1,%edx
f01019ca:	0f af 4d 10          	imul   0x10(%ebp),%ecx
f01019ce:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
f01019d0:	0f b6 02             	movzbl (%edx),%eax
f01019d3:	8d 70 d0             	lea    -0x30(%eax),%esi
f01019d6:	89 f3                	mov    %esi,%ebx
f01019d8:	80 fb 09             	cmp    $0x9,%bl
f01019db:	76 df                	jbe    f01019bc <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f01019dd:	8d 70 9f             	lea    -0x61(%eax),%esi
f01019e0:	89 f3                	mov    %esi,%ebx
f01019e2:	80 fb 19             	cmp    $0x19,%bl
f01019e5:	77 08                	ja     f01019ef <strtol+0xb3>
			dig = *s - 'a' + 10;
f01019e7:	0f be c0             	movsbl %al,%eax
f01019ea:	83 e8 57             	sub    $0x57,%eax
f01019ed:	eb d3                	jmp    f01019c2 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f01019ef:	8d 70 bf             	lea    -0x41(%eax),%esi
f01019f2:	89 f3                	mov    %esi,%ebx
f01019f4:	80 fb 19             	cmp    $0x19,%bl
f01019f7:	77 08                	ja     f0101a01 <strtol+0xc5>
			dig = *s - 'A' + 10;
f01019f9:	0f be c0             	movsbl %al,%eax
f01019fc:	83 e8 37             	sub    $0x37,%eax
f01019ff:	eb c1                	jmp    f01019c2 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f0101a01:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101a05:	74 05                	je     f0101a0c <strtol+0xd0>
		*endptr = (char *) s;
f0101a07:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101a0a:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f0101a0c:	89 c8                	mov    %ecx,%eax
f0101a0e:	f7 d8                	neg    %eax
f0101a10:	85 ff                	test   %edi,%edi
f0101a12:	0f 45 c8             	cmovne %eax,%ecx
}
f0101a15:	89 c8                	mov    %ecx,%eax
f0101a17:	5b                   	pop    %ebx
f0101a18:	5e                   	pop    %esi
f0101a19:	5f                   	pop    %edi
f0101a1a:	5d                   	pop    %ebp
f0101a1b:	c3                   	ret    
f0101a1c:	66 90                	xchg   %ax,%ax
f0101a1e:	66 90                	xchg   %ax,%ax

f0101a20 <__udivdi3>:
f0101a20:	f3 0f 1e fb          	endbr32 
f0101a24:	55                   	push   %ebp
f0101a25:	57                   	push   %edi
f0101a26:	56                   	push   %esi
f0101a27:	53                   	push   %ebx
f0101a28:	83 ec 1c             	sub    $0x1c,%esp
f0101a2b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0101a2f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0101a33:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101a37:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0101a3b:	85 d2                	test   %edx,%edx
f0101a3d:	75 19                	jne    f0101a58 <__udivdi3+0x38>
f0101a3f:	39 f3                	cmp    %esi,%ebx
f0101a41:	76 4d                	jbe    f0101a90 <__udivdi3+0x70>
f0101a43:	31 ff                	xor    %edi,%edi
f0101a45:	89 e8                	mov    %ebp,%eax
f0101a47:	89 f2                	mov    %esi,%edx
f0101a49:	f7 f3                	div    %ebx
f0101a4b:	89 fa                	mov    %edi,%edx
f0101a4d:	83 c4 1c             	add    $0x1c,%esp
f0101a50:	5b                   	pop    %ebx
f0101a51:	5e                   	pop    %esi
f0101a52:	5f                   	pop    %edi
f0101a53:	5d                   	pop    %ebp
f0101a54:	c3                   	ret    
f0101a55:	8d 76 00             	lea    0x0(%esi),%esi
f0101a58:	39 f2                	cmp    %esi,%edx
f0101a5a:	76 14                	jbe    f0101a70 <__udivdi3+0x50>
f0101a5c:	31 ff                	xor    %edi,%edi
f0101a5e:	31 c0                	xor    %eax,%eax
f0101a60:	89 fa                	mov    %edi,%edx
f0101a62:	83 c4 1c             	add    $0x1c,%esp
f0101a65:	5b                   	pop    %ebx
f0101a66:	5e                   	pop    %esi
f0101a67:	5f                   	pop    %edi
f0101a68:	5d                   	pop    %ebp
f0101a69:	c3                   	ret    
f0101a6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a70:	0f bd fa             	bsr    %edx,%edi
f0101a73:	83 f7 1f             	xor    $0x1f,%edi
f0101a76:	75 48                	jne    f0101ac0 <__udivdi3+0xa0>
f0101a78:	39 f2                	cmp    %esi,%edx
f0101a7a:	72 06                	jb     f0101a82 <__udivdi3+0x62>
f0101a7c:	31 c0                	xor    %eax,%eax
f0101a7e:	39 eb                	cmp    %ebp,%ebx
f0101a80:	77 de                	ja     f0101a60 <__udivdi3+0x40>
f0101a82:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a87:	eb d7                	jmp    f0101a60 <__udivdi3+0x40>
f0101a89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a90:	89 d9                	mov    %ebx,%ecx
f0101a92:	85 db                	test   %ebx,%ebx
f0101a94:	75 0b                	jne    f0101aa1 <__udivdi3+0x81>
f0101a96:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a9b:	31 d2                	xor    %edx,%edx
f0101a9d:	f7 f3                	div    %ebx
f0101a9f:	89 c1                	mov    %eax,%ecx
f0101aa1:	31 d2                	xor    %edx,%edx
f0101aa3:	89 f0                	mov    %esi,%eax
f0101aa5:	f7 f1                	div    %ecx
f0101aa7:	89 c6                	mov    %eax,%esi
f0101aa9:	89 e8                	mov    %ebp,%eax
f0101aab:	89 f7                	mov    %esi,%edi
f0101aad:	f7 f1                	div    %ecx
f0101aaf:	89 fa                	mov    %edi,%edx
f0101ab1:	83 c4 1c             	add    $0x1c,%esp
f0101ab4:	5b                   	pop    %ebx
f0101ab5:	5e                   	pop    %esi
f0101ab6:	5f                   	pop    %edi
f0101ab7:	5d                   	pop    %ebp
f0101ab8:	c3                   	ret    
f0101ab9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101ac0:	89 f9                	mov    %edi,%ecx
f0101ac2:	b8 20 00 00 00       	mov    $0x20,%eax
f0101ac7:	29 f8                	sub    %edi,%eax
f0101ac9:	d3 e2                	shl    %cl,%edx
f0101acb:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101acf:	89 c1                	mov    %eax,%ecx
f0101ad1:	89 da                	mov    %ebx,%edx
f0101ad3:	d3 ea                	shr    %cl,%edx
f0101ad5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101ad9:	09 d1                	or     %edx,%ecx
f0101adb:	89 f2                	mov    %esi,%edx
f0101add:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101ae1:	89 f9                	mov    %edi,%ecx
f0101ae3:	d3 e3                	shl    %cl,%ebx
f0101ae5:	89 c1                	mov    %eax,%ecx
f0101ae7:	d3 ea                	shr    %cl,%edx
f0101ae9:	89 f9                	mov    %edi,%ecx
f0101aeb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101aef:	89 eb                	mov    %ebp,%ebx
f0101af1:	d3 e6                	shl    %cl,%esi
f0101af3:	89 c1                	mov    %eax,%ecx
f0101af5:	d3 eb                	shr    %cl,%ebx
f0101af7:	09 de                	or     %ebx,%esi
f0101af9:	89 f0                	mov    %esi,%eax
f0101afb:	f7 74 24 08          	divl   0x8(%esp)
f0101aff:	89 d6                	mov    %edx,%esi
f0101b01:	89 c3                	mov    %eax,%ebx
f0101b03:	f7 64 24 0c          	mull   0xc(%esp)
f0101b07:	39 d6                	cmp    %edx,%esi
f0101b09:	72 15                	jb     f0101b20 <__udivdi3+0x100>
f0101b0b:	89 f9                	mov    %edi,%ecx
f0101b0d:	d3 e5                	shl    %cl,%ebp
f0101b0f:	39 c5                	cmp    %eax,%ebp
f0101b11:	73 04                	jae    f0101b17 <__udivdi3+0xf7>
f0101b13:	39 d6                	cmp    %edx,%esi
f0101b15:	74 09                	je     f0101b20 <__udivdi3+0x100>
f0101b17:	89 d8                	mov    %ebx,%eax
f0101b19:	31 ff                	xor    %edi,%edi
f0101b1b:	e9 40 ff ff ff       	jmp    f0101a60 <__udivdi3+0x40>
f0101b20:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101b23:	31 ff                	xor    %edi,%edi
f0101b25:	e9 36 ff ff ff       	jmp    f0101a60 <__udivdi3+0x40>
f0101b2a:	66 90                	xchg   %ax,%ax
f0101b2c:	66 90                	xchg   %ax,%ax
f0101b2e:	66 90                	xchg   %ax,%ax

f0101b30 <__umoddi3>:
f0101b30:	f3 0f 1e fb          	endbr32 
f0101b34:	55                   	push   %ebp
f0101b35:	57                   	push   %edi
f0101b36:	56                   	push   %esi
f0101b37:	53                   	push   %ebx
f0101b38:	83 ec 1c             	sub    $0x1c,%esp
f0101b3b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0101b3f:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101b43:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101b47:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101b4b:	85 c0                	test   %eax,%eax
f0101b4d:	75 19                	jne    f0101b68 <__umoddi3+0x38>
f0101b4f:	39 df                	cmp    %ebx,%edi
f0101b51:	76 5d                	jbe    f0101bb0 <__umoddi3+0x80>
f0101b53:	89 f0                	mov    %esi,%eax
f0101b55:	89 da                	mov    %ebx,%edx
f0101b57:	f7 f7                	div    %edi
f0101b59:	89 d0                	mov    %edx,%eax
f0101b5b:	31 d2                	xor    %edx,%edx
f0101b5d:	83 c4 1c             	add    $0x1c,%esp
f0101b60:	5b                   	pop    %ebx
f0101b61:	5e                   	pop    %esi
f0101b62:	5f                   	pop    %edi
f0101b63:	5d                   	pop    %ebp
f0101b64:	c3                   	ret    
f0101b65:	8d 76 00             	lea    0x0(%esi),%esi
f0101b68:	89 f2                	mov    %esi,%edx
f0101b6a:	39 d8                	cmp    %ebx,%eax
f0101b6c:	76 12                	jbe    f0101b80 <__umoddi3+0x50>
f0101b6e:	89 f0                	mov    %esi,%eax
f0101b70:	89 da                	mov    %ebx,%edx
f0101b72:	83 c4 1c             	add    $0x1c,%esp
f0101b75:	5b                   	pop    %ebx
f0101b76:	5e                   	pop    %esi
f0101b77:	5f                   	pop    %edi
f0101b78:	5d                   	pop    %ebp
f0101b79:	c3                   	ret    
f0101b7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101b80:	0f bd e8             	bsr    %eax,%ebp
f0101b83:	83 f5 1f             	xor    $0x1f,%ebp
f0101b86:	75 50                	jne    f0101bd8 <__umoddi3+0xa8>
f0101b88:	39 d8                	cmp    %ebx,%eax
f0101b8a:	0f 82 e0 00 00 00    	jb     f0101c70 <__umoddi3+0x140>
f0101b90:	89 d9                	mov    %ebx,%ecx
f0101b92:	39 f7                	cmp    %esi,%edi
f0101b94:	0f 86 d6 00 00 00    	jbe    f0101c70 <__umoddi3+0x140>
f0101b9a:	89 d0                	mov    %edx,%eax
f0101b9c:	89 ca                	mov    %ecx,%edx
f0101b9e:	83 c4 1c             	add    $0x1c,%esp
f0101ba1:	5b                   	pop    %ebx
f0101ba2:	5e                   	pop    %esi
f0101ba3:	5f                   	pop    %edi
f0101ba4:	5d                   	pop    %ebp
f0101ba5:	c3                   	ret    
f0101ba6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101bad:	8d 76 00             	lea    0x0(%esi),%esi
f0101bb0:	89 fd                	mov    %edi,%ebp
f0101bb2:	85 ff                	test   %edi,%edi
f0101bb4:	75 0b                	jne    f0101bc1 <__umoddi3+0x91>
f0101bb6:	b8 01 00 00 00       	mov    $0x1,%eax
f0101bbb:	31 d2                	xor    %edx,%edx
f0101bbd:	f7 f7                	div    %edi
f0101bbf:	89 c5                	mov    %eax,%ebp
f0101bc1:	89 d8                	mov    %ebx,%eax
f0101bc3:	31 d2                	xor    %edx,%edx
f0101bc5:	f7 f5                	div    %ebp
f0101bc7:	89 f0                	mov    %esi,%eax
f0101bc9:	f7 f5                	div    %ebp
f0101bcb:	89 d0                	mov    %edx,%eax
f0101bcd:	31 d2                	xor    %edx,%edx
f0101bcf:	eb 8c                	jmp    f0101b5d <__umoddi3+0x2d>
f0101bd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101bd8:	89 e9                	mov    %ebp,%ecx
f0101bda:	ba 20 00 00 00       	mov    $0x20,%edx
f0101bdf:	29 ea                	sub    %ebp,%edx
f0101be1:	d3 e0                	shl    %cl,%eax
f0101be3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101be7:	89 d1                	mov    %edx,%ecx
f0101be9:	89 f8                	mov    %edi,%eax
f0101beb:	d3 e8                	shr    %cl,%eax
f0101bed:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101bf1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101bf5:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101bf9:	09 c1                	or     %eax,%ecx
f0101bfb:	89 d8                	mov    %ebx,%eax
f0101bfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101c01:	89 e9                	mov    %ebp,%ecx
f0101c03:	d3 e7                	shl    %cl,%edi
f0101c05:	89 d1                	mov    %edx,%ecx
f0101c07:	d3 e8                	shr    %cl,%eax
f0101c09:	89 e9                	mov    %ebp,%ecx
f0101c0b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101c0f:	d3 e3                	shl    %cl,%ebx
f0101c11:	89 c7                	mov    %eax,%edi
f0101c13:	89 d1                	mov    %edx,%ecx
f0101c15:	89 f0                	mov    %esi,%eax
f0101c17:	d3 e8                	shr    %cl,%eax
f0101c19:	89 e9                	mov    %ebp,%ecx
f0101c1b:	89 fa                	mov    %edi,%edx
f0101c1d:	d3 e6                	shl    %cl,%esi
f0101c1f:	09 d8                	or     %ebx,%eax
f0101c21:	f7 74 24 08          	divl   0x8(%esp)
f0101c25:	89 d1                	mov    %edx,%ecx
f0101c27:	89 f3                	mov    %esi,%ebx
f0101c29:	f7 64 24 0c          	mull   0xc(%esp)
f0101c2d:	89 c6                	mov    %eax,%esi
f0101c2f:	89 d7                	mov    %edx,%edi
f0101c31:	39 d1                	cmp    %edx,%ecx
f0101c33:	72 06                	jb     f0101c3b <__umoddi3+0x10b>
f0101c35:	75 10                	jne    f0101c47 <__umoddi3+0x117>
f0101c37:	39 c3                	cmp    %eax,%ebx
f0101c39:	73 0c                	jae    f0101c47 <__umoddi3+0x117>
f0101c3b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f0101c3f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0101c43:	89 d7                	mov    %edx,%edi
f0101c45:	89 c6                	mov    %eax,%esi
f0101c47:	89 ca                	mov    %ecx,%edx
f0101c49:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101c4e:	29 f3                	sub    %esi,%ebx
f0101c50:	19 fa                	sbb    %edi,%edx
f0101c52:	89 d0                	mov    %edx,%eax
f0101c54:	d3 e0                	shl    %cl,%eax
f0101c56:	89 e9                	mov    %ebp,%ecx
f0101c58:	d3 eb                	shr    %cl,%ebx
f0101c5a:	d3 ea                	shr    %cl,%edx
f0101c5c:	09 d8                	or     %ebx,%eax
f0101c5e:	83 c4 1c             	add    $0x1c,%esp
f0101c61:	5b                   	pop    %ebx
f0101c62:	5e                   	pop    %esi
f0101c63:	5f                   	pop    %edi
f0101c64:	5d                   	pop    %ebp
f0101c65:	c3                   	ret    
f0101c66:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101c6d:	8d 76 00             	lea    0x0(%esi),%esi
f0101c70:	89 d9                	mov    %ebx,%ecx
f0101c72:	89 f2                	mov    %esi,%edx
f0101c74:	29 fa                	sub    %edi,%edx
f0101c76:	19 c1                	sbb    %eax,%ecx
f0101c78:	e9 1d ff ff ff       	jmp    f0101b9a <__umoddi3+0x6a>
