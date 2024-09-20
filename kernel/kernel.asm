
kernel/kernel:     formato del fichero elf64-littleriscv


Desensamblado de la sección .text:

0000000080000000 <_entry>:
    80000000:	0000b117          	auipc	sp,0xb
    80000004:	14013103          	ld	sp,320(sp) # 8000b140 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	1761                	addi	a4,a4,-8 # 200bff8 <_entry-0x7dff4008>
    8000003a:	6318                	ld	a4,0(a4)
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	0000b717          	auipc	a4,0xb
    80000054:	15070713          	addi	a4,a4,336 # 8000b1a0 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	cbe78793          	addi	a5,a5,-834 # 80005d20 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffda1ef>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	e2678793          	addi	a5,a5,-474 # 80000ed2 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	f84a                	sd	s2,48(sp)
    80000108:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    8000010a:	04c05663          	blez	a2,80000156 <consolewrite+0x56>
    8000010e:	fc26                	sd	s1,56(sp)
    80000110:	f44e                	sd	s3,40(sp)
    80000112:	f052                	sd	s4,32(sp)
    80000114:	ec56                	sd	s5,24(sp)
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	428080e7          	jalr	1064(ra) # 80002552 <either_copyin>
    80000132:	03550463          	beq	a0,s5,8000015a <consolewrite+0x5a>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	7e4080e7          	jalr	2020(ra) # 8000091e <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
    8000014c:	74e2                	ld	s1,56(sp)
    8000014e:	79a2                	ld	s3,40(sp)
    80000150:	7a02                	ld	s4,32(sp)
    80000152:	6ae2                	ld	s5,24(sp)
    80000154:	a039                	j	80000162 <consolewrite+0x62>
    80000156:	4901                	li	s2,0
    80000158:	a029                	j	80000162 <consolewrite+0x62>
    8000015a:	74e2                	ld	s1,56(sp)
    8000015c:	79a2                	ld	s3,40(sp)
    8000015e:	7a02                	ld	s4,32(sp)
    80000160:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    80000162:	854a                	mv	a0,s2
    80000164:	60a6                	ld	ra,72(sp)
    80000166:	6406                	ld	s0,64(sp)
    80000168:	7942                	ld	s2,48(sp)
    8000016a:	6161                	addi	sp,sp,80
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	addi	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	addi	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018c:	00013517          	auipc	a0,0x13
    80000190:	15450513          	addi	a0,a0,340 # 800132e0 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	aa4080e7          	jalr	-1372(ra) # 80000c38 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00013497          	auipc	s1,0x13
    800001a0:	14448493          	addi	s1,s1,324 # 800132e0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	00013917          	auipc	s2,0x13
    800001a8:	1d490913          	addi	s2,s2,468 # 80013378 <cons+0x98>
  while(n > 0){
    800001ac:	0d305763          	blez	s3,8000027a <consoleread+0x10c>
    while(cons.r == cons.w){
    800001b0:	0984a783          	lw	a5,152(s1)
    800001b4:	09c4a703          	lw	a4,156(s1)
    800001b8:	0af71c63          	bne	a4,a5,80000270 <consoleread+0x102>
      if(killed(myproc())){
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	88e080e7          	jalr	-1906(ra) # 80001a4a <myproc>
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	1d8080e7          	jalr	472(ra) # 8000239c <killed>
    800001cc:	e52d                	bnez	a0,80000236 <consoleread+0xc8>
      sleep(&cons.r, &cons.lock);
    800001ce:	85a6                	mv	a1,s1
    800001d0:	854a                	mv	a0,s2
    800001d2:	00002097          	auipc	ra,0x2
    800001d6:	f22080e7          	jalr	-222(ra) # 800020f4 <sleep>
    while(cons.r == cons.w){
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70de3          	beq	a4,a5,800001bc <consoleread+0x4e>
    800001e6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	00013717          	auipc	a4,0x13
    800001ec:	0f870713          	addi	a4,a4,248 # 800132e0 <cons>
    800001f0:	0017869b          	addiw	a3,a5,1
    800001f4:	08d72c23          	sw	a3,152(a4)
    800001f8:	07f7f693          	andi	a3,a5,127
    800001fc:	9736                	add	a4,a4,a3
    800001fe:	01874703          	lbu	a4,24(a4)
    80000202:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80000206:	4691                	li	a3,4
    80000208:	04db8a63          	beq	s7,a3,8000025c <consoleread+0xee>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000020c:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	faf40613          	addi	a2,s0,-81
    80000216:	85d2                	mv	a1,s4
    80000218:	8556                	mv	a0,s5
    8000021a:	00002097          	auipc	ra,0x2
    8000021e:	2e2080e7          	jalr	738(ra) # 800024fc <either_copyout>
    80000222:	57fd                	li	a5,-1
    80000224:	04f50a63          	beq	a0,a5,80000278 <consoleread+0x10a>
      break;

    dst++;
    80000228:	0a05                	addi	s4,s4,1
    --n;
    8000022a:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000022c:	47a9                	li	a5,10
    8000022e:	06fb8163          	beq	s7,a5,80000290 <consoleread+0x122>
    80000232:	6be2                	ld	s7,24(sp)
    80000234:	bfa5                	j	800001ac <consoleread+0x3e>
        release(&cons.lock);
    80000236:	00013517          	auipc	a0,0x13
    8000023a:	0aa50513          	addi	a0,a0,170 # 800132e0 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	aae080e7          	jalr	-1362(ra) # 80000cec <release>
        return -1;
    80000246:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000248:	60e6                	ld	ra,88(sp)
    8000024a:	6446                	ld	s0,80(sp)
    8000024c:	64a6                	ld	s1,72(sp)
    8000024e:	6906                	ld	s2,64(sp)
    80000250:	79e2                	ld	s3,56(sp)
    80000252:	7a42                	ld	s4,48(sp)
    80000254:	7aa2                	ld	s5,40(sp)
    80000256:	7b02                	ld	s6,32(sp)
    80000258:	6125                	addi	sp,sp,96
    8000025a:	8082                	ret
      if(n < target){
    8000025c:	0009871b          	sext.w	a4,s3
    80000260:	01677a63          	bgeu	a4,s6,80000274 <consoleread+0x106>
        cons.r--;
    80000264:	00013717          	auipc	a4,0x13
    80000268:	10f72a23          	sw	a5,276(a4) # 80013378 <cons+0x98>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a031                	j	8000027a <consoleread+0x10c>
    80000270:	ec5e                	sd	s7,24(sp)
    80000272:	bf9d                	j	800001e8 <consoleread+0x7a>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	a011                	j	8000027a <consoleread+0x10c>
    80000278:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000027a:	00013517          	auipc	a0,0x13
    8000027e:	06650513          	addi	a0,a0,102 # 800132e0 <cons>
    80000282:	00001097          	auipc	ra,0x1
    80000286:	a6a080e7          	jalr	-1430(ra) # 80000cec <release>
  return target - n;
    8000028a:	413b053b          	subw	a0,s6,s3
    8000028e:	bf6d                	j	80000248 <consoleread+0xda>
    80000290:	6be2                	ld	s7,24(sp)
    80000292:	b7e5                	j	8000027a <consoleread+0x10c>

0000000080000294 <consputc>:
{
    80000294:	1141                	addi	sp,sp,-16
    80000296:	e406                	sd	ra,8(sp)
    80000298:	e022                	sd	s0,0(sp)
    8000029a:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000029c:	10000793          	li	a5,256
    800002a0:	00f50a63          	beq	a0,a5,800002b4 <consputc+0x20>
    uartputc_sync(c);
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	59c080e7          	jalr	1436(ra) # 80000840 <uartputc_sync>
}
    800002ac:	60a2                	ld	ra,8(sp)
    800002ae:	6402                	ld	s0,0(sp)
    800002b0:	0141                	addi	sp,sp,16
    800002b2:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002b4:	4521                	li	a0,8
    800002b6:	00000097          	auipc	ra,0x0
    800002ba:	58a080e7          	jalr	1418(ra) # 80000840 <uartputc_sync>
    800002be:	02000513          	li	a0,32
    800002c2:	00000097          	auipc	ra,0x0
    800002c6:	57e080e7          	jalr	1406(ra) # 80000840 <uartputc_sync>
    800002ca:	4521                	li	a0,8
    800002cc:	00000097          	auipc	ra,0x0
    800002d0:	574080e7          	jalr	1396(ra) # 80000840 <uartputc_sync>
    800002d4:	bfe1                	j	800002ac <consputc+0x18>

00000000800002d6 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002d6:	1101                	addi	sp,sp,-32
    800002d8:	ec06                	sd	ra,24(sp)
    800002da:	e822                	sd	s0,16(sp)
    800002dc:	e426                	sd	s1,8(sp)
    800002de:	1000                	addi	s0,sp,32
    800002e0:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002e2:	00013517          	auipc	a0,0x13
    800002e6:	ffe50513          	addi	a0,a0,-2 # 800132e0 <cons>
    800002ea:	00001097          	auipc	ra,0x1
    800002ee:	94e080e7          	jalr	-1714(ra) # 80000c38 <acquire>

  switch(c){
    800002f2:	47d5                	li	a5,21
    800002f4:	0af48563          	beq	s1,a5,8000039e <consoleintr+0xc8>
    800002f8:	0297c963          	blt	a5,s1,8000032a <consoleintr+0x54>
    800002fc:	47a1                	li	a5,8
    800002fe:	0ef48c63          	beq	s1,a5,800003f6 <consoleintr+0x120>
    80000302:	47c1                	li	a5,16
    80000304:	10f49f63          	bne	s1,a5,80000422 <consoleintr+0x14c>
  case C('P'):  // Print process list.
    procdump();
    80000308:	00002097          	auipc	ra,0x2
    8000030c:	2a0080e7          	jalr	672(ra) # 800025a8 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000310:	00013517          	auipc	a0,0x13
    80000314:	fd050513          	addi	a0,a0,-48 # 800132e0 <cons>
    80000318:	00001097          	auipc	ra,0x1
    8000031c:	9d4080e7          	jalr	-1580(ra) # 80000cec <release>
}
    80000320:	60e2                	ld	ra,24(sp)
    80000322:	6442                	ld	s0,16(sp)
    80000324:	64a2                	ld	s1,8(sp)
    80000326:	6105                	addi	sp,sp,32
    80000328:	8082                	ret
  switch(c){
    8000032a:	07f00793          	li	a5,127
    8000032e:	0cf48463          	beq	s1,a5,800003f6 <consoleintr+0x120>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000332:	00013717          	auipc	a4,0x13
    80000336:	fae70713          	addi	a4,a4,-82 # 800132e0 <cons>
    8000033a:	0a072783          	lw	a5,160(a4)
    8000033e:	09872703          	lw	a4,152(a4)
    80000342:	9f99                	subw	a5,a5,a4
    80000344:	07f00713          	li	a4,127
    80000348:	fcf764e3          	bltu	a4,a5,80000310 <consoleintr+0x3a>
      c = (c == '\r') ? '\n' : c;
    8000034c:	47b5                	li	a5,13
    8000034e:	0cf48d63          	beq	s1,a5,80000428 <consoleintr+0x152>
      consputc(c);
    80000352:	8526                	mv	a0,s1
    80000354:	00000097          	auipc	ra,0x0
    80000358:	f40080e7          	jalr	-192(ra) # 80000294 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000035c:	00013797          	auipc	a5,0x13
    80000360:	f8478793          	addi	a5,a5,-124 # 800132e0 <cons>
    80000364:	0a07a683          	lw	a3,160(a5)
    80000368:	0016871b          	addiw	a4,a3,1
    8000036c:	0007061b          	sext.w	a2,a4
    80000370:	0ae7a023          	sw	a4,160(a5)
    80000374:	07f6f693          	andi	a3,a3,127
    80000378:	97b6                	add	a5,a5,a3
    8000037a:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000037e:	47a9                	li	a5,10
    80000380:	0cf48b63          	beq	s1,a5,80000456 <consoleintr+0x180>
    80000384:	4791                	li	a5,4
    80000386:	0cf48863          	beq	s1,a5,80000456 <consoleintr+0x180>
    8000038a:	00013797          	auipc	a5,0x13
    8000038e:	fee7a783          	lw	a5,-18(a5) # 80013378 <cons+0x98>
    80000392:	9f1d                	subw	a4,a4,a5
    80000394:	08000793          	li	a5,128
    80000398:	f6f71ce3          	bne	a4,a5,80000310 <consoleintr+0x3a>
    8000039c:	a86d                	j	80000456 <consoleintr+0x180>
    8000039e:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    800003a0:	00013717          	auipc	a4,0x13
    800003a4:	f4070713          	addi	a4,a4,-192 # 800132e0 <cons>
    800003a8:	0a072783          	lw	a5,160(a4)
    800003ac:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003b0:	00013497          	auipc	s1,0x13
    800003b4:	f3048493          	addi	s1,s1,-208 # 800132e0 <cons>
    while(cons.e != cons.w &&
    800003b8:	4929                	li	s2,10
    800003ba:	02f70a63          	beq	a4,a5,800003ee <consoleintr+0x118>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003be:	37fd                	addiw	a5,a5,-1
    800003c0:	07f7f713          	andi	a4,a5,127
    800003c4:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003c6:	01874703          	lbu	a4,24(a4)
    800003ca:	03270463          	beq	a4,s2,800003f2 <consoleintr+0x11c>
      cons.e--;
    800003ce:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003d2:	10000513          	li	a0,256
    800003d6:	00000097          	auipc	ra,0x0
    800003da:	ebe080e7          	jalr	-322(ra) # 80000294 <consputc>
    while(cons.e != cons.w &&
    800003de:	0a04a783          	lw	a5,160(s1)
    800003e2:	09c4a703          	lw	a4,156(s1)
    800003e6:	fcf71ce3          	bne	a4,a5,800003be <consoleintr+0xe8>
    800003ea:	6902                	ld	s2,0(sp)
    800003ec:	b715                	j	80000310 <consoleintr+0x3a>
    800003ee:	6902                	ld	s2,0(sp)
    800003f0:	b705                	j	80000310 <consoleintr+0x3a>
    800003f2:	6902                	ld	s2,0(sp)
    800003f4:	bf31                	j	80000310 <consoleintr+0x3a>
    if(cons.e != cons.w){
    800003f6:	00013717          	auipc	a4,0x13
    800003fa:	eea70713          	addi	a4,a4,-278 # 800132e0 <cons>
    800003fe:	0a072783          	lw	a5,160(a4)
    80000402:	09c72703          	lw	a4,156(a4)
    80000406:	f0f705e3          	beq	a4,a5,80000310 <consoleintr+0x3a>
      cons.e--;
    8000040a:	37fd                	addiw	a5,a5,-1
    8000040c:	00013717          	auipc	a4,0x13
    80000410:	f6f72a23          	sw	a5,-140(a4) # 80013380 <cons+0xa0>
      consputc(BACKSPACE);
    80000414:	10000513          	li	a0,256
    80000418:	00000097          	auipc	ra,0x0
    8000041c:	e7c080e7          	jalr	-388(ra) # 80000294 <consputc>
    80000420:	bdc5                	j	80000310 <consoleintr+0x3a>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000422:	ee0487e3          	beqz	s1,80000310 <consoleintr+0x3a>
    80000426:	b731                	j	80000332 <consoleintr+0x5c>
      consputc(c);
    80000428:	4529                	li	a0,10
    8000042a:	00000097          	auipc	ra,0x0
    8000042e:	e6a080e7          	jalr	-406(ra) # 80000294 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000432:	00013797          	auipc	a5,0x13
    80000436:	eae78793          	addi	a5,a5,-338 # 800132e0 <cons>
    8000043a:	0a07a703          	lw	a4,160(a5)
    8000043e:	0017069b          	addiw	a3,a4,1
    80000442:	0006861b          	sext.w	a2,a3
    80000446:	0ad7a023          	sw	a3,160(a5)
    8000044a:	07f77713          	andi	a4,a4,127
    8000044e:	97ba                	add	a5,a5,a4
    80000450:	4729                	li	a4,10
    80000452:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000456:	00013797          	auipc	a5,0x13
    8000045a:	f2c7a323          	sw	a2,-218(a5) # 8001337c <cons+0x9c>
        wakeup(&cons.r);
    8000045e:	00013517          	auipc	a0,0x13
    80000462:	f1a50513          	addi	a0,a0,-230 # 80013378 <cons+0x98>
    80000466:	00002097          	auipc	ra,0x2
    8000046a:	cf2080e7          	jalr	-782(ra) # 80002158 <wakeup>
    8000046e:	b54d                	j	80000310 <consoleintr+0x3a>

0000000080000470 <consoleinit>:

void
consoleinit(void)
{
    80000470:	1141                	addi	sp,sp,-16
    80000472:	e406                	sd	ra,8(sp)
    80000474:	e022                	sd	s0,0(sp)
    80000476:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000478:	00008597          	auipc	a1,0x8
    8000047c:	b8858593          	addi	a1,a1,-1144 # 80008000 <etext>
    80000480:	00013517          	auipc	a0,0x13
    80000484:	e6050513          	addi	a0,a0,-416 # 800132e0 <cons>
    80000488:	00000097          	auipc	ra,0x0
    8000048c:	720080e7          	jalr	1824(ra) # 80000ba8 <initlock>

  uartinit();
    80000490:	00000097          	auipc	ra,0x0
    80000494:	354080e7          	jalr	852(ra) # 800007e4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000498:	00023797          	auipc	a5,0x23
    8000049c:	fe078793          	addi	a5,a5,-32 # 80023478 <devsw>
    800004a0:	00000717          	auipc	a4,0x0
    800004a4:	cce70713          	addi	a4,a4,-818 # 8000016e <consoleread>
    800004a8:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004aa:	00000717          	auipc	a4,0x0
    800004ae:	c5670713          	addi	a4,a4,-938 # 80000100 <consolewrite>
    800004b2:	ef98                	sd	a4,24(a5)
}
    800004b4:	60a2                	ld	ra,8(sp)
    800004b6:	6402                	ld	s0,0(sp)
    800004b8:	0141                	addi	sp,sp,16
    800004ba:	8082                	ret

00000000800004bc <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004bc:	7179                	addi	sp,sp,-48
    800004be:	f406                	sd	ra,40(sp)
    800004c0:	f022                	sd	s0,32(sp)
    800004c2:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004c4:	c219                	beqz	a2,800004ca <printint+0xe>
    800004c6:	08054963          	bltz	a0,80000558 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ca:	2501                	sext.w	a0,a0
    800004cc:	4881                	li	a7,0
    800004ce:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004d2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004d4:	2581                	sext.w	a1,a1
    800004d6:	00008617          	auipc	a2,0x8
    800004da:	25260613          	addi	a2,a2,594 # 80008728 <digits>
    800004de:	883a                	mv	a6,a4
    800004e0:	2705                	addiw	a4,a4,1
    800004e2:	02b577bb          	remuw	a5,a0,a1
    800004e6:	1782                	slli	a5,a5,0x20
    800004e8:	9381                	srli	a5,a5,0x20
    800004ea:	97b2                	add	a5,a5,a2
    800004ec:	0007c783          	lbu	a5,0(a5)
    800004f0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004f4:	0005079b          	sext.w	a5,a0
    800004f8:	02b5553b          	divuw	a0,a0,a1
    800004fc:	0685                	addi	a3,a3,1
    800004fe:	feb7f0e3          	bgeu	a5,a1,800004de <printint+0x22>

  if(sign)
    80000502:	00088c63          	beqz	a7,8000051a <printint+0x5e>
    buf[i++] = '-';
    80000506:	fe070793          	addi	a5,a4,-32
    8000050a:	00878733          	add	a4,a5,s0
    8000050e:	02d00793          	li	a5,45
    80000512:	fef70823          	sb	a5,-16(a4)
    80000516:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    8000051a:	02e05b63          	blez	a4,80000550 <printint+0x94>
    8000051e:	ec26                	sd	s1,24(sp)
    80000520:	e84a                	sd	s2,16(sp)
    80000522:	fd040793          	addi	a5,s0,-48
    80000526:	00e784b3          	add	s1,a5,a4
    8000052a:	fff78913          	addi	s2,a5,-1
    8000052e:	993a                	add	s2,s2,a4
    80000530:	377d                	addiw	a4,a4,-1
    80000532:	1702                	slli	a4,a4,0x20
    80000534:	9301                	srli	a4,a4,0x20
    80000536:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000053a:	fff4c503          	lbu	a0,-1(s1)
    8000053e:	00000097          	auipc	ra,0x0
    80000542:	d56080e7          	jalr	-682(ra) # 80000294 <consputc>
  while(--i >= 0)
    80000546:	14fd                	addi	s1,s1,-1
    80000548:	ff2499e3          	bne	s1,s2,8000053a <printint+0x7e>
    8000054c:	64e2                	ld	s1,24(sp)
    8000054e:	6942                	ld	s2,16(sp)
}
    80000550:	70a2                	ld	ra,40(sp)
    80000552:	7402                	ld	s0,32(sp)
    80000554:	6145                	addi	sp,sp,48
    80000556:	8082                	ret
    x = -xx;
    80000558:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000055c:	4885                	li	a7,1
    x = -xx;
    8000055e:	bf85                	j	800004ce <printint+0x12>

0000000080000560 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000560:	1101                	addi	sp,sp,-32
    80000562:	ec06                	sd	ra,24(sp)
    80000564:	e822                	sd	s0,16(sp)
    80000566:	e426                	sd	s1,8(sp)
    80000568:	1000                	addi	s0,sp,32
    8000056a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000056c:	00013797          	auipc	a5,0x13
    80000570:	e207aa23          	sw	zero,-460(a5) # 800133a0 <pr+0x18>
  printf("panic: ");
    80000574:	00008517          	auipc	a0,0x8
    80000578:	a9450513          	addi	a0,a0,-1388 # 80008008 <etext+0x8>
    8000057c:	00000097          	auipc	ra,0x0
    80000580:	02e080e7          	jalr	46(ra) # 800005aa <printf>
  printf(s);
    80000584:	8526                	mv	a0,s1
    80000586:	00000097          	auipc	ra,0x0
    8000058a:	024080e7          	jalr	36(ra) # 800005aa <printf>
  printf("\n");
    8000058e:	00008517          	auipc	a0,0x8
    80000592:	a8250513          	addi	a0,a0,-1406 # 80008010 <etext+0x10>
    80000596:	00000097          	auipc	ra,0x0
    8000059a:	014080e7          	jalr	20(ra) # 800005aa <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000059e:	4785                	li	a5,1
    800005a0:	0000b717          	auipc	a4,0xb
    800005a4:	bcf72023          	sw	a5,-1088(a4) # 8000b160 <panicked>
  for(;;)
    800005a8:	a001                	j	800005a8 <panic+0x48>

00000000800005aa <printf>:
{
    800005aa:	7131                	addi	sp,sp,-192
    800005ac:	fc86                	sd	ra,120(sp)
    800005ae:	f8a2                	sd	s0,112(sp)
    800005b0:	e8d2                	sd	s4,80(sp)
    800005b2:	f06a                	sd	s10,32(sp)
    800005b4:	0100                	addi	s0,sp,128
    800005b6:	8a2a                	mv	s4,a0
    800005b8:	e40c                	sd	a1,8(s0)
    800005ba:	e810                	sd	a2,16(s0)
    800005bc:	ec14                	sd	a3,24(s0)
    800005be:	f018                	sd	a4,32(s0)
    800005c0:	f41c                	sd	a5,40(s0)
    800005c2:	03043823          	sd	a6,48(s0)
    800005c6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ca:	00013d17          	auipc	s10,0x13
    800005ce:	dd6d2d03          	lw	s10,-554(s10) # 800133a0 <pr+0x18>
  if(locking)
    800005d2:	040d1463          	bnez	s10,8000061a <printf+0x70>
  if (fmt == 0)
    800005d6:	040a0b63          	beqz	s4,8000062c <printf+0x82>
  va_start(ap, fmt);
    800005da:	00840793          	addi	a5,s0,8
    800005de:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005e2:	000a4503          	lbu	a0,0(s4)
    800005e6:	18050b63          	beqz	a0,8000077c <printf+0x1d2>
    800005ea:	f4a6                	sd	s1,104(sp)
    800005ec:	f0ca                	sd	s2,96(sp)
    800005ee:	ecce                	sd	s3,88(sp)
    800005f0:	e4d6                	sd	s5,72(sp)
    800005f2:	e0da                	sd	s6,64(sp)
    800005f4:	fc5e                	sd	s7,56(sp)
    800005f6:	f862                	sd	s8,48(sp)
    800005f8:	f466                	sd	s9,40(sp)
    800005fa:	ec6e                	sd	s11,24(sp)
    800005fc:	4981                	li	s3,0
    if(c != '%'){
    800005fe:	02500b13          	li	s6,37
    switch(c){
    80000602:	07000b93          	li	s7,112
  consputc('x');
    80000606:	4cc1                	li	s9,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000608:	00008a97          	auipc	s5,0x8
    8000060c:	120a8a93          	addi	s5,s5,288 # 80008728 <digits>
    switch(c){
    80000610:	07300c13          	li	s8,115
    80000614:	06400d93          	li	s11,100
    80000618:	a0b1                	j	80000664 <printf+0xba>
    acquire(&pr.lock);
    8000061a:	00013517          	auipc	a0,0x13
    8000061e:	d6e50513          	addi	a0,a0,-658 # 80013388 <pr>
    80000622:	00000097          	auipc	ra,0x0
    80000626:	616080e7          	jalr	1558(ra) # 80000c38 <acquire>
    8000062a:	b775                	j	800005d6 <printf+0x2c>
    8000062c:	f4a6                	sd	s1,104(sp)
    8000062e:	f0ca                	sd	s2,96(sp)
    80000630:	ecce                	sd	s3,88(sp)
    80000632:	e4d6                	sd	s5,72(sp)
    80000634:	e0da                	sd	s6,64(sp)
    80000636:	fc5e                	sd	s7,56(sp)
    80000638:	f862                	sd	s8,48(sp)
    8000063a:	f466                	sd	s9,40(sp)
    8000063c:	ec6e                	sd	s11,24(sp)
    panic("null fmt");
    8000063e:	00008517          	auipc	a0,0x8
    80000642:	9e250513          	addi	a0,a0,-1566 # 80008020 <etext+0x20>
    80000646:	00000097          	auipc	ra,0x0
    8000064a:	f1a080e7          	jalr	-230(ra) # 80000560 <panic>
      consputc(c);
    8000064e:	00000097          	auipc	ra,0x0
    80000652:	c46080e7          	jalr	-954(ra) # 80000294 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000656:	2985                	addiw	s3,s3,1
    80000658:	013a07b3          	add	a5,s4,s3
    8000065c:	0007c503          	lbu	a0,0(a5)
    80000660:	10050563          	beqz	a0,8000076a <printf+0x1c0>
    if(c != '%'){
    80000664:	ff6515e3          	bne	a0,s6,8000064e <printf+0xa4>
    c = fmt[++i] & 0xff;
    80000668:	2985                	addiw	s3,s3,1
    8000066a:	013a07b3          	add	a5,s4,s3
    8000066e:	0007c783          	lbu	a5,0(a5)
    80000672:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000676:	10078b63          	beqz	a5,8000078c <printf+0x1e2>
    switch(c){
    8000067a:	05778a63          	beq	a5,s7,800006ce <printf+0x124>
    8000067e:	02fbf663          	bgeu	s7,a5,800006aa <printf+0x100>
    80000682:	09878863          	beq	a5,s8,80000712 <printf+0x168>
    80000686:	07800713          	li	a4,120
    8000068a:	0ce79563          	bne	a5,a4,80000754 <printf+0x1aa>
      printint(va_arg(ap, int), 16, 1);
    8000068e:	f8843783          	ld	a5,-120(s0)
    80000692:	00878713          	addi	a4,a5,8
    80000696:	f8e43423          	sd	a4,-120(s0)
    8000069a:	4605                	li	a2,1
    8000069c:	85e6                	mv	a1,s9
    8000069e:	4388                	lw	a0,0(a5)
    800006a0:	00000097          	auipc	ra,0x0
    800006a4:	e1c080e7          	jalr	-484(ra) # 800004bc <printint>
      break;
    800006a8:	b77d                	j	80000656 <printf+0xac>
    switch(c){
    800006aa:	09678f63          	beq	a5,s6,80000748 <printf+0x19e>
    800006ae:	0bb79363          	bne	a5,s11,80000754 <printf+0x1aa>
      printint(va_arg(ap, int), 10, 1);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4605                	li	a2,1
    800006c0:	45a9                	li	a1,10
    800006c2:	4388                	lw	a0,0(a5)
    800006c4:	00000097          	auipc	ra,0x0
    800006c8:	df8080e7          	jalr	-520(ra) # 800004bc <printint>
      break;
    800006cc:	b769                	j	80000656 <printf+0xac>
      printptr(va_arg(ap, uint64));
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	addi	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006de:	03000513          	li	a0,48
    800006e2:	00000097          	auipc	ra,0x0
    800006e6:	bb2080e7          	jalr	-1102(ra) # 80000294 <consputc>
  consputc('x');
    800006ea:	07800513          	li	a0,120
    800006ee:	00000097          	auipc	ra,0x0
    800006f2:	ba6080e7          	jalr	-1114(ra) # 80000294 <consputc>
    800006f6:	84e6                	mv	s1,s9
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006f8:	03c95793          	srli	a5,s2,0x3c
    800006fc:	97d6                	add	a5,a5,s5
    800006fe:	0007c503          	lbu	a0,0(a5)
    80000702:	00000097          	auipc	ra,0x0
    80000706:	b92080e7          	jalr	-1134(ra) # 80000294 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000070a:	0912                	slli	s2,s2,0x4
    8000070c:	34fd                	addiw	s1,s1,-1
    8000070e:	f4ed                	bnez	s1,800006f8 <printf+0x14e>
    80000710:	b799                	j	80000656 <printf+0xac>
      if((s = va_arg(ap, char*)) == 0)
    80000712:	f8843783          	ld	a5,-120(s0)
    80000716:	00878713          	addi	a4,a5,8
    8000071a:	f8e43423          	sd	a4,-120(s0)
    8000071e:	6384                	ld	s1,0(a5)
    80000720:	cc89                	beqz	s1,8000073a <printf+0x190>
      for(; *s; s++)
    80000722:	0004c503          	lbu	a0,0(s1)
    80000726:	d905                	beqz	a0,80000656 <printf+0xac>
        consputc(*s);
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b6c080e7          	jalr	-1172(ra) # 80000294 <consputc>
      for(; *s; s++)
    80000730:	0485                	addi	s1,s1,1
    80000732:	0004c503          	lbu	a0,0(s1)
    80000736:	f96d                	bnez	a0,80000728 <printf+0x17e>
    80000738:	bf39                	j	80000656 <printf+0xac>
        s = "(null)";
    8000073a:	00008497          	auipc	s1,0x8
    8000073e:	8de48493          	addi	s1,s1,-1826 # 80008018 <etext+0x18>
      for(; *s; s++)
    80000742:	02800513          	li	a0,40
    80000746:	b7cd                	j	80000728 <printf+0x17e>
      consputc('%');
    80000748:	855a                	mv	a0,s6
    8000074a:	00000097          	auipc	ra,0x0
    8000074e:	b4a080e7          	jalr	-1206(ra) # 80000294 <consputc>
      break;
    80000752:	b711                	j	80000656 <printf+0xac>
      consputc('%');
    80000754:	855a                	mv	a0,s6
    80000756:	00000097          	auipc	ra,0x0
    8000075a:	b3e080e7          	jalr	-1218(ra) # 80000294 <consputc>
      consputc(c);
    8000075e:	8526                	mv	a0,s1
    80000760:	00000097          	auipc	ra,0x0
    80000764:	b34080e7          	jalr	-1228(ra) # 80000294 <consputc>
      break;
    80000768:	b5fd                	j	80000656 <printf+0xac>
    8000076a:	74a6                	ld	s1,104(sp)
    8000076c:	7906                	ld	s2,96(sp)
    8000076e:	69e6                	ld	s3,88(sp)
    80000770:	6aa6                	ld	s5,72(sp)
    80000772:	6b06                	ld	s6,64(sp)
    80000774:	7be2                	ld	s7,56(sp)
    80000776:	7c42                	ld	s8,48(sp)
    80000778:	7ca2                	ld	s9,40(sp)
    8000077a:	6de2                	ld	s11,24(sp)
  if(locking)
    8000077c:	020d1263          	bnez	s10,800007a0 <printf+0x1f6>
}
    80000780:	70e6                	ld	ra,120(sp)
    80000782:	7446                	ld	s0,112(sp)
    80000784:	6a46                	ld	s4,80(sp)
    80000786:	7d02                	ld	s10,32(sp)
    80000788:	6129                	addi	sp,sp,192
    8000078a:	8082                	ret
    8000078c:	74a6                	ld	s1,104(sp)
    8000078e:	7906                	ld	s2,96(sp)
    80000790:	69e6                	ld	s3,88(sp)
    80000792:	6aa6                	ld	s5,72(sp)
    80000794:	6b06                	ld	s6,64(sp)
    80000796:	7be2                	ld	s7,56(sp)
    80000798:	7c42                	ld	s8,48(sp)
    8000079a:	7ca2                	ld	s9,40(sp)
    8000079c:	6de2                	ld	s11,24(sp)
    8000079e:	bff9                	j	8000077c <printf+0x1d2>
    release(&pr.lock);
    800007a0:	00013517          	auipc	a0,0x13
    800007a4:	be850513          	addi	a0,a0,-1048 # 80013388 <pr>
    800007a8:	00000097          	auipc	ra,0x0
    800007ac:	544080e7          	jalr	1348(ra) # 80000cec <release>
}
    800007b0:	bfc1                	j	80000780 <printf+0x1d6>

00000000800007b2 <printfinit>:
    ;
}

void
printfinit(void)
{
    800007b2:	1101                	addi	sp,sp,-32
    800007b4:	ec06                	sd	ra,24(sp)
    800007b6:	e822                	sd	s0,16(sp)
    800007b8:	e426                	sd	s1,8(sp)
    800007ba:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007bc:	00013497          	auipc	s1,0x13
    800007c0:	bcc48493          	addi	s1,s1,-1076 # 80013388 <pr>
    800007c4:	00008597          	auipc	a1,0x8
    800007c8:	86c58593          	addi	a1,a1,-1940 # 80008030 <etext+0x30>
    800007cc:	8526                	mv	a0,s1
    800007ce:	00000097          	auipc	ra,0x0
    800007d2:	3da080e7          	jalr	986(ra) # 80000ba8 <initlock>
  pr.locking = 1;
    800007d6:	4785                	li	a5,1
    800007d8:	cc9c                	sw	a5,24(s1)
}
    800007da:	60e2                	ld	ra,24(sp)
    800007dc:	6442                	ld	s0,16(sp)
    800007de:	64a2                	ld	s1,8(sp)
    800007e0:	6105                	addi	sp,sp,32
    800007e2:	8082                	ret

00000000800007e4 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007e4:	1141                	addi	sp,sp,-16
    800007e6:	e406                	sd	ra,8(sp)
    800007e8:	e022                	sd	s0,0(sp)
    800007ea:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ec:	100007b7          	lui	a5,0x10000
    800007f0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007f4:	10000737          	lui	a4,0x10000
    800007f8:	f8000693          	li	a3,-128
    800007fc:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000800:	468d                	li	a3,3
    80000802:	10000637          	lui	a2,0x10000
    80000806:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000080a:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000080e:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000812:	10000737          	lui	a4,0x10000
    80000816:	461d                	li	a2,7
    80000818:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000081c:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000820:	00008597          	auipc	a1,0x8
    80000824:	81858593          	addi	a1,a1,-2024 # 80008038 <etext+0x38>
    80000828:	00013517          	auipc	a0,0x13
    8000082c:	b8050513          	addi	a0,a0,-1152 # 800133a8 <uart_tx_lock>
    80000830:	00000097          	auipc	ra,0x0
    80000834:	378080e7          	jalr	888(ra) # 80000ba8 <initlock>
}
    80000838:	60a2                	ld	ra,8(sp)
    8000083a:	6402                	ld	s0,0(sp)
    8000083c:	0141                	addi	sp,sp,16
    8000083e:	8082                	ret

0000000080000840 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000840:	1101                	addi	sp,sp,-32
    80000842:	ec06                	sd	ra,24(sp)
    80000844:	e822                	sd	s0,16(sp)
    80000846:	e426                	sd	s1,8(sp)
    80000848:	1000                	addi	s0,sp,32
    8000084a:	84aa                	mv	s1,a0
  push_off();
    8000084c:	00000097          	auipc	ra,0x0
    80000850:	3a0080e7          	jalr	928(ra) # 80000bec <push_off>

  if(panicked){
    80000854:	0000b797          	auipc	a5,0xb
    80000858:	90c7a783          	lw	a5,-1780(a5) # 8000b160 <panicked>
    8000085c:	eb85                	bnez	a5,8000088c <uartputc_sync+0x4c>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000085e:	10000737          	lui	a4,0x10000
    80000862:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000864:	00074783          	lbu	a5,0(a4)
    80000868:	0207f793          	andi	a5,a5,32
    8000086c:	dfe5                	beqz	a5,80000864 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000086e:	0ff4f513          	zext.b	a0,s1
    80000872:	100007b7          	lui	a5,0x10000
    80000876:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000087a:	00000097          	auipc	ra,0x0
    8000087e:	412080e7          	jalr	1042(ra) # 80000c8c <pop_off>
}
    80000882:	60e2                	ld	ra,24(sp)
    80000884:	6442                	ld	s0,16(sp)
    80000886:	64a2                	ld	s1,8(sp)
    80000888:	6105                	addi	sp,sp,32
    8000088a:	8082                	ret
    for(;;)
    8000088c:	a001                	j	8000088c <uartputc_sync+0x4c>

000000008000088e <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000088e:	0000b797          	auipc	a5,0xb
    80000892:	8da7b783          	ld	a5,-1830(a5) # 8000b168 <uart_tx_r>
    80000896:	0000b717          	auipc	a4,0xb
    8000089a:	8da73703          	ld	a4,-1830(a4) # 8000b170 <uart_tx_w>
    8000089e:	06f70f63          	beq	a4,a5,8000091c <uartstart+0x8e>
{
    800008a2:	7139                	addi	sp,sp,-64
    800008a4:	fc06                	sd	ra,56(sp)
    800008a6:	f822                	sd	s0,48(sp)
    800008a8:	f426                	sd	s1,40(sp)
    800008aa:	f04a                	sd	s2,32(sp)
    800008ac:	ec4e                	sd	s3,24(sp)
    800008ae:	e852                	sd	s4,16(sp)
    800008b0:	e456                	sd	s5,8(sp)
    800008b2:	e05a                	sd	s6,0(sp)
    800008b4:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008b6:	10000937          	lui	s2,0x10000
    800008ba:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008bc:	00013a97          	auipc	s5,0x13
    800008c0:	aeca8a93          	addi	s5,s5,-1300 # 800133a8 <uart_tx_lock>
    uart_tx_r += 1;
    800008c4:	0000b497          	auipc	s1,0xb
    800008c8:	8a448493          	addi	s1,s1,-1884 # 8000b168 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008cc:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008d0:	0000b997          	auipc	s3,0xb
    800008d4:	8a098993          	addi	s3,s3,-1888 # 8000b170 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008d8:	00094703          	lbu	a4,0(s2)
    800008dc:	02077713          	andi	a4,a4,32
    800008e0:	c705                	beqz	a4,80000908 <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008e2:	01f7f713          	andi	a4,a5,31
    800008e6:	9756                	add	a4,a4,s5
    800008e8:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008ec:	0785                	addi	a5,a5,1
    800008ee:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008f0:	8526                	mv	a0,s1
    800008f2:	00002097          	auipc	ra,0x2
    800008f6:	866080e7          	jalr	-1946(ra) # 80002158 <wakeup>
    WriteReg(THR, c);
    800008fa:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800008fe:	609c                	ld	a5,0(s1)
    80000900:	0009b703          	ld	a4,0(s3)
    80000904:	fcf71ae3          	bne	a4,a5,800008d8 <uartstart+0x4a>
  }
}
    80000908:	70e2                	ld	ra,56(sp)
    8000090a:	7442                	ld	s0,48(sp)
    8000090c:	74a2                	ld	s1,40(sp)
    8000090e:	7902                	ld	s2,32(sp)
    80000910:	69e2                	ld	s3,24(sp)
    80000912:	6a42                	ld	s4,16(sp)
    80000914:	6aa2                	ld	s5,8(sp)
    80000916:	6b02                	ld	s6,0(sp)
    80000918:	6121                	addi	sp,sp,64
    8000091a:	8082                	ret
    8000091c:	8082                	ret

000000008000091e <uartputc>:
{
    8000091e:	7179                	addi	sp,sp,-48
    80000920:	f406                	sd	ra,40(sp)
    80000922:	f022                	sd	s0,32(sp)
    80000924:	ec26                	sd	s1,24(sp)
    80000926:	e84a                	sd	s2,16(sp)
    80000928:	e44e                	sd	s3,8(sp)
    8000092a:	e052                	sd	s4,0(sp)
    8000092c:	1800                	addi	s0,sp,48
    8000092e:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000930:	00013517          	auipc	a0,0x13
    80000934:	a7850513          	addi	a0,a0,-1416 # 800133a8 <uart_tx_lock>
    80000938:	00000097          	auipc	ra,0x0
    8000093c:	300080e7          	jalr	768(ra) # 80000c38 <acquire>
  if(panicked){
    80000940:	0000b797          	auipc	a5,0xb
    80000944:	8207a783          	lw	a5,-2016(a5) # 8000b160 <panicked>
    80000948:	e7c9                	bnez	a5,800009d2 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000094a:	0000b717          	auipc	a4,0xb
    8000094e:	82673703          	ld	a4,-2010(a4) # 8000b170 <uart_tx_w>
    80000952:	0000b797          	auipc	a5,0xb
    80000956:	8167b783          	ld	a5,-2026(a5) # 8000b168 <uart_tx_r>
    8000095a:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000095e:	00013997          	auipc	s3,0x13
    80000962:	a4a98993          	addi	s3,s3,-1462 # 800133a8 <uart_tx_lock>
    80000966:	0000b497          	auipc	s1,0xb
    8000096a:	80248493          	addi	s1,s1,-2046 # 8000b168 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000096e:	0000b917          	auipc	s2,0xb
    80000972:	80290913          	addi	s2,s2,-2046 # 8000b170 <uart_tx_w>
    80000976:	00e79f63          	bne	a5,a4,80000994 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000097a:	85ce                	mv	a1,s3
    8000097c:	8526                	mv	a0,s1
    8000097e:	00001097          	auipc	ra,0x1
    80000982:	776080e7          	jalr	1910(ra) # 800020f4 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00093703          	ld	a4,0(s2)
    8000098a:	609c                	ld	a5,0(s1)
    8000098c:	02078793          	addi	a5,a5,32
    80000990:	fee785e3          	beq	a5,a4,8000097a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000994:	00013497          	auipc	s1,0x13
    80000998:	a1448493          	addi	s1,s1,-1516 # 800133a8 <uart_tx_lock>
    8000099c:	01f77793          	andi	a5,a4,31
    800009a0:	97a6                	add	a5,a5,s1
    800009a2:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009a6:	0705                	addi	a4,a4,1
    800009a8:	0000a797          	auipc	a5,0xa
    800009ac:	7ce7b423          	sd	a4,1992(a5) # 8000b170 <uart_tx_w>
  uartstart();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	ede080e7          	jalr	-290(ra) # 8000088e <uartstart>
  release(&uart_tx_lock);
    800009b8:	8526                	mv	a0,s1
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	332080e7          	jalr	818(ra) # 80000cec <release>
}
    800009c2:	70a2                	ld	ra,40(sp)
    800009c4:	7402                	ld	s0,32(sp)
    800009c6:	64e2                	ld	s1,24(sp)
    800009c8:	6942                	ld	s2,16(sp)
    800009ca:	69a2                	ld	s3,8(sp)
    800009cc:	6a02                	ld	s4,0(sp)
    800009ce:	6145                	addi	sp,sp,48
    800009d0:	8082                	ret
    for(;;)
    800009d2:	a001                	j	800009d2 <uartputc+0xb4>

00000000800009d4 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009d4:	1141                	addi	sp,sp,-16
    800009d6:	e422                	sd	s0,8(sp)
    800009d8:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009da:	100007b7          	lui	a5,0x10000
    800009de:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009e0:	0007c783          	lbu	a5,0(a5)
    800009e4:	8b85                	andi	a5,a5,1
    800009e6:	cb81                	beqz	a5,800009f6 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009e8:	100007b7          	lui	a5,0x10000
    800009ec:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009f0:	6422                	ld	s0,8(sp)
    800009f2:	0141                	addi	sp,sp,16
    800009f4:	8082                	ret
    return -1;
    800009f6:	557d                	li	a0,-1
    800009f8:	bfe5                	j	800009f0 <uartgetc+0x1c>

00000000800009fa <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009fa:	1101                	addi	sp,sp,-32
    800009fc:	ec06                	sd	ra,24(sp)
    800009fe:	e822                	sd	s0,16(sp)
    80000a00:	e426                	sd	s1,8(sp)
    80000a02:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a04:	54fd                	li	s1,-1
    80000a06:	a029                	j	80000a10 <uartintr+0x16>
      break;
    consoleintr(c);
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	8ce080e7          	jalr	-1842(ra) # 800002d6 <consoleintr>
    int c = uartgetc();
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	fc4080e7          	jalr	-60(ra) # 800009d4 <uartgetc>
    if(c == -1)
    80000a18:	fe9518e3          	bne	a0,s1,80000a08 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a1c:	00013497          	auipc	s1,0x13
    80000a20:	98c48493          	addi	s1,s1,-1652 # 800133a8 <uart_tx_lock>
    80000a24:	8526                	mv	a0,s1
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	212080e7          	jalr	530(ra) # 80000c38 <acquire>
  uartstart();
    80000a2e:	00000097          	auipc	ra,0x0
    80000a32:	e60080e7          	jalr	-416(ra) # 8000088e <uartstart>
  release(&uart_tx_lock);
    80000a36:	8526                	mv	a0,s1
    80000a38:	00000097          	auipc	ra,0x0
    80000a3c:	2b4080e7          	jalr	692(ra) # 80000cec <release>
}
    80000a40:	60e2                	ld	ra,24(sp)
    80000a42:	6442                	ld	s0,16(sp)
    80000a44:	64a2                	ld	s1,8(sp)
    80000a46:	6105                	addi	sp,sp,32
    80000a48:	8082                	ret

0000000080000a4a <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a4a:	1101                	addi	sp,sp,-32
    80000a4c:	ec06                	sd	ra,24(sp)
    80000a4e:	e822                	sd	s0,16(sp)
    80000a50:	e426                	sd	s1,8(sp)
    80000a52:	e04a                	sd	s2,0(sp)
    80000a54:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a56:	03451793          	slli	a5,a0,0x34
    80000a5a:	ebb9                	bnez	a5,80000ab0 <kfree+0x66>
    80000a5c:	84aa                	mv	s1,a0
    80000a5e:	00024797          	auipc	a5,0x24
    80000a62:	bb278793          	addi	a5,a5,-1102 # 80024610 <end>
    80000a66:	04f56563          	bltu	a0,a5,80000ab0 <kfree+0x66>
    80000a6a:	47c5                	li	a5,17
    80000a6c:	07ee                	slli	a5,a5,0x1b
    80000a6e:	04f57163          	bgeu	a0,a5,80000ab0 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a72:	6605                	lui	a2,0x1
    80000a74:	4585                	li	a1,1
    80000a76:	00000097          	auipc	ra,0x0
    80000a7a:	2be080e7          	jalr	702(ra) # 80000d34 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a7e:	00013917          	auipc	s2,0x13
    80000a82:	96290913          	addi	s2,s2,-1694 # 800133e0 <kmem>
    80000a86:	854a                	mv	a0,s2
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	1b0080e7          	jalr	432(ra) # 80000c38 <acquire>
  r->next = kmem.freelist;
    80000a90:	01893783          	ld	a5,24(s2)
    80000a94:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a96:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a9a:	854a                	mv	a0,s2
    80000a9c:	00000097          	auipc	ra,0x0
    80000aa0:	250080e7          	jalr	592(ra) # 80000cec <release>
}
    80000aa4:	60e2                	ld	ra,24(sp)
    80000aa6:	6442                	ld	s0,16(sp)
    80000aa8:	64a2                	ld	s1,8(sp)
    80000aaa:	6902                	ld	s2,0(sp)
    80000aac:	6105                	addi	sp,sp,32
    80000aae:	8082                	ret
    panic("kfree");
    80000ab0:	00007517          	auipc	a0,0x7
    80000ab4:	59050513          	addi	a0,a0,1424 # 80008040 <etext+0x40>
    80000ab8:	00000097          	auipc	ra,0x0
    80000abc:	aa8080e7          	jalr	-1368(ra) # 80000560 <panic>

0000000080000ac0 <freerange>:
{
    80000ac0:	7179                	addi	sp,sp,-48
    80000ac2:	f406                	sd	ra,40(sp)
    80000ac4:	f022                	sd	s0,32(sp)
    80000ac6:	ec26                	sd	s1,24(sp)
    80000ac8:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000aca:	6785                	lui	a5,0x1
    80000acc:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ad0:	00e504b3          	add	s1,a0,a4
    80000ad4:	777d                	lui	a4,0xfffff
    80000ad6:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad8:	94be                	add	s1,s1,a5
    80000ada:	0295e463          	bltu	a1,s1,80000b02 <freerange+0x42>
    80000ade:	e84a                	sd	s2,16(sp)
    80000ae0:	e44e                	sd	s3,8(sp)
    80000ae2:	e052                	sd	s4,0(sp)
    80000ae4:	892e                	mv	s2,a1
    kfree(p);
    80000ae6:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae8:	6985                	lui	s3,0x1
    kfree(p);
    80000aea:	01448533          	add	a0,s1,s4
    80000aee:	00000097          	auipc	ra,0x0
    80000af2:	f5c080e7          	jalr	-164(ra) # 80000a4a <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af6:	94ce                	add	s1,s1,s3
    80000af8:	fe9979e3          	bgeu	s2,s1,80000aea <freerange+0x2a>
    80000afc:	6942                	ld	s2,16(sp)
    80000afe:	69a2                	ld	s3,8(sp)
    80000b00:	6a02                	ld	s4,0(sp)
}
    80000b02:	70a2                	ld	ra,40(sp)
    80000b04:	7402                	ld	s0,32(sp)
    80000b06:	64e2                	ld	s1,24(sp)
    80000b08:	6145                	addi	sp,sp,48
    80000b0a:	8082                	ret

0000000080000b0c <kinit>:
{
    80000b0c:	1141                	addi	sp,sp,-16
    80000b0e:	e406                	sd	ra,8(sp)
    80000b10:	e022                	sd	s0,0(sp)
    80000b12:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b14:	00007597          	auipc	a1,0x7
    80000b18:	53458593          	addi	a1,a1,1332 # 80008048 <etext+0x48>
    80000b1c:	00013517          	auipc	a0,0x13
    80000b20:	8c450513          	addi	a0,a0,-1852 # 800133e0 <kmem>
    80000b24:	00000097          	auipc	ra,0x0
    80000b28:	084080e7          	jalr	132(ra) # 80000ba8 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b2c:	45c5                	li	a1,17
    80000b2e:	05ee                	slli	a1,a1,0x1b
    80000b30:	00024517          	auipc	a0,0x24
    80000b34:	ae050513          	addi	a0,a0,-1312 # 80024610 <end>
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	f88080e7          	jalr	-120(ra) # 80000ac0 <freerange>
}
    80000b40:	60a2                	ld	ra,8(sp)
    80000b42:	6402                	ld	s0,0(sp)
    80000b44:	0141                	addi	sp,sp,16
    80000b46:	8082                	ret

0000000080000b48 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b48:	1101                	addi	sp,sp,-32
    80000b4a:	ec06                	sd	ra,24(sp)
    80000b4c:	e822                	sd	s0,16(sp)
    80000b4e:	e426                	sd	s1,8(sp)
    80000b50:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b52:	00013497          	auipc	s1,0x13
    80000b56:	88e48493          	addi	s1,s1,-1906 # 800133e0 <kmem>
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	00000097          	auipc	ra,0x0
    80000b60:	0dc080e7          	jalr	220(ra) # 80000c38 <acquire>
  r = kmem.freelist;
    80000b64:	6c84                	ld	s1,24(s1)
  if(r)
    80000b66:	c885                	beqz	s1,80000b96 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b68:	609c                	ld	a5,0(s1)
    80000b6a:	00013517          	auipc	a0,0x13
    80000b6e:	87650513          	addi	a0,a0,-1930 # 800133e0 <kmem>
    80000b72:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b74:	00000097          	auipc	ra,0x0
    80000b78:	178080e7          	jalr	376(ra) # 80000cec <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b7c:	6605                	lui	a2,0x1
    80000b7e:	4595                	li	a1,5
    80000b80:	8526                	mv	a0,s1
    80000b82:	00000097          	auipc	ra,0x0
    80000b86:	1b2080e7          	jalr	434(ra) # 80000d34 <memset>
  return (void*)r;
}
    80000b8a:	8526                	mv	a0,s1
    80000b8c:	60e2                	ld	ra,24(sp)
    80000b8e:	6442                	ld	s0,16(sp)
    80000b90:	64a2                	ld	s1,8(sp)
    80000b92:	6105                	addi	sp,sp,32
    80000b94:	8082                	ret
  release(&kmem.lock);
    80000b96:	00013517          	auipc	a0,0x13
    80000b9a:	84a50513          	addi	a0,a0,-1974 # 800133e0 <kmem>
    80000b9e:	00000097          	auipc	ra,0x0
    80000ba2:	14e080e7          	jalr	334(ra) # 80000cec <release>
  if(r)
    80000ba6:	b7d5                	j	80000b8a <kalloc+0x42>

0000000080000ba8 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000ba8:	1141                	addi	sp,sp,-16
    80000baa:	e422                	sd	s0,8(sp)
    80000bac:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bae:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bb0:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bb4:	00053823          	sd	zero,16(a0)
}
    80000bb8:	6422                	ld	s0,8(sp)
    80000bba:	0141                	addi	sp,sp,16
    80000bbc:	8082                	ret

0000000080000bbe <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bbe:	411c                	lw	a5,0(a0)
    80000bc0:	e399                	bnez	a5,80000bc6 <holding+0x8>
    80000bc2:	4501                	li	a0,0
  return r;
}
    80000bc4:	8082                	ret
{
    80000bc6:	1101                	addi	sp,sp,-32
    80000bc8:	ec06                	sd	ra,24(sp)
    80000bca:	e822                	sd	s0,16(sp)
    80000bcc:	e426                	sd	s1,8(sp)
    80000bce:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bd0:	6904                	ld	s1,16(a0)
    80000bd2:	00001097          	auipc	ra,0x1
    80000bd6:	e5c080e7          	jalr	-420(ra) # 80001a2e <mycpu>
    80000bda:	40a48533          	sub	a0,s1,a0
    80000bde:	00153513          	seqz	a0,a0
}
    80000be2:	60e2                	ld	ra,24(sp)
    80000be4:	6442                	ld	s0,16(sp)
    80000be6:	64a2                	ld	s1,8(sp)
    80000be8:	6105                	addi	sp,sp,32
    80000bea:	8082                	ret

0000000080000bec <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bec:	1101                	addi	sp,sp,-32
    80000bee:	ec06                	sd	ra,24(sp)
    80000bf0:	e822                	sd	s0,16(sp)
    80000bf2:	e426                	sd	s1,8(sp)
    80000bf4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bf6:	100024f3          	csrr	s1,sstatus
    80000bfa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bfe:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c00:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c04:	00001097          	auipc	ra,0x1
    80000c08:	e2a080e7          	jalr	-470(ra) # 80001a2e <mycpu>
    80000c0c:	5d3c                	lw	a5,120(a0)
    80000c0e:	cf89                	beqz	a5,80000c28 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c10:	00001097          	auipc	ra,0x1
    80000c14:	e1e080e7          	jalr	-482(ra) # 80001a2e <mycpu>
    80000c18:	5d3c                	lw	a5,120(a0)
    80000c1a:	2785                	addiw	a5,a5,1
    80000c1c:	dd3c                	sw	a5,120(a0)
}
    80000c1e:	60e2                	ld	ra,24(sp)
    80000c20:	6442                	ld	s0,16(sp)
    80000c22:	64a2                	ld	s1,8(sp)
    80000c24:	6105                	addi	sp,sp,32
    80000c26:	8082                	ret
    mycpu()->intena = old;
    80000c28:	00001097          	auipc	ra,0x1
    80000c2c:	e06080e7          	jalr	-506(ra) # 80001a2e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c30:	8085                	srli	s1,s1,0x1
    80000c32:	8885                	andi	s1,s1,1
    80000c34:	dd64                	sw	s1,124(a0)
    80000c36:	bfe9                	j	80000c10 <push_off+0x24>

0000000080000c38 <acquire>:
{
    80000c38:	1101                	addi	sp,sp,-32
    80000c3a:	ec06                	sd	ra,24(sp)
    80000c3c:	e822                	sd	s0,16(sp)
    80000c3e:	e426                	sd	s1,8(sp)
    80000c40:	1000                	addi	s0,sp,32
    80000c42:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c44:	00000097          	auipc	ra,0x0
    80000c48:	fa8080e7          	jalr	-88(ra) # 80000bec <push_off>
  if(holding(lk))
    80000c4c:	8526                	mv	a0,s1
    80000c4e:	00000097          	auipc	ra,0x0
    80000c52:	f70080e7          	jalr	-144(ra) # 80000bbe <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c56:	4705                	li	a4,1
  if(holding(lk))
    80000c58:	e115                	bnez	a0,80000c7c <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c5a:	87ba                	mv	a5,a4
    80000c5c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c60:	2781                	sext.w	a5,a5
    80000c62:	ffe5                	bnez	a5,80000c5a <acquire+0x22>
  __sync_synchronize();
    80000c64:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c68:	00001097          	auipc	ra,0x1
    80000c6c:	dc6080e7          	jalr	-570(ra) # 80001a2e <mycpu>
    80000c70:	e888                	sd	a0,16(s1)
}
    80000c72:	60e2                	ld	ra,24(sp)
    80000c74:	6442                	ld	s0,16(sp)
    80000c76:	64a2                	ld	s1,8(sp)
    80000c78:	6105                	addi	sp,sp,32
    80000c7a:	8082                	ret
    panic("acquire");
    80000c7c:	00007517          	auipc	a0,0x7
    80000c80:	3d450513          	addi	a0,a0,980 # 80008050 <etext+0x50>
    80000c84:	00000097          	auipc	ra,0x0
    80000c88:	8dc080e7          	jalr	-1828(ra) # 80000560 <panic>

0000000080000c8c <pop_off>:

void
pop_off(void)
{
    80000c8c:	1141                	addi	sp,sp,-16
    80000c8e:	e406                	sd	ra,8(sp)
    80000c90:	e022                	sd	s0,0(sp)
    80000c92:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c94:	00001097          	auipc	ra,0x1
    80000c98:	d9a080e7          	jalr	-614(ra) # 80001a2e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c9c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000ca0:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000ca2:	e78d                	bnez	a5,80000ccc <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000ca4:	5d3c                	lw	a5,120(a0)
    80000ca6:	02f05b63          	blez	a5,80000cdc <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000caa:	37fd                	addiw	a5,a5,-1
    80000cac:	0007871b          	sext.w	a4,a5
    80000cb0:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cb2:	eb09                	bnez	a4,80000cc4 <pop_off+0x38>
    80000cb4:	5d7c                	lw	a5,124(a0)
    80000cb6:	c799                	beqz	a5,80000cc4 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cb8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cbc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cc0:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cc4:	60a2                	ld	ra,8(sp)
    80000cc6:	6402                	ld	s0,0(sp)
    80000cc8:	0141                	addi	sp,sp,16
    80000cca:	8082                	ret
    panic("pop_off - interruptible");
    80000ccc:	00007517          	auipc	a0,0x7
    80000cd0:	38c50513          	addi	a0,a0,908 # 80008058 <etext+0x58>
    80000cd4:	00000097          	auipc	ra,0x0
    80000cd8:	88c080e7          	jalr	-1908(ra) # 80000560 <panic>
    panic("pop_off");
    80000cdc:	00007517          	auipc	a0,0x7
    80000ce0:	39450513          	addi	a0,a0,916 # 80008070 <etext+0x70>
    80000ce4:	00000097          	auipc	ra,0x0
    80000ce8:	87c080e7          	jalr	-1924(ra) # 80000560 <panic>

0000000080000cec <release>:
{
    80000cec:	1101                	addi	sp,sp,-32
    80000cee:	ec06                	sd	ra,24(sp)
    80000cf0:	e822                	sd	s0,16(sp)
    80000cf2:	e426                	sd	s1,8(sp)
    80000cf4:	1000                	addi	s0,sp,32
    80000cf6:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cf8:	00000097          	auipc	ra,0x0
    80000cfc:	ec6080e7          	jalr	-314(ra) # 80000bbe <holding>
    80000d00:	c115                	beqz	a0,80000d24 <release+0x38>
  lk->cpu = 0;
    80000d02:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d06:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000d0a:	0310000f          	fence	rw,w
    80000d0e:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000d12:	00000097          	auipc	ra,0x0
    80000d16:	f7a080e7          	jalr	-134(ra) # 80000c8c <pop_off>
}
    80000d1a:	60e2                	ld	ra,24(sp)
    80000d1c:	6442                	ld	s0,16(sp)
    80000d1e:	64a2                	ld	s1,8(sp)
    80000d20:	6105                	addi	sp,sp,32
    80000d22:	8082                	ret
    panic("release");
    80000d24:	00007517          	auipc	a0,0x7
    80000d28:	35450513          	addi	a0,a0,852 # 80008078 <etext+0x78>
    80000d2c:	00000097          	auipc	ra,0x0
    80000d30:	834080e7          	jalr	-1996(ra) # 80000560 <panic>

0000000080000d34 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d34:	1141                	addi	sp,sp,-16
    80000d36:	e422                	sd	s0,8(sp)
    80000d38:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d3a:	ca19                	beqz	a2,80000d50 <memset+0x1c>
    80000d3c:	87aa                	mv	a5,a0
    80000d3e:	1602                	slli	a2,a2,0x20
    80000d40:	9201                	srli	a2,a2,0x20
    80000d42:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d46:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d4a:	0785                	addi	a5,a5,1
    80000d4c:	fee79de3          	bne	a5,a4,80000d46 <memset+0x12>
  }
  return dst;
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	addi	sp,sp,16
    80000d54:	8082                	ret

0000000080000d56 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d56:	1141                	addi	sp,sp,-16
    80000d58:	e422                	sd	s0,8(sp)
    80000d5a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d5c:	ca05                	beqz	a2,80000d8c <memcmp+0x36>
    80000d5e:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d62:	1682                	slli	a3,a3,0x20
    80000d64:	9281                	srli	a3,a3,0x20
    80000d66:	0685                	addi	a3,a3,1
    80000d68:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d6a:	00054783          	lbu	a5,0(a0)
    80000d6e:	0005c703          	lbu	a4,0(a1)
    80000d72:	00e79863          	bne	a5,a4,80000d82 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d76:	0505                	addi	a0,a0,1
    80000d78:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d7a:	fed518e3          	bne	a0,a3,80000d6a <memcmp+0x14>
  }

  return 0;
    80000d7e:	4501                	li	a0,0
    80000d80:	a019                	j	80000d86 <memcmp+0x30>
      return *s1 - *s2;
    80000d82:	40e7853b          	subw	a0,a5,a4
}
    80000d86:	6422                	ld	s0,8(sp)
    80000d88:	0141                	addi	sp,sp,16
    80000d8a:	8082                	ret
  return 0;
    80000d8c:	4501                	li	a0,0
    80000d8e:	bfe5                	j	80000d86 <memcmp+0x30>

0000000080000d90 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d90:	1141                	addi	sp,sp,-16
    80000d92:	e422                	sd	s0,8(sp)
    80000d94:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d96:	c205                	beqz	a2,80000db6 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d98:	02a5e263          	bltu	a1,a0,80000dbc <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d9c:	1602                	slli	a2,a2,0x20
    80000d9e:	9201                	srli	a2,a2,0x20
    80000da0:	00c587b3          	add	a5,a1,a2
{
    80000da4:	872a                	mv	a4,a0
      *d++ = *s++;
    80000da6:	0585                	addi	a1,a1,1
    80000da8:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffda9f1>
    80000daa:	fff5c683          	lbu	a3,-1(a1)
    80000dae:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000db2:	feb79ae3          	bne	a5,a1,80000da6 <memmove+0x16>

  return dst;
}
    80000db6:	6422                	ld	s0,8(sp)
    80000db8:	0141                	addi	sp,sp,16
    80000dba:	8082                	ret
  if(s < d && s + n > d){
    80000dbc:	02061693          	slli	a3,a2,0x20
    80000dc0:	9281                	srli	a3,a3,0x20
    80000dc2:	00d58733          	add	a4,a1,a3
    80000dc6:	fce57be3          	bgeu	a0,a4,80000d9c <memmove+0xc>
    d += n;
    80000dca:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000dcc:	fff6079b          	addiw	a5,a2,-1
    80000dd0:	1782                	slli	a5,a5,0x20
    80000dd2:	9381                	srli	a5,a5,0x20
    80000dd4:	fff7c793          	not	a5,a5
    80000dd8:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000dda:	177d                	addi	a4,a4,-1
    80000ddc:	16fd                	addi	a3,a3,-1
    80000dde:	00074603          	lbu	a2,0(a4)
    80000de2:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000de6:	fef71ae3          	bne	a4,a5,80000dda <memmove+0x4a>
    80000dea:	b7f1                	j	80000db6 <memmove+0x26>

0000000080000dec <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dec:	1141                	addi	sp,sp,-16
    80000dee:	e406                	sd	ra,8(sp)
    80000df0:	e022                	sd	s0,0(sp)
    80000df2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000df4:	00000097          	auipc	ra,0x0
    80000df8:	f9c080e7          	jalr	-100(ra) # 80000d90 <memmove>
}
    80000dfc:	60a2                	ld	ra,8(sp)
    80000dfe:	6402                	ld	s0,0(sp)
    80000e00:	0141                	addi	sp,sp,16
    80000e02:	8082                	ret

0000000080000e04 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e04:	1141                	addi	sp,sp,-16
    80000e06:	e422                	sd	s0,8(sp)
    80000e08:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e0a:	ce11                	beqz	a2,80000e26 <strncmp+0x22>
    80000e0c:	00054783          	lbu	a5,0(a0)
    80000e10:	cf89                	beqz	a5,80000e2a <strncmp+0x26>
    80000e12:	0005c703          	lbu	a4,0(a1)
    80000e16:	00f71a63          	bne	a4,a5,80000e2a <strncmp+0x26>
    n--, p++, q++;
    80000e1a:	367d                	addiw	a2,a2,-1
    80000e1c:	0505                	addi	a0,a0,1
    80000e1e:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e20:	f675                	bnez	a2,80000e0c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e22:	4501                	li	a0,0
    80000e24:	a801                	j	80000e34 <strncmp+0x30>
    80000e26:	4501                	li	a0,0
    80000e28:	a031                	j	80000e34 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000e2a:	00054503          	lbu	a0,0(a0)
    80000e2e:	0005c783          	lbu	a5,0(a1)
    80000e32:	9d1d                	subw	a0,a0,a5
}
    80000e34:	6422                	ld	s0,8(sp)
    80000e36:	0141                	addi	sp,sp,16
    80000e38:	8082                	ret

0000000080000e3a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e3a:	1141                	addi	sp,sp,-16
    80000e3c:	e422                	sd	s0,8(sp)
    80000e3e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e40:	87aa                	mv	a5,a0
    80000e42:	86b2                	mv	a3,a2
    80000e44:	367d                	addiw	a2,a2,-1
    80000e46:	02d05563          	blez	a3,80000e70 <strncpy+0x36>
    80000e4a:	0785                	addi	a5,a5,1
    80000e4c:	0005c703          	lbu	a4,0(a1)
    80000e50:	fee78fa3          	sb	a4,-1(a5)
    80000e54:	0585                	addi	a1,a1,1
    80000e56:	f775                	bnez	a4,80000e42 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e58:	873e                	mv	a4,a5
    80000e5a:	9fb5                	addw	a5,a5,a3
    80000e5c:	37fd                	addiw	a5,a5,-1
    80000e5e:	00c05963          	blez	a2,80000e70 <strncpy+0x36>
    *s++ = 0;
    80000e62:	0705                	addi	a4,a4,1
    80000e64:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e68:	40e786bb          	subw	a3,a5,a4
    80000e6c:	fed04be3          	bgtz	a3,80000e62 <strncpy+0x28>
  return os;
}
    80000e70:	6422                	ld	s0,8(sp)
    80000e72:	0141                	addi	sp,sp,16
    80000e74:	8082                	ret

0000000080000e76 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e76:	1141                	addi	sp,sp,-16
    80000e78:	e422                	sd	s0,8(sp)
    80000e7a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e7c:	02c05363          	blez	a2,80000ea2 <safestrcpy+0x2c>
    80000e80:	fff6069b          	addiw	a3,a2,-1
    80000e84:	1682                	slli	a3,a3,0x20
    80000e86:	9281                	srli	a3,a3,0x20
    80000e88:	96ae                	add	a3,a3,a1
    80000e8a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e8c:	00d58963          	beq	a1,a3,80000e9e <safestrcpy+0x28>
    80000e90:	0585                	addi	a1,a1,1
    80000e92:	0785                	addi	a5,a5,1
    80000e94:	fff5c703          	lbu	a4,-1(a1)
    80000e98:	fee78fa3          	sb	a4,-1(a5)
    80000e9c:	fb65                	bnez	a4,80000e8c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e9e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ea2:	6422                	ld	s0,8(sp)
    80000ea4:	0141                	addi	sp,sp,16
    80000ea6:	8082                	ret

0000000080000ea8 <strlen>:

int
strlen(const char *s)
{
    80000ea8:	1141                	addi	sp,sp,-16
    80000eaa:	e422                	sd	s0,8(sp)
    80000eac:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000eae:	00054783          	lbu	a5,0(a0)
    80000eb2:	cf91                	beqz	a5,80000ece <strlen+0x26>
    80000eb4:	0505                	addi	a0,a0,1
    80000eb6:	87aa                	mv	a5,a0
    80000eb8:	86be                	mv	a3,a5
    80000eba:	0785                	addi	a5,a5,1
    80000ebc:	fff7c703          	lbu	a4,-1(a5)
    80000ec0:	ff65                	bnez	a4,80000eb8 <strlen+0x10>
    80000ec2:	40a6853b          	subw	a0,a3,a0
    80000ec6:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000ec8:	6422                	ld	s0,8(sp)
    80000eca:	0141                	addi	sp,sp,16
    80000ecc:	8082                	ret
  for(n = 0; s[n]; n++)
    80000ece:	4501                	li	a0,0
    80000ed0:	bfe5                	j	80000ec8 <strlen+0x20>

0000000080000ed2 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ed2:	1141                	addi	sp,sp,-16
    80000ed4:	e406                	sd	ra,8(sp)
    80000ed6:	e022                	sd	s0,0(sp)
    80000ed8:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000eda:	00001097          	auipc	ra,0x1
    80000ede:	b44080e7          	jalr	-1212(ra) # 80001a1e <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ee2:	0000a717          	auipc	a4,0xa
    80000ee6:	29670713          	addi	a4,a4,662 # 8000b178 <started>
  if(cpuid() == 0){
    80000eea:	c139                	beqz	a0,80000f30 <main+0x5e>
    while(started == 0)
    80000eec:	431c                	lw	a5,0(a4)
    80000eee:	2781                	sext.w	a5,a5
    80000ef0:	dff5                	beqz	a5,80000eec <main+0x1a>
      ;
    __sync_synchronize();
    80000ef2:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000ef6:	00001097          	auipc	ra,0x1
    80000efa:	b28080e7          	jalr	-1240(ra) # 80001a1e <cpuid>
    80000efe:	85aa                	mv	a1,a0
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	19850513          	addi	a0,a0,408 # 80008098 <etext+0x98>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	6a2080e7          	jalr	1698(ra) # 800005aa <printf>
    kvminithart();    // turn on paging
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	0d8080e7          	jalr	216(ra) # 80000fe8 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f18:	00001097          	auipc	ra,0x1
    80000f1c:	7d2080e7          	jalr	2002(ra) # 800026ea <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f20:	00005097          	auipc	ra,0x5
    80000f24:	e44080e7          	jalr	-444(ra) # 80005d64 <plicinithart>
  }

  scheduler();        
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	01a080e7          	jalr	26(ra) # 80001f42 <scheduler>
    consoleinit();
    80000f30:	fffff097          	auipc	ra,0xfffff
    80000f34:	540080e7          	jalr	1344(ra) # 80000470 <consoleinit>
    printfinit();
    80000f38:	00000097          	auipc	ra,0x0
    80000f3c:	87a080e7          	jalr	-1926(ra) # 800007b2 <printfinit>
    printf("\n");
    80000f40:	00007517          	auipc	a0,0x7
    80000f44:	0d050513          	addi	a0,a0,208 # 80008010 <etext+0x10>
    80000f48:	fffff097          	auipc	ra,0xfffff
    80000f4c:	662080e7          	jalr	1634(ra) # 800005aa <printf>
    printf("xv6 kernel is booting\n");
    80000f50:	00007517          	auipc	a0,0x7
    80000f54:	13050513          	addi	a0,a0,304 # 80008080 <etext+0x80>
    80000f58:	fffff097          	auipc	ra,0xfffff
    80000f5c:	652080e7          	jalr	1618(ra) # 800005aa <printf>
    printf("\n");
    80000f60:	00007517          	auipc	a0,0x7
    80000f64:	0b050513          	addi	a0,a0,176 # 80008010 <etext+0x10>
    80000f68:	fffff097          	auipc	ra,0xfffff
    80000f6c:	642080e7          	jalr	1602(ra) # 800005aa <printf>
    kinit();         // physical page allocator
    80000f70:	00000097          	auipc	ra,0x0
    80000f74:	b9c080e7          	jalr	-1124(ra) # 80000b0c <kinit>
    kvminit();       // create kernel page table
    80000f78:	00000097          	auipc	ra,0x0
    80000f7c:	326080e7          	jalr	806(ra) # 8000129e <kvminit>
    kvminithart();   // turn on paging
    80000f80:	00000097          	auipc	ra,0x0
    80000f84:	068080e7          	jalr	104(ra) # 80000fe8 <kvminithart>
    procinit();      // process table
    80000f88:	00001097          	auipc	ra,0x1
    80000f8c:	9d4080e7          	jalr	-1580(ra) # 8000195c <procinit>
    trapinit();      // trap vectors
    80000f90:	00001097          	auipc	ra,0x1
    80000f94:	732080e7          	jalr	1842(ra) # 800026c2 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f98:	00001097          	auipc	ra,0x1
    80000f9c:	752080e7          	jalr	1874(ra) # 800026ea <trapinithart>
    plicinit();      // set up interrupt controller
    80000fa0:	00005097          	auipc	ra,0x5
    80000fa4:	daa080e7          	jalr	-598(ra) # 80005d4a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa8:	00005097          	auipc	ra,0x5
    80000fac:	dbc080e7          	jalr	-580(ra) # 80005d64 <plicinithart>
    binit();         // buffer cache
    80000fb0:	00002097          	auipc	ra,0x2
    80000fb4:	e82080e7          	jalr	-382(ra) # 80002e32 <binit>
    iinit();         // inode table
    80000fb8:	00002097          	auipc	ra,0x2
    80000fbc:	538080e7          	jalr	1336(ra) # 800034f0 <iinit>
    fileinit();      // file table
    80000fc0:	00003097          	auipc	ra,0x3
    80000fc4:	4e8080e7          	jalr	1256(ra) # 800044a8 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fc8:	00005097          	auipc	ra,0x5
    80000fcc:	ea4080e7          	jalr	-348(ra) # 80005e6c <virtio_disk_init>
    userinit();      // first user process
    80000fd0:	00001097          	auipc	ra,0x1
    80000fd4:	d52080e7          	jalr	-686(ra) # 80001d22 <userinit>
    __sync_synchronize();
    80000fd8:	0330000f          	fence	rw,rw
    started = 1;
    80000fdc:	4785                	li	a5,1
    80000fde:	0000a717          	auipc	a4,0xa
    80000fe2:	18f72d23          	sw	a5,410(a4) # 8000b178 <started>
    80000fe6:	b789                	j	80000f28 <main+0x56>

0000000080000fe8 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fe8:	1141                	addi	sp,sp,-16
    80000fea:	e422                	sd	s0,8(sp)
    80000fec:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fee:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ff2:	0000a797          	auipc	a5,0xa
    80000ff6:	18e7b783          	ld	a5,398(a5) # 8000b180 <kernel_pagetable>
    80000ffa:	83b1                	srli	a5,a5,0xc
    80000ffc:	577d                	li	a4,-1
    80000ffe:	177e                	slli	a4,a4,0x3f
    80001000:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001002:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001006:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    8000100a:	6422                	ld	s0,8(sp)
    8000100c:	0141                	addi	sp,sp,16
    8000100e:	8082                	ret

0000000080001010 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001010:	7139                	addi	sp,sp,-64
    80001012:	fc06                	sd	ra,56(sp)
    80001014:	f822                	sd	s0,48(sp)
    80001016:	f426                	sd	s1,40(sp)
    80001018:	f04a                	sd	s2,32(sp)
    8000101a:	ec4e                	sd	s3,24(sp)
    8000101c:	e852                	sd	s4,16(sp)
    8000101e:	e456                	sd	s5,8(sp)
    80001020:	e05a                	sd	s6,0(sp)
    80001022:	0080                	addi	s0,sp,64
    80001024:	84aa                	mv	s1,a0
    80001026:	89ae                	mv	s3,a1
    80001028:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000102a:	57fd                	li	a5,-1
    8000102c:	83e9                	srli	a5,a5,0x1a
    8000102e:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001030:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001032:	04b7f263          	bgeu	a5,a1,80001076 <walk+0x66>
    panic("walk");
    80001036:	00007517          	auipc	a0,0x7
    8000103a:	07a50513          	addi	a0,a0,122 # 800080b0 <etext+0xb0>
    8000103e:	fffff097          	auipc	ra,0xfffff
    80001042:	522080e7          	jalr	1314(ra) # 80000560 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001046:	060a8663          	beqz	s5,800010b2 <walk+0xa2>
    8000104a:	00000097          	auipc	ra,0x0
    8000104e:	afe080e7          	jalr	-1282(ra) # 80000b48 <kalloc>
    80001052:	84aa                	mv	s1,a0
    80001054:	c529                	beqz	a0,8000109e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001056:	6605                	lui	a2,0x1
    80001058:	4581                	li	a1,0
    8000105a:	00000097          	auipc	ra,0x0
    8000105e:	cda080e7          	jalr	-806(ra) # 80000d34 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001062:	00c4d793          	srli	a5,s1,0xc
    80001066:	07aa                	slli	a5,a5,0xa
    80001068:	0017e793          	ori	a5,a5,1
    8000106c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001070:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffda9e7>
    80001072:	036a0063          	beq	s4,s6,80001092 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001076:	0149d933          	srl	s2,s3,s4
    8000107a:	1ff97913          	andi	s2,s2,511
    8000107e:	090e                	slli	s2,s2,0x3
    80001080:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001082:	00093483          	ld	s1,0(s2)
    80001086:	0014f793          	andi	a5,s1,1
    8000108a:	dfd5                	beqz	a5,80001046 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000108c:	80a9                	srli	s1,s1,0xa
    8000108e:	04b2                	slli	s1,s1,0xc
    80001090:	b7c5                	j	80001070 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001092:	00c9d513          	srli	a0,s3,0xc
    80001096:	1ff57513          	andi	a0,a0,511
    8000109a:	050e                	slli	a0,a0,0x3
    8000109c:	9526                	add	a0,a0,s1
}
    8000109e:	70e2                	ld	ra,56(sp)
    800010a0:	7442                	ld	s0,48(sp)
    800010a2:	74a2                	ld	s1,40(sp)
    800010a4:	7902                	ld	s2,32(sp)
    800010a6:	69e2                	ld	s3,24(sp)
    800010a8:	6a42                	ld	s4,16(sp)
    800010aa:	6aa2                	ld	s5,8(sp)
    800010ac:	6b02                	ld	s6,0(sp)
    800010ae:	6121                	addi	sp,sp,64
    800010b0:	8082                	ret
        return 0;
    800010b2:	4501                	li	a0,0
    800010b4:	b7ed                	j	8000109e <walk+0x8e>

00000000800010b6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010b6:	57fd                	li	a5,-1
    800010b8:	83e9                	srli	a5,a5,0x1a
    800010ba:	00b7f463          	bgeu	a5,a1,800010c2 <walkaddr+0xc>
    return 0;
    800010be:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010c0:	8082                	ret
{
    800010c2:	1141                	addi	sp,sp,-16
    800010c4:	e406                	sd	ra,8(sp)
    800010c6:	e022                	sd	s0,0(sp)
    800010c8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010ca:	4601                	li	a2,0
    800010cc:	00000097          	auipc	ra,0x0
    800010d0:	f44080e7          	jalr	-188(ra) # 80001010 <walk>
  if(pte == 0)
    800010d4:	c105                	beqz	a0,800010f4 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010d6:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010d8:	0117f693          	andi	a3,a5,17
    800010dc:	4745                	li	a4,17
    return 0;
    800010de:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010e0:	00e68663          	beq	a3,a4,800010ec <walkaddr+0x36>
}
    800010e4:	60a2                	ld	ra,8(sp)
    800010e6:	6402                	ld	s0,0(sp)
    800010e8:	0141                	addi	sp,sp,16
    800010ea:	8082                	ret
  pa = PTE2PA(*pte);
    800010ec:	83a9                	srli	a5,a5,0xa
    800010ee:	00c79513          	slli	a0,a5,0xc
  return pa;
    800010f2:	bfcd                	j	800010e4 <walkaddr+0x2e>
    return 0;
    800010f4:	4501                	li	a0,0
    800010f6:	b7fd                	j	800010e4 <walkaddr+0x2e>

00000000800010f8 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010f8:	715d                	addi	sp,sp,-80
    800010fa:	e486                	sd	ra,72(sp)
    800010fc:	e0a2                	sd	s0,64(sp)
    800010fe:	fc26                	sd	s1,56(sp)
    80001100:	f84a                	sd	s2,48(sp)
    80001102:	f44e                	sd	s3,40(sp)
    80001104:	f052                	sd	s4,32(sp)
    80001106:	ec56                	sd	s5,24(sp)
    80001108:	e85a                	sd	s6,16(sp)
    8000110a:	e45e                	sd	s7,8(sp)
    8000110c:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    8000110e:	c639                	beqz	a2,8000115c <mappages+0x64>
    80001110:	8aaa                	mv	s5,a0
    80001112:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001114:	777d                	lui	a4,0xfffff
    80001116:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000111a:	fff58993          	addi	s3,a1,-1
    8000111e:	99b2                	add	s3,s3,a2
    80001120:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001124:	893e                	mv	s2,a5
    80001126:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000112a:	6b85                	lui	s7,0x1
    8000112c:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001130:	4605                	li	a2,1
    80001132:	85ca                	mv	a1,s2
    80001134:	8556                	mv	a0,s5
    80001136:	00000097          	auipc	ra,0x0
    8000113a:	eda080e7          	jalr	-294(ra) # 80001010 <walk>
    8000113e:	cd1d                	beqz	a0,8000117c <mappages+0x84>
    if(*pte & PTE_V)
    80001140:	611c                	ld	a5,0(a0)
    80001142:	8b85                	andi	a5,a5,1
    80001144:	e785                	bnez	a5,8000116c <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001146:	80b1                	srli	s1,s1,0xc
    80001148:	04aa                	slli	s1,s1,0xa
    8000114a:	0164e4b3          	or	s1,s1,s6
    8000114e:	0014e493          	ori	s1,s1,1
    80001152:	e104                	sd	s1,0(a0)
    if(a == last)
    80001154:	05390063          	beq	s2,s3,80001194 <mappages+0x9c>
    a += PGSIZE;
    80001158:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000115a:	bfc9                	j	8000112c <mappages+0x34>
    panic("mappages: size");
    8000115c:	00007517          	auipc	a0,0x7
    80001160:	f5c50513          	addi	a0,a0,-164 # 800080b8 <etext+0xb8>
    80001164:	fffff097          	auipc	ra,0xfffff
    80001168:	3fc080e7          	jalr	1020(ra) # 80000560 <panic>
      panic("mappages: remap");
    8000116c:	00007517          	auipc	a0,0x7
    80001170:	f5c50513          	addi	a0,a0,-164 # 800080c8 <etext+0xc8>
    80001174:	fffff097          	auipc	ra,0xfffff
    80001178:	3ec080e7          	jalr	1004(ra) # 80000560 <panic>
      return -1;
    8000117c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000117e:	60a6                	ld	ra,72(sp)
    80001180:	6406                	ld	s0,64(sp)
    80001182:	74e2                	ld	s1,56(sp)
    80001184:	7942                	ld	s2,48(sp)
    80001186:	79a2                	ld	s3,40(sp)
    80001188:	7a02                	ld	s4,32(sp)
    8000118a:	6ae2                	ld	s5,24(sp)
    8000118c:	6b42                	ld	s6,16(sp)
    8000118e:	6ba2                	ld	s7,8(sp)
    80001190:	6161                	addi	sp,sp,80
    80001192:	8082                	ret
  return 0;
    80001194:	4501                	li	a0,0
    80001196:	b7e5                	j	8000117e <mappages+0x86>

0000000080001198 <kvmmap>:
{
    80001198:	1141                	addi	sp,sp,-16
    8000119a:	e406                	sd	ra,8(sp)
    8000119c:	e022                	sd	s0,0(sp)
    8000119e:	0800                	addi	s0,sp,16
    800011a0:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800011a2:	86b2                	mv	a3,a2
    800011a4:	863e                	mv	a2,a5
    800011a6:	00000097          	auipc	ra,0x0
    800011aa:	f52080e7          	jalr	-174(ra) # 800010f8 <mappages>
    800011ae:	e509                	bnez	a0,800011b8 <kvmmap+0x20>
}
    800011b0:	60a2                	ld	ra,8(sp)
    800011b2:	6402                	ld	s0,0(sp)
    800011b4:	0141                	addi	sp,sp,16
    800011b6:	8082                	ret
    panic("kvmmap");
    800011b8:	00007517          	auipc	a0,0x7
    800011bc:	f2050513          	addi	a0,a0,-224 # 800080d8 <etext+0xd8>
    800011c0:	fffff097          	auipc	ra,0xfffff
    800011c4:	3a0080e7          	jalr	928(ra) # 80000560 <panic>

00000000800011c8 <kvmmake>:
{
    800011c8:	1101                	addi	sp,sp,-32
    800011ca:	ec06                	sd	ra,24(sp)
    800011cc:	e822                	sd	s0,16(sp)
    800011ce:	e426                	sd	s1,8(sp)
    800011d0:	e04a                	sd	s2,0(sp)
    800011d2:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011d4:	00000097          	auipc	ra,0x0
    800011d8:	974080e7          	jalr	-1676(ra) # 80000b48 <kalloc>
    800011dc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011de:	6605                	lui	a2,0x1
    800011e0:	4581                	li	a1,0
    800011e2:	00000097          	auipc	ra,0x0
    800011e6:	b52080e7          	jalr	-1198(ra) # 80000d34 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011ea:	4719                	li	a4,6
    800011ec:	6685                	lui	a3,0x1
    800011ee:	10000637          	lui	a2,0x10000
    800011f2:	100005b7          	lui	a1,0x10000
    800011f6:	8526                	mv	a0,s1
    800011f8:	00000097          	auipc	ra,0x0
    800011fc:	fa0080e7          	jalr	-96(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001200:	4719                	li	a4,6
    80001202:	6685                	lui	a3,0x1
    80001204:	10001637          	lui	a2,0x10001
    80001208:	100015b7          	lui	a1,0x10001
    8000120c:	8526                	mv	a0,s1
    8000120e:	00000097          	auipc	ra,0x0
    80001212:	f8a080e7          	jalr	-118(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001216:	4719                	li	a4,6
    80001218:	004006b7          	lui	a3,0x400
    8000121c:	0c000637          	lui	a2,0xc000
    80001220:	0c0005b7          	lui	a1,0xc000
    80001224:	8526                	mv	a0,s1
    80001226:	00000097          	auipc	ra,0x0
    8000122a:	f72080e7          	jalr	-142(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000122e:	00007917          	auipc	s2,0x7
    80001232:	dd290913          	addi	s2,s2,-558 # 80008000 <etext>
    80001236:	4729                	li	a4,10
    80001238:	80007697          	auipc	a3,0x80007
    8000123c:	dc868693          	addi	a3,a3,-568 # 8000 <_entry-0x7fff8000>
    80001240:	4605                	li	a2,1
    80001242:	067e                	slli	a2,a2,0x1f
    80001244:	85b2                	mv	a1,a2
    80001246:	8526                	mv	a0,s1
    80001248:	00000097          	auipc	ra,0x0
    8000124c:	f50080e7          	jalr	-176(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001250:	46c5                	li	a3,17
    80001252:	06ee                	slli	a3,a3,0x1b
    80001254:	4719                	li	a4,6
    80001256:	412686b3          	sub	a3,a3,s2
    8000125a:	864a                	mv	a2,s2
    8000125c:	85ca                	mv	a1,s2
    8000125e:	8526                	mv	a0,s1
    80001260:	00000097          	auipc	ra,0x0
    80001264:	f38080e7          	jalr	-200(ra) # 80001198 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001268:	4729                	li	a4,10
    8000126a:	6685                	lui	a3,0x1
    8000126c:	00006617          	auipc	a2,0x6
    80001270:	d9460613          	addi	a2,a2,-620 # 80007000 <_trampoline>
    80001274:	040005b7          	lui	a1,0x4000
    80001278:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000127a:	05b2                	slli	a1,a1,0xc
    8000127c:	8526                	mv	a0,s1
    8000127e:	00000097          	auipc	ra,0x0
    80001282:	f1a080e7          	jalr	-230(ra) # 80001198 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001286:	8526                	mv	a0,s1
    80001288:	00000097          	auipc	ra,0x0
    8000128c:	630080e7          	jalr	1584(ra) # 800018b8 <proc_mapstacks>
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6902                	ld	s2,0(sp)
    8000129a:	6105                	addi	sp,sp,32
    8000129c:	8082                	ret

000000008000129e <kvminit>:
{
    8000129e:	1141                	addi	sp,sp,-16
    800012a0:	e406                	sd	ra,8(sp)
    800012a2:	e022                	sd	s0,0(sp)
    800012a4:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800012a6:	00000097          	auipc	ra,0x0
    800012aa:	f22080e7          	jalr	-222(ra) # 800011c8 <kvmmake>
    800012ae:	0000a797          	auipc	a5,0xa
    800012b2:	eca7b923          	sd	a0,-302(a5) # 8000b180 <kernel_pagetable>
}
    800012b6:	60a2                	ld	ra,8(sp)
    800012b8:	6402                	ld	s0,0(sp)
    800012ba:	0141                	addi	sp,sp,16
    800012bc:	8082                	ret

00000000800012be <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012be:	715d                	addi	sp,sp,-80
    800012c0:	e486                	sd	ra,72(sp)
    800012c2:	e0a2                	sd	s0,64(sp)
    800012c4:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012c6:	03459793          	slli	a5,a1,0x34
    800012ca:	e39d                	bnez	a5,800012f0 <uvmunmap+0x32>
    800012cc:	f84a                	sd	s2,48(sp)
    800012ce:	f44e                	sd	s3,40(sp)
    800012d0:	f052                	sd	s4,32(sp)
    800012d2:	ec56                	sd	s5,24(sp)
    800012d4:	e85a                	sd	s6,16(sp)
    800012d6:	e45e                	sd	s7,8(sp)
    800012d8:	8a2a                	mv	s4,a0
    800012da:	892e                	mv	s2,a1
    800012dc:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012de:	0632                	slli	a2,a2,0xc
    800012e0:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012e4:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e6:	6b05                	lui	s6,0x1
    800012e8:	0935fb63          	bgeu	a1,s3,8000137e <uvmunmap+0xc0>
    800012ec:	fc26                	sd	s1,56(sp)
    800012ee:	a8a9                	j	80001348 <uvmunmap+0x8a>
    800012f0:	fc26                	sd	s1,56(sp)
    800012f2:	f84a                	sd	s2,48(sp)
    800012f4:	f44e                	sd	s3,40(sp)
    800012f6:	f052                	sd	s4,32(sp)
    800012f8:	ec56                	sd	s5,24(sp)
    800012fa:	e85a                	sd	s6,16(sp)
    800012fc:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800012fe:	00007517          	auipc	a0,0x7
    80001302:	de250513          	addi	a0,a0,-542 # 800080e0 <etext+0xe0>
    80001306:	fffff097          	auipc	ra,0xfffff
    8000130a:	25a080e7          	jalr	602(ra) # 80000560 <panic>
      panic("uvmunmap: walk");
    8000130e:	00007517          	auipc	a0,0x7
    80001312:	dea50513          	addi	a0,a0,-534 # 800080f8 <etext+0xf8>
    80001316:	fffff097          	auipc	ra,0xfffff
    8000131a:	24a080e7          	jalr	586(ra) # 80000560 <panic>
      panic("uvmunmap: not mapped");
    8000131e:	00007517          	auipc	a0,0x7
    80001322:	dea50513          	addi	a0,a0,-534 # 80008108 <etext+0x108>
    80001326:	fffff097          	auipc	ra,0xfffff
    8000132a:	23a080e7          	jalr	570(ra) # 80000560 <panic>
      panic("uvmunmap: not a leaf");
    8000132e:	00007517          	auipc	a0,0x7
    80001332:	df250513          	addi	a0,a0,-526 # 80008120 <etext+0x120>
    80001336:	fffff097          	auipc	ra,0xfffff
    8000133a:	22a080e7          	jalr	554(ra) # 80000560 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000133e:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001342:	995a                	add	s2,s2,s6
    80001344:	03397c63          	bgeu	s2,s3,8000137c <uvmunmap+0xbe>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001348:	4601                	li	a2,0
    8000134a:	85ca                	mv	a1,s2
    8000134c:	8552                	mv	a0,s4
    8000134e:	00000097          	auipc	ra,0x0
    80001352:	cc2080e7          	jalr	-830(ra) # 80001010 <walk>
    80001356:	84aa                	mv	s1,a0
    80001358:	d95d                	beqz	a0,8000130e <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)
    8000135a:	6108                	ld	a0,0(a0)
    8000135c:	00157793          	andi	a5,a0,1
    80001360:	dfdd                	beqz	a5,8000131e <uvmunmap+0x60>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001362:	3ff57793          	andi	a5,a0,1023
    80001366:	fd7784e3          	beq	a5,s7,8000132e <uvmunmap+0x70>
    if(do_free){
    8000136a:	fc0a8ae3          	beqz	s5,8000133e <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    8000136e:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001370:	0532                	slli	a0,a0,0xc
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	6d8080e7          	jalr	1752(ra) # 80000a4a <kfree>
    8000137a:	b7d1                	j	8000133e <uvmunmap+0x80>
    8000137c:	74e2                	ld	s1,56(sp)
    8000137e:	7942                	ld	s2,48(sp)
    80001380:	79a2                	ld	s3,40(sp)
    80001382:	7a02                	ld	s4,32(sp)
    80001384:	6ae2                	ld	s5,24(sp)
    80001386:	6b42                	ld	s6,16(sp)
    80001388:	6ba2                	ld	s7,8(sp)
  }
}
    8000138a:	60a6                	ld	ra,72(sp)
    8000138c:	6406                	ld	s0,64(sp)
    8000138e:	6161                	addi	sp,sp,80
    80001390:	8082                	ret

0000000080001392 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001392:	1101                	addi	sp,sp,-32
    80001394:	ec06                	sd	ra,24(sp)
    80001396:	e822                	sd	s0,16(sp)
    80001398:	e426                	sd	s1,8(sp)
    8000139a:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000139c:	fffff097          	auipc	ra,0xfffff
    800013a0:	7ac080e7          	jalr	1964(ra) # 80000b48 <kalloc>
    800013a4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013a6:	c519                	beqz	a0,800013b4 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013a8:	6605                	lui	a2,0x1
    800013aa:	4581                	li	a1,0
    800013ac:	00000097          	auipc	ra,0x0
    800013b0:	988080e7          	jalr	-1656(ra) # 80000d34 <memset>
  return pagetable;
}
    800013b4:	8526                	mv	a0,s1
    800013b6:	60e2                	ld	ra,24(sp)
    800013b8:	6442                	ld	s0,16(sp)
    800013ba:	64a2                	ld	s1,8(sp)
    800013bc:	6105                	addi	sp,sp,32
    800013be:	8082                	ret

00000000800013c0 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800013c0:	7179                	addi	sp,sp,-48
    800013c2:	f406                	sd	ra,40(sp)
    800013c4:	f022                	sd	s0,32(sp)
    800013c6:	ec26                	sd	s1,24(sp)
    800013c8:	e84a                	sd	s2,16(sp)
    800013ca:	e44e                	sd	s3,8(sp)
    800013cc:	e052                	sd	s4,0(sp)
    800013ce:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013d0:	6785                	lui	a5,0x1
    800013d2:	04f67863          	bgeu	a2,a5,80001422 <uvmfirst+0x62>
    800013d6:	8a2a                	mv	s4,a0
    800013d8:	89ae                	mv	s3,a1
    800013da:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800013dc:	fffff097          	auipc	ra,0xfffff
    800013e0:	76c080e7          	jalr	1900(ra) # 80000b48 <kalloc>
    800013e4:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013e6:	6605                	lui	a2,0x1
    800013e8:	4581                	li	a1,0
    800013ea:	00000097          	auipc	ra,0x0
    800013ee:	94a080e7          	jalr	-1718(ra) # 80000d34 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013f2:	4779                	li	a4,30
    800013f4:	86ca                	mv	a3,s2
    800013f6:	6605                	lui	a2,0x1
    800013f8:	4581                	li	a1,0
    800013fa:	8552                	mv	a0,s4
    800013fc:	00000097          	auipc	ra,0x0
    80001400:	cfc080e7          	jalr	-772(ra) # 800010f8 <mappages>
  memmove(mem, src, sz);
    80001404:	8626                	mv	a2,s1
    80001406:	85ce                	mv	a1,s3
    80001408:	854a                	mv	a0,s2
    8000140a:	00000097          	auipc	ra,0x0
    8000140e:	986080e7          	jalr	-1658(ra) # 80000d90 <memmove>
}
    80001412:	70a2                	ld	ra,40(sp)
    80001414:	7402                	ld	s0,32(sp)
    80001416:	64e2                	ld	s1,24(sp)
    80001418:	6942                	ld	s2,16(sp)
    8000141a:	69a2                	ld	s3,8(sp)
    8000141c:	6a02                	ld	s4,0(sp)
    8000141e:	6145                	addi	sp,sp,48
    80001420:	8082                	ret
    panic("uvmfirst: more than a page");
    80001422:	00007517          	auipc	a0,0x7
    80001426:	d1650513          	addi	a0,a0,-746 # 80008138 <etext+0x138>
    8000142a:	fffff097          	auipc	ra,0xfffff
    8000142e:	136080e7          	jalr	310(ra) # 80000560 <panic>

0000000080001432 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001432:	1101                	addi	sp,sp,-32
    80001434:	ec06                	sd	ra,24(sp)
    80001436:	e822                	sd	s0,16(sp)
    80001438:	e426                	sd	s1,8(sp)
    8000143a:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000143c:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000143e:	00b67d63          	bgeu	a2,a1,80001458 <uvmdealloc+0x26>
    80001442:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001444:	6785                	lui	a5,0x1
    80001446:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001448:	00f60733          	add	a4,a2,a5
    8000144c:	76fd                	lui	a3,0xfffff
    8000144e:	8f75                	and	a4,a4,a3
    80001450:	97ae                	add	a5,a5,a1
    80001452:	8ff5                	and	a5,a5,a3
    80001454:	00f76863          	bltu	a4,a5,80001464 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001458:	8526                	mv	a0,s1
    8000145a:	60e2                	ld	ra,24(sp)
    8000145c:	6442                	ld	s0,16(sp)
    8000145e:	64a2                	ld	s1,8(sp)
    80001460:	6105                	addi	sp,sp,32
    80001462:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001464:	8f99                	sub	a5,a5,a4
    80001466:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001468:	4685                	li	a3,1
    8000146a:	0007861b          	sext.w	a2,a5
    8000146e:	85ba                	mv	a1,a4
    80001470:	00000097          	auipc	ra,0x0
    80001474:	e4e080e7          	jalr	-434(ra) # 800012be <uvmunmap>
    80001478:	b7c5                	j	80001458 <uvmdealloc+0x26>

000000008000147a <uvmalloc>:
  if(newsz < oldsz)
    8000147a:	0ab66b63          	bltu	a2,a1,80001530 <uvmalloc+0xb6>
{
    8000147e:	7139                	addi	sp,sp,-64
    80001480:	fc06                	sd	ra,56(sp)
    80001482:	f822                	sd	s0,48(sp)
    80001484:	ec4e                	sd	s3,24(sp)
    80001486:	e852                	sd	s4,16(sp)
    80001488:	e456                	sd	s5,8(sp)
    8000148a:	0080                	addi	s0,sp,64
    8000148c:	8aaa                	mv	s5,a0
    8000148e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001490:	6785                	lui	a5,0x1
    80001492:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001494:	95be                	add	a1,a1,a5
    80001496:	77fd                	lui	a5,0xfffff
    80001498:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000149c:	08c9fc63          	bgeu	s3,a2,80001534 <uvmalloc+0xba>
    800014a0:	f426                	sd	s1,40(sp)
    800014a2:	f04a                	sd	s2,32(sp)
    800014a4:	e05a                	sd	s6,0(sp)
    800014a6:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014a8:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800014ac:	fffff097          	auipc	ra,0xfffff
    800014b0:	69c080e7          	jalr	1692(ra) # 80000b48 <kalloc>
    800014b4:	84aa                	mv	s1,a0
    if(mem == 0){
    800014b6:	c915                	beqz	a0,800014ea <uvmalloc+0x70>
    memset(mem, 0, PGSIZE);
    800014b8:	6605                	lui	a2,0x1
    800014ba:	4581                	li	a1,0
    800014bc:	00000097          	auipc	ra,0x0
    800014c0:	878080e7          	jalr	-1928(ra) # 80000d34 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014c4:	875a                	mv	a4,s6
    800014c6:	86a6                	mv	a3,s1
    800014c8:	6605                	lui	a2,0x1
    800014ca:	85ca                	mv	a1,s2
    800014cc:	8556                	mv	a0,s5
    800014ce:	00000097          	auipc	ra,0x0
    800014d2:	c2a080e7          	jalr	-982(ra) # 800010f8 <mappages>
    800014d6:	ed05                	bnez	a0,8000150e <uvmalloc+0x94>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014d8:	6785                	lui	a5,0x1
    800014da:	993e                	add	s2,s2,a5
    800014dc:	fd4968e3          	bltu	s2,s4,800014ac <uvmalloc+0x32>
  return newsz;
    800014e0:	8552                	mv	a0,s4
    800014e2:	74a2                	ld	s1,40(sp)
    800014e4:	7902                	ld	s2,32(sp)
    800014e6:	6b02                	ld	s6,0(sp)
    800014e8:	a821                	j	80001500 <uvmalloc+0x86>
      uvmdealloc(pagetable, a, oldsz);
    800014ea:	864e                	mv	a2,s3
    800014ec:	85ca                	mv	a1,s2
    800014ee:	8556                	mv	a0,s5
    800014f0:	00000097          	auipc	ra,0x0
    800014f4:	f42080e7          	jalr	-190(ra) # 80001432 <uvmdealloc>
      return 0;
    800014f8:	4501                	li	a0,0
    800014fa:	74a2                	ld	s1,40(sp)
    800014fc:	7902                	ld	s2,32(sp)
    800014fe:	6b02                	ld	s6,0(sp)
}
    80001500:	70e2                	ld	ra,56(sp)
    80001502:	7442                	ld	s0,48(sp)
    80001504:	69e2                	ld	s3,24(sp)
    80001506:	6a42                	ld	s4,16(sp)
    80001508:	6aa2                	ld	s5,8(sp)
    8000150a:	6121                	addi	sp,sp,64
    8000150c:	8082                	ret
      kfree(mem);
    8000150e:	8526                	mv	a0,s1
    80001510:	fffff097          	auipc	ra,0xfffff
    80001514:	53a080e7          	jalr	1338(ra) # 80000a4a <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001518:	864e                	mv	a2,s3
    8000151a:	85ca                	mv	a1,s2
    8000151c:	8556                	mv	a0,s5
    8000151e:	00000097          	auipc	ra,0x0
    80001522:	f14080e7          	jalr	-236(ra) # 80001432 <uvmdealloc>
      return 0;
    80001526:	4501                	li	a0,0
    80001528:	74a2                	ld	s1,40(sp)
    8000152a:	7902                	ld	s2,32(sp)
    8000152c:	6b02                	ld	s6,0(sp)
    8000152e:	bfc9                	j	80001500 <uvmalloc+0x86>
    return oldsz;
    80001530:	852e                	mv	a0,a1
}
    80001532:	8082                	ret
  return newsz;
    80001534:	8532                	mv	a0,a2
    80001536:	b7e9                	j	80001500 <uvmalloc+0x86>

0000000080001538 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001538:	7179                	addi	sp,sp,-48
    8000153a:	f406                	sd	ra,40(sp)
    8000153c:	f022                	sd	s0,32(sp)
    8000153e:	ec26                	sd	s1,24(sp)
    80001540:	e84a                	sd	s2,16(sp)
    80001542:	e44e                	sd	s3,8(sp)
    80001544:	e052                	sd	s4,0(sp)
    80001546:	1800                	addi	s0,sp,48
    80001548:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000154a:	84aa                	mv	s1,a0
    8000154c:	6905                	lui	s2,0x1
    8000154e:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001550:	4985                	li	s3,1
    80001552:	a829                	j	8000156c <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001554:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001556:	00c79513          	slli	a0,a5,0xc
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	fde080e7          	jalr	-34(ra) # 80001538 <freewalk>
      pagetable[i] = 0;
    80001562:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001566:	04a1                	addi	s1,s1,8
    80001568:	03248163          	beq	s1,s2,8000158a <freewalk+0x52>
    pte_t pte = pagetable[i];
    8000156c:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000156e:	00f7f713          	andi	a4,a5,15
    80001572:	ff3701e3          	beq	a4,s3,80001554 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001576:	8b85                	andi	a5,a5,1
    80001578:	d7fd                	beqz	a5,80001566 <freewalk+0x2e>
      panic("freewalk: leaf");
    8000157a:	00007517          	auipc	a0,0x7
    8000157e:	bde50513          	addi	a0,a0,-1058 # 80008158 <etext+0x158>
    80001582:	fffff097          	auipc	ra,0xfffff
    80001586:	fde080e7          	jalr	-34(ra) # 80000560 <panic>
    }
  }
  kfree((void*)pagetable);
    8000158a:	8552                	mv	a0,s4
    8000158c:	fffff097          	auipc	ra,0xfffff
    80001590:	4be080e7          	jalr	1214(ra) # 80000a4a <kfree>
}
    80001594:	70a2                	ld	ra,40(sp)
    80001596:	7402                	ld	s0,32(sp)
    80001598:	64e2                	ld	s1,24(sp)
    8000159a:	6942                	ld	s2,16(sp)
    8000159c:	69a2                	ld	s3,8(sp)
    8000159e:	6a02                	ld	s4,0(sp)
    800015a0:	6145                	addi	sp,sp,48
    800015a2:	8082                	ret

00000000800015a4 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015a4:	1101                	addi	sp,sp,-32
    800015a6:	ec06                	sd	ra,24(sp)
    800015a8:	e822                	sd	s0,16(sp)
    800015aa:	e426                	sd	s1,8(sp)
    800015ac:	1000                	addi	s0,sp,32
    800015ae:	84aa                	mv	s1,a0
  if(sz > 0)
    800015b0:	e999                	bnez	a1,800015c6 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015b2:	8526                	mv	a0,s1
    800015b4:	00000097          	auipc	ra,0x0
    800015b8:	f84080e7          	jalr	-124(ra) # 80001538 <freewalk>
}
    800015bc:	60e2                	ld	ra,24(sp)
    800015be:	6442                	ld	s0,16(sp)
    800015c0:	64a2                	ld	s1,8(sp)
    800015c2:	6105                	addi	sp,sp,32
    800015c4:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015c6:	6785                	lui	a5,0x1
    800015c8:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015ca:	95be                	add	a1,a1,a5
    800015cc:	4685                	li	a3,1
    800015ce:	00c5d613          	srli	a2,a1,0xc
    800015d2:	4581                	li	a1,0
    800015d4:	00000097          	auipc	ra,0x0
    800015d8:	cea080e7          	jalr	-790(ra) # 800012be <uvmunmap>
    800015dc:	bfd9                	j	800015b2 <uvmfree+0xe>

00000000800015de <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015de:	c679                	beqz	a2,800016ac <uvmcopy+0xce>
{
    800015e0:	715d                	addi	sp,sp,-80
    800015e2:	e486                	sd	ra,72(sp)
    800015e4:	e0a2                	sd	s0,64(sp)
    800015e6:	fc26                	sd	s1,56(sp)
    800015e8:	f84a                	sd	s2,48(sp)
    800015ea:	f44e                	sd	s3,40(sp)
    800015ec:	f052                	sd	s4,32(sp)
    800015ee:	ec56                	sd	s5,24(sp)
    800015f0:	e85a                	sd	s6,16(sp)
    800015f2:	e45e                	sd	s7,8(sp)
    800015f4:	0880                	addi	s0,sp,80
    800015f6:	8b2a                	mv	s6,a0
    800015f8:	8aae                	mv	s5,a1
    800015fa:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015fc:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015fe:	4601                	li	a2,0
    80001600:	85ce                	mv	a1,s3
    80001602:	855a                	mv	a0,s6
    80001604:	00000097          	auipc	ra,0x0
    80001608:	a0c080e7          	jalr	-1524(ra) # 80001010 <walk>
    8000160c:	c531                	beqz	a0,80001658 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000160e:	6118                	ld	a4,0(a0)
    80001610:	00177793          	andi	a5,a4,1
    80001614:	cbb1                	beqz	a5,80001668 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001616:	00a75593          	srli	a1,a4,0xa
    8000161a:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000161e:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001622:	fffff097          	auipc	ra,0xfffff
    80001626:	526080e7          	jalr	1318(ra) # 80000b48 <kalloc>
    8000162a:	892a                	mv	s2,a0
    8000162c:	c939                	beqz	a0,80001682 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000162e:	6605                	lui	a2,0x1
    80001630:	85de                	mv	a1,s7
    80001632:	fffff097          	auipc	ra,0xfffff
    80001636:	75e080e7          	jalr	1886(ra) # 80000d90 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000163a:	8726                	mv	a4,s1
    8000163c:	86ca                	mv	a3,s2
    8000163e:	6605                	lui	a2,0x1
    80001640:	85ce                	mv	a1,s3
    80001642:	8556                	mv	a0,s5
    80001644:	00000097          	auipc	ra,0x0
    80001648:	ab4080e7          	jalr	-1356(ra) # 800010f8 <mappages>
    8000164c:	e515                	bnez	a0,80001678 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000164e:	6785                	lui	a5,0x1
    80001650:	99be                	add	s3,s3,a5
    80001652:	fb49e6e3          	bltu	s3,s4,800015fe <uvmcopy+0x20>
    80001656:	a081                	j	80001696 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001658:	00007517          	auipc	a0,0x7
    8000165c:	b1050513          	addi	a0,a0,-1264 # 80008168 <etext+0x168>
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	f00080e7          	jalr	-256(ra) # 80000560 <panic>
      panic("uvmcopy: page not present");
    80001668:	00007517          	auipc	a0,0x7
    8000166c:	b2050513          	addi	a0,a0,-1248 # 80008188 <etext+0x188>
    80001670:	fffff097          	auipc	ra,0xfffff
    80001674:	ef0080e7          	jalr	-272(ra) # 80000560 <panic>
      kfree(mem);
    80001678:	854a                	mv	a0,s2
    8000167a:	fffff097          	auipc	ra,0xfffff
    8000167e:	3d0080e7          	jalr	976(ra) # 80000a4a <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001682:	4685                	li	a3,1
    80001684:	00c9d613          	srli	a2,s3,0xc
    80001688:	4581                	li	a1,0
    8000168a:	8556                	mv	a0,s5
    8000168c:	00000097          	auipc	ra,0x0
    80001690:	c32080e7          	jalr	-974(ra) # 800012be <uvmunmap>
  return -1;
    80001694:	557d                	li	a0,-1
}
    80001696:	60a6                	ld	ra,72(sp)
    80001698:	6406                	ld	s0,64(sp)
    8000169a:	74e2                	ld	s1,56(sp)
    8000169c:	7942                	ld	s2,48(sp)
    8000169e:	79a2                	ld	s3,40(sp)
    800016a0:	7a02                	ld	s4,32(sp)
    800016a2:	6ae2                	ld	s5,24(sp)
    800016a4:	6b42                	ld	s6,16(sp)
    800016a6:	6ba2                	ld	s7,8(sp)
    800016a8:	6161                	addi	sp,sp,80
    800016aa:	8082                	ret
  return 0;
    800016ac:	4501                	li	a0,0
}
    800016ae:	8082                	ret

00000000800016b0 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016b0:	1141                	addi	sp,sp,-16
    800016b2:	e406                	sd	ra,8(sp)
    800016b4:	e022                	sd	s0,0(sp)
    800016b6:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016b8:	4601                	li	a2,0
    800016ba:	00000097          	auipc	ra,0x0
    800016be:	956080e7          	jalr	-1706(ra) # 80001010 <walk>
  if(pte == 0)
    800016c2:	c901                	beqz	a0,800016d2 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016c4:	611c                	ld	a5,0(a0)
    800016c6:	9bbd                	andi	a5,a5,-17
    800016c8:	e11c                	sd	a5,0(a0)
}
    800016ca:	60a2                	ld	ra,8(sp)
    800016cc:	6402                	ld	s0,0(sp)
    800016ce:	0141                	addi	sp,sp,16
    800016d0:	8082                	ret
    panic("uvmclear");
    800016d2:	00007517          	auipc	a0,0x7
    800016d6:	ad650513          	addi	a0,a0,-1322 # 800081a8 <etext+0x1a8>
    800016da:	fffff097          	auipc	ra,0xfffff
    800016de:	e86080e7          	jalr	-378(ra) # 80000560 <panic>

00000000800016e2 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016e2:	c6bd                	beqz	a3,80001750 <copyout+0x6e>
{
    800016e4:	715d                	addi	sp,sp,-80
    800016e6:	e486                	sd	ra,72(sp)
    800016e8:	e0a2                	sd	s0,64(sp)
    800016ea:	fc26                	sd	s1,56(sp)
    800016ec:	f84a                	sd	s2,48(sp)
    800016ee:	f44e                	sd	s3,40(sp)
    800016f0:	f052                	sd	s4,32(sp)
    800016f2:	ec56                	sd	s5,24(sp)
    800016f4:	e85a                	sd	s6,16(sp)
    800016f6:	e45e                	sd	s7,8(sp)
    800016f8:	e062                	sd	s8,0(sp)
    800016fa:	0880                	addi	s0,sp,80
    800016fc:	8b2a                	mv	s6,a0
    800016fe:	8c2e                	mv	s8,a1
    80001700:	8a32                	mv	s4,a2
    80001702:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001704:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001706:	6a85                	lui	s5,0x1
    80001708:	a015                	j	8000172c <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000170a:	9562                	add	a0,a0,s8
    8000170c:	0004861b          	sext.w	a2,s1
    80001710:	85d2                	mv	a1,s4
    80001712:	41250533          	sub	a0,a0,s2
    80001716:	fffff097          	auipc	ra,0xfffff
    8000171a:	67a080e7          	jalr	1658(ra) # 80000d90 <memmove>

    len -= n;
    8000171e:	409989b3          	sub	s3,s3,s1
    src += n;
    80001722:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001724:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001728:	02098263          	beqz	s3,8000174c <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000172c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001730:	85ca                	mv	a1,s2
    80001732:	855a                	mv	a0,s6
    80001734:	00000097          	auipc	ra,0x0
    80001738:	982080e7          	jalr	-1662(ra) # 800010b6 <walkaddr>
    if(pa0 == 0)
    8000173c:	cd01                	beqz	a0,80001754 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000173e:	418904b3          	sub	s1,s2,s8
    80001742:	94d6                	add	s1,s1,s5
    if(n > len)
    80001744:	fc99f3e3          	bgeu	s3,s1,8000170a <copyout+0x28>
    80001748:	84ce                	mv	s1,s3
    8000174a:	b7c1                	j	8000170a <copyout+0x28>
  }
  return 0;
    8000174c:	4501                	li	a0,0
    8000174e:	a021                	j	80001756 <copyout+0x74>
    80001750:	4501                	li	a0,0
}
    80001752:	8082                	ret
      return -1;
    80001754:	557d                	li	a0,-1
}
    80001756:	60a6                	ld	ra,72(sp)
    80001758:	6406                	ld	s0,64(sp)
    8000175a:	74e2                	ld	s1,56(sp)
    8000175c:	7942                	ld	s2,48(sp)
    8000175e:	79a2                	ld	s3,40(sp)
    80001760:	7a02                	ld	s4,32(sp)
    80001762:	6ae2                	ld	s5,24(sp)
    80001764:	6b42                	ld	s6,16(sp)
    80001766:	6ba2                	ld	s7,8(sp)
    80001768:	6c02                	ld	s8,0(sp)
    8000176a:	6161                	addi	sp,sp,80
    8000176c:	8082                	ret

000000008000176e <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000176e:	caa5                	beqz	a3,800017de <copyin+0x70>
{
    80001770:	715d                	addi	sp,sp,-80
    80001772:	e486                	sd	ra,72(sp)
    80001774:	e0a2                	sd	s0,64(sp)
    80001776:	fc26                	sd	s1,56(sp)
    80001778:	f84a                	sd	s2,48(sp)
    8000177a:	f44e                	sd	s3,40(sp)
    8000177c:	f052                	sd	s4,32(sp)
    8000177e:	ec56                	sd	s5,24(sp)
    80001780:	e85a                	sd	s6,16(sp)
    80001782:	e45e                	sd	s7,8(sp)
    80001784:	e062                	sd	s8,0(sp)
    80001786:	0880                	addi	s0,sp,80
    80001788:	8b2a                	mv	s6,a0
    8000178a:	8a2e                	mv	s4,a1
    8000178c:	8c32                	mv	s8,a2
    8000178e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001790:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001792:	6a85                	lui	s5,0x1
    80001794:	a01d                	j	800017ba <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001796:	018505b3          	add	a1,a0,s8
    8000179a:	0004861b          	sext.w	a2,s1
    8000179e:	412585b3          	sub	a1,a1,s2
    800017a2:	8552                	mv	a0,s4
    800017a4:	fffff097          	auipc	ra,0xfffff
    800017a8:	5ec080e7          	jalr	1516(ra) # 80000d90 <memmove>

    len -= n;
    800017ac:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017b0:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017b2:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017b6:	02098263          	beqz	s3,800017da <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017ba:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017be:	85ca                	mv	a1,s2
    800017c0:	855a                	mv	a0,s6
    800017c2:	00000097          	auipc	ra,0x0
    800017c6:	8f4080e7          	jalr	-1804(ra) # 800010b6 <walkaddr>
    if(pa0 == 0)
    800017ca:	cd01                	beqz	a0,800017e2 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017cc:	418904b3          	sub	s1,s2,s8
    800017d0:	94d6                	add	s1,s1,s5
    if(n > len)
    800017d2:	fc99f2e3          	bgeu	s3,s1,80001796 <copyin+0x28>
    800017d6:	84ce                	mv	s1,s3
    800017d8:	bf7d                	j	80001796 <copyin+0x28>
  }
  return 0;
    800017da:	4501                	li	a0,0
    800017dc:	a021                	j	800017e4 <copyin+0x76>
    800017de:	4501                	li	a0,0
}
    800017e0:	8082                	ret
      return -1;
    800017e2:	557d                	li	a0,-1
}
    800017e4:	60a6                	ld	ra,72(sp)
    800017e6:	6406                	ld	s0,64(sp)
    800017e8:	74e2                	ld	s1,56(sp)
    800017ea:	7942                	ld	s2,48(sp)
    800017ec:	79a2                	ld	s3,40(sp)
    800017ee:	7a02                	ld	s4,32(sp)
    800017f0:	6ae2                	ld	s5,24(sp)
    800017f2:	6b42                	ld	s6,16(sp)
    800017f4:	6ba2                	ld	s7,8(sp)
    800017f6:	6c02                	ld	s8,0(sp)
    800017f8:	6161                	addi	sp,sp,80
    800017fa:	8082                	ret

00000000800017fc <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017fc:	cacd                	beqz	a3,800018ae <copyinstr+0xb2>
{
    800017fe:	715d                	addi	sp,sp,-80
    80001800:	e486                	sd	ra,72(sp)
    80001802:	e0a2                	sd	s0,64(sp)
    80001804:	fc26                	sd	s1,56(sp)
    80001806:	f84a                	sd	s2,48(sp)
    80001808:	f44e                	sd	s3,40(sp)
    8000180a:	f052                	sd	s4,32(sp)
    8000180c:	ec56                	sd	s5,24(sp)
    8000180e:	e85a                	sd	s6,16(sp)
    80001810:	e45e                	sd	s7,8(sp)
    80001812:	0880                	addi	s0,sp,80
    80001814:	8a2a                	mv	s4,a0
    80001816:	8b2e                	mv	s6,a1
    80001818:	8bb2                	mv	s7,a2
    8000181a:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    8000181c:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000181e:	6985                	lui	s3,0x1
    80001820:	a825                	j	80001858 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001822:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001826:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001828:	37fd                	addiw	a5,a5,-1
    8000182a:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000182e:	60a6                	ld	ra,72(sp)
    80001830:	6406                	ld	s0,64(sp)
    80001832:	74e2                	ld	s1,56(sp)
    80001834:	7942                	ld	s2,48(sp)
    80001836:	79a2                	ld	s3,40(sp)
    80001838:	7a02                	ld	s4,32(sp)
    8000183a:	6ae2                	ld	s5,24(sp)
    8000183c:	6b42                	ld	s6,16(sp)
    8000183e:	6ba2                	ld	s7,8(sp)
    80001840:	6161                	addi	sp,sp,80
    80001842:	8082                	ret
    80001844:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001848:	9742                	add	a4,a4,a6
      --max;
    8000184a:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    8000184e:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001852:	04e58663          	beq	a1,a4,8000189e <copyinstr+0xa2>
{
    80001856:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80001858:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000185c:	85a6                	mv	a1,s1
    8000185e:	8552                	mv	a0,s4
    80001860:	00000097          	auipc	ra,0x0
    80001864:	856080e7          	jalr	-1962(ra) # 800010b6 <walkaddr>
    if(pa0 == 0)
    80001868:	cd0d                	beqz	a0,800018a2 <copyinstr+0xa6>
    n = PGSIZE - (srcva - va0);
    8000186a:	417486b3          	sub	a3,s1,s7
    8000186e:	96ce                	add	a3,a3,s3
    if(n > max)
    80001870:	00d97363          	bgeu	s2,a3,80001876 <copyinstr+0x7a>
    80001874:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001876:	955e                	add	a0,a0,s7
    80001878:	8d05                	sub	a0,a0,s1
    while(n > 0){
    8000187a:	c695                	beqz	a3,800018a6 <copyinstr+0xaa>
    8000187c:	87da                	mv	a5,s6
    8000187e:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001880:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001884:	96da                	add	a3,a3,s6
    80001886:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001888:	00f60733          	add	a4,a2,a5
    8000188c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffda9f0>
    80001890:	db49                	beqz	a4,80001822 <copyinstr+0x26>
        *dst = *p;
    80001892:	00e78023          	sb	a4,0(a5)
      dst++;
    80001896:	0785                	addi	a5,a5,1
    while(n > 0){
    80001898:	fed797e3          	bne	a5,a3,80001886 <copyinstr+0x8a>
    8000189c:	b765                	j	80001844 <copyinstr+0x48>
    8000189e:	4781                	li	a5,0
    800018a0:	b761                	j	80001828 <copyinstr+0x2c>
      return -1;
    800018a2:	557d                	li	a0,-1
    800018a4:	b769                	j	8000182e <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    800018a6:	6b85                	lui	s7,0x1
    800018a8:	9ba6                	add	s7,s7,s1
    800018aa:	87da                	mv	a5,s6
    800018ac:	b76d                	j	80001856 <copyinstr+0x5a>
  int got_null = 0;
    800018ae:	4781                	li	a5,0
  if(got_null){
    800018b0:	37fd                	addiw	a5,a5,-1
    800018b2:	0007851b          	sext.w	a0,a5
}
    800018b6:	8082                	ret

00000000800018b8 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800018b8:	7139                	addi	sp,sp,-64
    800018ba:	fc06                	sd	ra,56(sp)
    800018bc:	f822                	sd	s0,48(sp)
    800018be:	f426                	sd	s1,40(sp)
    800018c0:	f04a                	sd	s2,32(sp)
    800018c2:	ec4e                	sd	s3,24(sp)
    800018c4:	e852                	sd	s4,16(sp)
    800018c6:	e456                	sd	s5,8(sp)
    800018c8:	e05a                	sd	s6,0(sp)
    800018ca:	0080                	addi	s0,sp,64
    800018cc:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800018ce:	00012497          	auipc	s1,0x12
    800018d2:	f6248493          	addi	s1,s1,-158 # 80013830 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800018d6:	8b26                	mv	s6,s1
    800018d8:	04fa5937          	lui	s2,0x4fa5
    800018dc:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    800018e0:	0932                	slli	s2,s2,0xc
    800018e2:	fa590913          	addi	s2,s2,-91
    800018e6:	0932                	slli	s2,s2,0xc
    800018e8:	fa590913          	addi	s2,s2,-91
    800018ec:	0932                	slli	s2,s2,0xc
    800018ee:	fa590913          	addi	s2,s2,-91
    800018f2:	040009b7          	lui	s3,0x4000
    800018f6:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018f8:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018fa:	00018a97          	auipc	s5,0x18
    800018fe:	936a8a93          	addi	s5,s5,-1738 # 80019230 <tickslock>
    char *pa = kalloc();
    80001902:	fffff097          	auipc	ra,0xfffff
    80001906:	246080e7          	jalr	582(ra) # 80000b48 <kalloc>
    8000190a:	862a                	mv	a2,a0
    if(pa == 0)
    8000190c:	c121                	beqz	a0,8000194c <proc_mapstacks+0x94>
    uint64 va = KSTACK((int) (p - proc));
    8000190e:	416485b3          	sub	a1,s1,s6
    80001912:	858d                	srai	a1,a1,0x3
    80001914:	032585b3          	mul	a1,a1,s2
    80001918:	2585                	addiw	a1,a1,1
    8000191a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000191e:	4719                	li	a4,6
    80001920:	6685                	lui	a3,0x1
    80001922:	40b985b3          	sub	a1,s3,a1
    80001926:	8552                	mv	a0,s4
    80001928:	00000097          	auipc	ra,0x0
    8000192c:	870080e7          	jalr	-1936(ra) # 80001198 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001930:	16848493          	addi	s1,s1,360
    80001934:	fd5497e3          	bne	s1,s5,80001902 <proc_mapstacks+0x4a>
  }
}
    80001938:	70e2                	ld	ra,56(sp)
    8000193a:	7442                	ld	s0,48(sp)
    8000193c:	74a2                	ld	s1,40(sp)
    8000193e:	7902                	ld	s2,32(sp)
    80001940:	69e2                	ld	s3,24(sp)
    80001942:	6a42                	ld	s4,16(sp)
    80001944:	6aa2                	ld	s5,8(sp)
    80001946:	6b02                	ld	s6,0(sp)
    80001948:	6121                	addi	sp,sp,64
    8000194a:	8082                	ret
      panic("kalloc");
    8000194c:	00007517          	auipc	a0,0x7
    80001950:	86c50513          	addi	a0,a0,-1940 # 800081b8 <etext+0x1b8>
    80001954:	fffff097          	auipc	ra,0xfffff
    80001958:	c0c080e7          	jalr	-1012(ra) # 80000560 <panic>

000000008000195c <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000195c:	7139                	addi	sp,sp,-64
    8000195e:	fc06                	sd	ra,56(sp)
    80001960:	f822                	sd	s0,48(sp)
    80001962:	f426                	sd	s1,40(sp)
    80001964:	f04a                	sd	s2,32(sp)
    80001966:	ec4e                	sd	s3,24(sp)
    80001968:	e852                	sd	s4,16(sp)
    8000196a:	e456                	sd	s5,8(sp)
    8000196c:	e05a                	sd	s6,0(sp)
    8000196e:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001970:	00007597          	auipc	a1,0x7
    80001974:	85058593          	addi	a1,a1,-1968 # 800081c0 <etext+0x1c0>
    80001978:	00012517          	auipc	a0,0x12
    8000197c:	a8850513          	addi	a0,a0,-1400 # 80013400 <pid_lock>
    80001980:	fffff097          	auipc	ra,0xfffff
    80001984:	228080e7          	jalr	552(ra) # 80000ba8 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001988:	00007597          	auipc	a1,0x7
    8000198c:	84058593          	addi	a1,a1,-1984 # 800081c8 <etext+0x1c8>
    80001990:	00012517          	auipc	a0,0x12
    80001994:	a8850513          	addi	a0,a0,-1400 # 80013418 <wait_lock>
    80001998:	fffff097          	auipc	ra,0xfffff
    8000199c:	210080e7          	jalr	528(ra) # 80000ba8 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019a0:	00012497          	auipc	s1,0x12
    800019a4:	e9048493          	addi	s1,s1,-368 # 80013830 <proc>
      initlock(&p->lock, "proc");
    800019a8:	00007b17          	auipc	s6,0x7
    800019ac:	830b0b13          	addi	s6,s6,-2000 # 800081d8 <etext+0x1d8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    800019b0:	8aa6                	mv	s5,s1
    800019b2:	04fa5937          	lui	s2,0x4fa5
    800019b6:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    800019ba:	0932                	slli	s2,s2,0xc
    800019bc:	fa590913          	addi	s2,s2,-91
    800019c0:	0932                	slli	s2,s2,0xc
    800019c2:	fa590913          	addi	s2,s2,-91
    800019c6:	0932                	slli	s2,s2,0xc
    800019c8:	fa590913          	addi	s2,s2,-91
    800019cc:	040009b7          	lui	s3,0x4000
    800019d0:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800019d2:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019d4:	00018a17          	auipc	s4,0x18
    800019d8:	85ca0a13          	addi	s4,s4,-1956 # 80019230 <tickslock>
      initlock(&p->lock, "proc");
    800019dc:	85da                	mv	a1,s6
    800019de:	8526                	mv	a0,s1
    800019e0:	fffff097          	auipc	ra,0xfffff
    800019e4:	1c8080e7          	jalr	456(ra) # 80000ba8 <initlock>
      p->state = UNUSED;
    800019e8:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800019ec:	415487b3          	sub	a5,s1,s5
    800019f0:	878d                	srai	a5,a5,0x3
    800019f2:	032787b3          	mul	a5,a5,s2
    800019f6:	2785                	addiw	a5,a5,1
    800019f8:	00d7979b          	slliw	a5,a5,0xd
    800019fc:	40f987b3          	sub	a5,s3,a5
    80001a00:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a02:	16848493          	addi	s1,s1,360
    80001a06:	fd449be3          	bne	s1,s4,800019dc <procinit+0x80>
  }
}
    80001a0a:	70e2                	ld	ra,56(sp)
    80001a0c:	7442                	ld	s0,48(sp)
    80001a0e:	74a2                	ld	s1,40(sp)
    80001a10:	7902                	ld	s2,32(sp)
    80001a12:	69e2                	ld	s3,24(sp)
    80001a14:	6a42                	ld	s4,16(sp)
    80001a16:	6aa2                	ld	s5,8(sp)
    80001a18:	6b02                	ld	s6,0(sp)
    80001a1a:	6121                	addi	sp,sp,64
    80001a1c:	8082                	ret

0000000080001a1e <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001a1e:	1141                	addi	sp,sp,-16
    80001a20:	e422                	sd	s0,8(sp)
    80001a22:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a24:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a26:	2501                	sext.w	a0,a0
    80001a28:	6422                	ld	s0,8(sp)
    80001a2a:	0141                	addi	sp,sp,16
    80001a2c:	8082                	ret

0000000080001a2e <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001a2e:	1141                	addi	sp,sp,-16
    80001a30:	e422                	sd	s0,8(sp)
    80001a32:	0800                	addi	s0,sp,16
    80001a34:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a36:	2781                	sext.w	a5,a5
    80001a38:	079e                	slli	a5,a5,0x7
  return c;
}
    80001a3a:	00012517          	auipc	a0,0x12
    80001a3e:	9f650513          	addi	a0,a0,-1546 # 80013430 <cpus>
    80001a42:	953e                	add	a0,a0,a5
    80001a44:	6422                	ld	s0,8(sp)
    80001a46:	0141                	addi	sp,sp,16
    80001a48:	8082                	ret

0000000080001a4a <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001a4a:	1101                	addi	sp,sp,-32
    80001a4c:	ec06                	sd	ra,24(sp)
    80001a4e:	e822                	sd	s0,16(sp)
    80001a50:	e426                	sd	s1,8(sp)
    80001a52:	1000                	addi	s0,sp,32
  push_off();
    80001a54:	fffff097          	auipc	ra,0xfffff
    80001a58:	198080e7          	jalr	408(ra) # 80000bec <push_off>
    80001a5c:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a5e:	2781                	sext.w	a5,a5
    80001a60:	079e                	slli	a5,a5,0x7
    80001a62:	00012717          	auipc	a4,0x12
    80001a66:	99e70713          	addi	a4,a4,-1634 # 80013400 <pid_lock>
    80001a6a:	97ba                	add	a5,a5,a4
    80001a6c:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a6e:	fffff097          	auipc	ra,0xfffff
    80001a72:	21e080e7          	jalr	542(ra) # 80000c8c <pop_off>
  return p;
}
    80001a76:	8526                	mv	a0,s1
    80001a78:	60e2                	ld	ra,24(sp)
    80001a7a:	6442                	ld	s0,16(sp)
    80001a7c:	64a2                	ld	s1,8(sp)
    80001a7e:	6105                	addi	sp,sp,32
    80001a80:	8082                	ret

0000000080001a82 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a82:	1141                	addi	sp,sp,-16
    80001a84:	e406                	sd	ra,8(sp)
    80001a86:	e022                	sd	s0,0(sp)
    80001a88:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a8a:	00000097          	auipc	ra,0x0
    80001a8e:	fc0080e7          	jalr	-64(ra) # 80001a4a <myproc>
    80001a92:	fffff097          	auipc	ra,0xfffff
    80001a96:	25a080e7          	jalr	602(ra) # 80000cec <release>

  if (first) {
    80001a9a:	00009797          	auipc	a5,0x9
    80001a9e:	6567a783          	lw	a5,1622(a5) # 8000b0f0 <first.1>
    80001aa2:	eb89                	bnez	a5,80001ab4 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001aa4:	00001097          	auipc	ra,0x1
    80001aa8:	c5e080e7          	jalr	-930(ra) # 80002702 <usertrapret>
}
    80001aac:	60a2                	ld	ra,8(sp)
    80001aae:	6402                	ld	s0,0(sp)
    80001ab0:	0141                	addi	sp,sp,16
    80001ab2:	8082                	ret
    first = 0;
    80001ab4:	00009797          	auipc	a5,0x9
    80001ab8:	6207ae23          	sw	zero,1596(a5) # 8000b0f0 <first.1>
    fsinit(ROOTDEV);
    80001abc:	4505                	li	a0,1
    80001abe:	00002097          	auipc	ra,0x2
    80001ac2:	9b2080e7          	jalr	-1614(ra) # 80003470 <fsinit>
    80001ac6:	bff9                	j	80001aa4 <forkret+0x22>

0000000080001ac8 <allocpid>:
{
    80001ac8:	1101                	addi	sp,sp,-32
    80001aca:	ec06                	sd	ra,24(sp)
    80001acc:	e822                	sd	s0,16(sp)
    80001ace:	e426                	sd	s1,8(sp)
    80001ad0:	e04a                	sd	s2,0(sp)
    80001ad2:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001ad4:	00012917          	auipc	s2,0x12
    80001ad8:	92c90913          	addi	s2,s2,-1748 # 80013400 <pid_lock>
    80001adc:	854a                	mv	a0,s2
    80001ade:	fffff097          	auipc	ra,0xfffff
    80001ae2:	15a080e7          	jalr	346(ra) # 80000c38 <acquire>
  pid = nextpid;
    80001ae6:	00009797          	auipc	a5,0x9
    80001aea:	60e78793          	addi	a5,a5,1550 # 8000b0f4 <nextpid>
    80001aee:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001af0:	0014871b          	addiw	a4,s1,1
    80001af4:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001af6:	854a                	mv	a0,s2
    80001af8:	fffff097          	auipc	ra,0xfffff
    80001afc:	1f4080e7          	jalr	500(ra) # 80000cec <release>
}
    80001b00:	8526                	mv	a0,s1
    80001b02:	60e2                	ld	ra,24(sp)
    80001b04:	6442                	ld	s0,16(sp)
    80001b06:	64a2                	ld	s1,8(sp)
    80001b08:	6902                	ld	s2,0(sp)
    80001b0a:	6105                	addi	sp,sp,32
    80001b0c:	8082                	ret

0000000080001b0e <proc_pagetable>:
{
    80001b0e:	1101                	addi	sp,sp,-32
    80001b10:	ec06                	sd	ra,24(sp)
    80001b12:	e822                	sd	s0,16(sp)
    80001b14:	e426                	sd	s1,8(sp)
    80001b16:	e04a                	sd	s2,0(sp)
    80001b18:	1000                	addi	s0,sp,32
    80001b1a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b1c:	00000097          	auipc	ra,0x0
    80001b20:	876080e7          	jalr	-1930(ra) # 80001392 <uvmcreate>
    80001b24:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b26:	c121                	beqz	a0,80001b66 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b28:	4729                	li	a4,10
    80001b2a:	00005697          	auipc	a3,0x5
    80001b2e:	4d668693          	addi	a3,a3,1238 # 80007000 <_trampoline>
    80001b32:	6605                	lui	a2,0x1
    80001b34:	040005b7          	lui	a1,0x4000
    80001b38:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b3a:	05b2                	slli	a1,a1,0xc
    80001b3c:	fffff097          	auipc	ra,0xfffff
    80001b40:	5bc080e7          	jalr	1468(ra) # 800010f8 <mappages>
    80001b44:	02054863          	bltz	a0,80001b74 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b48:	4719                	li	a4,6
    80001b4a:	05893683          	ld	a3,88(s2)
    80001b4e:	6605                	lui	a2,0x1
    80001b50:	020005b7          	lui	a1,0x2000
    80001b54:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b56:	05b6                	slli	a1,a1,0xd
    80001b58:	8526                	mv	a0,s1
    80001b5a:	fffff097          	auipc	ra,0xfffff
    80001b5e:	59e080e7          	jalr	1438(ra) # 800010f8 <mappages>
    80001b62:	02054163          	bltz	a0,80001b84 <proc_pagetable+0x76>
}
    80001b66:	8526                	mv	a0,s1
    80001b68:	60e2                	ld	ra,24(sp)
    80001b6a:	6442                	ld	s0,16(sp)
    80001b6c:	64a2                	ld	s1,8(sp)
    80001b6e:	6902                	ld	s2,0(sp)
    80001b70:	6105                	addi	sp,sp,32
    80001b72:	8082                	ret
    uvmfree(pagetable, 0);
    80001b74:	4581                	li	a1,0
    80001b76:	8526                	mv	a0,s1
    80001b78:	00000097          	auipc	ra,0x0
    80001b7c:	a2c080e7          	jalr	-1492(ra) # 800015a4 <uvmfree>
    return 0;
    80001b80:	4481                	li	s1,0
    80001b82:	b7d5                	j	80001b66 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b84:	4681                	li	a3,0
    80001b86:	4605                	li	a2,1
    80001b88:	040005b7          	lui	a1,0x4000
    80001b8c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b8e:	05b2                	slli	a1,a1,0xc
    80001b90:	8526                	mv	a0,s1
    80001b92:	fffff097          	auipc	ra,0xfffff
    80001b96:	72c080e7          	jalr	1836(ra) # 800012be <uvmunmap>
    uvmfree(pagetable, 0);
    80001b9a:	4581                	li	a1,0
    80001b9c:	8526                	mv	a0,s1
    80001b9e:	00000097          	auipc	ra,0x0
    80001ba2:	a06080e7          	jalr	-1530(ra) # 800015a4 <uvmfree>
    return 0;
    80001ba6:	4481                	li	s1,0
    80001ba8:	bf7d                	j	80001b66 <proc_pagetable+0x58>

0000000080001baa <proc_freepagetable>:
{
    80001baa:	1101                	addi	sp,sp,-32
    80001bac:	ec06                	sd	ra,24(sp)
    80001bae:	e822                	sd	s0,16(sp)
    80001bb0:	e426                	sd	s1,8(sp)
    80001bb2:	e04a                	sd	s2,0(sp)
    80001bb4:	1000                	addi	s0,sp,32
    80001bb6:	84aa                	mv	s1,a0
    80001bb8:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bba:	4681                	li	a3,0
    80001bbc:	4605                	li	a2,1
    80001bbe:	040005b7          	lui	a1,0x4000
    80001bc2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bc4:	05b2                	slli	a1,a1,0xc
    80001bc6:	fffff097          	auipc	ra,0xfffff
    80001bca:	6f8080e7          	jalr	1784(ra) # 800012be <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bce:	4681                	li	a3,0
    80001bd0:	4605                	li	a2,1
    80001bd2:	020005b7          	lui	a1,0x2000
    80001bd6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bd8:	05b6                	slli	a1,a1,0xd
    80001bda:	8526                	mv	a0,s1
    80001bdc:	fffff097          	auipc	ra,0xfffff
    80001be0:	6e2080e7          	jalr	1762(ra) # 800012be <uvmunmap>
  uvmfree(pagetable, sz);
    80001be4:	85ca                	mv	a1,s2
    80001be6:	8526                	mv	a0,s1
    80001be8:	00000097          	auipc	ra,0x0
    80001bec:	9bc080e7          	jalr	-1604(ra) # 800015a4 <uvmfree>
}
    80001bf0:	60e2                	ld	ra,24(sp)
    80001bf2:	6442                	ld	s0,16(sp)
    80001bf4:	64a2                	ld	s1,8(sp)
    80001bf6:	6902                	ld	s2,0(sp)
    80001bf8:	6105                	addi	sp,sp,32
    80001bfa:	8082                	ret

0000000080001bfc <freeproc>:
{
    80001bfc:	1101                	addi	sp,sp,-32
    80001bfe:	ec06                	sd	ra,24(sp)
    80001c00:	e822                	sd	s0,16(sp)
    80001c02:	e426                	sd	s1,8(sp)
    80001c04:	1000                	addi	s0,sp,32
    80001c06:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c08:	6d28                	ld	a0,88(a0)
    80001c0a:	c509                	beqz	a0,80001c14 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c0c:	fffff097          	auipc	ra,0xfffff
    80001c10:	e3e080e7          	jalr	-450(ra) # 80000a4a <kfree>
  p->trapframe = 0;
    80001c14:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001c18:	68a8                	ld	a0,80(s1)
    80001c1a:	c511                	beqz	a0,80001c26 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c1c:	64ac                	ld	a1,72(s1)
    80001c1e:	00000097          	auipc	ra,0x0
    80001c22:	f8c080e7          	jalr	-116(ra) # 80001baa <proc_freepagetable>
  p->pagetable = 0;
    80001c26:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c2a:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c2e:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c32:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c36:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c3a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c3e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c42:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c46:	0004ac23          	sw	zero,24(s1)
}
    80001c4a:	60e2                	ld	ra,24(sp)
    80001c4c:	6442                	ld	s0,16(sp)
    80001c4e:	64a2                	ld	s1,8(sp)
    80001c50:	6105                	addi	sp,sp,32
    80001c52:	8082                	ret

0000000080001c54 <allocproc>:
{
    80001c54:	1101                	addi	sp,sp,-32
    80001c56:	ec06                	sd	ra,24(sp)
    80001c58:	e822                	sd	s0,16(sp)
    80001c5a:	e426                	sd	s1,8(sp)
    80001c5c:	e04a                	sd	s2,0(sp)
    80001c5e:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c60:	00012497          	auipc	s1,0x12
    80001c64:	bd048493          	addi	s1,s1,-1072 # 80013830 <proc>
    80001c68:	00017917          	auipc	s2,0x17
    80001c6c:	5c890913          	addi	s2,s2,1480 # 80019230 <tickslock>
    acquire(&p->lock);
    80001c70:	8526                	mv	a0,s1
    80001c72:	fffff097          	auipc	ra,0xfffff
    80001c76:	fc6080e7          	jalr	-58(ra) # 80000c38 <acquire>
    if(p->state == UNUSED) {
    80001c7a:	4c9c                	lw	a5,24(s1)
    80001c7c:	cf81                	beqz	a5,80001c94 <allocproc+0x40>
      release(&p->lock);
    80001c7e:	8526                	mv	a0,s1
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	06c080e7          	jalr	108(ra) # 80000cec <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c88:	16848493          	addi	s1,s1,360
    80001c8c:	ff2492e3          	bne	s1,s2,80001c70 <allocproc+0x1c>
  return 0;
    80001c90:	4481                	li	s1,0
    80001c92:	a889                	j	80001ce4 <allocproc+0x90>
  p->pid = allocpid();
    80001c94:	00000097          	auipc	ra,0x0
    80001c98:	e34080e7          	jalr	-460(ra) # 80001ac8 <allocpid>
    80001c9c:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c9e:	4785                	li	a5,1
    80001ca0:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ca2:	fffff097          	auipc	ra,0xfffff
    80001ca6:	ea6080e7          	jalr	-346(ra) # 80000b48 <kalloc>
    80001caa:	892a                	mv	s2,a0
    80001cac:	eca8                	sd	a0,88(s1)
    80001cae:	c131                	beqz	a0,80001cf2 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001cb0:	8526                	mv	a0,s1
    80001cb2:	00000097          	auipc	ra,0x0
    80001cb6:	e5c080e7          	jalr	-420(ra) # 80001b0e <proc_pagetable>
    80001cba:	892a                	mv	s2,a0
    80001cbc:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001cbe:	c531                	beqz	a0,80001d0a <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001cc0:	07000613          	li	a2,112
    80001cc4:	4581                	li	a1,0
    80001cc6:	06048513          	addi	a0,s1,96
    80001cca:	fffff097          	auipc	ra,0xfffff
    80001cce:	06a080e7          	jalr	106(ra) # 80000d34 <memset>
  p->context.ra = (uint64)forkret;
    80001cd2:	00000797          	auipc	a5,0x0
    80001cd6:	db078793          	addi	a5,a5,-592 # 80001a82 <forkret>
    80001cda:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cdc:	60bc                	ld	a5,64(s1)
    80001cde:	6705                	lui	a4,0x1
    80001ce0:	97ba                	add	a5,a5,a4
    80001ce2:	f4bc                	sd	a5,104(s1)
}
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	60e2                	ld	ra,24(sp)
    80001ce8:	6442                	ld	s0,16(sp)
    80001cea:	64a2                	ld	s1,8(sp)
    80001cec:	6902                	ld	s2,0(sp)
    80001cee:	6105                	addi	sp,sp,32
    80001cf0:	8082                	ret
    freeproc(p);
    80001cf2:	8526                	mv	a0,s1
    80001cf4:	00000097          	auipc	ra,0x0
    80001cf8:	f08080e7          	jalr	-248(ra) # 80001bfc <freeproc>
    release(&p->lock);
    80001cfc:	8526                	mv	a0,s1
    80001cfe:	fffff097          	auipc	ra,0xfffff
    80001d02:	fee080e7          	jalr	-18(ra) # 80000cec <release>
    return 0;
    80001d06:	84ca                	mv	s1,s2
    80001d08:	bff1                	j	80001ce4 <allocproc+0x90>
    freeproc(p);
    80001d0a:	8526                	mv	a0,s1
    80001d0c:	00000097          	auipc	ra,0x0
    80001d10:	ef0080e7          	jalr	-272(ra) # 80001bfc <freeproc>
    release(&p->lock);
    80001d14:	8526                	mv	a0,s1
    80001d16:	fffff097          	auipc	ra,0xfffff
    80001d1a:	fd6080e7          	jalr	-42(ra) # 80000cec <release>
    return 0;
    80001d1e:	84ca                	mv	s1,s2
    80001d20:	b7d1                	j	80001ce4 <allocproc+0x90>

0000000080001d22 <userinit>:
{
    80001d22:	1101                	addi	sp,sp,-32
    80001d24:	ec06                	sd	ra,24(sp)
    80001d26:	e822                	sd	s0,16(sp)
    80001d28:	e426                	sd	s1,8(sp)
    80001d2a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d2c:	00000097          	auipc	ra,0x0
    80001d30:	f28080e7          	jalr	-216(ra) # 80001c54 <allocproc>
    80001d34:	84aa                	mv	s1,a0
  initproc = p;
    80001d36:	00009797          	auipc	a5,0x9
    80001d3a:	44a7b923          	sd	a0,1106(a5) # 8000b188 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d3e:	03400613          	li	a2,52
    80001d42:	00009597          	auipc	a1,0x9
    80001d46:	3be58593          	addi	a1,a1,958 # 8000b100 <initcode>
    80001d4a:	6928                	ld	a0,80(a0)
    80001d4c:	fffff097          	auipc	ra,0xfffff
    80001d50:	674080e7          	jalr	1652(ra) # 800013c0 <uvmfirst>
  p->sz = PGSIZE;
    80001d54:	6785                	lui	a5,0x1
    80001d56:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d58:	6cb8                	ld	a4,88(s1)
    80001d5a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d5e:	6cb8                	ld	a4,88(s1)
    80001d60:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d62:	4641                	li	a2,16
    80001d64:	00006597          	auipc	a1,0x6
    80001d68:	47c58593          	addi	a1,a1,1148 # 800081e0 <etext+0x1e0>
    80001d6c:	15848513          	addi	a0,s1,344
    80001d70:	fffff097          	auipc	ra,0xfffff
    80001d74:	106080e7          	jalr	262(ra) # 80000e76 <safestrcpy>
  p->cwd = namei("/");
    80001d78:	00006517          	auipc	a0,0x6
    80001d7c:	47850513          	addi	a0,a0,1144 # 800081f0 <etext+0x1f0>
    80001d80:	00002097          	auipc	ra,0x2
    80001d84:	142080e7          	jalr	322(ra) # 80003ec2 <namei>
    80001d88:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d8c:	478d                	li	a5,3
    80001d8e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d90:	8526                	mv	a0,s1
    80001d92:	fffff097          	auipc	ra,0xfffff
    80001d96:	f5a080e7          	jalr	-166(ra) # 80000cec <release>
}
    80001d9a:	60e2                	ld	ra,24(sp)
    80001d9c:	6442                	ld	s0,16(sp)
    80001d9e:	64a2                	ld	s1,8(sp)
    80001da0:	6105                	addi	sp,sp,32
    80001da2:	8082                	ret

0000000080001da4 <growproc>:
{
    80001da4:	1101                	addi	sp,sp,-32
    80001da6:	ec06                	sd	ra,24(sp)
    80001da8:	e822                	sd	s0,16(sp)
    80001daa:	e426                	sd	s1,8(sp)
    80001dac:	e04a                	sd	s2,0(sp)
    80001dae:	1000                	addi	s0,sp,32
    80001db0:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001db2:	00000097          	auipc	ra,0x0
    80001db6:	c98080e7          	jalr	-872(ra) # 80001a4a <myproc>
    80001dba:	84aa                	mv	s1,a0
  sz = p->sz;
    80001dbc:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001dbe:	01204c63          	bgtz	s2,80001dd6 <growproc+0x32>
  } else if(n < 0){
    80001dc2:	02094663          	bltz	s2,80001dee <growproc+0x4a>
  p->sz = sz;
    80001dc6:	e4ac                	sd	a1,72(s1)
  return 0;
    80001dc8:	4501                	li	a0,0
}
    80001dca:	60e2                	ld	ra,24(sp)
    80001dcc:	6442                	ld	s0,16(sp)
    80001dce:	64a2                	ld	s1,8(sp)
    80001dd0:	6902                	ld	s2,0(sp)
    80001dd2:	6105                	addi	sp,sp,32
    80001dd4:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001dd6:	4691                	li	a3,4
    80001dd8:	00b90633          	add	a2,s2,a1
    80001ddc:	6928                	ld	a0,80(a0)
    80001dde:	fffff097          	auipc	ra,0xfffff
    80001de2:	69c080e7          	jalr	1692(ra) # 8000147a <uvmalloc>
    80001de6:	85aa                	mv	a1,a0
    80001de8:	fd79                	bnez	a0,80001dc6 <growproc+0x22>
      return -1;
    80001dea:	557d                	li	a0,-1
    80001dec:	bff9                	j	80001dca <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dee:	00b90633          	add	a2,s2,a1
    80001df2:	6928                	ld	a0,80(a0)
    80001df4:	fffff097          	auipc	ra,0xfffff
    80001df8:	63e080e7          	jalr	1598(ra) # 80001432 <uvmdealloc>
    80001dfc:	85aa                	mv	a1,a0
    80001dfe:	b7e1                	j	80001dc6 <growproc+0x22>

0000000080001e00 <fork>:
{
    80001e00:	7139                	addi	sp,sp,-64
    80001e02:	fc06                	sd	ra,56(sp)
    80001e04:	f822                	sd	s0,48(sp)
    80001e06:	f04a                	sd	s2,32(sp)
    80001e08:	e456                	sd	s5,8(sp)
    80001e0a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e0c:	00000097          	auipc	ra,0x0
    80001e10:	c3e080e7          	jalr	-962(ra) # 80001a4a <myproc>
    80001e14:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e16:	00000097          	auipc	ra,0x0
    80001e1a:	e3e080e7          	jalr	-450(ra) # 80001c54 <allocproc>
    80001e1e:	12050063          	beqz	a0,80001f3e <fork+0x13e>
    80001e22:	e852                	sd	s4,16(sp)
    80001e24:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e26:	048ab603          	ld	a2,72(s5)
    80001e2a:	692c                	ld	a1,80(a0)
    80001e2c:	050ab503          	ld	a0,80(s5)
    80001e30:	fffff097          	auipc	ra,0xfffff
    80001e34:	7ae080e7          	jalr	1966(ra) # 800015de <uvmcopy>
    80001e38:	04054a63          	bltz	a0,80001e8c <fork+0x8c>
    80001e3c:	f426                	sd	s1,40(sp)
    80001e3e:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001e40:	048ab783          	ld	a5,72(s5)
    80001e44:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e48:	058ab683          	ld	a3,88(s5)
    80001e4c:	87b6                	mv	a5,a3
    80001e4e:	058a3703          	ld	a4,88(s4)
    80001e52:	12068693          	addi	a3,a3,288
    80001e56:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e5a:	6788                	ld	a0,8(a5)
    80001e5c:	6b8c                	ld	a1,16(a5)
    80001e5e:	6f90                	ld	a2,24(a5)
    80001e60:	01073023          	sd	a6,0(a4)
    80001e64:	e708                	sd	a0,8(a4)
    80001e66:	eb0c                	sd	a1,16(a4)
    80001e68:	ef10                	sd	a2,24(a4)
    80001e6a:	02078793          	addi	a5,a5,32
    80001e6e:	02070713          	addi	a4,a4,32
    80001e72:	fed792e3          	bne	a5,a3,80001e56 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e76:	058a3783          	ld	a5,88(s4)
    80001e7a:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e7e:	0d0a8493          	addi	s1,s5,208
    80001e82:	0d0a0913          	addi	s2,s4,208
    80001e86:	150a8993          	addi	s3,s5,336
    80001e8a:	a015                	j	80001eae <fork+0xae>
    freeproc(np);
    80001e8c:	8552                	mv	a0,s4
    80001e8e:	00000097          	auipc	ra,0x0
    80001e92:	d6e080e7          	jalr	-658(ra) # 80001bfc <freeproc>
    release(&np->lock);
    80001e96:	8552                	mv	a0,s4
    80001e98:	fffff097          	auipc	ra,0xfffff
    80001e9c:	e54080e7          	jalr	-428(ra) # 80000cec <release>
    return -1;
    80001ea0:	597d                	li	s2,-1
    80001ea2:	6a42                	ld	s4,16(sp)
    80001ea4:	a071                	j	80001f30 <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001ea6:	04a1                	addi	s1,s1,8
    80001ea8:	0921                	addi	s2,s2,8
    80001eaa:	01348b63          	beq	s1,s3,80001ec0 <fork+0xc0>
    if(p->ofile[i])
    80001eae:	6088                	ld	a0,0(s1)
    80001eb0:	d97d                	beqz	a0,80001ea6 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eb2:	00002097          	auipc	ra,0x2
    80001eb6:	688080e7          	jalr	1672(ra) # 8000453a <filedup>
    80001eba:	00a93023          	sd	a0,0(s2)
    80001ebe:	b7e5                	j	80001ea6 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001ec0:	150ab503          	ld	a0,336(s5)
    80001ec4:	00001097          	auipc	ra,0x1
    80001ec8:	7f2080e7          	jalr	2034(ra) # 800036b6 <idup>
    80001ecc:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ed0:	4641                	li	a2,16
    80001ed2:	158a8593          	addi	a1,s5,344
    80001ed6:	158a0513          	addi	a0,s4,344
    80001eda:	fffff097          	auipc	ra,0xfffff
    80001ede:	f9c080e7          	jalr	-100(ra) # 80000e76 <safestrcpy>
  pid = np->pid;
    80001ee2:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001ee6:	8552                	mv	a0,s4
    80001ee8:	fffff097          	auipc	ra,0xfffff
    80001eec:	e04080e7          	jalr	-508(ra) # 80000cec <release>
  acquire(&wait_lock);
    80001ef0:	00011497          	auipc	s1,0x11
    80001ef4:	52848493          	addi	s1,s1,1320 # 80013418 <wait_lock>
    80001ef8:	8526                	mv	a0,s1
    80001efa:	fffff097          	auipc	ra,0xfffff
    80001efe:	d3e080e7          	jalr	-706(ra) # 80000c38 <acquire>
  np->parent = p;
    80001f02:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001f06:	8526                	mv	a0,s1
    80001f08:	fffff097          	auipc	ra,0xfffff
    80001f0c:	de4080e7          	jalr	-540(ra) # 80000cec <release>
  acquire(&np->lock);
    80001f10:	8552                	mv	a0,s4
    80001f12:	fffff097          	auipc	ra,0xfffff
    80001f16:	d26080e7          	jalr	-730(ra) # 80000c38 <acquire>
  np->state = RUNNABLE;
    80001f1a:	478d                	li	a5,3
    80001f1c:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f20:	8552                	mv	a0,s4
    80001f22:	fffff097          	auipc	ra,0xfffff
    80001f26:	dca080e7          	jalr	-566(ra) # 80000cec <release>
  return pid;
    80001f2a:	74a2                	ld	s1,40(sp)
    80001f2c:	69e2                	ld	s3,24(sp)
    80001f2e:	6a42                	ld	s4,16(sp)
}
    80001f30:	854a                	mv	a0,s2
    80001f32:	70e2                	ld	ra,56(sp)
    80001f34:	7442                	ld	s0,48(sp)
    80001f36:	7902                	ld	s2,32(sp)
    80001f38:	6aa2                	ld	s5,8(sp)
    80001f3a:	6121                	addi	sp,sp,64
    80001f3c:	8082                	ret
    return -1;
    80001f3e:	597d                	li	s2,-1
    80001f40:	bfc5                	j	80001f30 <fork+0x130>

0000000080001f42 <scheduler>:
{
    80001f42:	7139                	addi	sp,sp,-64
    80001f44:	fc06                	sd	ra,56(sp)
    80001f46:	f822                	sd	s0,48(sp)
    80001f48:	f426                	sd	s1,40(sp)
    80001f4a:	f04a                	sd	s2,32(sp)
    80001f4c:	ec4e                	sd	s3,24(sp)
    80001f4e:	e852                	sd	s4,16(sp)
    80001f50:	e456                	sd	s5,8(sp)
    80001f52:	e05a                	sd	s6,0(sp)
    80001f54:	0080                	addi	s0,sp,64
    80001f56:	8792                	mv	a5,tp
  int id = r_tp();
    80001f58:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f5a:	00779a93          	slli	s5,a5,0x7
    80001f5e:	00011717          	auipc	a4,0x11
    80001f62:	4a270713          	addi	a4,a4,1186 # 80013400 <pid_lock>
    80001f66:	9756                	add	a4,a4,s5
    80001f68:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f6c:	00011717          	auipc	a4,0x11
    80001f70:	4cc70713          	addi	a4,a4,1228 # 80013438 <cpus+0x8>
    80001f74:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001f76:	498d                	li	s3,3
        p->state = RUNNING;
    80001f78:	4b11                	li	s6,4
        c->proc = p;
    80001f7a:	079e                	slli	a5,a5,0x7
    80001f7c:	00011a17          	auipc	s4,0x11
    80001f80:	484a0a13          	addi	s4,s4,1156 # 80013400 <pid_lock>
    80001f84:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f86:	00017917          	auipc	s2,0x17
    80001f8a:	2aa90913          	addi	s2,s2,682 # 80019230 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f8e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f92:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f96:	10079073          	csrw	sstatus,a5
    80001f9a:	00012497          	auipc	s1,0x12
    80001f9e:	89648493          	addi	s1,s1,-1898 # 80013830 <proc>
    80001fa2:	a811                	j	80001fb6 <scheduler+0x74>
      release(&p->lock);
    80001fa4:	8526                	mv	a0,s1
    80001fa6:	fffff097          	auipc	ra,0xfffff
    80001faa:	d46080e7          	jalr	-698(ra) # 80000cec <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fae:	16848493          	addi	s1,s1,360
    80001fb2:	fd248ee3          	beq	s1,s2,80001f8e <scheduler+0x4c>
      acquire(&p->lock);
    80001fb6:	8526                	mv	a0,s1
    80001fb8:	fffff097          	auipc	ra,0xfffff
    80001fbc:	c80080e7          	jalr	-896(ra) # 80000c38 <acquire>
      if(p->state == RUNNABLE) {
    80001fc0:	4c9c                	lw	a5,24(s1)
    80001fc2:	ff3791e3          	bne	a5,s3,80001fa4 <scheduler+0x62>
        p->state = RUNNING;
    80001fc6:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001fca:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fce:	06048593          	addi	a1,s1,96
    80001fd2:	8556                	mv	a0,s5
    80001fd4:	00000097          	auipc	ra,0x0
    80001fd8:	684080e7          	jalr	1668(ra) # 80002658 <swtch>
        c->proc = 0;
    80001fdc:	020a3823          	sd	zero,48(s4)
    80001fe0:	b7d1                	j	80001fa4 <scheduler+0x62>

0000000080001fe2 <sched>:
{
    80001fe2:	7179                	addi	sp,sp,-48
    80001fe4:	f406                	sd	ra,40(sp)
    80001fe6:	f022                	sd	s0,32(sp)
    80001fe8:	ec26                	sd	s1,24(sp)
    80001fea:	e84a                	sd	s2,16(sp)
    80001fec:	e44e                	sd	s3,8(sp)
    80001fee:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001ff0:	00000097          	auipc	ra,0x0
    80001ff4:	a5a080e7          	jalr	-1446(ra) # 80001a4a <myproc>
    80001ff8:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001ffa:	fffff097          	auipc	ra,0xfffff
    80001ffe:	bc4080e7          	jalr	-1084(ra) # 80000bbe <holding>
    80002002:	c93d                	beqz	a0,80002078 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002004:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002006:	2781                	sext.w	a5,a5
    80002008:	079e                	slli	a5,a5,0x7
    8000200a:	00011717          	auipc	a4,0x11
    8000200e:	3f670713          	addi	a4,a4,1014 # 80013400 <pid_lock>
    80002012:	97ba                	add	a5,a5,a4
    80002014:	0a87a703          	lw	a4,168(a5)
    80002018:	4785                	li	a5,1
    8000201a:	06f71763          	bne	a4,a5,80002088 <sched+0xa6>
  if(p->state == RUNNING)
    8000201e:	4c98                	lw	a4,24(s1)
    80002020:	4791                	li	a5,4
    80002022:	06f70b63          	beq	a4,a5,80002098 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002026:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000202a:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000202c:	efb5                	bnez	a5,800020a8 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000202e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002030:	00011917          	auipc	s2,0x11
    80002034:	3d090913          	addi	s2,s2,976 # 80013400 <pid_lock>
    80002038:	2781                	sext.w	a5,a5
    8000203a:	079e                	slli	a5,a5,0x7
    8000203c:	97ca                	add	a5,a5,s2
    8000203e:	0ac7a983          	lw	s3,172(a5)
    80002042:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002044:	2781                	sext.w	a5,a5
    80002046:	079e                	slli	a5,a5,0x7
    80002048:	00011597          	auipc	a1,0x11
    8000204c:	3f058593          	addi	a1,a1,1008 # 80013438 <cpus+0x8>
    80002050:	95be                	add	a1,a1,a5
    80002052:	06048513          	addi	a0,s1,96
    80002056:	00000097          	auipc	ra,0x0
    8000205a:	602080e7          	jalr	1538(ra) # 80002658 <swtch>
    8000205e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002060:	2781                	sext.w	a5,a5
    80002062:	079e                	slli	a5,a5,0x7
    80002064:	993e                	add	s2,s2,a5
    80002066:	0b392623          	sw	s3,172(s2)
}
    8000206a:	70a2                	ld	ra,40(sp)
    8000206c:	7402                	ld	s0,32(sp)
    8000206e:	64e2                	ld	s1,24(sp)
    80002070:	6942                	ld	s2,16(sp)
    80002072:	69a2                	ld	s3,8(sp)
    80002074:	6145                	addi	sp,sp,48
    80002076:	8082                	ret
    panic("sched p->lock");
    80002078:	00006517          	auipc	a0,0x6
    8000207c:	18050513          	addi	a0,a0,384 # 800081f8 <etext+0x1f8>
    80002080:	ffffe097          	auipc	ra,0xffffe
    80002084:	4e0080e7          	jalr	1248(ra) # 80000560 <panic>
    panic("sched locks");
    80002088:	00006517          	auipc	a0,0x6
    8000208c:	18050513          	addi	a0,a0,384 # 80008208 <etext+0x208>
    80002090:	ffffe097          	auipc	ra,0xffffe
    80002094:	4d0080e7          	jalr	1232(ra) # 80000560 <panic>
    panic("sched running");
    80002098:	00006517          	auipc	a0,0x6
    8000209c:	18050513          	addi	a0,a0,384 # 80008218 <etext+0x218>
    800020a0:	ffffe097          	auipc	ra,0xffffe
    800020a4:	4c0080e7          	jalr	1216(ra) # 80000560 <panic>
    panic("sched interruptible");
    800020a8:	00006517          	auipc	a0,0x6
    800020ac:	18050513          	addi	a0,a0,384 # 80008228 <etext+0x228>
    800020b0:	ffffe097          	auipc	ra,0xffffe
    800020b4:	4b0080e7          	jalr	1200(ra) # 80000560 <panic>

00000000800020b8 <yield>:
{
    800020b8:	1101                	addi	sp,sp,-32
    800020ba:	ec06                	sd	ra,24(sp)
    800020bc:	e822                	sd	s0,16(sp)
    800020be:	e426                	sd	s1,8(sp)
    800020c0:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020c2:	00000097          	auipc	ra,0x0
    800020c6:	988080e7          	jalr	-1656(ra) # 80001a4a <myproc>
    800020ca:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020cc:	fffff097          	auipc	ra,0xfffff
    800020d0:	b6c080e7          	jalr	-1172(ra) # 80000c38 <acquire>
  p->state = RUNNABLE;
    800020d4:	478d                	li	a5,3
    800020d6:	cc9c                	sw	a5,24(s1)
  sched();
    800020d8:	00000097          	auipc	ra,0x0
    800020dc:	f0a080e7          	jalr	-246(ra) # 80001fe2 <sched>
  release(&p->lock);
    800020e0:	8526                	mv	a0,s1
    800020e2:	fffff097          	auipc	ra,0xfffff
    800020e6:	c0a080e7          	jalr	-1014(ra) # 80000cec <release>
}
    800020ea:	60e2                	ld	ra,24(sp)
    800020ec:	6442                	ld	s0,16(sp)
    800020ee:	64a2                	ld	s1,8(sp)
    800020f0:	6105                	addi	sp,sp,32
    800020f2:	8082                	ret

00000000800020f4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020f4:	7179                	addi	sp,sp,-48
    800020f6:	f406                	sd	ra,40(sp)
    800020f8:	f022                	sd	s0,32(sp)
    800020fa:	ec26                	sd	s1,24(sp)
    800020fc:	e84a                	sd	s2,16(sp)
    800020fe:	e44e                	sd	s3,8(sp)
    80002100:	1800                	addi	s0,sp,48
    80002102:	89aa                	mv	s3,a0
    80002104:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002106:	00000097          	auipc	ra,0x0
    8000210a:	944080e7          	jalr	-1724(ra) # 80001a4a <myproc>
    8000210e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002110:	fffff097          	auipc	ra,0xfffff
    80002114:	b28080e7          	jalr	-1240(ra) # 80000c38 <acquire>
  release(lk);
    80002118:	854a                	mv	a0,s2
    8000211a:	fffff097          	auipc	ra,0xfffff
    8000211e:	bd2080e7          	jalr	-1070(ra) # 80000cec <release>

  // Go to sleep.
  p->chan = chan;
    80002122:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002126:	4789                	li	a5,2
    80002128:	cc9c                	sw	a5,24(s1)

  sched();
    8000212a:	00000097          	auipc	ra,0x0
    8000212e:	eb8080e7          	jalr	-328(ra) # 80001fe2 <sched>

  // Tidy up.
  p->chan = 0;
    80002132:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002136:	8526                	mv	a0,s1
    80002138:	fffff097          	auipc	ra,0xfffff
    8000213c:	bb4080e7          	jalr	-1100(ra) # 80000cec <release>
  acquire(lk);
    80002140:	854a                	mv	a0,s2
    80002142:	fffff097          	auipc	ra,0xfffff
    80002146:	af6080e7          	jalr	-1290(ra) # 80000c38 <acquire>
}
    8000214a:	70a2                	ld	ra,40(sp)
    8000214c:	7402                	ld	s0,32(sp)
    8000214e:	64e2                	ld	s1,24(sp)
    80002150:	6942                	ld	s2,16(sp)
    80002152:	69a2                	ld	s3,8(sp)
    80002154:	6145                	addi	sp,sp,48
    80002156:	8082                	ret

0000000080002158 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002158:	7139                	addi	sp,sp,-64
    8000215a:	fc06                	sd	ra,56(sp)
    8000215c:	f822                	sd	s0,48(sp)
    8000215e:	f426                	sd	s1,40(sp)
    80002160:	f04a                	sd	s2,32(sp)
    80002162:	ec4e                	sd	s3,24(sp)
    80002164:	e852                	sd	s4,16(sp)
    80002166:	e456                	sd	s5,8(sp)
    80002168:	0080                	addi	s0,sp,64
    8000216a:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000216c:	00011497          	auipc	s1,0x11
    80002170:	6c448493          	addi	s1,s1,1732 # 80013830 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002174:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002176:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002178:	00017917          	auipc	s2,0x17
    8000217c:	0b890913          	addi	s2,s2,184 # 80019230 <tickslock>
    80002180:	a811                	j	80002194 <wakeup+0x3c>
      }
      release(&p->lock);
    80002182:	8526                	mv	a0,s1
    80002184:	fffff097          	auipc	ra,0xfffff
    80002188:	b68080e7          	jalr	-1176(ra) # 80000cec <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000218c:	16848493          	addi	s1,s1,360
    80002190:	03248663          	beq	s1,s2,800021bc <wakeup+0x64>
    if(p != myproc()){
    80002194:	00000097          	auipc	ra,0x0
    80002198:	8b6080e7          	jalr	-1866(ra) # 80001a4a <myproc>
    8000219c:	fea488e3          	beq	s1,a0,8000218c <wakeup+0x34>
      acquire(&p->lock);
    800021a0:	8526                	mv	a0,s1
    800021a2:	fffff097          	auipc	ra,0xfffff
    800021a6:	a96080e7          	jalr	-1386(ra) # 80000c38 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800021aa:	4c9c                	lw	a5,24(s1)
    800021ac:	fd379be3          	bne	a5,s3,80002182 <wakeup+0x2a>
    800021b0:	709c                	ld	a5,32(s1)
    800021b2:	fd4798e3          	bne	a5,s4,80002182 <wakeup+0x2a>
        p->state = RUNNABLE;
    800021b6:	0154ac23          	sw	s5,24(s1)
    800021ba:	b7e1                	j	80002182 <wakeup+0x2a>
    }
  }
}
    800021bc:	70e2                	ld	ra,56(sp)
    800021be:	7442                	ld	s0,48(sp)
    800021c0:	74a2                	ld	s1,40(sp)
    800021c2:	7902                	ld	s2,32(sp)
    800021c4:	69e2                	ld	s3,24(sp)
    800021c6:	6a42                	ld	s4,16(sp)
    800021c8:	6aa2                	ld	s5,8(sp)
    800021ca:	6121                	addi	sp,sp,64
    800021cc:	8082                	ret

00000000800021ce <reparent>:
{
    800021ce:	7179                	addi	sp,sp,-48
    800021d0:	f406                	sd	ra,40(sp)
    800021d2:	f022                	sd	s0,32(sp)
    800021d4:	ec26                	sd	s1,24(sp)
    800021d6:	e84a                	sd	s2,16(sp)
    800021d8:	e44e                	sd	s3,8(sp)
    800021da:	e052                	sd	s4,0(sp)
    800021dc:	1800                	addi	s0,sp,48
    800021de:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021e0:	00011497          	auipc	s1,0x11
    800021e4:	65048493          	addi	s1,s1,1616 # 80013830 <proc>
      pp->parent = initproc;
    800021e8:	00009a17          	auipc	s4,0x9
    800021ec:	fa0a0a13          	addi	s4,s4,-96 # 8000b188 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021f0:	00017997          	auipc	s3,0x17
    800021f4:	04098993          	addi	s3,s3,64 # 80019230 <tickslock>
    800021f8:	a029                	j	80002202 <reparent+0x34>
    800021fa:	16848493          	addi	s1,s1,360
    800021fe:	01348d63          	beq	s1,s3,80002218 <reparent+0x4a>
    if(pp->parent == p){
    80002202:	7c9c                	ld	a5,56(s1)
    80002204:	ff279be3          	bne	a5,s2,800021fa <reparent+0x2c>
      pp->parent = initproc;
    80002208:	000a3503          	ld	a0,0(s4)
    8000220c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000220e:	00000097          	auipc	ra,0x0
    80002212:	f4a080e7          	jalr	-182(ra) # 80002158 <wakeup>
    80002216:	b7d5                	j	800021fa <reparent+0x2c>
}
    80002218:	70a2                	ld	ra,40(sp)
    8000221a:	7402                	ld	s0,32(sp)
    8000221c:	64e2                	ld	s1,24(sp)
    8000221e:	6942                	ld	s2,16(sp)
    80002220:	69a2                	ld	s3,8(sp)
    80002222:	6a02                	ld	s4,0(sp)
    80002224:	6145                	addi	sp,sp,48
    80002226:	8082                	ret

0000000080002228 <exit>:
{
    80002228:	7179                	addi	sp,sp,-48
    8000222a:	f406                	sd	ra,40(sp)
    8000222c:	f022                	sd	s0,32(sp)
    8000222e:	ec26                	sd	s1,24(sp)
    80002230:	e84a                	sd	s2,16(sp)
    80002232:	e44e                	sd	s3,8(sp)
    80002234:	e052                	sd	s4,0(sp)
    80002236:	1800                	addi	s0,sp,48
    80002238:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000223a:	00000097          	auipc	ra,0x0
    8000223e:	810080e7          	jalr	-2032(ra) # 80001a4a <myproc>
    80002242:	89aa                	mv	s3,a0
  if(p == initproc)
    80002244:	00009797          	auipc	a5,0x9
    80002248:	f447b783          	ld	a5,-188(a5) # 8000b188 <initproc>
    8000224c:	0d050493          	addi	s1,a0,208
    80002250:	15050913          	addi	s2,a0,336
    80002254:	02a79363          	bne	a5,a0,8000227a <exit+0x52>
    panic("init exiting");
    80002258:	00006517          	auipc	a0,0x6
    8000225c:	fe850513          	addi	a0,a0,-24 # 80008240 <etext+0x240>
    80002260:	ffffe097          	auipc	ra,0xffffe
    80002264:	300080e7          	jalr	768(ra) # 80000560 <panic>
      fileclose(f);
    80002268:	00002097          	auipc	ra,0x2
    8000226c:	324080e7          	jalr	804(ra) # 8000458c <fileclose>
      p->ofile[fd] = 0;
    80002270:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002274:	04a1                	addi	s1,s1,8
    80002276:	01248563          	beq	s1,s2,80002280 <exit+0x58>
    if(p->ofile[fd]){
    8000227a:	6088                	ld	a0,0(s1)
    8000227c:	f575                	bnez	a0,80002268 <exit+0x40>
    8000227e:	bfdd                	j	80002274 <exit+0x4c>
  begin_op();
    80002280:	00002097          	auipc	ra,0x2
    80002284:	e42080e7          	jalr	-446(ra) # 800040c2 <begin_op>
  iput(p->cwd);
    80002288:	1509b503          	ld	a0,336(s3)
    8000228c:	00001097          	auipc	ra,0x1
    80002290:	626080e7          	jalr	1574(ra) # 800038b2 <iput>
  end_op();
    80002294:	00002097          	auipc	ra,0x2
    80002298:	ea8080e7          	jalr	-344(ra) # 8000413c <end_op>
  p->cwd = 0;
    8000229c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022a0:	00011497          	auipc	s1,0x11
    800022a4:	17848493          	addi	s1,s1,376 # 80013418 <wait_lock>
    800022a8:	8526                	mv	a0,s1
    800022aa:	fffff097          	auipc	ra,0xfffff
    800022ae:	98e080e7          	jalr	-1650(ra) # 80000c38 <acquire>
  reparent(p);
    800022b2:	854e                	mv	a0,s3
    800022b4:	00000097          	auipc	ra,0x0
    800022b8:	f1a080e7          	jalr	-230(ra) # 800021ce <reparent>
  wakeup(p->parent);
    800022bc:	0389b503          	ld	a0,56(s3)
    800022c0:	00000097          	auipc	ra,0x0
    800022c4:	e98080e7          	jalr	-360(ra) # 80002158 <wakeup>
  acquire(&p->lock);
    800022c8:	854e                	mv	a0,s3
    800022ca:	fffff097          	auipc	ra,0xfffff
    800022ce:	96e080e7          	jalr	-1682(ra) # 80000c38 <acquire>
  p->xstate = status;
    800022d2:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022d6:	4795                	li	a5,5
    800022d8:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022dc:	8526                	mv	a0,s1
    800022de:	fffff097          	auipc	ra,0xfffff
    800022e2:	a0e080e7          	jalr	-1522(ra) # 80000cec <release>
  sched();
    800022e6:	00000097          	auipc	ra,0x0
    800022ea:	cfc080e7          	jalr	-772(ra) # 80001fe2 <sched>
  panic("zombie exit");
    800022ee:	00006517          	auipc	a0,0x6
    800022f2:	f6250513          	addi	a0,a0,-158 # 80008250 <etext+0x250>
    800022f6:	ffffe097          	auipc	ra,0xffffe
    800022fa:	26a080e7          	jalr	618(ra) # 80000560 <panic>

00000000800022fe <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800022fe:	7179                	addi	sp,sp,-48
    80002300:	f406                	sd	ra,40(sp)
    80002302:	f022                	sd	s0,32(sp)
    80002304:	ec26                	sd	s1,24(sp)
    80002306:	e84a                	sd	s2,16(sp)
    80002308:	e44e                	sd	s3,8(sp)
    8000230a:	1800                	addi	s0,sp,48
    8000230c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000230e:	00011497          	auipc	s1,0x11
    80002312:	52248493          	addi	s1,s1,1314 # 80013830 <proc>
    80002316:	00017997          	auipc	s3,0x17
    8000231a:	f1a98993          	addi	s3,s3,-230 # 80019230 <tickslock>
    acquire(&p->lock);
    8000231e:	8526                	mv	a0,s1
    80002320:	fffff097          	auipc	ra,0xfffff
    80002324:	918080e7          	jalr	-1768(ra) # 80000c38 <acquire>
    if(p->pid == pid){
    80002328:	589c                	lw	a5,48(s1)
    8000232a:	01278d63          	beq	a5,s2,80002344 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000232e:	8526                	mv	a0,s1
    80002330:	fffff097          	auipc	ra,0xfffff
    80002334:	9bc080e7          	jalr	-1604(ra) # 80000cec <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002338:	16848493          	addi	s1,s1,360
    8000233c:	ff3491e3          	bne	s1,s3,8000231e <kill+0x20>
  }
  return -1;
    80002340:	557d                	li	a0,-1
    80002342:	a829                	j	8000235c <kill+0x5e>
      p->killed = 1;
    80002344:	4785                	li	a5,1
    80002346:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002348:	4c98                	lw	a4,24(s1)
    8000234a:	4789                	li	a5,2
    8000234c:	00f70f63          	beq	a4,a5,8000236a <kill+0x6c>
      release(&p->lock);
    80002350:	8526                	mv	a0,s1
    80002352:	fffff097          	auipc	ra,0xfffff
    80002356:	99a080e7          	jalr	-1638(ra) # 80000cec <release>
      return 0;
    8000235a:	4501                	li	a0,0
}
    8000235c:	70a2                	ld	ra,40(sp)
    8000235e:	7402                	ld	s0,32(sp)
    80002360:	64e2                	ld	s1,24(sp)
    80002362:	6942                	ld	s2,16(sp)
    80002364:	69a2                	ld	s3,8(sp)
    80002366:	6145                	addi	sp,sp,48
    80002368:	8082                	ret
        p->state = RUNNABLE;
    8000236a:	478d                	li	a5,3
    8000236c:	cc9c                	sw	a5,24(s1)
    8000236e:	b7cd                	j	80002350 <kill+0x52>

0000000080002370 <setkilled>:

void
setkilled(struct proc *p)
{
    80002370:	1101                	addi	sp,sp,-32
    80002372:	ec06                	sd	ra,24(sp)
    80002374:	e822                	sd	s0,16(sp)
    80002376:	e426                	sd	s1,8(sp)
    80002378:	1000                	addi	s0,sp,32
    8000237a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000237c:	fffff097          	auipc	ra,0xfffff
    80002380:	8bc080e7          	jalr	-1860(ra) # 80000c38 <acquire>
  p->killed = 1;
    80002384:	4785                	li	a5,1
    80002386:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002388:	8526                	mv	a0,s1
    8000238a:	fffff097          	auipc	ra,0xfffff
    8000238e:	962080e7          	jalr	-1694(ra) # 80000cec <release>
}
    80002392:	60e2                	ld	ra,24(sp)
    80002394:	6442                	ld	s0,16(sp)
    80002396:	64a2                	ld	s1,8(sp)
    80002398:	6105                	addi	sp,sp,32
    8000239a:	8082                	ret

000000008000239c <killed>:

int
killed(struct proc *p)
{
    8000239c:	1101                	addi	sp,sp,-32
    8000239e:	ec06                	sd	ra,24(sp)
    800023a0:	e822                	sd	s0,16(sp)
    800023a2:	e426                	sd	s1,8(sp)
    800023a4:	e04a                	sd	s2,0(sp)
    800023a6:	1000                	addi	s0,sp,32
    800023a8:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800023aa:	fffff097          	auipc	ra,0xfffff
    800023ae:	88e080e7          	jalr	-1906(ra) # 80000c38 <acquire>
  k = p->killed;
    800023b2:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800023b6:	8526                	mv	a0,s1
    800023b8:	fffff097          	auipc	ra,0xfffff
    800023bc:	934080e7          	jalr	-1740(ra) # 80000cec <release>
  return k;
}
    800023c0:	854a                	mv	a0,s2
    800023c2:	60e2                	ld	ra,24(sp)
    800023c4:	6442                	ld	s0,16(sp)
    800023c6:	64a2                	ld	s1,8(sp)
    800023c8:	6902                	ld	s2,0(sp)
    800023ca:	6105                	addi	sp,sp,32
    800023cc:	8082                	ret

00000000800023ce <wait>:
{
    800023ce:	715d                	addi	sp,sp,-80
    800023d0:	e486                	sd	ra,72(sp)
    800023d2:	e0a2                	sd	s0,64(sp)
    800023d4:	fc26                	sd	s1,56(sp)
    800023d6:	f84a                	sd	s2,48(sp)
    800023d8:	f44e                	sd	s3,40(sp)
    800023da:	f052                	sd	s4,32(sp)
    800023dc:	ec56                	sd	s5,24(sp)
    800023de:	e85a                	sd	s6,16(sp)
    800023e0:	e45e                	sd	s7,8(sp)
    800023e2:	e062                	sd	s8,0(sp)
    800023e4:	0880                	addi	s0,sp,80
    800023e6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023e8:	fffff097          	auipc	ra,0xfffff
    800023ec:	662080e7          	jalr	1634(ra) # 80001a4a <myproc>
    800023f0:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023f2:	00011517          	auipc	a0,0x11
    800023f6:	02650513          	addi	a0,a0,38 # 80013418 <wait_lock>
    800023fa:	fffff097          	auipc	ra,0xfffff
    800023fe:	83e080e7          	jalr	-1986(ra) # 80000c38 <acquire>
    havekids = 0;
    80002402:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002404:	4a15                	li	s4,5
        havekids = 1;
    80002406:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002408:	00017997          	auipc	s3,0x17
    8000240c:	e2898993          	addi	s3,s3,-472 # 80019230 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002410:	00011c17          	auipc	s8,0x11
    80002414:	008c0c13          	addi	s8,s8,8 # 80013418 <wait_lock>
    80002418:	a0d1                	j	800024dc <wait+0x10e>
          pid = pp->pid;
    8000241a:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000241e:	000b0e63          	beqz	s6,8000243a <wait+0x6c>
    80002422:	4691                	li	a3,4
    80002424:	02c48613          	addi	a2,s1,44
    80002428:	85da                	mv	a1,s6
    8000242a:	05093503          	ld	a0,80(s2)
    8000242e:	fffff097          	auipc	ra,0xfffff
    80002432:	2b4080e7          	jalr	692(ra) # 800016e2 <copyout>
    80002436:	04054163          	bltz	a0,80002478 <wait+0xaa>
          freeproc(pp);
    8000243a:	8526                	mv	a0,s1
    8000243c:	fffff097          	auipc	ra,0xfffff
    80002440:	7c0080e7          	jalr	1984(ra) # 80001bfc <freeproc>
          release(&pp->lock);
    80002444:	8526                	mv	a0,s1
    80002446:	fffff097          	auipc	ra,0xfffff
    8000244a:	8a6080e7          	jalr	-1882(ra) # 80000cec <release>
          release(&wait_lock);
    8000244e:	00011517          	auipc	a0,0x11
    80002452:	fca50513          	addi	a0,a0,-54 # 80013418 <wait_lock>
    80002456:	fffff097          	auipc	ra,0xfffff
    8000245a:	896080e7          	jalr	-1898(ra) # 80000cec <release>
}
    8000245e:	854e                	mv	a0,s3
    80002460:	60a6                	ld	ra,72(sp)
    80002462:	6406                	ld	s0,64(sp)
    80002464:	74e2                	ld	s1,56(sp)
    80002466:	7942                	ld	s2,48(sp)
    80002468:	79a2                	ld	s3,40(sp)
    8000246a:	7a02                	ld	s4,32(sp)
    8000246c:	6ae2                	ld	s5,24(sp)
    8000246e:	6b42                	ld	s6,16(sp)
    80002470:	6ba2                	ld	s7,8(sp)
    80002472:	6c02                	ld	s8,0(sp)
    80002474:	6161                	addi	sp,sp,80
    80002476:	8082                	ret
            release(&pp->lock);
    80002478:	8526                	mv	a0,s1
    8000247a:	fffff097          	auipc	ra,0xfffff
    8000247e:	872080e7          	jalr	-1934(ra) # 80000cec <release>
            release(&wait_lock);
    80002482:	00011517          	auipc	a0,0x11
    80002486:	f9650513          	addi	a0,a0,-106 # 80013418 <wait_lock>
    8000248a:	fffff097          	auipc	ra,0xfffff
    8000248e:	862080e7          	jalr	-1950(ra) # 80000cec <release>
            return -1;
    80002492:	59fd                	li	s3,-1
    80002494:	b7e9                	j	8000245e <wait+0x90>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002496:	16848493          	addi	s1,s1,360
    8000249a:	03348463          	beq	s1,s3,800024c2 <wait+0xf4>
      if(pp->parent == p){
    8000249e:	7c9c                	ld	a5,56(s1)
    800024a0:	ff279be3          	bne	a5,s2,80002496 <wait+0xc8>
        acquire(&pp->lock);
    800024a4:	8526                	mv	a0,s1
    800024a6:	ffffe097          	auipc	ra,0xffffe
    800024aa:	792080e7          	jalr	1938(ra) # 80000c38 <acquire>
        if(pp->state == ZOMBIE){
    800024ae:	4c9c                	lw	a5,24(s1)
    800024b0:	f74785e3          	beq	a5,s4,8000241a <wait+0x4c>
        release(&pp->lock);
    800024b4:	8526                	mv	a0,s1
    800024b6:	fffff097          	auipc	ra,0xfffff
    800024ba:	836080e7          	jalr	-1994(ra) # 80000cec <release>
        havekids = 1;
    800024be:	8756                	mv	a4,s5
    800024c0:	bfd9                	j	80002496 <wait+0xc8>
    if(!havekids || killed(p)){
    800024c2:	c31d                	beqz	a4,800024e8 <wait+0x11a>
    800024c4:	854a                	mv	a0,s2
    800024c6:	00000097          	auipc	ra,0x0
    800024ca:	ed6080e7          	jalr	-298(ra) # 8000239c <killed>
    800024ce:	ed09                	bnez	a0,800024e8 <wait+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024d0:	85e2                	mv	a1,s8
    800024d2:	854a                	mv	a0,s2
    800024d4:	00000097          	auipc	ra,0x0
    800024d8:	c20080e7          	jalr	-992(ra) # 800020f4 <sleep>
    havekids = 0;
    800024dc:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024de:	00011497          	auipc	s1,0x11
    800024e2:	35248493          	addi	s1,s1,850 # 80013830 <proc>
    800024e6:	bf65                	j	8000249e <wait+0xd0>
      release(&wait_lock);
    800024e8:	00011517          	auipc	a0,0x11
    800024ec:	f3050513          	addi	a0,a0,-208 # 80013418 <wait_lock>
    800024f0:	ffffe097          	auipc	ra,0xffffe
    800024f4:	7fc080e7          	jalr	2044(ra) # 80000cec <release>
      return -1;
    800024f8:	59fd                	li	s3,-1
    800024fa:	b795                	j	8000245e <wait+0x90>

00000000800024fc <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024fc:	7179                	addi	sp,sp,-48
    800024fe:	f406                	sd	ra,40(sp)
    80002500:	f022                	sd	s0,32(sp)
    80002502:	ec26                	sd	s1,24(sp)
    80002504:	e84a                	sd	s2,16(sp)
    80002506:	e44e                	sd	s3,8(sp)
    80002508:	e052                	sd	s4,0(sp)
    8000250a:	1800                	addi	s0,sp,48
    8000250c:	84aa                	mv	s1,a0
    8000250e:	892e                	mv	s2,a1
    80002510:	89b2                	mv	s3,a2
    80002512:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002514:	fffff097          	auipc	ra,0xfffff
    80002518:	536080e7          	jalr	1334(ra) # 80001a4a <myproc>
  if(user_dst){
    8000251c:	c08d                	beqz	s1,8000253e <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000251e:	86d2                	mv	a3,s4
    80002520:	864e                	mv	a2,s3
    80002522:	85ca                	mv	a1,s2
    80002524:	6928                	ld	a0,80(a0)
    80002526:	fffff097          	auipc	ra,0xfffff
    8000252a:	1bc080e7          	jalr	444(ra) # 800016e2 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000252e:	70a2                	ld	ra,40(sp)
    80002530:	7402                	ld	s0,32(sp)
    80002532:	64e2                	ld	s1,24(sp)
    80002534:	6942                	ld	s2,16(sp)
    80002536:	69a2                	ld	s3,8(sp)
    80002538:	6a02                	ld	s4,0(sp)
    8000253a:	6145                	addi	sp,sp,48
    8000253c:	8082                	ret
    memmove((char *)dst, src, len);
    8000253e:	000a061b          	sext.w	a2,s4
    80002542:	85ce                	mv	a1,s3
    80002544:	854a                	mv	a0,s2
    80002546:	fffff097          	auipc	ra,0xfffff
    8000254a:	84a080e7          	jalr	-1974(ra) # 80000d90 <memmove>
    return 0;
    8000254e:	8526                	mv	a0,s1
    80002550:	bff9                	j	8000252e <either_copyout+0x32>

0000000080002552 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002552:	7179                	addi	sp,sp,-48
    80002554:	f406                	sd	ra,40(sp)
    80002556:	f022                	sd	s0,32(sp)
    80002558:	ec26                	sd	s1,24(sp)
    8000255a:	e84a                	sd	s2,16(sp)
    8000255c:	e44e                	sd	s3,8(sp)
    8000255e:	e052                	sd	s4,0(sp)
    80002560:	1800                	addi	s0,sp,48
    80002562:	892a                	mv	s2,a0
    80002564:	84ae                	mv	s1,a1
    80002566:	89b2                	mv	s3,a2
    80002568:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000256a:	fffff097          	auipc	ra,0xfffff
    8000256e:	4e0080e7          	jalr	1248(ra) # 80001a4a <myproc>
  if(user_src){
    80002572:	c08d                	beqz	s1,80002594 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002574:	86d2                	mv	a3,s4
    80002576:	864e                	mv	a2,s3
    80002578:	85ca                	mv	a1,s2
    8000257a:	6928                	ld	a0,80(a0)
    8000257c:	fffff097          	auipc	ra,0xfffff
    80002580:	1f2080e7          	jalr	498(ra) # 8000176e <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002584:	70a2                	ld	ra,40(sp)
    80002586:	7402                	ld	s0,32(sp)
    80002588:	64e2                	ld	s1,24(sp)
    8000258a:	6942                	ld	s2,16(sp)
    8000258c:	69a2                	ld	s3,8(sp)
    8000258e:	6a02                	ld	s4,0(sp)
    80002590:	6145                	addi	sp,sp,48
    80002592:	8082                	ret
    memmove(dst, (char*)src, len);
    80002594:	000a061b          	sext.w	a2,s4
    80002598:	85ce                	mv	a1,s3
    8000259a:	854a                	mv	a0,s2
    8000259c:	ffffe097          	auipc	ra,0xffffe
    800025a0:	7f4080e7          	jalr	2036(ra) # 80000d90 <memmove>
    return 0;
    800025a4:	8526                	mv	a0,s1
    800025a6:	bff9                	j	80002584 <either_copyin+0x32>

00000000800025a8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025a8:	715d                	addi	sp,sp,-80
    800025aa:	e486                	sd	ra,72(sp)
    800025ac:	e0a2                	sd	s0,64(sp)
    800025ae:	fc26                	sd	s1,56(sp)
    800025b0:	f84a                	sd	s2,48(sp)
    800025b2:	f44e                	sd	s3,40(sp)
    800025b4:	f052                	sd	s4,32(sp)
    800025b6:	ec56                	sd	s5,24(sp)
    800025b8:	e85a                	sd	s6,16(sp)
    800025ba:	e45e                	sd	s7,8(sp)
    800025bc:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800025be:	00006517          	auipc	a0,0x6
    800025c2:	a5250513          	addi	a0,a0,-1454 # 80008010 <etext+0x10>
    800025c6:	ffffe097          	auipc	ra,0xffffe
    800025ca:	fe4080e7          	jalr	-28(ra) # 800005aa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025ce:	00011497          	auipc	s1,0x11
    800025d2:	3ba48493          	addi	s1,s1,954 # 80013988 <proc+0x158>
    800025d6:	00017917          	auipc	s2,0x17
    800025da:	db290913          	addi	s2,s2,-590 # 80019388 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025de:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800025e0:	00006997          	auipc	s3,0x6
    800025e4:	c8098993          	addi	s3,s3,-896 # 80008260 <etext+0x260>
    printf("%d %s %s", p->pid, state, p->name);
    800025e8:	00006a97          	auipc	s5,0x6
    800025ec:	c80a8a93          	addi	s5,s5,-896 # 80008268 <etext+0x268>
    printf("\n");
    800025f0:	00006a17          	auipc	s4,0x6
    800025f4:	a20a0a13          	addi	s4,s4,-1504 # 80008010 <etext+0x10>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025f8:	00006b97          	auipc	s7,0x6
    800025fc:	148b8b93          	addi	s7,s7,328 # 80008740 <states.0>
    80002600:	a00d                	j	80002622 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002602:	ed86a583          	lw	a1,-296(a3)
    80002606:	8556                	mv	a0,s5
    80002608:	ffffe097          	auipc	ra,0xffffe
    8000260c:	fa2080e7          	jalr	-94(ra) # 800005aa <printf>
    printf("\n");
    80002610:	8552                	mv	a0,s4
    80002612:	ffffe097          	auipc	ra,0xffffe
    80002616:	f98080e7          	jalr	-104(ra) # 800005aa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000261a:	16848493          	addi	s1,s1,360
    8000261e:	03248263          	beq	s1,s2,80002642 <procdump+0x9a>
    if(p->state == UNUSED)
    80002622:	86a6                	mv	a3,s1
    80002624:	ec04a783          	lw	a5,-320(s1)
    80002628:	dbed                	beqz	a5,8000261a <procdump+0x72>
      state = "???";
    8000262a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000262c:	fcfb6be3          	bltu	s6,a5,80002602 <procdump+0x5a>
    80002630:	02079713          	slli	a4,a5,0x20
    80002634:	01d75793          	srli	a5,a4,0x1d
    80002638:	97de                	add	a5,a5,s7
    8000263a:	6390                	ld	a2,0(a5)
    8000263c:	f279                	bnez	a2,80002602 <procdump+0x5a>
      state = "???";
    8000263e:	864e                	mv	a2,s3
    80002640:	b7c9                	j	80002602 <procdump+0x5a>
  }
}
    80002642:	60a6                	ld	ra,72(sp)
    80002644:	6406                	ld	s0,64(sp)
    80002646:	74e2                	ld	s1,56(sp)
    80002648:	7942                	ld	s2,48(sp)
    8000264a:	79a2                	ld	s3,40(sp)
    8000264c:	7a02                	ld	s4,32(sp)
    8000264e:	6ae2                	ld	s5,24(sp)
    80002650:	6b42                	ld	s6,16(sp)
    80002652:	6ba2                	ld	s7,8(sp)
    80002654:	6161                	addi	sp,sp,80
    80002656:	8082                	ret

0000000080002658 <swtch>:
    80002658:	00153023          	sd	ra,0(a0)
    8000265c:	00253423          	sd	sp,8(a0)
    80002660:	e900                	sd	s0,16(a0)
    80002662:	ed04                	sd	s1,24(a0)
    80002664:	03253023          	sd	s2,32(a0)
    80002668:	03353423          	sd	s3,40(a0)
    8000266c:	03453823          	sd	s4,48(a0)
    80002670:	03553c23          	sd	s5,56(a0)
    80002674:	05653023          	sd	s6,64(a0)
    80002678:	05753423          	sd	s7,72(a0)
    8000267c:	05853823          	sd	s8,80(a0)
    80002680:	05953c23          	sd	s9,88(a0)
    80002684:	07a53023          	sd	s10,96(a0)
    80002688:	07b53423          	sd	s11,104(a0)
    8000268c:	0005b083          	ld	ra,0(a1)
    80002690:	0085b103          	ld	sp,8(a1)
    80002694:	6980                	ld	s0,16(a1)
    80002696:	6d84                	ld	s1,24(a1)
    80002698:	0205b903          	ld	s2,32(a1)
    8000269c:	0285b983          	ld	s3,40(a1)
    800026a0:	0305ba03          	ld	s4,48(a1)
    800026a4:	0385ba83          	ld	s5,56(a1)
    800026a8:	0405bb03          	ld	s6,64(a1)
    800026ac:	0485bb83          	ld	s7,72(a1)
    800026b0:	0505bc03          	ld	s8,80(a1)
    800026b4:	0585bc83          	ld	s9,88(a1)
    800026b8:	0605bd03          	ld	s10,96(a1)
    800026bc:	0685bd83          	ld	s11,104(a1)
    800026c0:	8082                	ret

00000000800026c2 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800026c2:	1141                	addi	sp,sp,-16
    800026c4:	e406                	sd	ra,8(sp)
    800026c6:	e022                	sd	s0,0(sp)
    800026c8:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800026ca:	00006597          	auipc	a1,0x6
    800026ce:	bde58593          	addi	a1,a1,-1058 # 800082a8 <etext+0x2a8>
    800026d2:	00017517          	auipc	a0,0x17
    800026d6:	b5e50513          	addi	a0,a0,-1186 # 80019230 <tickslock>
    800026da:	ffffe097          	auipc	ra,0xffffe
    800026de:	4ce080e7          	jalr	1230(ra) # 80000ba8 <initlock>
}
    800026e2:	60a2                	ld	ra,8(sp)
    800026e4:	6402                	ld	s0,0(sp)
    800026e6:	0141                	addi	sp,sp,16
    800026e8:	8082                	ret

00000000800026ea <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026ea:	1141                	addi	sp,sp,-16
    800026ec:	e422                	sd	s0,8(sp)
    800026ee:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026f0:	00003797          	auipc	a5,0x3
    800026f4:	5a078793          	addi	a5,a5,1440 # 80005c90 <kernelvec>
    800026f8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026fc:	6422                	ld	s0,8(sp)
    800026fe:	0141                	addi	sp,sp,16
    80002700:	8082                	ret

0000000080002702 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002702:	1141                	addi	sp,sp,-16
    80002704:	e406                	sd	ra,8(sp)
    80002706:	e022                	sd	s0,0(sp)
    80002708:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000270a:	fffff097          	auipc	ra,0xfffff
    8000270e:	340080e7          	jalr	832(ra) # 80001a4a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002712:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002716:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002718:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000271c:	00005697          	auipc	a3,0x5
    80002720:	8e468693          	addi	a3,a3,-1820 # 80007000 <_trampoline>
    80002724:	00005717          	auipc	a4,0x5
    80002728:	8dc70713          	addi	a4,a4,-1828 # 80007000 <_trampoline>
    8000272c:	8f15                	sub	a4,a4,a3
    8000272e:	040007b7          	lui	a5,0x4000
    80002732:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002734:	07b2                	slli	a5,a5,0xc
    80002736:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002738:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000273c:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000273e:	18002673          	csrr	a2,satp
    80002742:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002744:	6d30                	ld	a2,88(a0)
    80002746:	6138                	ld	a4,64(a0)
    80002748:	6585                	lui	a1,0x1
    8000274a:	972e                	add	a4,a4,a1
    8000274c:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000274e:	6d38                	ld	a4,88(a0)
    80002750:	00000617          	auipc	a2,0x0
    80002754:	13860613          	addi	a2,a2,312 # 80002888 <usertrap>
    80002758:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000275a:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000275c:	8612                	mv	a2,tp
    8000275e:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002760:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002764:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002768:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000276c:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002770:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002772:	6f18                	ld	a4,24(a4)
    80002774:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002778:	6928                	ld	a0,80(a0)
    8000277a:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000277c:	00005717          	auipc	a4,0x5
    80002780:	92070713          	addi	a4,a4,-1760 # 8000709c <userret>
    80002784:	8f15                	sub	a4,a4,a3
    80002786:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002788:	577d                	li	a4,-1
    8000278a:	177e                	slli	a4,a4,0x3f
    8000278c:	8d59                	or	a0,a0,a4
    8000278e:	9782                	jalr	a5
}
    80002790:	60a2                	ld	ra,8(sp)
    80002792:	6402                	ld	s0,0(sp)
    80002794:	0141                	addi	sp,sp,16
    80002796:	8082                	ret

0000000080002798 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002798:	1101                	addi	sp,sp,-32
    8000279a:	ec06                	sd	ra,24(sp)
    8000279c:	e822                	sd	s0,16(sp)
    8000279e:	e426                	sd	s1,8(sp)
    800027a0:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800027a2:	00017497          	auipc	s1,0x17
    800027a6:	a8e48493          	addi	s1,s1,-1394 # 80019230 <tickslock>
    800027aa:	8526                	mv	a0,s1
    800027ac:	ffffe097          	auipc	ra,0xffffe
    800027b0:	48c080e7          	jalr	1164(ra) # 80000c38 <acquire>
  ticks++;
    800027b4:	00009517          	auipc	a0,0x9
    800027b8:	9dc50513          	addi	a0,a0,-1572 # 8000b190 <ticks>
    800027bc:	411c                	lw	a5,0(a0)
    800027be:	2785                	addiw	a5,a5,1
    800027c0:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800027c2:	00000097          	auipc	ra,0x0
    800027c6:	996080e7          	jalr	-1642(ra) # 80002158 <wakeup>
  release(&tickslock);
    800027ca:	8526                	mv	a0,s1
    800027cc:	ffffe097          	auipc	ra,0xffffe
    800027d0:	520080e7          	jalr	1312(ra) # 80000cec <release>
}
    800027d4:	60e2                	ld	ra,24(sp)
    800027d6:	6442                	ld	s0,16(sp)
    800027d8:	64a2                	ld	s1,8(sp)
    800027da:	6105                	addi	sp,sp,32
    800027dc:	8082                	ret

00000000800027de <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027de:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027e2:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    800027e4:	0a07d163          	bgez	a5,80002886 <devintr+0xa8>
{
    800027e8:	1101                	addi	sp,sp,-32
    800027ea:	ec06                	sd	ra,24(sp)
    800027ec:	e822                	sd	s0,16(sp)
    800027ee:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    800027f0:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    800027f4:	46a5                	li	a3,9
    800027f6:	00d70c63          	beq	a4,a3,8000280e <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    800027fa:	577d                	li	a4,-1
    800027fc:	177e                	slli	a4,a4,0x3f
    800027fe:	0705                	addi	a4,a4,1
    return 0;
    80002800:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002802:	06e78163          	beq	a5,a4,80002864 <devintr+0x86>
  }
}
    80002806:	60e2                	ld	ra,24(sp)
    80002808:	6442                	ld	s0,16(sp)
    8000280a:	6105                	addi	sp,sp,32
    8000280c:	8082                	ret
    8000280e:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002810:	00003097          	auipc	ra,0x3
    80002814:	58c080e7          	jalr	1420(ra) # 80005d9c <plic_claim>
    80002818:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000281a:	47a9                	li	a5,10
    8000281c:	00f50963          	beq	a0,a5,8000282e <devintr+0x50>
    } else if(irq == VIRTIO0_IRQ){
    80002820:	4785                	li	a5,1
    80002822:	00f50b63          	beq	a0,a5,80002838 <devintr+0x5a>
    return 1;
    80002826:	4505                	li	a0,1
    } else if(irq){
    80002828:	ec89                	bnez	s1,80002842 <devintr+0x64>
    8000282a:	64a2                	ld	s1,8(sp)
    8000282c:	bfe9                	j	80002806 <devintr+0x28>
      uartintr();
    8000282e:	ffffe097          	auipc	ra,0xffffe
    80002832:	1cc080e7          	jalr	460(ra) # 800009fa <uartintr>
    if(irq)
    80002836:	a839                	j	80002854 <devintr+0x76>
      virtio_disk_intr();
    80002838:	00004097          	auipc	ra,0x4
    8000283c:	a8e080e7          	jalr	-1394(ra) # 800062c6 <virtio_disk_intr>
    if(irq)
    80002840:	a811                	j	80002854 <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    80002842:	85a6                	mv	a1,s1
    80002844:	00006517          	auipc	a0,0x6
    80002848:	a6c50513          	addi	a0,a0,-1428 # 800082b0 <etext+0x2b0>
    8000284c:	ffffe097          	auipc	ra,0xffffe
    80002850:	d5e080e7          	jalr	-674(ra) # 800005aa <printf>
      plic_complete(irq);
    80002854:	8526                	mv	a0,s1
    80002856:	00003097          	auipc	ra,0x3
    8000285a:	56a080e7          	jalr	1386(ra) # 80005dc0 <plic_complete>
    return 1;
    8000285e:	4505                	li	a0,1
    80002860:	64a2                	ld	s1,8(sp)
    80002862:	b755                	j	80002806 <devintr+0x28>
    if(cpuid() == 0){
    80002864:	fffff097          	auipc	ra,0xfffff
    80002868:	1ba080e7          	jalr	442(ra) # 80001a1e <cpuid>
    8000286c:	c901                	beqz	a0,8000287c <devintr+0x9e>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000286e:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002872:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002874:	14479073          	csrw	sip,a5
    return 2;
    80002878:	4509                	li	a0,2
    8000287a:	b771                	j	80002806 <devintr+0x28>
      clockintr();
    8000287c:	00000097          	auipc	ra,0x0
    80002880:	f1c080e7          	jalr	-228(ra) # 80002798 <clockintr>
    80002884:	b7ed                	j	8000286e <devintr+0x90>
}
    80002886:	8082                	ret

0000000080002888 <usertrap>:
{
    80002888:	1101                	addi	sp,sp,-32
    8000288a:	ec06                	sd	ra,24(sp)
    8000288c:	e822                	sd	s0,16(sp)
    8000288e:	e426                	sd	s1,8(sp)
    80002890:	e04a                	sd	s2,0(sp)
    80002892:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002894:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002898:	1007f793          	andi	a5,a5,256
    8000289c:	e3b1                	bnez	a5,800028e0 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000289e:	00003797          	auipc	a5,0x3
    800028a2:	3f278793          	addi	a5,a5,1010 # 80005c90 <kernelvec>
    800028a6:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800028aa:	fffff097          	auipc	ra,0xfffff
    800028ae:	1a0080e7          	jalr	416(ra) # 80001a4a <myproc>
    800028b2:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800028b4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028b6:	14102773          	csrr	a4,sepc
    800028ba:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028bc:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800028c0:	47a1                	li	a5,8
    800028c2:	02f70763          	beq	a4,a5,800028f0 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    800028c6:	00000097          	auipc	ra,0x0
    800028ca:	f18080e7          	jalr	-232(ra) # 800027de <devintr>
    800028ce:	892a                	mv	s2,a0
    800028d0:	c151                	beqz	a0,80002954 <usertrap+0xcc>
  if(killed(p))
    800028d2:	8526                	mv	a0,s1
    800028d4:	00000097          	auipc	ra,0x0
    800028d8:	ac8080e7          	jalr	-1336(ra) # 8000239c <killed>
    800028dc:	c929                	beqz	a0,8000292e <usertrap+0xa6>
    800028de:	a099                	j	80002924 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    800028e0:	00006517          	auipc	a0,0x6
    800028e4:	9f050513          	addi	a0,a0,-1552 # 800082d0 <etext+0x2d0>
    800028e8:	ffffe097          	auipc	ra,0xffffe
    800028ec:	c78080e7          	jalr	-904(ra) # 80000560 <panic>
    if(killed(p))
    800028f0:	00000097          	auipc	ra,0x0
    800028f4:	aac080e7          	jalr	-1364(ra) # 8000239c <killed>
    800028f8:	e921                	bnez	a0,80002948 <usertrap+0xc0>
    p->trapframe->epc += 4;
    800028fa:	6cb8                	ld	a4,88(s1)
    800028fc:	6f1c                	ld	a5,24(a4)
    800028fe:	0791                	addi	a5,a5,4
    80002900:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002902:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002906:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000290a:	10079073          	csrw	sstatus,a5
    syscall();
    8000290e:	00000097          	auipc	ra,0x0
    80002912:	2d4080e7          	jalr	724(ra) # 80002be2 <syscall>
  if(killed(p))
    80002916:	8526                	mv	a0,s1
    80002918:	00000097          	auipc	ra,0x0
    8000291c:	a84080e7          	jalr	-1404(ra) # 8000239c <killed>
    80002920:	c911                	beqz	a0,80002934 <usertrap+0xac>
    80002922:	4901                	li	s2,0
    exit(-1);
    80002924:	557d                	li	a0,-1
    80002926:	00000097          	auipc	ra,0x0
    8000292a:	902080e7          	jalr	-1790(ra) # 80002228 <exit>
  if(which_dev == 2)
    8000292e:	4789                	li	a5,2
    80002930:	04f90f63          	beq	s2,a5,8000298e <usertrap+0x106>
  usertrapret();
    80002934:	00000097          	auipc	ra,0x0
    80002938:	dce080e7          	jalr	-562(ra) # 80002702 <usertrapret>
}
    8000293c:	60e2                	ld	ra,24(sp)
    8000293e:	6442                	ld	s0,16(sp)
    80002940:	64a2                	ld	s1,8(sp)
    80002942:	6902                	ld	s2,0(sp)
    80002944:	6105                	addi	sp,sp,32
    80002946:	8082                	ret
      exit(-1);
    80002948:	557d                	li	a0,-1
    8000294a:	00000097          	auipc	ra,0x0
    8000294e:	8de080e7          	jalr	-1826(ra) # 80002228 <exit>
    80002952:	b765                	j	800028fa <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002954:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002958:	5890                	lw	a2,48(s1)
    8000295a:	00006517          	auipc	a0,0x6
    8000295e:	99650513          	addi	a0,a0,-1642 # 800082f0 <etext+0x2f0>
    80002962:	ffffe097          	auipc	ra,0xffffe
    80002966:	c48080e7          	jalr	-952(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000296a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000296e:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002972:	00006517          	auipc	a0,0x6
    80002976:	9ae50513          	addi	a0,a0,-1618 # 80008320 <etext+0x320>
    8000297a:	ffffe097          	auipc	ra,0xffffe
    8000297e:	c30080e7          	jalr	-976(ra) # 800005aa <printf>
    setkilled(p);
    80002982:	8526                	mv	a0,s1
    80002984:	00000097          	auipc	ra,0x0
    80002988:	9ec080e7          	jalr	-1556(ra) # 80002370 <setkilled>
    8000298c:	b769                	j	80002916 <usertrap+0x8e>
    yield();
    8000298e:	fffff097          	auipc	ra,0xfffff
    80002992:	72a080e7          	jalr	1834(ra) # 800020b8 <yield>
    80002996:	bf79                	j	80002934 <usertrap+0xac>

0000000080002998 <kerneltrap>:
{
    80002998:	7179                	addi	sp,sp,-48
    8000299a:	f406                	sd	ra,40(sp)
    8000299c:	f022                	sd	s0,32(sp)
    8000299e:	ec26                	sd	s1,24(sp)
    800029a0:	e84a                	sd	s2,16(sp)
    800029a2:	e44e                	sd	s3,8(sp)
    800029a4:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029a6:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029aa:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029ae:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800029b2:	1004f793          	andi	a5,s1,256
    800029b6:	cb85                	beqz	a5,800029e6 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029b8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029bc:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800029be:	ef85                	bnez	a5,800029f6 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800029c0:	00000097          	auipc	ra,0x0
    800029c4:	e1e080e7          	jalr	-482(ra) # 800027de <devintr>
    800029c8:	cd1d                	beqz	a0,80002a06 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029ca:	4789                	li	a5,2
    800029cc:	06f50a63          	beq	a0,a5,80002a40 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029d0:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029d4:	10049073          	csrw	sstatus,s1
}
    800029d8:	70a2                	ld	ra,40(sp)
    800029da:	7402                	ld	s0,32(sp)
    800029dc:	64e2                	ld	s1,24(sp)
    800029de:	6942                	ld	s2,16(sp)
    800029e0:	69a2                	ld	s3,8(sp)
    800029e2:	6145                	addi	sp,sp,48
    800029e4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800029e6:	00006517          	auipc	a0,0x6
    800029ea:	95a50513          	addi	a0,a0,-1702 # 80008340 <etext+0x340>
    800029ee:	ffffe097          	auipc	ra,0xffffe
    800029f2:	b72080e7          	jalr	-1166(ra) # 80000560 <panic>
    panic("kerneltrap: interrupts enabled");
    800029f6:	00006517          	auipc	a0,0x6
    800029fa:	97250513          	addi	a0,a0,-1678 # 80008368 <etext+0x368>
    800029fe:	ffffe097          	auipc	ra,0xffffe
    80002a02:	b62080e7          	jalr	-1182(ra) # 80000560 <panic>
    printf("scause %p\n", scause);
    80002a06:	85ce                	mv	a1,s3
    80002a08:	00006517          	auipc	a0,0x6
    80002a0c:	98050513          	addi	a0,a0,-1664 # 80008388 <etext+0x388>
    80002a10:	ffffe097          	auipc	ra,0xffffe
    80002a14:	b9a080e7          	jalr	-1126(ra) # 800005aa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a18:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a1c:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a20:	00006517          	auipc	a0,0x6
    80002a24:	97850513          	addi	a0,a0,-1672 # 80008398 <etext+0x398>
    80002a28:	ffffe097          	auipc	ra,0xffffe
    80002a2c:	b82080e7          	jalr	-1150(ra) # 800005aa <printf>
    panic("kerneltrap");
    80002a30:	00006517          	auipc	a0,0x6
    80002a34:	98050513          	addi	a0,a0,-1664 # 800083b0 <etext+0x3b0>
    80002a38:	ffffe097          	auipc	ra,0xffffe
    80002a3c:	b28080e7          	jalr	-1240(ra) # 80000560 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a40:	fffff097          	auipc	ra,0xfffff
    80002a44:	00a080e7          	jalr	10(ra) # 80001a4a <myproc>
    80002a48:	d541                	beqz	a0,800029d0 <kerneltrap+0x38>
    80002a4a:	fffff097          	auipc	ra,0xfffff
    80002a4e:	000080e7          	jalr	ra # 80001a4a <myproc>
    80002a52:	4d18                	lw	a4,24(a0)
    80002a54:	4791                	li	a5,4
    80002a56:	f6f71de3          	bne	a4,a5,800029d0 <kerneltrap+0x38>
    yield();
    80002a5a:	fffff097          	auipc	ra,0xfffff
    80002a5e:	65e080e7          	jalr	1630(ra) # 800020b8 <yield>
    80002a62:	b7bd                	j	800029d0 <kerneltrap+0x38>

0000000080002a64 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a64:	1101                	addi	sp,sp,-32
    80002a66:	ec06                	sd	ra,24(sp)
    80002a68:	e822                	sd	s0,16(sp)
    80002a6a:	e426                	sd	s1,8(sp)
    80002a6c:	1000                	addi	s0,sp,32
    80002a6e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a70:	fffff097          	auipc	ra,0xfffff
    80002a74:	fda080e7          	jalr	-38(ra) # 80001a4a <myproc>
  switch (n) {
    80002a78:	4795                	li	a5,5
    80002a7a:	0497e163          	bltu	a5,s1,80002abc <argraw+0x58>
    80002a7e:	048a                	slli	s1,s1,0x2
    80002a80:	00006717          	auipc	a4,0x6
    80002a84:	cf070713          	addi	a4,a4,-784 # 80008770 <states.0+0x30>
    80002a88:	94ba                	add	s1,s1,a4
    80002a8a:	409c                	lw	a5,0(s1)
    80002a8c:	97ba                	add	a5,a5,a4
    80002a8e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a90:	6d3c                	ld	a5,88(a0)
    80002a92:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a94:	60e2                	ld	ra,24(sp)
    80002a96:	6442                	ld	s0,16(sp)
    80002a98:	64a2                	ld	s1,8(sp)
    80002a9a:	6105                	addi	sp,sp,32
    80002a9c:	8082                	ret
    return p->trapframe->a1;
    80002a9e:	6d3c                	ld	a5,88(a0)
    80002aa0:	7fa8                	ld	a0,120(a5)
    80002aa2:	bfcd                	j	80002a94 <argraw+0x30>
    return p->trapframe->a2;
    80002aa4:	6d3c                	ld	a5,88(a0)
    80002aa6:	63c8                	ld	a0,128(a5)
    80002aa8:	b7f5                	j	80002a94 <argraw+0x30>
    return p->trapframe->a3;
    80002aaa:	6d3c                	ld	a5,88(a0)
    80002aac:	67c8                	ld	a0,136(a5)
    80002aae:	b7dd                	j	80002a94 <argraw+0x30>
    return p->trapframe->a4;
    80002ab0:	6d3c                	ld	a5,88(a0)
    80002ab2:	6bc8                	ld	a0,144(a5)
    80002ab4:	b7c5                	j	80002a94 <argraw+0x30>
    return p->trapframe->a5;
    80002ab6:	6d3c                	ld	a5,88(a0)
    80002ab8:	6fc8                	ld	a0,152(a5)
    80002aba:	bfe9                	j	80002a94 <argraw+0x30>
  panic("argraw");
    80002abc:	00006517          	auipc	a0,0x6
    80002ac0:	90450513          	addi	a0,a0,-1788 # 800083c0 <etext+0x3c0>
    80002ac4:	ffffe097          	auipc	ra,0xffffe
    80002ac8:	a9c080e7          	jalr	-1380(ra) # 80000560 <panic>

0000000080002acc <fetchaddr>:
{
    80002acc:	1101                	addi	sp,sp,-32
    80002ace:	ec06                	sd	ra,24(sp)
    80002ad0:	e822                	sd	s0,16(sp)
    80002ad2:	e426                	sd	s1,8(sp)
    80002ad4:	e04a                	sd	s2,0(sp)
    80002ad6:	1000                	addi	s0,sp,32
    80002ad8:	84aa                	mv	s1,a0
    80002ada:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002adc:	fffff097          	auipc	ra,0xfffff
    80002ae0:	f6e080e7          	jalr	-146(ra) # 80001a4a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002ae4:	653c                	ld	a5,72(a0)
    80002ae6:	02f4f863          	bgeu	s1,a5,80002b16 <fetchaddr+0x4a>
    80002aea:	00848713          	addi	a4,s1,8
    80002aee:	02e7e663          	bltu	a5,a4,80002b1a <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002af2:	46a1                	li	a3,8
    80002af4:	8626                	mv	a2,s1
    80002af6:	85ca                	mv	a1,s2
    80002af8:	6928                	ld	a0,80(a0)
    80002afa:	fffff097          	auipc	ra,0xfffff
    80002afe:	c74080e7          	jalr	-908(ra) # 8000176e <copyin>
    80002b02:	00a03533          	snez	a0,a0
    80002b06:	40a00533          	neg	a0,a0
}
    80002b0a:	60e2                	ld	ra,24(sp)
    80002b0c:	6442                	ld	s0,16(sp)
    80002b0e:	64a2                	ld	s1,8(sp)
    80002b10:	6902                	ld	s2,0(sp)
    80002b12:	6105                	addi	sp,sp,32
    80002b14:	8082                	ret
    return -1;
    80002b16:	557d                	li	a0,-1
    80002b18:	bfcd                	j	80002b0a <fetchaddr+0x3e>
    80002b1a:	557d                	li	a0,-1
    80002b1c:	b7fd                	j	80002b0a <fetchaddr+0x3e>

0000000080002b1e <fetchstr>:
{
    80002b1e:	7179                	addi	sp,sp,-48
    80002b20:	f406                	sd	ra,40(sp)
    80002b22:	f022                	sd	s0,32(sp)
    80002b24:	ec26                	sd	s1,24(sp)
    80002b26:	e84a                	sd	s2,16(sp)
    80002b28:	e44e                	sd	s3,8(sp)
    80002b2a:	1800                	addi	s0,sp,48
    80002b2c:	892a                	mv	s2,a0
    80002b2e:	84ae                	mv	s1,a1
    80002b30:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b32:	fffff097          	auipc	ra,0xfffff
    80002b36:	f18080e7          	jalr	-232(ra) # 80001a4a <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002b3a:	86ce                	mv	a3,s3
    80002b3c:	864a                	mv	a2,s2
    80002b3e:	85a6                	mv	a1,s1
    80002b40:	6928                	ld	a0,80(a0)
    80002b42:	fffff097          	auipc	ra,0xfffff
    80002b46:	cba080e7          	jalr	-838(ra) # 800017fc <copyinstr>
    80002b4a:	00054e63          	bltz	a0,80002b66 <fetchstr+0x48>
  return strlen(buf);
    80002b4e:	8526                	mv	a0,s1
    80002b50:	ffffe097          	auipc	ra,0xffffe
    80002b54:	358080e7          	jalr	856(ra) # 80000ea8 <strlen>
}
    80002b58:	70a2                	ld	ra,40(sp)
    80002b5a:	7402                	ld	s0,32(sp)
    80002b5c:	64e2                	ld	s1,24(sp)
    80002b5e:	6942                	ld	s2,16(sp)
    80002b60:	69a2                	ld	s3,8(sp)
    80002b62:	6145                	addi	sp,sp,48
    80002b64:	8082                	ret
    return -1;
    80002b66:	557d                	li	a0,-1
    80002b68:	bfc5                	j	80002b58 <fetchstr+0x3a>

0000000080002b6a <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002b6a:	1101                	addi	sp,sp,-32
    80002b6c:	ec06                	sd	ra,24(sp)
    80002b6e:	e822                	sd	s0,16(sp)
    80002b70:	e426                	sd	s1,8(sp)
    80002b72:	1000                	addi	s0,sp,32
    80002b74:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b76:	00000097          	auipc	ra,0x0
    80002b7a:	eee080e7          	jalr	-274(ra) # 80002a64 <argraw>
    80002b7e:	c088                	sw	a0,0(s1)
}
    80002b80:	60e2                	ld	ra,24(sp)
    80002b82:	6442                	ld	s0,16(sp)
    80002b84:	64a2                	ld	s1,8(sp)
    80002b86:	6105                	addi	sp,sp,32
    80002b88:	8082                	ret

0000000080002b8a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002b8a:	1101                	addi	sp,sp,-32
    80002b8c:	ec06                	sd	ra,24(sp)
    80002b8e:	e822                	sd	s0,16(sp)
    80002b90:	e426                	sd	s1,8(sp)
    80002b92:	1000                	addi	s0,sp,32
    80002b94:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b96:	00000097          	auipc	ra,0x0
    80002b9a:	ece080e7          	jalr	-306(ra) # 80002a64 <argraw>
    80002b9e:	e088                	sd	a0,0(s1)
}
    80002ba0:	60e2                	ld	ra,24(sp)
    80002ba2:	6442                	ld	s0,16(sp)
    80002ba4:	64a2                	ld	s1,8(sp)
    80002ba6:	6105                	addi	sp,sp,32
    80002ba8:	8082                	ret

0000000080002baa <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002baa:	7179                	addi	sp,sp,-48
    80002bac:	f406                	sd	ra,40(sp)
    80002bae:	f022                	sd	s0,32(sp)
    80002bb0:	ec26                	sd	s1,24(sp)
    80002bb2:	e84a                	sd	s2,16(sp)
    80002bb4:	1800                	addi	s0,sp,48
    80002bb6:	84ae                	mv	s1,a1
    80002bb8:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002bba:	fd840593          	addi	a1,s0,-40
    80002bbe:	00000097          	auipc	ra,0x0
    80002bc2:	fcc080e7          	jalr	-52(ra) # 80002b8a <argaddr>
  return fetchstr(addr, buf, max);
    80002bc6:	864a                	mv	a2,s2
    80002bc8:	85a6                	mv	a1,s1
    80002bca:	fd843503          	ld	a0,-40(s0)
    80002bce:	00000097          	auipc	ra,0x0
    80002bd2:	f50080e7          	jalr	-176(ra) # 80002b1e <fetchstr>
}
    80002bd6:	70a2                	ld	ra,40(sp)
    80002bd8:	7402                	ld	s0,32(sp)
    80002bda:	64e2                	ld	s1,24(sp)
    80002bdc:	6942                	ld	s2,16(sp)
    80002bde:	6145                	addi	sp,sp,48
    80002be0:	8082                	ret

0000000080002be2 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002be2:	1101                	addi	sp,sp,-32
    80002be4:	ec06                	sd	ra,24(sp)
    80002be6:	e822                	sd	s0,16(sp)
    80002be8:	e426                	sd	s1,8(sp)
    80002bea:	e04a                	sd	s2,0(sp)
    80002bec:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002bee:	fffff097          	auipc	ra,0xfffff
    80002bf2:	e5c080e7          	jalr	-420(ra) # 80001a4a <myproc>
    80002bf6:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002bf8:	05853903          	ld	s2,88(a0)
    80002bfc:	0a893783          	ld	a5,168(s2)
    80002c00:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c04:	37fd                	addiw	a5,a5,-1
    80002c06:	4751                	li	a4,20
    80002c08:	00f76f63          	bltu	a4,a5,80002c26 <syscall+0x44>
    80002c0c:	00369713          	slli	a4,a3,0x3
    80002c10:	00006797          	auipc	a5,0x6
    80002c14:	b7878793          	addi	a5,a5,-1160 # 80008788 <syscalls>
    80002c18:	97ba                	add	a5,a5,a4
    80002c1a:	639c                	ld	a5,0(a5)
    80002c1c:	c789                	beqz	a5,80002c26 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002c1e:	9782                	jalr	a5
    80002c20:	06a93823          	sd	a0,112(s2)
    80002c24:	a839                	j	80002c42 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c26:	15848613          	addi	a2,s1,344
    80002c2a:	588c                	lw	a1,48(s1)
    80002c2c:	00005517          	auipc	a0,0x5
    80002c30:	79c50513          	addi	a0,a0,1948 # 800083c8 <etext+0x3c8>
    80002c34:	ffffe097          	auipc	ra,0xffffe
    80002c38:	976080e7          	jalr	-1674(ra) # 800005aa <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c3c:	6cbc                	ld	a5,88(s1)
    80002c3e:	577d                	li	a4,-1
    80002c40:	fbb8                	sd	a4,112(a5)
  }
}
    80002c42:	60e2                	ld	ra,24(sp)
    80002c44:	6442                	ld	s0,16(sp)
    80002c46:	64a2                	ld	s1,8(sp)
    80002c48:	6902                	ld	s2,0(sp)
    80002c4a:	6105                	addi	sp,sp,32
    80002c4c:	8082                	ret

0000000080002c4e <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002c4e:	1101                	addi	sp,sp,-32
    80002c50:	ec06                	sd	ra,24(sp)
    80002c52:	e822                	sd	s0,16(sp)
    80002c54:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002c56:	fec40593          	addi	a1,s0,-20
    80002c5a:	4501                	li	a0,0
    80002c5c:	00000097          	auipc	ra,0x0
    80002c60:	f0e080e7          	jalr	-242(ra) # 80002b6a <argint>
  exit(n);
    80002c64:	fec42503          	lw	a0,-20(s0)
    80002c68:	fffff097          	auipc	ra,0xfffff
    80002c6c:	5c0080e7          	jalr	1472(ra) # 80002228 <exit>
  return 0;  // not reached
}
    80002c70:	4501                	li	a0,0
    80002c72:	60e2                	ld	ra,24(sp)
    80002c74:	6442                	ld	s0,16(sp)
    80002c76:	6105                	addi	sp,sp,32
    80002c78:	8082                	ret

0000000080002c7a <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c7a:	1141                	addi	sp,sp,-16
    80002c7c:	e406                	sd	ra,8(sp)
    80002c7e:	e022                	sd	s0,0(sp)
    80002c80:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c82:	fffff097          	auipc	ra,0xfffff
    80002c86:	dc8080e7          	jalr	-568(ra) # 80001a4a <myproc>
}
    80002c8a:	5908                	lw	a0,48(a0)
    80002c8c:	60a2                	ld	ra,8(sp)
    80002c8e:	6402                	ld	s0,0(sp)
    80002c90:	0141                	addi	sp,sp,16
    80002c92:	8082                	ret

0000000080002c94 <sys_fork>:

uint64
sys_fork(void)
{
    80002c94:	1141                	addi	sp,sp,-16
    80002c96:	e406                	sd	ra,8(sp)
    80002c98:	e022                	sd	s0,0(sp)
    80002c9a:	0800                	addi	s0,sp,16
  return fork();
    80002c9c:	fffff097          	auipc	ra,0xfffff
    80002ca0:	164080e7          	jalr	356(ra) # 80001e00 <fork>
}
    80002ca4:	60a2                	ld	ra,8(sp)
    80002ca6:	6402                	ld	s0,0(sp)
    80002ca8:	0141                	addi	sp,sp,16
    80002caa:	8082                	ret

0000000080002cac <sys_wait>:

uint64
sys_wait(void)
{
    80002cac:	1101                	addi	sp,sp,-32
    80002cae:	ec06                	sd	ra,24(sp)
    80002cb0:	e822                	sd	s0,16(sp)
    80002cb2:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002cb4:	fe840593          	addi	a1,s0,-24
    80002cb8:	4501                	li	a0,0
    80002cba:	00000097          	auipc	ra,0x0
    80002cbe:	ed0080e7          	jalr	-304(ra) # 80002b8a <argaddr>
  return wait(p);
    80002cc2:	fe843503          	ld	a0,-24(s0)
    80002cc6:	fffff097          	auipc	ra,0xfffff
    80002cca:	708080e7          	jalr	1800(ra) # 800023ce <wait>
}
    80002cce:	60e2                	ld	ra,24(sp)
    80002cd0:	6442                	ld	s0,16(sp)
    80002cd2:	6105                	addi	sp,sp,32
    80002cd4:	8082                	ret

0000000080002cd6 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002cd6:	7179                	addi	sp,sp,-48
    80002cd8:	f406                	sd	ra,40(sp)
    80002cda:	f022                	sd	s0,32(sp)
    80002cdc:	ec26                	sd	s1,24(sp)
    80002cde:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002ce0:	fdc40593          	addi	a1,s0,-36
    80002ce4:	4501                	li	a0,0
    80002ce6:	00000097          	auipc	ra,0x0
    80002cea:	e84080e7          	jalr	-380(ra) # 80002b6a <argint>
  addr = myproc()->sz;
    80002cee:	fffff097          	auipc	ra,0xfffff
    80002cf2:	d5c080e7          	jalr	-676(ra) # 80001a4a <myproc>
    80002cf6:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002cf8:	fdc42503          	lw	a0,-36(s0)
    80002cfc:	fffff097          	auipc	ra,0xfffff
    80002d00:	0a8080e7          	jalr	168(ra) # 80001da4 <growproc>
    80002d04:	00054863          	bltz	a0,80002d14 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002d08:	8526                	mv	a0,s1
    80002d0a:	70a2                	ld	ra,40(sp)
    80002d0c:	7402                	ld	s0,32(sp)
    80002d0e:	64e2                	ld	s1,24(sp)
    80002d10:	6145                	addi	sp,sp,48
    80002d12:	8082                	ret
    return -1;
    80002d14:	54fd                	li	s1,-1
    80002d16:	bfcd                	j	80002d08 <sys_sbrk+0x32>

0000000080002d18 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d18:	7139                	addi	sp,sp,-64
    80002d1a:	fc06                	sd	ra,56(sp)
    80002d1c:	f822                	sd	s0,48(sp)
    80002d1e:	f04a                	sd	s2,32(sp)
    80002d20:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002d22:	fcc40593          	addi	a1,s0,-52
    80002d26:	4501                	li	a0,0
    80002d28:	00000097          	auipc	ra,0x0
    80002d2c:	e42080e7          	jalr	-446(ra) # 80002b6a <argint>
  acquire(&tickslock);
    80002d30:	00016517          	auipc	a0,0x16
    80002d34:	50050513          	addi	a0,a0,1280 # 80019230 <tickslock>
    80002d38:	ffffe097          	auipc	ra,0xffffe
    80002d3c:	f00080e7          	jalr	-256(ra) # 80000c38 <acquire>
  ticks0 = ticks;
    80002d40:	00008917          	auipc	s2,0x8
    80002d44:	45092903          	lw	s2,1104(s2) # 8000b190 <ticks>
  while(ticks - ticks0 < n){
    80002d48:	fcc42783          	lw	a5,-52(s0)
    80002d4c:	c3b9                	beqz	a5,80002d92 <sys_sleep+0x7a>
    80002d4e:	f426                	sd	s1,40(sp)
    80002d50:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d52:	00016997          	auipc	s3,0x16
    80002d56:	4de98993          	addi	s3,s3,1246 # 80019230 <tickslock>
    80002d5a:	00008497          	auipc	s1,0x8
    80002d5e:	43648493          	addi	s1,s1,1078 # 8000b190 <ticks>
    if(killed(myproc())){
    80002d62:	fffff097          	auipc	ra,0xfffff
    80002d66:	ce8080e7          	jalr	-792(ra) # 80001a4a <myproc>
    80002d6a:	fffff097          	auipc	ra,0xfffff
    80002d6e:	632080e7          	jalr	1586(ra) # 8000239c <killed>
    80002d72:	ed15                	bnez	a0,80002dae <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002d74:	85ce                	mv	a1,s3
    80002d76:	8526                	mv	a0,s1
    80002d78:	fffff097          	auipc	ra,0xfffff
    80002d7c:	37c080e7          	jalr	892(ra) # 800020f4 <sleep>
  while(ticks - ticks0 < n){
    80002d80:	409c                	lw	a5,0(s1)
    80002d82:	412787bb          	subw	a5,a5,s2
    80002d86:	fcc42703          	lw	a4,-52(s0)
    80002d8a:	fce7ece3          	bltu	a5,a4,80002d62 <sys_sleep+0x4a>
    80002d8e:	74a2                	ld	s1,40(sp)
    80002d90:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002d92:	00016517          	auipc	a0,0x16
    80002d96:	49e50513          	addi	a0,a0,1182 # 80019230 <tickslock>
    80002d9a:	ffffe097          	auipc	ra,0xffffe
    80002d9e:	f52080e7          	jalr	-174(ra) # 80000cec <release>
  return 0;
    80002da2:	4501                	li	a0,0
}
    80002da4:	70e2                	ld	ra,56(sp)
    80002da6:	7442                	ld	s0,48(sp)
    80002da8:	7902                	ld	s2,32(sp)
    80002daa:	6121                	addi	sp,sp,64
    80002dac:	8082                	ret
      release(&tickslock);
    80002dae:	00016517          	auipc	a0,0x16
    80002db2:	48250513          	addi	a0,a0,1154 # 80019230 <tickslock>
    80002db6:	ffffe097          	auipc	ra,0xffffe
    80002dba:	f36080e7          	jalr	-202(ra) # 80000cec <release>
      return -1;
    80002dbe:	557d                	li	a0,-1
    80002dc0:	74a2                	ld	s1,40(sp)
    80002dc2:	69e2                	ld	s3,24(sp)
    80002dc4:	b7c5                	j	80002da4 <sys_sleep+0x8c>

0000000080002dc6 <sys_kill>:

uint64
sys_kill(void)
{
    80002dc6:	1101                	addi	sp,sp,-32
    80002dc8:	ec06                	sd	ra,24(sp)
    80002dca:	e822                	sd	s0,16(sp)
    80002dcc:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002dce:	fec40593          	addi	a1,s0,-20
    80002dd2:	4501                	li	a0,0
    80002dd4:	00000097          	auipc	ra,0x0
    80002dd8:	d96080e7          	jalr	-618(ra) # 80002b6a <argint>
  return kill(pid);
    80002ddc:	fec42503          	lw	a0,-20(s0)
    80002de0:	fffff097          	auipc	ra,0xfffff
    80002de4:	51e080e7          	jalr	1310(ra) # 800022fe <kill>
}
    80002de8:	60e2                	ld	ra,24(sp)
    80002dea:	6442                	ld	s0,16(sp)
    80002dec:	6105                	addi	sp,sp,32
    80002dee:	8082                	ret

0000000080002df0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002df0:	1101                	addi	sp,sp,-32
    80002df2:	ec06                	sd	ra,24(sp)
    80002df4:	e822                	sd	s0,16(sp)
    80002df6:	e426                	sd	s1,8(sp)
    80002df8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002dfa:	00016517          	auipc	a0,0x16
    80002dfe:	43650513          	addi	a0,a0,1078 # 80019230 <tickslock>
    80002e02:	ffffe097          	auipc	ra,0xffffe
    80002e06:	e36080e7          	jalr	-458(ra) # 80000c38 <acquire>
  xticks = ticks;
    80002e0a:	00008497          	auipc	s1,0x8
    80002e0e:	3864a483          	lw	s1,902(s1) # 8000b190 <ticks>
  release(&tickslock);
    80002e12:	00016517          	auipc	a0,0x16
    80002e16:	41e50513          	addi	a0,a0,1054 # 80019230 <tickslock>
    80002e1a:	ffffe097          	auipc	ra,0xffffe
    80002e1e:	ed2080e7          	jalr	-302(ra) # 80000cec <release>
  return xticks;
}
    80002e22:	02049513          	slli	a0,s1,0x20
    80002e26:	9101                	srli	a0,a0,0x20
    80002e28:	60e2                	ld	ra,24(sp)
    80002e2a:	6442                	ld	s0,16(sp)
    80002e2c:	64a2                	ld	s1,8(sp)
    80002e2e:	6105                	addi	sp,sp,32
    80002e30:	8082                	ret

0000000080002e32 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e32:	7179                	addi	sp,sp,-48
    80002e34:	f406                	sd	ra,40(sp)
    80002e36:	f022                	sd	s0,32(sp)
    80002e38:	ec26                	sd	s1,24(sp)
    80002e3a:	e84a                	sd	s2,16(sp)
    80002e3c:	e44e                	sd	s3,8(sp)
    80002e3e:	e052                	sd	s4,0(sp)
    80002e40:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e42:	00005597          	auipc	a1,0x5
    80002e46:	5a658593          	addi	a1,a1,1446 # 800083e8 <etext+0x3e8>
    80002e4a:	00016517          	auipc	a0,0x16
    80002e4e:	3fe50513          	addi	a0,a0,1022 # 80019248 <bcache>
    80002e52:	ffffe097          	auipc	ra,0xffffe
    80002e56:	d56080e7          	jalr	-682(ra) # 80000ba8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e5a:	0001e797          	auipc	a5,0x1e
    80002e5e:	3ee78793          	addi	a5,a5,1006 # 80021248 <bcache+0x8000>
    80002e62:	0001e717          	auipc	a4,0x1e
    80002e66:	64e70713          	addi	a4,a4,1614 # 800214b0 <bcache+0x8268>
    80002e6a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e6e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e72:	00016497          	auipc	s1,0x16
    80002e76:	3ee48493          	addi	s1,s1,1006 # 80019260 <bcache+0x18>
    b->next = bcache.head.next;
    80002e7a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e7c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e7e:	00005a17          	auipc	s4,0x5
    80002e82:	572a0a13          	addi	s4,s4,1394 # 800083f0 <etext+0x3f0>
    b->next = bcache.head.next;
    80002e86:	2b893783          	ld	a5,696(s2)
    80002e8a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e8c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e90:	85d2                	mv	a1,s4
    80002e92:	01048513          	addi	a0,s1,16
    80002e96:	00001097          	auipc	ra,0x1
    80002e9a:	4e8080e7          	jalr	1256(ra) # 8000437e <initsleeplock>
    bcache.head.next->prev = b;
    80002e9e:	2b893783          	ld	a5,696(s2)
    80002ea2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002ea4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ea8:	45848493          	addi	s1,s1,1112
    80002eac:	fd349de3          	bne	s1,s3,80002e86 <binit+0x54>
  }
}
    80002eb0:	70a2                	ld	ra,40(sp)
    80002eb2:	7402                	ld	s0,32(sp)
    80002eb4:	64e2                	ld	s1,24(sp)
    80002eb6:	6942                	ld	s2,16(sp)
    80002eb8:	69a2                	ld	s3,8(sp)
    80002eba:	6a02                	ld	s4,0(sp)
    80002ebc:	6145                	addi	sp,sp,48
    80002ebe:	8082                	ret

0000000080002ec0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002ec0:	7179                	addi	sp,sp,-48
    80002ec2:	f406                	sd	ra,40(sp)
    80002ec4:	f022                	sd	s0,32(sp)
    80002ec6:	ec26                	sd	s1,24(sp)
    80002ec8:	e84a                	sd	s2,16(sp)
    80002eca:	e44e                	sd	s3,8(sp)
    80002ecc:	1800                	addi	s0,sp,48
    80002ece:	892a                	mv	s2,a0
    80002ed0:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002ed2:	00016517          	auipc	a0,0x16
    80002ed6:	37650513          	addi	a0,a0,886 # 80019248 <bcache>
    80002eda:	ffffe097          	auipc	ra,0xffffe
    80002ede:	d5e080e7          	jalr	-674(ra) # 80000c38 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002ee2:	0001e497          	auipc	s1,0x1e
    80002ee6:	61e4b483          	ld	s1,1566(s1) # 80021500 <bcache+0x82b8>
    80002eea:	0001e797          	auipc	a5,0x1e
    80002eee:	5c678793          	addi	a5,a5,1478 # 800214b0 <bcache+0x8268>
    80002ef2:	02f48f63          	beq	s1,a5,80002f30 <bread+0x70>
    80002ef6:	873e                	mv	a4,a5
    80002ef8:	a021                	j	80002f00 <bread+0x40>
    80002efa:	68a4                	ld	s1,80(s1)
    80002efc:	02e48a63          	beq	s1,a4,80002f30 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f00:	449c                	lw	a5,8(s1)
    80002f02:	ff279ce3          	bne	a5,s2,80002efa <bread+0x3a>
    80002f06:	44dc                	lw	a5,12(s1)
    80002f08:	ff3799e3          	bne	a5,s3,80002efa <bread+0x3a>
      b->refcnt++;
    80002f0c:	40bc                	lw	a5,64(s1)
    80002f0e:	2785                	addiw	a5,a5,1
    80002f10:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f12:	00016517          	auipc	a0,0x16
    80002f16:	33650513          	addi	a0,a0,822 # 80019248 <bcache>
    80002f1a:	ffffe097          	auipc	ra,0xffffe
    80002f1e:	dd2080e7          	jalr	-558(ra) # 80000cec <release>
      acquiresleep(&b->lock);
    80002f22:	01048513          	addi	a0,s1,16
    80002f26:	00001097          	auipc	ra,0x1
    80002f2a:	492080e7          	jalr	1170(ra) # 800043b8 <acquiresleep>
      return b;
    80002f2e:	a8b9                	j	80002f8c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f30:	0001e497          	auipc	s1,0x1e
    80002f34:	5c84b483          	ld	s1,1480(s1) # 800214f8 <bcache+0x82b0>
    80002f38:	0001e797          	auipc	a5,0x1e
    80002f3c:	57878793          	addi	a5,a5,1400 # 800214b0 <bcache+0x8268>
    80002f40:	00f48863          	beq	s1,a5,80002f50 <bread+0x90>
    80002f44:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f46:	40bc                	lw	a5,64(s1)
    80002f48:	cf81                	beqz	a5,80002f60 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f4a:	64a4                	ld	s1,72(s1)
    80002f4c:	fee49de3          	bne	s1,a4,80002f46 <bread+0x86>
  panic("bget: no buffers");
    80002f50:	00005517          	auipc	a0,0x5
    80002f54:	4a850513          	addi	a0,a0,1192 # 800083f8 <etext+0x3f8>
    80002f58:	ffffd097          	auipc	ra,0xffffd
    80002f5c:	608080e7          	jalr	1544(ra) # 80000560 <panic>
      b->dev = dev;
    80002f60:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f64:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f68:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f6c:	4785                	li	a5,1
    80002f6e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f70:	00016517          	auipc	a0,0x16
    80002f74:	2d850513          	addi	a0,a0,728 # 80019248 <bcache>
    80002f78:	ffffe097          	auipc	ra,0xffffe
    80002f7c:	d74080e7          	jalr	-652(ra) # 80000cec <release>
      acquiresleep(&b->lock);
    80002f80:	01048513          	addi	a0,s1,16
    80002f84:	00001097          	auipc	ra,0x1
    80002f88:	434080e7          	jalr	1076(ra) # 800043b8 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f8c:	409c                	lw	a5,0(s1)
    80002f8e:	cb89                	beqz	a5,80002fa0 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f90:	8526                	mv	a0,s1
    80002f92:	70a2                	ld	ra,40(sp)
    80002f94:	7402                	ld	s0,32(sp)
    80002f96:	64e2                	ld	s1,24(sp)
    80002f98:	6942                	ld	s2,16(sp)
    80002f9a:	69a2                	ld	s3,8(sp)
    80002f9c:	6145                	addi	sp,sp,48
    80002f9e:	8082                	ret
    virtio_disk_rw(b, 0);
    80002fa0:	4581                	li	a1,0
    80002fa2:	8526                	mv	a0,s1
    80002fa4:	00003097          	auipc	ra,0x3
    80002fa8:	0f4080e7          	jalr	244(ra) # 80006098 <virtio_disk_rw>
    b->valid = 1;
    80002fac:	4785                	li	a5,1
    80002fae:	c09c                	sw	a5,0(s1)
  return b;
    80002fb0:	b7c5                	j	80002f90 <bread+0xd0>

0000000080002fb2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002fb2:	1101                	addi	sp,sp,-32
    80002fb4:	ec06                	sd	ra,24(sp)
    80002fb6:	e822                	sd	s0,16(sp)
    80002fb8:	e426                	sd	s1,8(sp)
    80002fba:	1000                	addi	s0,sp,32
    80002fbc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fbe:	0541                	addi	a0,a0,16
    80002fc0:	00001097          	auipc	ra,0x1
    80002fc4:	492080e7          	jalr	1170(ra) # 80004452 <holdingsleep>
    80002fc8:	cd01                	beqz	a0,80002fe0 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002fca:	4585                	li	a1,1
    80002fcc:	8526                	mv	a0,s1
    80002fce:	00003097          	auipc	ra,0x3
    80002fd2:	0ca080e7          	jalr	202(ra) # 80006098 <virtio_disk_rw>
}
    80002fd6:	60e2                	ld	ra,24(sp)
    80002fd8:	6442                	ld	s0,16(sp)
    80002fda:	64a2                	ld	s1,8(sp)
    80002fdc:	6105                	addi	sp,sp,32
    80002fde:	8082                	ret
    panic("bwrite");
    80002fe0:	00005517          	auipc	a0,0x5
    80002fe4:	43050513          	addi	a0,a0,1072 # 80008410 <etext+0x410>
    80002fe8:	ffffd097          	auipc	ra,0xffffd
    80002fec:	578080e7          	jalr	1400(ra) # 80000560 <panic>

0000000080002ff0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002ff0:	1101                	addi	sp,sp,-32
    80002ff2:	ec06                	sd	ra,24(sp)
    80002ff4:	e822                	sd	s0,16(sp)
    80002ff6:	e426                	sd	s1,8(sp)
    80002ff8:	e04a                	sd	s2,0(sp)
    80002ffa:	1000                	addi	s0,sp,32
    80002ffc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002ffe:	01050913          	addi	s2,a0,16
    80003002:	854a                	mv	a0,s2
    80003004:	00001097          	auipc	ra,0x1
    80003008:	44e080e7          	jalr	1102(ra) # 80004452 <holdingsleep>
    8000300c:	c925                	beqz	a0,8000307c <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    8000300e:	854a                	mv	a0,s2
    80003010:	00001097          	auipc	ra,0x1
    80003014:	3fe080e7          	jalr	1022(ra) # 8000440e <releasesleep>

  acquire(&bcache.lock);
    80003018:	00016517          	auipc	a0,0x16
    8000301c:	23050513          	addi	a0,a0,560 # 80019248 <bcache>
    80003020:	ffffe097          	auipc	ra,0xffffe
    80003024:	c18080e7          	jalr	-1000(ra) # 80000c38 <acquire>
  b->refcnt--;
    80003028:	40bc                	lw	a5,64(s1)
    8000302a:	37fd                	addiw	a5,a5,-1
    8000302c:	0007871b          	sext.w	a4,a5
    80003030:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003032:	e71d                	bnez	a4,80003060 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003034:	68b8                	ld	a4,80(s1)
    80003036:	64bc                	ld	a5,72(s1)
    80003038:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    8000303a:	68b8                	ld	a4,80(s1)
    8000303c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000303e:	0001e797          	auipc	a5,0x1e
    80003042:	20a78793          	addi	a5,a5,522 # 80021248 <bcache+0x8000>
    80003046:	2b87b703          	ld	a4,696(a5)
    8000304a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000304c:	0001e717          	auipc	a4,0x1e
    80003050:	46470713          	addi	a4,a4,1124 # 800214b0 <bcache+0x8268>
    80003054:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003056:	2b87b703          	ld	a4,696(a5)
    8000305a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000305c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003060:	00016517          	auipc	a0,0x16
    80003064:	1e850513          	addi	a0,a0,488 # 80019248 <bcache>
    80003068:	ffffe097          	auipc	ra,0xffffe
    8000306c:	c84080e7          	jalr	-892(ra) # 80000cec <release>
}
    80003070:	60e2                	ld	ra,24(sp)
    80003072:	6442                	ld	s0,16(sp)
    80003074:	64a2                	ld	s1,8(sp)
    80003076:	6902                	ld	s2,0(sp)
    80003078:	6105                	addi	sp,sp,32
    8000307a:	8082                	ret
    panic("brelse");
    8000307c:	00005517          	auipc	a0,0x5
    80003080:	39c50513          	addi	a0,a0,924 # 80008418 <etext+0x418>
    80003084:	ffffd097          	auipc	ra,0xffffd
    80003088:	4dc080e7          	jalr	1244(ra) # 80000560 <panic>

000000008000308c <bpin>:

void
bpin(struct buf *b) {
    8000308c:	1101                	addi	sp,sp,-32
    8000308e:	ec06                	sd	ra,24(sp)
    80003090:	e822                	sd	s0,16(sp)
    80003092:	e426                	sd	s1,8(sp)
    80003094:	1000                	addi	s0,sp,32
    80003096:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003098:	00016517          	auipc	a0,0x16
    8000309c:	1b050513          	addi	a0,a0,432 # 80019248 <bcache>
    800030a0:	ffffe097          	auipc	ra,0xffffe
    800030a4:	b98080e7          	jalr	-1128(ra) # 80000c38 <acquire>
  b->refcnt++;
    800030a8:	40bc                	lw	a5,64(s1)
    800030aa:	2785                	addiw	a5,a5,1
    800030ac:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030ae:	00016517          	auipc	a0,0x16
    800030b2:	19a50513          	addi	a0,a0,410 # 80019248 <bcache>
    800030b6:	ffffe097          	auipc	ra,0xffffe
    800030ba:	c36080e7          	jalr	-970(ra) # 80000cec <release>
}
    800030be:	60e2                	ld	ra,24(sp)
    800030c0:	6442                	ld	s0,16(sp)
    800030c2:	64a2                	ld	s1,8(sp)
    800030c4:	6105                	addi	sp,sp,32
    800030c6:	8082                	ret

00000000800030c8 <bunpin>:

void
bunpin(struct buf *b) {
    800030c8:	1101                	addi	sp,sp,-32
    800030ca:	ec06                	sd	ra,24(sp)
    800030cc:	e822                	sd	s0,16(sp)
    800030ce:	e426                	sd	s1,8(sp)
    800030d0:	1000                	addi	s0,sp,32
    800030d2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030d4:	00016517          	auipc	a0,0x16
    800030d8:	17450513          	addi	a0,a0,372 # 80019248 <bcache>
    800030dc:	ffffe097          	auipc	ra,0xffffe
    800030e0:	b5c080e7          	jalr	-1188(ra) # 80000c38 <acquire>
  b->refcnt--;
    800030e4:	40bc                	lw	a5,64(s1)
    800030e6:	37fd                	addiw	a5,a5,-1
    800030e8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030ea:	00016517          	auipc	a0,0x16
    800030ee:	15e50513          	addi	a0,a0,350 # 80019248 <bcache>
    800030f2:	ffffe097          	auipc	ra,0xffffe
    800030f6:	bfa080e7          	jalr	-1030(ra) # 80000cec <release>
}
    800030fa:	60e2                	ld	ra,24(sp)
    800030fc:	6442                	ld	s0,16(sp)
    800030fe:	64a2                	ld	s1,8(sp)
    80003100:	6105                	addi	sp,sp,32
    80003102:	8082                	ret

0000000080003104 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003104:	1101                	addi	sp,sp,-32
    80003106:	ec06                	sd	ra,24(sp)
    80003108:	e822                	sd	s0,16(sp)
    8000310a:	e426                	sd	s1,8(sp)
    8000310c:	e04a                	sd	s2,0(sp)
    8000310e:	1000                	addi	s0,sp,32
    80003110:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003112:	00d5d59b          	srliw	a1,a1,0xd
    80003116:	0001f797          	auipc	a5,0x1f
    8000311a:	80e7a783          	lw	a5,-2034(a5) # 80021924 <sb+0x1c>
    8000311e:	9dbd                	addw	a1,a1,a5
    80003120:	00000097          	auipc	ra,0x0
    80003124:	da0080e7          	jalr	-608(ra) # 80002ec0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003128:	0074f713          	andi	a4,s1,7
    8000312c:	4785                	li	a5,1
    8000312e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003132:	14ce                	slli	s1,s1,0x33
    80003134:	90d9                	srli	s1,s1,0x36
    80003136:	00950733          	add	a4,a0,s1
    8000313a:	05874703          	lbu	a4,88(a4)
    8000313e:	00e7f6b3          	and	a3,a5,a4
    80003142:	c69d                	beqz	a3,80003170 <bfree+0x6c>
    80003144:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003146:	94aa                	add	s1,s1,a0
    80003148:	fff7c793          	not	a5,a5
    8000314c:	8f7d                	and	a4,a4,a5
    8000314e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003152:	00001097          	auipc	ra,0x1
    80003156:	148080e7          	jalr	328(ra) # 8000429a <log_write>
  brelse(bp);
    8000315a:	854a                	mv	a0,s2
    8000315c:	00000097          	auipc	ra,0x0
    80003160:	e94080e7          	jalr	-364(ra) # 80002ff0 <brelse>
}
    80003164:	60e2                	ld	ra,24(sp)
    80003166:	6442                	ld	s0,16(sp)
    80003168:	64a2                	ld	s1,8(sp)
    8000316a:	6902                	ld	s2,0(sp)
    8000316c:	6105                	addi	sp,sp,32
    8000316e:	8082                	ret
    panic("freeing free block");
    80003170:	00005517          	auipc	a0,0x5
    80003174:	2b050513          	addi	a0,a0,688 # 80008420 <etext+0x420>
    80003178:	ffffd097          	auipc	ra,0xffffd
    8000317c:	3e8080e7          	jalr	1000(ra) # 80000560 <panic>

0000000080003180 <balloc>:
{
    80003180:	711d                	addi	sp,sp,-96
    80003182:	ec86                	sd	ra,88(sp)
    80003184:	e8a2                	sd	s0,80(sp)
    80003186:	e4a6                	sd	s1,72(sp)
    80003188:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000318a:	0001e797          	auipc	a5,0x1e
    8000318e:	7827a783          	lw	a5,1922(a5) # 8002190c <sb+0x4>
    80003192:	10078f63          	beqz	a5,800032b0 <balloc+0x130>
    80003196:	e0ca                	sd	s2,64(sp)
    80003198:	fc4e                	sd	s3,56(sp)
    8000319a:	f852                	sd	s4,48(sp)
    8000319c:	f456                	sd	s5,40(sp)
    8000319e:	f05a                	sd	s6,32(sp)
    800031a0:	ec5e                	sd	s7,24(sp)
    800031a2:	e862                	sd	s8,16(sp)
    800031a4:	e466                	sd	s9,8(sp)
    800031a6:	8baa                	mv	s7,a0
    800031a8:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800031aa:	0001eb17          	auipc	s6,0x1e
    800031ae:	75eb0b13          	addi	s6,s6,1886 # 80021908 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031b2:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800031b4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031b6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800031b8:	6c89                	lui	s9,0x2
    800031ba:	a061                	j	80003242 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800031bc:	97ca                	add	a5,a5,s2
    800031be:	8e55                	or	a2,a2,a3
    800031c0:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800031c4:	854a                	mv	a0,s2
    800031c6:	00001097          	auipc	ra,0x1
    800031ca:	0d4080e7          	jalr	212(ra) # 8000429a <log_write>
        brelse(bp);
    800031ce:	854a                	mv	a0,s2
    800031d0:	00000097          	auipc	ra,0x0
    800031d4:	e20080e7          	jalr	-480(ra) # 80002ff0 <brelse>
  bp = bread(dev, bno);
    800031d8:	85a6                	mv	a1,s1
    800031da:	855e                	mv	a0,s7
    800031dc:	00000097          	auipc	ra,0x0
    800031e0:	ce4080e7          	jalr	-796(ra) # 80002ec0 <bread>
    800031e4:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800031e6:	40000613          	li	a2,1024
    800031ea:	4581                	li	a1,0
    800031ec:	05850513          	addi	a0,a0,88
    800031f0:	ffffe097          	auipc	ra,0xffffe
    800031f4:	b44080e7          	jalr	-1212(ra) # 80000d34 <memset>
  log_write(bp);
    800031f8:	854a                	mv	a0,s2
    800031fa:	00001097          	auipc	ra,0x1
    800031fe:	0a0080e7          	jalr	160(ra) # 8000429a <log_write>
  brelse(bp);
    80003202:	854a                	mv	a0,s2
    80003204:	00000097          	auipc	ra,0x0
    80003208:	dec080e7          	jalr	-532(ra) # 80002ff0 <brelse>
}
    8000320c:	6906                	ld	s2,64(sp)
    8000320e:	79e2                	ld	s3,56(sp)
    80003210:	7a42                	ld	s4,48(sp)
    80003212:	7aa2                	ld	s5,40(sp)
    80003214:	7b02                	ld	s6,32(sp)
    80003216:	6be2                	ld	s7,24(sp)
    80003218:	6c42                	ld	s8,16(sp)
    8000321a:	6ca2                	ld	s9,8(sp)
}
    8000321c:	8526                	mv	a0,s1
    8000321e:	60e6                	ld	ra,88(sp)
    80003220:	6446                	ld	s0,80(sp)
    80003222:	64a6                	ld	s1,72(sp)
    80003224:	6125                	addi	sp,sp,96
    80003226:	8082                	ret
    brelse(bp);
    80003228:	854a                	mv	a0,s2
    8000322a:	00000097          	auipc	ra,0x0
    8000322e:	dc6080e7          	jalr	-570(ra) # 80002ff0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003232:	015c87bb          	addw	a5,s9,s5
    80003236:	00078a9b          	sext.w	s5,a5
    8000323a:	004b2703          	lw	a4,4(s6)
    8000323e:	06eaf163          	bgeu	s5,a4,800032a0 <balloc+0x120>
    bp = bread(dev, BBLOCK(b, sb));
    80003242:	41fad79b          	sraiw	a5,s5,0x1f
    80003246:	0137d79b          	srliw	a5,a5,0x13
    8000324a:	015787bb          	addw	a5,a5,s5
    8000324e:	40d7d79b          	sraiw	a5,a5,0xd
    80003252:	01cb2583          	lw	a1,28(s6)
    80003256:	9dbd                	addw	a1,a1,a5
    80003258:	855e                	mv	a0,s7
    8000325a:	00000097          	auipc	ra,0x0
    8000325e:	c66080e7          	jalr	-922(ra) # 80002ec0 <bread>
    80003262:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003264:	004b2503          	lw	a0,4(s6)
    80003268:	000a849b          	sext.w	s1,s5
    8000326c:	8762                	mv	a4,s8
    8000326e:	faa4fde3          	bgeu	s1,a0,80003228 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003272:	00777693          	andi	a3,a4,7
    80003276:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000327a:	41f7579b          	sraiw	a5,a4,0x1f
    8000327e:	01d7d79b          	srliw	a5,a5,0x1d
    80003282:	9fb9                	addw	a5,a5,a4
    80003284:	4037d79b          	sraiw	a5,a5,0x3
    80003288:	00f90633          	add	a2,s2,a5
    8000328c:	05864603          	lbu	a2,88(a2)
    80003290:	00c6f5b3          	and	a1,a3,a2
    80003294:	d585                	beqz	a1,800031bc <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003296:	2705                	addiw	a4,a4,1
    80003298:	2485                	addiw	s1,s1,1
    8000329a:	fd471ae3          	bne	a4,s4,8000326e <balloc+0xee>
    8000329e:	b769                	j	80003228 <balloc+0xa8>
    800032a0:	6906                	ld	s2,64(sp)
    800032a2:	79e2                	ld	s3,56(sp)
    800032a4:	7a42                	ld	s4,48(sp)
    800032a6:	7aa2                	ld	s5,40(sp)
    800032a8:	7b02                	ld	s6,32(sp)
    800032aa:	6be2                	ld	s7,24(sp)
    800032ac:	6c42                	ld	s8,16(sp)
    800032ae:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800032b0:	00005517          	auipc	a0,0x5
    800032b4:	18850513          	addi	a0,a0,392 # 80008438 <etext+0x438>
    800032b8:	ffffd097          	auipc	ra,0xffffd
    800032bc:	2f2080e7          	jalr	754(ra) # 800005aa <printf>
  return 0;
    800032c0:	4481                	li	s1,0
    800032c2:	bfa9                	j	8000321c <balloc+0x9c>

00000000800032c4 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800032c4:	7179                	addi	sp,sp,-48
    800032c6:	f406                	sd	ra,40(sp)
    800032c8:	f022                	sd	s0,32(sp)
    800032ca:	ec26                	sd	s1,24(sp)
    800032cc:	e84a                	sd	s2,16(sp)
    800032ce:	e44e                	sd	s3,8(sp)
    800032d0:	1800                	addi	s0,sp,48
    800032d2:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800032d4:	47ad                	li	a5,11
    800032d6:	02b7e863          	bltu	a5,a1,80003306 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800032da:	02059793          	slli	a5,a1,0x20
    800032de:	01e7d593          	srli	a1,a5,0x1e
    800032e2:	00b504b3          	add	s1,a0,a1
    800032e6:	0504a903          	lw	s2,80(s1)
    800032ea:	08091263          	bnez	s2,8000336e <bmap+0xaa>
      addr = balloc(ip->dev);
    800032ee:	4108                	lw	a0,0(a0)
    800032f0:	00000097          	auipc	ra,0x0
    800032f4:	e90080e7          	jalr	-368(ra) # 80003180 <balloc>
    800032f8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800032fc:	06090963          	beqz	s2,8000336e <bmap+0xaa>
        return 0;
      ip->addrs[bn] = addr;
    80003300:	0524a823          	sw	s2,80(s1)
    80003304:	a0ad                	j	8000336e <bmap+0xaa>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003306:	ff45849b          	addiw	s1,a1,-12
    8000330a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000330e:	0ff00793          	li	a5,255
    80003312:	08e7e863          	bltu	a5,a4,800033a2 <bmap+0xde>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003316:	08052903          	lw	s2,128(a0)
    8000331a:	00091f63          	bnez	s2,80003338 <bmap+0x74>
      addr = balloc(ip->dev);
    8000331e:	4108                	lw	a0,0(a0)
    80003320:	00000097          	auipc	ra,0x0
    80003324:	e60080e7          	jalr	-416(ra) # 80003180 <balloc>
    80003328:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000332c:	04090163          	beqz	s2,8000336e <bmap+0xaa>
    80003330:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003332:	0929a023          	sw	s2,128(s3)
    80003336:	a011                	j	8000333a <bmap+0x76>
    80003338:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000333a:	85ca                	mv	a1,s2
    8000333c:	0009a503          	lw	a0,0(s3)
    80003340:	00000097          	auipc	ra,0x0
    80003344:	b80080e7          	jalr	-1152(ra) # 80002ec0 <bread>
    80003348:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000334a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000334e:	02049713          	slli	a4,s1,0x20
    80003352:	01e75593          	srli	a1,a4,0x1e
    80003356:	00b784b3          	add	s1,a5,a1
    8000335a:	0004a903          	lw	s2,0(s1)
    8000335e:	02090063          	beqz	s2,8000337e <bmap+0xba>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003362:	8552                	mv	a0,s4
    80003364:	00000097          	auipc	ra,0x0
    80003368:	c8c080e7          	jalr	-884(ra) # 80002ff0 <brelse>
    return addr;
    8000336c:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000336e:	854a                	mv	a0,s2
    80003370:	70a2                	ld	ra,40(sp)
    80003372:	7402                	ld	s0,32(sp)
    80003374:	64e2                	ld	s1,24(sp)
    80003376:	6942                	ld	s2,16(sp)
    80003378:	69a2                	ld	s3,8(sp)
    8000337a:	6145                	addi	sp,sp,48
    8000337c:	8082                	ret
      addr = balloc(ip->dev);
    8000337e:	0009a503          	lw	a0,0(s3)
    80003382:	00000097          	auipc	ra,0x0
    80003386:	dfe080e7          	jalr	-514(ra) # 80003180 <balloc>
    8000338a:	0005091b          	sext.w	s2,a0
      if(addr){
    8000338e:	fc090ae3          	beqz	s2,80003362 <bmap+0x9e>
        a[bn] = addr;
    80003392:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003396:	8552                	mv	a0,s4
    80003398:	00001097          	auipc	ra,0x1
    8000339c:	f02080e7          	jalr	-254(ra) # 8000429a <log_write>
    800033a0:	b7c9                	j	80003362 <bmap+0x9e>
    800033a2:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800033a4:	00005517          	auipc	a0,0x5
    800033a8:	0ac50513          	addi	a0,a0,172 # 80008450 <etext+0x450>
    800033ac:	ffffd097          	auipc	ra,0xffffd
    800033b0:	1b4080e7          	jalr	436(ra) # 80000560 <panic>

00000000800033b4 <iget>:
{
    800033b4:	7179                	addi	sp,sp,-48
    800033b6:	f406                	sd	ra,40(sp)
    800033b8:	f022                	sd	s0,32(sp)
    800033ba:	ec26                	sd	s1,24(sp)
    800033bc:	e84a                	sd	s2,16(sp)
    800033be:	e44e                	sd	s3,8(sp)
    800033c0:	e052                	sd	s4,0(sp)
    800033c2:	1800                	addi	s0,sp,48
    800033c4:	89aa                	mv	s3,a0
    800033c6:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800033c8:	0001e517          	auipc	a0,0x1e
    800033cc:	56050513          	addi	a0,a0,1376 # 80021928 <itable>
    800033d0:	ffffe097          	auipc	ra,0xffffe
    800033d4:	868080e7          	jalr	-1944(ra) # 80000c38 <acquire>
  empty = 0;
    800033d8:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033da:	0001e497          	auipc	s1,0x1e
    800033de:	56648493          	addi	s1,s1,1382 # 80021940 <itable+0x18>
    800033e2:	00020697          	auipc	a3,0x20
    800033e6:	fee68693          	addi	a3,a3,-18 # 800233d0 <log>
    800033ea:	a039                	j	800033f8 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033ec:	02090b63          	beqz	s2,80003422 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033f0:	08848493          	addi	s1,s1,136
    800033f4:	02d48a63          	beq	s1,a3,80003428 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800033f8:	449c                	lw	a5,8(s1)
    800033fa:	fef059e3          	blez	a5,800033ec <iget+0x38>
    800033fe:	4098                	lw	a4,0(s1)
    80003400:	ff3716e3          	bne	a4,s3,800033ec <iget+0x38>
    80003404:	40d8                	lw	a4,4(s1)
    80003406:	ff4713e3          	bne	a4,s4,800033ec <iget+0x38>
      ip->ref++;
    8000340a:	2785                	addiw	a5,a5,1
    8000340c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000340e:	0001e517          	auipc	a0,0x1e
    80003412:	51a50513          	addi	a0,a0,1306 # 80021928 <itable>
    80003416:	ffffe097          	auipc	ra,0xffffe
    8000341a:	8d6080e7          	jalr	-1834(ra) # 80000cec <release>
      return ip;
    8000341e:	8926                	mv	s2,s1
    80003420:	a03d                	j	8000344e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003422:	f7f9                	bnez	a5,800033f0 <iget+0x3c>
      empty = ip;
    80003424:	8926                	mv	s2,s1
    80003426:	b7e9                	j	800033f0 <iget+0x3c>
  if(empty == 0)
    80003428:	02090c63          	beqz	s2,80003460 <iget+0xac>
  ip->dev = dev;
    8000342c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003430:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003434:	4785                	li	a5,1
    80003436:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000343a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000343e:	0001e517          	auipc	a0,0x1e
    80003442:	4ea50513          	addi	a0,a0,1258 # 80021928 <itable>
    80003446:	ffffe097          	auipc	ra,0xffffe
    8000344a:	8a6080e7          	jalr	-1882(ra) # 80000cec <release>
}
    8000344e:	854a                	mv	a0,s2
    80003450:	70a2                	ld	ra,40(sp)
    80003452:	7402                	ld	s0,32(sp)
    80003454:	64e2                	ld	s1,24(sp)
    80003456:	6942                	ld	s2,16(sp)
    80003458:	69a2                	ld	s3,8(sp)
    8000345a:	6a02                	ld	s4,0(sp)
    8000345c:	6145                	addi	sp,sp,48
    8000345e:	8082                	ret
    panic("iget: no inodes");
    80003460:	00005517          	auipc	a0,0x5
    80003464:	00850513          	addi	a0,a0,8 # 80008468 <etext+0x468>
    80003468:	ffffd097          	auipc	ra,0xffffd
    8000346c:	0f8080e7          	jalr	248(ra) # 80000560 <panic>

0000000080003470 <fsinit>:
fsinit(int dev) {
    80003470:	7179                	addi	sp,sp,-48
    80003472:	f406                	sd	ra,40(sp)
    80003474:	f022                	sd	s0,32(sp)
    80003476:	ec26                	sd	s1,24(sp)
    80003478:	e84a                	sd	s2,16(sp)
    8000347a:	e44e                	sd	s3,8(sp)
    8000347c:	1800                	addi	s0,sp,48
    8000347e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003480:	4585                	li	a1,1
    80003482:	00000097          	auipc	ra,0x0
    80003486:	a3e080e7          	jalr	-1474(ra) # 80002ec0 <bread>
    8000348a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000348c:	0001e997          	auipc	s3,0x1e
    80003490:	47c98993          	addi	s3,s3,1148 # 80021908 <sb>
    80003494:	02000613          	li	a2,32
    80003498:	05850593          	addi	a1,a0,88
    8000349c:	854e                	mv	a0,s3
    8000349e:	ffffe097          	auipc	ra,0xffffe
    800034a2:	8f2080e7          	jalr	-1806(ra) # 80000d90 <memmove>
  brelse(bp);
    800034a6:	8526                	mv	a0,s1
    800034a8:	00000097          	auipc	ra,0x0
    800034ac:	b48080e7          	jalr	-1208(ra) # 80002ff0 <brelse>
  if(sb.magic != FSMAGIC)
    800034b0:	0009a703          	lw	a4,0(s3)
    800034b4:	102037b7          	lui	a5,0x10203
    800034b8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800034bc:	02f71263          	bne	a4,a5,800034e0 <fsinit+0x70>
  initlog(dev, &sb);
    800034c0:	0001e597          	auipc	a1,0x1e
    800034c4:	44858593          	addi	a1,a1,1096 # 80021908 <sb>
    800034c8:	854a                	mv	a0,s2
    800034ca:	00001097          	auipc	ra,0x1
    800034ce:	b60080e7          	jalr	-1184(ra) # 8000402a <initlog>
}
    800034d2:	70a2                	ld	ra,40(sp)
    800034d4:	7402                	ld	s0,32(sp)
    800034d6:	64e2                	ld	s1,24(sp)
    800034d8:	6942                	ld	s2,16(sp)
    800034da:	69a2                	ld	s3,8(sp)
    800034dc:	6145                	addi	sp,sp,48
    800034de:	8082                	ret
    panic("invalid file system");
    800034e0:	00005517          	auipc	a0,0x5
    800034e4:	f9850513          	addi	a0,a0,-104 # 80008478 <etext+0x478>
    800034e8:	ffffd097          	auipc	ra,0xffffd
    800034ec:	078080e7          	jalr	120(ra) # 80000560 <panic>

00000000800034f0 <iinit>:
{
    800034f0:	7179                	addi	sp,sp,-48
    800034f2:	f406                	sd	ra,40(sp)
    800034f4:	f022                	sd	s0,32(sp)
    800034f6:	ec26                	sd	s1,24(sp)
    800034f8:	e84a                	sd	s2,16(sp)
    800034fa:	e44e                	sd	s3,8(sp)
    800034fc:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800034fe:	00005597          	auipc	a1,0x5
    80003502:	f9258593          	addi	a1,a1,-110 # 80008490 <etext+0x490>
    80003506:	0001e517          	auipc	a0,0x1e
    8000350a:	42250513          	addi	a0,a0,1058 # 80021928 <itable>
    8000350e:	ffffd097          	auipc	ra,0xffffd
    80003512:	69a080e7          	jalr	1690(ra) # 80000ba8 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003516:	0001e497          	auipc	s1,0x1e
    8000351a:	43a48493          	addi	s1,s1,1082 # 80021950 <itable+0x28>
    8000351e:	00020997          	auipc	s3,0x20
    80003522:	ec298993          	addi	s3,s3,-318 # 800233e0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003526:	00005917          	auipc	s2,0x5
    8000352a:	f7290913          	addi	s2,s2,-142 # 80008498 <etext+0x498>
    8000352e:	85ca                	mv	a1,s2
    80003530:	8526                	mv	a0,s1
    80003532:	00001097          	auipc	ra,0x1
    80003536:	e4c080e7          	jalr	-436(ra) # 8000437e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000353a:	08848493          	addi	s1,s1,136
    8000353e:	ff3498e3          	bne	s1,s3,8000352e <iinit+0x3e>
}
    80003542:	70a2                	ld	ra,40(sp)
    80003544:	7402                	ld	s0,32(sp)
    80003546:	64e2                	ld	s1,24(sp)
    80003548:	6942                	ld	s2,16(sp)
    8000354a:	69a2                	ld	s3,8(sp)
    8000354c:	6145                	addi	sp,sp,48
    8000354e:	8082                	ret

0000000080003550 <ialloc>:
{
    80003550:	7139                	addi	sp,sp,-64
    80003552:	fc06                	sd	ra,56(sp)
    80003554:	f822                	sd	s0,48(sp)
    80003556:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003558:	0001e717          	auipc	a4,0x1e
    8000355c:	3bc72703          	lw	a4,956(a4) # 80021914 <sb+0xc>
    80003560:	4785                	li	a5,1
    80003562:	06e7f463          	bgeu	a5,a4,800035ca <ialloc+0x7a>
    80003566:	f426                	sd	s1,40(sp)
    80003568:	f04a                	sd	s2,32(sp)
    8000356a:	ec4e                	sd	s3,24(sp)
    8000356c:	e852                	sd	s4,16(sp)
    8000356e:	e456                	sd	s5,8(sp)
    80003570:	e05a                	sd	s6,0(sp)
    80003572:	8aaa                	mv	s5,a0
    80003574:	8b2e                	mv	s6,a1
    80003576:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003578:	0001ea17          	auipc	s4,0x1e
    8000357c:	390a0a13          	addi	s4,s4,912 # 80021908 <sb>
    80003580:	00495593          	srli	a1,s2,0x4
    80003584:	018a2783          	lw	a5,24(s4)
    80003588:	9dbd                	addw	a1,a1,a5
    8000358a:	8556                	mv	a0,s5
    8000358c:	00000097          	auipc	ra,0x0
    80003590:	934080e7          	jalr	-1740(ra) # 80002ec0 <bread>
    80003594:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003596:	05850993          	addi	s3,a0,88
    8000359a:	00f97793          	andi	a5,s2,15
    8000359e:	079a                	slli	a5,a5,0x6
    800035a0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800035a2:	00099783          	lh	a5,0(s3)
    800035a6:	cf9d                	beqz	a5,800035e4 <ialloc+0x94>
    brelse(bp);
    800035a8:	00000097          	auipc	ra,0x0
    800035ac:	a48080e7          	jalr	-1464(ra) # 80002ff0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800035b0:	0905                	addi	s2,s2,1
    800035b2:	00ca2703          	lw	a4,12(s4)
    800035b6:	0009079b          	sext.w	a5,s2
    800035ba:	fce7e3e3          	bltu	a5,a4,80003580 <ialloc+0x30>
    800035be:	74a2                	ld	s1,40(sp)
    800035c0:	7902                	ld	s2,32(sp)
    800035c2:	69e2                	ld	s3,24(sp)
    800035c4:	6a42                	ld	s4,16(sp)
    800035c6:	6aa2                	ld	s5,8(sp)
    800035c8:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800035ca:	00005517          	auipc	a0,0x5
    800035ce:	ed650513          	addi	a0,a0,-298 # 800084a0 <etext+0x4a0>
    800035d2:	ffffd097          	auipc	ra,0xffffd
    800035d6:	fd8080e7          	jalr	-40(ra) # 800005aa <printf>
  return 0;
    800035da:	4501                	li	a0,0
}
    800035dc:	70e2                	ld	ra,56(sp)
    800035de:	7442                	ld	s0,48(sp)
    800035e0:	6121                	addi	sp,sp,64
    800035e2:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800035e4:	04000613          	li	a2,64
    800035e8:	4581                	li	a1,0
    800035ea:	854e                	mv	a0,s3
    800035ec:	ffffd097          	auipc	ra,0xffffd
    800035f0:	748080e7          	jalr	1864(ra) # 80000d34 <memset>
      dip->type = type;
    800035f4:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800035f8:	8526                	mv	a0,s1
    800035fa:	00001097          	auipc	ra,0x1
    800035fe:	ca0080e7          	jalr	-864(ra) # 8000429a <log_write>
      brelse(bp);
    80003602:	8526                	mv	a0,s1
    80003604:	00000097          	auipc	ra,0x0
    80003608:	9ec080e7          	jalr	-1556(ra) # 80002ff0 <brelse>
      return iget(dev, inum);
    8000360c:	0009059b          	sext.w	a1,s2
    80003610:	8556                	mv	a0,s5
    80003612:	00000097          	auipc	ra,0x0
    80003616:	da2080e7          	jalr	-606(ra) # 800033b4 <iget>
    8000361a:	74a2                	ld	s1,40(sp)
    8000361c:	7902                	ld	s2,32(sp)
    8000361e:	69e2                	ld	s3,24(sp)
    80003620:	6a42                	ld	s4,16(sp)
    80003622:	6aa2                	ld	s5,8(sp)
    80003624:	6b02                	ld	s6,0(sp)
    80003626:	bf5d                	j	800035dc <ialloc+0x8c>

0000000080003628 <iupdate>:
{
    80003628:	1101                	addi	sp,sp,-32
    8000362a:	ec06                	sd	ra,24(sp)
    8000362c:	e822                	sd	s0,16(sp)
    8000362e:	e426                	sd	s1,8(sp)
    80003630:	e04a                	sd	s2,0(sp)
    80003632:	1000                	addi	s0,sp,32
    80003634:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003636:	415c                	lw	a5,4(a0)
    80003638:	0047d79b          	srliw	a5,a5,0x4
    8000363c:	0001e597          	auipc	a1,0x1e
    80003640:	2e45a583          	lw	a1,740(a1) # 80021920 <sb+0x18>
    80003644:	9dbd                	addw	a1,a1,a5
    80003646:	4108                	lw	a0,0(a0)
    80003648:	00000097          	auipc	ra,0x0
    8000364c:	878080e7          	jalr	-1928(ra) # 80002ec0 <bread>
    80003650:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003652:	05850793          	addi	a5,a0,88
    80003656:	40d8                	lw	a4,4(s1)
    80003658:	8b3d                	andi	a4,a4,15
    8000365a:	071a                	slli	a4,a4,0x6
    8000365c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000365e:	04449703          	lh	a4,68(s1)
    80003662:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003666:	04649703          	lh	a4,70(s1)
    8000366a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000366e:	04849703          	lh	a4,72(s1)
    80003672:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003676:	04a49703          	lh	a4,74(s1)
    8000367a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000367e:	44f8                	lw	a4,76(s1)
    80003680:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003682:	03400613          	li	a2,52
    80003686:	05048593          	addi	a1,s1,80
    8000368a:	00c78513          	addi	a0,a5,12
    8000368e:	ffffd097          	auipc	ra,0xffffd
    80003692:	702080e7          	jalr	1794(ra) # 80000d90 <memmove>
  log_write(bp);
    80003696:	854a                	mv	a0,s2
    80003698:	00001097          	auipc	ra,0x1
    8000369c:	c02080e7          	jalr	-1022(ra) # 8000429a <log_write>
  brelse(bp);
    800036a0:	854a                	mv	a0,s2
    800036a2:	00000097          	auipc	ra,0x0
    800036a6:	94e080e7          	jalr	-1714(ra) # 80002ff0 <brelse>
}
    800036aa:	60e2                	ld	ra,24(sp)
    800036ac:	6442                	ld	s0,16(sp)
    800036ae:	64a2                	ld	s1,8(sp)
    800036b0:	6902                	ld	s2,0(sp)
    800036b2:	6105                	addi	sp,sp,32
    800036b4:	8082                	ret

00000000800036b6 <idup>:
{
    800036b6:	1101                	addi	sp,sp,-32
    800036b8:	ec06                	sd	ra,24(sp)
    800036ba:	e822                	sd	s0,16(sp)
    800036bc:	e426                	sd	s1,8(sp)
    800036be:	1000                	addi	s0,sp,32
    800036c0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800036c2:	0001e517          	auipc	a0,0x1e
    800036c6:	26650513          	addi	a0,a0,614 # 80021928 <itable>
    800036ca:	ffffd097          	auipc	ra,0xffffd
    800036ce:	56e080e7          	jalr	1390(ra) # 80000c38 <acquire>
  ip->ref++;
    800036d2:	449c                	lw	a5,8(s1)
    800036d4:	2785                	addiw	a5,a5,1
    800036d6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800036d8:	0001e517          	auipc	a0,0x1e
    800036dc:	25050513          	addi	a0,a0,592 # 80021928 <itable>
    800036e0:	ffffd097          	auipc	ra,0xffffd
    800036e4:	60c080e7          	jalr	1548(ra) # 80000cec <release>
}
    800036e8:	8526                	mv	a0,s1
    800036ea:	60e2                	ld	ra,24(sp)
    800036ec:	6442                	ld	s0,16(sp)
    800036ee:	64a2                	ld	s1,8(sp)
    800036f0:	6105                	addi	sp,sp,32
    800036f2:	8082                	ret

00000000800036f4 <ilock>:
{
    800036f4:	1101                	addi	sp,sp,-32
    800036f6:	ec06                	sd	ra,24(sp)
    800036f8:	e822                	sd	s0,16(sp)
    800036fa:	e426                	sd	s1,8(sp)
    800036fc:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800036fe:	c10d                	beqz	a0,80003720 <ilock+0x2c>
    80003700:	84aa                	mv	s1,a0
    80003702:	451c                	lw	a5,8(a0)
    80003704:	00f05e63          	blez	a5,80003720 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003708:	0541                	addi	a0,a0,16
    8000370a:	00001097          	auipc	ra,0x1
    8000370e:	cae080e7          	jalr	-850(ra) # 800043b8 <acquiresleep>
  if(ip->valid == 0){
    80003712:	40bc                	lw	a5,64(s1)
    80003714:	cf99                	beqz	a5,80003732 <ilock+0x3e>
}
    80003716:	60e2                	ld	ra,24(sp)
    80003718:	6442                	ld	s0,16(sp)
    8000371a:	64a2                	ld	s1,8(sp)
    8000371c:	6105                	addi	sp,sp,32
    8000371e:	8082                	ret
    80003720:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003722:	00005517          	auipc	a0,0x5
    80003726:	d9650513          	addi	a0,a0,-618 # 800084b8 <etext+0x4b8>
    8000372a:	ffffd097          	auipc	ra,0xffffd
    8000372e:	e36080e7          	jalr	-458(ra) # 80000560 <panic>
    80003732:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003734:	40dc                	lw	a5,4(s1)
    80003736:	0047d79b          	srliw	a5,a5,0x4
    8000373a:	0001e597          	auipc	a1,0x1e
    8000373e:	1e65a583          	lw	a1,486(a1) # 80021920 <sb+0x18>
    80003742:	9dbd                	addw	a1,a1,a5
    80003744:	4088                	lw	a0,0(s1)
    80003746:	fffff097          	auipc	ra,0xfffff
    8000374a:	77a080e7          	jalr	1914(ra) # 80002ec0 <bread>
    8000374e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003750:	05850593          	addi	a1,a0,88
    80003754:	40dc                	lw	a5,4(s1)
    80003756:	8bbd                	andi	a5,a5,15
    80003758:	079a                	slli	a5,a5,0x6
    8000375a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000375c:	00059783          	lh	a5,0(a1)
    80003760:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003764:	00259783          	lh	a5,2(a1)
    80003768:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000376c:	00459783          	lh	a5,4(a1)
    80003770:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003774:	00659783          	lh	a5,6(a1)
    80003778:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000377c:	459c                	lw	a5,8(a1)
    8000377e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003780:	03400613          	li	a2,52
    80003784:	05b1                	addi	a1,a1,12
    80003786:	05048513          	addi	a0,s1,80
    8000378a:	ffffd097          	auipc	ra,0xffffd
    8000378e:	606080e7          	jalr	1542(ra) # 80000d90 <memmove>
    brelse(bp);
    80003792:	854a                	mv	a0,s2
    80003794:	00000097          	auipc	ra,0x0
    80003798:	85c080e7          	jalr	-1956(ra) # 80002ff0 <brelse>
    ip->valid = 1;
    8000379c:	4785                	li	a5,1
    8000379e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800037a0:	04449783          	lh	a5,68(s1)
    800037a4:	c399                	beqz	a5,800037aa <ilock+0xb6>
    800037a6:	6902                	ld	s2,0(sp)
    800037a8:	b7bd                	j	80003716 <ilock+0x22>
      panic("ilock: no type");
    800037aa:	00005517          	auipc	a0,0x5
    800037ae:	d1650513          	addi	a0,a0,-746 # 800084c0 <etext+0x4c0>
    800037b2:	ffffd097          	auipc	ra,0xffffd
    800037b6:	dae080e7          	jalr	-594(ra) # 80000560 <panic>

00000000800037ba <iunlock>:
{
    800037ba:	1101                	addi	sp,sp,-32
    800037bc:	ec06                	sd	ra,24(sp)
    800037be:	e822                	sd	s0,16(sp)
    800037c0:	e426                	sd	s1,8(sp)
    800037c2:	e04a                	sd	s2,0(sp)
    800037c4:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800037c6:	c905                	beqz	a0,800037f6 <iunlock+0x3c>
    800037c8:	84aa                	mv	s1,a0
    800037ca:	01050913          	addi	s2,a0,16
    800037ce:	854a                	mv	a0,s2
    800037d0:	00001097          	auipc	ra,0x1
    800037d4:	c82080e7          	jalr	-894(ra) # 80004452 <holdingsleep>
    800037d8:	cd19                	beqz	a0,800037f6 <iunlock+0x3c>
    800037da:	449c                	lw	a5,8(s1)
    800037dc:	00f05d63          	blez	a5,800037f6 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800037e0:	854a                	mv	a0,s2
    800037e2:	00001097          	auipc	ra,0x1
    800037e6:	c2c080e7          	jalr	-980(ra) # 8000440e <releasesleep>
}
    800037ea:	60e2                	ld	ra,24(sp)
    800037ec:	6442                	ld	s0,16(sp)
    800037ee:	64a2                	ld	s1,8(sp)
    800037f0:	6902                	ld	s2,0(sp)
    800037f2:	6105                	addi	sp,sp,32
    800037f4:	8082                	ret
    panic("iunlock");
    800037f6:	00005517          	auipc	a0,0x5
    800037fa:	cda50513          	addi	a0,a0,-806 # 800084d0 <etext+0x4d0>
    800037fe:	ffffd097          	auipc	ra,0xffffd
    80003802:	d62080e7          	jalr	-670(ra) # 80000560 <panic>

0000000080003806 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003806:	7179                	addi	sp,sp,-48
    80003808:	f406                	sd	ra,40(sp)
    8000380a:	f022                	sd	s0,32(sp)
    8000380c:	ec26                	sd	s1,24(sp)
    8000380e:	e84a                	sd	s2,16(sp)
    80003810:	e44e                	sd	s3,8(sp)
    80003812:	1800                	addi	s0,sp,48
    80003814:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003816:	05050493          	addi	s1,a0,80
    8000381a:	08050913          	addi	s2,a0,128
    8000381e:	a021                	j	80003826 <itrunc+0x20>
    80003820:	0491                	addi	s1,s1,4
    80003822:	01248d63          	beq	s1,s2,8000383c <itrunc+0x36>
    if(ip->addrs[i]){
    80003826:	408c                	lw	a1,0(s1)
    80003828:	dde5                	beqz	a1,80003820 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000382a:	0009a503          	lw	a0,0(s3)
    8000382e:	00000097          	auipc	ra,0x0
    80003832:	8d6080e7          	jalr	-1834(ra) # 80003104 <bfree>
      ip->addrs[i] = 0;
    80003836:	0004a023          	sw	zero,0(s1)
    8000383a:	b7dd                	j	80003820 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000383c:	0809a583          	lw	a1,128(s3)
    80003840:	ed99                	bnez	a1,8000385e <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003842:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003846:	854e                	mv	a0,s3
    80003848:	00000097          	auipc	ra,0x0
    8000384c:	de0080e7          	jalr	-544(ra) # 80003628 <iupdate>
}
    80003850:	70a2                	ld	ra,40(sp)
    80003852:	7402                	ld	s0,32(sp)
    80003854:	64e2                	ld	s1,24(sp)
    80003856:	6942                	ld	s2,16(sp)
    80003858:	69a2                	ld	s3,8(sp)
    8000385a:	6145                	addi	sp,sp,48
    8000385c:	8082                	ret
    8000385e:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003860:	0009a503          	lw	a0,0(s3)
    80003864:	fffff097          	auipc	ra,0xfffff
    80003868:	65c080e7          	jalr	1628(ra) # 80002ec0 <bread>
    8000386c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000386e:	05850493          	addi	s1,a0,88
    80003872:	45850913          	addi	s2,a0,1112
    80003876:	a021                	j	8000387e <itrunc+0x78>
    80003878:	0491                	addi	s1,s1,4
    8000387a:	01248b63          	beq	s1,s2,80003890 <itrunc+0x8a>
      if(a[j])
    8000387e:	408c                	lw	a1,0(s1)
    80003880:	dde5                	beqz	a1,80003878 <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80003882:	0009a503          	lw	a0,0(s3)
    80003886:	00000097          	auipc	ra,0x0
    8000388a:	87e080e7          	jalr	-1922(ra) # 80003104 <bfree>
    8000388e:	b7ed                	j	80003878 <itrunc+0x72>
    brelse(bp);
    80003890:	8552                	mv	a0,s4
    80003892:	fffff097          	auipc	ra,0xfffff
    80003896:	75e080e7          	jalr	1886(ra) # 80002ff0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000389a:	0809a583          	lw	a1,128(s3)
    8000389e:	0009a503          	lw	a0,0(s3)
    800038a2:	00000097          	auipc	ra,0x0
    800038a6:	862080e7          	jalr	-1950(ra) # 80003104 <bfree>
    ip->addrs[NDIRECT] = 0;
    800038aa:	0809a023          	sw	zero,128(s3)
    800038ae:	6a02                	ld	s4,0(sp)
    800038b0:	bf49                	j	80003842 <itrunc+0x3c>

00000000800038b2 <iput>:
{
    800038b2:	1101                	addi	sp,sp,-32
    800038b4:	ec06                	sd	ra,24(sp)
    800038b6:	e822                	sd	s0,16(sp)
    800038b8:	e426                	sd	s1,8(sp)
    800038ba:	1000                	addi	s0,sp,32
    800038bc:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038be:	0001e517          	auipc	a0,0x1e
    800038c2:	06a50513          	addi	a0,a0,106 # 80021928 <itable>
    800038c6:	ffffd097          	auipc	ra,0xffffd
    800038ca:	372080e7          	jalr	882(ra) # 80000c38 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038ce:	4498                	lw	a4,8(s1)
    800038d0:	4785                	li	a5,1
    800038d2:	02f70263          	beq	a4,a5,800038f6 <iput+0x44>
  ip->ref--;
    800038d6:	449c                	lw	a5,8(s1)
    800038d8:	37fd                	addiw	a5,a5,-1
    800038da:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800038dc:	0001e517          	auipc	a0,0x1e
    800038e0:	04c50513          	addi	a0,a0,76 # 80021928 <itable>
    800038e4:	ffffd097          	auipc	ra,0xffffd
    800038e8:	408080e7          	jalr	1032(ra) # 80000cec <release>
}
    800038ec:	60e2                	ld	ra,24(sp)
    800038ee:	6442                	ld	s0,16(sp)
    800038f0:	64a2                	ld	s1,8(sp)
    800038f2:	6105                	addi	sp,sp,32
    800038f4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038f6:	40bc                	lw	a5,64(s1)
    800038f8:	dff9                	beqz	a5,800038d6 <iput+0x24>
    800038fa:	04a49783          	lh	a5,74(s1)
    800038fe:	ffe1                	bnez	a5,800038d6 <iput+0x24>
    80003900:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003902:	01048913          	addi	s2,s1,16
    80003906:	854a                	mv	a0,s2
    80003908:	00001097          	auipc	ra,0x1
    8000390c:	ab0080e7          	jalr	-1360(ra) # 800043b8 <acquiresleep>
    release(&itable.lock);
    80003910:	0001e517          	auipc	a0,0x1e
    80003914:	01850513          	addi	a0,a0,24 # 80021928 <itable>
    80003918:	ffffd097          	auipc	ra,0xffffd
    8000391c:	3d4080e7          	jalr	980(ra) # 80000cec <release>
    itrunc(ip);
    80003920:	8526                	mv	a0,s1
    80003922:	00000097          	auipc	ra,0x0
    80003926:	ee4080e7          	jalr	-284(ra) # 80003806 <itrunc>
    ip->type = 0;
    8000392a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000392e:	8526                	mv	a0,s1
    80003930:	00000097          	auipc	ra,0x0
    80003934:	cf8080e7          	jalr	-776(ra) # 80003628 <iupdate>
    ip->valid = 0;
    80003938:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000393c:	854a                	mv	a0,s2
    8000393e:	00001097          	auipc	ra,0x1
    80003942:	ad0080e7          	jalr	-1328(ra) # 8000440e <releasesleep>
    acquire(&itable.lock);
    80003946:	0001e517          	auipc	a0,0x1e
    8000394a:	fe250513          	addi	a0,a0,-30 # 80021928 <itable>
    8000394e:	ffffd097          	auipc	ra,0xffffd
    80003952:	2ea080e7          	jalr	746(ra) # 80000c38 <acquire>
    80003956:	6902                	ld	s2,0(sp)
    80003958:	bfbd                	j	800038d6 <iput+0x24>

000000008000395a <iunlockput>:
{
    8000395a:	1101                	addi	sp,sp,-32
    8000395c:	ec06                	sd	ra,24(sp)
    8000395e:	e822                	sd	s0,16(sp)
    80003960:	e426                	sd	s1,8(sp)
    80003962:	1000                	addi	s0,sp,32
    80003964:	84aa                	mv	s1,a0
  iunlock(ip);
    80003966:	00000097          	auipc	ra,0x0
    8000396a:	e54080e7          	jalr	-428(ra) # 800037ba <iunlock>
  iput(ip);
    8000396e:	8526                	mv	a0,s1
    80003970:	00000097          	auipc	ra,0x0
    80003974:	f42080e7          	jalr	-190(ra) # 800038b2 <iput>
}
    80003978:	60e2                	ld	ra,24(sp)
    8000397a:	6442                	ld	s0,16(sp)
    8000397c:	64a2                	ld	s1,8(sp)
    8000397e:	6105                	addi	sp,sp,32
    80003980:	8082                	ret

0000000080003982 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003982:	1141                	addi	sp,sp,-16
    80003984:	e422                	sd	s0,8(sp)
    80003986:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003988:	411c                	lw	a5,0(a0)
    8000398a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000398c:	415c                	lw	a5,4(a0)
    8000398e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003990:	04451783          	lh	a5,68(a0)
    80003994:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003998:	04a51783          	lh	a5,74(a0)
    8000399c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800039a0:	04c56783          	lwu	a5,76(a0)
    800039a4:	e99c                	sd	a5,16(a1)
}
    800039a6:	6422                	ld	s0,8(sp)
    800039a8:	0141                	addi	sp,sp,16
    800039aa:	8082                	ret

00000000800039ac <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039ac:	457c                	lw	a5,76(a0)
    800039ae:	10d7e563          	bltu	a5,a3,80003ab8 <readi+0x10c>
{
    800039b2:	7159                	addi	sp,sp,-112
    800039b4:	f486                	sd	ra,104(sp)
    800039b6:	f0a2                	sd	s0,96(sp)
    800039b8:	eca6                	sd	s1,88(sp)
    800039ba:	e0d2                	sd	s4,64(sp)
    800039bc:	fc56                	sd	s5,56(sp)
    800039be:	f85a                	sd	s6,48(sp)
    800039c0:	f45e                	sd	s7,40(sp)
    800039c2:	1880                	addi	s0,sp,112
    800039c4:	8b2a                	mv	s6,a0
    800039c6:	8bae                	mv	s7,a1
    800039c8:	8a32                	mv	s4,a2
    800039ca:	84b6                	mv	s1,a3
    800039cc:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800039ce:	9f35                	addw	a4,a4,a3
    return 0;
    800039d0:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800039d2:	0cd76a63          	bltu	a4,a3,80003aa6 <readi+0xfa>
    800039d6:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800039d8:	00e7f463          	bgeu	a5,a4,800039e0 <readi+0x34>
    n = ip->size - off;
    800039dc:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039e0:	0a0a8963          	beqz	s5,80003a92 <readi+0xe6>
    800039e4:	e8ca                	sd	s2,80(sp)
    800039e6:	f062                	sd	s8,32(sp)
    800039e8:	ec66                	sd	s9,24(sp)
    800039ea:	e86a                	sd	s10,16(sp)
    800039ec:	e46e                	sd	s11,8(sp)
    800039ee:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800039f0:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800039f4:	5c7d                	li	s8,-1
    800039f6:	a82d                	j	80003a30 <readi+0x84>
    800039f8:	020d1d93          	slli	s11,s10,0x20
    800039fc:	020ddd93          	srli	s11,s11,0x20
    80003a00:	05890613          	addi	a2,s2,88
    80003a04:	86ee                	mv	a3,s11
    80003a06:	963a                	add	a2,a2,a4
    80003a08:	85d2                	mv	a1,s4
    80003a0a:	855e                	mv	a0,s7
    80003a0c:	fffff097          	auipc	ra,0xfffff
    80003a10:	af0080e7          	jalr	-1296(ra) # 800024fc <either_copyout>
    80003a14:	05850d63          	beq	a0,s8,80003a6e <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003a18:	854a                	mv	a0,s2
    80003a1a:	fffff097          	auipc	ra,0xfffff
    80003a1e:	5d6080e7          	jalr	1494(ra) # 80002ff0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a22:	013d09bb          	addw	s3,s10,s3
    80003a26:	009d04bb          	addw	s1,s10,s1
    80003a2a:	9a6e                	add	s4,s4,s11
    80003a2c:	0559fd63          	bgeu	s3,s5,80003a86 <readi+0xda>
    uint addr = bmap(ip, off/BSIZE);
    80003a30:	00a4d59b          	srliw	a1,s1,0xa
    80003a34:	855a                	mv	a0,s6
    80003a36:	00000097          	auipc	ra,0x0
    80003a3a:	88e080e7          	jalr	-1906(ra) # 800032c4 <bmap>
    80003a3e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003a42:	c9b1                	beqz	a1,80003a96 <readi+0xea>
    bp = bread(ip->dev, addr);
    80003a44:	000b2503          	lw	a0,0(s6)
    80003a48:	fffff097          	auipc	ra,0xfffff
    80003a4c:	478080e7          	jalr	1144(ra) # 80002ec0 <bread>
    80003a50:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a52:	3ff4f713          	andi	a4,s1,1023
    80003a56:	40ec87bb          	subw	a5,s9,a4
    80003a5a:	413a86bb          	subw	a3,s5,s3
    80003a5e:	8d3e                	mv	s10,a5
    80003a60:	2781                	sext.w	a5,a5
    80003a62:	0006861b          	sext.w	a2,a3
    80003a66:	f8f679e3          	bgeu	a2,a5,800039f8 <readi+0x4c>
    80003a6a:	8d36                	mv	s10,a3
    80003a6c:	b771                	j	800039f8 <readi+0x4c>
      brelse(bp);
    80003a6e:	854a                	mv	a0,s2
    80003a70:	fffff097          	auipc	ra,0xfffff
    80003a74:	580080e7          	jalr	1408(ra) # 80002ff0 <brelse>
      tot = -1;
    80003a78:	59fd                	li	s3,-1
      break;
    80003a7a:	6946                	ld	s2,80(sp)
    80003a7c:	7c02                	ld	s8,32(sp)
    80003a7e:	6ce2                	ld	s9,24(sp)
    80003a80:	6d42                	ld	s10,16(sp)
    80003a82:	6da2                	ld	s11,8(sp)
    80003a84:	a831                	j	80003aa0 <readi+0xf4>
    80003a86:	6946                	ld	s2,80(sp)
    80003a88:	7c02                	ld	s8,32(sp)
    80003a8a:	6ce2                	ld	s9,24(sp)
    80003a8c:	6d42                	ld	s10,16(sp)
    80003a8e:	6da2                	ld	s11,8(sp)
    80003a90:	a801                	j	80003aa0 <readi+0xf4>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a92:	89d6                	mv	s3,s5
    80003a94:	a031                	j	80003aa0 <readi+0xf4>
    80003a96:	6946                	ld	s2,80(sp)
    80003a98:	7c02                	ld	s8,32(sp)
    80003a9a:	6ce2                	ld	s9,24(sp)
    80003a9c:	6d42                	ld	s10,16(sp)
    80003a9e:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003aa0:	0009851b          	sext.w	a0,s3
    80003aa4:	69a6                	ld	s3,72(sp)
}
    80003aa6:	70a6                	ld	ra,104(sp)
    80003aa8:	7406                	ld	s0,96(sp)
    80003aaa:	64e6                	ld	s1,88(sp)
    80003aac:	6a06                	ld	s4,64(sp)
    80003aae:	7ae2                	ld	s5,56(sp)
    80003ab0:	7b42                	ld	s6,48(sp)
    80003ab2:	7ba2                	ld	s7,40(sp)
    80003ab4:	6165                	addi	sp,sp,112
    80003ab6:	8082                	ret
    return 0;
    80003ab8:	4501                	li	a0,0
}
    80003aba:	8082                	ret

0000000080003abc <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003abc:	457c                	lw	a5,76(a0)
    80003abe:	10d7ee63          	bltu	a5,a3,80003bda <writei+0x11e>
{
    80003ac2:	7159                	addi	sp,sp,-112
    80003ac4:	f486                	sd	ra,104(sp)
    80003ac6:	f0a2                	sd	s0,96(sp)
    80003ac8:	e8ca                	sd	s2,80(sp)
    80003aca:	e0d2                	sd	s4,64(sp)
    80003acc:	fc56                	sd	s5,56(sp)
    80003ace:	f85a                	sd	s6,48(sp)
    80003ad0:	f45e                	sd	s7,40(sp)
    80003ad2:	1880                	addi	s0,sp,112
    80003ad4:	8aaa                	mv	s5,a0
    80003ad6:	8bae                	mv	s7,a1
    80003ad8:	8a32                	mv	s4,a2
    80003ada:	8936                	mv	s2,a3
    80003adc:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ade:	00e687bb          	addw	a5,a3,a4
    80003ae2:	0ed7ee63          	bltu	a5,a3,80003bde <writei+0x122>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003ae6:	00043737          	lui	a4,0x43
    80003aea:	0ef76c63          	bltu	a4,a5,80003be2 <writei+0x126>
    80003aee:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003af0:	0c0b0d63          	beqz	s6,80003bca <writei+0x10e>
    80003af4:	eca6                	sd	s1,88(sp)
    80003af6:	f062                	sd	s8,32(sp)
    80003af8:	ec66                	sd	s9,24(sp)
    80003afa:	e86a                	sd	s10,16(sp)
    80003afc:	e46e                	sd	s11,8(sp)
    80003afe:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b00:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b04:	5c7d                	li	s8,-1
    80003b06:	a091                	j	80003b4a <writei+0x8e>
    80003b08:	020d1d93          	slli	s11,s10,0x20
    80003b0c:	020ddd93          	srli	s11,s11,0x20
    80003b10:	05848513          	addi	a0,s1,88
    80003b14:	86ee                	mv	a3,s11
    80003b16:	8652                	mv	a2,s4
    80003b18:	85de                	mv	a1,s7
    80003b1a:	953a                	add	a0,a0,a4
    80003b1c:	fffff097          	auipc	ra,0xfffff
    80003b20:	a36080e7          	jalr	-1482(ra) # 80002552 <either_copyin>
    80003b24:	07850263          	beq	a0,s8,80003b88 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b28:	8526                	mv	a0,s1
    80003b2a:	00000097          	auipc	ra,0x0
    80003b2e:	770080e7          	jalr	1904(ra) # 8000429a <log_write>
    brelse(bp);
    80003b32:	8526                	mv	a0,s1
    80003b34:	fffff097          	auipc	ra,0xfffff
    80003b38:	4bc080e7          	jalr	1212(ra) # 80002ff0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b3c:	013d09bb          	addw	s3,s10,s3
    80003b40:	012d093b          	addw	s2,s10,s2
    80003b44:	9a6e                	add	s4,s4,s11
    80003b46:	0569f663          	bgeu	s3,s6,80003b92 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003b4a:	00a9559b          	srliw	a1,s2,0xa
    80003b4e:	8556                	mv	a0,s5
    80003b50:	fffff097          	auipc	ra,0xfffff
    80003b54:	774080e7          	jalr	1908(ra) # 800032c4 <bmap>
    80003b58:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003b5c:	c99d                	beqz	a1,80003b92 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003b5e:	000aa503          	lw	a0,0(s5)
    80003b62:	fffff097          	auipc	ra,0xfffff
    80003b66:	35e080e7          	jalr	862(ra) # 80002ec0 <bread>
    80003b6a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b6c:	3ff97713          	andi	a4,s2,1023
    80003b70:	40ec87bb          	subw	a5,s9,a4
    80003b74:	413b06bb          	subw	a3,s6,s3
    80003b78:	8d3e                	mv	s10,a5
    80003b7a:	2781                	sext.w	a5,a5
    80003b7c:	0006861b          	sext.w	a2,a3
    80003b80:	f8f674e3          	bgeu	a2,a5,80003b08 <writei+0x4c>
    80003b84:	8d36                	mv	s10,a3
    80003b86:	b749                	j	80003b08 <writei+0x4c>
      brelse(bp);
    80003b88:	8526                	mv	a0,s1
    80003b8a:	fffff097          	auipc	ra,0xfffff
    80003b8e:	466080e7          	jalr	1126(ra) # 80002ff0 <brelse>
  }

  if(off > ip->size)
    80003b92:	04caa783          	lw	a5,76(s5)
    80003b96:	0327fc63          	bgeu	a5,s2,80003bce <writei+0x112>
    ip->size = off;
    80003b9a:	052aa623          	sw	s2,76(s5)
    80003b9e:	64e6                	ld	s1,88(sp)
    80003ba0:	7c02                	ld	s8,32(sp)
    80003ba2:	6ce2                	ld	s9,24(sp)
    80003ba4:	6d42                	ld	s10,16(sp)
    80003ba6:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003ba8:	8556                	mv	a0,s5
    80003baa:	00000097          	auipc	ra,0x0
    80003bae:	a7e080e7          	jalr	-1410(ra) # 80003628 <iupdate>

  return tot;
    80003bb2:	0009851b          	sext.w	a0,s3
    80003bb6:	69a6                	ld	s3,72(sp)
}
    80003bb8:	70a6                	ld	ra,104(sp)
    80003bba:	7406                	ld	s0,96(sp)
    80003bbc:	6946                	ld	s2,80(sp)
    80003bbe:	6a06                	ld	s4,64(sp)
    80003bc0:	7ae2                	ld	s5,56(sp)
    80003bc2:	7b42                	ld	s6,48(sp)
    80003bc4:	7ba2                	ld	s7,40(sp)
    80003bc6:	6165                	addi	sp,sp,112
    80003bc8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bca:	89da                	mv	s3,s6
    80003bcc:	bff1                	j	80003ba8 <writei+0xec>
    80003bce:	64e6                	ld	s1,88(sp)
    80003bd0:	7c02                	ld	s8,32(sp)
    80003bd2:	6ce2                	ld	s9,24(sp)
    80003bd4:	6d42                	ld	s10,16(sp)
    80003bd6:	6da2                	ld	s11,8(sp)
    80003bd8:	bfc1                	j	80003ba8 <writei+0xec>
    return -1;
    80003bda:	557d                	li	a0,-1
}
    80003bdc:	8082                	ret
    return -1;
    80003bde:	557d                	li	a0,-1
    80003be0:	bfe1                	j	80003bb8 <writei+0xfc>
    return -1;
    80003be2:	557d                	li	a0,-1
    80003be4:	bfd1                	j	80003bb8 <writei+0xfc>

0000000080003be6 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003be6:	1141                	addi	sp,sp,-16
    80003be8:	e406                	sd	ra,8(sp)
    80003bea:	e022                	sd	s0,0(sp)
    80003bec:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003bee:	4639                	li	a2,14
    80003bf0:	ffffd097          	auipc	ra,0xffffd
    80003bf4:	214080e7          	jalr	532(ra) # 80000e04 <strncmp>
}
    80003bf8:	60a2                	ld	ra,8(sp)
    80003bfa:	6402                	ld	s0,0(sp)
    80003bfc:	0141                	addi	sp,sp,16
    80003bfe:	8082                	ret

0000000080003c00 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c00:	7139                	addi	sp,sp,-64
    80003c02:	fc06                	sd	ra,56(sp)
    80003c04:	f822                	sd	s0,48(sp)
    80003c06:	f426                	sd	s1,40(sp)
    80003c08:	f04a                	sd	s2,32(sp)
    80003c0a:	ec4e                	sd	s3,24(sp)
    80003c0c:	e852                	sd	s4,16(sp)
    80003c0e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c10:	04451703          	lh	a4,68(a0)
    80003c14:	4785                	li	a5,1
    80003c16:	00f71a63          	bne	a4,a5,80003c2a <dirlookup+0x2a>
    80003c1a:	892a                	mv	s2,a0
    80003c1c:	89ae                	mv	s3,a1
    80003c1e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c20:	457c                	lw	a5,76(a0)
    80003c22:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c24:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c26:	e79d                	bnez	a5,80003c54 <dirlookup+0x54>
    80003c28:	a8a5                	j	80003ca0 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c2a:	00005517          	auipc	a0,0x5
    80003c2e:	8ae50513          	addi	a0,a0,-1874 # 800084d8 <etext+0x4d8>
    80003c32:	ffffd097          	auipc	ra,0xffffd
    80003c36:	92e080e7          	jalr	-1746(ra) # 80000560 <panic>
      panic("dirlookup read");
    80003c3a:	00005517          	auipc	a0,0x5
    80003c3e:	8b650513          	addi	a0,a0,-1866 # 800084f0 <etext+0x4f0>
    80003c42:	ffffd097          	auipc	ra,0xffffd
    80003c46:	91e080e7          	jalr	-1762(ra) # 80000560 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c4a:	24c1                	addiw	s1,s1,16
    80003c4c:	04c92783          	lw	a5,76(s2)
    80003c50:	04f4f763          	bgeu	s1,a5,80003c9e <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c54:	4741                	li	a4,16
    80003c56:	86a6                	mv	a3,s1
    80003c58:	fc040613          	addi	a2,s0,-64
    80003c5c:	4581                	li	a1,0
    80003c5e:	854a                	mv	a0,s2
    80003c60:	00000097          	auipc	ra,0x0
    80003c64:	d4c080e7          	jalr	-692(ra) # 800039ac <readi>
    80003c68:	47c1                	li	a5,16
    80003c6a:	fcf518e3          	bne	a0,a5,80003c3a <dirlookup+0x3a>
    if(de.inum == 0)
    80003c6e:	fc045783          	lhu	a5,-64(s0)
    80003c72:	dfe1                	beqz	a5,80003c4a <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003c74:	fc240593          	addi	a1,s0,-62
    80003c78:	854e                	mv	a0,s3
    80003c7a:	00000097          	auipc	ra,0x0
    80003c7e:	f6c080e7          	jalr	-148(ra) # 80003be6 <namecmp>
    80003c82:	f561                	bnez	a0,80003c4a <dirlookup+0x4a>
      if(poff)
    80003c84:	000a0463          	beqz	s4,80003c8c <dirlookup+0x8c>
        *poff = off;
    80003c88:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c8c:	fc045583          	lhu	a1,-64(s0)
    80003c90:	00092503          	lw	a0,0(s2)
    80003c94:	fffff097          	auipc	ra,0xfffff
    80003c98:	720080e7          	jalr	1824(ra) # 800033b4 <iget>
    80003c9c:	a011                	j	80003ca0 <dirlookup+0xa0>
  return 0;
    80003c9e:	4501                	li	a0,0
}
    80003ca0:	70e2                	ld	ra,56(sp)
    80003ca2:	7442                	ld	s0,48(sp)
    80003ca4:	74a2                	ld	s1,40(sp)
    80003ca6:	7902                	ld	s2,32(sp)
    80003ca8:	69e2                	ld	s3,24(sp)
    80003caa:	6a42                	ld	s4,16(sp)
    80003cac:	6121                	addi	sp,sp,64
    80003cae:	8082                	ret

0000000080003cb0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003cb0:	711d                	addi	sp,sp,-96
    80003cb2:	ec86                	sd	ra,88(sp)
    80003cb4:	e8a2                	sd	s0,80(sp)
    80003cb6:	e4a6                	sd	s1,72(sp)
    80003cb8:	e0ca                	sd	s2,64(sp)
    80003cba:	fc4e                	sd	s3,56(sp)
    80003cbc:	f852                	sd	s4,48(sp)
    80003cbe:	f456                	sd	s5,40(sp)
    80003cc0:	f05a                	sd	s6,32(sp)
    80003cc2:	ec5e                	sd	s7,24(sp)
    80003cc4:	e862                	sd	s8,16(sp)
    80003cc6:	e466                	sd	s9,8(sp)
    80003cc8:	1080                	addi	s0,sp,96
    80003cca:	84aa                	mv	s1,a0
    80003ccc:	8b2e                	mv	s6,a1
    80003cce:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003cd0:	00054703          	lbu	a4,0(a0)
    80003cd4:	02f00793          	li	a5,47
    80003cd8:	02f70263          	beq	a4,a5,80003cfc <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003cdc:	ffffe097          	auipc	ra,0xffffe
    80003ce0:	d6e080e7          	jalr	-658(ra) # 80001a4a <myproc>
    80003ce4:	15053503          	ld	a0,336(a0)
    80003ce8:	00000097          	auipc	ra,0x0
    80003cec:	9ce080e7          	jalr	-1586(ra) # 800036b6 <idup>
    80003cf0:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003cf2:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003cf6:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003cf8:	4b85                	li	s7,1
    80003cfa:	a875                	j	80003db6 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003cfc:	4585                	li	a1,1
    80003cfe:	4505                	li	a0,1
    80003d00:	fffff097          	auipc	ra,0xfffff
    80003d04:	6b4080e7          	jalr	1716(ra) # 800033b4 <iget>
    80003d08:	8a2a                	mv	s4,a0
    80003d0a:	b7e5                	j	80003cf2 <namex+0x42>
      iunlockput(ip);
    80003d0c:	8552                	mv	a0,s4
    80003d0e:	00000097          	auipc	ra,0x0
    80003d12:	c4c080e7          	jalr	-948(ra) # 8000395a <iunlockput>
      return 0;
    80003d16:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d18:	8552                	mv	a0,s4
    80003d1a:	60e6                	ld	ra,88(sp)
    80003d1c:	6446                	ld	s0,80(sp)
    80003d1e:	64a6                	ld	s1,72(sp)
    80003d20:	6906                	ld	s2,64(sp)
    80003d22:	79e2                	ld	s3,56(sp)
    80003d24:	7a42                	ld	s4,48(sp)
    80003d26:	7aa2                	ld	s5,40(sp)
    80003d28:	7b02                	ld	s6,32(sp)
    80003d2a:	6be2                	ld	s7,24(sp)
    80003d2c:	6c42                	ld	s8,16(sp)
    80003d2e:	6ca2                	ld	s9,8(sp)
    80003d30:	6125                	addi	sp,sp,96
    80003d32:	8082                	ret
      iunlock(ip);
    80003d34:	8552                	mv	a0,s4
    80003d36:	00000097          	auipc	ra,0x0
    80003d3a:	a84080e7          	jalr	-1404(ra) # 800037ba <iunlock>
      return ip;
    80003d3e:	bfe9                	j	80003d18 <namex+0x68>
      iunlockput(ip);
    80003d40:	8552                	mv	a0,s4
    80003d42:	00000097          	auipc	ra,0x0
    80003d46:	c18080e7          	jalr	-1000(ra) # 8000395a <iunlockput>
      return 0;
    80003d4a:	8a4e                	mv	s4,s3
    80003d4c:	b7f1                	j	80003d18 <namex+0x68>
  len = path - s;
    80003d4e:	40998633          	sub	a2,s3,s1
    80003d52:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003d56:	099c5863          	bge	s8,s9,80003de6 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003d5a:	4639                	li	a2,14
    80003d5c:	85a6                	mv	a1,s1
    80003d5e:	8556                	mv	a0,s5
    80003d60:	ffffd097          	auipc	ra,0xffffd
    80003d64:	030080e7          	jalr	48(ra) # 80000d90 <memmove>
    80003d68:	84ce                	mv	s1,s3
  while(*path == '/')
    80003d6a:	0004c783          	lbu	a5,0(s1)
    80003d6e:	01279763          	bne	a5,s2,80003d7c <namex+0xcc>
    path++;
    80003d72:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d74:	0004c783          	lbu	a5,0(s1)
    80003d78:	ff278de3          	beq	a5,s2,80003d72 <namex+0xc2>
    ilock(ip);
    80003d7c:	8552                	mv	a0,s4
    80003d7e:	00000097          	auipc	ra,0x0
    80003d82:	976080e7          	jalr	-1674(ra) # 800036f4 <ilock>
    if(ip->type != T_DIR){
    80003d86:	044a1783          	lh	a5,68(s4)
    80003d8a:	f97791e3          	bne	a5,s7,80003d0c <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003d8e:	000b0563          	beqz	s6,80003d98 <namex+0xe8>
    80003d92:	0004c783          	lbu	a5,0(s1)
    80003d96:	dfd9                	beqz	a5,80003d34 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d98:	4601                	li	a2,0
    80003d9a:	85d6                	mv	a1,s5
    80003d9c:	8552                	mv	a0,s4
    80003d9e:	00000097          	auipc	ra,0x0
    80003da2:	e62080e7          	jalr	-414(ra) # 80003c00 <dirlookup>
    80003da6:	89aa                	mv	s3,a0
    80003da8:	dd41                	beqz	a0,80003d40 <namex+0x90>
    iunlockput(ip);
    80003daa:	8552                	mv	a0,s4
    80003dac:	00000097          	auipc	ra,0x0
    80003db0:	bae080e7          	jalr	-1106(ra) # 8000395a <iunlockput>
    ip = next;
    80003db4:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003db6:	0004c783          	lbu	a5,0(s1)
    80003dba:	01279763          	bne	a5,s2,80003dc8 <namex+0x118>
    path++;
    80003dbe:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003dc0:	0004c783          	lbu	a5,0(s1)
    80003dc4:	ff278de3          	beq	a5,s2,80003dbe <namex+0x10e>
  if(*path == 0)
    80003dc8:	cb9d                	beqz	a5,80003dfe <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003dca:	0004c783          	lbu	a5,0(s1)
    80003dce:	89a6                	mv	s3,s1
  len = path - s;
    80003dd0:	4c81                	li	s9,0
    80003dd2:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003dd4:	01278963          	beq	a5,s2,80003de6 <namex+0x136>
    80003dd8:	dbbd                	beqz	a5,80003d4e <namex+0x9e>
    path++;
    80003dda:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003ddc:	0009c783          	lbu	a5,0(s3)
    80003de0:	ff279ce3          	bne	a5,s2,80003dd8 <namex+0x128>
    80003de4:	b7ad                	j	80003d4e <namex+0x9e>
    memmove(name, s, len);
    80003de6:	2601                	sext.w	a2,a2
    80003de8:	85a6                	mv	a1,s1
    80003dea:	8556                	mv	a0,s5
    80003dec:	ffffd097          	auipc	ra,0xffffd
    80003df0:	fa4080e7          	jalr	-92(ra) # 80000d90 <memmove>
    name[len] = 0;
    80003df4:	9cd6                	add	s9,s9,s5
    80003df6:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003dfa:	84ce                	mv	s1,s3
    80003dfc:	b7bd                	j	80003d6a <namex+0xba>
  if(nameiparent){
    80003dfe:	f00b0de3          	beqz	s6,80003d18 <namex+0x68>
    iput(ip);
    80003e02:	8552                	mv	a0,s4
    80003e04:	00000097          	auipc	ra,0x0
    80003e08:	aae080e7          	jalr	-1362(ra) # 800038b2 <iput>
    return 0;
    80003e0c:	4a01                	li	s4,0
    80003e0e:	b729                	j	80003d18 <namex+0x68>

0000000080003e10 <dirlink>:
{
    80003e10:	7139                	addi	sp,sp,-64
    80003e12:	fc06                	sd	ra,56(sp)
    80003e14:	f822                	sd	s0,48(sp)
    80003e16:	f04a                	sd	s2,32(sp)
    80003e18:	ec4e                	sd	s3,24(sp)
    80003e1a:	e852                	sd	s4,16(sp)
    80003e1c:	0080                	addi	s0,sp,64
    80003e1e:	892a                	mv	s2,a0
    80003e20:	8a2e                	mv	s4,a1
    80003e22:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e24:	4601                	li	a2,0
    80003e26:	00000097          	auipc	ra,0x0
    80003e2a:	dda080e7          	jalr	-550(ra) # 80003c00 <dirlookup>
    80003e2e:	ed25                	bnez	a0,80003ea6 <dirlink+0x96>
    80003e30:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e32:	04c92483          	lw	s1,76(s2)
    80003e36:	c49d                	beqz	s1,80003e64 <dirlink+0x54>
    80003e38:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e3a:	4741                	li	a4,16
    80003e3c:	86a6                	mv	a3,s1
    80003e3e:	fc040613          	addi	a2,s0,-64
    80003e42:	4581                	li	a1,0
    80003e44:	854a                	mv	a0,s2
    80003e46:	00000097          	auipc	ra,0x0
    80003e4a:	b66080e7          	jalr	-1178(ra) # 800039ac <readi>
    80003e4e:	47c1                	li	a5,16
    80003e50:	06f51163          	bne	a0,a5,80003eb2 <dirlink+0xa2>
    if(de.inum == 0)
    80003e54:	fc045783          	lhu	a5,-64(s0)
    80003e58:	c791                	beqz	a5,80003e64 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e5a:	24c1                	addiw	s1,s1,16
    80003e5c:	04c92783          	lw	a5,76(s2)
    80003e60:	fcf4ede3          	bltu	s1,a5,80003e3a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003e64:	4639                	li	a2,14
    80003e66:	85d2                	mv	a1,s4
    80003e68:	fc240513          	addi	a0,s0,-62
    80003e6c:	ffffd097          	auipc	ra,0xffffd
    80003e70:	fce080e7          	jalr	-50(ra) # 80000e3a <strncpy>
  de.inum = inum;
    80003e74:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e78:	4741                	li	a4,16
    80003e7a:	86a6                	mv	a3,s1
    80003e7c:	fc040613          	addi	a2,s0,-64
    80003e80:	4581                	li	a1,0
    80003e82:	854a                	mv	a0,s2
    80003e84:	00000097          	auipc	ra,0x0
    80003e88:	c38080e7          	jalr	-968(ra) # 80003abc <writei>
    80003e8c:	1541                	addi	a0,a0,-16
    80003e8e:	00a03533          	snez	a0,a0
    80003e92:	40a00533          	neg	a0,a0
    80003e96:	74a2                	ld	s1,40(sp)
}
    80003e98:	70e2                	ld	ra,56(sp)
    80003e9a:	7442                	ld	s0,48(sp)
    80003e9c:	7902                	ld	s2,32(sp)
    80003e9e:	69e2                	ld	s3,24(sp)
    80003ea0:	6a42                	ld	s4,16(sp)
    80003ea2:	6121                	addi	sp,sp,64
    80003ea4:	8082                	ret
    iput(ip);
    80003ea6:	00000097          	auipc	ra,0x0
    80003eaa:	a0c080e7          	jalr	-1524(ra) # 800038b2 <iput>
    return -1;
    80003eae:	557d                	li	a0,-1
    80003eb0:	b7e5                	j	80003e98 <dirlink+0x88>
      panic("dirlink read");
    80003eb2:	00004517          	auipc	a0,0x4
    80003eb6:	64e50513          	addi	a0,a0,1614 # 80008500 <etext+0x500>
    80003eba:	ffffc097          	auipc	ra,0xffffc
    80003ebe:	6a6080e7          	jalr	1702(ra) # 80000560 <panic>

0000000080003ec2 <namei>:

struct inode*
namei(char *path)
{
    80003ec2:	1101                	addi	sp,sp,-32
    80003ec4:	ec06                	sd	ra,24(sp)
    80003ec6:	e822                	sd	s0,16(sp)
    80003ec8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003eca:	fe040613          	addi	a2,s0,-32
    80003ece:	4581                	li	a1,0
    80003ed0:	00000097          	auipc	ra,0x0
    80003ed4:	de0080e7          	jalr	-544(ra) # 80003cb0 <namex>
}
    80003ed8:	60e2                	ld	ra,24(sp)
    80003eda:	6442                	ld	s0,16(sp)
    80003edc:	6105                	addi	sp,sp,32
    80003ede:	8082                	ret

0000000080003ee0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003ee0:	1141                	addi	sp,sp,-16
    80003ee2:	e406                	sd	ra,8(sp)
    80003ee4:	e022                	sd	s0,0(sp)
    80003ee6:	0800                	addi	s0,sp,16
    80003ee8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003eea:	4585                	li	a1,1
    80003eec:	00000097          	auipc	ra,0x0
    80003ef0:	dc4080e7          	jalr	-572(ra) # 80003cb0 <namex>
}
    80003ef4:	60a2                	ld	ra,8(sp)
    80003ef6:	6402                	ld	s0,0(sp)
    80003ef8:	0141                	addi	sp,sp,16
    80003efa:	8082                	ret

0000000080003efc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003efc:	1101                	addi	sp,sp,-32
    80003efe:	ec06                	sd	ra,24(sp)
    80003f00:	e822                	sd	s0,16(sp)
    80003f02:	e426                	sd	s1,8(sp)
    80003f04:	e04a                	sd	s2,0(sp)
    80003f06:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f08:	0001f917          	auipc	s2,0x1f
    80003f0c:	4c890913          	addi	s2,s2,1224 # 800233d0 <log>
    80003f10:	01892583          	lw	a1,24(s2)
    80003f14:	02892503          	lw	a0,40(s2)
    80003f18:	fffff097          	auipc	ra,0xfffff
    80003f1c:	fa8080e7          	jalr	-88(ra) # 80002ec0 <bread>
    80003f20:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f22:	02c92603          	lw	a2,44(s2)
    80003f26:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f28:	00c05f63          	blez	a2,80003f46 <write_head+0x4a>
    80003f2c:	0001f717          	auipc	a4,0x1f
    80003f30:	4d470713          	addi	a4,a4,1236 # 80023400 <log+0x30>
    80003f34:	87aa                	mv	a5,a0
    80003f36:	060a                	slli	a2,a2,0x2
    80003f38:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003f3a:	4314                	lw	a3,0(a4)
    80003f3c:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003f3e:	0711                	addi	a4,a4,4
    80003f40:	0791                	addi	a5,a5,4
    80003f42:	fec79ce3          	bne	a5,a2,80003f3a <write_head+0x3e>
  }
  bwrite(buf);
    80003f46:	8526                	mv	a0,s1
    80003f48:	fffff097          	auipc	ra,0xfffff
    80003f4c:	06a080e7          	jalr	106(ra) # 80002fb2 <bwrite>
  brelse(buf);
    80003f50:	8526                	mv	a0,s1
    80003f52:	fffff097          	auipc	ra,0xfffff
    80003f56:	09e080e7          	jalr	158(ra) # 80002ff0 <brelse>
}
    80003f5a:	60e2                	ld	ra,24(sp)
    80003f5c:	6442                	ld	s0,16(sp)
    80003f5e:	64a2                	ld	s1,8(sp)
    80003f60:	6902                	ld	s2,0(sp)
    80003f62:	6105                	addi	sp,sp,32
    80003f64:	8082                	ret

0000000080003f66 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f66:	0001f797          	auipc	a5,0x1f
    80003f6a:	4967a783          	lw	a5,1174(a5) # 800233fc <log+0x2c>
    80003f6e:	0af05d63          	blez	a5,80004028 <install_trans+0xc2>
{
    80003f72:	7139                	addi	sp,sp,-64
    80003f74:	fc06                	sd	ra,56(sp)
    80003f76:	f822                	sd	s0,48(sp)
    80003f78:	f426                	sd	s1,40(sp)
    80003f7a:	f04a                	sd	s2,32(sp)
    80003f7c:	ec4e                	sd	s3,24(sp)
    80003f7e:	e852                	sd	s4,16(sp)
    80003f80:	e456                	sd	s5,8(sp)
    80003f82:	e05a                	sd	s6,0(sp)
    80003f84:	0080                	addi	s0,sp,64
    80003f86:	8b2a                	mv	s6,a0
    80003f88:	0001fa97          	auipc	s5,0x1f
    80003f8c:	478a8a93          	addi	s5,s5,1144 # 80023400 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f90:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f92:	0001f997          	auipc	s3,0x1f
    80003f96:	43e98993          	addi	s3,s3,1086 # 800233d0 <log>
    80003f9a:	a00d                	j	80003fbc <install_trans+0x56>
    brelse(lbuf);
    80003f9c:	854a                	mv	a0,s2
    80003f9e:	fffff097          	auipc	ra,0xfffff
    80003fa2:	052080e7          	jalr	82(ra) # 80002ff0 <brelse>
    brelse(dbuf);
    80003fa6:	8526                	mv	a0,s1
    80003fa8:	fffff097          	auipc	ra,0xfffff
    80003fac:	048080e7          	jalr	72(ra) # 80002ff0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fb0:	2a05                	addiw	s4,s4,1
    80003fb2:	0a91                	addi	s5,s5,4
    80003fb4:	02c9a783          	lw	a5,44(s3)
    80003fb8:	04fa5e63          	bge	s4,a5,80004014 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003fbc:	0189a583          	lw	a1,24(s3)
    80003fc0:	014585bb          	addw	a1,a1,s4
    80003fc4:	2585                	addiw	a1,a1,1
    80003fc6:	0289a503          	lw	a0,40(s3)
    80003fca:	fffff097          	auipc	ra,0xfffff
    80003fce:	ef6080e7          	jalr	-266(ra) # 80002ec0 <bread>
    80003fd2:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003fd4:	000aa583          	lw	a1,0(s5)
    80003fd8:	0289a503          	lw	a0,40(s3)
    80003fdc:	fffff097          	auipc	ra,0xfffff
    80003fe0:	ee4080e7          	jalr	-284(ra) # 80002ec0 <bread>
    80003fe4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003fe6:	40000613          	li	a2,1024
    80003fea:	05890593          	addi	a1,s2,88
    80003fee:	05850513          	addi	a0,a0,88
    80003ff2:	ffffd097          	auipc	ra,0xffffd
    80003ff6:	d9e080e7          	jalr	-610(ra) # 80000d90 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003ffa:	8526                	mv	a0,s1
    80003ffc:	fffff097          	auipc	ra,0xfffff
    80004000:	fb6080e7          	jalr	-74(ra) # 80002fb2 <bwrite>
    if(recovering == 0)
    80004004:	f80b1ce3          	bnez	s6,80003f9c <install_trans+0x36>
      bunpin(dbuf);
    80004008:	8526                	mv	a0,s1
    8000400a:	fffff097          	auipc	ra,0xfffff
    8000400e:	0be080e7          	jalr	190(ra) # 800030c8 <bunpin>
    80004012:	b769                	j	80003f9c <install_trans+0x36>
}
    80004014:	70e2                	ld	ra,56(sp)
    80004016:	7442                	ld	s0,48(sp)
    80004018:	74a2                	ld	s1,40(sp)
    8000401a:	7902                	ld	s2,32(sp)
    8000401c:	69e2                	ld	s3,24(sp)
    8000401e:	6a42                	ld	s4,16(sp)
    80004020:	6aa2                	ld	s5,8(sp)
    80004022:	6b02                	ld	s6,0(sp)
    80004024:	6121                	addi	sp,sp,64
    80004026:	8082                	ret
    80004028:	8082                	ret

000000008000402a <initlog>:
{
    8000402a:	7179                	addi	sp,sp,-48
    8000402c:	f406                	sd	ra,40(sp)
    8000402e:	f022                	sd	s0,32(sp)
    80004030:	ec26                	sd	s1,24(sp)
    80004032:	e84a                	sd	s2,16(sp)
    80004034:	e44e                	sd	s3,8(sp)
    80004036:	1800                	addi	s0,sp,48
    80004038:	892a                	mv	s2,a0
    8000403a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000403c:	0001f497          	auipc	s1,0x1f
    80004040:	39448493          	addi	s1,s1,916 # 800233d0 <log>
    80004044:	00004597          	auipc	a1,0x4
    80004048:	4cc58593          	addi	a1,a1,1228 # 80008510 <etext+0x510>
    8000404c:	8526                	mv	a0,s1
    8000404e:	ffffd097          	auipc	ra,0xffffd
    80004052:	b5a080e7          	jalr	-1190(ra) # 80000ba8 <initlock>
  log.start = sb->logstart;
    80004056:	0149a583          	lw	a1,20(s3)
    8000405a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000405c:	0109a783          	lw	a5,16(s3)
    80004060:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004062:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004066:	854a                	mv	a0,s2
    80004068:	fffff097          	auipc	ra,0xfffff
    8000406c:	e58080e7          	jalr	-424(ra) # 80002ec0 <bread>
  log.lh.n = lh->n;
    80004070:	4d30                	lw	a2,88(a0)
    80004072:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004074:	00c05f63          	blez	a2,80004092 <initlog+0x68>
    80004078:	87aa                	mv	a5,a0
    8000407a:	0001f717          	auipc	a4,0x1f
    8000407e:	38670713          	addi	a4,a4,902 # 80023400 <log+0x30>
    80004082:	060a                	slli	a2,a2,0x2
    80004084:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004086:	4ff4                	lw	a3,92(a5)
    80004088:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000408a:	0791                	addi	a5,a5,4
    8000408c:	0711                	addi	a4,a4,4
    8000408e:	fec79ce3          	bne	a5,a2,80004086 <initlog+0x5c>
  brelse(buf);
    80004092:	fffff097          	auipc	ra,0xfffff
    80004096:	f5e080e7          	jalr	-162(ra) # 80002ff0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000409a:	4505                	li	a0,1
    8000409c:	00000097          	auipc	ra,0x0
    800040a0:	eca080e7          	jalr	-310(ra) # 80003f66 <install_trans>
  log.lh.n = 0;
    800040a4:	0001f797          	auipc	a5,0x1f
    800040a8:	3407ac23          	sw	zero,856(a5) # 800233fc <log+0x2c>
  write_head(); // clear the log
    800040ac:	00000097          	auipc	ra,0x0
    800040b0:	e50080e7          	jalr	-432(ra) # 80003efc <write_head>
}
    800040b4:	70a2                	ld	ra,40(sp)
    800040b6:	7402                	ld	s0,32(sp)
    800040b8:	64e2                	ld	s1,24(sp)
    800040ba:	6942                	ld	s2,16(sp)
    800040bc:	69a2                	ld	s3,8(sp)
    800040be:	6145                	addi	sp,sp,48
    800040c0:	8082                	ret

00000000800040c2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800040c2:	1101                	addi	sp,sp,-32
    800040c4:	ec06                	sd	ra,24(sp)
    800040c6:	e822                	sd	s0,16(sp)
    800040c8:	e426                	sd	s1,8(sp)
    800040ca:	e04a                	sd	s2,0(sp)
    800040cc:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800040ce:	0001f517          	auipc	a0,0x1f
    800040d2:	30250513          	addi	a0,a0,770 # 800233d0 <log>
    800040d6:	ffffd097          	auipc	ra,0xffffd
    800040da:	b62080e7          	jalr	-1182(ra) # 80000c38 <acquire>
  while(1){
    if(log.committing){
    800040de:	0001f497          	auipc	s1,0x1f
    800040e2:	2f248493          	addi	s1,s1,754 # 800233d0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040e6:	4979                	li	s2,30
    800040e8:	a039                	j	800040f6 <begin_op+0x34>
      sleep(&log, &log.lock);
    800040ea:	85a6                	mv	a1,s1
    800040ec:	8526                	mv	a0,s1
    800040ee:	ffffe097          	auipc	ra,0xffffe
    800040f2:	006080e7          	jalr	6(ra) # 800020f4 <sleep>
    if(log.committing){
    800040f6:	50dc                	lw	a5,36(s1)
    800040f8:	fbed                	bnez	a5,800040ea <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040fa:	5098                	lw	a4,32(s1)
    800040fc:	2705                	addiw	a4,a4,1
    800040fe:	0027179b          	slliw	a5,a4,0x2
    80004102:	9fb9                	addw	a5,a5,a4
    80004104:	0017979b          	slliw	a5,a5,0x1
    80004108:	54d4                	lw	a3,44(s1)
    8000410a:	9fb5                	addw	a5,a5,a3
    8000410c:	00f95963          	bge	s2,a5,8000411e <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004110:	85a6                	mv	a1,s1
    80004112:	8526                	mv	a0,s1
    80004114:	ffffe097          	auipc	ra,0xffffe
    80004118:	fe0080e7          	jalr	-32(ra) # 800020f4 <sleep>
    8000411c:	bfe9                	j	800040f6 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000411e:	0001f517          	auipc	a0,0x1f
    80004122:	2b250513          	addi	a0,a0,690 # 800233d0 <log>
    80004126:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004128:	ffffd097          	auipc	ra,0xffffd
    8000412c:	bc4080e7          	jalr	-1084(ra) # 80000cec <release>
      break;
    }
  }
}
    80004130:	60e2                	ld	ra,24(sp)
    80004132:	6442                	ld	s0,16(sp)
    80004134:	64a2                	ld	s1,8(sp)
    80004136:	6902                	ld	s2,0(sp)
    80004138:	6105                	addi	sp,sp,32
    8000413a:	8082                	ret

000000008000413c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000413c:	7139                	addi	sp,sp,-64
    8000413e:	fc06                	sd	ra,56(sp)
    80004140:	f822                	sd	s0,48(sp)
    80004142:	f426                	sd	s1,40(sp)
    80004144:	f04a                	sd	s2,32(sp)
    80004146:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004148:	0001f497          	auipc	s1,0x1f
    8000414c:	28848493          	addi	s1,s1,648 # 800233d0 <log>
    80004150:	8526                	mv	a0,s1
    80004152:	ffffd097          	auipc	ra,0xffffd
    80004156:	ae6080e7          	jalr	-1306(ra) # 80000c38 <acquire>
  log.outstanding -= 1;
    8000415a:	509c                	lw	a5,32(s1)
    8000415c:	37fd                	addiw	a5,a5,-1
    8000415e:	0007891b          	sext.w	s2,a5
    80004162:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004164:	50dc                	lw	a5,36(s1)
    80004166:	e7b9                	bnez	a5,800041b4 <end_op+0x78>
    panic("log.committing");
  if(log.outstanding == 0){
    80004168:	06091163          	bnez	s2,800041ca <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000416c:	0001f497          	auipc	s1,0x1f
    80004170:	26448493          	addi	s1,s1,612 # 800233d0 <log>
    80004174:	4785                	li	a5,1
    80004176:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004178:	8526                	mv	a0,s1
    8000417a:	ffffd097          	auipc	ra,0xffffd
    8000417e:	b72080e7          	jalr	-1166(ra) # 80000cec <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004182:	54dc                	lw	a5,44(s1)
    80004184:	06f04763          	bgtz	a5,800041f2 <end_op+0xb6>
    acquire(&log.lock);
    80004188:	0001f497          	auipc	s1,0x1f
    8000418c:	24848493          	addi	s1,s1,584 # 800233d0 <log>
    80004190:	8526                	mv	a0,s1
    80004192:	ffffd097          	auipc	ra,0xffffd
    80004196:	aa6080e7          	jalr	-1370(ra) # 80000c38 <acquire>
    log.committing = 0;
    8000419a:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000419e:	8526                	mv	a0,s1
    800041a0:	ffffe097          	auipc	ra,0xffffe
    800041a4:	fb8080e7          	jalr	-72(ra) # 80002158 <wakeup>
    release(&log.lock);
    800041a8:	8526                	mv	a0,s1
    800041aa:	ffffd097          	auipc	ra,0xffffd
    800041ae:	b42080e7          	jalr	-1214(ra) # 80000cec <release>
}
    800041b2:	a815                	j	800041e6 <end_op+0xaa>
    800041b4:	ec4e                	sd	s3,24(sp)
    800041b6:	e852                	sd	s4,16(sp)
    800041b8:	e456                	sd	s5,8(sp)
    panic("log.committing");
    800041ba:	00004517          	auipc	a0,0x4
    800041be:	35e50513          	addi	a0,a0,862 # 80008518 <etext+0x518>
    800041c2:	ffffc097          	auipc	ra,0xffffc
    800041c6:	39e080e7          	jalr	926(ra) # 80000560 <panic>
    wakeup(&log);
    800041ca:	0001f497          	auipc	s1,0x1f
    800041ce:	20648493          	addi	s1,s1,518 # 800233d0 <log>
    800041d2:	8526                	mv	a0,s1
    800041d4:	ffffe097          	auipc	ra,0xffffe
    800041d8:	f84080e7          	jalr	-124(ra) # 80002158 <wakeup>
  release(&log.lock);
    800041dc:	8526                	mv	a0,s1
    800041de:	ffffd097          	auipc	ra,0xffffd
    800041e2:	b0e080e7          	jalr	-1266(ra) # 80000cec <release>
}
    800041e6:	70e2                	ld	ra,56(sp)
    800041e8:	7442                	ld	s0,48(sp)
    800041ea:	74a2                	ld	s1,40(sp)
    800041ec:	7902                	ld	s2,32(sp)
    800041ee:	6121                	addi	sp,sp,64
    800041f0:	8082                	ret
    800041f2:	ec4e                	sd	s3,24(sp)
    800041f4:	e852                	sd	s4,16(sp)
    800041f6:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800041f8:	0001fa97          	auipc	s5,0x1f
    800041fc:	208a8a93          	addi	s5,s5,520 # 80023400 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004200:	0001fa17          	auipc	s4,0x1f
    80004204:	1d0a0a13          	addi	s4,s4,464 # 800233d0 <log>
    80004208:	018a2583          	lw	a1,24(s4)
    8000420c:	012585bb          	addw	a1,a1,s2
    80004210:	2585                	addiw	a1,a1,1
    80004212:	028a2503          	lw	a0,40(s4)
    80004216:	fffff097          	auipc	ra,0xfffff
    8000421a:	caa080e7          	jalr	-854(ra) # 80002ec0 <bread>
    8000421e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004220:	000aa583          	lw	a1,0(s5)
    80004224:	028a2503          	lw	a0,40(s4)
    80004228:	fffff097          	auipc	ra,0xfffff
    8000422c:	c98080e7          	jalr	-872(ra) # 80002ec0 <bread>
    80004230:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004232:	40000613          	li	a2,1024
    80004236:	05850593          	addi	a1,a0,88
    8000423a:	05848513          	addi	a0,s1,88
    8000423e:	ffffd097          	auipc	ra,0xffffd
    80004242:	b52080e7          	jalr	-1198(ra) # 80000d90 <memmove>
    bwrite(to);  // write the log
    80004246:	8526                	mv	a0,s1
    80004248:	fffff097          	auipc	ra,0xfffff
    8000424c:	d6a080e7          	jalr	-662(ra) # 80002fb2 <bwrite>
    brelse(from);
    80004250:	854e                	mv	a0,s3
    80004252:	fffff097          	auipc	ra,0xfffff
    80004256:	d9e080e7          	jalr	-610(ra) # 80002ff0 <brelse>
    brelse(to);
    8000425a:	8526                	mv	a0,s1
    8000425c:	fffff097          	auipc	ra,0xfffff
    80004260:	d94080e7          	jalr	-620(ra) # 80002ff0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004264:	2905                	addiw	s2,s2,1
    80004266:	0a91                	addi	s5,s5,4
    80004268:	02ca2783          	lw	a5,44(s4)
    8000426c:	f8f94ee3          	blt	s2,a5,80004208 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004270:	00000097          	auipc	ra,0x0
    80004274:	c8c080e7          	jalr	-884(ra) # 80003efc <write_head>
    install_trans(0); // Now install writes to home locations
    80004278:	4501                	li	a0,0
    8000427a:	00000097          	auipc	ra,0x0
    8000427e:	cec080e7          	jalr	-788(ra) # 80003f66 <install_trans>
    log.lh.n = 0;
    80004282:	0001f797          	auipc	a5,0x1f
    80004286:	1607ad23          	sw	zero,378(a5) # 800233fc <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000428a:	00000097          	auipc	ra,0x0
    8000428e:	c72080e7          	jalr	-910(ra) # 80003efc <write_head>
    80004292:	69e2                	ld	s3,24(sp)
    80004294:	6a42                	ld	s4,16(sp)
    80004296:	6aa2                	ld	s5,8(sp)
    80004298:	bdc5                	j	80004188 <end_op+0x4c>

000000008000429a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000429a:	1101                	addi	sp,sp,-32
    8000429c:	ec06                	sd	ra,24(sp)
    8000429e:	e822                	sd	s0,16(sp)
    800042a0:	e426                	sd	s1,8(sp)
    800042a2:	e04a                	sd	s2,0(sp)
    800042a4:	1000                	addi	s0,sp,32
    800042a6:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800042a8:	0001f917          	auipc	s2,0x1f
    800042ac:	12890913          	addi	s2,s2,296 # 800233d0 <log>
    800042b0:	854a                	mv	a0,s2
    800042b2:	ffffd097          	auipc	ra,0xffffd
    800042b6:	986080e7          	jalr	-1658(ra) # 80000c38 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800042ba:	02c92603          	lw	a2,44(s2)
    800042be:	47f5                	li	a5,29
    800042c0:	06c7c563          	blt	a5,a2,8000432a <log_write+0x90>
    800042c4:	0001f797          	auipc	a5,0x1f
    800042c8:	1287a783          	lw	a5,296(a5) # 800233ec <log+0x1c>
    800042cc:	37fd                	addiw	a5,a5,-1
    800042ce:	04f65e63          	bge	a2,a5,8000432a <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800042d2:	0001f797          	auipc	a5,0x1f
    800042d6:	11e7a783          	lw	a5,286(a5) # 800233f0 <log+0x20>
    800042da:	06f05063          	blez	a5,8000433a <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800042de:	4781                	li	a5,0
    800042e0:	06c05563          	blez	a2,8000434a <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800042e4:	44cc                	lw	a1,12(s1)
    800042e6:	0001f717          	auipc	a4,0x1f
    800042ea:	11a70713          	addi	a4,a4,282 # 80023400 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800042ee:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800042f0:	4314                	lw	a3,0(a4)
    800042f2:	04b68c63          	beq	a3,a1,8000434a <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800042f6:	2785                	addiw	a5,a5,1
    800042f8:	0711                	addi	a4,a4,4
    800042fa:	fef61be3          	bne	a2,a5,800042f0 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800042fe:	0621                	addi	a2,a2,8
    80004300:	060a                	slli	a2,a2,0x2
    80004302:	0001f797          	auipc	a5,0x1f
    80004306:	0ce78793          	addi	a5,a5,206 # 800233d0 <log>
    8000430a:	97b2                	add	a5,a5,a2
    8000430c:	44d8                	lw	a4,12(s1)
    8000430e:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004310:	8526                	mv	a0,s1
    80004312:	fffff097          	auipc	ra,0xfffff
    80004316:	d7a080e7          	jalr	-646(ra) # 8000308c <bpin>
    log.lh.n++;
    8000431a:	0001f717          	auipc	a4,0x1f
    8000431e:	0b670713          	addi	a4,a4,182 # 800233d0 <log>
    80004322:	575c                	lw	a5,44(a4)
    80004324:	2785                	addiw	a5,a5,1
    80004326:	d75c                	sw	a5,44(a4)
    80004328:	a82d                	j	80004362 <log_write+0xc8>
    panic("too big a transaction");
    8000432a:	00004517          	auipc	a0,0x4
    8000432e:	1fe50513          	addi	a0,a0,510 # 80008528 <etext+0x528>
    80004332:	ffffc097          	auipc	ra,0xffffc
    80004336:	22e080e7          	jalr	558(ra) # 80000560 <panic>
    panic("log_write outside of trans");
    8000433a:	00004517          	auipc	a0,0x4
    8000433e:	20650513          	addi	a0,a0,518 # 80008540 <etext+0x540>
    80004342:	ffffc097          	auipc	ra,0xffffc
    80004346:	21e080e7          	jalr	542(ra) # 80000560 <panic>
  log.lh.block[i] = b->blockno;
    8000434a:	00878693          	addi	a3,a5,8
    8000434e:	068a                	slli	a3,a3,0x2
    80004350:	0001f717          	auipc	a4,0x1f
    80004354:	08070713          	addi	a4,a4,128 # 800233d0 <log>
    80004358:	9736                	add	a4,a4,a3
    8000435a:	44d4                	lw	a3,12(s1)
    8000435c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000435e:	faf609e3          	beq	a2,a5,80004310 <log_write+0x76>
  }
  release(&log.lock);
    80004362:	0001f517          	auipc	a0,0x1f
    80004366:	06e50513          	addi	a0,a0,110 # 800233d0 <log>
    8000436a:	ffffd097          	auipc	ra,0xffffd
    8000436e:	982080e7          	jalr	-1662(ra) # 80000cec <release>
}
    80004372:	60e2                	ld	ra,24(sp)
    80004374:	6442                	ld	s0,16(sp)
    80004376:	64a2                	ld	s1,8(sp)
    80004378:	6902                	ld	s2,0(sp)
    8000437a:	6105                	addi	sp,sp,32
    8000437c:	8082                	ret

000000008000437e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000437e:	1101                	addi	sp,sp,-32
    80004380:	ec06                	sd	ra,24(sp)
    80004382:	e822                	sd	s0,16(sp)
    80004384:	e426                	sd	s1,8(sp)
    80004386:	e04a                	sd	s2,0(sp)
    80004388:	1000                	addi	s0,sp,32
    8000438a:	84aa                	mv	s1,a0
    8000438c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000438e:	00004597          	auipc	a1,0x4
    80004392:	1d258593          	addi	a1,a1,466 # 80008560 <etext+0x560>
    80004396:	0521                	addi	a0,a0,8
    80004398:	ffffd097          	auipc	ra,0xffffd
    8000439c:	810080e7          	jalr	-2032(ra) # 80000ba8 <initlock>
  lk->name = name;
    800043a0:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800043a4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043a8:	0204a423          	sw	zero,40(s1)
}
    800043ac:	60e2                	ld	ra,24(sp)
    800043ae:	6442                	ld	s0,16(sp)
    800043b0:	64a2                	ld	s1,8(sp)
    800043b2:	6902                	ld	s2,0(sp)
    800043b4:	6105                	addi	sp,sp,32
    800043b6:	8082                	ret

00000000800043b8 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800043b8:	1101                	addi	sp,sp,-32
    800043ba:	ec06                	sd	ra,24(sp)
    800043bc:	e822                	sd	s0,16(sp)
    800043be:	e426                	sd	s1,8(sp)
    800043c0:	e04a                	sd	s2,0(sp)
    800043c2:	1000                	addi	s0,sp,32
    800043c4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043c6:	00850913          	addi	s2,a0,8
    800043ca:	854a                	mv	a0,s2
    800043cc:	ffffd097          	auipc	ra,0xffffd
    800043d0:	86c080e7          	jalr	-1940(ra) # 80000c38 <acquire>
  while (lk->locked) {
    800043d4:	409c                	lw	a5,0(s1)
    800043d6:	cb89                	beqz	a5,800043e8 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800043d8:	85ca                	mv	a1,s2
    800043da:	8526                	mv	a0,s1
    800043dc:	ffffe097          	auipc	ra,0xffffe
    800043e0:	d18080e7          	jalr	-744(ra) # 800020f4 <sleep>
  while (lk->locked) {
    800043e4:	409c                	lw	a5,0(s1)
    800043e6:	fbed                	bnez	a5,800043d8 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800043e8:	4785                	li	a5,1
    800043ea:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800043ec:	ffffd097          	auipc	ra,0xffffd
    800043f0:	65e080e7          	jalr	1630(ra) # 80001a4a <myproc>
    800043f4:	591c                	lw	a5,48(a0)
    800043f6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800043f8:	854a                	mv	a0,s2
    800043fa:	ffffd097          	auipc	ra,0xffffd
    800043fe:	8f2080e7          	jalr	-1806(ra) # 80000cec <release>
}
    80004402:	60e2                	ld	ra,24(sp)
    80004404:	6442                	ld	s0,16(sp)
    80004406:	64a2                	ld	s1,8(sp)
    80004408:	6902                	ld	s2,0(sp)
    8000440a:	6105                	addi	sp,sp,32
    8000440c:	8082                	ret

000000008000440e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000440e:	1101                	addi	sp,sp,-32
    80004410:	ec06                	sd	ra,24(sp)
    80004412:	e822                	sd	s0,16(sp)
    80004414:	e426                	sd	s1,8(sp)
    80004416:	e04a                	sd	s2,0(sp)
    80004418:	1000                	addi	s0,sp,32
    8000441a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000441c:	00850913          	addi	s2,a0,8
    80004420:	854a                	mv	a0,s2
    80004422:	ffffd097          	auipc	ra,0xffffd
    80004426:	816080e7          	jalr	-2026(ra) # 80000c38 <acquire>
  lk->locked = 0;
    8000442a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000442e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004432:	8526                	mv	a0,s1
    80004434:	ffffe097          	auipc	ra,0xffffe
    80004438:	d24080e7          	jalr	-732(ra) # 80002158 <wakeup>
  release(&lk->lk);
    8000443c:	854a                	mv	a0,s2
    8000443e:	ffffd097          	auipc	ra,0xffffd
    80004442:	8ae080e7          	jalr	-1874(ra) # 80000cec <release>
}
    80004446:	60e2                	ld	ra,24(sp)
    80004448:	6442                	ld	s0,16(sp)
    8000444a:	64a2                	ld	s1,8(sp)
    8000444c:	6902                	ld	s2,0(sp)
    8000444e:	6105                	addi	sp,sp,32
    80004450:	8082                	ret

0000000080004452 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004452:	7179                	addi	sp,sp,-48
    80004454:	f406                	sd	ra,40(sp)
    80004456:	f022                	sd	s0,32(sp)
    80004458:	ec26                	sd	s1,24(sp)
    8000445a:	e84a                	sd	s2,16(sp)
    8000445c:	1800                	addi	s0,sp,48
    8000445e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004460:	00850913          	addi	s2,a0,8
    80004464:	854a                	mv	a0,s2
    80004466:	ffffc097          	auipc	ra,0xffffc
    8000446a:	7d2080e7          	jalr	2002(ra) # 80000c38 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000446e:	409c                	lw	a5,0(s1)
    80004470:	ef91                	bnez	a5,8000448c <holdingsleep+0x3a>
    80004472:	4481                	li	s1,0
  release(&lk->lk);
    80004474:	854a                	mv	a0,s2
    80004476:	ffffd097          	auipc	ra,0xffffd
    8000447a:	876080e7          	jalr	-1930(ra) # 80000cec <release>
  return r;
}
    8000447e:	8526                	mv	a0,s1
    80004480:	70a2                	ld	ra,40(sp)
    80004482:	7402                	ld	s0,32(sp)
    80004484:	64e2                	ld	s1,24(sp)
    80004486:	6942                	ld	s2,16(sp)
    80004488:	6145                	addi	sp,sp,48
    8000448a:	8082                	ret
    8000448c:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000448e:	0284a983          	lw	s3,40(s1)
    80004492:	ffffd097          	auipc	ra,0xffffd
    80004496:	5b8080e7          	jalr	1464(ra) # 80001a4a <myproc>
    8000449a:	5904                	lw	s1,48(a0)
    8000449c:	413484b3          	sub	s1,s1,s3
    800044a0:	0014b493          	seqz	s1,s1
    800044a4:	69a2                	ld	s3,8(sp)
    800044a6:	b7f9                	j	80004474 <holdingsleep+0x22>

00000000800044a8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800044a8:	1141                	addi	sp,sp,-16
    800044aa:	e406                	sd	ra,8(sp)
    800044ac:	e022                	sd	s0,0(sp)
    800044ae:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800044b0:	00004597          	auipc	a1,0x4
    800044b4:	0c058593          	addi	a1,a1,192 # 80008570 <etext+0x570>
    800044b8:	0001f517          	auipc	a0,0x1f
    800044bc:	06050513          	addi	a0,a0,96 # 80023518 <ftable>
    800044c0:	ffffc097          	auipc	ra,0xffffc
    800044c4:	6e8080e7          	jalr	1768(ra) # 80000ba8 <initlock>
}
    800044c8:	60a2                	ld	ra,8(sp)
    800044ca:	6402                	ld	s0,0(sp)
    800044cc:	0141                	addi	sp,sp,16
    800044ce:	8082                	ret

00000000800044d0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800044d0:	1101                	addi	sp,sp,-32
    800044d2:	ec06                	sd	ra,24(sp)
    800044d4:	e822                	sd	s0,16(sp)
    800044d6:	e426                	sd	s1,8(sp)
    800044d8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800044da:	0001f517          	auipc	a0,0x1f
    800044de:	03e50513          	addi	a0,a0,62 # 80023518 <ftable>
    800044e2:	ffffc097          	auipc	ra,0xffffc
    800044e6:	756080e7          	jalr	1878(ra) # 80000c38 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044ea:	0001f497          	auipc	s1,0x1f
    800044ee:	04648493          	addi	s1,s1,70 # 80023530 <ftable+0x18>
    800044f2:	00020717          	auipc	a4,0x20
    800044f6:	fde70713          	addi	a4,a4,-34 # 800244d0 <disk>
    if(f->ref == 0){
    800044fa:	40dc                	lw	a5,4(s1)
    800044fc:	cf99                	beqz	a5,8000451a <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044fe:	02848493          	addi	s1,s1,40
    80004502:	fee49ce3          	bne	s1,a4,800044fa <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004506:	0001f517          	auipc	a0,0x1f
    8000450a:	01250513          	addi	a0,a0,18 # 80023518 <ftable>
    8000450e:	ffffc097          	auipc	ra,0xffffc
    80004512:	7de080e7          	jalr	2014(ra) # 80000cec <release>
  return 0;
    80004516:	4481                	li	s1,0
    80004518:	a819                	j	8000452e <filealloc+0x5e>
      f->ref = 1;
    8000451a:	4785                	li	a5,1
    8000451c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000451e:	0001f517          	auipc	a0,0x1f
    80004522:	ffa50513          	addi	a0,a0,-6 # 80023518 <ftable>
    80004526:	ffffc097          	auipc	ra,0xffffc
    8000452a:	7c6080e7          	jalr	1990(ra) # 80000cec <release>
}
    8000452e:	8526                	mv	a0,s1
    80004530:	60e2                	ld	ra,24(sp)
    80004532:	6442                	ld	s0,16(sp)
    80004534:	64a2                	ld	s1,8(sp)
    80004536:	6105                	addi	sp,sp,32
    80004538:	8082                	ret

000000008000453a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000453a:	1101                	addi	sp,sp,-32
    8000453c:	ec06                	sd	ra,24(sp)
    8000453e:	e822                	sd	s0,16(sp)
    80004540:	e426                	sd	s1,8(sp)
    80004542:	1000                	addi	s0,sp,32
    80004544:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004546:	0001f517          	auipc	a0,0x1f
    8000454a:	fd250513          	addi	a0,a0,-46 # 80023518 <ftable>
    8000454e:	ffffc097          	auipc	ra,0xffffc
    80004552:	6ea080e7          	jalr	1770(ra) # 80000c38 <acquire>
  if(f->ref < 1)
    80004556:	40dc                	lw	a5,4(s1)
    80004558:	02f05263          	blez	a5,8000457c <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000455c:	2785                	addiw	a5,a5,1
    8000455e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004560:	0001f517          	auipc	a0,0x1f
    80004564:	fb850513          	addi	a0,a0,-72 # 80023518 <ftable>
    80004568:	ffffc097          	auipc	ra,0xffffc
    8000456c:	784080e7          	jalr	1924(ra) # 80000cec <release>
  return f;
}
    80004570:	8526                	mv	a0,s1
    80004572:	60e2                	ld	ra,24(sp)
    80004574:	6442                	ld	s0,16(sp)
    80004576:	64a2                	ld	s1,8(sp)
    80004578:	6105                	addi	sp,sp,32
    8000457a:	8082                	ret
    panic("filedup");
    8000457c:	00004517          	auipc	a0,0x4
    80004580:	ffc50513          	addi	a0,a0,-4 # 80008578 <etext+0x578>
    80004584:	ffffc097          	auipc	ra,0xffffc
    80004588:	fdc080e7          	jalr	-36(ra) # 80000560 <panic>

000000008000458c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000458c:	7139                	addi	sp,sp,-64
    8000458e:	fc06                	sd	ra,56(sp)
    80004590:	f822                	sd	s0,48(sp)
    80004592:	f426                	sd	s1,40(sp)
    80004594:	0080                	addi	s0,sp,64
    80004596:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004598:	0001f517          	auipc	a0,0x1f
    8000459c:	f8050513          	addi	a0,a0,-128 # 80023518 <ftable>
    800045a0:	ffffc097          	auipc	ra,0xffffc
    800045a4:	698080e7          	jalr	1688(ra) # 80000c38 <acquire>
  if(f->ref < 1)
    800045a8:	40dc                	lw	a5,4(s1)
    800045aa:	04f05c63          	blez	a5,80004602 <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    800045ae:	37fd                	addiw	a5,a5,-1
    800045b0:	0007871b          	sext.w	a4,a5
    800045b4:	c0dc                	sw	a5,4(s1)
    800045b6:	06e04263          	bgtz	a4,8000461a <fileclose+0x8e>
    800045ba:	f04a                	sd	s2,32(sp)
    800045bc:	ec4e                	sd	s3,24(sp)
    800045be:	e852                	sd	s4,16(sp)
    800045c0:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800045c2:	0004a903          	lw	s2,0(s1)
    800045c6:	0094ca83          	lbu	s5,9(s1)
    800045ca:	0104ba03          	ld	s4,16(s1)
    800045ce:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800045d2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800045d6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800045da:	0001f517          	auipc	a0,0x1f
    800045de:	f3e50513          	addi	a0,a0,-194 # 80023518 <ftable>
    800045e2:	ffffc097          	auipc	ra,0xffffc
    800045e6:	70a080e7          	jalr	1802(ra) # 80000cec <release>

  if(ff.type == FD_PIPE){
    800045ea:	4785                	li	a5,1
    800045ec:	04f90463          	beq	s2,a5,80004634 <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800045f0:	3979                	addiw	s2,s2,-2
    800045f2:	4785                	li	a5,1
    800045f4:	0527fb63          	bgeu	a5,s2,8000464a <fileclose+0xbe>
    800045f8:	7902                	ld	s2,32(sp)
    800045fa:	69e2                	ld	s3,24(sp)
    800045fc:	6a42                	ld	s4,16(sp)
    800045fe:	6aa2                	ld	s5,8(sp)
    80004600:	a02d                	j	8000462a <fileclose+0x9e>
    80004602:	f04a                	sd	s2,32(sp)
    80004604:	ec4e                	sd	s3,24(sp)
    80004606:	e852                	sd	s4,16(sp)
    80004608:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000460a:	00004517          	auipc	a0,0x4
    8000460e:	f7650513          	addi	a0,a0,-138 # 80008580 <etext+0x580>
    80004612:	ffffc097          	auipc	ra,0xffffc
    80004616:	f4e080e7          	jalr	-178(ra) # 80000560 <panic>
    release(&ftable.lock);
    8000461a:	0001f517          	auipc	a0,0x1f
    8000461e:	efe50513          	addi	a0,a0,-258 # 80023518 <ftable>
    80004622:	ffffc097          	auipc	ra,0xffffc
    80004626:	6ca080e7          	jalr	1738(ra) # 80000cec <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000462a:	70e2                	ld	ra,56(sp)
    8000462c:	7442                	ld	s0,48(sp)
    8000462e:	74a2                	ld	s1,40(sp)
    80004630:	6121                	addi	sp,sp,64
    80004632:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004634:	85d6                	mv	a1,s5
    80004636:	8552                	mv	a0,s4
    80004638:	00000097          	auipc	ra,0x0
    8000463c:	3a2080e7          	jalr	930(ra) # 800049da <pipeclose>
    80004640:	7902                	ld	s2,32(sp)
    80004642:	69e2                	ld	s3,24(sp)
    80004644:	6a42                	ld	s4,16(sp)
    80004646:	6aa2                	ld	s5,8(sp)
    80004648:	b7cd                	j	8000462a <fileclose+0x9e>
    begin_op();
    8000464a:	00000097          	auipc	ra,0x0
    8000464e:	a78080e7          	jalr	-1416(ra) # 800040c2 <begin_op>
    iput(ff.ip);
    80004652:	854e                	mv	a0,s3
    80004654:	fffff097          	auipc	ra,0xfffff
    80004658:	25e080e7          	jalr	606(ra) # 800038b2 <iput>
    end_op();
    8000465c:	00000097          	auipc	ra,0x0
    80004660:	ae0080e7          	jalr	-1312(ra) # 8000413c <end_op>
    80004664:	7902                	ld	s2,32(sp)
    80004666:	69e2                	ld	s3,24(sp)
    80004668:	6a42                	ld	s4,16(sp)
    8000466a:	6aa2                	ld	s5,8(sp)
    8000466c:	bf7d                	j	8000462a <fileclose+0x9e>

000000008000466e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000466e:	715d                	addi	sp,sp,-80
    80004670:	e486                	sd	ra,72(sp)
    80004672:	e0a2                	sd	s0,64(sp)
    80004674:	fc26                	sd	s1,56(sp)
    80004676:	f44e                	sd	s3,40(sp)
    80004678:	0880                	addi	s0,sp,80
    8000467a:	84aa                	mv	s1,a0
    8000467c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000467e:	ffffd097          	auipc	ra,0xffffd
    80004682:	3cc080e7          	jalr	972(ra) # 80001a4a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004686:	409c                	lw	a5,0(s1)
    80004688:	37f9                	addiw	a5,a5,-2
    8000468a:	4705                	li	a4,1
    8000468c:	04f76863          	bltu	a4,a5,800046dc <filestat+0x6e>
    80004690:	f84a                	sd	s2,48(sp)
    80004692:	892a                	mv	s2,a0
    ilock(f->ip);
    80004694:	6c88                	ld	a0,24(s1)
    80004696:	fffff097          	auipc	ra,0xfffff
    8000469a:	05e080e7          	jalr	94(ra) # 800036f4 <ilock>
    stati(f->ip, &st);
    8000469e:	fb840593          	addi	a1,s0,-72
    800046a2:	6c88                	ld	a0,24(s1)
    800046a4:	fffff097          	auipc	ra,0xfffff
    800046a8:	2de080e7          	jalr	734(ra) # 80003982 <stati>
    iunlock(f->ip);
    800046ac:	6c88                	ld	a0,24(s1)
    800046ae:	fffff097          	auipc	ra,0xfffff
    800046b2:	10c080e7          	jalr	268(ra) # 800037ba <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800046b6:	46e1                	li	a3,24
    800046b8:	fb840613          	addi	a2,s0,-72
    800046bc:	85ce                	mv	a1,s3
    800046be:	05093503          	ld	a0,80(s2)
    800046c2:	ffffd097          	auipc	ra,0xffffd
    800046c6:	020080e7          	jalr	32(ra) # 800016e2 <copyout>
    800046ca:	41f5551b          	sraiw	a0,a0,0x1f
    800046ce:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800046d0:	60a6                	ld	ra,72(sp)
    800046d2:	6406                	ld	s0,64(sp)
    800046d4:	74e2                	ld	s1,56(sp)
    800046d6:	79a2                	ld	s3,40(sp)
    800046d8:	6161                	addi	sp,sp,80
    800046da:	8082                	ret
  return -1;
    800046dc:	557d                	li	a0,-1
    800046de:	bfcd                	j	800046d0 <filestat+0x62>

00000000800046e0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800046e0:	7179                	addi	sp,sp,-48
    800046e2:	f406                	sd	ra,40(sp)
    800046e4:	f022                	sd	s0,32(sp)
    800046e6:	e84a                	sd	s2,16(sp)
    800046e8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800046ea:	00854783          	lbu	a5,8(a0)
    800046ee:	cbc5                	beqz	a5,8000479e <fileread+0xbe>
    800046f0:	ec26                	sd	s1,24(sp)
    800046f2:	e44e                	sd	s3,8(sp)
    800046f4:	84aa                	mv	s1,a0
    800046f6:	89ae                	mv	s3,a1
    800046f8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800046fa:	411c                	lw	a5,0(a0)
    800046fc:	4705                	li	a4,1
    800046fe:	04e78963          	beq	a5,a4,80004750 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004702:	470d                	li	a4,3
    80004704:	04e78f63          	beq	a5,a4,80004762 <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004708:	4709                	li	a4,2
    8000470a:	08e79263          	bne	a5,a4,8000478e <fileread+0xae>
    ilock(f->ip);
    8000470e:	6d08                	ld	a0,24(a0)
    80004710:	fffff097          	auipc	ra,0xfffff
    80004714:	fe4080e7          	jalr	-28(ra) # 800036f4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004718:	874a                	mv	a4,s2
    8000471a:	5094                	lw	a3,32(s1)
    8000471c:	864e                	mv	a2,s3
    8000471e:	4585                	li	a1,1
    80004720:	6c88                	ld	a0,24(s1)
    80004722:	fffff097          	auipc	ra,0xfffff
    80004726:	28a080e7          	jalr	650(ra) # 800039ac <readi>
    8000472a:	892a                	mv	s2,a0
    8000472c:	00a05563          	blez	a0,80004736 <fileread+0x56>
      f->off += r;
    80004730:	509c                	lw	a5,32(s1)
    80004732:	9fa9                	addw	a5,a5,a0
    80004734:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004736:	6c88                	ld	a0,24(s1)
    80004738:	fffff097          	auipc	ra,0xfffff
    8000473c:	082080e7          	jalr	130(ra) # 800037ba <iunlock>
    80004740:	64e2                	ld	s1,24(sp)
    80004742:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004744:	854a                	mv	a0,s2
    80004746:	70a2                	ld	ra,40(sp)
    80004748:	7402                	ld	s0,32(sp)
    8000474a:	6942                	ld	s2,16(sp)
    8000474c:	6145                	addi	sp,sp,48
    8000474e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004750:	6908                	ld	a0,16(a0)
    80004752:	00000097          	auipc	ra,0x0
    80004756:	400080e7          	jalr	1024(ra) # 80004b52 <piperead>
    8000475a:	892a                	mv	s2,a0
    8000475c:	64e2                	ld	s1,24(sp)
    8000475e:	69a2                	ld	s3,8(sp)
    80004760:	b7d5                	j	80004744 <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004762:	02451783          	lh	a5,36(a0)
    80004766:	03079693          	slli	a3,a5,0x30
    8000476a:	92c1                	srli	a3,a3,0x30
    8000476c:	4725                	li	a4,9
    8000476e:	02d76a63          	bltu	a4,a3,800047a2 <fileread+0xc2>
    80004772:	0792                	slli	a5,a5,0x4
    80004774:	0001f717          	auipc	a4,0x1f
    80004778:	d0470713          	addi	a4,a4,-764 # 80023478 <devsw>
    8000477c:	97ba                	add	a5,a5,a4
    8000477e:	639c                	ld	a5,0(a5)
    80004780:	c78d                	beqz	a5,800047aa <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    80004782:	4505                	li	a0,1
    80004784:	9782                	jalr	a5
    80004786:	892a                	mv	s2,a0
    80004788:	64e2                	ld	s1,24(sp)
    8000478a:	69a2                	ld	s3,8(sp)
    8000478c:	bf65                	j	80004744 <fileread+0x64>
    panic("fileread");
    8000478e:	00004517          	auipc	a0,0x4
    80004792:	e0250513          	addi	a0,a0,-510 # 80008590 <etext+0x590>
    80004796:	ffffc097          	auipc	ra,0xffffc
    8000479a:	dca080e7          	jalr	-566(ra) # 80000560 <panic>
    return -1;
    8000479e:	597d                	li	s2,-1
    800047a0:	b755                	j	80004744 <fileread+0x64>
      return -1;
    800047a2:	597d                	li	s2,-1
    800047a4:	64e2                	ld	s1,24(sp)
    800047a6:	69a2                	ld	s3,8(sp)
    800047a8:	bf71                	j	80004744 <fileread+0x64>
    800047aa:	597d                	li	s2,-1
    800047ac:	64e2                	ld	s1,24(sp)
    800047ae:	69a2                	ld	s3,8(sp)
    800047b0:	bf51                	j	80004744 <fileread+0x64>

00000000800047b2 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800047b2:	00954783          	lbu	a5,9(a0)
    800047b6:	12078963          	beqz	a5,800048e8 <filewrite+0x136>
{
    800047ba:	715d                	addi	sp,sp,-80
    800047bc:	e486                	sd	ra,72(sp)
    800047be:	e0a2                	sd	s0,64(sp)
    800047c0:	f84a                	sd	s2,48(sp)
    800047c2:	f052                	sd	s4,32(sp)
    800047c4:	e85a                	sd	s6,16(sp)
    800047c6:	0880                	addi	s0,sp,80
    800047c8:	892a                	mv	s2,a0
    800047ca:	8b2e                	mv	s6,a1
    800047cc:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800047ce:	411c                	lw	a5,0(a0)
    800047d0:	4705                	li	a4,1
    800047d2:	02e78763          	beq	a5,a4,80004800 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047d6:	470d                	li	a4,3
    800047d8:	02e78a63          	beq	a5,a4,8000480c <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800047dc:	4709                	li	a4,2
    800047de:	0ee79863          	bne	a5,a4,800048ce <filewrite+0x11c>
    800047e2:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800047e4:	0cc05463          	blez	a2,800048ac <filewrite+0xfa>
    800047e8:	fc26                	sd	s1,56(sp)
    800047ea:	ec56                	sd	s5,24(sp)
    800047ec:	e45e                	sd	s7,8(sp)
    800047ee:	e062                	sd	s8,0(sp)
    int i = 0;
    800047f0:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800047f2:	6b85                	lui	s7,0x1
    800047f4:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800047f8:	6c05                	lui	s8,0x1
    800047fa:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800047fe:	a851                	j	80004892 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004800:	6908                	ld	a0,16(a0)
    80004802:	00000097          	auipc	ra,0x0
    80004806:	248080e7          	jalr	584(ra) # 80004a4a <pipewrite>
    8000480a:	a85d                	j	800048c0 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000480c:	02451783          	lh	a5,36(a0)
    80004810:	03079693          	slli	a3,a5,0x30
    80004814:	92c1                	srli	a3,a3,0x30
    80004816:	4725                	li	a4,9
    80004818:	0cd76a63          	bltu	a4,a3,800048ec <filewrite+0x13a>
    8000481c:	0792                	slli	a5,a5,0x4
    8000481e:	0001f717          	auipc	a4,0x1f
    80004822:	c5a70713          	addi	a4,a4,-934 # 80023478 <devsw>
    80004826:	97ba                	add	a5,a5,a4
    80004828:	679c                	ld	a5,8(a5)
    8000482a:	c3f9                	beqz	a5,800048f0 <filewrite+0x13e>
    ret = devsw[f->major].write(1, addr, n);
    8000482c:	4505                	li	a0,1
    8000482e:	9782                	jalr	a5
    80004830:	a841                	j	800048c0 <filewrite+0x10e>
      if(n1 > max)
    80004832:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004836:	00000097          	auipc	ra,0x0
    8000483a:	88c080e7          	jalr	-1908(ra) # 800040c2 <begin_op>
      ilock(f->ip);
    8000483e:	01893503          	ld	a0,24(s2)
    80004842:	fffff097          	auipc	ra,0xfffff
    80004846:	eb2080e7          	jalr	-334(ra) # 800036f4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000484a:	8756                	mv	a4,s5
    8000484c:	02092683          	lw	a3,32(s2)
    80004850:	01698633          	add	a2,s3,s6
    80004854:	4585                	li	a1,1
    80004856:	01893503          	ld	a0,24(s2)
    8000485a:	fffff097          	auipc	ra,0xfffff
    8000485e:	262080e7          	jalr	610(ra) # 80003abc <writei>
    80004862:	84aa                	mv	s1,a0
    80004864:	00a05763          	blez	a0,80004872 <filewrite+0xc0>
        f->off += r;
    80004868:	02092783          	lw	a5,32(s2)
    8000486c:	9fa9                	addw	a5,a5,a0
    8000486e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004872:	01893503          	ld	a0,24(s2)
    80004876:	fffff097          	auipc	ra,0xfffff
    8000487a:	f44080e7          	jalr	-188(ra) # 800037ba <iunlock>
      end_op();
    8000487e:	00000097          	auipc	ra,0x0
    80004882:	8be080e7          	jalr	-1858(ra) # 8000413c <end_op>

      if(r != n1){
    80004886:	029a9563          	bne	s5,s1,800048b0 <filewrite+0xfe>
        // error from writei
        break;
      }
      i += r;
    8000488a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000488e:	0149da63          	bge	s3,s4,800048a2 <filewrite+0xf0>
      int n1 = n - i;
    80004892:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004896:	0004879b          	sext.w	a5,s1
    8000489a:	f8fbdce3          	bge	s7,a5,80004832 <filewrite+0x80>
    8000489e:	84e2                	mv	s1,s8
    800048a0:	bf49                	j	80004832 <filewrite+0x80>
    800048a2:	74e2                	ld	s1,56(sp)
    800048a4:	6ae2                	ld	s5,24(sp)
    800048a6:	6ba2                	ld	s7,8(sp)
    800048a8:	6c02                	ld	s8,0(sp)
    800048aa:	a039                	j	800048b8 <filewrite+0x106>
    int i = 0;
    800048ac:	4981                	li	s3,0
    800048ae:	a029                	j	800048b8 <filewrite+0x106>
    800048b0:	74e2                	ld	s1,56(sp)
    800048b2:	6ae2                	ld	s5,24(sp)
    800048b4:	6ba2                	ld	s7,8(sp)
    800048b6:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    800048b8:	033a1e63          	bne	s4,s3,800048f4 <filewrite+0x142>
    800048bc:	8552                	mv	a0,s4
    800048be:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800048c0:	60a6                	ld	ra,72(sp)
    800048c2:	6406                	ld	s0,64(sp)
    800048c4:	7942                	ld	s2,48(sp)
    800048c6:	7a02                	ld	s4,32(sp)
    800048c8:	6b42                	ld	s6,16(sp)
    800048ca:	6161                	addi	sp,sp,80
    800048cc:	8082                	ret
    800048ce:	fc26                	sd	s1,56(sp)
    800048d0:	f44e                	sd	s3,40(sp)
    800048d2:	ec56                	sd	s5,24(sp)
    800048d4:	e45e                	sd	s7,8(sp)
    800048d6:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800048d8:	00004517          	auipc	a0,0x4
    800048dc:	cc850513          	addi	a0,a0,-824 # 800085a0 <etext+0x5a0>
    800048e0:	ffffc097          	auipc	ra,0xffffc
    800048e4:	c80080e7          	jalr	-896(ra) # 80000560 <panic>
    return -1;
    800048e8:	557d                	li	a0,-1
}
    800048ea:	8082                	ret
      return -1;
    800048ec:	557d                	li	a0,-1
    800048ee:	bfc9                	j	800048c0 <filewrite+0x10e>
    800048f0:	557d                	li	a0,-1
    800048f2:	b7f9                	j	800048c0 <filewrite+0x10e>
    ret = (i == n ? n : -1);
    800048f4:	557d                	li	a0,-1
    800048f6:	79a2                	ld	s3,40(sp)
    800048f8:	b7e1                	j	800048c0 <filewrite+0x10e>

00000000800048fa <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800048fa:	7179                	addi	sp,sp,-48
    800048fc:	f406                	sd	ra,40(sp)
    800048fe:	f022                	sd	s0,32(sp)
    80004900:	ec26                	sd	s1,24(sp)
    80004902:	e052                	sd	s4,0(sp)
    80004904:	1800                	addi	s0,sp,48
    80004906:	84aa                	mv	s1,a0
    80004908:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000490a:	0005b023          	sd	zero,0(a1)
    8000490e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004912:	00000097          	auipc	ra,0x0
    80004916:	bbe080e7          	jalr	-1090(ra) # 800044d0 <filealloc>
    8000491a:	e088                	sd	a0,0(s1)
    8000491c:	cd49                	beqz	a0,800049b6 <pipealloc+0xbc>
    8000491e:	00000097          	auipc	ra,0x0
    80004922:	bb2080e7          	jalr	-1102(ra) # 800044d0 <filealloc>
    80004926:	00aa3023          	sd	a0,0(s4)
    8000492a:	c141                	beqz	a0,800049aa <pipealloc+0xb0>
    8000492c:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000492e:	ffffc097          	auipc	ra,0xffffc
    80004932:	21a080e7          	jalr	538(ra) # 80000b48 <kalloc>
    80004936:	892a                	mv	s2,a0
    80004938:	c13d                	beqz	a0,8000499e <pipealloc+0xa4>
    8000493a:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000493c:	4985                	li	s3,1
    8000493e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004942:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004946:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000494a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000494e:	00004597          	auipc	a1,0x4
    80004952:	c6258593          	addi	a1,a1,-926 # 800085b0 <etext+0x5b0>
    80004956:	ffffc097          	auipc	ra,0xffffc
    8000495a:	252080e7          	jalr	594(ra) # 80000ba8 <initlock>
  (*f0)->type = FD_PIPE;
    8000495e:	609c                	ld	a5,0(s1)
    80004960:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004964:	609c                	ld	a5,0(s1)
    80004966:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000496a:	609c                	ld	a5,0(s1)
    8000496c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004970:	609c                	ld	a5,0(s1)
    80004972:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004976:	000a3783          	ld	a5,0(s4)
    8000497a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000497e:	000a3783          	ld	a5,0(s4)
    80004982:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004986:	000a3783          	ld	a5,0(s4)
    8000498a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000498e:	000a3783          	ld	a5,0(s4)
    80004992:	0127b823          	sd	s2,16(a5)
  return 0;
    80004996:	4501                	li	a0,0
    80004998:	6942                	ld	s2,16(sp)
    8000499a:	69a2                	ld	s3,8(sp)
    8000499c:	a03d                	j	800049ca <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000499e:	6088                	ld	a0,0(s1)
    800049a0:	c119                	beqz	a0,800049a6 <pipealloc+0xac>
    800049a2:	6942                	ld	s2,16(sp)
    800049a4:	a029                	j	800049ae <pipealloc+0xb4>
    800049a6:	6942                	ld	s2,16(sp)
    800049a8:	a039                	j	800049b6 <pipealloc+0xbc>
    800049aa:	6088                	ld	a0,0(s1)
    800049ac:	c50d                	beqz	a0,800049d6 <pipealloc+0xdc>
    fileclose(*f0);
    800049ae:	00000097          	auipc	ra,0x0
    800049b2:	bde080e7          	jalr	-1058(ra) # 8000458c <fileclose>
  if(*f1)
    800049b6:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800049ba:	557d                	li	a0,-1
  if(*f1)
    800049bc:	c799                	beqz	a5,800049ca <pipealloc+0xd0>
    fileclose(*f1);
    800049be:	853e                	mv	a0,a5
    800049c0:	00000097          	auipc	ra,0x0
    800049c4:	bcc080e7          	jalr	-1076(ra) # 8000458c <fileclose>
  return -1;
    800049c8:	557d                	li	a0,-1
}
    800049ca:	70a2                	ld	ra,40(sp)
    800049cc:	7402                	ld	s0,32(sp)
    800049ce:	64e2                	ld	s1,24(sp)
    800049d0:	6a02                	ld	s4,0(sp)
    800049d2:	6145                	addi	sp,sp,48
    800049d4:	8082                	ret
  return -1;
    800049d6:	557d                	li	a0,-1
    800049d8:	bfcd                	j	800049ca <pipealloc+0xd0>

00000000800049da <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800049da:	1101                	addi	sp,sp,-32
    800049dc:	ec06                	sd	ra,24(sp)
    800049de:	e822                	sd	s0,16(sp)
    800049e0:	e426                	sd	s1,8(sp)
    800049e2:	e04a                	sd	s2,0(sp)
    800049e4:	1000                	addi	s0,sp,32
    800049e6:	84aa                	mv	s1,a0
    800049e8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800049ea:	ffffc097          	auipc	ra,0xffffc
    800049ee:	24e080e7          	jalr	590(ra) # 80000c38 <acquire>
  if(writable){
    800049f2:	02090d63          	beqz	s2,80004a2c <pipeclose+0x52>
    pi->writeopen = 0;
    800049f6:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800049fa:	21848513          	addi	a0,s1,536
    800049fe:	ffffd097          	auipc	ra,0xffffd
    80004a02:	75a080e7          	jalr	1882(ra) # 80002158 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a06:	2204b783          	ld	a5,544(s1)
    80004a0a:	eb95                	bnez	a5,80004a3e <pipeclose+0x64>
    release(&pi->lock);
    80004a0c:	8526                	mv	a0,s1
    80004a0e:	ffffc097          	auipc	ra,0xffffc
    80004a12:	2de080e7          	jalr	734(ra) # 80000cec <release>
    kfree((char*)pi);
    80004a16:	8526                	mv	a0,s1
    80004a18:	ffffc097          	auipc	ra,0xffffc
    80004a1c:	032080e7          	jalr	50(ra) # 80000a4a <kfree>
  } else
    release(&pi->lock);
}
    80004a20:	60e2                	ld	ra,24(sp)
    80004a22:	6442                	ld	s0,16(sp)
    80004a24:	64a2                	ld	s1,8(sp)
    80004a26:	6902                	ld	s2,0(sp)
    80004a28:	6105                	addi	sp,sp,32
    80004a2a:	8082                	ret
    pi->readopen = 0;
    80004a2c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a30:	21c48513          	addi	a0,s1,540
    80004a34:	ffffd097          	auipc	ra,0xffffd
    80004a38:	724080e7          	jalr	1828(ra) # 80002158 <wakeup>
    80004a3c:	b7e9                	j	80004a06 <pipeclose+0x2c>
    release(&pi->lock);
    80004a3e:	8526                	mv	a0,s1
    80004a40:	ffffc097          	auipc	ra,0xffffc
    80004a44:	2ac080e7          	jalr	684(ra) # 80000cec <release>
}
    80004a48:	bfe1                	j	80004a20 <pipeclose+0x46>

0000000080004a4a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a4a:	711d                	addi	sp,sp,-96
    80004a4c:	ec86                	sd	ra,88(sp)
    80004a4e:	e8a2                	sd	s0,80(sp)
    80004a50:	e4a6                	sd	s1,72(sp)
    80004a52:	e0ca                	sd	s2,64(sp)
    80004a54:	fc4e                	sd	s3,56(sp)
    80004a56:	f852                	sd	s4,48(sp)
    80004a58:	f456                	sd	s5,40(sp)
    80004a5a:	1080                	addi	s0,sp,96
    80004a5c:	84aa                	mv	s1,a0
    80004a5e:	8aae                	mv	s5,a1
    80004a60:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a62:	ffffd097          	auipc	ra,0xffffd
    80004a66:	fe8080e7          	jalr	-24(ra) # 80001a4a <myproc>
    80004a6a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004a6c:	8526                	mv	a0,s1
    80004a6e:	ffffc097          	auipc	ra,0xffffc
    80004a72:	1ca080e7          	jalr	458(ra) # 80000c38 <acquire>
  while(i < n){
    80004a76:	0d405863          	blez	s4,80004b46 <pipewrite+0xfc>
    80004a7a:	f05a                	sd	s6,32(sp)
    80004a7c:	ec5e                	sd	s7,24(sp)
    80004a7e:	e862                	sd	s8,16(sp)
  int i = 0;
    80004a80:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a82:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004a84:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a88:	21c48b93          	addi	s7,s1,540
    80004a8c:	a089                	j	80004ace <pipewrite+0x84>
      release(&pi->lock);
    80004a8e:	8526                	mv	a0,s1
    80004a90:	ffffc097          	auipc	ra,0xffffc
    80004a94:	25c080e7          	jalr	604(ra) # 80000cec <release>
      return -1;
    80004a98:	597d                	li	s2,-1
    80004a9a:	7b02                	ld	s6,32(sp)
    80004a9c:	6be2                	ld	s7,24(sp)
    80004a9e:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004aa0:	854a                	mv	a0,s2
    80004aa2:	60e6                	ld	ra,88(sp)
    80004aa4:	6446                	ld	s0,80(sp)
    80004aa6:	64a6                	ld	s1,72(sp)
    80004aa8:	6906                	ld	s2,64(sp)
    80004aaa:	79e2                	ld	s3,56(sp)
    80004aac:	7a42                	ld	s4,48(sp)
    80004aae:	7aa2                	ld	s5,40(sp)
    80004ab0:	6125                	addi	sp,sp,96
    80004ab2:	8082                	ret
      wakeup(&pi->nread);
    80004ab4:	8562                	mv	a0,s8
    80004ab6:	ffffd097          	auipc	ra,0xffffd
    80004aba:	6a2080e7          	jalr	1698(ra) # 80002158 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004abe:	85a6                	mv	a1,s1
    80004ac0:	855e                	mv	a0,s7
    80004ac2:	ffffd097          	auipc	ra,0xffffd
    80004ac6:	632080e7          	jalr	1586(ra) # 800020f4 <sleep>
  while(i < n){
    80004aca:	05495f63          	bge	s2,s4,80004b28 <pipewrite+0xde>
    if(pi->readopen == 0 || killed(pr)){
    80004ace:	2204a783          	lw	a5,544(s1)
    80004ad2:	dfd5                	beqz	a5,80004a8e <pipewrite+0x44>
    80004ad4:	854e                	mv	a0,s3
    80004ad6:	ffffe097          	auipc	ra,0xffffe
    80004ada:	8c6080e7          	jalr	-1850(ra) # 8000239c <killed>
    80004ade:	f945                	bnez	a0,80004a8e <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004ae0:	2184a783          	lw	a5,536(s1)
    80004ae4:	21c4a703          	lw	a4,540(s1)
    80004ae8:	2007879b          	addiw	a5,a5,512
    80004aec:	fcf704e3          	beq	a4,a5,80004ab4 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004af0:	4685                	li	a3,1
    80004af2:	01590633          	add	a2,s2,s5
    80004af6:	faf40593          	addi	a1,s0,-81
    80004afa:	0509b503          	ld	a0,80(s3)
    80004afe:	ffffd097          	auipc	ra,0xffffd
    80004b02:	c70080e7          	jalr	-912(ra) # 8000176e <copyin>
    80004b06:	05650263          	beq	a0,s6,80004b4a <pipewrite+0x100>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b0a:	21c4a783          	lw	a5,540(s1)
    80004b0e:	0017871b          	addiw	a4,a5,1
    80004b12:	20e4ae23          	sw	a4,540(s1)
    80004b16:	1ff7f793          	andi	a5,a5,511
    80004b1a:	97a6                	add	a5,a5,s1
    80004b1c:	faf44703          	lbu	a4,-81(s0)
    80004b20:	00e78c23          	sb	a4,24(a5)
      i++;
    80004b24:	2905                	addiw	s2,s2,1
    80004b26:	b755                	j	80004aca <pipewrite+0x80>
    80004b28:	7b02                	ld	s6,32(sp)
    80004b2a:	6be2                	ld	s7,24(sp)
    80004b2c:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004b2e:	21848513          	addi	a0,s1,536
    80004b32:	ffffd097          	auipc	ra,0xffffd
    80004b36:	626080e7          	jalr	1574(ra) # 80002158 <wakeup>
  release(&pi->lock);
    80004b3a:	8526                	mv	a0,s1
    80004b3c:	ffffc097          	auipc	ra,0xffffc
    80004b40:	1b0080e7          	jalr	432(ra) # 80000cec <release>
  return i;
    80004b44:	bfb1                	j	80004aa0 <pipewrite+0x56>
  int i = 0;
    80004b46:	4901                	li	s2,0
    80004b48:	b7dd                	j	80004b2e <pipewrite+0xe4>
    80004b4a:	7b02                	ld	s6,32(sp)
    80004b4c:	6be2                	ld	s7,24(sp)
    80004b4e:	6c42                	ld	s8,16(sp)
    80004b50:	bff9                	j	80004b2e <pipewrite+0xe4>

0000000080004b52 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b52:	715d                	addi	sp,sp,-80
    80004b54:	e486                	sd	ra,72(sp)
    80004b56:	e0a2                	sd	s0,64(sp)
    80004b58:	fc26                	sd	s1,56(sp)
    80004b5a:	f84a                	sd	s2,48(sp)
    80004b5c:	f44e                	sd	s3,40(sp)
    80004b5e:	f052                	sd	s4,32(sp)
    80004b60:	ec56                	sd	s5,24(sp)
    80004b62:	0880                	addi	s0,sp,80
    80004b64:	84aa                	mv	s1,a0
    80004b66:	892e                	mv	s2,a1
    80004b68:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b6a:	ffffd097          	auipc	ra,0xffffd
    80004b6e:	ee0080e7          	jalr	-288(ra) # 80001a4a <myproc>
    80004b72:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b74:	8526                	mv	a0,s1
    80004b76:	ffffc097          	auipc	ra,0xffffc
    80004b7a:	0c2080e7          	jalr	194(ra) # 80000c38 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b7e:	2184a703          	lw	a4,536(s1)
    80004b82:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b86:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b8a:	02f71963          	bne	a4,a5,80004bbc <piperead+0x6a>
    80004b8e:	2244a783          	lw	a5,548(s1)
    80004b92:	cf95                	beqz	a5,80004bce <piperead+0x7c>
    if(killed(pr)){
    80004b94:	8552                	mv	a0,s4
    80004b96:	ffffe097          	auipc	ra,0xffffe
    80004b9a:	806080e7          	jalr	-2042(ra) # 8000239c <killed>
    80004b9e:	e10d                	bnez	a0,80004bc0 <piperead+0x6e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ba0:	85a6                	mv	a1,s1
    80004ba2:	854e                	mv	a0,s3
    80004ba4:	ffffd097          	auipc	ra,0xffffd
    80004ba8:	550080e7          	jalr	1360(ra) # 800020f4 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bac:	2184a703          	lw	a4,536(s1)
    80004bb0:	21c4a783          	lw	a5,540(s1)
    80004bb4:	fcf70de3          	beq	a4,a5,80004b8e <piperead+0x3c>
    80004bb8:	e85a                	sd	s6,16(sp)
    80004bba:	a819                	j	80004bd0 <piperead+0x7e>
    80004bbc:	e85a                	sd	s6,16(sp)
    80004bbe:	a809                	j	80004bd0 <piperead+0x7e>
      release(&pi->lock);
    80004bc0:	8526                	mv	a0,s1
    80004bc2:	ffffc097          	auipc	ra,0xffffc
    80004bc6:	12a080e7          	jalr	298(ra) # 80000cec <release>
      return -1;
    80004bca:	59fd                	li	s3,-1
    80004bcc:	a0a5                	j	80004c34 <piperead+0xe2>
    80004bce:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bd0:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004bd2:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bd4:	05505463          	blez	s5,80004c1c <piperead+0xca>
    if(pi->nread == pi->nwrite)
    80004bd8:	2184a783          	lw	a5,536(s1)
    80004bdc:	21c4a703          	lw	a4,540(s1)
    80004be0:	02f70e63          	beq	a4,a5,80004c1c <piperead+0xca>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004be4:	0017871b          	addiw	a4,a5,1
    80004be8:	20e4ac23          	sw	a4,536(s1)
    80004bec:	1ff7f793          	andi	a5,a5,511
    80004bf0:	97a6                	add	a5,a5,s1
    80004bf2:	0187c783          	lbu	a5,24(a5)
    80004bf6:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004bfa:	4685                	li	a3,1
    80004bfc:	fbf40613          	addi	a2,s0,-65
    80004c00:	85ca                	mv	a1,s2
    80004c02:	050a3503          	ld	a0,80(s4)
    80004c06:	ffffd097          	auipc	ra,0xffffd
    80004c0a:	adc080e7          	jalr	-1316(ra) # 800016e2 <copyout>
    80004c0e:	01650763          	beq	a0,s6,80004c1c <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c12:	2985                	addiw	s3,s3,1
    80004c14:	0905                	addi	s2,s2,1
    80004c16:	fd3a91e3          	bne	s5,s3,80004bd8 <piperead+0x86>
    80004c1a:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c1c:	21c48513          	addi	a0,s1,540
    80004c20:	ffffd097          	auipc	ra,0xffffd
    80004c24:	538080e7          	jalr	1336(ra) # 80002158 <wakeup>
  release(&pi->lock);
    80004c28:	8526                	mv	a0,s1
    80004c2a:	ffffc097          	auipc	ra,0xffffc
    80004c2e:	0c2080e7          	jalr	194(ra) # 80000cec <release>
    80004c32:	6b42                	ld	s6,16(sp)
  return i;
}
    80004c34:	854e                	mv	a0,s3
    80004c36:	60a6                	ld	ra,72(sp)
    80004c38:	6406                	ld	s0,64(sp)
    80004c3a:	74e2                	ld	s1,56(sp)
    80004c3c:	7942                	ld	s2,48(sp)
    80004c3e:	79a2                	ld	s3,40(sp)
    80004c40:	7a02                	ld	s4,32(sp)
    80004c42:	6ae2                	ld	s5,24(sp)
    80004c44:	6161                	addi	sp,sp,80
    80004c46:	8082                	ret

0000000080004c48 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004c48:	1141                	addi	sp,sp,-16
    80004c4a:	e422                	sd	s0,8(sp)
    80004c4c:	0800                	addi	s0,sp,16
    80004c4e:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004c50:	8905                	andi	a0,a0,1
    80004c52:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004c54:	8b89                	andi	a5,a5,2
    80004c56:	c399                	beqz	a5,80004c5c <flags2perm+0x14>
      perm |= PTE_W;
    80004c58:	00456513          	ori	a0,a0,4
    return perm;
}
    80004c5c:	6422                	ld	s0,8(sp)
    80004c5e:	0141                	addi	sp,sp,16
    80004c60:	8082                	ret

0000000080004c62 <exec>:

int
exec(char *path, char **argv)
{
    80004c62:	df010113          	addi	sp,sp,-528
    80004c66:	20113423          	sd	ra,520(sp)
    80004c6a:	20813023          	sd	s0,512(sp)
    80004c6e:	ffa6                	sd	s1,504(sp)
    80004c70:	fbca                	sd	s2,496(sp)
    80004c72:	0c00                	addi	s0,sp,528
    80004c74:	892a                	mv	s2,a0
    80004c76:	dea43c23          	sd	a0,-520(s0)
    80004c7a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c7e:	ffffd097          	auipc	ra,0xffffd
    80004c82:	dcc080e7          	jalr	-564(ra) # 80001a4a <myproc>
    80004c86:	84aa                	mv	s1,a0

  begin_op();
    80004c88:	fffff097          	auipc	ra,0xfffff
    80004c8c:	43a080e7          	jalr	1082(ra) # 800040c2 <begin_op>

  if((ip = namei(path)) == 0){
    80004c90:	854a                	mv	a0,s2
    80004c92:	fffff097          	auipc	ra,0xfffff
    80004c96:	230080e7          	jalr	560(ra) # 80003ec2 <namei>
    80004c9a:	c135                	beqz	a0,80004cfe <exec+0x9c>
    80004c9c:	f3d2                	sd	s4,480(sp)
    80004c9e:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004ca0:	fffff097          	auipc	ra,0xfffff
    80004ca4:	a54080e7          	jalr	-1452(ra) # 800036f4 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004ca8:	04000713          	li	a4,64
    80004cac:	4681                	li	a3,0
    80004cae:	e5040613          	addi	a2,s0,-432
    80004cb2:	4581                	li	a1,0
    80004cb4:	8552                	mv	a0,s4
    80004cb6:	fffff097          	auipc	ra,0xfffff
    80004cba:	cf6080e7          	jalr	-778(ra) # 800039ac <readi>
    80004cbe:	04000793          	li	a5,64
    80004cc2:	00f51a63          	bne	a0,a5,80004cd6 <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004cc6:	e5042703          	lw	a4,-432(s0)
    80004cca:	464c47b7          	lui	a5,0x464c4
    80004cce:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004cd2:	02f70c63          	beq	a4,a5,80004d0a <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004cd6:	8552                	mv	a0,s4
    80004cd8:	fffff097          	auipc	ra,0xfffff
    80004cdc:	c82080e7          	jalr	-894(ra) # 8000395a <iunlockput>
    end_op();
    80004ce0:	fffff097          	auipc	ra,0xfffff
    80004ce4:	45c080e7          	jalr	1116(ra) # 8000413c <end_op>
  }
  return -1;
    80004ce8:	557d                	li	a0,-1
    80004cea:	7a1e                	ld	s4,480(sp)
}
    80004cec:	20813083          	ld	ra,520(sp)
    80004cf0:	20013403          	ld	s0,512(sp)
    80004cf4:	74fe                	ld	s1,504(sp)
    80004cf6:	795e                	ld	s2,496(sp)
    80004cf8:	21010113          	addi	sp,sp,528
    80004cfc:	8082                	ret
    end_op();
    80004cfe:	fffff097          	auipc	ra,0xfffff
    80004d02:	43e080e7          	jalr	1086(ra) # 8000413c <end_op>
    return -1;
    80004d06:	557d                	li	a0,-1
    80004d08:	b7d5                	j	80004cec <exec+0x8a>
    80004d0a:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004d0c:	8526                	mv	a0,s1
    80004d0e:	ffffd097          	auipc	ra,0xffffd
    80004d12:	e00080e7          	jalr	-512(ra) # 80001b0e <proc_pagetable>
    80004d16:	8b2a                	mv	s6,a0
    80004d18:	30050f63          	beqz	a0,80005036 <exec+0x3d4>
    80004d1c:	f7ce                	sd	s3,488(sp)
    80004d1e:	efd6                	sd	s5,472(sp)
    80004d20:	e7de                	sd	s7,456(sp)
    80004d22:	e3e2                	sd	s8,448(sp)
    80004d24:	ff66                	sd	s9,440(sp)
    80004d26:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d28:	e7042d03          	lw	s10,-400(s0)
    80004d2c:	e8845783          	lhu	a5,-376(s0)
    80004d30:	14078d63          	beqz	a5,80004e8a <exec+0x228>
    80004d34:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d36:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d38:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004d3a:	6c85                	lui	s9,0x1
    80004d3c:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004d40:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004d44:	6a85                	lui	s5,0x1
    80004d46:	a0b5                	j	80004db2 <exec+0x150>
      panic("loadseg: address should exist");
    80004d48:	00004517          	auipc	a0,0x4
    80004d4c:	87050513          	addi	a0,a0,-1936 # 800085b8 <etext+0x5b8>
    80004d50:	ffffc097          	auipc	ra,0xffffc
    80004d54:	810080e7          	jalr	-2032(ra) # 80000560 <panic>
    if(sz - i < PGSIZE)
    80004d58:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d5a:	8726                	mv	a4,s1
    80004d5c:	012c06bb          	addw	a3,s8,s2
    80004d60:	4581                	li	a1,0
    80004d62:	8552                	mv	a0,s4
    80004d64:	fffff097          	auipc	ra,0xfffff
    80004d68:	c48080e7          	jalr	-952(ra) # 800039ac <readi>
    80004d6c:	2501                	sext.w	a0,a0
    80004d6e:	28a49863          	bne	s1,a0,80004ffe <exec+0x39c>
  for(i = 0; i < sz; i += PGSIZE){
    80004d72:	012a893b          	addw	s2,s5,s2
    80004d76:	03397563          	bgeu	s2,s3,80004da0 <exec+0x13e>
    pa = walkaddr(pagetable, va + i);
    80004d7a:	02091593          	slli	a1,s2,0x20
    80004d7e:	9181                	srli	a1,a1,0x20
    80004d80:	95de                	add	a1,a1,s7
    80004d82:	855a                	mv	a0,s6
    80004d84:	ffffc097          	auipc	ra,0xffffc
    80004d88:	332080e7          	jalr	818(ra) # 800010b6 <walkaddr>
    80004d8c:	862a                	mv	a2,a0
    if(pa == 0)
    80004d8e:	dd4d                	beqz	a0,80004d48 <exec+0xe6>
    if(sz - i < PGSIZE)
    80004d90:	412984bb          	subw	s1,s3,s2
    80004d94:	0004879b          	sext.w	a5,s1
    80004d98:	fcfcf0e3          	bgeu	s9,a5,80004d58 <exec+0xf6>
    80004d9c:	84d6                	mv	s1,s5
    80004d9e:	bf6d                	j	80004d58 <exec+0xf6>
    sz = sz1;
    80004da0:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004da4:	2d85                	addiw	s11,s11,1
    80004da6:	038d0d1b          	addiw	s10,s10,56
    80004daa:	e8845783          	lhu	a5,-376(s0)
    80004dae:	08fdd663          	bge	s11,a5,80004e3a <exec+0x1d8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004db2:	2d01                	sext.w	s10,s10
    80004db4:	03800713          	li	a4,56
    80004db8:	86ea                	mv	a3,s10
    80004dba:	e1840613          	addi	a2,s0,-488
    80004dbe:	4581                	li	a1,0
    80004dc0:	8552                	mv	a0,s4
    80004dc2:	fffff097          	auipc	ra,0xfffff
    80004dc6:	bea080e7          	jalr	-1046(ra) # 800039ac <readi>
    80004dca:	03800793          	li	a5,56
    80004dce:	20f51063          	bne	a0,a5,80004fce <exec+0x36c>
    if(ph.type != ELF_PROG_LOAD)
    80004dd2:	e1842783          	lw	a5,-488(s0)
    80004dd6:	4705                	li	a4,1
    80004dd8:	fce796e3          	bne	a5,a4,80004da4 <exec+0x142>
    if(ph.memsz < ph.filesz)
    80004ddc:	e4043483          	ld	s1,-448(s0)
    80004de0:	e3843783          	ld	a5,-456(s0)
    80004de4:	1ef4e963          	bltu	s1,a5,80004fd6 <exec+0x374>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004de8:	e2843783          	ld	a5,-472(s0)
    80004dec:	94be                	add	s1,s1,a5
    80004dee:	1ef4e863          	bltu	s1,a5,80004fde <exec+0x37c>
    if(ph.vaddr % PGSIZE != 0)
    80004df2:	df043703          	ld	a4,-528(s0)
    80004df6:	8ff9                	and	a5,a5,a4
    80004df8:	1e079763          	bnez	a5,80004fe6 <exec+0x384>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004dfc:	e1c42503          	lw	a0,-484(s0)
    80004e00:	00000097          	auipc	ra,0x0
    80004e04:	e48080e7          	jalr	-440(ra) # 80004c48 <flags2perm>
    80004e08:	86aa                	mv	a3,a0
    80004e0a:	8626                	mv	a2,s1
    80004e0c:	85ca                	mv	a1,s2
    80004e0e:	855a                	mv	a0,s6
    80004e10:	ffffc097          	auipc	ra,0xffffc
    80004e14:	66a080e7          	jalr	1642(ra) # 8000147a <uvmalloc>
    80004e18:	e0a43423          	sd	a0,-504(s0)
    80004e1c:	1c050963          	beqz	a0,80004fee <exec+0x38c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004e20:	e2843b83          	ld	s7,-472(s0)
    80004e24:	e2042c03          	lw	s8,-480(s0)
    80004e28:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004e2c:	00098463          	beqz	s3,80004e34 <exec+0x1d2>
    80004e30:	4901                	li	s2,0
    80004e32:	b7a1                	j	80004d7a <exec+0x118>
    sz = sz1;
    80004e34:	e0843903          	ld	s2,-504(s0)
    80004e38:	b7b5                	j	80004da4 <exec+0x142>
    80004e3a:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004e3c:	8552                	mv	a0,s4
    80004e3e:	fffff097          	auipc	ra,0xfffff
    80004e42:	b1c080e7          	jalr	-1252(ra) # 8000395a <iunlockput>
  end_op();
    80004e46:	fffff097          	auipc	ra,0xfffff
    80004e4a:	2f6080e7          	jalr	758(ra) # 8000413c <end_op>
  p = myproc();
    80004e4e:	ffffd097          	auipc	ra,0xffffd
    80004e52:	bfc080e7          	jalr	-1028(ra) # 80001a4a <myproc>
    80004e56:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004e58:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004e5c:	6985                	lui	s3,0x1
    80004e5e:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004e60:	99ca                	add	s3,s3,s2
    80004e62:	77fd                	lui	a5,0xfffff
    80004e64:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004e68:	4691                	li	a3,4
    80004e6a:	6609                	lui	a2,0x2
    80004e6c:	964e                	add	a2,a2,s3
    80004e6e:	85ce                	mv	a1,s3
    80004e70:	855a                	mv	a0,s6
    80004e72:	ffffc097          	auipc	ra,0xffffc
    80004e76:	608080e7          	jalr	1544(ra) # 8000147a <uvmalloc>
    80004e7a:	892a                	mv	s2,a0
    80004e7c:	e0a43423          	sd	a0,-504(s0)
    80004e80:	e519                	bnez	a0,80004e8e <exec+0x22c>
  if(pagetable)
    80004e82:	e1343423          	sd	s3,-504(s0)
    80004e86:	4a01                	li	s4,0
    80004e88:	aaa5                	j	80005000 <exec+0x39e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e8a:	4901                	li	s2,0
    80004e8c:	bf45                	j	80004e3c <exec+0x1da>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004e8e:	75f9                	lui	a1,0xffffe
    80004e90:	95aa                	add	a1,a1,a0
    80004e92:	855a                	mv	a0,s6
    80004e94:	ffffd097          	auipc	ra,0xffffd
    80004e98:	81c080e7          	jalr	-2020(ra) # 800016b0 <uvmclear>
  stackbase = sp - PGSIZE;
    80004e9c:	7bfd                	lui	s7,0xfffff
    80004e9e:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004ea0:	e0043783          	ld	a5,-512(s0)
    80004ea4:	6388                	ld	a0,0(a5)
    80004ea6:	c52d                	beqz	a0,80004f10 <exec+0x2ae>
    80004ea8:	e9040993          	addi	s3,s0,-368
    80004eac:	f9040c13          	addi	s8,s0,-112
    80004eb0:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004eb2:	ffffc097          	auipc	ra,0xffffc
    80004eb6:	ff6080e7          	jalr	-10(ra) # 80000ea8 <strlen>
    80004eba:	0015079b          	addiw	a5,a0,1
    80004ebe:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004ec2:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004ec6:	13796863          	bltu	s2,s7,80004ff6 <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004eca:	e0043d03          	ld	s10,-512(s0)
    80004ece:	000d3a03          	ld	s4,0(s10)
    80004ed2:	8552                	mv	a0,s4
    80004ed4:	ffffc097          	auipc	ra,0xffffc
    80004ed8:	fd4080e7          	jalr	-44(ra) # 80000ea8 <strlen>
    80004edc:	0015069b          	addiw	a3,a0,1
    80004ee0:	8652                	mv	a2,s4
    80004ee2:	85ca                	mv	a1,s2
    80004ee4:	855a                	mv	a0,s6
    80004ee6:	ffffc097          	auipc	ra,0xffffc
    80004eea:	7fc080e7          	jalr	2044(ra) # 800016e2 <copyout>
    80004eee:	10054663          	bltz	a0,80004ffa <exec+0x398>
    ustack[argc] = sp;
    80004ef2:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004ef6:	0485                	addi	s1,s1,1
    80004ef8:	008d0793          	addi	a5,s10,8
    80004efc:	e0f43023          	sd	a5,-512(s0)
    80004f00:	008d3503          	ld	a0,8(s10)
    80004f04:	c909                	beqz	a0,80004f16 <exec+0x2b4>
    if(argc >= MAXARG)
    80004f06:	09a1                	addi	s3,s3,8
    80004f08:	fb8995e3          	bne	s3,s8,80004eb2 <exec+0x250>
  ip = 0;
    80004f0c:	4a01                	li	s4,0
    80004f0e:	a8cd                	j	80005000 <exec+0x39e>
  sp = sz;
    80004f10:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004f14:	4481                	li	s1,0
  ustack[argc] = 0;
    80004f16:	00349793          	slli	a5,s1,0x3
    80004f1a:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffda980>
    80004f1e:	97a2                	add	a5,a5,s0
    80004f20:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004f24:	00148693          	addi	a3,s1,1
    80004f28:	068e                	slli	a3,a3,0x3
    80004f2a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004f2e:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004f32:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004f36:	f57966e3          	bltu	s2,s7,80004e82 <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f3a:	e9040613          	addi	a2,s0,-368
    80004f3e:	85ca                	mv	a1,s2
    80004f40:	855a                	mv	a0,s6
    80004f42:	ffffc097          	auipc	ra,0xffffc
    80004f46:	7a0080e7          	jalr	1952(ra) # 800016e2 <copyout>
    80004f4a:	0e054863          	bltz	a0,8000503a <exec+0x3d8>
  p->trapframe->a1 = sp;
    80004f4e:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004f52:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004f56:	df843783          	ld	a5,-520(s0)
    80004f5a:	0007c703          	lbu	a4,0(a5)
    80004f5e:	cf11                	beqz	a4,80004f7a <exec+0x318>
    80004f60:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004f62:	02f00693          	li	a3,47
    80004f66:	a039                	j	80004f74 <exec+0x312>
      last = s+1;
    80004f68:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004f6c:	0785                	addi	a5,a5,1
    80004f6e:	fff7c703          	lbu	a4,-1(a5)
    80004f72:	c701                	beqz	a4,80004f7a <exec+0x318>
    if(*s == '/')
    80004f74:	fed71ce3          	bne	a4,a3,80004f6c <exec+0x30a>
    80004f78:	bfc5                	j	80004f68 <exec+0x306>
  safestrcpy(p->name, last, sizeof(p->name));
    80004f7a:	4641                	li	a2,16
    80004f7c:	df843583          	ld	a1,-520(s0)
    80004f80:	158a8513          	addi	a0,s5,344
    80004f84:	ffffc097          	auipc	ra,0xffffc
    80004f88:	ef2080e7          	jalr	-270(ra) # 80000e76 <safestrcpy>
  oldpagetable = p->pagetable;
    80004f8c:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004f90:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004f94:	e0843783          	ld	a5,-504(s0)
    80004f98:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004f9c:	058ab783          	ld	a5,88(s5)
    80004fa0:	e6843703          	ld	a4,-408(s0)
    80004fa4:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004fa6:	058ab783          	ld	a5,88(s5)
    80004faa:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004fae:	85e6                	mv	a1,s9
    80004fb0:	ffffd097          	auipc	ra,0xffffd
    80004fb4:	bfa080e7          	jalr	-1030(ra) # 80001baa <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004fb8:	0004851b          	sext.w	a0,s1
    80004fbc:	79be                	ld	s3,488(sp)
    80004fbe:	7a1e                	ld	s4,480(sp)
    80004fc0:	6afe                	ld	s5,472(sp)
    80004fc2:	6b5e                	ld	s6,464(sp)
    80004fc4:	6bbe                	ld	s7,456(sp)
    80004fc6:	6c1e                	ld	s8,448(sp)
    80004fc8:	7cfa                	ld	s9,440(sp)
    80004fca:	7d5a                	ld	s10,432(sp)
    80004fcc:	b305                	j	80004cec <exec+0x8a>
    80004fce:	e1243423          	sd	s2,-504(s0)
    80004fd2:	7dba                	ld	s11,424(sp)
    80004fd4:	a035                	j	80005000 <exec+0x39e>
    80004fd6:	e1243423          	sd	s2,-504(s0)
    80004fda:	7dba                	ld	s11,424(sp)
    80004fdc:	a015                	j	80005000 <exec+0x39e>
    80004fde:	e1243423          	sd	s2,-504(s0)
    80004fe2:	7dba                	ld	s11,424(sp)
    80004fe4:	a831                	j	80005000 <exec+0x39e>
    80004fe6:	e1243423          	sd	s2,-504(s0)
    80004fea:	7dba                	ld	s11,424(sp)
    80004fec:	a811                	j	80005000 <exec+0x39e>
    80004fee:	e1243423          	sd	s2,-504(s0)
    80004ff2:	7dba                	ld	s11,424(sp)
    80004ff4:	a031                	j	80005000 <exec+0x39e>
  ip = 0;
    80004ff6:	4a01                	li	s4,0
    80004ff8:	a021                	j	80005000 <exec+0x39e>
    80004ffa:	4a01                	li	s4,0
  if(pagetable)
    80004ffc:	a011                	j	80005000 <exec+0x39e>
    80004ffe:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80005000:	e0843583          	ld	a1,-504(s0)
    80005004:	855a                	mv	a0,s6
    80005006:	ffffd097          	auipc	ra,0xffffd
    8000500a:	ba4080e7          	jalr	-1116(ra) # 80001baa <proc_freepagetable>
  return -1;
    8000500e:	557d                	li	a0,-1
  if(ip){
    80005010:	000a1b63          	bnez	s4,80005026 <exec+0x3c4>
    80005014:	79be                	ld	s3,488(sp)
    80005016:	7a1e                	ld	s4,480(sp)
    80005018:	6afe                	ld	s5,472(sp)
    8000501a:	6b5e                	ld	s6,464(sp)
    8000501c:	6bbe                	ld	s7,456(sp)
    8000501e:	6c1e                	ld	s8,448(sp)
    80005020:	7cfa                	ld	s9,440(sp)
    80005022:	7d5a                	ld	s10,432(sp)
    80005024:	b1e1                	j	80004cec <exec+0x8a>
    80005026:	79be                	ld	s3,488(sp)
    80005028:	6afe                	ld	s5,472(sp)
    8000502a:	6b5e                	ld	s6,464(sp)
    8000502c:	6bbe                	ld	s7,456(sp)
    8000502e:	6c1e                	ld	s8,448(sp)
    80005030:	7cfa                	ld	s9,440(sp)
    80005032:	7d5a                	ld	s10,432(sp)
    80005034:	b14d                	j	80004cd6 <exec+0x74>
    80005036:	6b5e                	ld	s6,464(sp)
    80005038:	b979                	j	80004cd6 <exec+0x74>
  sz = sz1;
    8000503a:	e0843983          	ld	s3,-504(s0)
    8000503e:	b591                	j	80004e82 <exec+0x220>

0000000080005040 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005040:	7179                	addi	sp,sp,-48
    80005042:	f406                	sd	ra,40(sp)
    80005044:	f022                	sd	s0,32(sp)
    80005046:	ec26                	sd	s1,24(sp)
    80005048:	e84a                	sd	s2,16(sp)
    8000504a:	1800                	addi	s0,sp,48
    8000504c:	892e                	mv	s2,a1
    8000504e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005050:	fdc40593          	addi	a1,s0,-36
    80005054:	ffffe097          	auipc	ra,0xffffe
    80005058:	b16080e7          	jalr	-1258(ra) # 80002b6a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000505c:	fdc42703          	lw	a4,-36(s0)
    80005060:	47bd                	li	a5,15
    80005062:	02e7eb63          	bltu	a5,a4,80005098 <argfd+0x58>
    80005066:	ffffd097          	auipc	ra,0xffffd
    8000506a:	9e4080e7          	jalr	-1564(ra) # 80001a4a <myproc>
    8000506e:	fdc42703          	lw	a4,-36(s0)
    80005072:	01a70793          	addi	a5,a4,26
    80005076:	078e                	slli	a5,a5,0x3
    80005078:	953e                	add	a0,a0,a5
    8000507a:	611c                	ld	a5,0(a0)
    8000507c:	c385                	beqz	a5,8000509c <argfd+0x5c>
    return -1;
  if(pfd)
    8000507e:	00090463          	beqz	s2,80005086 <argfd+0x46>
    *pfd = fd;
    80005082:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005086:	4501                	li	a0,0
  if(pf)
    80005088:	c091                	beqz	s1,8000508c <argfd+0x4c>
    *pf = f;
    8000508a:	e09c                	sd	a5,0(s1)
}
    8000508c:	70a2                	ld	ra,40(sp)
    8000508e:	7402                	ld	s0,32(sp)
    80005090:	64e2                	ld	s1,24(sp)
    80005092:	6942                	ld	s2,16(sp)
    80005094:	6145                	addi	sp,sp,48
    80005096:	8082                	ret
    return -1;
    80005098:	557d                	li	a0,-1
    8000509a:	bfcd                	j	8000508c <argfd+0x4c>
    8000509c:	557d                	li	a0,-1
    8000509e:	b7fd                	j	8000508c <argfd+0x4c>

00000000800050a0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800050a0:	1101                	addi	sp,sp,-32
    800050a2:	ec06                	sd	ra,24(sp)
    800050a4:	e822                	sd	s0,16(sp)
    800050a6:	e426                	sd	s1,8(sp)
    800050a8:	1000                	addi	s0,sp,32
    800050aa:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800050ac:	ffffd097          	auipc	ra,0xffffd
    800050b0:	99e080e7          	jalr	-1634(ra) # 80001a4a <myproc>
    800050b4:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800050b6:	0d050793          	addi	a5,a0,208
    800050ba:	4501                	li	a0,0
    800050bc:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800050be:	6398                	ld	a4,0(a5)
    800050c0:	cb19                	beqz	a4,800050d6 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800050c2:	2505                	addiw	a0,a0,1
    800050c4:	07a1                	addi	a5,a5,8
    800050c6:	fed51ce3          	bne	a0,a3,800050be <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800050ca:	557d                	li	a0,-1
}
    800050cc:	60e2                	ld	ra,24(sp)
    800050ce:	6442                	ld	s0,16(sp)
    800050d0:	64a2                	ld	s1,8(sp)
    800050d2:	6105                	addi	sp,sp,32
    800050d4:	8082                	ret
      p->ofile[fd] = f;
    800050d6:	01a50793          	addi	a5,a0,26
    800050da:	078e                	slli	a5,a5,0x3
    800050dc:	963e                	add	a2,a2,a5
    800050de:	e204                	sd	s1,0(a2)
      return fd;
    800050e0:	b7f5                	j	800050cc <fdalloc+0x2c>

00000000800050e2 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800050e2:	715d                	addi	sp,sp,-80
    800050e4:	e486                	sd	ra,72(sp)
    800050e6:	e0a2                	sd	s0,64(sp)
    800050e8:	fc26                	sd	s1,56(sp)
    800050ea:	f84a                	sd	s2,48(sp)
    800050ec:	f44e                	sd	s3,40(sp)
    800050ee:	ec56                	sd	s5,24(sp)
    800050f0:	e85a                	sd	s6,16(sp)
    800050f2:	0880                	addi	s0,sp,80
    800050f4:	8b2e                	mv	s6,a1
    800050f6:	89b2                	mv	s3,a2
    800050f8:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800050fa:	fb040593          	addi	a1,s0,-80
    800050fe:	fffff097          	auipc	ra,0xfffff
    80005102:	de2080e7          	jalr	-542(ra) # 80003ee0 <nameiparent>
    80005106:	84aa                	mv	s1,a0
    80005108:	14050e63          	beqz	a0,80005264 <create+0x182>
    return 0;

  ilock(dp);
    8000510c:	ffffe097          	auipc	ra,0xffffe
    80005110:	5e8080e7          	jalr	1512(ra) # 800036f4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005114:	4601                	li	a2,0
    80005116:	fb040593          	addi	a1,s0,-80
    8000511a:	8526                	mv	a0,s1
    8000511c:	fffff097          	auipc	ra,0xfffff
    80005120:	ae4080e7          	jalr	-1308(ra) # 80003c00 <dirlookup>
    80005124:	8aaa                	mv	s5,a0
    80005126:	c539                	beqz	a0,80005174 <create+0x92>
    iunlockput(dp);
    80005128:	8526                	mv	a0,s1
    8000512a:	fffff097          	auipc	ra,0xfffff
    8000512e:	830080e7          	jalr	-2000(ra) # 8000395a <iunlockput>
    ilock(ip);
    80005132:	8556                	mv	a0,s5
    80005134:	ffffe097          	auipc	ra,0xffffe
    80005138:	5c0080e7          	jalr	1472(ra) # 800036f4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000513c:	4789                	li	a5,2
    8000513e:	02fb1463          	bne	s6,a5,80005166 <create+0x84>
    80005142:	044ad783          	lhu	a5,68(s5)
    80005146:	37f9                	addiw	a5,a5,-2
    80005148:	17c2                	slli	a5,a5,0x30
    8000514a:	93c1                	srli	a5,a5,0x30
    8000514c:	4705                	li	a4,1
    8000514e:	00f76c63          	bltu	a4,a5,80005166 <create+0x84>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005152:	8556                	mv	a0,s5
    80005154:	60a6                	ld	ra,72(sp)
    80005156:	6406                	ld	s0,64(sp)
    80005158:	74e2                	ld	s1,56(sp)
    8000515a:	7942                	ld	s2,48(sp)
    8000515c:	79a2                	ld	s3,40(sp)
    8000515e:	6ae2                	ld	s5,24(sp)
    80005160:	6b42                	ld	s6,16(sp)
    80005162:	6161                	addi	sp,sp,80
    80005164:	8082                	ret
    iunlockput(ip);
    80005166:	8556                	mv	a0,s5
    80005168:	ffffe097          	auipc	ra,0xffffe
    8000516c:	7f2080e7          	jalr	2034(ra) # 8000395a <iunlockput>
    return 0;
    80005170:	4a81                	li	s5,0
    80005172:	b7c5                	j	80005152 <create+0x70>
    80005174:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80005176:	85da                	mv	a1,s6
    80005178:	4088                	lw	a0,0(s1)
    8000517a:	ffffe097          	auipc	ra,0xffffe
    8000517e:	3d6080e7          	jalr	982(ra) # 80003550 <ialloc>
    80005182:	8a2a                	mv	s4,a0
    80005184:	c531                	beqz	a0,800051d0 <create+0xee>
  ilock(ip);
    80005186:	ffffe097          	auipc	ra,0xffffe
    8000518a:	56e080e7          	jalr	1390(ra) # 800036f4 <ilock>
  ip->major = major;
    8000518e:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005192:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005196:	4905                	li	s2,1
    80005198:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000519c:	8552                	mv	a0,s4
    8000519e:	ffffe097          	auipc	ra,0xffffe
    800051a2:	48a080e7          	jalr	1162(ra) # 80003628 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800051a6:	032b0d63          	beq	s6,s2,800051e0 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800051aa:	004a2603          	lw	a2,4(s4)
    800051ae:	fb040593          	addi	a1,s0,-80
    800051b2:	8526                	mv	a0,s1
    800051b4:	fffff097          	auipc	ra,0xfffff
    800051b8:	c5c080e7          	jalr	-932(ra) # 80003e10 <dirlink>
    800051bc:	08054163          	bltz	a0,8000523e <create+0x15c>
  iunlockput(dp);
    800051c0:	8526                	mv	a0,s1
    800051c2:	ffffe097          	auipc	ra,0xffffe
    800051c6:	798080e7          	jalr	1944(ra) # 8000395a <iunlockput>
  return ip;
    800051ca:	8ad2                	mv	s5,s4
    800051cc:	7a02                	ld	s4,32(sp)
    800051ce:	b751                	j	80005152 <create+0x70>
    iunlockput(dp);
    800051d0:	8526                	mv	a0,s1
    800051d2:	ffffe097          	auipc	ra,0xffffe
    800051d6:	788080e7          	jalr	1928(ra) # 8000395a <iunlockput>
    return 0;
    800051da:	8ad2                	mv	s5,s4
    800051dc:	7a02                	ld	s4,32(sp)
    800051de:	bf95                	j	80005152 <create+0x70>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800051e0:	004a2603          	lw	a2,4(s4)
    800051e4:	00003597          	auipc	a1,0x3
    800051e8:	3f458593          	addi	a1,a1,1012 # 800085d8 <etext+0x5d8>
    800051ec:	8552                	mv	a0,s4
    800051ee:	fffff097          	auipc	ra,0xfffff
    800051f2:	c22080e7          	jalr	-990(ra) # 80003e10 <dirlink>
    800051f6:	04054463          	bltz	a0,8000523e <create+0x15c>
    800051fa:	40d0                	lw	a2,4(s1)
    800051fc:	00003597          	auipc	a1,0x3
    80005200:	3e458593          	addi	a1,a1,996 # 800085e0 <etext+0x5e0>
    80005204:	8552                	mv	a0,s4
    80005206:	fffff097          	auipc	ra,0xfffff
    8000520a:	c0a080e7          	jalr	-1014(ra) # 80003e10 <dirlink>
    8000520e:	02054863          	bltz	a0,8000523e <create+0x15c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005212:	004a2603          	lw	a2,4(s4)
    80005216:	fb040593          	addi	a1,s0,-80
    8000521a:	8526                	mv	a0,s1
    8000521c:	fffff097          	auipc	ra,0xfffff
    80005220:	bf4080e7          	jalr	-1036(ra) # 80003e10 <dirlink>
    80005224:	00054d63          	bltz	a0,8000523e <create+0x15c>
    dp->nlink++;  // for ".."
    80005228:	04a4d783          	lhu	a5,74(s1)
    8000522c:	2785                	addiw	a5,a5,1
    8000522e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005232:	8526                	mv	a0,s1
    80005234:	ffffe097          	auipc	ra,0xffffe
    80005238:	3f4080e7          	jalr	1012(ra) # 80003628 <iupdate>
    8000523c:	b751                	j	800051c0 <create+0xde>
  ip->nlink = 0;
    8000523e:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005242:	8552                	mv	a0,s4
    80005244:	ffffe097          	auipc	ra,0xffffe
    80005248:	3e4080e7          	jalr	996(ra) # 80003628 <iupdate>
  iunlockput(ip);
    8000524c:	8552                	mv	a0,s4
    8000524e:	ffffe097          	auipc	ra,0xffffe
    80005252:	70c080e7          	jalr	1804(ra) # 8000395a <iunlockput>
  iunlockput(dp);
    80005256:	8526                	mv	a0,s1
    80005258:	ffffe097          	auipc	ra,0xffffe
    8000525c:	702080e7          	jalr	1794(ra) # 8000395a <iunlockput>
  return 0;
    80005260:	7a02                	ld	s4,32(sp)
    80005262:	bdc5                	j	80005152 <create+0x70>
    return 0;
    80005264:	8aaa                	mv	s5,a0
    80005266:	b5f5                	j	80005152 <create+0x70>

0000000080005268 <sys_dup>:
{
    80005268:	7179                	addi	sp,sp,-48
    8000526a:	f406                	sd	ra,40(sp)
    8000526c:	f022                	sd	s0,32(sp)
    8000526e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005270:	fd840613          	addi	a2,s0,-40
    80005274:	4581                	li	a1,0
    80005276:	4501                	li	a0,0
    80005278:	00000097          	auipc	ra,0x0
    8000527c:	dc8080e7          	jalr	-568(ra) # 80005040 <argfd>
    return -1;
    80005280:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005282:	02054763          	bltz	a0,800052b0 <sys_dup+0x48>
    80005286:	ec26                	sd	s1,24(sp)
    80005288:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    8000528a:	fd843903          	ld	s2,-40(s0)
    8000528e:	854a                	mv	a0,s2
    80005290:	00000097          	auipc	ra,0x0
    80005294:	e10080e7          	jalr	-496(ra) # 800050a0 <fdalloc>
    80005298:	84aa                	mv	s1,a0
    return -1;
    8000529a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000529c:	00054f63          	bltz	a0,800052ba <sys_dup+0x52>
  filedup(f);
    800052a0:	854a                	mv	a0,s2
    800052a2:	fffff097          	auipc	ra,0xfffff
    800052a6:	298080e7          	jalr	664(ra) # 8000453a <filedup>
  return fd;
    800052aa:	87a6                	mv	a5,s1
    800052ac:	64e2                	ld	s1,24(sp)
    800052ae:	6942                	ld	s2,16(sp)
}
    800052b0:	853e                	mv	a0,a5
    800052b2:	70a2                	ld	ra,40(sp)
    800052b4:	7402                	ld	s0,32(sp)
    800052b6:	6145                	addi	sp,sp,48
    800052b8:	8082                	ret
    800052ba:	64e2                	ld	s1,24(sp)
    800052bc:	6942                	ld	s2,16(sp)
    800052be:	bfcd                	j	800052b0 <sys_dup+0x48>

00000000800052c0 <sys_read>:
{
    800052c0:	7179                	addi	sp,sp,-48
    800052c2:	f406                	sd	ra,40(sp)
    800052c4:	f022                	sd	s0,32(sp)
    800052c6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800052c8:	fd840593          	addi	a1,s0,-40
    800052cc:	4505                	li	a0,1
    800052ce:	ffffe097          	auipc	ra,0xffffe
    800052d2:	8bc080e7          	jalr	-1860(ra) # 80002b8a <argaddr>
  argint(2, &n);
    800052d6:	fe440593          	addi	a1,s0,-28
    800052da:	4509                	li	a0,2
    800052dc:	ffffe097          	auipc	ra,0xffffe
    800052e0:	88e080e7          	jalr	-1906(ra) # 80002b6a <argint>
  if(argfd(0, 0, &f) < 0)
    800052e4:	fe840613          	addi	a2,s0,-24
    800052e8:	4581                	li	a1,0
    800052ea:	4501                	li	a0,0
    800052ec:	00000097          	auipc	ra,0x0
    800052f0:	d54080e7          	jalr	-684(ra) # 80005040 <argfd>
    800052f4:	87aa                	mv	a5,a0
    return -1;
    800052f6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800052f8:	0007cc63          	bltz	a5,80005310 <sys_read+0x50>
  return fileread(f, p, n);
    800052fc:	fe442603          	lw	a2,-28(s0)
    80005300:	fd843583          	ld	a1,-40(s0)
    80005304:	fe843503          	ld	a0,-24(s0)
    80005308:	fffff097          	auipc	ra,0xfffff
    8000530c:	3d8080e7          	jalr	984(ra) # 800046e0 <fileread>
}
    80005310:	70a2                	ld	ra,40(sp)
    80005312:	7402                	ld	s0,32(sp)
    80005314:	6145                	addi	sp,sp,48
    80005316:	8082                	ret

0000000080005318 <sys_write>:
{
    80005318:	7179                	addi	sp,sp,-48
    8000531a:	f406                	sd	ra,40(sp)
    8000531c:	f022                	sd	s0,32(sp)
    8000531e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005320:	fd840593          	addi	a1,s0,-40
    80005324:	4505                	li	a0,1
    80005326:	ffffe097          	auipc	ra,0xffffe
    8000532a:	864080e7          	jalr	-1948(ra) # 80002b8a <argaddr>
  argint(2, &n);
    8000532e:	fe440593          	addi	a1,s0,-28
    80005332:	4509                	li	a0,2
    80005334:	ffffe097          	auipc	ra,0xffffe
    80005338:	836080e7          	jalr	-1994(ra) # 80002b6a <argint>
  if(argfd(0, 0, &f) < 0)
    8000533c:	fe840613          	addi	a2,s0,-24
    80005340:	4581                	li	a1,0
    80005342:	4501                	li	a0,0
    80005344:	00000097          	auipc	ra,0x0
    80005348:	cfc080e7          	jalr	-772(ra) # 80005040 <argfd>
    8000534c:	87aa                	mv	a5,a0
    return -1;
    8000534e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005350:	0007cc63          	bltz	a5,80005368 <sys_write+0x50>
  return filewrite(f, p, n);
    80005354:	fe442603          	lw	a2,-28(s0)
    80005358:	fd843583          	ld	a1,-40(s0)
    8000535c:	fe843503          	ld	a0,-24(s0)
    80005360:	fffff097          	auipc	ra,0xfffff
    80005364:	452080e7          	jalr	1106(ra) # 800047b2 <filewrite>
}
    80005368:	70a2                	ld	ra,40(sp)
    8000536a:	7402                	ld	s0,32(sp)
    8000536c:	6145                	addi	sp,sp,48
    8000536e:	8082                	ret

0000000080005370 <sys_close>:
{
    80005370:	1101                	addi	sp,sp,-32
    80005372:	ec06                	sd	ra,24(sp)
    80005374:	e822                	sd	s0,16(sp)
    80005376:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005378:	fe040613          	addi	a2,s0,-32
    8000537c:	fec40593          	addi	a1,s0,-20
    80005380:	4501                	li	a0,0
    80005382:	00000097          	auipc	ra,0x0
    80005386:	cbe080e7          	jalr	-834(ra) # 80005040 <argfd>
    return -1;
    8000538a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000538c:	02054463          	bltz	a0,800053b4 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005390:	ffffc097          	auipc	ra,0xffffc
    80005394:	6ba080e7          	jalr	1722(ra) # 80001a4a <myproc>
    80005398:	fec42783          	lw	a5,-20(s0)
    8000539c:	07e9                	addi	a5,a5,26
    8000539e:	078e                	slli	a5,a5,0x3
    800053a0:	953e                	add	a0,a0,a5
    800053a2:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800053a6:	fe043503          	ld	a0,-32(s0)
    800053aa:	fffff097          	auipc	ra,0xfffff
    800053ae:	1e2080e7          	jalr	482(ra) # 8000458c <fileclose>
  return 0;
    800053b2:	4781                	li	a5,0
}
    800053b4:	853e                	mv	a0,a5
    800053b6:	60e2                	ld	ra,24(sp)
    800053b8:	6442                	ld	s0,16(sp)
    800053ba:	6105                	addi	sp,sp,32
    800053bc:	8082                	ret

00000000800053be <sys_fstat>:
{
    800053be:	1101                	addi	sp,sp,-32
    800053c0:	ec06                	sd	ra,24(sp)
    800053c2:	e822                	sd	s0,16(sp)
    800053c4:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800053c6:	fe040593          	addi	a1,s0,-32
    800053ca:	4505                	li	a0,1
    800053cc:	ffffd097          	auipc	ra,0xffffd
    800053d0:	7be080e7          	jalr	1982(ra) # 80002b8a <argaddr>
  if(argfd(0, 0, &f) < 0)
    800053d4:	fe840613          	addi	a2,s0,-24
    800053d8:	4581                	li	a1,0
    800053da:	4501                	li	a0,0
    800053dc:	00000097          	auipc	ra,0x0
    800053e0:	c64080e7          	jalr	-924(ra) # 80005040 <argfd>
    800053e4:	87aa                	mv	a5,a0
    return -1;
    800053e6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800053e8:	0007ca63          	bltz	a5,800053fc <sys_fstat+0x3e>
  return filestat(f, st);
    800053ec:	fe043583          	ld	a1,-32(s0)
    800053f0:	fe843503          	ld	a0,-24(s0)
    800053f4:	fffff097          	auipc	ra,0xfffff
    800053f8:	27a080e7          	jalr	634(ra) # 8000466e <filestat>
}
    800053fc:	60e2                	ld	ra,24(sp)
    800053fe:	6442                	ld	s0,16(sp)
    80005400:	6105                	addi	sp,sp,32
    80005402:	8082                	ret

0000000080005404 <sys_link>:
{
    80005404:	7169                	addi	sp,sp,-304
    80005406:	f606                	sd	ra,296(sp)
    80005408:	f222                	sd	s0,288(sp)
    8000540a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000540c:	08000613          	li	a2,128
    80005410:	ed040593          	addi	a1,s0,-304
    80005414:	4501                	li	a0,0
    80005416:	ffffd097          	auipc	ra,0xffffd
    8000541a:	794080e7          	jalr	1940(ra) # 80002baa <argstr>
    return -1;
    8000541e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005420:	12054663          	bltz	a0,8000554c <sys_link+0x148>
    80005424:	08000613          	li	a2,128
    80005428:	f5040593          	addi	a1,s0,-176
    8000542c:	4505                	li	a0,1
    8000542e:	ffffd097          	auipc	ra,0xffffd
    80005432:	77c080e7          	jalr	1916(ra) # 80002baa <argstr>
    return -1;
    80005436:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005438:	10054a63          	bltz	a0,8000554c <sys_link+0x148>
    8000543c:	ee26                	sd	s1,280(sp)
  begin_op();
    8000543e:	fffff097          	auipc	ra,0xfffff
    80005442:	c84080e7          	jalr	-892(ra) # 800040c2 <begin_op>
  if((ip = namei(old)) == 0){
    80005446:	ed040513          	addi	a0,s0,-304
    8000544a:	fffff097          	auipc	ra,0xfffff
    8000544e:	a78080e7          	jalr	-1416(ra) # 80003ec2 <namei>
    80005452:	84aa                	mv	s1,a0
    80005454:	c949                	beqz	a0,800054e6 <sys_link+0xe2>
  ilock(ip);
    80005456:	ffffe097          	auipc	ra,0xffffe
    8000545a:	29e080e7          	jalr	670(ra) # 800036f4 <ilock>
  if(ip->type == T_DIR){
    8000545e:	04449703          	lh	a4,68(s1)
    80005462:	4785                	li	a5,1
    80005464:	08f70863          	beq	a4,a5,800054f4 <sys_link+0xf0>
    80005468:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000546a:	04a4d783          	lhu	a5,74(s1)
    8000546e:	2785                	addiw	a5,a5,1
    80005470:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005474:	8526                	mv	a0,s1
    80005476:	ffffe097          	auipc	ra,0xffffe
    8000547a:	1b2080e7          	jalr	434(ra) # 80003628 <iupdate>
  iunlock(ip);
    8000547e:	8526                	mv	a0,s1
    80005480:	ffffe097          	auipc	ra,0xffffe
    80005484:	33a080e7          	jalr	826(ra) # 800037ba <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005488:	fd040593          	addi	a1,s0,-48
    8000548c:	f5040513          	addi	a0,s0,-176
    80005490:	fffff097          	auipc	ra,0xfffff
    80005494:	a50080e7          	jalr	-1456(ra) # 80003ee0 <nameiparent>
    80005498:	892a                	mv	s2,a0
    8000549a:	cd35                	beqz	a0,80005516 <sys_link+0x112>
  ilock(dp);
    8000549c:	ffffe097          	auipc	ra,0xffffe
    800054a0:	258080e7          	jalr	600(ra) # 800036f4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800054a4:	00092703          	lw	a4,0(s2)
    800054a8:	409c                	lw	a5,0(s1)
    800054aa:	06f71163          	bne	a4,a5,8000550c <sys_link+0x108>
    800054ae:	40d0                	lw	a2,4(s1)
    800054b0:	fd040593          	addi	a1,s0,-48
    800054b4:	854a                	mv	a0,s2
    800054b6:	fffff097          	auipc	ra,0xfffff
    800054ba:	95a080e7          	jalr	-1702(ra) # 80003e10 <dirlink>
    800054be:	04054763          	bltz	a0,8000550c <sys_link+0x108>
  iunlockput(dp);
    800054c2:	854a                	mv	a0,s2
    800054c4:	ffffe097          	auipc	ra,0xffffe
    800054c8:	496080e7          	jalr	1174(ra) # 8000395a <iunlockput>
  iput(ip);
    800054cc:	8526                	mv	a0,s1
    800054ce:	ffffe097          	auipc	ra,0xffffe
    800054d2:	3e4080e7          	jalr	996(ra) # 800038b2 <iput>
  end_op();
    800054d6:	fffff097          	auipc	ra,0xfffff
    800054da:	c66080e7          	jalr	-922(ra) # 8000413c <end_op>
  return 0;
    800054de:	4781                	li	a5,0
    800054e0:	64f2                	ld	s1,280(sp)
    800054e2:	6952                	ld	s2,272(sp)
    800054e4:	a0a5                	j	8000554c <sys_link+0x148>
    end_op();
    800054e6:	fffff097          	auipc	ra,0xfffff
    800054ea:	c56080e7          	jalr	-938(ra) # 8000413c <end_op>
    return -1;
    800054ee:	57fd                	li	a5,-1
    800054f0:	64f2                	ld	s1,280(sp)
    800054f2:	a8a9                	j	8000554c <sys_link+0x148>
    iunlockput(ip);
    800054f4:	8526                	mv	a0,s1
    800054f6:	ffffe097          	auipc	ra,0xffffe
    800054fa:	464080e7          	jalr	1124(ra) # 8000395a <iunlockput>
    end_op();
    800054fe:	fffff097          	auipc	ra,0xfffff
    80005502:	c3e080e7          	jalr	-962(ra) # 8000413c <end_op>
    return -1;
    80005506:	57fd                	li	a5,-1
    80005508:	64f2                	ld	s1,280(sp)
    8000550a:	a089                	j	8000554c <sys_link+0x148>
    iunlockput(dp);
    8000550c:	854a                	mv	a0,s2
    8000550e:	ffffe097          	auipc	ra,0xffffe
    80005512:	44c080e7          	jalr	1100(ra) # 8000395a <iunlockput>
  ilock(ip);
    80005516:	8526                	mv	a0,s1
    80005518:	ffffe097          	auipc	ra,0xffffe
    8000551c:	1dc080e7          	jalr	476(ra) # 800036f4 <ilock>
  ip->nlink--;
    80005520:	04a4d783          	lhu	a5,74(s1)
    80005524:	37fd                	addiw	a5,a5,-1
    80005526:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000552a:	8526                	mv	a0,s1
    8000552c:	ffffe097          	auipc	ra,0xffffe
    80005530:	0fc080e7          	jalr	252(ra) # 80003628 <iupdate>
  iunlockput(ip);
    80005534:	8526                	mv	a0,s1
    80005536:	ffffe097          	auipc	ra,0xffffe
    8000553a:	424080e7          	jalr	1060(ra) # 8000395a <iunlockput>
  end_op();
    8000553e:	fffff097          	auipc	ra,0xfffff
    80005542:	bfe080e7          	jalr	-1026(ra) # 8000413c <end_op>
  return -1;
    80005546:	57fd                	li	a5,-1
    80005548:	64f2                	ld	s1,280(sp)
    8000554a:	6952                	ld	s2,272(sp)
}
    8000554c:	853e                	mv	a0,a5
    8000554e:	70b2                	ld	ra,296(sp)
    80005550:	7412                	ld	s0,288(sp)
    80005552:	6155                	addi	sp,sp,304
    80005554:	8082                	ret

0000000080005556 <sys_unlink>:
{
    80005556:	7151                	addi	sp,sp,-240
    80005558:	f586                	sd	ra,232(sp)
    8000555a:	f1a2                	sd	s0,224(sp)
    8000555c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000555e:	08000613          	li	a2,128
    80005562:	f3040593          	addi	a1,s0,-208
    80005566:	4501                	li	a0,0
    80005568:	ffffd097          	auipc	ra,0xffffd
    8000556c:	642080e7          	jalr	1602(ra) # 80002baa <argstr>
    80005570:	1a054a63          	bltz	a0,80005724 <sys_unlink+0x1ce>
    80005574:	eda6                	sd	s1,216(sp)
  begin_op();
    80005576:	fffff097          	auipc	ra,0xfffff
    8000557a:	b4c080e7          	jalr	-1204(ra) # 800040c2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000557e:	fb040593          	addi	a1,s0,-80
    80005582:	f3040513          	addi	a0,s0,-208
    80005586:	fffff097          	auipc	ra,0xfffff
    8000558a:	95a080e7          	jalr	-1702(ra) # 80003ee0 <nameiparent>
    8000558e:	84aa                	mv	s1,a0
    80005590:	cd71                	beqz	a0,8000566c <sys_unlink+0x116>
  ilock(dp);
    80005592:	ffffe097          	auipc	ra,0xffffe
    80005596:	162080e7          	jalr	354(ra) # 800036f4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000559a:	00003597          	auipc	a1,0x3
    8000559e:	03e58593          	addi	a1,a1,62 # 800085d8 <etext+0x5d8>
    800055a2:	fb040513          	addi	a0,s0,-80
    800055a6:	ffffe097          	auipc	ra,0xffffe
    800055aa:	640080e7          	jalr	1600(ra) # 80003be6 <namecmp>
    800055ae:	14050c63          	beqz	a0,80005706 <sys_unlink+0x1b0>
    800055b2:	00003597          	auipc	a1,0x3
    800055b6:	02e58593          	addi	a1,a1,46 # 800085e0 <etext+0x5e0>
    800055ba:	fb040513          	addi	a0,s0,-80
    800055be:	ffffe097          	auipc	ra,0xffffe
    800055c2:	628080e7          	jalr	1576(ra) # 80003be6 <namecmp>
    800055c6:	14050063          	beqz	a0,80005706 <sys_unlink+0x1b0>
    800055ca:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800055cc:	f2c40613          	addi	a2,s0,-212
    800055d0:	fb040593          	addi	a1,s0,-80
    800055d4:	8526                	mv	a0,s1
    800055d6:	ffffe097          	auipc	ra,0xffffe
    800055da:	62a080e7          	jalr	1578(ra) # 80003c00 <dirlookup>
    800055de:	892a                	mv	s2,a0
    800055e0:	12050263          	beqz	a0,80005704 <sys_unlink+0x1ae>
  ilock(ip);
    800055e4:	ffffe097          	auipc	ra,0xffffe
    800055e8:	110080e7          	jalr	272(ra) # 800036f4 <ilock>
  if(ip->nlink < 1)
    800055ec:	04a91783          	lh	a5,74(s2)
    800055f0:	08f05563          	blez	a5,8000567a <sys_unlink+0x124>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800055f4:	04491703          	lh	a4,68(s2)
    800055f8:	4785                	li	a5,1
    800055fa:	08f70963          	beq	a4,a5,8000568c <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    800055fe:	4641                	li	a2,16
    80005600:	4581                	li	a1,0
    80005602:	fc040513          	addi	a0,s0,-64
    80005606:	ffffb097          	auipc	ra,0xffffb
    8000560a:	72e080e7          	jalr	1838(ra) # 80000d34 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000560e:	4741                	li	a4,16
    80005610:	f2c42683          	lw	a3,-212(s0)
    80005614:	fc040613          	addi	a2,s0,-64
    80005618:	4581                	li	a1,0
    8000561a:	8526                	mv	a0,s1
    8000561c:	ffffe097          	auipc	ra,0xffffe
    80005620:	4a0080e7          	jalr	1184(ra) # 80003abc <writei>
    80005624:	47c1                	li	a5,16
    80005626:	0af51b63          	bne	a0,a5,800056dc <sys_unlink+0x186>
  if(ip->type == T_DIR){
    8000562a:	04491703          	lh	a4,68(s2)
    8000562e:	4785                	li	a5,1
    80005630:	0af70f63          	beq	a4,a5,800056ee <sys_unlink+0x198>
  iunlockput(dp);
    80005634:	8526                	mv	a0,s1
    80005636:	ffffe097          	auipc	ra,0xffffe
    8000563a:	324080e7          	jalr	804(ra) # 8000395a <iunlockput>
  ip->nlink--;
    8000563e:	04a95783          	lhu	a5,74(s2)
    80005642:	37fd                	addiw	a5,a5,-1
    80005644:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005648:	854a                	mv	a0,s2
    8000564a:	ffffe097          	auipc	ra,0xffffe
    8000564e:	fde080e7          	jalr	-34(ra) # 80003628 <iupdate>
  iunlockput(ip);
    80005652:	854a                	mv	a0,s2
    80005654:	ffffe097          	auipc	ra,0xffffe
    80005658:	306080e7          	jalr	774(ra) # 8000395a <iunlockput>
  end_op();
    8000565c:	fffff097          	auipc	ra,0xfffff
    80005660:	ae0080e7          	jalr	-1312(ra) # 8000413c <end_op>
  return 0;
    80005664:	4501                	li	a0,0
    80005666:	64ee                	ld	s1,216(sp)
    80005668:	694e                	ld	s2,208(sp)
    8000566a:	a84d                	j	8000571c <sys_unlink+0x1c6>
    end_op();
    8000566c:	fffff097          	auipc	ra,0xfffff
    80005670:	ad0080e7          	jalr	-1328(ra) # 8000413c <end_op>
    return -1;
    80005674:	557d                	li	a0,-1
    80005676:	64ee                	ld	s1,216(sp)
    80005678:	a055                	j	8000571c <sys_unlink+0x1c6>
    8000567a:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    8000567c:	00003517          	auipc	a0,0x3
    80005680:	f6c50513          	addi	a0,a0,-148 # 800085e8 <etext+0x5e8>
    80005684:	ffffb097          	auipc	ra,0xffffb
    80005688:	edc080e7          	jalr	-292(ra) # 80000560 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000568c:	04c92703          	lw	a4,76(s2)
    80005690:	02000793          	li	a5,32
    80005694:	f6e7f5e3          	bgeu	a5,a4,800055fe <sys_unlink+0xa8>
    80005698:	e5ce                	sd	s3,200(sp)
    8000569a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000569e:	4741                	li	a4,16
    800056a0:	86ce                	mv	a3,s3
    800056a2:	f1840613          	addi	a2,s0,-232
    800056a6:	4581                	li	a1,0
    800056a8:	854a                	mv	a0,s2
    800056aa:	ffffe097          	auipc	ra,0xffffe
    800056ae:	302080e7          	jalr	770(ra) # 800039ac <readi>
    800056b2:	47c1                	li	a5,16
    800056b4:	00f51c63          	bne	a0,a5,800056cc <sys_unlink+0x176>
    if(de.inum != 0)
    800056b8:	f1845783          	lhu	a5,-232(s0)
    800056bc:	e7b5                	bnez	a5,80005728 <sys_unlink+0x1d2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800056be:	29c1                	addiw	s3,s3,16
    800056c0:	04c92783          	lw	a5,76(s2)
    800056c4:	fcf9ede3          	bltu	s3,a5,8000569e <sys_unlink+0x148>
    800056c8:	69ae                	ld	s3,200(sp)
    800056ca:	bf15                	j	800055fe <sys_unlink+0xa8>
      panic("isdirempty: readi");
    800056cc:	00003517          	auipc	a0,0x3
    800056d0:	f3450513          	addi	a0,a0,-204 # 80008600 <etext+0x600>
    800056d4:	ffffb097          	auipc	ra,0xffffb
    800056d8:	e8c080e7          	jalr	-372(ra) # 80000560 <panic>
    800056dc:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    800056de:	00003517          	auipc	a0,0x3
    800056e2:	f3a50513          	addi	a0,a0,-198 # 80008618 <etext+0x618>
    800056e6:	ffffb097          	auipc	ra,0xffffb
    800056ea:	e7a080e7          	jalr	-390(ra) # 80000560 <panic>
    dp->nlink--;
    800056ee:	04a4d783          	lhu	a5,74(s1)
    800056f2:	37fd                	addiw	a5,a5,-1
    800056f4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800056f8:	8526                	mv	a0,s1
    800056fa:	ffffe097          	auipc	ra,0xffffe
    800056fe:	f2e080e7          	jalr	-210(ra) # 80003628 <iupdate>
    80005702:	bf0d                	j	80005634 <sys_unlink+0xde>
    80005704:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005706:	8526                	mv	a0,s1
    80005708:	ffffe097          	auipc	ra,0xffffe
    8000570c:	252080e7          	jalr	594(ra) # 8000395a <iunlockput>
  end_op();
    80005710:	fffff097          	auipc	ra,0xfffff
    80005714:	a2c080e7          	jalr	-1492(ra) # 8000413c <end_op>
  return -1;
    80005718:	557d                	li	a0,-1
    8000571a:	64ee                	ld	s1,216(sp)
}
    8000571c:	70ae                	ld	ra,232(sp)
    8000571e:	740e                	ld	s0,224(sp)
    80005720:	616d                	addi	sp,sp,240
    80005722:	8082                	ret
    return -1;
    80005724:	557d                	li	a0,-1
    80005726:	bfdd                	j	8000571c <sys_unlink+0x1c6>
    iunlockput(ip);
    80005728:	854a                	mv	a0,s2
    8000572a:	ffffe097          	auipc	ra,0xffffe
    8000572e:	230080e7          	jalr	560(ra) # 8000395a <iunlockput>
    goto bad;
    80005732:	694e                	ld	s2,208(sp)
    80005734:	69ae                	ld	s3,200(sp)
    80005736:	bfc1                	j	80005706 <sys_unlink+0x1b0>

0000000080005738 <sys_open>:

uint64
sys_open(void)
{
    80005738:	7131                	addi	sp,sp,-192
    8000573a:	fd06                	sd	ra,184(sp)
    8000573c:	f922                	sd	s0,176(sp)
    8000573e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005740:	f4c40593          	addi	a1,s0,-180
    80005744:	4505                	li	a0,1
    80005746:	ffffd097          	auipc	ra,0xffffd
    8000574a:	424080e7          	jalr	1060(ra) # 80002b6a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000574e:	08000613          	li	a2,128
    80005752:	f5040593          	addi	a1,s0,-176
    80005756:	4501                	li	a0,0
    80005758:	ffffd097          	auipc	ra,0xffffd
    8000575c:	452080e7          	jalr	1106(ra) # 80002baa <argstr>
    80005760:	87aa                	mv	a5,a0
    return -1;
    80005762:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005764:	0a07ce63          	bltz	a5,80005820 <sys_open+0xe8>
    80005768:	f526                	sd	s1,168(sp)

  begin_op();
    8000576a:	fffff097          	auipc	ra,0xfffff
    8000576e:	958080e7          	jalr	-1704(ra) # 800040c2 <begin_op>

  if(omode & O_CREATE){
    80005772:	f4c42783          	lw	a5,-180(s0)
    80005776:	2007f793          	andi	a5,a5,512
    8000577a:	cfd5                	beqz	a5,80005836 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000577c:	4681                	li	a3,0
    8000577e:	4601                	li	a2,0
    80005780:	4589                	li	a1,2
    80005782:	f5040513          	addi	a0,s0,-176
    80005786:	00000097          	auipc	ra,0x0
    8000578a:	95c080e7          	jalr	-1700(ra) # 800050e2 <create>
    8000578e:	84aa                	mv	s1,a0
    if(ip == 0){
    80005790:	cd41                	beqz	a0,80005828 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005792:	04449703          	lh	a4,68(s1)
    80005796:	478d                	li	a5,3
    80005798:	00f71763          	bne	a4,a5,800057a6 <sys_open+0x6e>
    8000579c:	0464d703          	lhu	a4,70(s1)
    800057a0:	47a5                	li	a5,9
    800057a2:	0ee7e163          	bltu	a5,a4,80005884 <sys_open+0x14c>
    800057a6:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800057a8:	fffff097          	auipc	ra,0xfffff
    800057ac:	d28080e7          	jalr	-728(ra) # 800044d0 <filealloc>
    800057b0:	892a                	mv	s2,a0
    800057b2:	c97d                	beqz	a0,800058a8 <sys_open+0x170>
    800057b4:	ed4e                	sd	s3,152(sp)
    800057b6:	00000097          	auipc	ra,0x0
    800057ba:	8ea080e7          	jalr	-1814(ra) # 800050a0 <fdalloc>
    800057be:	89aa                	mv	s3,a0
    800057c0:	0c054e63          	bltz	a0,8000589c <sys_open+0x164>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800057c4:	04449703          	lh	a4,68(s1)
    800057c8:	478d                	li	a5,3
    800057ca:	0ef70c63          	beq	a4,a5,800058c2 <sys_open+0x18a>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800057ce:	4789                	li	a5,2
    800057d0:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800057d4:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800057d8:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800057dc:	f4c42783          	lw	a5,-180(s0)
    800057e0:	0017c713          	xori	a4,a5,1
    800057e4:	8b05                	andi	a4,a4,1
    800057e6:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800057ea:	0037f713          	andi	a4,a5,3
    800057ee:	00e03733          	snez	a4,a4
    800057f2:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800057f6:	4007f793          	andi	a5,a5,1024
    800057fa:	c791                	beqz	a5,80005806 <sys_open+0xce>
    800057fc:	04449703          	lh	a4,68(s1)
    80005800:	4789                	li	a5,2
    80005802:	0cf70763          	beq	a4,a5,800058d0 <sys_open+0x198>
    itrunc(ip);
  }

  iunlock(ip);
    80005806:	8526                	mv	a0,s1
    80005808:	ffffe097          	auipc	ra,0xffffe
    8000580c:	fb2080e7          	jalr	-78(ra) # 800037ba <iunlock>
  end_op();
    80005810:	fffff097          	auipc	ra,0xfffff
    80005814:	92c080e7          	jalr	-1748(ra) # 8000413c <end_op>

  return fd;
    80005818:	854e                	mv	a0,s3
    8000581a:	74aa                	ld	s1,168(sp)
    8000581c:	790a                	ld	s2,160(sp)
    8000581e:	69ea                	ld	s3,152(sp)
}
    80005820:	70ea                	ld	ra,184(sp)
    80005822:	744a                	ld	s0,176(sp)
    80005824:	6129                	addi	sp,sp,192
    80005826:	8082                	ret
      end_op();
    80005828:	fffff097          	auipc	ra,0xfffff
    8000582c:	914080e7          	jalr	-1772(ra) # 8000413c <end_op>
      return -1;
    80005830:	557d                	li	a0,-1
    80005832:	74aa                	ld	s1,168(sp)
    80005834:	b7f5                	j	80005820 <sys_open+0xe8>
    if((ip = namei(path)) == 0){
    80005836:	f5040513          	addi	a0,s0,-176
    8000583a:	ffffe097          	auipc	ra,0xffffe
    8000583e:	688080e7          	jalr	1672(ra) # 80003ec2 <namei>
    80005842:	84aa                	mv	s1,a0
    80005844:	c90d                	beqz	a0,80005876 <sys_open+0x13e>
    ilock(ip);
    80005846:	ffffe097          	auipc	ra,0xffffe
    8000584a:	eae080e7          	jalr	-338(ra) # 800036f4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000584e:	04449703          	lh	a4,68(s1)
    80005852:	4785                	li	a5,1
    80005854:	f2f71fe3          	bne	a4,a5,80005792 <sys_open+0x5a>
    80005858:	f4c42783          	lw	a5,-180(s0)
    8000585c:	d7a9                	beqz	a5,800057a6 <sys_open+0x6e>
      iunlockput(ip);
    8000585e:	8526                	mv	a0,s1
    80005860:	ffffe097          	auipc	ra,0xffffe
    80005864:	0fa080e7          	jalr	250(ra) # 8000395a <iunlockput>
      end_op();
    80005868:	fffff097          	auipc	ra,0xfffff
    8000586c:	8d4080e7          	jalr	-1836(ra) # 8000413c <end_op>
      return -1;
    80005870:	557d                	li	a0,-1
    80005872:	74aa                	ld	s1,168(sp)
    80005874:	b775                	j	80005820 <sys_open+0xe8>
      end_op();
    80005876:	fffff097          	auipc	ra,0xfffff
    8000587a:	8c6080e7          	jalr	-1850(ra) # 8000413c <end_op>
      return -1;
    8000587e:	557d                	li	a0,-1
    80005880:	74aa                	ld	s1,168(sp)
    80005882:	bf79                	j	80005820 <sys_open+0xe8>
    iunlockput(ip);
    80005884:	8526                	mv	a0,s1
    80005886:	ffffe097          	auipc	ra,0xffffe
    8000588a:	0d4080e7          	jalr	212(ra) # 8000395a <iunlockput>
    end_op();
    8000588e:	fffff097          	auipc	ra,0xfffff
    80005892:	8ae080e7          	jalr	-1874(ra) # 8000413c <end_op>
    return -1;
    80005896:	557d                	li	a0,-1
    80005898:	74aa                	ld	s1,168(sp)
    8000589a:	b759                	j	80005820 <sys_open+0xe8>
      fileclose(f);
    8000589c:	854a                	mv	a0,s2
    8000589e:	fffff097          	auipc	ra,0xfffff
    800058a2:	cee080e7          	jalr	-786(ra) # 8000458c <fileclose>
    800058a6:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800058a8:	8526                	mv	a0,s1
    800058aa:	ffffe097          	auipc	ra,0xffffe
    800058ae:	0b0080e7          	jalr	176(ra) # 8000395a <iunlockput>
    end_op();
    800058b2:	fffff097          	auipc	ra,0xfffff
    800058b6:	88a080e7          	jalr	-1910(ra) # 8000413c <end_op>
    return -1;
    800058ba:	557d                	li	a0,-1
    800058bc:	74aa                	ld	s1,168(sp)
    800058be:	790a                	ld	s2,160(sp)
    800058c0:	b785                	j	80005820 <sys_open+0xe8>
    f->type = FD_DEVICE;
    800058c2:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800058c6:	04649783          	lh	a5,70(s1)
    800058ca:	02f91223          	sh	a5,36(s2)
    800058ce:	b729                	j	800057d8 <sys_open+0xa0>
    itrunc(ip);
    800058d0:	8526                	mv	a0,s1
    800058d2:	ffffe097          	auipc	ra,0xffffe
    800058d6:	f34080e7          	jalr	-204(ra) # 80003806 <itrunc>
    800058da:	b735                	j	80005806 <sys_open+0xce>

00000000800058dc <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800058dc:	7175                	addi	sp,sp,-144
    800058de:	e506                	sd	ra,136(sp)
    800058e0:	e122                	sd	s0,128(sp)
    800058e2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800058e4:	ffffe097          	auipc	ra,0xffffe
    800058e8:	7de080e7          	jalr	2014(ra) # 800040c2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800058ec:	08000613          	li	a2,128
    800058f0:	f7040593          	addi	a1,s0,-144
    800058f4:	4501                	li	a0,0
    800058f6:	ffffd097          	auipc	ra,0xffffd
    800058fa:	2b4080e7          	jalr	692(ra) # 80002baa <argstr>
    800058fe:	02054963          	bltz	a0,80005930 <sys_mkdir+0x54>
    80005902:	4681                	li	a3,0
    80005904:	4601                	li	a2,0
    80005906:	4585                	li	a1,1
    80005908:	f7040513          	addi	a0,s0,-144
    8000590c:	fffff097          	auipc	ra,0xfffff
    80005910:	7d6080e7          	jalr	2006(ra) # 800050e2 <create>
    80005914:	cd11                	beqz	a0,80005930 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005916:	ffffe097          	auipc	ra,0xffffe
    8000591a:	044080e7          	jalr	68(ra) # 8000395a <iunlockput>
  end_op();
    8000591e:	fffff097          	auipc	ra,0xfffff
    80005922:	81e080e7          	jalr	-2018(ra) # 8000413c <end_op>
  return 0;
    80005926:	4501                	li	a0,0
}
    80005928:	60aa                	ld	ra,136(sp)
    8000592a:	640a                	ld	s0,128(sp)
    8000592c:	6149                	addi	sp,sp,144
    8000592e:	8082                	ret
    end_op();
    80005930:	fffff097          	auipc	ra,0xfffff
    80005934:	80c080e7          	jalr	-2036(ra) # 8000413c <end_op>
    return -1;
    80005938:	557d                	li	a0,-1
    8000593a:	b7fd                	j	80005928 <sys_mkdir+0x4c>

000000008000593c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000593c:	7135                	addi	sp,sp,-160
    8000593e:	ed06                	sd	ra,152(sp)
    80005940:	e922                	sd	s0,144(sp)
    80005942:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005944:	ffffe097          	auipc	ra,0xffffe
    80005948:	77e080e7          	jalr	1918(ra) # 800040c2 <begin_op>
  argint(1, &major);
    8000594c:	f6c40593          	addi	a1,s0,-148
    80005950:	4505                	li	a0,1
    80005952:	ffffd097          	auipc	ra,0xffffd
    80005956:	218080e7          	jalr	536(ra) # 80002b6a <argint>
  argint(2, &minor);
    8000595a:	f6840593          	addi	a1,s0,-152
    8000595e:	4509                	li	a0,2
    80005960:	ffffd097          	auipc	ra,0xffffd
    80005964:	20a080e7          	jalr	522(ra) # 80002b6a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005968:	08000613          	li	a2,128
    8000596c:	f7040593          	addi	a1,s0,-144
    80005970:	4501                	li	a0,0
    80005972:	ffffd097          	auipc	ra,0xffffd
    80005976:	238080e7          	jalr	568(ra) # 80002baa <argstr>
    8000597a:	02054b63          	bltz	a0,800059b0 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000597e:	f6841683          	lh	a3,-152(s0)
    80005982:	f6c41603          	lh	a2,-148(s0)
    80005986:	458d                	li	a1,3
    80005988:	f7040513          	addi	a0,s0,-144
    8000598c:	fffff097          	auipc	ra,0xfffff
    80005990:	756080e7          	jalr	1878(ra) # 800050e2 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005994:	cd11                	beqz	a0,800059b0 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005996:	ffffe097          	auipc	ra,0xffffe
    8000599a:	fc4080e7          	jalr	-60(ra) # 8000395a <iunlockput>
  end_op();
    8000599e:	ffffe097          	auipc	ra,0xffffe
    800059a2:	79e080e7          	jalr	1950(ra) # 8000413c <end_op>
  return 0;
    800059a6:	4501                	li	a0,0
}
    800059a8:	60ea                	ld	ra,152(sp)
    800059aa:	644a                	ld	s0,144(sp)
    800059ac:	610d                	addi	sp,sp,160
    800059ae:	8082                	ret
    end_op();
    800059b0:	ffffe097          	auipc	ra,0xffffe
    800059b4:	78c080e7          	jalr	1932(ra) # 8000413c <end_op>
    return -1;
    800059b8:	557d                	li	a0,-1
    800059ba:	b7fd                	j	800059a8 <sys_mknod+0x6c>

00000000800059bc <sys_chdir>:

uint64
sys_chdir(void)
{
    800059bc:	7135                	addi	sp,sp,-160
    800059be:	ed06                	sd	ra,152(sp)
    800059c0:	e922                	sd	s0,144(sp)
    800059c2:	e14a                	sd	s2,128(sp)
    800059c4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800059c6:	ffffc097          	auipc	ra,0xffffc
    800059ca:	084080e7          	jalr	132(ra) # 80001a4a <myproc>
    800059ce:	892a                	mv	s2,a0
  
  begin_op();
    800059d0:	ffffe097          	auipc	ra,0xffffe
    800059d4:	6f2080e7          	jalr	1778(ra) # 800040c2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800059d8:	08000613          	li	a2,128
    800059dc:	f6040593          	addi	a1,s0,-160
    800059e0:	4501                	li	a0,0
    800059e2:	ffffd097          	auipc	ra,0xffffd
    800059e6:	1c8080e7          	jalr	456(ra) # 80002baa <argstr>
    800059ea:	04054d63          	bltz	a0,80005a44 <sys_chdir+0x88>
    800059ee:	e526                	sd	s1,136(sp)
    800059f0:	f6040513          	addi	a0,s0,-160
    800059f4:	ffffe097          	auipc	ra,0xffffe
    800059f8:	4ce080e7          	jalr	1230(ra) # 80003ec2 <namei>
    800059fc:	84aa                	mv	s1,a0
    800059fe:	c131                	beqz	a0,80005a42 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005a00:	ffffe097          	auipc	ra,0xffffe
    80005a04:	cf4080e7          	jalr	-780(ra) # 800036f4 <ilock>
  if(ip->type != T_DIR){
    80005a08:	04449703          	lh	a4,68(s1)
    80005a0c:	4785                	li	a5,1
    80005a0e:	04f71163          	bne	a4,a5,80005a50 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005a12:	8526                	mv	a0,s1
    80005a14:	ffffe097          	auipc	ra,0xffffe
    80005a18:	da6080e7          	jalr	-602(ra) # 800037ba <iunlock>
  iput(p->cwd);
    80005a1c:	15093503          	ld	a0,336(s2)
    80005a20:	ffffe097          	auipc	ra,0xffffe
    80005a24:	e92080e7          	jalr	-366(ra) # 800038b2 <iput>
  end_op();
    80005a28:	ffffe097          	auipc	ra,0xffffe
    80005a2c:	714080e7          	jalr	1812(ra) # 8000413c <end_op>
  p->cwd = ip;
    80005a30:	14993823          	sd	s1,336(s2)
  return 0;
    80005a34:	4501                	li	a0,0
    80005a36:	64aa                	ld	s1,136(sp)
}
    80005a38:	60ea                	ld	ra,152(sp)
    80005a3a:	644a                	ld	s0,144(sp)
    80005a3c:	690a                	ld	s2,128(sp)
    80005a3e:	610d                	addi	sp,sp,160
    80005a40:	8082                	ret
    80005a42:	64aa                	ld	s1,136(sp)
    end_op();
    80005a44:	ffffe097          	auipc	ra,0xffffe
    80005a48:	6f8080e7          	jalr	1784(ra) # 8000413c <end_op>
    return -1;
    80005a4c:	557d                	li	a0,-1
    80005a4e:	b7ed                	j	80005a38 <sys_chdir+0x7c>
    iunlockput(ip);
    80005a50:	8526                	mv	a0,s1
    80005a52:	ffffe097          	auipc	ra,0xffffe
    80005a56:	f08080e7          	jalr	-248(ra) # 8000395a <iunlockput>
    end_op();
    80005a5a:	ffffe097          	auipc	ra,0xffffe
    80005a5e:	6e2080e7          	jalr	1762(ra) # 8000413c <end_op>
    return -1;
    80005a62:	557d                	li	a0,-1
    80005a64:	64aa                	ld	s1,136(sp)
    80005a66:	bfc9                	j	80005a38 <sys_chdir+0x7c>

0000000080005a68 <sys_exec>:

uint64
sys_exec(void)
{
    80005a68:	7121                	addi	sp,sp,-448
    80005a6a:	ff06                	sd	ra,440(sp)
    80005a6c:	fb22                	sd	s0,432(sp)
    80005a6e:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005a70:	e4840593          	addi	a1,s0,-440
    80005a74:	4505                	li	a0,1
    80005a76:	ffffd097          	auipc	ra,0xffffd
    80005a7a:	114080e7          	jalr	276(ra) # 80002b8a <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005a7e:	08000613          	li	a2,128
    80005a82:	f5040593          	addi	a1,s0,-176
    80005a86:	4501                	li	a0,0
    80005a88:	ffffd097          	auipc	ra,0xffffd
    80005a8c:	122080e7          	jalr	290(ra) # 80002baa <argstr>
    80005a90:	87aa                	mv	a5,a0
    return -1;
    80005a92:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005a94:	0e07c263          	bltz	a5,80005b78 <sys_exec+0x110>
    80005a98:	f726                	sd	s1,424(sp)
    80005a9a:	f34a                	sd	s2,416(sp)
    80005a9c:	ef4e                	sd	s3,408(sp)
    80005a9e:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005aa0:	10000613          	li	a2,256
    80005aa4:	4581                	li	a1,0
    80005aa6:	e5040513          	addi	a0,s0,-432
    80005aaa:	ffffb097          	auipc	ra,0xffffb
    80005aae:	28a080e7          	jalr	650(ra) # 80000d34 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005ab2:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005ab6:	89a6                	mv	s3,s1
    80005ab8:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005aba:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005abe:	00391513          	slli	a0,s2,0x3
    80005ac2:	e4040593          	addi	a1,s0,-448
    80005ac6:	e4843783          	ld	a5,-440(s0)
    80005aca:	953e                	add	a0,a0,a5
    80005acc:	ffffd097          	auipc	ra,0xffffd
    80005ad0:	000080e7          	jalr	ra # 80002acc <fetchaddr>
    80005ad4:	02054a63          	bltz	a0,80005b08 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005ad8:	e4043783          	ld	a5,-448(s0)
    80005adc:	c7b9                	beqz	a5,80005b2a <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005ade:	ffffb097          	auipc	ra,0xffffb
    80005ae2:	06a080e7          	jalr	106(ra) # 80000b48 <kalloc>
    80005ae6:	85aa                	mv	a1,a0
    80005ae8:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005aec:	cd11                	beqz	a0,80005b08 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005aee:	6605                	lui	a2,0x1
    80005af0:	e4043503          	ld	a0,-448(s0)
    80005af4:	ffffd097          	auipc	ra,0xffffd
    80005af8:	02a080e7          	jalr	42(ra) # 80002b1e <fetchstr>
    80005afc:	00054663          	bltz	a0,80005b08 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005b00:	0905                	addi	s2,s2,1
    80005b02:	09a1                	addi	s3,s3,8
    80005b04:	fb491de3          	bne	s2,s4,80005abe <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b08:	f5040913          	addi	s2,s0,-176
    80005b0c:	6088                	ld	a0,0(s1)
    80005b0e:	c125                	beqz	a0,80005b6e <sys_exec+0x106>
    kfree(argv[i]);
    80005b10:	ffffb097          	auipc	ra,0xffffb
    80005b14:	f3a080e7          	jalr	-198(ra) # 80000a4a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b18:	04a1                	addi	s1,s1,8
    80005b1a:	ff2499e3          	bne	s1,s2,80005b0c <sys_exec+0xa4>
  return -1;
    80005b1e:	557d                	li	a0,-1
    80005b20:	74ba                	ld	s1,424(sp)
    80005b22:	791a                	ld	s2,416(sp)
    80005b24:	69fa                	ld	s3,408(sp)
    80005b26:	6a5a                	ld	s4,400(sp)
    80005b28:	a881                	j	80005b78 <sys_exec+0x110>
      argv[i] = 0;
    80005b2a:	0009079b          	sext.w	a5,s2
    80005b2e:	078e                	slli	a5,a5,0x3
    80005b30:	fd078793          	addi	a5,a5,-48
    80005b34:	97a2                	add	a5,a5,s0
    80005b36:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005b3a:	e5040593          	addi	a1,s0,-432
    80005b3e:	f5040513          	addi	a0,s0,-176
    80005b42:	fffff097          	auipc	ra,0xfffff
    80005b46:	120080e7          	jalr	288(ra) # 80004c62 <exec>
    80005b4a:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b4c:	f5040993          	addi	s3,s0,-176
    80005b50:	6088                	ld	a0,0(s1)
    80005b52:	c901                	beqz	a0,80005b62 <sys_exec+0xfa>
    kfree(argv[i]);
    80005b54:	ffffb097          	auipc	ra,0xffffb
    80005b58:	ef6080e7          	jalr	-266(ra) # 80000a4a <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b5c:	04a1                	addi	s1,s1,8
    80005b5e:	ff3499e3          	bne	s1,s3,80005b50 <sys_exec+0xe8>
  return ret;
    80005b62:	854a                	mv	a0,s2
    80005b64:	74ba                	ld	s1,424(sp)
    80005b66:	791a                	ld	s2,416(sp)
    80005b68:	69fa                	ld	s3,408(sp)
    80005b6a:	6a5a                	ld	s4,400(sp)
    80005b6c:	a031                	j	80005b78 <sys_exec+0x110>
  return -1;
    80005b6e:	557d                	li	a0,-1
    80005b70:	74ba                	ld	s1,424(sp)
    80005b72:	791a                	ld	s2,416(sp)
    80005b74:	69fa                	ld	s3,408(sp)
    80005b76:	6a5a                	ld	s4,400(sp)
}
    80005b78:	70fa                	ld	ra,440(sp)
    80005b7a:	745a                	ld	s0,432(sp)
    80005b7c:	6139                	addi	sp,sp,448
    80005b7e:	8082                	ret

0000000080005b80 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005b80:	7139                	addi	sp,sp,-64
    80005b82:	fc06                	sd	ra,56(sp)
    80005b84:	f822                	sd	s0,48(sp)
    80005b86:	f426                	sd	s1,40(sp)
    80005b88:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005b8a:	ffffc097          	auipc	ra,0xffffc
    80005b8e:	ec0080e7          	jalr	-320(ra) # 80001a4a <myproc>
    80005b92:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005b94:	fd840593          	addi	a1,s0,-40
    80005b98:	4501                	li	a0,0
    80005b9a:	ffffd097          	auipc	ra,0xffffd
    80005b9e:	ff0080e7          	jalr	-16(ra) # 80002b8a <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005ba2:	fc840593          	addi	a1,s0,-56
    80005ba6:	fd040513          	addi	a0,s0,-48
    80005baa:	fffff097          	auipc	ra,0xfffff
    80005bae:	d50080e7          	jalr	-688(ra) # 800048fa <pipealloc>
    return -1;
    80005bb2:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005bb4:	0c054463          	bltz	a0,80005c7c <sys_pipe+0xfc>
  fd0 = -1;
    80005bb8:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005bbc:	fd043503          	ld	a0,-48(s0)
    80005bc0:	fffff097          	auipc	ra,0xfffff
    80005bc4:	4e0080e7          	jalr	1248(ra) # 800050a0 <fdalloc>
    80005bc8:	fca42223          	sw	a0,-60(s0)
    80005bcc:	08054b63          	bltz	a0,80005c62 <sys_pipe+0xe2>
    80005bd0:	fc843503          	ld	a0,-56(s0)
    80005bd4:	fffff097          	auipc	ra,0xfffff
    80005bd8:	4cc080e7          	jalr	1228(ra) # 800050a0 <fdalloc>
    80005bdc:	fca42023          	sw	a0,-64(s0)
    80005be0:	06054863          	bltz	a0,80005c50 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005be4:	4691                	li	a3,4
    80005be6:	fc440613          	addi	a2,s0,-60
    80005bea:	fd843583          	ld	a1,-40(s0)
    80005bee:	68a8                	ld	a0,80(s1)
    80005bf0:	ffffc097          	auipc	ra,0xffffc
    80005bf4:	af2080e7          	jalr	-1294(ra) # 800016e2 <copyout>
    80005bf8:	02054063          	bltz	a0,80005c18 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005bfc:	4691                	li	a3,4
    80005bfe:	fc040613          	addi	a2,s0,-64
    80005c02:	fd843583          	ld	a1,-40(s0)
    80005c06:	0591                	addi	a1,a1,4
    80005c08:	68a8                	ld	a0,80(s1)
    80005c0a:	ffffc097          	auipc	ra,0xffffc
    80005c0e:	ad8080e7          	jalr	-1320(ra) # 800016e2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005c12:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c14:	06055463          	bgez	a0,80005c7c <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005c18:	fc442783          	lw	a5,-60(s0)
    80005c1c:	07e9                	addi	a5,a5,26
    80005c1e:	078e                	slli	a5,a5,0x3
    80005c20:	97a6                	add	a5,a5,s1
    80005c22:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005c26:	fc042783          	lw	a5,-64(s0)
    80005c2a:	07e9                	addi	a5,a5,26
    80005c2c:	078e                	slli	a5,a5,0x3
    80005c2e:	94be                	add	s1,s1,a5
    80005c30:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005c34:	fd043503          	ld	a0,-48(s0)
    80005c38:	fffff097          	auipc	ra,0xfffff
    80005c3c:	954080e7          	jalr	-1708(ra) # 8000458c <fileclose>
    fileclose(wf);
    80005c40:	fc843503          	ld	a0,-56(s0)
    80005c44:	fffff097          	auipc	ra,0xfffff
    80005c48:	948080e7          	jalr	-1720(ra) # 8000458c <fileclose>
    return -1;
    80005c4c:	57fd                	li	a5,-1
    80005c4e:	a03d                	j	80005c7c <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005c50:	fc442783          	lw	a5,-60(s0)
    80005c54:	0007c763          	bltz	a5,80005c62 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005c58:	07e9                	addi	a5,a5,26
    80005c5a:	078e                	slli	a5,a5,0x3
    80005c5c:	97a6                	add	a5,a5,s1
    80005c5e:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005c62:	fd043503          	ld	a0,-48(s0)
    80005c66:	fffff097          	auipc	ra,0xfffff
    80005c6a:	926080e7          	jalr	-1754(ra) # 8000458c <fileclose>
    fileclose(wf);
    80005c6e:	fc843503          	ld	a0,-56(s0)
    80005c72:	fffff097          	auipc	ra,0xfffff
    80005c76:	91a080e7          	jalr	-1766(ra) # 8000458c <fileclose>
    return -1;
    80005c7a:	57fd                	li	a5,-1
}
    80005c7c:	853e                	mv	a0,a5
    80005c7e:	70e2                	ld	ra,56(sp)
    80005c80:	7442                	ld	s0,48(sp)
    80005c82:	74a2                	ld	s1,40(sp)
    80005c84:	6121                	addi	sp,sp,64
    80005c86:	8082                	ret
	...

0000000080005c90 <kernelvec>:
    80005c90:	7111                	addi	sp,sp,-256
    80005c92:	e006                	sd	ra,0(sp)
    80005c94:	e40a                	sd	sp,8(sp)
    80005c96:	e80e                	sd	gp,16(sp)
    80005c98:	ec12                	sd	tp,24(sp)
    80005c9a:	f016                	sd	t0,32(sp)
    80005c9c:	f41a                	sd	t1,40(sp)
    80005c9e:	f81e                	sd	t2,48(sp)
    80005ca0:	fc22                	sd	s0,56(sp)
    80005ca2:	e0a6                	sd	s1,64(sp)
    80005ca4:	e4aa                	sd	a0,72(sp)
    80005ca6:	e8ae                	sd	a1,80(sp)
    80005ca8:	ecb2                	sd	a2,88(sp)
    80005caa:	f0b6                	sd	a3,96(sp)
    80005cac:	f4ba                	sd	a4,104(sp)
    80005cae:	f8be                	sd	a5,112(sp)
    80005cb0:	fcc2                	sd	a6,120(sp)
    80005cb2:	e146                	sd	a7,128(sp)
    80005cb4:	e54a                	sd	s2,136(sp)
    80005cb6:	e94e                	sd	s3,144(sp)
    80005cb8:	ed52                	sd	s4,152(sp)
    80005cba:	f156                	sd	s5,160(sp)
    80005cbc:	f55a                	sd	s6,168(sp)
    80005cbe:	f95e                	sd	s7,176(sp)
    80005cc0:	fd62                	sd	s8,184(sp)
    80005cc2:	e1e6                	sd	s9,192(sp)
    80005cc4:	e5ea                	sd	s10,200(sp)
    80005cc6:	e9ee                	sd	s11,208(sp)
    80005cc8:	edf2                	sd	t3,216(sp)
    80005cca:	f1f6                	sd	t4,224(sp)
    80005ccc:	f5fa                	sd	t5,232(sp)
    80005cce:	f9fe                	sd	t6,240(sp)
    80005cd0:	cc9fc0ef          	jal	80002998 <kerneltrap>
    80005cd4:	6082                	ld	ra,0(sp)
    80005cd6:	6122                	ld	sp,8(sp)
    80005cd8:	61c2                	ld	gp,16(sp)
    80005cda:	7282                	ld	t0,32(sp)
    80005cdc:	7322                	ld	t1,40(sp)
    80005cde:	73c2                	ld	t2,48(sp)
    80005ce0:	7462                	ld	s0,56(sp)
    80005ce2:	6486                	ld	s1,64(sp)
    80005ce4:	6526                	ld	a0,72(sp)
    80005ce6:	65c6                	ld	a1,80(sp)
    80005ce8:	6666                	ld	a2,88(sp)
    80005cea:	7686                	ld	a3,96(sp)
    80005cec:	7726                	ld	a4,104(sp)
    80005cee:	77c6                	ld	a5,112(sp)
    80005cf0:	7866                	ld	a6,120(sp)
    80005cf2:	688a                	ld	a7,128(sp)
    80005cf4:	692a                	ld	s2,136(sp)
    80005cf6:	69ca                	ld	s3,144(sp)
    80005cf8:	6a6a                	ld	s4,152(sp)
    80005cfa:	7a8a                	ld	s5,160(sp)
    80005cfc:	7b2a                	ld	s6,168(sp)
    80005cfe:	7bca                	ld	s7,176(sp)
    80005d00:	7c6a                	ld	s8,184(sp)
    80005d02:	6c8e                	ld	s9,192(sp)
    80005d04:	6d2e                	ld	s10,200(sp)
    80005d06:	6dce                	ld	s11,208(sp)
    80005d08:	6e6e                	ld	t3,216(sp)
    80005d0a:	7e8e                	ld	t4,224(sp)
    80005d0c:	7f2e                	ld	t5,232(sp)
    80005d0e:	7fce                	ld	t6,240(sp)
    80005d10:	6111                	addi	sp,sp,256
    80005d12:	10200073          	sret
    80005d16:	00000013          	nop
    80005d1a:	00000013          	nop
    80005d1e:	0001                	nop

0000000080005d20 <timervec>:
    80005d20:	34051573          	csrrw	a0,mscratch,a0
    80005d24:	e10c                	sd	a1,0(a0)
    80005d26:	e510                	sd	a2,8(a0)
    80005d28:	e914                	sd	a3,16(a0)
    80005d2a:	6d0c                	ld	a1,24(a0)
    80005d2c:	7110                	ld	a2,32(a0)
    80005d2e:	6194                	ld	a3,0(a1)
    80005d30:	96b2                	add	a3,a3,a2
    80005d32:	e194                	sd	a3,0(a1)
    80005d34:	4589                	li	a1,2
    80005d36:	14459073          	csrw	sip,a1
    80005d3a:	6914                	ld	a3,16(a0)
    80005d3c:	6510                	ld	a2,8(a0)
    80005d3e:	610c                	ld	a1,0(a0)
    80005d40:	34051573          	csrrw	a0,mscratch,a0
    80005d44:	30200073          	mret
	...

0000000080005d4a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005d4a:	1141                	addi	sp,sp,-16
    80005d4c:	e422                	sd	s0,8(sp)
    80005d4e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005d50:	0c0007b7          	lui	a5,0xc000
    80005d54:	4705                	li	a4,1
    80005d56:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005d58:	0c0007b7          	lui	a5,0xc000
    80005d5c:	c3d8                	sw	a4,4(a5)
}
    80005d5e:	6422                	ld	s0,8(sp)
    80005d60:	0141                	addi	sp,sp,16
    80005d62:	8082                	ret

0000000080005d64 <plicinithart>:

void
plicinithart(void)
{
    80005d64:	1141                	addi	sp,sp,-16
    80005d66:	e406                	sd	ra,8(sp)
    80005d68:	e022                	sd	s0,0(sp)
    80005d6a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d6c:	ffffc097          	auipc	ra,0xffffc
    80005d70:	cb2080e7          	jalr	-846(ra) # 80001a1e <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005d74:	0085171b          	slliw	a4,a0,0x8
    80005d78:	0c0027b7          	lui	a5,0xc002
    80005d7c:	97ba                	add	a5,a5,a4
    80005d7e:	40200713          	li	a4,1026
    80005d82:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005d86:	00d5151b          	slliw	a0,a0,0xd
    80005d8a:	0c2017b7          	lui	a5,0xc201
    80005d8e:	97aa                	add	a5,a5,a0
    80005d90:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005d94:	60a2                	ld	ra,8(sp)
    80005d96:	6402                	ld	s0,0(sp)
    80005d98:	0141                	addi	sp,sp,16
    80005d9a:	8082                	ret

0000000080005d9c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d9c:	1141                	addi	sp,sp,-16
    80005d9e:	e406                	sd	ra,8(sp)
    80005da0:	e022                	sd	s0,0(sp)
    80005da2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005da4:	ffffc097          	auipc	ra,0xffffc
    80005da8:	c7a080e7          	jalr	-902(ra) # 80001a1e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005dac:	00d5151b          	slliw	a0,a0,0xd
    80005db0:	0c2017b7          	lui	a5,0xc201
    80005db4:	97aa                	add	a5,a5,a0
  return irq;
}
    80005db6:	43c8                	lw	a0,4(a5)
    80005db8:	60a2                	ld	ra,8(sp)
    80005dba:	6402                	ld	s0,0(sp)
    80005dbc:	0141                	addi	sp,sp,16
    80005dbe:	8082                	ret

0000000080005dc0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005dc0:	1101                	addi	sp,sp,-32
    80005dc2:	ec06                	sd	ra,24(sp)
    80005dc4:	e822                	sd	s0,16(sp)
    80005dc6:	e426                	sd	s1,8(sp)
    80005dc8:	1000                	addi	s0,sp,32
    80005dca:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005dcc:	ffffc097          	auipc	ra,0xffffc
    80005dd0:	c52080e7          	jalr	-942(ra) # 80001a1e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005dd4:	00d5151b          	slliw	a0,a0,0xd
    80005dd8:	0c2017b7          	lui	a5,0xc201
    80005ddc:	97aa                	add	a5,a5,a0
    80005dde:	c3c4                	sw	s1,4(a5)
}
    80005de0:	60e2                	ld	ra,24(sp)
    80005de2:	6442                	ld	s0,16(sp)
    80005de4:	64a2                	ld	s1,8(sp)
    80005de6:	6105                	addi	sp,sp,32
    80005de8:	8082                	ret

0000000080005dea <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005dea:	1141                	addi	sp,sp,-16
    80005dec:	e406                	sd	ra,8(sp)
    80005dee:	e022                	sd	s0,0(sp)
    80005df0:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005df2:	479d                	li	a5,7
    80005df4:	04a7cc63          	blt	a5,a0,80005e4c <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005df8:	0001e797          	auipc	a5,0x1e
    80005dfc:	6d878793          	addi	a5,a5,1752 # 800244d0 <disk>
    80005e00:	97aa                	add	a5,a5,a0
    80005e02:	0187c783          	lbu	a5,24(a5)
    80005e06:	ebb9                	bnez	a5,80005e5c <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005e08:	00451693          	slli	a3,a0,0x4
    80005e0c:	0001e797          	auipc	a5,0x1e
    80005e10:	6c478793          	addi	a5,a5,1732 # 800244d0 <disk>
    80005e14:	6398                	ld	a4,0(a5)
    80005e16:	9736                	add	a4,a4,a3
    80005e18:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005e1c:	6398                	ld	a4,0(a5)
    80005e1e:	9736                	add	a4,a4,a3
    80005e20:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005e24:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005e28:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005e2c:	97aa                	add	a5,a5,a0
    80005e2e:	4705                	li	a4,1
    80005e30:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005e34:	0001e517          	auipc	a0,0x1e
    80005e38:	6b450513          	addi	a0,a0,1716 # 800244e8 <disk+0x18>
    80005e3c:	ffffc097          	auipc	ra,0xffffc
    80005e40:	31c080e7          	jalr	796(ra) # 80002158 <wakeup>
}
    80005e44:	60a2                	ld	ra,8(sp)
    80005e46:	6402                	ld	s0,0(sp)
    80005e48:	0141                	addi	sp,sp,16
    80005e4a:	8082                	ret
    panic("free_desc 1");
    80005e4c:	00002517          	auipc	a0,0x2
    80005e50:	7dc50513          	addi	a0,a0,2012 # 80008628 <etext+0x628>
    80005e54:	ffffa097          	auipc	ra,0xffffa
    80005e58:	70c080e7          	jalr	1804(ra) # 80000560 <panic>
    panic("free_desc 2");
    80005e5c:	00002517          	auipc	a0,0x2
    80005e60:	7dc50513          	addi	a0,a0,2012 # 80008638 <etext+0x638>
    80005e64:	ffffa097          	auipc	ra,0xffffa
    80005e68:	6fc080e7          	jalr	1788(ra) # 80000560 <panic>

0000000080005e6c <virtio_disk_init>:
{
    80005e6c:	1101                	addi	sp,sp,-32
    80005e6e:	ec06                	sd	ra,24(sp)
    80005e70:	e822                	sd	s0,16(sp)
    80005e72:	e426                	sd	s1,8(sp)
    80005e74:	e04a                	sd	s2,0(sp)
    80005e76:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005e78:	00002597          	auipc	a1,0x2
    80005e7c:	7d058593          	addi	a1,a1,2000 # 80008648 <etext+0x648>
    80005e80:	0001e517          	auipc	a0,0x1e
    80005e84:	77850513          	addi	a0,a0,1912 # 800245f8 <disk+0x128>
    80005e88:	ffffb097          	auipc	ra,0xffffb
    80005e8c:	d20080e7          	jalr	-736(ra) # 80000ba8 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e90:	100017b7          	lui	a5,0x10001
    80005e94:	4398                	lw	a4,0(a5)
    80005e96:	2701                	sext.w	a4,a4
    80005e98:	747277b7          	lui	a5,0x74727
    80005e9c:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005ea0:	18f71c63          	bne	a4,a5,80006038 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005ea4:	100017b7          	lui	a5,0x10001
    80005ea8:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005eaa:	439c                	lw	a5,0(a5)
    80005eac:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005eae:	4709                	li	a4,2
    80005eb0:	18e79463          	bne	a5,a4,80006038 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005eb4:	100017b7          	lui	a5,0x10001
    80005eb8:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005eba:	439c                	lw	a5,0(a5)
    80005ebc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005ebe:	16e79d63          	bne	a5,a4,80006038 <virtio_disk_init+0x1cc>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005ec2:	100017b7          	lui	a5,0x10001
    80005ec6:	47d8                	lw	a4,12(a5)
    80005ec8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005eca:	554d47b7          	lui	a5,0x554d4
    80005ece:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005ed2:	16f71363          	bne	a4,a5,80006038 <virtio_disk_init+0x1cc>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ed6:	100017b7          	lui	a5,0x10001
    80005eda:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ede:	4705                	li	a4,1
    80005ee0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ee2:	470d                	li	a4,3
    80005ee4:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005ee6:	10001737          	lui	a4,0x10001
    80005eea:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005eec:	c7ffe737          	lui	a4,0xc7ffe
    80005ef0:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fda14f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005ef4:	8ef9                	and	a3,a3,a4
    80005ef6:	10001737          	lui	a4,0x10001
    80005efa:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005efc:	472d                	li	a4,11
    80005efe:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f00:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005f04:	439c                	lw	a5,0(a5)
    80005f06:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005f0a:	8ba1                	andi	a5,a5,8
    80005f0c:	12078e63          	beqz	a5,80006048 <virtio_disk_init+0x1dc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005f10:	100017b7          	lui	a5,0x10001
    80005f14:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005f18:	100017b7          	lui	a5,0x10001
    80005f1c:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005f20:	439c                	lw	a5,0(a5)
    80005f22:	2781                	sext.w	a5,a5
    80005f24:	12079a63          	bnez	a5,80006058 <virtio_disk_init+0x1ec>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005f28:	100017b7          	lui	a5,0x10001
    80005f2c:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005f30:	439c                	lw	a5,0(a5)
    80005f32:	2781                	sext.w	a5,a5
  if(max == 0)
    80005f34:	12078a63          	beqz	a5,80006068 <virtio_disk_init+0x1fc>
  if(max < NUM)
    80005f38:	471d                	li	a4,7
    80005f3a:	12f77f63          	bgeu	a4,a5,80006078 <virtio_disk_init+0x20c>
  disk.desc = kalloc();
    80005f3e:	ffffb097          	auipc	ra,0xffffb
    80005f42:	c0a080e7          	jalr	-1014(ra) # 80000b48 <kalloc>
    80005f46:	0001e497          	auipc	s1,0x1e
    80005f4a:	58a48493          	addi	s1,s1,1418 # 800244d0 <disk>
    80005f4e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005f50:	ffffb097          	auipc	ra,0xffffb
    80005f54:	bf8080e7          	jalr	-1032(ra) # 80000b48 <kalloc>
    80005f58:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005f5a:	ffffb097          	auipc	ra,0xffffb
    80005f5e:	bee080e7          	jalr	-1042(ra) # 80000b48 <kalloc>
    80005f62:	87aa                	mv	a5,a0
    80005f64:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005f66:	6088                	ld	a0,0(s1)
    80005f68:	12050063          	beqz	a0,80006088 <virtio_disk_init+0x21c>
    80005f6c:	0001e717          	auipc	a4,0x1e
    80005f70:	56c73703          	ld	a4,1388(a4) # 800244d8 <disk+0x8>
    80005f74:	10070a63          	beqz	a4,80006088 <virtio_disk_init+0x21c>
    80005f78:	10078863          	beqz	a5,80006088 <virtio_disk_init+0x21c>
  memset(disk.desc, 0, PGSIZE);
    80005f7c:	6605                	lui	a2,0x1
    80005f7e:	4581                	li	a1,0
    80005f80:	ffffb097          	auipc	ra,0xffffb
    80005f84:	db4080e7          	jalr	-588(ra) # 80000d34 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005f88:	0001e497          	auipc	s1,0x1e
    80005f8c:	54848493          	addi	s1,s1,1352 # 800244d0 <disk>
    80005f90:	6605                	lui	a2,0x1
    80005f92:	4581                	li	a1,0
    80005f94:	6488                	ld	a0,8(s1)
    80005f96:	ffffb097          	auipc	ra,0xffffb
    80005f9a:	d9e080e7          	jalr	-610(ra) # 80000d34 <memset>
  memset(disk.used, 0, PGSIZE);
    80005f9e:	6605                	lui	a2,0x1
    80005fa0:	4581                	li	a1,0
    80005fa2:	6888                	ld	a0,16(s1)
    80005fa4:	ffffb097          	auipc	ra,0xffffb
    80005fa8:	d90080e7          	jalr	-624(ra) # 80000d34 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005fac:	100017b7          	lui	a5,0x10001
    80005fb0:	4721                	li	a4,8
    80005fb2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005fb4:	4098                	lw	a4,0(s1)
    80005fb6:	100017b7          	lui	a5,0x10001
    80005fba:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005fbe:	40d8                	lw	a4,4(s1)
    80005fc0:	100017b7          	lui	a5,0x10001
    80005fc4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005fc8:	649c                	ld	a5,8(s1)
    80005fca:	0007869b          	sext.w	a3,a5
    80005fce:	10001737          	lui	a4,0x10001
    80005fd2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005fd6:	9781                	srai	a5,a5,0x20
    80005fd8:	10001737          	lui	a4,0x10001
    80005fdc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005fe0:	689c                	ld	a5,16(s1)
    80005fe2:	0007869b          	sext.w	a3,a5
    80005fe6:	10001737          	lui	a4,0x10001
    80005fea:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005fee:	9781                	srai	a5,a5,0x20
    80005ff0:	10001737          	lui	a4,0x10001
    80005ff4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005ff8:	10001737          	lui	a4,0x10001
    80005ffc:	4785                	li	a5,1
    80005ffe:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006000:	00f48c23          	sb	a5,24(s1)
    80006004:	00f48ca3          	sb	a5,25(s1)
    80006008:	00f48d23          	sb	a5,26(s1)
    8000600c:	00f48da3          	sb	a5,27(s1)
    80006010:	00f48e23          	sb	a5,28(s1)
    80006014:	00f48ea3          	sb	a5,29(s1)
    80006018:	00f48f23          	sb	a5,30(s1)
    8000601c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006020:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006024:	100017b7          	lui	a5,0x10001
    80006028:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000602c:	60e2                	ld	ra,24(sp)
    8000602e:	6442                	ld	s0,16(sp)
    80006030:	64a2                	ld	s1,8(sp)
    80006032:	6902                	ld	s2,0(sp)
    80006034:	6105                	addi	sp,sp,32
    80006036:	8082                	ret
    panic("could not find virtio disk");
    80006038:	00002517          	auipc	a0,0x2
    8000603c:	62050513          	addi	a0,a0,1568 # 80008658 <etext+0x658>
    80006040:	ffffa097          	auipc	ra,0xffffa
    80006044:	520080e7          	jalr	1312(ra) # 80000560 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006048:	00002517          	auipc	a0,0x2
    8000604c:	63050513          	addi	a0,a0,1584 # 80008678 <etext+0x678>
    80006050:	ffffa097          	auipc	ra,0xffffa
    80006054:	510080e7          	jalr	1296(ra) # 80000560 <panic>
    panic("virtio disk should not be ready");
    80006058:	00002517          	auipc	a0,0x2
    8000605c:	64050513          	addi	a0,a0,1600 # 80008698 <etext+0x698>
    80006060:	ffffa097          	auipc	ra,0xffffa
    80006064:	500080e7          	jalr	1280(ra) # 80000560 <panic>
    panic("virtio disk has no queue 0");
    80006068:	00002517          	auipc	a0,0x2
    8000606c:	65050513          	addi	a0,a0,1616 # 800086b8 <etext+0x6b8>
    80006070:	ffffa097          	auipc	ra,0xffffa
    80006074:	4f0080e7          	jalr	1264(ra) # 80000560 <panic>
    panic("virtio disk max queue too short");
    80006078:	00002517          	auipc	a0,0x2
    8000607c:	66050513          	addi	a0,a0,1632 # 800086d8 <etext+0x6d8>
    80006080:	ffffa097          	auipc	ra,0xffffa
    80006084:	4e0080e7          	jalr	1248(ra) # 80000560 <panic>
    panic("virtio disk kalloc");
    80006088:	00002517          	auipc	a0,0x2
    8000608c:	67050513          	addi	a0,a0,1648 # 800086f8 <etext+0x6f8>
    80006090:	ffffa097          	auipc	ra,0xffffa
    80006094:	4d0080e7          	jalr	1232(ra) # 80000560 <panic>

0000000080006098 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006098:	7159                	addi	sp,sp,-112
    8000609a:	f486                	sd	ra,104(sp)
    8000609c:	f0a2                	sd	s0,96(sp)
    8000609e:	eca6                	sd	s1,88(sp)
    800060a0:	e8ca                	sd	s2,80(sp)
    800060a2:	e4ce                	sd	s3,72(sp)
    800060a4:	e0d2                	sd	s4,64(sp)
    800060a6:	fc56                	sd	s5,56(sp)
    800060a8:	f85a                	sd	s6,48(sp)
    800060aa:	f45e                	sd	s7,40(sp)
    800060ac:	f062                	sd	s8,32(sp)
    800060ae:	ec66                	sd	s9,24(sp)
    800060b0:	1880                	addi	s0,sp,112
    800060b2:	8a2a                	mv	s4,a0
    800060b4:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800060b6:	00c52c83          	lw	s9,12(a0)
    800060ba:	001c9c9b          	slliw	s9,s9,0x1
    800060be:	1c82                	slli	s9,s9,0x20
    800060c0:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800060c4:	0001e517          	auipc	a0,0x1e
    800060c8:	53450513          	addi	a0,a0,1332 # 800245f8 <disk+0x128>
    800060cc:	ffffb097          	auipc	ra,0xffffb
    800060d0:	b6c080e7          	jalr	-1172(ra) # 80000c38 <acquire>
  for(int i = 0; i < 3; i++){
    800060d4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800060d6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800060d8:	0001eb17          	auipc	s6,0x1e
    800060dc:	3f8b0b13          	addi	s6,s6,1016 # 800244d0 <disk>
  for(int i = 0; i < 3; i++){
    800060e0:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800060e2:	0001ec17          	auipc	s8,0x1e
    800060e6:	516c0c13          	addi	s8,s8,1302 # 800245f8 <disk+0x128>
    800060ea:	a0ad                	j	80006154 <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    800060ec:	00fb0733          	add	a4,s6,a5
    800060f0:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800060f4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800060f6:	0207c563          	bltz	a5,80006120 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800060fa:	2905                	addiw	s2,s2,1
    800060fc:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800060fe:	05590f63          	beq	s2,s5,8000615c <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80006102:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006104:	0001e717          	auipc	a4,0x1e
    80006108:	3cc70713          	addi	a4,a4,972 # 800244d0 <disk>
    8000610c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000610e:	01874683          	lbu	a3,24(a4)
    80006112:	fee9                	bnez	a3,800060ec <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80006114:	2785                	addiw	a5,a5,1
    80006116:	0705                	addi	a4,a4,1
    80006118:	fe979be3          	bne	a5,s1,8000610e <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000611c:	57fd                	li	a5,-1
    8000611e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006120:	03205163          	blez	s2,80006142 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006124:	f9042503          	lw	a0,-112(s0)
    80006128:	00000097          	auipc	ra,0x0
    8000612c:	cc2080e7          	jalr	-830(ra) # 80005dea <free_desc>
      for(int j = 0; j < i; j++)
    80006130:	4785                	li	a5,1
    80006132:	0127d863          	bge	a5,s2,80006142 <virtio_disk_rw+0xaa>
        free_desc(idx[j]);
    80006136:	f9442503          	lw	a0,-108(s0)
    8000613a:	00000097          	auipc	ra,0x0
    8000613e:	cb0080e7          	jalr	-848(ra) # 80005dea <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006142:	85e2                	mv	a1,s8
    80006144:	0001e517          	auipc	a0,0x1e
    80006148:	3a450513          	addi	a0,a0,932 # 800244e8 <disk+0x18>
    8000614c:	ffffc097          	auipc	ra,0xffffc
    80006150:	fa8080e7          	jalr	-88(ra) # 800020f4 <sleep>
  for(int i = 0; i < 3; i++){
    80006154:	f9040613          	addi	a2,s0,-112
    80006158:	894e                	mv	s2,s3
    8000615a:	b765                	j	80006102 <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000615c:	f9042503          	lw	a0,-112(s0)
    80006160:	00451693          	slli	a3,a0,0x4

  if(write)
    80006164:	0001e797          	auipc	a5,0x1e
    80006168:	36c78793          	addi	a5,a5,876 # 800244d0 <disk>
    8000616c:	00a50713          	addi	a4,a0,10
    80006170:	0712                	slli	a4,a4,0x4
    80006172:	973e                	add	a4,a4,a5
    80006174:	01703633          	snez	a2,s7
    80006178:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000617a:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    8000617e:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006182:	6398                	ld	a4,0(a5)
    80006184:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006186:	0a868613          	addi	a2,a3,168
    8000618a:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000618c:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000618e:	6390                	ld	a2,0(a5)
    80006190:	00d605b3          	add	a1,a2,a3
    80006194:	4741                	li	a4,16
    80006196:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006198:	4805                	li	a6,1
    8000619a:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    8000619e:	f9442703          	lw	a4,-108(s0)
    800061a2:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800061a6:	0712                	slli	a4,a4,0x4
    800061a8:	963a                	add	a2,a2,a4
    800061aa:	058a0593          	addi	a1,s4,88
    800061ae:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800061b0:	0007b883          	ld	a7,0(a5)
    800061b4:	9746                	add	a4,a4,a7
    800061b6:	40000613          	li	a2,1024
    800061ba:	c710                	sw	a2,8(a4)
  if(write)
    800061bc:	001bb613          	seqz	a2,s7
    800061c0:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800061c4:	00166613          	ori	a2,a2,1
    800061c8:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800061cc:	f9842583          	lw	a1,-104(s0)
    800061d0:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800061d4:	00250613          	addi	a2,a0,2
    800061d8:	0612                	slli	a2,a2,0x4
    800061da:	963e                	add	a2,a2,a5
    800061dc:	577d                	li	a4,-1
    800061de:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800061e2:	0592                	slli	a1,a1,0x4
    800061e4:	98ae                	add	a7,a7,a1
    800061e6:	03068713          	addi	a4,a3,48
    800061ea:	973e                	add	a4,a4,a5
    800061ec:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800061f0:	6398                	ld	a4,0(a5)
    800061f2:	972e                	add	a4,a4,a1
    800061f4:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800061f8:	4689                	li	a3,2
    800061fa:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800061fe:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006202:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80006206:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000620a:	6794                	ld	a3,8(a5)
    8000620c:	0026d703          	lhu	a4,2(a3)
    80006210:	8b1d                	andi	a4,a4,7
    80006212:	0706                	slli	a4,a4,0x1
    80006214:	96ba                	add	a3,a3,a4
    80006216:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    8000621a:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000621e:	6798                	ld	a4,8(a5)
    80006220:	00275783          	lhu	a5,2(a4)
    80006224:	2785                	addiw	a5,a5,1
    80006226:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000622a:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000622e:	100017b7          	lui	a5,0x10001
    80006232:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006236:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    8000623a:	0001e917          	auipc	s2,0x1e
    8000623e:	3be90913          	addi	s2,s2,958 # 800245f8 <disk+0x128>
  while(b->disk == 1) {
    80006242:	4485                	li	s1,1
    80006244:	01079c63          	bne	a5,a6,8000625c <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006248:	85ca                	mv	a1,s2
    8000624a:	8552                	mv	a0,s4
    8000624c:	ffffc097          	auipc	ra,0xffffc
    80006250:	ea8080e7          	jalr	-344(ra) # 800020f4 <sleep>
  while(b->disk == 1) {
    80006254:	004a2783          	lw	a5,4(s4)
    80006258:	fe9788e3          	beq	a5,s1,80006248 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    8000625c:	f9042903          	lw	s2,-112(s0)
    80006260:	00290713          	addi	a4,s2,2
    80006264:	0712                	slli	a4,a4,0x4
    80006266:	0001e797          	auipc	a5,0x1e
    8000626a:	26a78793          	addi	a5,a5,618 # 800244d0 <disk>
    8000626e:	97ba                	add	a5,a5,a4
    80006270:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006274:	0001e997          	auipc	s3,0x1e
    80006278:	25c98993          	addi	s3,s3,604 # 800244d0 <disk>
    8000627c:	00491713          	slli	a4,s2,0x4
    80006280:	0009b783          	ld	a5,0(s3)
    80006284:	97ba                	add	a5,a5,a4
    80006286:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000628a:	854a                	mv	a0,s2
    8000628c:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006290:	00000097          	auipc	ra,0x0
    80006294:	b5a080e7          	jalr	-1190(ra) # 80005dea <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006298:	8885                	andi	s1,s1,1
    8000629a:	f0ed                	bnez	s1,8000627c <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000629c:	0001e517          	auipc	a0,0x1e
    800062a0:	35c50513          	addi	a0,a0,860 # 800245f8 <disk+0x128>
    800062a4:	ffffb097          	auipc	ra,0xffffb
    800062a8:	a48080e7          	jalr	-1464(ra) # 80000cec <release>
}
    800062ac:	70a6                	ld	ra,104(sp)
    800062ae:	7406                	ld	s0,96(sp)
    800062b0:	64e6                	ld	s1,88(sp)
    800062b2:	6946                	ld	s2,80(sp)
    800062b4:	69a6                	ld	s3,72(sp)
    800062b6:	6a06                	ld	s4,64(sp)
    800062b8:	7ae2                	ld	s5,56(sp)
    800062ba:	7b42                	ld	s6,48(sp)
    800062bc:	7ba2                	ld	s7,40(sp)
    800062be:	7c02                	ld	s8,32(sp)
    800062c0:	6ce2                	ld	s9,24(sp)
    800062c2:	6165                	addi	sp,sp,112
    800062c4:	8082                	ret

00000000800062c6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800062c6:	1101                	addi	sp,sp,-32
    800062c8:	ec06                	sd	ra,24(sp)
    800062ca:	e822                	sd	s0,16(sp)
    800062cc:	e426                	sd	s1,8(sp)
    800062ce:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800062d0:	0001e497          	auipc	s1,0x1e
    800062d4:	20048493          	addi	s1,s1,512 # 800244d0 <disk>
    800062d8:	0001e517          	auipc	a0,0x1e
    800062dc:	32050513          	addi	a0,a0,800 # 800245f8 <disk+0x128>
    800062e0:	ffffb097          	auipc	ra,0xffffb
    800062e4:	958080e7          	jalr	-1704(ra) # 80000c38 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800062e8:	100017b7          	lui	a5,0x10001
    800062ec:	53b8                	lw	a4,96(a5)
    800062ee:	8b0d                	andi	a4,a4,3
    800062f0:	100017b7          	lui	a5,0x10001
    800062f4:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    800062f6:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800062fa:	689c                	ld	a5,16(s1)
    800062fc:	0204d703          	lhu	a4,32(s1)
    80006300:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80006304:	04f70863          	beq	a4,a5,80006354 <virtio_disk_intr+0x8e>
    __sync_synchronize();
    80006308:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000630c:	6898                	ld	a4,16(s1)
    8000630e:	0204d783          	lhu	a5,32(s1)
    80006312:	8b9d                	andi	a5,a5,7
    80006314:	078e                	slli	a5,a5,0x3
    80006316:	97ba                	add	a5,a5,a4
    80006318:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000631a:	00278713          	addi	a4,a5,2
    8000631e:	0712                	slli	a4,a4,0x4
    80006320:	9726                	add	a4,a4,s1
    80006322:	01074703          	lbu	a4,16(a4)
    80006326:	e721                	bnez	a4,8000636e <virtio_disk_intr+0xa8>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006328:	0789                	addi	a5,a5,2
    8000632a:	0792                	slli	a5,a5,0x4
    8000632c:	97a6                	add	a5,a5,s1
    8000632e:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006330:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006334:	ffffc097          	auipc	ra,0xffffc
    80006338:	e24080e7          	jalr	-476(ra) # 80002158 <wakeup>

    disk.used_idx += 1;
    8000633c:	0204d783          	lhu	a5,32(s1)
    80006340:	2785                	addiw	a5,a5,1
    80006342:	17c2                	slli	a5,a5,0x30
    80006344:	93c1                	srli	a5,a5,0x30
    80006346:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000634a:	6898                	ld	a4,16(s1)
    8000634c:	00275703          	lhu	a4,2(a4)
    80006350:	faf71ce3          	bne	a4,a5,80006308 <virtio_disk_intr+0x42>
  }

  release(&disk.vdisk_lock);
    80006354:	0001e517          	auipc	a0,0x1e
    80006358:	2a450513          	addi	a0,a0,676 # 800245f8 <disk+0x128>
    8000635c:	ffffb097          	auipc	ra,0xffffb
    80006360:	990080e7          	jalr	-1648(ra) # 80000cec <release>
}
    80006364:	60e2                	ld	ra,24(sp)
    80006366:	6442                	ld	s0,16(sp)
    80006368:	64a2                	ld	s1,8(sp)
    8000636a:	6105                	addi	sp,sp,32
    8000636c:	8082                	ret
      panic("virtio_disk_intr status");
    8000636e:	00002517          	auipc	a0,0x2
    80006372:	3a250513          	addi	a0,a0,930 # 80008710 <etext+0x710>
    80006376:	ffffa097          	auipc	ra,0xffffa
    8000637a:	1ea080e7          	jalr	490(ra) # 80000560 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
