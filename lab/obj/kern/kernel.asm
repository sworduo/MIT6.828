
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
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
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
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

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
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 80 18 10 f0       	push   $0xf0101880
f0100050:	e8 a3 08 00 00       	call   f01008f8 <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
	else
		mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 f3 06 00 00       	call   f010076e <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 9c 18 10 f0       	push   $0xf010189c
f0100087:	e8 6c 08 00 00       	call   f01008f8 <cprintf>
}
f010008c:	83 c4 10             	add    $0x10,%esp
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009a:	b8 40 29 11 f0       	mov    $0xf0112940,%eax
f010009f:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 23 11 f0       	push   $0xf0112300
f01000ac:	e8 30 13 00 00       	call   f01013e1 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 9d 04 00 00       	call   f0100553 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 b7 18 10 f0       	push   $0xf01018b7
f01000c3:	e8 30 08 00 00       	call   f01008f8 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000c8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000cf:	e8 6c ff ff ff       	call   f0100040 <test_backtrace>
f01000d4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000d7:	83 ec 0c             	sub    $0xc,%esp
f01000da:	6a 00                	push   $0x0
f01000dc:	e8 97 06 00 00       	call   f0100778 <monitor>
f01000e1:	83 c4 10             	add    $0x10,%esp
f01000e4:	eb f1                	jmp    f01000d7 <i386_init+0x43>

f01000e6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000e6:	55                   	push   %ebp
f01000e7:	89 e5                	mov    %esp,%ebp
f01000e9:	56                   	push   %esi
f01000ea:	53                   	push   %ebx
f01000eb:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000ee:	83 3d 44 29 11 f0 00 	cmpl   $0x0,0xf0112944
f01000f5:	75 37                	jne    f010012e <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000f7:	89 35 44 29 11 f0    	mov    %esi,0xf0112944

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000fd:	fa                   	cli    
f01000fe:	fc                   	cld    

	va_start(ap, fmt);
f01000ff:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100102:	83 ec 04             	sub    $0x4,%esp
f0100105:	ff 75 0c             	pushl  0xc(%ebp)
f0100108:	ff 75 08             	pushl  0x8(%ebp)
f010010b:	68 d2 18 10 f0       	push   $0xf01018d2
f0100110:	e8 e3 07 00 00       	call   f01008f8 <cprintf>
	vcprintf(fmt, ap);
f0100115:	83 c4 08             	add    $0x8,%esp
f0100118:	53                   	push   %ebx
f0100119:	56                   	push   %esi
f010011a:	e8 b3 07 00 00       	call   f01008d2 <vcprintf>
	cprintf("\n");
f010011f:	c7 04 24 0e 19 10 f0 	movl   $0xf010190e,(%esp)
f0100126:	e8 cd 07 00 00       	call   f01008f8 <cprintf>
	va_end(ap);
f010012b:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010012e:	83 ec 0c             	sub    $0xc,%esp
f0100131:	6a 00                	push   $0x0
f0100133:	e8 40 06 00 00       	call   f0100778 <monitor>
f0100138:	83 c4 10             	add    $0x10,%esp
f010013b:	eb f1                	jmp    f010012e <_panic+0x48>

f010013d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010013d:	55                   	push   %ebp
f010013e:	89 e5                	mov    %esp,%ebp
f0100140:	53                   	push   %ebx
f0100141:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100144:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100147:	ff 75 0c             	pushl  0xc(%ebp)
f010014a:	ff 75 08             	pushl  0x8(%ebp)
f010014d:	68 ea 18 10 f0       	push   $0xf01018ea
f0100152:	e8 a1 07 00 00       	call   f01008f8 <cprintf>
	vcprintf(fmt, ap);
f0100157:	83 c4 08             	add    $0x8,%esp
f010015a:	53                   	push   %ebx
f010015b:	ff 75 10             	pushl  0x10(%ebp)
f010015e:	e8 6f 07 00 00       	call   f01008d2 <vcprintf>
	cprintf("\n");
f0100163:	c7 04 24 0e 19 10 f0 	movl   $0xf010190e,(%esp)
f010016a:	e8 89 07 00 00       	call   f01008f8 <cprintf>
	va_end(ap);
}
f010016f:	83 c4 10             	add    $0x10,%esp
f0100172:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100175:	c9                   	leave  
f0100176:	c3                   	ret    

f0100177 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100177:	55                   	push   %ebp
f0100178:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010017a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010017f:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100180:	a8 01                	test   $0x1,%al
f0100182:	74 0b                	je     f010018f <serial_proc_data+0x18>
f0100184:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100189:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010018a:	0f b6 c0             	movzbl %al,%eax
f010018d:	eb 05                	jmp    f0100194 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010018f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100194:	5d                   	pop    %ebp
f0100195:	c3                   	ret    

f0100196 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100196:	55                   	push   %ebp
f0100197:	89 e5                	mov    %esp,%ebp
f0100199:	53                   	push   %ebx
f010019a:	83 ec 04             	sub    $0x4,%esp
f010019d:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010019f:	eb 2b                	jmp    f01001cc <cons_intr+0x36>
		if (c == 0)
f01001a1:	85 c0                	test   %eax,%eax
f01001a3:	74 27                	je     f01001cc <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a5:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f01001ab:	8d 51 01             	lea    0x1(%ecx),%edx
f01001ae:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f01001b4:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001ba:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c0:	75 0a                	jne    f01001cc <cons_intr+0x36>
			cons.wpos = 0;
f01001c2:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f01001c9:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001cc:	ff d3                	call   *%ebx
f01001ce:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001d1:	75 ce                	jne    f01001a1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001d3:	83 c4 04             	add    $0x4,%esp
f01001d6:	5b                   	pop    %ebx
f01001d7:	5d                   	pop    %ebp
f01001d8:	c3                   	ret    

f01001d9 <kbd_proc_data>:
f01001d9:	ba 64 00 00 00       	mov    $0x64,%edx
f01001de:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01001df:	a8 01                	test   $0x1,%al
f01001e1:	0f 84 f8 00 00 00    	je     f01002df <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01001e7:	a8 20                	test   $0x20,%al
f01001e9:	0f 85 f6 00 00 00    	jne    f01002e5 <kbd_proc_data+0x10c>
f01001ef:	ba 60 00 00 00       	mov    $0x60,%edx
f01001f4:	ec                   	in     (%dx),%al
f01001f5:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001f7:	3c e0                	cmp    $0xe0,%al
f01001f9:	75 0d                	jne    f0100208 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01001fb:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f0100202:	b8 00 00 00 00       	mov    $0x0,%eax
f0100207:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100208:	55                   	push   %ebp
f0100209:	89 e5                	mov    %esp,%ebp
f010020b:	53                   	push   %ebx
f010020c:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010020f:	84 c0                	test   %al,%al
f0100211:	79 36                	jns    f0100249 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100213:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100219:	89 cb                	mov    %ecx,%ebx
f010021b:	83 e3 40             	and    $0x40,%ebx
f010021e:	83 e0 7f             	and    $0x7f,%eax
f0100221:	85 db                	test   %ebx,%ebx
f0100223:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100226:	0f b6 d2             	movzbl %dl,%edx
f0100229:	0f b6 82 60 1a 10 f0 	movzbl -0xfefe5a0(%edx),%eax
f0100230:	83 c8 40             	or     $0x40,%eax
f0100233:	0f b6 c0             	movzbl %al,%eax
f0100236:	f7 d0                	not    %eax
f0100238:	21 c8                	and    %ecx,%eax
f010023a:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f010023f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100244:	e9 a4 00 00 00       	jmp    f01002ed <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100249:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f010024f:	f6 c1 40             	test   $0x40,%cl
f0100252:	74 0e                	je     f0100262 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100254:	83 c8 80             	or     $0xffffff80,%eax
f0100257:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100259:	83 e1 bf             	and    $0xffffffbf,%ecx
f010025c:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f0100262:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100265:	0f b6 82 60 1a 10 f0 	movzbl -0xfefe5a0(%edx),%eax
f010026c:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
f0100272:	0f b6 8a 60 19 10 f0 	movzbl -0xfefe6a0(%edx),%ecx
f0100279:	31 c8                	xor    %ecx,%eax
f010027b:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100280:	89 c1                	mov    %eax,%ecx
f0100282:	83 e1 03             	and    $0x3,%ecx
f0100285:	8b 0c 8d 40 19 10 f0 	mov    -0xfefe6c0(,%ecx,4),%ecx
f010028c:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100290:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100293:	a8 08                	test   $0x8,%al
f0100295:	74 1b                	je     f01002b2 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f0100297:	89 da                	mov    %ebx,%edx
f0100299:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010029c:	83 f9 19             	cmp    $0x19,%ecx
f010029f:	77 05                	ja     f01002a6 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01002a1:	83 eb 20             	sub    $0x20,%ebx
f01002a4:	eb 0c                	jmp    f01002b2 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01002a6:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002a9:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002ac:	83 fa 19             	cmp    $0x19,%edx
f01002af:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002b2:	f7 d0                	not    %eax
f01002b4:	a8 06                	test   $0x6,%al
f01002b6:	75 33                	jne    f01002eb <kbd_proc_data+0x112>
f01002b8:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002be:	75 2b                	jne    f01002eb <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01002c0:	83 ec 0c             	sub    $0xc,%esp
f01002c3:	68 04 19 10 f0       	push   $0xf0101904
f01002c8:	e8 2b 06 00 00       	call   f01008f8 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002cd:	ba 92 00 00 00       	mov    $0x92,%edx
f01002d2:	b8 03 00 00 00       	mov    $0x3,%eax
f01002d7:	ee                   	out    %al,(%dx)
f01002d8:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002db:	89 d8                	mov    %ebx,%eax
f01002dd:	eb 0e                	jmp    f01002ed <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01002df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002e4:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01002e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002ea:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002eb:	89 d8                	mov    %ebx,%eax
}
f01002ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002f0:	c9                   	leave  
f01002f1:	c3                   	ret    

f01002f2 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002f2:	55                   	push   %ebp
f01002f3:	89 e5                	mov    %esp,%ebp
f01002f5:	57                   	push   %edi
f01002f6:	56                   	push   %esi
f01002f7:	53                   	push   %ebx
f01002f8:	83 ec 1c             	sub    $0x1c,%esp
f01002fb:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002fd:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100302:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100307:	b9 84 00 00 00       	mov    $0x84,%ecx
f010030c:	eb 09                	jmp    f0100317 <cons_putc+0x25>
f010030e:	89 ca                	mov    %ecx,%edx
f0100310:	ec                   	in     (%dx),%al
f0100311:	ec                   	in     (%dx),%al
f0100312:	ec                   	in     (%dx),%al
f0100313:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100314:	83 c3 01             	add    $0x1,%ebx
f0100317:	89 f2                	mov    %esi,%edx
f0100319:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010031a:	a8 20                	test   $0x20,%al
f010031c:	75 08                	jne    f0100326 <cons_putc+0x34>
f010031e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100324:	7e e8                	jle    f010030e <cons_putc+0x1c>
f0100326:	89 f8                	mov    %edi,%eax
f0100328:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010032b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100330:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100331:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100336:	be 79 03 00 00       	mov    $0x379,%esi
f010033b:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100340:	eb 09                	jmp    f010034b <cons_putc+0x59>
f0100342:	89 ca                	mov    %ecx,%edx
f0100344:	ec                   	in     (%dx),%al
f0100345:	ec                   	in     (%dx),%al
f0100346:	ec                   	in     (%dx),%al
f0100347:	ec                   	in     (%dx),%al
f0100348:	83 c3 01             	add    $0x1,%ebx
f010034b:	89 f2                	mov    %esi,%edx
f010034d:	ec                   	in     (%dx),%al
f010034e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100354:	7f 04                	jg     f010035a <cons_putc+0x68>
f0100356:	84 c0                	test   %al,%al
f0100358:	79 e8                	jns    f0100342 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010035a:	ba 78 03 00 00       	mov    $0x378,%edx
f010035f:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100363:	ee                   	out    %al,(%dx)
f0100364:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100369:	b8 0d 00 00 00       	mov    $0xd,%eax
f010036e:	ee                   	out    %al,(%dx)
f010036f:	b8 08 00 00 00       	mov    $0x8,%eax
f0100374:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100375:	89 fa                	mov    %edi,%edx
f0100377:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010037d:	89 f8                	mov    %edi,%eax
f010037f:	80 cc 07             	or     $0x7,%ah
f0100382:	85 d2                	test   %edx,%edx
f0100384:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100387:	89 f8                	mov    %edi,%eax
f0100389:	0f b6 c0             	movzbl %al,%eax
f010038c:	83 f8 09             	cmp    $0x9,%eax
f010038f:	74 74                	je     f0100405 <cons_putc+0x113>
f0100391:	83 f8 09             	cmp    $0x9,%eax
f0100394:	7f 0a                	jg     f01003a0 <cons_putc+0xae>
f0100396:	83 f8 08             	cmp    $0x8,%eax
f0100399:	74 14                	je     f01003af <cons_putc+0xbd>
f010039b:	e9 99 00 00 00       	jmp    f0100439 <cons_putc+0x147>
f01003a0:	83 f8 0a             	cmp    $0xa,%eax
f01003a3:	74 3a                	je     f01003df <cons_putc+0xed>
f01003a5:	83 f8 0d             	cmp    $0xd,%eax
f01003a8:	74 3d                	je     f01003e7 <cons_putc+0xf5>
f01003aa:	e9 8a 00 00 00       	jmp    f0100439 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01003af:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003b6:	66 85 c0             	test   %ax,%ax
f01003b9:	0f 84 e6 00 00 00    	je     f01004a5 <cons_putc+0x1b3>
			crt_pos--;
f01003bf:	83 e8 01             	sub    $0x1,%eax
f01003c2:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003c8:	0f b7 c0             	movzwl %ax,%eax
f01003cb:	66 81 e7 00 ff       	and    $0xff00,%di
f01003d0:	83 cf 20             	or     $0x20,%edi
f01003d3:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01003d9:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003dd:	eb 78                	jmp    f0100457 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003df:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f01003e6:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003e7:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003ee:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003f4:	c1 e8 16             	shr    $0x16,%eax
f01003f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003fa:	c1 e0 04             	shl    $0x4,%eax
f01003fd:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
f0100403:	eb 52                	jmp    f0100457 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f0100405:	b8 20 00 00 00       	mov    $0x20,%eax
f010040a:	e8 e3 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f010040f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100414:	e8 d9 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f0100419:	b8 20 00 00 00       	mov    $0x20,%eax
f010041e:	e8 cf fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f0100423:	b8 20 00 00 00       	mov    $0x20,%eax
f0100428:	e8 c5 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f010042d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100432:	e8 bb fe ff ff       	call   f01002f2 <cons_putc>
f0100437:	eb 1e                	jmp    f0100457 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100439:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f0100440:	8d 50 01             	lea    0x1(%eax),%edx
f0100443:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f010044a:	0f b7 c0             	movzwl %ax,%eax
f010044d:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100453:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100457:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f010045e:	cf 07 
f0100460:	76 43                	jbe    f01004a5 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100462:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f0100467:	83 ec 04             	sub    $0x4,%esp
f010046a:	68 00 0f 00 00       	push   $0xf00
f010046f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100475:	52                   	push   %edx
f0100476:	50                   	push   %eax
f0100477:	e8 b2 0f 00 00       	call   f010142e <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010047c:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100482:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100488:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010048e:	83 c4 10             	add    $0x10,%esp
f0100491:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100496:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100499:	39 d0                	cmp    %edx,%eax
f010049b:	75 f4                	jne    f0100491 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010049d:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f01004a4:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004a5:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f01004ab:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004b0:	89 ca                	mov    %ecx,%edx
f01004b2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004b3:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f01004ba:	8d 71 01             	lea    0x1(%ecx),%esi
f01004bd:	89 d8                	mov    %ebx,%eax
f01004bf:	66 c1 e8 08          	shr    $0x8,%ax
f01004c3:	89 f2                	mov    %esi,%edx
f01004c5:	ee                   	out    %al,(%dx)
f01004c6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004cb:	89 ca                	mov    %ecx,%edx
f01004cd:	ee                   	out    %al,(%dx)
f01004ce:	89 d8                	mov    %ebx,%eax
f01004d0:	89 f2                	mov    %esi,%edx
f01004d2:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004d6:	5b                   	pop    %ebx
f01004d7:	5e                   	pop    %esi
f01004d8:	5f                   	pop    %edi
f01004d9:	5d                   	pop    %ebp
f01004da:	c3                   	ret    

f01004db <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004db:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f01004e2:	74 11                	je     f01004f5 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004e4:	55                   	push   %ebp
f01004e5:	89 e5                	mov    %esp,%ebp
f01004e7:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004ea:	b8 77 01 10 f0       	mov    $0xf0100177,%eax
f01004ef:	e8 a2 fc ff ff       	call   f0100196 <cons_intr>
}
f01004f4:	c9                   	leave  
f01004f5:	f3 c3                	repz ret 

f01004f7 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004f7:	55                   	push   %ebp
f01004f8:	89 e5                	mov    %esp,%ebp
f01004fa:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004fd:	b8 d9 01 10 f0       	mov    $0xf01001d9,%eax
f0100502:	e8 8f fc ff ff       	call   f0100196 <cons_intr>
}
f0100507:	c9                   	leave  
f0100508:	c3                   	ret    

f0100509 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100509:	55                   	push   %ebp
f010050a:	89 e5                	mov    %esp,%ebp
f010050c:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010050f:	e8 c7 ff ff ff       	call   f01004db <serial_intr>
	kbd_intr();
f0100514:	e8 de ff ff ff       	call   f01004f7 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100519:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f010051e:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f0100524:	74 26                	je     f010054c <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100526:	8d 50 01             	lea    0x1(%eax),%edx
f0100529:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f010052f:	0f b6 88 20 23 11 f0 	movzbl -0xfeedce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100536:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100538:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010053e:	75 11                	jne    f0100551 <cons_getc+0x48>
			cons.rpos = 0;
f0100540:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f0100547:	00 00 00 
f010054a:	eb 05                	jmp    f0100551 <cons_getc+0x48>
		return c;
	}
	return 0;
f010054c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100551:	c9                   	leave  
f0100552:	c3                   	ret    

f0100553 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100553:	55                   	push   %ebp
f0100554:	89 e5                	mov    %esp,%ebp
f0100556:	57                   	push   %edi
f0100557:	56                   	push   %esi
f0100558:	53                   	push   %ebx
f0100559:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010055c:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100563:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010056a:	5a a5 
	if (*cp != 0xA55A) {
f010056c:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100573:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100577:	74 11                	je     f010058a <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100579:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f0100580:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100583:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100588:	eb 16                	jmp    f01005a0 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010058a:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100591:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f0100598:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010059b:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005a0:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f01005a6:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005ab:	89 fa                	mov    %edi,%edx
f01005ad:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005ae:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b1:	89 da                	mov    %ebx,%edx
f01005b3:	ec                   	in     (%dx),%al
f01005b4:	0f b6 c8             	movzbl %al,%ecx
f01005b7:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005ba:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005bf:	89 fa                	mov    %edi,%edx
f01005c1:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c2:	89 da                	mov    %ebx,%edx
f01005c4:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005c5:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	crt_pos = pos;
f01005cb:	0f b6 c0             	movzbl %al,%eax
f01005ce:	09 c8                	or     %ecx,%eax
f01005d0:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005d6:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005db:	b8 00 00 00 00       	mov    $0x0,%eax
f01005e0:	89 f2                	mov    %esi,%edx
f01005e2:	ee                   	out    %al,(%dx)
f01005e3:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005e8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005ed:	ee                   	out    %al,(%dx)
f01005ee:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005f3:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005f8:	89 da                	mov    %ebx,%edx
f01005fa:	ee                   	out    %al,(%dx)
f01005fb:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100600:	b8 00 00 00 00       	mov    $0x0,%eax
f0100605:	ee                   	out    %al,(%dx)
f0100606:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010060b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100610:	ee                   	out    %al,(%dx)
f0100611:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100616:	b8 00 00 00 00       	mov    $0x0,%eax
f010061b:	ee                   	out    %al,(%dx)
f010061c:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100621:	b8 01 00 00 00       	mov    $0x1,%eax
f0100626:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100627:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010062c:	ec                   	in     (%dx),%al
f010062d:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010062f:	3c ff                	cmp    $0xff,%al
f0100631:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f0100638:	89 f2                	mov    %esi,%edx
f010063a:	ec                   	in     (%dx),%al
f010063b:	89 da                	mov    %ebx,%edx
f010063d:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010063e:	80 f9 ff             	cmp    $0xff,%cl
f0100641:	75 10                	jne    f0100653 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f0100643:	83 ec 0c             	sub    $0xc,%esp
f0100646:	68 10 19 10 f0       	push   $0xf0101910
f010064b:	e8 a8 02 00 00       	call   f01008f8 <cprintf>
f0100650:	83 c4 10             	add    $0x10,%esp
}
f0100653:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100656:	5b                   	pop    %ebx
f0100657:	5e                   	pop    %esi
f0100658:	5f                   	pop    %edi
f0100659:	5d                   	pop    %ebp
f010065a:	c3                   	ret    

f010065b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010065b:	55                   	push   %ebp
f010065c:	89 e5                	mov    %esp,%ebp
f010065e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100661:	8b 45 08             	mov    0x8(%ebp),%eax
f0100664:	e8 89 fc ff ff       	call   f01002f2 <cons_putc>
}
f0100669:	c9                   	leave  
f010066a:	c3                   	ret    

f010066b <getchar>:

int
getchar(void)
{
f010066b:	55                   	push   %ebp
f010066c:	89 e5                	mov    %esp,%ebp
f010066e:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100671:	e8 93 fe ff ff       	call   f0100509 <cons_getc>
f0100676:	85 c0                	test   %eax,%eax
f0100678:	74 f7                	je     f0100671 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010067a:	c9                   	leave  
f010067b:	c3                   	ret    

f010067c <iscons>:

int
iscons(int fdnum)
{
f010067c:	55                   	push   %ebp
f010067d:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010067f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100684:	5d                   	pop    %ebp
f0100685:	c3                   	ret    

f0100686 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100686:	55                   	push   %ebp
f0100687:	89 e5                	mov    %esp,%ebp
f0100689:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010068c:	68 60 1b 10 f0       	push   $0xf0101b60
f0100691:	68 7e 1b 10 f0       	push   $0xf0101b7e
f0100696:	68 83 1b 10 f0       	push   $0xf0101b83
f010069b:	e8 58 02 00 00       	call   f01008f8 <cprintf>
f01006a0:	83 c4 0c             	add    $0xc,%esp
f01006a3:	68 ec 1b 10 f0       	push   $0xf0101bec
f01006a8:	68 8c 1b 10 f0       	push   $0xf0101b8c
f01006ad:	68 83 1b 10 f0       	push   $0xf0101b83
f01006b2:	e8 41 02 00 00       	call   f01008f8 <cprintf>
	return 0;
}
f01006b7:	b8 00 00 00 00       	mov    $0x0,%eax
f01006bc:	c9                   	leave  
f01006bd:	c3                   	ret    

f01006be <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006be:	55                   	push   %ebp
f01006bf:	89 e5                	mov    %esp,%ebp
f01006c1:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006c4:	68 95 1b 10 f0       	push   $0xf0101b95
f01006c9:	e8 2a 02 00 00       	call   f01008f8 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006ce:	83 c4 08             	add    $0x8,%esp
f01006d1:	68 0c 00 10 00       	push   $0x10000c
f01006d6:	68 14 1c 10 f0       	push   $0xf0101c14
f01006db:	e8 18 02 00 00       	call   f01008f8 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006e0:	83 c4 0c             	add    $0xc,%esp
f01006e3:	68 0c 00 10 00       	push   $0x10000c
f01006e8:	68 0c 00 10 f0       	push   $0xf010000c
f01006ed:	68 3c 1c 10 f0       	push   $0xf0101c3c
f01006f2:	e8 01 02 00 00       	call   f01008f8 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006f7:	83 c4 0c             	add    $0xc,%esp
f01006fa:	68 71 18 10 00       	push   $0x101871
f01006ff:	68 71 18 10 f0       	push   $0xf0101871
f0100704:	68 60 1c 10 f0       	push   $0xf0101c60
f0100709:	e8 ea 01 00 00       	call   f01008f8 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010070e:	83 c4 0c             	add    $0xc,%esp
f0100711:	68 00 23 11 00       	push   $0x112300
f0100716:	68 00 23 11 f0       	push   $0xf0112300
f010071b:	68 84 1c 10 f0       	push   $0xf0101c84
f0100720:	e8 d3 01 00 00       	call   f01008f8 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100725:	83 c4 0c             	add    $0xc,%esp
f0100728:	68 40 29 11 00       	push   $0x112940
f010072d:	68 40 29 11 f0       	push   $0xf0112940
f0100732:	68 a8 1c 10 f0       	push   $0xf0101ca8
f0100737:	e8 bc 01 00 00       	call   f01008f8 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010073c:	b8 3f 2d 11 f0       	mov    $0xf0112d3f,%eax
f0100741:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100746:	83 c4 08             	add    $0x8,%esp
f0100749:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010074e:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100754:	85 c0                	test   %eax,%eax
f0100756:	0f 48 c2             	cmovs  %edx,%eax
f0100759:	c1 f8 0a             	sar    $0xa,%eax
f010075c:	50                   	push   %eax
f010075d:	68 cc 1c 10 f0       	push   $0xf0101ccc
f0100762:	e8 91 01 00 00       	call   f01008f8 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100767:	b8 00 00 00 00       	mov    $0x0,%eax
f010076c:	c9                   	leave  
f010076d:	c3                   	ret    

f010076e <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010076e:	55                   	push   %ebp
f010076f:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f0100771:	b8 00 00 00 00       	mov    $0x0,%eax
f0100776:	5d                   	pop    %ebp
f0100777:	c3                   	ret    

f0100778 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100778:	55                   	push   %ebp
f0100779:	89 e5                	mov    %esp,%ebp
f010077b:	57                   	push   %edi
f010077c:	56                   	push   %esi
f010077d:	53                   	push   %ebx
f010077e:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100781:	68 f8 1c 10 f0       	push   $0xf0101cf8
f0100786:	e8 6d 01 00 00       	call   f01008f8 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010078b:	c7 04 24 1c 1d 10 f0 	movl   $0xf0101d1c,(%esp)
f0100792:	e8 61 01 00 00       	call   f01008f8 <cprintf>
f0100797:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f010079a:	83 ec 0c             	sub    $0xc,%esp
f010079d:	68 ae 1b 10 f0       	push   $0xf0101bae
f01007a2:	e8 e3 09 00 00       	call   f010118a <readline>
f01007a7:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007a9:	83 c4 10             	add    $0x10,%esp
f01007ac:	85 c0                	test   %eax,%eax
f01007ae:	74 ea                	je     f010079a <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007b0:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01007b7:	be 00 00 00 00       	mov    $0x0,%esi
f01007bc:	eb 0a                	jmp    f01007c8 <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01007be:	c6 03 00             	movb   $0x0,(%ebx)
f01007c1:	89 f7                	mov    %esi,%edi
f01007c3:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01007c6:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01007c8:	0f b6 03             	movzbl (%ebx),%eax
f01007cb:	84 c0                	test   %al,%al
f01007cd:	74 63                	je     f0100832 <monitor+0xba>
f01007cf:	83 ec 08             	sub    $0x8,%esp
f01007d2:	0f be c0             	movsbl %al,%eax
f01007d5:	50                   	push   %eax
f01007d6:	68 b2 1b 10 f0       	push   $0xf0101bb2
f01007db:	e8 c4 0b 00 00       	call   f01013a4 <strchr>
f01007e0:	83 c4 10             	add    $0x10,%esp
f01007e3:	85 c0                	test   %eax,%eax
f01007e5:	75 d7                	jne    f01007be <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f01007e7:	80 3b 00             	cmpb   $0x0,(%ebx)
f01007ea:	74 46                	je     f0100832 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01007ec:	83 fe 0f             	cmp    $0xf,%esi
f01007ef:	75 14                	jne    f0100805 <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01007f1:	83 ec 08             	sub    $0x8,%esp
f01007f4:	6a 10                	push   $0x10
f01007f6:	68 b7 1b 10 f0       	push   $0xf0101bb7
f01007fb:	e8 f8 00 00 00       	call   f01008f8 <cprintf>
f0100800:	83 c4 10             	add    $0x10,%esp
f0100803:	eb 95                	jmp    f010079a <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f0100805:	8d 7e 01             	lea    0x1(%esi),%edi
f0100808:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010080c:	eb 03                	jmp    f0100811 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f010080e:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100811:	0f b6 03             	movzbl (%ebx),%eax
f0100814:	84 c0                	test   %al,%al
f0100816:	74 ae                	je     f01007c6 <monitor+0x4e>
f0100818:	83 ec 08             	sub    $0x8,%esp
f010081b:	0f be c0             	movsbl %al,%eax
f010081e:	50                   	push   %eax
f010081f:	68 b2 1b 10 f0       	push   $0xf0101bb2
f0100824:	e8 7b 0b 00 00       	call   f01013a4 <strchr>
f0100829:	83 c4 10             	add    $0x10,%esp
f010082c:	85 c0                	test   %eax,%eax
f010082e:	74 de                	je     f010080e <monitor+0x96>
f0100830:	eb 94                	jmp    f01007c6 <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f0100832:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100839:	00 

	// Lookup and invoke the command
	if (argc == 0)
f010083a:	85 f6                	test   %esi,%esi
f010083c:	0f 84 58 ff ff ff    	je     f010079a <monitor+0x22>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100842:	83 ec 08             	sub    $0x8,%esp
f0100845:	68 7e 1b 10 f0       	push   $0xf0101b7e
f010084a:	ff 75 a8             	pushl  -0x58(%ebp)
f010084d:	e8 f4 0a 00 00       	call   f0101346 <strcmp>
f0100852:	83 c4 10             	add    $0x10,%esp
f0100855:	85 c0                	test   %eax,%eax
f0100857:	74 1e                	je     f0100877 <monitor+0xff>
f0100859:	83 ec 08             	sub    $0x8,%esp
f010085c:	68 8c 1b 10 f0       	push   $0xf0101b8c
f0100861:	ff 75 a8             	pushl  -0x58(%ebp)
f0100864:	e8 dd 0a 00 00       	call   f0101346 <strcmp>
f0100869:	83 c4 10             	add    $0x10,%esp
f010086c:	85 c0                	test   %eax,%eax
f010086e:	75 2f                	jne    f010089f <monitor+0x127>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100870:	b8 01 00 00 00       	mov    $0x1,%eax
f0100875:	eb 05                	jmp    f010087c <monitor+0x104>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100877:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f010087c:	83 ec 04             	sub    $0x4,%esp
f010087f:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100882:	01 d0                	add    %edx,%eax
f0100884:	ff 75 08             	pushl  0x8(%ebp)
f0100887:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f010088a:	51                   	push   %ecx
f010088b:	56                   	push   %esi
f010088c:	ff 14 85 4c 1d 10 f0 	call   *-0xfefe2b4(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100893:	83 c4 10             	add    $0x10,%esp
f0100896:	85 c0                	test   %eax,%eax
f0100898:	78 1d                	js     f01008b7 <monitor+0x13f>
f010089a:	e9 fb fe ff ff       	jmp    f010079a <monitor+0x22>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010089f:	83 ec 08             	sub    $0x8,%esp
f01008a2:	ff 75 a8             	pushl  -0x58(%ebp)
f01008a5:	68 d4 1b 10 f0       	push   $0xf0101bd4
f01008aa:	e8 49 00 00 00       	call   f01008f8 <cprintf>
f01008af:	83 c4 10             	add    $0x10,%esp
f01008b2:	e9 e3 fe ff ff       	jmp    f010079a <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008ba:	5b                   	pop    %ebx
f01008bb:	5e                   	pop    %esi
f01008bc:	5f                   	pop    %edi
f01008bd:	5d                   	pop    %ebp
f01008be:	c3                   	ret    

f01008bf <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01008bf:	55                   	push   %ebp
f01008c0:	89 e5                	mov    %esp,%ebp
f01008c2:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01008c5:	ff 75 08             	pushl  0x8(%ebp)
f01008c8:	e8 8e fd ff ff       	call   f010065b <cputchar>
	*cnt++;
}
f01008cd:	83 c4 10             	add    $0x10,%esp
f01008d0:	c9                   	leave  
f01008d1:	c3                   	ret    

f01008d2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01008d2:	55                   	push   %ebp
f01008d3:	89 e5                	mov    %esp,%ebp
f01008d5:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01008d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01008df:	ff 75 0c             	pushl  0xc(%ebp)
f01008e2:	ff 75 08             	pushl  0x8(%ebp)
f01008e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01008e8:	50                   	push   %eax
f01008e9:	68 bf 08 10 f0       	push   $0xf01008bf
f01008ee:	e8 c9 03 00 00       	call   f0100cbc <vprintfmt>
	return cnt;
}
f01008f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01008f6:	c9                   	leave  
f01008f7:	c3                   	ret    

f01008f8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01008f8:	55                   	push   %ebp
f01008f9:	89 e5                	mov    %esp,%ebp
f01008fb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01008fe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100901:	50                   	push   %eax
f0100902:	ff 75 08             	pushl  0x8(%ebp)
f0100905:	e8 c8 ff ff ff       	call   f01008d2 <vcprintf>
	va_end(ap);

	return cnt;
}
f010090a:	c9                   	leave  
f010090b:	c3                   	ret    

f010090c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010090c:	55                   	push   %ebp
f010090d:	89 e5                	mov    %esp,%ebp
f010090f:	57                   	push   %edi
f0100910:	56                   	push   %esi
f0100911:	53                   	push   %ebx
f0100912:	83 ec 14             	sub    $0x14,%esp
f0100915:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100918:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010091b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010091e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100921:	8b 1a                	mov    (%edx),%ebx
f0100923:	8b 01                	mov    (%ecx),%eax
f0100925:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100928:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010092f:	eb 7f                	jmp    f01009b0 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0100931:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100934:	01 d8                	add    %ebx,%eax
f0100936:	89 c6                	mov    %eax,%esi
f0100938:	c1 ee 1f             	shr    $0x1f,%esi
f010093b:	01 c6                	add    %eax,%esi
f010093d:	d1 fe                	sar    %esi
f010093f:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100942:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100945:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0100948:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010094a:	eb 03                	jmp    f010094f <stab_binsearch+0x43>
			m--;
f010094c:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010094f:	39 c3                	cmp    %eax,%ebx
f0100951:	7f 0d                	jg     f0100960 <stab_binsearch+0x54>
f0100953:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100957:	83 ea 0c             	sub    $0xc,%edx
f010095a:	39 f9                	cmp    %edi,%ecx
f010095c:	75 ee                	jne    f010094c <stab_binsearch+0x40>
f010095e:	eb 05                	jmp    f0100965 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100960:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0100963:	eb 4b                	jmp    f01009b0 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100965:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100968:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010096b:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010096f:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100972:	76 11                	jbe    f0100985 <stab_binsearch+0x79>
			*region_left = m;
f0100974:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100977:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100979:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010097c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100983:	eb 2b                	jmp    f01009b0 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100985:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100988:	73 14                	jae    f010099e <stab_binsearch+0x92>
			*region_right = m - 1;
f010098a:	83 e8 01             	sub    $0x1,%eax
f010098d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100990:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100993:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100995:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010099c:	eb 12                	jmp    f01009b0 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010099e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01009a1:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01009a3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01009a7:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01009a9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01009b0:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01009b3:	0f 8e 78 ff ff ff    	jle    f0100931 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01009b9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01009bd:	75 0f                	jne    f01009ce <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f01009bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009c2:	8b 00                	mov    (%eax),%eax
f01009c4:	83 e8 01             	sub    $0x1,%eax
f01009c7:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01009ca:	89 06                	mov    %eax,(%esi)
f01009cc:	eb 2c                	jmp    f01009fa <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01009ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01009d1:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01009d3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01009d6:	8b 0e                	mov    (%esi),%ecx
f01009d8:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01009db:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01009de:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01009e1:	eb 03                	jmp    f01009e6 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01009e3:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01009e6:	39 c8                	cmp    %ecx,%eax
f01009e8:	7e 0b                	jle    f01009f5 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01009ea:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01009ee:	83 ea 0c             	sub    $0xc,%edx
f01009f1:	39 df                	cmp    %ebx,%edi
f01009f3:	75 ee                	jne    f01009e3 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01009f5:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01009f8:	89 06                	mov    %eax,(%esi)
	}
}
f01009fa:	83 c4 14             	add    $0x14,%esp
f01009fd:	5b                   	pop    %ebx
f01009fe:	5e                   	pop    %esi
f01009ff:	5f                   	pop    %edi
f0100a00:	5d                   	pop    %ebp
f0100a01:	c3                   	ret    

f0100a02 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100a02:	55                   	push   %ebp
f0100a03:	89 e5                	mov    %esp,%ebp
f0100a05:	57                   	push   %edi
f0100a06:	56                   	push   %esi
f0100a07:	53                   	push   %ebx
f0100a08:	83 ec 1c             	sub    $0x1c,%esp
f0100a0b:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100a0e:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100a11:	c7 06 5c 1d 10 f0    	movl   $0xf0101d5c,(%esi)
	info->eip_line = 0;
f0100a17:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100a1e:	c7 46 08 5c 1d 10 f0 	movl   $0xf0101d5c,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100a25:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100a2c:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100a2f:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100a36:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100a3c:	76 11                	jbe    f0100a4f <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100a3e:	b8 1f 71 10 f0       	mov    $0xf010711f,%eax
f0100a43:	3d 65 58 10 f0       	cmp    $0xf0105865,%eax
f0100a48:	77 19                	ja     f0100a63 <debuginfo_eip+0x61>
f0100a4a:	e9 62 01 00 00       	jmp    f0100bb1 <debuginfo_eip+0x1af>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100a4f:	83 ec 04             	sub    $0x4,%esp
f0100a52:	68 66 1d 10 f0       	push   $0xf0101d66
f0100a57:	6a 7f                	push   $0x7f
f0100a59:	68 73 1d 10 f0       	push   $0xf0101d73
f0100a5e:	e8 83 f6 ff ff       	call   f01000e6 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100a63:	80 3d 1e 71 10 f0 00 	cmpb   $0x0,0xf010711e
f0100a6a:	0f 85 48 01 00 00    	jne    f0100bb8 <debuginfo_eip+0x1b6>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100a70:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100a77:	b8 64 58 10 f0       	mov    $0xf0105864,%eax
f0100a7c:	2d 94 1f 10 f0       	sub    $0xf0101f94,%eax
f0100a81:	c1 f8 02             	sar    $0x2,%eax
f0100a84:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100a8a:	83 e8 01             	sub    $0x1,%eax
f0100a8d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100a90:	83 ec 08             	sub    $0x8,%esp
f0100a93:	57                   	push   %edi
f0100a94:	6a 64                	push   $0x64
f0100a96:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100a99:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100a9c:	b8 94 1f 10 f0       	mov    $0xf0101f94,%eax
f0100aa1:	e8 66 fe ff ff       	call   f010090c <stab_binsearch>
	if (lfile == 0)
f0100aa6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100aa9:	83 c4 10             	add    $0x10,%esp
f0100aac:	85 c0                	test   %eax,%eax
f0100aae:	0f 84 0b 01 00 00    	je     f0100bbf <debuginfo_eip+0x1bd>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100ab4:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100ab7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100aba:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100abd:	83 ec 08             	sub    $0x8,%esp
f0100ac0:	57                   	push   %edi
f0100ac1:	6a 24                	push   $0x24
f0100ac3:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100ac6:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ac9:	b8 94 1f 10 f0       	mov    $0xf0101f94,%eax
f0100ace:	e8 39 fe ff ff       	call   f010090c <stab_binsearch>

	if (lfun <= rfun) {
f0100ad3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100ad6:	83 c4 10             	add    $0x10,%esp
f0100ad9:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0100adc:	7f 31                	jg     f0100b0f <debuginfo_eip+0x10d>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100ade:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100ae1:	c1 e0 02             	shl    $0x2,%eax
f0100ae4:	8d 90 94 1f 10 f0    	lea    -0xfefe06c(%eax),%edx
f0100aea:	8b 88 94 1f 10 f0    	mov    -0xfefe06c(%eax),%ecx
f0100af0:	b8 1f 71 10 f0       	mov    $0xf010711f,%eax
f0100af5:	2d 65 58 10 f0       	sub    $0xf0105865,%eax
f0100afa:	39 c1                	cmp    %eax,%ecx
f0100afc:	73 09                	jae    f0100b07 <debuginfo_eip+0x105>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100afe:	81 c1 65 58 10 f0    	add    $0xf0105865,%ecx
f0100b04:	89 4e 08             	mov    %ecx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100b07:	8b 42 08             	mov    0x8(%edx),%eax
f0100b0a:	89 46 10             	mov    %eax,0x10(%esi)
f0100b0d:	eb 06                	jmp    f0100b15 <debuginfo_eip+0x113>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100b0f:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100b12:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100b15:	83 ec 08             	sub    $0x8,%esp
f0100b18:	6a 3a                	push   $0x3a
f0100b1a:	ff 76 08             	pushl  0x8(%esi)
f0100b1d:	e8 a3 08 00 00       	call   f01013c5 <strfind>
f0100b22:	2b 46 08             	sub    0x8(%esi),%eax
f0100b25:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100b28:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100b2b:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b2e:	8d 04 85 94 1f 10 f0 	lea    -0xfefe06c(,%eax,4),%eax
f0100b35:	83 c4 10             	add    $0x10,%esp
f0100b38:	eb 06                	jmp    f0100b40 <debuginfo_eip+0x13e>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100b3a:	83 eb 01             	sub    $0x1,%ebx
f0100b3d:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100b40:	39 fb                	cmp    %edi,%ebx
f0100b42:	7c 34                	jl     f0100b78 <debuginfo_eip+0x176>
	       && stabs[lline].n_type != N_SOL
f0100b44:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0100b48:	80 fa 84             	cmp    $0x84,%dl
f0100b4b:	74 0b                	je     f0100b58 <debuginfo_eip+0x156>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100b4d:	80 fa 64             	cmp    $0x64,%dl
f0100b50:	75 e8                	jne    f0100b3a <debuginfo_eip+0x138>
f0100b52:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100b56:	74 e2                	je     f0100b3a <debuginfo_eip+0x138>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100b58:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b5b:	8b 14 85 94 1f 10 f0 	mov    -0xfefe06c(,%eax,4),%edx
f0100b62:	b8 1f 71 10 f0       	mov    $0xf010711f,%eax
f0100b67:	2d 65 58 10 f0       	sub    $0xf0105865,%eax
f0100b6c:	39 c2                	cmp    %eax,%edx
f0100b6e:	73 08                	jae    f0100b78 <debuginfo_eip+0x176>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100b70:	81 c2 65 58 10 f0    	add    $0xf0105865,%edx
f0100b76:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100b78:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100b7b:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100b7e:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100b83:	39 cb                	cmp    %ecx,%ebx
f0100b85:	7d 44                	jge    f0100bcb <debuginfo_eip+0x1c9>
		for (lline = lfun + 1;
f0100b87:	8d 53 01             	lea    0x1(%ebx),%edx
f0100b8a:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100b8d:	8d 04 85 94 1f 10 f0 	lea    -0xfefe06c(,%eax,4),%eax
f0100b94:	eb 07                	jmp    f0100b9d <debuginfo_eip+0x19b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100b96:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0100b9a:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100b9d:	39 ca                	cmp    %ecx,%edx
f0100b9f:	74 25                	je     f0100bc6 <debuginfo_eip+0x1c4>
f0100ba1:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100ba4:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0100ba8:	74 ec                	je     f0100b96 <debuginfo_eip+0x194>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100baa:	b8 00 00 00 00       	mov    $0x0,%eax
f0100baf:	eb 1a                	jmp    f0100bcb <debuginfo_eip+0x1c9>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100bb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100bb6:	eb 13                	jmp    f0100bcb <debuginfo_eip+0x1c9>
f0100bb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100bbd:	eb 0c                	jmp    f0100bcb <debuginfo_eip+0x1c9>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100bbf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100bc4:	eb 05                	jmp    f0100bcb <debuginfo_eip+0x1c9>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100bc6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100bcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100bce:	5b                   	pop    %ebx
f0100bcf:	5e                   	pop    %esi
f0100bd0:	5f                   	pop    %edi
f0100bd1:	5d                   	pop    %ebp
f0100bd2:	c3                   	ret    

f0100bd3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100bd3:	55                   	push   %ebp
f0100bd4:	89 e5                	mov    %esp,%ebp
f0100bd6:	57                   	push   %edi
f0100bd7:	56                   	push   %esi
f0100bd8:	53                   	push   %ebx
f0100bd9:	83 ec 1c             	sub    $0x1c,%esp
f0100bdc:	89 c7                	mov    %eax,%edi
f0100bde:	89 d6                	mov    %edx,%esi
f0100be0:	8b 45 08             	mov    0x8(%ebp),%eax
f0100be3:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100be6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100be9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100bec:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100bef:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100bf4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100bf7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100bfa:	39 d3                	cmp    %edx,%ebx
f0100bfc:	72 05                	jb     f0100c03 <printnum+0x30>
f0100bfe:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100c01:	77 45                	ja     f0100c48 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100c03:	83 ec 0c             	sub    $0xc,%esp
f0100c06:	ff 75 18             	pushl  0x18(%ebp)
f0100c09:	8b 45 14             	mov    0x14(%ebp),%eax
f0100c0c:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100c0f:	53                   	push   %ebx
f0100c10:	ff 75 10             	pushl  0x10(%ebp)
f0100c13:	83 ec 08             	sub    $0x8,%esp
f0100c16:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100c19:	ff 75 e0             	pushl  -0x20(%ebp)
f0100c1c:	ff 75 dc             	pushl  -0x24(%ebp)
f0100c1f:	ff 75 d8             	pushl  -0x28(%ebp)
f0100c22:	e8 c9 09 00 00       	call   f01015f0 <__udivdi3>
f0100c27:	83 c4 18             	add    $0x18,%esp
f0100c2a:	52                   	push   %edx
f0100c2b:	50                   	push   %eax
f0100c2c:	89 f2                	mov    %esi,%edx
f0100c2e:	89 f8                	mov    %edi,%eax
f0100c30:	e8 9e ff ff ff       	call   f0100bd3 <printnum>
f0100c35:	83 c4 20             	add    $0x20,%esp
f0100c38:	eb 18                	jmp    f0100c52 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100c3a:	83 ec 08             	sub    $0x8,%esp
f0100c3d:	56                   	push   %esi
f0100c3e:	ff 75 18             	pushl  0x18(%ebp)
f0100c41:	ff d7                	call   *%edi
f0100c43:	83 c4 10             	add    $0x10,%esp
f0100c46:	eb 03                	jmp    f0100c4b <printnum+0x78>
f0100c48:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100c4b:	83 eb 01             	sub    $0x1,%ebx
f0100c4e:	85 db                	test   %ebx,%ebx
f0100c50:	7f e8                	jg     f0100c3a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100c52:	83 ec 08             	sub    $0x8,%esp
f0100c55:	56                   	push   %esi
f0100c56:	83 ec 04             	sub    $0x4,%esp
f0100c59:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100c5c:	ff 75 e0             	pushl  -0x20(%ebp)
f0100c5f:	ff 75 dc             	pushl  -0x24(%ebp)
f0100c62:	ff 75 d8             	pushl  -0x28(%ebp)
f0100c65:	e8 b6 0a 00 00       	call   f0101720 <__umoddi3>
f0100c6a:	83 c4 14             	add    $0x14,%esp
f0100c6d:	0f be 80 81 1d 10 f0 	movsbl -0xfefe27f(%eax),%eax
f0100c74:	50                   	push   %eax
f0100c75:	ff d7                	call   *%edi
}
f0100c77:	83 c4 10             	add    $0x10,%esp
f0100c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c7d:	5b                   	pop    %ebx
f0100c7e:	5e                   	pop    %esi
f0100c7f:	5f                   	pop    %edi
f0100c80:	5d                   	pop    %ebp
f0100c81:	c3                   	ret    

f0100c82 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100c82:	55                   	push   %ebp
f0100c83:	89 e5                	mov    %esp,%ebp
f0100c85:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100c88:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100c8c:	8b 10                	mov    (%eax),%edx
f0100c8e:	3b 50 04             	cmp    0x4(%eax),%edx
f0100c91:	73 0a                	jae    f0100c9d <sprintputch+0x1b>
		*b->buf++ = ch;
f0100c93:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100c96:	89 08                	mov    %ecx,(%eax)
f0100c98:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c9b:	88 02                	mov    %al,(%edx)
}
f0100c9d:	5d                   	pop    %ebp
f0100c9e:	c3                   	ret    

f0100c9f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100c9f:	55                   	push   %ebp
f0100ca0:	89 e5                	mov    %esp,%ebp
f0100ca2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100ca5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100ca8:	50                   	push   %eax
f0100ca9:	ff 75 10             	pushl  0x10(%ebp)
f0100cac:	ff 75 0c             	pushl  0xc(%ebp)
f0100caf:	ff 75 08             	pushl  0x8(%ebp)
f0100cb2:	e8 05 00 00 00       	call   f0100cbc <vprintfmt>
	va_end(ap);
}
f0100cb7:	83 c4 10             	add    $0x10,%esp
f0100cba:	c9                   	leave  
f0100cbb:	c3                   	ret    

f0100cbc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100cbc:	55                   	push   %ebp
f0100cbd:	89 e5                	mov    %esp,%ebp
f0100cbf:	57                   	push   %edi
f0100cc0:	56                   	push   %esi
f0100cc1:	53                   	push   %ebx
f0100cc2:	83 ec 2c             	sub    $0x2c,%esp
f0100cc5:	8b 75 08             	mov    0x8(%ebp),%esi
f0100cc8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100ccb:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100cce:	eb 12                	jmp    f0100ce2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100cd0:	85 c0                	test   %eax,%eax
f0100cd2:	0f 84 42 04 00 00    	je     f010111a <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
f0100cd8:	83 ec 08             	sub    $0x8,%esp
f0100cdb:	53                   	push   %ebx
f0100cdc:	50                   	push   %eax
f0100cdd:	ff d6                	call   *%esi
f0100cdf:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100ce2:	83 c7 01             	add    $0x1,%edi
f0100ce5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100ce9:	83 f8 25             	cmp    $0x25,%eax
f0100cec:	75 e2                	jne    f0100cd0 <vprintfmt+0x14>
f0100cee:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100cf2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100cf9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100d00:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100d07:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100d0c:	eb 07                	jmp    f0100d15 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d0e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100d11:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d15:	8d 47 01             	lea    0x1(%edi),%eax
f0100d18:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100d1b:	0f b6 07             	movzbl (%edi),%eax
f0100d1e:	0f b6 d0             	movzbl %al,%edx
f0100d21:	83 e8 23             	sub    $0x23,%eax
f0100d24:	3c 55                	cmp    $0x55,%al
f0100d26:	0f 87 d3 03 00 00    	ja     f01010ff <vprintfmt+0x443>
f0100d2c:	0f b6 c0             	movzbl %al,%eax
f0100d2f:	ff 24 85 10 1e 10 f0 	jmp    *-0xfefe1f0(,%eax,4)
f0100d36:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100d39:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100d3d:	eb d6                	jmp    f0100d15 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d3f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d42:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d47:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100d4a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100d4d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0100d51:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0100d54:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100d57:	83 f9 09             	cmp    $0x9,%ecx
f0100d5a:	77 3f                	ja     f0100d9b <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100d5c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100d5f:	eb e9                	jmp    f0100d4a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100d61:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d64:	8b 00                	mov    (%eax),%eax
f0100d66:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100d69:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d6c:	8d 40 04             	lea    0x4(%eax),%eax
f0100d6f:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d72:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100d75:	eb 2a                	jmp    f0100da1 <vprintfmt+0xe5>
f0100d77:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d7a:	85 c0                	test   %eax,%eax
f0100d7c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d81:	0f 49 d0             	cmovns %eax,%edx
f0100d84:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100d87:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d8a:	eb 89                	jmp    f0100d15 <vprintfmt+0x59>
f0100d8c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100d8f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100d96:	e9 7a ff ff ff       	jmp    f0100d15 <vprintfmt+0x59>
f0100d9b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100d9e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0100da1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100da5:	0f 89 6a ff ff ff    	jns    f0100d15 <vprintfmt+0x59>
				width = precision, precision = -1;
f0100dab:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100dae:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100db1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100db8:	e9 58 ff ff ff       	jmp    f0100d15 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100dbd:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100dc0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100dc3:	e9 4d ff ff ff       	jmp    f0100d15 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100dc8:	8b 45 14             	mov    0x14(%ebp),%eax
f0100dcb:	8d 78 04             	lea    0x4(%eax),%edi
f0100dce:	83 ec 08             	sub    $0x8,%esp
f0100dd1:	53                   	push   %ebx
f0100dd2:	ff 30                	pushl  (%eax)
f0100dd4:	ff d6                	call   *%esi
			break;
f0100dd6:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100dd9:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ddc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100ddf:	e9 fe fe ff ff       	jmp    f0100ce2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100de4:	8b 45 14             	mov    0x14(%ebp),%eax
f0100de7:	8d 78 04             	lea    0x4(%eax),%edi
f0100dea:	8b 00                	mov    (%eax),%eax
f0100dec:	99                   	cltd   
f0100ded:	31 d0                	xor    %edx,%eax
f0100def:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100df1:	83 f8 06             	cmp    $0x6,%eax
f0100df4:	7f 0b                	jg     f0100e01 <vprintfmt+0x145>
f0100df6:	8b 14 85 68 1f 10 f0 	mov    -0xfefe098(,%eax,4),%edx
f0100dfd:	85 d2                	test   %edx,%edx
f0100dff:	75 1b                	jne    f0100e1c <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
f0100e01:	50                   	push   %eax
f0100e02:	68 99 1d 10 f0       	push   $0xf0101d99
f0100e07:	53                   	push   %ebx
f0100e08:	56                   	push   %esi
f0100e09:	e8 91 fe ff ff       	call   f0100c9f <printfmt>
f0100e0e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100e11:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e14:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100e17:	e9 c6 fe ff ff       	jmp    f0100ce2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0100e1c:	52                   	push   %edx
f0100e1d:	68 a2 1d 10 f0       	push   $0xf0101da2
f0100e22:	53                   	push   %ebx
f0100e23:	56                   	push   %esi
f0100e24:	e8 76 fe ff ff       	call   f0100c9f <printfmt>
f0100e29:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100e2c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e2f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e32:	e9 ab fe ff ff       	jmp    f0100ce2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100e37:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e3a:	83 c0 04             	add    $0x4,%eax
f0100e3d:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100e40:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e43:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0100e45:	85 ff                	test   %edi,%edi
f0100e47:	b8 92 1d 10 f0       	mov    $0xf0101d92,%eax
f0100e4c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0100e4f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100e53:	0f 8e 94 00 00 00    	jle    f0100eed <vprintfmt+0x231>
f0100e59:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100e5d:	0f 84 98 00 00 00    	je     f0100efb <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100e63:	83 ec 08             	sub    $0x8,%esp
f0100e66:	ff 75 d0             	pushl  -0x30(%ebp)
f0100e69:	57                   	push   %edi
f0100e6a:	e8 0c 04 00 00       	call   f010127b <strnlen>
f0100e6f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100e72:	29 c1                	sub    %eax,%ecx
f0100e74:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0100e77:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100e7a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100e7e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100e81:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100e84:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100e86:	eb 0f                	jmp    f0100e97 <vprintfmt+0x1db>
					putch(padc, putdat);
f0100e88:	83 ec 08             	sub    $0x8,%esp
f0100e8b:	53                   	push   %ebx
f0100e8c:	ff 75 e0             	pushl  -0x20(%ebp)
f0100e8f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100e91:	83 ef 01             	sub    $0x1,%edi
f0100e94:	83 c4 10             	add    $0x10,%esp
f0100e97:	85 ff                	test   %edi,%edi
f0100e99:	7f ed                	jg     f0100e88 <vprintfmt+0x1cc>
f0100e9b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100e9e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100ea1:	85 c9                	test   %ecx,%ecx
f0100ea3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ea8:	0f 49 c1             	cmovns %ecx,%eax
f0100eab:	29 c1                	sub    %eax,%ecx
f0100ead:	89 75 08             	mov    %esi,0x8(%ebp)
f0100eb0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100eb3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100eb6:	89 cb                	mov    %ecx,%ebx
f0100eb8:	eb 4d                	jmp    f0100f07 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100eba:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100ebe:	74 1b                	je     f0100edb <vprintfmt+0x21f>
f0100ec0:	0f be c0             	movsbl %al,%eax
f0100ec3:	83 e8 20             	sub    $0x20,%eax
f0100ec6:	83 f8 5e             	cmp    $0x5e,%eax
f0100ec9:	76 10                	jbe    f0100edb <vprintfmt+0x21f>
					putch('?', putdat);
f0100ecb:	83 ec 08             	sub    $0x8,%esp
f0100ece:	ff 75 0c             	pushl  0xc(%ebp)
f0100ed1:	6a 3f                	push   $0x3f
f0100ed3:	ff 55 08             	call   *0x8(%ebp)
f0100ed6:	83 c4 10             	add    $0x10,%esp
f0100ed9:	eb 0d                	jmp    f0100ee8 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
f0100edb:	83 ec 08             	sub    $0x8,%esp
f0100ede:	ff 75 0c             	pushl  0xc(%ebp)
f0100ee1:	52                   	push   %edx
f0100ee2:	ff 55 08             	call   *0x8(%ebp)
f0100ee5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100ee8:	83 eb 01             	sub    $0x1,%ebx
f0100eeb:	eb 1a                	jmp    f0100f07 <vprintfmt+0x24b>
f0100eed:	89 75 08             	mov    %esi,0x8(%ebp)
f0100ef0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100ef3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100ef6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100ef9:	eb 0c                	jmp    f0100f07 <vprintfmt+0x24b>
f0100efb:	89 75 08             	mov    %esi,0x8(%ebp)
f0100efe:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100f01:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100f04:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100f07:	83 c7 01             	add    $0x1,%edi
f0100f0a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100f0e:	0f be d0             	movsbl %al,%edx
f0100f11:	85 d2                	test   %edx,%edx
f0100f13:	74 23                	je     f0100f38 <vprintfmt+0x27c>
f0100f15:	85 f6                	test   %esi,%esi
f0100f17:	78 a1                	js     f0100eba <vprintfmt+0x1fe>
f0100f19:	83 ee 01             	sub    $0x1,%esi
f0100f1c:	79 9c                	jns    f0100eba <vprintfmt+0x1fe>
f0100f1e:	89 df                	mov    %ebx,%edi
f0100f20:	8b 75 08             	mov    0x8(%ebp),%esi
f0100f23:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100f26:	eb 18                	jmp    f0100f40 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0100f28:	83 ec 08             	sub    $0x8,%esp
f0100f2b:	53                   	push   %ebx
f0100f2c:	6a 20                	push   $0x20
f0100f2e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0100f30:	83 ef 01             	sub    $0x1,%edi
f0100f33:	83 c4 10             	add    $0x10,%esp
f0100f36:	eb 08                	jmp    f0100f40 <vprintfmt+0x284>
f0100f38:	89 df                	mov    %ebx,%edi
f0100f3a:	8b 75 08             	mov    0x8(%ebp),%esi
f0100f3d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100f40:	85 ff                	test   %edi,%edi
f0100f42:	7f e4                	jg     f0100f28 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100f44:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0100f47:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f4a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f4d:	e9 90 fd ff ff       	jmp    f0100ce2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0100f52:	83 f9 01             	cmp    $0x1,%ecx
f0100f55:	7e 19                	jle    f0100f70 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
f0100f57:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f5a:	8b 50 04             	mov    0x4(%eax),%edx
f0100f5d:	8b 00                	mov    (%eax),%eax
f0100f5f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f62:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100f65:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f68:	8d 40 08             	lea    0x8(%eax),%eax
f0100f6b:	89 45 14             	mov    %eax,0x14(%ebp)
f0100f6e:	eb 38                	jmp    f0100fa8 <vprintfmt+0x2ec>
	else if (lflag)
f0100f70:	85 c9                	test   %ecx,%ecx
f0100f72:	74 1b                	je     f0100f8f <vprintfmt+0x2d3>
		return va_arg(*ap, long);
f0100f74:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f77:	8b 00                	mov    (%eax),%eax
f0100f79:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f7c:	89 c1                	mov    %eax,%ecx
f0100f7e:	c1 f9 1f             	sar    $0x1f,%ecx
f0100f81:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100f84:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f87:	8d 40 04             	lea    0x4(%eax),%eax
f0100f8a:	89 45 14             	mov    %eax,0x14(%ebp)
f0100f8d:	eb 19                	jmp    f0100fa8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f0100f8f:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f92:	8b 00                	mov    (%eax),%eax
f0100f94:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f97:	89 c1                	mov    %eax,%ecx
f0100f99:	c1 f9 1f             	sar    $0x1f,%ecx
f0100f9c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100f9f:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fa2:	8d 40 04             	lea    0x4(%eax),%eax
f0100fa5:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0100fa8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100fab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0100fae:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0100fb3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100fb7:	0f 89 0e 01 00 00    	jns    f01010cb <vprintfmt+0x40f>
				putch('-', putdat);
f0100fbd:	83 ec 08             	sub    $0x8,%esp
f0100fc0:	53                   	push   %ebx
f0100fc1:	6a 2d                	push   $0x2d
f0100fc3:	ff d6                	call   *%esi
				num = -(long long) num;
f0100fc5:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100fc8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100fcb:	f7 da                	neg    %edx
f0100fcd:	83 d1 00             	adc    $0x0,%ecx
f0100fd0:	f7 d9                	neg    %ecx
f0100fd2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0100fd5:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100fda:	e9 ec 00 00 00       	jmp    f01010cb <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0100fdf:	83 f9 01             	cmp    $0x1,%ecx
f0100fe2:	7e 18                	jle    f0100ffc <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
f0100fe4:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fe7:	8b 10                	mov    (%eax),%edx
f0100fe9:	8b 48 04             	mov    0x4(%eax),%ecx
f0100fec:	8d 40 08             	lea    0x8(%eax),%eax
f0100fef:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0100ff2:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100ff7:	e9 cf 00 00 00       	jmp    f01010cb <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0100ffc:	85 c9                	test   %ecx,%ecx
f0100ffe:	74 1a                	je     f010101a <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
f0101000:	8b 45 14             	mov    0x14(%ebp),%eax
f0101003:	8b 10                	mov    (%eax),%edx
f0101005:	b9 00 00 00 00       	mov    $0x0,%ecx
f010100a:	8d 40 04             	lea    0x4(%eax),%eax
f010100d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0101010:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101015:	e9 b1 00 00 00       	jmp    f01010cb <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f010101a:	8b 45 14             	mov    0x14(%ebp),%eax
f010101d:	8b 10                	mov    (%eax),%edx
f010101f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101024:	8d 40 04             	lea    0x4(%eax),%eax
f0101027:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f010102a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010102f:	e9 97 00 00 00       	jmp    f01010cb <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0101034:	83 ec 08             	sub    $0x8,%esp
f0101037:	53                   	push   %ebx
f0101038:	6a 58                	push   $0x58
f010103a:	ff d6                	call   *%esi
			putch('X', putdat);
f010103c:	83 c4 08             	add    $0x8,%esp
f010103f:	53                   	push   %ebx
f0101040:	6a 58                	push   $0x58
f0101042:	ff d6                	call   *%esi
			putch('X', putdat);
f0101044:	83 c4 08             	add    $0x8,%esp
f0101047:	53                   	push   %ebx
f0101048:	6a 58                	push   $0x58
f010104a:	ff d6                	call   *%esi
			break;
f010104c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010104f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0101052:	e9 8b fc ff ff       	jmp    f0100ce2 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
f0101057:	83 ec 08             	sub    $0x8,%esp
f010105a:	53                   	push   %ebx
f010105b:	6a 30                	push   $0x30
f010105d:	ff d6                	call   *%esi
			putch('x', putdat);
f010105f:	83 c4 08             	add    $0x8,%esp
f0101062:	53                   	push   %ebx
f0101063:	6a 78                	push   $0x78
f0101065:	ff d6                	call   *%esi
			num = (unsigned long long)
f0101067:	8b 45 14             	mov    0x14(%ebp),%eax
f010106a:	8b 10                	mov    (%eax),%edx
f010106c:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101071:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101074:	8d 40 04             	lea    0x4(%eax),%eax
f0101077:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010107a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f010107f:	eb 4a                	jmp    f01010cb <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101081:	83 f9 01             	cmp    $0x1,%ecx
f0101084:	7e 15                	jle    f010109b <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
f0101086:	8b 45 14             	mov    0x14(%ebp),%eax
f0101089:	8b 10                	mov    (%eax),%edx
f010108b:	8b 48 04             	mov    0x4(%eax),%ecx
f010108e:	8d 40 08             	lea    0x8(%eax),%eax
f0101091:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0101094:	b8 10 00 00 00       	mov    $0x10,%eax
f0101099:	eb 30                	jmp    f01010cb <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f010109b:	85 c9                	test   %ecx,%ecx
f010109d:	74 17                	je     f01010b6 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
f010109f:	8b 45 14             	mov    0x14(%ebp),%eax
f01010a2:	8b 10                	mov    (%eax),%edx
f01010a4:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010a9:	8d 40 04             	lea    0x4(%eax),%eax
f01010ac:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01010af:	b8 10 00 00 00       	mov    $0x10,%eax
f01010b4:	eb 15                	jmp    f01010cb <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f01010b6:	8b 45 14             	mov    0x14(%ebp),%eax
f01010b9:	8b 10                	mov    (%eax),%edx
f01010bb:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010c0:	8d 40 04             	lea    0x4(%eax),%eax
f01010c3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01010c6:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01010cb:	83 ec 0c             	sub    $0xc,%esp
f01010ce:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01010d2:	57                   	push   %edi
f01010d3:	ff 75 e0             	pushl  -0x20(%ebp)
f01010d6:	50                   	push   %eax
f01010d7:	51                   	push   %ecx
f01010d8:	52                   	push   %edx
f01010d9:	89 da                	mov    %ebx,%edx
f01010db:	89 f0                	mov    %esi,%eax
f01010dd:	e8 f1 fa ff ff       	call   f0100bd3 <printnum>
			break;
f01010e2:	83 c4 20             	add    $0x20,%esp
f01010e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01010e8:	e9 f5 fb ff ff       	jmp    f0100ce2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01010ed:	83 ec 08             	sub    $0x8,%esp
f01010f0:	53                   	push   %ebx
f01010f1:	52                   	push   %edx
f01010f2:	ff d6                	call   *%esi
			break;
f01010f4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01010fa:	e9 e3 fb ff ff       	jmp    f0100ce2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01010ff:	83 ec 08             	sub    $0x8,%esp
f0101102:	53                   	push   %ebx
f0101103:	6a 25                	push   $0x25
f0101105:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101107:	83 c4 10             	add    $0x10,%esp
f010110a:	eb 03                	jmp    f010110f <vprintfmt+0x453>
f010110c:	83 ef 01             	sub    $0x1,%edi
f010110f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0101113:	75 f7                	jne    f010110c <vprintfmt+0x450>
f0101115:	e9 c8 fb ff ff       	jmp    f0100ce2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f010111a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010111d:	5b                   	pop    %ebx
f010111e:	5e                   	pop    %esi
f010111f:	5f                   	pop    %edi
f0101120:	5d                   	pop    %ebp
f0101121:	c3                   	ret    

f0101122 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101122:	55                   	push   %ebp
f0101123:	89 e5                	mov    %esp,%ebp
f0101125:	83 ec 18             	sub    $0x18,%esp
f0101128:	8b 45 08             	mov    0x8(%ebp),%eax
f010112b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010112e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101131:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101135:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101138:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010113f:	85 c0                	test   %eax,%eax
f0101141:	74 26                	je     f0101169 <vsnprintf+0x47>
f0101143:	85 d2                	test   %edx,%edx
f0101145:	7e 22                	jle    f0101169 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101147:	ff 75 14             	pushl  0x14(%ebp)
f010114a:	ff 75 10             	pushl  0x10(%ebp)
f010114d:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101150:	50                   	push   %eax
f0101151:	68 82 0c 10 f0       	push   $0xf0100c82
f0101156:	e8 61 fb ff ff       	call   f0100cbc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010115b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010115e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101161:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101164:	83 c4 10             	add    $0x10,%esp
f0101167:	eb 05                	jmp    f010116e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101169:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010116e:	c9                   	leave  
f010116f:	c3                   	ret    

f0101170 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101170:	55                   	push   %ebp
f0101171:	89 e5                	mov    %esp,%ebp
f0101173:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101176:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101179:	50                   	push   %eax
f010117a:	ff 75 10             	pushl  0x10(%ebp)
f010117d:	ff 75 0c             	pushl  0xc(%ebp)
f0101180:	ff 75 08             	pushl  0x8(%ebp)
f0101183:	e8 9a ff ff ff       	call   f0101122 <vsnprintf>
	va_end(ap);

	return rc;
}
f0101188:	c9                   	leave  
f0101189:	c3                   	ret    

f010118a <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010118a:	55                   	push   %ebp
f010118b:	89 e5                	mov    %esp,%ebp
f010118d:	57                   	push   %edi
f010118e:	56                   	push   %esi
f010118f:	53                   	push   %ebx
f0101190:	83 ec 0c             	sub    $0xc,%esp
f0101193:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101196:	85 c0                	test   %eax,%eax
f0101198:	74 11                	je     f01011ab <readline+0x21>
		cprintf("%s", prompt);
f010119a:	83 ec 08             	sub    $0x8,%esp
f010119d:	50                   	push   %eax
f010119e:	68 a2 1d 10 f0       	push   $0xf0101da2
f01011a3:	e8 50 f7 ff ff       	call   f01008f8 <cprintf>
f01011a8:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01011ab:	83 ec 0c             	sub    $0xc,%esp
f01011ae:	6a 00                	push   $0x0
f01011b0:	e8 c7 f4 ff ff       	call   f010067c <iscons>
f01011b5:	89 c7                	mov    %eax,%edi
f01011b7:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01011ba:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01011bf:	e8 a7 f4 ff ff       	call   f010066b <getchar>
f01011c4:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01011c6:	85 c0                	test   %eax,%eax
f01011c8:	79 18                	jns    f01011e2 <readline+0x58>
			cprintf("read error: %e\n", c);
f01011ca:	83 ec 08             	sub    $0x8,%esp
f01011cd:	50                   	push   %eax
f01011ce:	68 84 1f 10 f0       	push   $0xf0101f84
f01011d3:	e8 20 f7 ff ff       	call   f01008f8 <cprintf>
			return NULL;
f01011d8:	83 c4 10             	add    $0x10,%esp
f01011db:	b8 00 00 00 00       	mov    $0x0,%eax
f01011e0:	eb 79                	jmp    f010125b <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01011e2:	83 f8 08             	cmp    $0x8,%eax
f01011e5:	0f 94 c2             	sete   %dl
f01011e8:	83 f8 7f             	cmp    $0x7f,%eax
f01011eb:	0f 94 c0             	sete   %al
f01011ee:	08 c2                	or     %al,%dl
f01011f0:	74 1a                	je     f010120c <readline+0x82>
f01011f2:	85 f6                	test   %esi,%esi
f01011f4:	7e 16                	jle    f010120c <readline+0x82>
			if (echoing)
f01011f6:	85 ff                	test   %edi,%edi
f01011f8:	74 0d                	je     f0101207 <readline+0x7d>
				cputchar('\b');
f01011fa:	83 ec 0c             	sub    $0xc,%esp
f01011fd:	6a 08                	push   $0x8
f01011ff:	e8 57 f4 ff ff       	call   f010065b <cputchar>
f0101204:	83 c4 10             	add    $0x10,%esp
			i--;
f0101207:	83 ee 01             	sub    $0x1,%esi
f010120a:	eb b3                	jmp    f01011bf <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010120c:	83 fb 1f             	cmp    $0x1f,%ebx
f010120f:	7e 23                	jle    f0101234 <readline+0xaa>
f0101211:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101217:	7f 1b                	jg     f0101234 <readline+0xaa>
			if (echoing)
f0101219:	85 ff                	test   %edi,%edi
f010121b:	74 0c                	je     f0101229 <readline+0x9f>
				cputchar(c);
f010121d:	83 ec 0c             	sub    $0xc,%esp
f0101220:	53                   	push   %ebx
f0101221:	e8 35 f4 ff ff       	call   f010065b <cputchar>
f0101226:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0101229:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f010122f:	8d 76 01             	lea    0x1(%esi),%esi
f0101232:	eb 8b                	jmp    f01011bf <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0101234:	83 fb 0a             	cmp    $0xa,%ebx
f0101237:	74 05                	je     f010123e <readline+0xb4>
f0101239:	83 fb 0d             	cmp    $0xd,%ebx
f010123c:	75 81                	jne    f01011bf <readline+0x35>
			if (echoing)
f010123e:	85 ff                	test   %edi,%edi
f0101240:	74 0d                	je     f010124f <readline+0xc5>
				cputchar('\n');
f0101242:	83 ec 0c             	sub    $0xc,%esp
f0101245:	6a 0a                	push   $0xa
f0101247:	e8 0f f4 ff ff       	call   f010065b <cputchar>
f010124c:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010124f:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f0101256:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f010125b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010125e:	5b                   	pop    %ebx
f010125f:	5e                   	pop    %esi
f0101260:	5f                   	pop    %edi
f0101261:	5d                   	pop    %ebp
f0101262:	c3                   	ret    

f0101263 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101263:	55                   	push   %ebp
f0101264:	89 e5                	mov    %esp,%ebp
f0101266:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101269:	b8 00 00 00 00       	mov    $0x0,%eax
f010126e:	eb 03                	jmp    f0101273 <strlen+0x10>
		n++;
f0101270:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101273:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101277:	75 f7                	jne    f0101270 <strlen+0xd>
		n++;
	return n;
}
f0101279:	5d                   	pop    %ebp
f010127a:	c3                   	ret    

f010127b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010127b:	55                   	push   %ebp
f010127c:	89 e5                	mov    %esp,%ebp
f010127e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101281:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101284:	ba 00 00 00 00       	mov    $0x0,%edx
f0101289:	eb 03                	jmp    f010128e <strnlen+0x13>
		n++;
f010128b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010128e:	39 c2                	cmp    %eax,%edx
f0101290:	74 08                	je     f010129a <strnlen+0x1f>
f0101292:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0101296:	75 f3                	jne    f010128b <strnlen+0x10>
f0101298:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010129a:	5d                   	pop    %ebp
f010129b:	c3                   	ret    

f010129c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010129c:	55                   	push   %ebp
f010129d:	89 e5                	mov    %esp,%ebp
f010129f:	53                   	push   %ebx
f01012a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01012a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01012a6:	89 c2                	mov    %eax,%edx
f01012a8:	83 c2 01             	add    $0x1,%edx
f01012ab:	83 c1 01             	add    $0x1,%ecx
f01012ae:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01012b2:	88 5a ff             	mov    %bl,-0x1(%edx)
f01012b5:	84 db                	test   %bl,%bl
f01012b7:	75 ef                	jne    f01012a8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01012b9:	5b                   	pop    %ebx
f01012ba:	5d                   	pop    %ebp
f01012bb:	c3                   	ret    

f01012bc <strcat>:

char *
strcat(char *dst, const char *src)
{
f01012bc:	55                   	push   %ebp
f01012bd:	89 e5                	mov    %esp,%ebp
f01012bf:	53                   	push   %ebx
f01012c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01012c3:	53                   	push   %ebx
f01012c4:	e8 9a ff ff ff       	call   f0101263 <strlen>
f01012c9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01012cc:	ff 75 0c             	pushl  0xc(%ebp)
f01012cf:	01 d8                	add    %ebx,%eax
f01012d1:	50                   	push   %eax
f01012d2:	e8 c5 ff ff ff       	call   f010129c <strcpy>
	return dst;
}
f01012d7:	89 d8                	mov    %ebx,%eax
f01012d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01012dc:	c9                   	leave  
f01012dd:	c3                   	ret    

f01012de <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01012de:	55                   	push   %ebp
f01012df:	89 e5                	mov    %esp,%ebp
f01012e1:	56                   	push   %esi
f01012e2:	53                   	push   %ebx
f01012e3:	8b 75 08             	mov    0x8(%ebp),%esi
f01012e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01012e9:	89 f3                	mov    %esi,%ebx
f01012eb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01012ee:	89 f2                	mov    %esi,%edx
f01012f0:	eb 0f                	jmp    f0101301 <strncpy+0x23>
		*dst++ = *src;
f01012f2:	83 c2 01             	add    $0x1,%edx
f01012f5:	0f b6 01             	movzbl (%ecx),%eax
f01012f8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01012fb:	80 39 01             	cmpb   $0x1,(%ecx)
f01012fe:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101301:	39 da                	cmp    %ebx,%edx
f0101303:	75 ed                	jne    f01012f2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101305:	89 f0                	mov    %esi,%eax
f0101307:	5b                   	pop    %ebx
f0101308:	5e                   	pop    %esi
f0101309:	5d                   	pop    %ebp
f010130a:	c3                   	ret    

f010130b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010130b:	55                   	push   %ebp
f010130c:	89 e5                	mov    %esp,%ebp
f010130e:	56                   	push   %esi
f010130f:	53                   	push   %ebx
f0101310:	8b 75 08             	mov    0x8(%ebp),%esi
f0101313:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101316:	8b 55 10             	mov    0x10(%ebp),%edx
f0101319:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010131b:	85 d2                	test   %edx,%edx
f010131d:	74 21                	je     f0101340 <strlcpy+0x35>
f010131f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0101323:	89 f2                	mov    %esi,%edx
f0101325:	eb 09                	jmp    f0101330 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101327:	83 c2 01             	add    $0x1,%edx
f010132a:	83 c1 01             	add    $0x1,%ecx
f010132d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101330:	39 c2                	cmp    %eax,%edx
f0101332:	74 09                	je     f010133d <strlcpy+0x32>
f0101334:	0f b6 19             	movzbl (%ecx),%ebx
f0101337:	84 db                	test   %bl,%bl
f0101339:	75 ec                	jne    f0101327 <strlcpy+0x1c>
f010133b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f010133d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101340:	29 f0                	sub    %esi,%eax
}
f0101342:	5b                   	pop    %ebx
f0101343:	5e                   	pop    %esi
f0101344:	5d                   	pop    %ebp
f0101345:	c3                   	ret    

f0101346 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101346:	55                   	push   %ebp
f0101347:	89 e5                	mov    %esp,%ebp
f0101349:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010134c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010134f:	eb 06                	jmp    f0101357 <strcmp+0x11>
		p++, q++;
f0101351:	83 c1 01             	add    $0x1,%ecx
f0101354:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101357:	0f b6 01             	movzbl (%ecx),%eax
f010135a:	84 c0                	test   %al,%al
f010135c:	74 04                	je     f0101362 <strcmp+0x1c>
f010135e:	3a 02                	cmp    (%edx),%al
f0101360:	74 ef                	je     f0101351 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101362:	0f b6 c0             	movzbl %al,%eax
f0101365:	0f b6 12             	movzbl (%edx),%edx
f0101368:	29 d0                	sub    %edx,%eax
}
f010136a:	5d                   	pop    %ebp
f010136b:	c3                   	ret    

f010136c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010136c:	55                   	push   %ebp
f010136d:	89 e5                	mov    %esp,%ebp
f010136f:	53                   	push   %ebx
f0101370:	8b 45 08             	mov    0x8(%ebp),%eax
f0101373:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101376:	89 c3                	mov    %eax,%ebx
f0101378:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010137b:	eb 06                	jmp    f0101383 <strncmp+0x17>
		n--, p++, q++;
f010137d:	83 c0 01             	add    $0x1,%eax
f0101380:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101383:	39 d8                	cmp    %ebx,%eax
f0101385:	74 15                	je     f010139c <strncmp+0x30>
f0101387:	0f b6 08             	movzbl (%eax),%ecx
f010138a:	84 c9                	test   %cl,%cl
f010138c:	74 04                	je     f0101392 <strncmp+0x26>
f010138e:	3a 0a                	cmp    (%edx),%cl
f0101390:	74 eb                	je     f010137d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101392:	0f b6 00             	movzbl (%eax),%eax
f0101395:	0f b6 12             	movzbl (%edx),%edx
f0101398:	29 d0                	sub    %edx,%eax
f010139a:	eb 05                	jmp    f01013a1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010139c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01013a1:	5b                   	pop    %ebx
f01013a2:	5d                   	pop    %ebp
f01013a3:	c3                   	ret    

f01013a4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01013a4:	55                   	push   %ebp
f01013a5:	89 e5                	mov    %esp,%ebp
f01013a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01013aa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01013ae:	eb 07                	jmp    f01013b7 <strchr+0x13>
		if (*s == c)
f01013b0:	38 ca                	cmp    %cl,%dl
f01013b2:	74 0f                	je     f01013c3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01013b4:	83 c0 01             	add    $0x1,%eax
f01013b7:	0f b6 10             	movzbl (%eax),%edx
f01013ba:	84 d2                	test   %dl,%dl
f01013bc:	75 f2                	jne    f01013b0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01013be:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01013c3:	5d                   	pop    %ebp
f01013c4:	c3                   	ret    

f01013c5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01013c5:	55                   	push   %ebp
f01013c6:	89 e5                	mov    %esp,%ebp
f01013c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01013cb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01013cf:	eb 03                	jmp    f01013d4 <strfind+0xf>
f01013d1:	83 c0 01             	add    $0x1,%eax
f01013d4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01013d7:	38 ca                	cmp    %cl,%dl
f01013d9:	74 04                	je     f01013df <strfind+0x1a>
f01013db:	84 d2                	test   %dl,%dl
f01013dd:	75 f2                	jne    f01013d1 <strfind+0xc>
			break;
	return (char *) s;
}
f01013df:	5d                   	pop    %ebp
f01013e0:	c3                   	ret    

f01013e1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01013e1:	55                   	push   %ebp
f01013e2:	89 e5                	mov    %esp,%ebp
f01013e4:	57                   	push   %edi
f01013e5:	56                   	push   %esi
f01013e6:	53                   	push   %ebx
f01013e7:	8b 7d 08             	mov    0x8(%ebp),%edi
f01013ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01013ed:	85 c9                	test   %ecx,%ecx
f01013ef:	74 36                	je     f0101427 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01013f1:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01013f7:	75 28                	jne    f0101421 <memset+0x40>
f01013f9:	f6 c1 03             	test   $0x3,%cl
f01013fc:	75 23                	jne    f0101421 <memset+0x40>
		c &= 0xFF;
f01013fe:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101402:	89 d3                	mov    %edx,%ebx
f0101404:	c1 e3 08             	shl    $0x8,%ebx
f0101407:	89 d6                	mov    %edx,%esi
f0101409:	c1 e6 18             	shl    $0x18,%esi
f010140c:	89 d0                	mov    %edx,%eax
f010140e:	c1 e0 10             	shl    $0x10,%eax
f0101411:	09 f0                	or     %esi,%eax
f0101413:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0101415:	89 d8                	mov    %ebx,%eax
f0101417:	09 d0                	or     %edx,%eax
f0101419:	c1 e9 02             	shr    $0x2,%ecx
f010141c:	fc                   	cld    
f010141d:	f3 ab                	rep stos %eax,%es:(%edi)
f010141f:	eb 06                	jmp    f0101427 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101421:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101424:	fc                   	cld    
f0101425:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101427:	89 f8                	mov    %edi,%eax
f0101429:	5b                   	pop    %ebx
f010142a:	5e                   	pop    %esi
f010142b:	5f                   	pop    %edi
f010142c:	5d                   	pop    %ebp
f010142d:	c3                   	ret    

f010142e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010142e:	55                   	push   %ebp
f010142f:	89 e5                	mov    %esp,%ebp
f0101431:	57                   	push   %edi
f0101432:	56                   	push   %esi
f0101433:	8b 45 08             	mov    0x8(%ebp),%eax
f0101436:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101439:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010143c:	39 c6                	cmp    %eax,%esi
f010143e:	73 35                	jae    f0101475 <memmove+0x47>
f0101440:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101443:	39 d0                	cmp    %edx,%eax
f0101445:	73 2e                	jae    f0101475 <memmove+0x47>
		s += n;
		d += n;
f0101447:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010144a:	89 d6                	mov    %edx,%esi
f010144c:	09 fe                	or     %edi,%esi
f010144e:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101454:	75 13                	jne    f0101469 <memmove+0x3b>
f0101456:	f6 c1 03             	test   $0x3,%cl
f0101459:	75 0e                	jne    f0101469 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f010145b:	83 ef 04             	sub    $0x4,%edi
f010145e:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101461:	c1 e9 02             	shr    $0x2,%ecx
f0101464:	fd                   	std    
f0101465:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101467:	eb 09                	jmp    f0101472 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101469:	83 ef 01             	sub    $0x1,%edi
f010146c:	8d 72 ff             	lea    -0x1(%edx),%esi
f010146f:	fd                   	std    
f0101470:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101472:	fc                   	cld    
f0101473:	eb 1d                	jmp    f0101492 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101475:	89 f2                	mov    %esi,%edx
f0101477:	09 c2                	or     %eax,%edx
f0101479:	f6 c2 03             	test   $0x3,%dl
f010147c:	75 0f                	jne    f010148d <memmove+0x5f>
f010147e:	f6 c1 03             	test   $0x3,%cl
f0101481:	75 0a                	jne    f010148d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0101483:	c1 e9 02             	shr    $0x2,%ecx
f0101486:	89 c7                	mov    %eax,%edi
f0101488:	fc                   	cld    
f0101489:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010148b:	eb 05                	jmp    f0101492 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010148d:	89 c7                	mov    %eax,%edi
f010148f:	fc                   	cld    
f0101490:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101492:	5e                   	pop    %esi
f0101493:	5f                   	pop    %edi
f0101494:	5d                   	pop    %ebp
f0101495:	c3                   	ret    

f0101496 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101496:	55                   	push   %ebp
f0101497:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101499:	ff 75 10             	pushl  0x10(%ebp)
f010149c:	ff 75 0c             	pushl  0xc(%ebp)
f010149f:	ff 75 08             	pushl  0x8(%ebp)
f01014a2:	e8 87 ff ff ff       	call   f010142e <memmove>
}
f01014a7:	c9                   	leave  
f01014a8:	c3                   	ret    

f01014a9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01014a9:	55                   	push   %ebp
f01014aa:	89 e5                	mov    %esp,%ebp
f01014ac:	56                   	push   %esi
f01014ad:	53                   	push   %ebx
f01014ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01014b1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01014b4:	89 c6                	mov    %eax,%esi
f01014b6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01014b9:	eb 1a                	jmp    f01014d5 <memcmp+0x2c>
		if (*s1 != *s2)
f01014bb:	0f b6 08             	movzbl (%eax),%ecx
f01014be:	0f b6 1a             	movzbl (%edx),%ebx
f01014c1:	38 d9                	cmp    %bl,%cl
f01014c3:	74 0a                	je     f01014cf <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01014c5:	0f b6 c1             	movzbl %cl,%eax
f01014c8:	0f b6 db             	movzbl %bl,%ebx
f01014cb:	29 d8                	sub    %ebx,%eax
f01014cd:	eb 0f                	jmp    f01014de <memcmp+0x35>
		s1++, s2++;
f01014cf:	83 c0 01             	add    $0x1,%eax
f01014d2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01014d5:	39 f0                	cmp    %esi,%eax
f01014d7:	75 e2                	jne    f01014bb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01014d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01014de:	5b                   	pop    %ebx
f01014df:	5e                   	pop    %esi
f01014e0:	5d                   	pop    %ebp
f01014e1:	c3                   	ret    

f01014e2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01014e2:	55                   	push   %ebp
f01014e3:	89 e5                	mov    %esp,%ebp
f01014e5:	53                   	push   %ebx
f01014e6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01014e9:	89 c1                	mov    %eax,%ecx
f01014eb:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01014ee:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01014f2:	eb 0a                	jmp    f01014fe <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01014f4:	0f b6 10             	movzbl (%eax),%edx
f01014f7:	39 da                	cmp    %ebx,%edx
f01014f9:	74 07                	je     f0101502 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01014fb:	83 c0 01             	add    $0x1,%eax
f01014fe:	39 c8                	cmp    %ecx,%eax
f0101500:	72 f2                	jb     f01014f4 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101502:	5b                   	pop    %ebx
f0101503:	5d                   	pop    %ebp
f0101504:	c3                   	ret    

f0101505 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101505:	55                   	push   %ebp
f0101506:	89 e5                	mov    %esp,%ebp
f0101508:	57                   	push   %edi
f0101509:	56                   	push   %esi
f010150a:	53                   	push   %ebx
f010150b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010150e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101511:	eb 03                	jmp    f0101516 <strtol+0x11>
		s++;
f0101513:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101516:	0f b6 01             	movzbl (%ecx),%eax
f0101519:	3c 20                	cmp    $0x20,%al
f010151b:	74 f6                	je     f0101513 <strtol+0xe>
f010151d:	3c 09                	cmp    $0x9,%al
f010151f:	74 f2                	je     f0101513 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101521:	3c 2b                	cmp    $0x2b,%al
f0101523:	75 0a                	jne    f010152f <strtol+0x2a>
		s++;
f0101525:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101528:	bf 00 00 00 00       	mov    $0x0,%edi
f010152d:	eb 11                	jmp    f0101540 <strtol+0x3b>
f010152f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101534:	3c 2d                	cmp    $0x2d,%al
f0101536:	75 08                	jne    f0101540 <strtol+0x3b>
		s++, neg = 1;
f0101538:	83 c1 01             	add    $0x1,%ecx
f010153b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101540:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101546:	75 15                	jne    f010155d <strtol+0x58>
f0101548:	80 39 30             	cmpb   $0x30,(%ecx)
f010154b:	75 10                	jne    f010155d <strtol+0x58>
f010154d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101551:	75 7c                	jne    f01015cf <strtol+0xca>
		s += 2, base = 16;
f0101553:	83 c1 02             	add    $0x2,%ecx
f0101556:	bb 10 00 00 00       	mov    $0x10,%ebx
f010155b:	eb 16                	jmp    f0101573 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f010155d:	85 db                	test   %ebx,%ebx
f010155f:	75 12                	jne    f0101573 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101561:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101566:	80 39 30             	cmpb   $0x30,(%ecx)
f0101569:	75 08                	jne    f0101573 <strtol+0x6e>
		s++, base = 8;
f010156b:	83 c1 01             	add    $0x1,%ecx
f010156e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0101573:	b8 00 00 00 00       	mov    $0x0,%eax
f0101578:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010157b:	0f b6 11             	movzbl (%ecx),%edx
f010157e:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101581:	89 f3                	mov    %esi,%ebx
f0101583:	80 fb 09             	cmp    $0x9,%bl
f0101586:	77 08                	ja     f0101590 <strtol+0x8b>
			dig = *s - '0';
f0101588:	0f be d2             	movsbl %dl,%edx
f010158b:	83 ea 30             	sub    $0x30,%edx
f010158e:	eb 22                	jmp    f01015b2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0101590:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101593:	89 f3                	mov    %esi,%ebx
f0101595:	80 fb 19             	cmp    $0x19,%bl
f0101598:	77 08                	ja     f01015a2 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010159a:	0f be d2             	movsbl %dl,%edx
f010159d:	83 ea 57             	sub    $0x57,%edx
f01015a0:	eb 10                	jmp    f01015b2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01015a2:	8d 72 bf             	lea    -0x41(%edx),%esi
f01015a5:	89 f3                	mov    %esi,%ebx
f01015a7:	80 fb 19             	cmp    $0x19,%bl
f01015aa:	77 16                	ja     f01015c2 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01015ac:	0f be d2             	movsbl %dl,%edx
f01015af:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01015b2:	3b 55 10             	cmp    0x10(%ebp),%edx
f01015b5:	7d 0b                	jge    f01015c2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01015b7:	83 c1 01             	add    $0x1,%ecx
f01015ba:	0f af 45 10          	imul   0x10(%ebp),%eax
f01015be:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01015c0:	eb b9                	jmp    f010157b <strtol+0x76>

	if (endptr)
f01015c2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01015c6:	74 0d                	je     f01015d5 <strtol+0xd0>
		*endptr = (char *) s;
f01015c8:	8b 75 0c             	mov    0xc(%ebp),%esi
f01015cb:	89 0e                	mov    %ecx,(%esi)
f01015cd:	eb 06                	jmp    f01015d5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01015cf:	85 db                	test   %ebx,%ebx
f01015d1:	74 98                	je     f010156b <strtol+0x66>
f01015d3:	eb 9e                	jmp    f0101573 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01015d5:	89 c2                	mov    %eax,%edx
f01015d7:	f7 da                	neg    %edx
f01015d9:	85 ff                	test   %edi,%edi
f01015db:	0f 45 c2             	cmovne %edx,%eax
}
f01015de:	5b                   	pop    %ebx
f01015df:	5e                   	pop    %esi
f01015e0:	5f                   	pop    %edi
f01015e1:	5d                   	pop    %ebp
f01015e2:	c3                   	ret    
f01015e3:	66 90                	xchg   %ax,%ax
f01015e5:	66 90                	xchg   %ax,%ax
f01015e7:	66 90                	xchg   %ax,%ax
f01015e9:	66 90                	xchg   %ax,%ax
f01015eb:	66 90                	xchg   %ax,%ax
f01015ed:	66 90                	xchg   %ax,%ax
f01015ef:	90                   	nop

f01015f0 <__udivdi3>:
f01015f0:	55                   	push   %ebp
f01015f1:	57                   	push   %edi
f01015f2:	56                   	push   %esi
f01015f3:	53                   	push   %ebx
f01015f4:	83 ec 1c             	sub    $0x1c,%esp
f01015f7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01015fb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01015ff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0101603:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101607:	85 f6                	test   %esi,%esi
f0101609:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010160d:	89 ca                	mov    %ecx,%edx
f010160f:	89 f8                	mov    %edi,%eax
f0101611:	75 3d                	jne    f0101650 <__udivdi3+0x60>
f0101613:	39 cf                	cmp    %ecx,%edi
f0101615:	0f 87 c5 00 00 00    	ja     f01016e0 <__udivdi3+0xf0>
f010161b:	85 ff                	test   %edi,%edi
f010161d:	89 fd                	mov    %edi,%ebp
f010161f:	75 0b                	jne    f010162c <__udivdi3+0x3c>
f0101621:	b8 01 00 00 00       	mov    $0x1,%eax
f0101626:	31 d2                	xor    %edx,%edx
f0101628:	f7 f7                	div    %edi
f010162a:	89 c5                	mov    %eax,%ebp
f010162c:	89 c8                	mov    %ecx,%eax
f010162e:	31 d2                	xor    %edx,%edx
f0101630:	f7 f5                	div    %ebp
f0101632:	89 c1                	mov    %eax,%ecx
f0101634:	89 d8                	mov    %ebx,%eax
f0101636:	89 cf                	mov    %ecx,%edi
f0101638:	f7 f5                	div    %ebp
f010163a:	89 c3                	mov    %eax,%ebx
f010163c:	89 d8                	mov    %ebx,%eax
f010163e:	89 fa                	mov    %edi,%edx
f0101640:	83 c4 1c             	add    $0x1c,%esp
f0101643:	5b                   	pop    %ebx
f0101644:	5e                   	pop    %esi
f0101645:	5f                   	pop    %edi
f0101646:	5d                   	pop    %ebp
f0101647:	c3                   	ret    
f0101648:	90                   	nop
f0101649:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101650:	39 ce                	cmp    %ecx,%esi
f0101652:	77 74                	ja     f01016c8 <__udivdi3+0xd8>
f0101654:	0f bd fe             	bsr    %esi,%edi
f0101657:	83 f7 1f             	xor    $0x1f,%edi
f010165a:	0f 84 98 00 00 00    	je     f01016f8 <__udivdi3+0x108>
f0101660:	bb 20 00 00 00       	mov    $0x20,%ebx
f0101665:	89 f9                	mov    %edi,%ecx
f0101667:	89 c5                	mov    %eax,%ebp
f0101669:	29 fb                	sub    %edi,%ebx
f010166b:	d3 e6                	shl    %cl,%esi
f010166d:	89 d9                	mov    %ebx,%ecx
f010166f:	d3 ed                	shr    %cl,%ebp
f0101671:	89 f9                	mov    %edi,%ecx
f0101673:	d3 e0                	shl    %cl,%eax
f0101675:	09 ee                	or     %ebp,%esi
f0101677:	89 d9                	mov    %ebx,%ecx
f0101679:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010167d:	89 d5                	mov    %edx,%ebp
f010167f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101683:	d3 ed                	shr    %cl,%ebp
f0101685:	89 f9                	mov    %edi,%ecx
f0101687:	d3 e2                	shl    %cl,%edx
f0101689:	89 d9                	mov    %ebx,%ecx
f010168b:	d3 e8                	shr    %cl,%eax
f010168d:	09 c2                	or     %eax,%edx
f010168f:	89 d0                	mov    %edx,%eax
f0101691:	89 ea                	mov    %ebp,%edx
f0101693:	f7 f6                	div    %esi
f0101695:	89 d5                	mov    %edx,%ebp
f0101697:	89 c3                	mov    %eax,%ebx
f0101699:	f7 64 24 0c          	mull   0xc(%esp)
f010169d:	39 d5                	cmp    %edx,%ebp
f010169f:	72 10                	jb     f01016b1 <__udivdi3+0xc1>
f01016a1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01016a5:	89 f9                	mov    %edi,%ecx
f01016a7:	d3 e6                	shl    %cl,%esi
f01016a9:	39 c6                	cmp    %eax,%esi
f01016ab:	73 07                	jae    f01016b4 <__udivdi3+0xc4>
f01016ad:	39 d5                	cmp    %edx,%ebp
f01016af:	75 03                	jne    f01016b4 <__udivdi3+0xc4>
f01016b1:	83 eb 01             	sub    $0x1,%ebx
f01016b4:	31 ff                	xor    %edi,%edi
f01016b6:	89 d8                	mov    %ebx,%eax
f01016b8:	89 fa                	mov    %edi,%edx
f01016ba:	83 c4 1c             	add    $0x1c,%esp
f01016bd:	5b                   	pop    %ebx
f01016be:	5e                   	pop    %esi
f01016bf:	5f                   	pop    %edi
f01016c0:	5d                   	pop    %ebp
f01016c1:	c3                   	ret    
f01016c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01016c8:	31 ff                	xor    %edi,%edi
f01016ca:	31 db                	xor    %ebx,%ebx
f01016cc:	89 d8                	mov    %ebx,%eax
f01016ce:	89 fa                	mov    %edi,%edx
f01016d0:	83 c4 1c             	add    $0x1c,%esp
f01016d3:	5b                   	pop    %ebx
f01016d4:	5e                   	pop    %esi
f01016d5:	5f                   	pop    %edi
f01016d6:	5d                   	pop    %ebp
f01016d7:	c3                   	ret    
f01016d8:	90                   	nop
f01016d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01016e0:	89 d8                	mov    %ebx,%eax
f01016e2:	f7 f7                	div    %edi
f01016e4:	31 ff                	xor    %edi,%edi
f01016e6:	89 c3                	mov    %eax,%ebx
f01016e8:	89 d8                	mov    %ebx,%eax
f01016ea:	89 fa                	mov    %edi,%edx
f01016ec:	83 c4 1c             	add    $0x1c,%esp
f01016ef:	5b                   	pop    %ebx
f01016f0:	5e                   	pop    %esi
f01016f1:	5f                   	pop    %edi
f01016f2:	5d                   	pop    %ebp
f01016f3:	c3                   	ret    
f01016f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01016f8:	39 ce                	cmp    %ecx,%esi
f01016fa:	72 0c                	jb     f0101708 <__udivdi3+0x118>
f01016fc:	31 db                	xor    %ebx,%ebx
f01016fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0101702:	0f 87 34 ff ff ff    	ja     f010163c <__udivdi3+0x4c>
f0101708:	bb 01 00 00 00       	mov    $0x1,%ebx
f010170d:	e9 2a ff ff ff       	jmp    f010163c <__udivdi3+0x4c>
f0101712:	66 90                	xchg   %ax,%ax
f0101714:	66 90                	xchg   %ax,%ax
f0101716:	66 90                	xchg   %ax,%ax
f0101718:	66 90                	xchg   %ax,%ax
f010171a:	66 90                	xchg   %ax,%ax
f010171c:	66 90                	xchg   %ax,%ax
f010171e:	66 90                	xchg   %ax,%ax

f0101720 <__umoddi3>:
f0101720:	55                   	push   %ebp
f0101721:	57                   	push   %edi
f0101722:	56                   	push   %esi
f0101723:	53                   	push   %ebx
f0101724:	83 ec 1c             	sub    $0x1c,%esp
f0101727:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010172b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010172f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101733:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101737:	85 d2                	test   %edx,%edx
f0101739:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010173d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101741:	89 f3                	mov    %esi,%ebx
f0101743:	89 3c 24             	mov    %edi,(%esp)
f0101746:	89 74 24 04          	mov    %esi,0x4(%esp)
f010174a:	75 1c                	jne    f0101768 <__umoddi3+0x48>
f010174c:	39 f7                	cmp    %esi,%edi
f010174e:	76 50                	jbe    f01017a0 <__umoddi3+0x80>
f0101750:	89 c8                	mov    %ecx,%eax
f0101752:	89 f2                	mov    %esi,%edx
f0101754:	f7 f7                	div    %edi
f0101756:	89 d0                	mov    %edx,%eax
f0101758:	31 d2                	xor    %edx,%edx
f010175a:	83 c4 1c             	add    $0x1c,%esp
f010175d:	5b                   	pop    %ebx
f010175e:	5e                   	pop    %esi
f010175f:	5f                   	pop    %edi
f0101760:	5d                   	pop    %ebp
f0101761:	c3                   	ret    
f0101762:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101768:	39 f2                	cmp    %esi,%edx
f010176a:	89 d0                	mov    %edx,%eax
f010176c:	77 52                	ja     f01017c0 <__umoddi3+0xa0>
f010176e:	0f bd ea             	bsr    %edx,%ebp
f0101771:	83 f5 1f             	xor    $0x1f,%ebp
f0101774:	75 5a                	jne    f01017d0 <__umoddi3+0xb0>
f0101776:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010177a:	0f 82 e0 00 00 00    	jb     f0101860 <__umoddi3+0x140>
f0101780:	39 0c 24             	cmp    %ecx,(%esp)
f0101783:	0f 86 d7 00 00 00    	jbe    f0101860 <__umoddi3+0x140>
f0101789:	8b 44 24 08          	mov    0x8(%esp),%eax
f010178d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101791:	83 c4 1c             	add    $0x1c,%esp
f0101794:	5b                   	pop    %ebx
f0101795:	5e                   	pop    %esi
f0101796:	5f                   	pop    %edi
f0101797:	5d                   	pop    %ebp
f0101798:	c3                   	ret    
f0101799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01017a0:	85 ff                	test   %edi,%edi
f01017a2:	89 fd                	mov    %edi,%ebp
f01017a4:	75 0b                	jne    f01017b1 <__umoddi3+0x91>
f01017a6:	b8 01 00 00 00       	mov    $0x1,%eax
f01017ab:	31 d2                	xor    %edx,%edx
f01017ad:	f7 f7                	div    %edi
f01017af:	89 c5                	mov    %eax,%ebp
f01017b1:	89 f0                	mov    %esi,%eax
f01017b3:	31 d2                	xor    %edx,%edx
f01017b5:	f7 f5                	div    %ebp
f01017b7:	89 c8                	mov    %ecx,%eax
f01017b9:	f7 f5                	div    %ebp
f01017bb:	89 d0                	mov    %edx,%eax
f01017bd:	eb 99                	jmp    f0101758 <__umoddi3+0x38>
f01017bf:	90                   	nop
f01017c0:	89 c8                	mov    %ecx,%eax
f01017c2:	89 f2                	mov    %esi,%edx
f01017c4:	83 c4 1c             	add    $0x1c,%esp
f01017c7:	5b                   	pop    %ebx
f01017c8:	5e                   	pop    %esi
f01017c9:	5f                   	pop    %edi
f01017ca:	5d                   	pop    %ebp
f01017cb:	c3                   	ret    
f01017cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01017d0:	8b 34 24             	mov    (%esp),%esi
f01017d3:	bf 20 00 00 00       	mov    $0x20,%edi
f01017d8:	89 e9                	mov    %ebp,%ecx
f01017da:	29 ef                	sub    %ebp,%edi
f01017dc:	d3 e0                	shl    %cl,%eax
f01017de:	89 f9                	mov    %edi,%ecx
f01017e0:	89 f2                	mov    %esi,%edx
f01017e2:	d3 ea                	shr    %cl,%edx
f01017e4:	89 e9                	mov    %ebp,%ecx
f01017e6:	09 c2                	or     %eax,%edx
f01017e8:	89 d8                	mov    %ebx,%eax
f01017ea:	89 14 24             	mov    %edx,(%esp)
f01017ed:	89 f2                	mov    %esi,%edx
f01017ef:	d3 e2                	shl    %cl,%edx
f01017f1:	89 f9                	mov    %edi,%ecx
f01017f3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01017f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01017fb:	d3 e8                	shr    %cl,%eax
f01017fd:	89 e9                	mov    %ebp,%ecx
f01017ff:	89 c6                	mov    %eax,%esi
f0101801:	d3 e3                	shl    %cl,%ebx
f0101803:	89 f9                	mov    %edi,%ecx
f0101805:	89 d0                	mov    %edx,%eax
f0101807:	d3 e8                	shr    %cl,%eax
f0101809:	89 e9                	mov    %ebp,%ecx
f010180b:	09 d8                	or     %ebx,%eax
f010180d:	89 d3                	mov    %edx,%ebx
f010180f:	89 f2                	mov    %esi,%edx
f0101811:	f7 34 24             	divl   (%esp)
f0101814:	89 d6                	mov    %edx,%esi
f0101816:	d3 e3                	shl    %cl,%ebx
f0101818:	f7 64 24 04          	mull   0x4(%esp)
f010181c:	39 d6                	cmp    %edx,%esi
f010181e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101822:	89 d1                	mov    %edx,%ecx
f0101824:	89 c3                	mov    %eax,%ebx
f0101826:	72 08                	jb     f0101830 <__umoddi3+0x110>
f0101828:	75 11                	jne    f010183b <__umoddi3+0x11b>
f010182a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010182e:	73 0b                	jae    f010183b <__umoddi3+0x11b>
f0101830:	2b 44 24 04          	sub    0x4(%esp),%eax
f0101834:	1b 14 24             	sbb    (%esp),%edx
f0101837:	89 d1                	mov    %edx,%ecx
f0101839:	89 c3                	mov    %eax,%ebx
f010183b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010183f:	29 da                	sub    %ebx,%edx
f0101841:	19 ce                	sbb    %ecx,%esi
f0101843:	89 f9                	mov    %edi,%ecx
f0101845:	89 f0                	mov    %esi,%eax
f0101847:	d3 e0                	shl    %cl,%eax
f0101849:	89 e9                	mov    %ebp,%ecx
f010184b:	d3 ea                	shr    %cl,%edx
f010184d:	89 e9                	mov    %ebp,%ecx
f010184f:	d3 ee                	shr    %cl,%esi
f0101851:	09 d0                	or     %edx,%eax
f0101853:	89 f2                	mov    %esi,%edx
f0101855:	83 c4 1c             	add    $0x1c,%esp
f0101858:	5b                   	pop    %ebx
f0101859:	5e                   	pop    %esi
f010185a:	5f                   	pop    %edi
f010185b:	5d                   	pop    %ebp
f010185c:	c3                   	ret    
f010185d:	8d 76 00             	lea    0x0(%esi),%esi
f0101860:	29 f9                	sub    %edi,%ecx
f0101862:	19 d6                	sbb    %edx,%esi
f0101864:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101868:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010186c:	e9 18 ff ff ff       	jmp    f0101789 <__umoddi3+0x69>
