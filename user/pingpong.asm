
user/_pingpong:     formato del fichero elf64-littleriscv


Desensamblado de la sección .text:

0000000000000000 <main>:





int main(int argc, char *argv[]) {
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	0080                	addi	s0,sp,64
    int valid_args_count = (argc == 2);	

    if (!valid_args_count) {
  12:	4789                	li	a5,2
  14:	0af51c63          	bne	a0,a5,cc <main+0xcc>
        printf("ERROR: Cantidad invalida de argumentos\n");
        exit(0);
    }   
int ciclillo = atoi(argv[1]);
  18:	6588                	ld	a0,8(a1)
  1a:	00000097          	auipc	ra,0x0
  1e:	2b4080e7          	jalr	692(ra) # 2ce <atoi>
  22:	8a2a                	mv	s4,a0
    if (ciclillo  <= 0){
  24:	0ca05163          	blez	a0,e6 <main+0xe6>
      printf("ERROR: Se necesita un argumento >= 0 para el numero de rondas.\n");
      return 0;
    }

int ping_sem = get_channel_sem();
  28:	00000097          	auipc	ra,0x0
  2c:	460080e7          	jalr	1120(ra) # 488 <get_channel_sem>
  30:	89aa                	mv	s3,a0
int pong_sem = get_channel_sem();
  32:	00000097          	auipc	ra,0x0
  36:	456080e7          	jalr	1110(ra) # 488 <get_channel_sem>
  3a:	892a                	mv	s2,a0
sem_open(ping_sem, 1);
  3c:	4585                	li	a1,1
  3e:	854e                	mv	a0,s3
  40:	00000097          	auipc	ra,0x0
  44:	428080e7          	jalr	1064(ra) # 468 <sem_open>
sem_open(pong_sem,1);
  48:	4585                	li	a1,1
  4a:	854a                	mv	a0,s2
  4c:	00000097          	auipc	ra,0x0
  50:	41c080e7          	jalr	1052(ra) # 468 <sem_open>
sem_down(pong_sem);
  54:	854a                	mv	a0,s2
  56:	00000097          	auipc	ra,0x0
  5a:	42a080e7          	jalr	1066(ra) # 480 <sem_down>
int rc = fork();
  5e:	00000097          	auipc	ra,0x0
  62:	362080e7          	jalr	866(ra) # 3c0 <fork>
  66:	84aa                	mv	s1,a0
    if(rc<0){
  68:	08054863          	bltz	a0,f8 <main+0xf8>
        printf("Error en el fork\n");
        exit(0);
    }
    // while(ciclillo--){
    if(rc==0){ //Hijijto
  6c:	e15d                	bnez	a0,112 <main+0x112>
    for (int i = 0; i < ciclillo; i++) {
        sem_down(ping_sem); 
        printf("Ping\n");
  6e:	00001a97          	auipc	s5,0x1
  72:	922a8a93          	addi	s5,s5,-1758 # 990 <malloc+0x16e>
        sem_down(ping_sem); 
  76:	854e                	mv	a0,s3
  78:	00000097          	auipc	ra,0x0
  7c:	408080e7          	jalr	1032(ra) # 480 <sem_down>
        printf("Ping\n");
  80:	8556                	mv	a0,s5
  82:	00000097          	auipc	ra,0x0
  86:	6e8080e7          	jalr	1768(ra) # 76a <printf>
        sem_up(pong_sem); 
  8a:	854a                	mv	a0,s2
  8c:	00000097          	auipc	ra,0x0
  90:	3ec080e7          	jalr	1004(ra) # 478 <sem_up>
    for (int i = 0; i < ciclillo; i++) {
  94:	2485                	addiw	s1,s1,1
  96:	fe9a10e3          	bne	s4,s1,76 <main+0x76>
    }
    sem_down(ping_sem);
  9a:	854e                	mv	a0,s3
  9c:	00000097          	auipc	ra,0x0
  a0:	3e4080e7          	jalr	996(ra) # 480 <sem_down>
        sem_down(pong_sem); 
        printf("\tPong\n");
        sem_up(ping_sem); 
    }
    }
  sem_close(ping_sem);
  a4:	854e                	mv	a0,s3
  a6:	00000097          	auipc	ra,0x0
  aa:	3ca080e7          	jalr	970(ra) # 470 <sem_close>
  sem_close(pong_sem);
  ae:	854a                	mv	a0,s2
  b0:	00000097          	auipc	ra,0x0
  b4:	3c0080e7          	jalr	960(ra) # 470 <sem_close>

return 0;
}
  b8:	4501                	li	a0,0
  ba:	70e2                	ld	ra,56(sp)
  bc:	7442                	ld	s0,48(sp)
  be:	74a2                	ld	s1,40(sp)
  c0:	7902                	ld	s2,32(sp)
  c2:	69e2                	ld	s3,24(sp)
  c4:	6a42                	ld	s4,16(sp)
  c6:	6aa2                	ld	s5,8(sp)
  c8:	6121                	addi	sp,sp,64
  ca:	8082                	ret
        printf("ERROR: Cantidad invalida de argumentos\n");
  cc:	00001517          	auipc	a0,0x1
  d0:	84450513          	addi	a0,a0,-1980 # 910 <malloc+0xee>
  d4:	00000097          	auipc	ra,0x0
  d8:	696080e7          	jalr	1686(ra) # 76a <printf>
        exit(0);
  dc:	4501                	li	a0,0
  de:	00000097          	auipc	ra,0x0
  e2:	2ea080e7          	jalr	746(ra) # 3c8 <exit>
      printf("ERROR: Se necesita un argumento >= 0 para el numero de rondas.\n");
  e6:	00001517          	auipc	a0,0x1
  ea:	85250513          	addi	a0,a0,-1966 # 938 <malloc+0x116>
  ee:	00000097          	auipc	ra,0x0
  f2:	67c080e7          	jalr	1660(ra) # 76a <printf>
      return 0;
  f6:	b7c9                	j	b8 <main+0xb8>
        printf("Error en el fork\n");
  f8:	00001517          	auipc	a0,0x1
  fc:	88050513          	addi	a0,a0,-1920 # 978 <malloc+0x156>
 100:	00000097          	auipc	ra,0x0
 104:	66a080e7          	jalr	1642(ra) # 76a <printf>
        exit(0);
 108:	4501                	li	a0,0
 10a:	00000097          	auipc	ra,0x0
 10e:	2be080e7          	jalr	702(ra) # 3c8 <exit>
    for (int i = 0; i < ciclillo; i++) {
 112:	4481                	li	s1,0
        printf("\tPong\n");
 114:	00001a97          	auipc	s5,0x1
 118:	884a8a93          	addi	s5,s5,-1916 # 998 <malloc+0x176>
        sem_down(pong_sem); 
 11c:	854a                	mv	a0,s2
 11e:	00000097          	auipc	ra,0x0
 122:	362080e7          	jalr	866(ra) # 480 <sem_down>
        printf("\tPong\n");
 126:	8556                	mv	a0,s5
 128:	00000097          	auipc	ra,0x0
 12c:	642080e7          	jalr	1602(ra) # 76a <printf>
        sem_up(ping_sem); 
 130:	854e                	mv	a0,s3
 132:	00000097          	auipc	ra,0x0
 136:	346080e7          	jalr	838(ra) # 478 <sem_up>
    for (int i = 0; i < ciclillo; i++) {
 13a:	2485                	addiw	s1,s1,1
 13c:	fe9a10e3          	bne	s4,s1,11c <main+0x11c>
 140:	b795                	j	a4 <main+0xa4>

0000000000000142 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 142:	1141                	addi	sp,sp,-16
 144:	e406                	sd	ra,8(sp)
 146:	e022                	sd	s0,0(sp)
 148:	0800                	addi	s0,sp,16
  extern int main();
  main();
 14a:	00000097          	auipc	ra,0x0
 14e:	eb6080e7          	jalr	-330(ra) # 0 <main>
  exit(0);
 152:	4501                	li	a0,0
 154:	00000097          	auipc	ra,0x0
 158:	274080e7          	jalr	628(ra) # 3c8 <exit>

000000000000015c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 15c:	1141                	addi	sp,sp,-16
 15e:	e422                	sd	s0,8(sp)
 160:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 162:	87aa                	mv	a5,a0
 164:	0585                	addi	a1,a1,1
 166:	0785                	addi	a5,a5,1
 168:	fff5c703          	lbu	a4,-1(a1)
 16c:	fee78fa3          	sb	a4,-1(a5)
 170:	fb75                	bnez	a4,164 <strcpy+0x8>
    ;
  return os;
}
 172:	6422                	ld	s0,8(sp)
 174:	0141                	addi	sp,sp,16
 176:	8082                	ret

0000000000000178 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 178:	1141                	addi	sp,sp,-16
 17a:	e422                	sd	s0,8(sp)
 17c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 17e:	00054783          	lbu	a5,0(a0)
 182:	cb91                	beqz	a5,196 <strcmp+0x1e>
 184:	0005c703          	lbu	a4,0(a1)
 188:	00f71763          	bne	a4,a5,196 <strcmp+0x1e>
    p++, q++;
 18c:	0505                	addi	a0,a0,1
 18e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 190:	00054783          	lbu	a5,0(a0)
 194:	fbe5                	bnez	a5,184 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 196:	0005c503          	lbu	a0,0(a1)
}
 19a:	40a7853b          	subw	a0,a5,a0
 19e:	6422                	ld	s0,8(sp)
 1a0:	0141                	addi	sp,sp,16
 1a2:	8082                	ret

00000000000001a4 <strlen>:

uint
strlen(const char *s)
{
 1a4:	1141                	addi	sp,sp,-16
 1a6:	e422                	sd	s0,8(sp)
 1a8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1aa:	00054783          	lbu	a5,0(a0)
 1ae:	cf91                	beqz	a5,1ca <strlen+0x26>
 1b0:	0505                	addi	a0,a0,1
 1b2:	87aa                	mv	a5,a0
 1b4:	4685                	li	a3,1
 1b6:	9e89                	subw	a3,a3,a0
 1b8:	00f6853b          	addw	a0,a3,a5
 1bc:	0785                	addi	a5,a5,1
 1be:	fff7c703          	lbu	a4,-1(a5)
 1c2:	fb7d                	bnez	a4,1b8 <strlen+0x14>
    ;
  return n;
}
 1c4:	6422                	ld	s0,8(sp)
 1c6:	0141                	addi	sp,sp,16
 1c8:	8082                	ret
  for(n = 0; s[n]; n++)
 1ca:	4501                	li	a0,0
 1cc:	bfe5                	j	1c4 <strlen+0x20>

00000000000001ce <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ce:	1141                	addi	sp,sp,-16
 1d0:	e422                	sd	s0,8(sp)
 1d2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1d4:	ca19                	beqz	a2,1ea <memset+0x1c>
 1d6:	87aa                	mv	a5,a0
 1d8:	1602                	slli	a2,a2,0x20
 1da:	9201                	srli	a2,a2,0x20
 1dc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1e0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1e4:	0785                	addi	a5,a5,1
 1e6:	fee79de3          	bne	a5,a4,1e0 <memset+0x12>
  }
  return dst;
}
 1ea:	6422                	ld	s0,8(sp)
 1ec:	0141                	addi	sp,sp,16
 1ee:	8082                	ret

00000000000001f0 <strchr>:

char*
strchr(const char *s, char c)
{
 1f0:	1141                	addi	sp,sp,-16
 1f2:	e422                	sd	s0,8(sp)
 1f4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1f6:	00054783          	lbu	a5,0(a0)
 1fa:	cb99                	beqz	a5,210 <strchr+0x20>
    if(*s == c)
 1fc:	00f58763          	beq	a1,a5,20a <strchr+0x1a>
  for(; *s; s++)
 200:	0505                	addi	a0,a0,1
 202:	00054783          	lbu	a5,0(a0)
 206:	fbfd                	bnez	a5,1fc <strchr+0xc>
      return (char*)s;
  return 0;
 208:	4501                	li	a0,0
}
 20a:	6422                	ld	s0,8(sp)
 20c:	0141                	addi	sp,sp,16
 20e:	8082                	ret
  return 0;
 210:	4501                	li	a0,0
 212:	bfe5                	j	20a <strchr+0x1a>

0000000000000214 <gets>:

char*
gets(char *buf, int max)
{
 214:	711d                	addi	sp,sp,-96
 216:	ec86                	sd	ra,88(sp)
 218:	e8a2                	sd	s0,80(sp)
 21a:	e4a6                	sd	s1,72(sp)
 21c:	e0ca                	sd	s2,64(sp)
 21e:	fc4e                	sd	s3,56(sp)
 220:	f852                	sd	s4,48(sp)
 222:	f456                	sd	s5,40(sp)
 224:	f05a                	sd	s6,32(sp)
 226:	ec5e                	sd	s7,24(sp)
 228:	1080                	addi	s0,sp,96
 22a:	8baa                	mv	s7,a0
 22c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 22e:	892a                	mv	s2,a0
 230:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 232:	4aa9                	li	s5,10
 234:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 236:	89a6                	mv	s3,s1
 238:	2485                	addiw	s1,s1,1
 23a:	0344d863          	bge	s1,s4,26a <gets+0x56>
    cc = read(0, &c, 1);
 23e:	4605                	li	a2,1
 240:	faf40593          	addi	a1,s0,-81
 244:	4501                	li	a0,0
 246:	00000097          	auipc	ra,0x0
 24a:	19a080e7          	jalr	410(ra) # 3e0 <read>
    if(cc < 1)
 24e:	00a05e63          	blez	a0,26a <gets+0x56>
    buf[i++] = c;
 252:	faf44783          	lbu	a5,-81(s0)
 256:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 25a:	01578763          	beq	a5,s5,268 <gets+0x54>
 25e:	0905                	addi	s2,s2,1
 260:	fd679be3          	bne	a5,s6,236 <gets+0x22>
  for(i=0; i+1 < max; ){
 264:	89a6                	mv	s3,s1
 266:	a011                	j	26a <gets+0x56>
 268:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 26a:	99de                	add	s3,s3,s7
 26c:	00098023          	sb	zero,0(s3)
  return buf;
}
 270:	855e                	mv	a0,s7
 272:	60e6                	ld	ra,88(sp)
 274:	6446                	ld	s0,80(sp)
 276:	64a6                	ld	s1,72(sp)
 278:	6906                	ld	s2,64(sp)
 27a:	79e2                	ld	s3,56(sp)
 27c:	7a42                	ld	s4,48(sp)
 27e:	7aa2                	ld	s5,40(sp)
 280:	7b02                	ld	s6,32(sp)
 282:	6be2                	ld	s7,24(sp)
 284:	6125                	addi	sp,sp,96
 286:	8082                	ret

0000000000000288 <stat>:

int
stat(const char *n, struct stat *st)
{
 288:	1101                	addi	sp,sp,-32
 28a:	ec06                	sd	ra,24(sp)
 28c:	e822                	sd	s0,16(sp)
 28e:	e426                	sd	s1,8(sp)
 290:	e04a                	sd	s2,0(sp)
 292:	1000                	addi	s0,sp,32
 294:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 296:	4581                	li	a1,0
 298:	00000097          	auipc	ra,0x0
 29c:	170080e7          	jalr	368(ra) # 408 <open>
  if(fd < 0)
 2a0:	02054563          	bltz	a0,2ca <stat+0x42>
 2a4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2a6:	85ca                	mv	a1,s2
 2a8:	00000097          	auipc	ra,0x0
 2ac:	178080e7          	jalr	376(ra) # 420 <fstat>
 2b0:	892a                	mv	s2,a0
  close(fd);
 2b2:	8526                	mv	a0,s1
 2b4:	00000097          	auipc	ra,0x0
 2b8:	13c080e7          	jalr	316(ra) # 3f0 <close>
  return r;
}
 2bc:	854a                	mv	a0,s2
 2be:	60e2                	ld	ra,24(sp)
 2c0:	6442                	ld	s0,16(sp)
 2c2:	64a2                	ld	s1,8(sp)
 2c4:	6902                	ld	s2,0(sp)
 2c6:	6105                	addi	sp,sp,32
 2c8:	8082                	ret
    return -1;
 2ca:	597d                	li	s2,-1
 2cc:	bfc5                	j	2bc <stat+0x34>

00000000000002ce <atoi>:

int
atoi(const char *s)
{
 2ce:	1141                	addi	sp,sp,-16
 2d0:	e422                	sd	s0,8(sp)
 2d2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2d4:	00054683          	lbu	a3,0(a0)
 2d8:	fd06879b          	addiw	a5,a3,-48
 2dc:	0ff7f793          	zext.b	a5,a5
 2e0:	4625                	li	a2,9
 2e2:	02f66863          	bltu	a2,a5,312 <atoi+0x44>
 2e6:	872a                	mv	a4,a0
  n = 0;
 2e8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2ea:	0705                	addi	a4,a4,1
 2ec:	0025179b          	slliw	a5,a0,0x2
 2f0:	9fa9                	addw	a5,a5,a0
 2f2:	0017979b          	slliw	a5,a5,0x1
 2f6:	9fb5                	addw	a5,a5,a3
 2f8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2fc:	00074683          	lbu	a3,0(a4)
 300:	fd06879b          	addiw	a5,a3,-48
 304:	0ff7f793          	zext.b	a5,a5
 308:	fef671e3          	bgeu	a2,a5,2ea <atoi+0x1c>
  return n;
}
 30c:	6422                	ld	s0,8(sp)
 30e:	0141                	addi	sp,sp,16
 310:	8082                	ret
  n = 0;
 312:	4501                	li	a0,0
 314:	bfe5                	j	30c <atoi+0x3e>

0000000000000316 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 316:	1141                	addi	sp,sp,-16
 318:	e422                	sd	s0,8(sp)
 31a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 31c:	02b57463          	bgeu	a0,a1,344 <memmove+0x2e>
    while(n-- > 0)
 320:	00c05f63          	blez	a2,33e <memmove+0x28>
 324:	1602                	slli	a2,a2,0x20
 326:	9201                	srli	a2,a2,0x20
 328:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 32c:	872a                	mv	a4,a0
      *dst++ = *src++;
 32e:	0585                	addi	a1,a1,1
 330:	0705                	addi	a4,a4,1
 332:	fff5c683          	lbu	a3,-1(a1)
 336:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 33a:	fee79ae3          	bne	a5,a4,32e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 33e:	6422                	ld	s0,8(sp)
 340:	0141                	addi	sp,sp,16
 342:	8082                	ret
    dst += n;
 344:	00c50733          	add	a4,a0,a2
    src += n;
 348:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 34a:	fec05ae3          	blez	a2,33e <memmove+0x28>
 34e:	fff6079b          	addiw	a5,a2,-1
 352:	1782                	slli	a5,a5,0x20
 354:	9381                	srli	a5,a5,0x20
 356:	fff7c793          	not	a5,a5
 35a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 35c:	15fd                	addi	a1,a1,-1
 35e:	177d                	addi	a4,a4,-1
 360:	0005c683          	lbu	a3,0(a1)
 364:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 368:	fee79ae3          	bne	a5,a4,35c <memmove+0x46>
 36c:	bfc9                	j	33e <memmove+0x28>

000000000000036e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 36e:	1141                	addi	sp,sp,-16
 370:	e422                	sd	s0,8(sp)
 372:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 374:	ca05                	beqz	a2,3a4 <memcmp+0x36>
 376:	fff6069b          	addiw	a3,a2,-1
 37a:	1682                	slli	a3,a3,0x20
 37c:	9281                	srli	a3,a3,0x20
 37e:	0685                	addi	a3,a3,1
 380:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 382:	00054783          	lbu	a5,0(a0)
 386:	0005c703          	lbu	a4,0(a1)
 38a:	00e79863          	bne	a5,a4,39a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 38e:	0505                	addi	a0,a0,1
    p2++;
 390:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 392:	fed518e3          	bne	a0,a3,382 <memcmp+0x14>
  }
  return 0;
 396:	4501                	li	a0,0
 398:	a019                	j	39e <memcmp+0x30>
      return *p1 - *p2;
 39a:	40e7853b          	subw	a0,a5,a4
}
 39e:	6422                	ld	s0,8(sp)
 3a0:	0141                	addi	sp,sp,16
 3a2:	8082                	ret
  return 0;
 3a4:	4501                	li	a0,0
 3a6:	bfe5                	j	39e <memcmp+0x30>

00000000000003a8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3a8:	1141                	addi	sp,sp,-16
 3aa:	e406                	sd	ra,8(sp)
 3ac:	e022                	sd	s0,0(sp)
 3ae:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3b0:	00000097          	auipc	ra,0x0
 3b4:	f66080e7          	jalr	-154(ra) # 316 <memmove>
}
 3b8:	60a2                	ld	ra,8(sp)
 3ba:	6402                	ld	s0,0(sp)
 3bc:	0141                	addi	sp,sp,16
 3be:	8082                	ret

00000000000003c0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3c0:	4885                	li	a7,1
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3c8:	4889                	li	a7,2
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3d0:	488d                	li	a7,3
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3d8:	4891                	li	a7,4
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <read>:
.global read
read:
 li a7, SYS_read
 3e0:	4895                	li	a7,5
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <write>:
.global write
write:
 li a7, SYS_write
 3e8:	48c1                	li	a7,16
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <close>:
.global close
close:
 li a7, SYS_close
 3f0:	48d5                	li	a7,21
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3f8:	4899                	li	a7,6
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <exec>:
.global exec
exec:
 li a7, SYS_exec
 400:	489d                	li	a7,7
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <open>:
.global open
open:
 li a7, SYS_open
 408:	48bd                	li	a7,15
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 410:	48c5                	li	a7,17
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 418:	48c9                	li	a7,18
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 420:	48a1                	li	a7,8
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <link>:
.global link
link:
 li a7, SYS_link
 428:	48cd                	li	a7,19
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 430:	48d1                	li	a7,20
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 438:	48a5                	li	a7,9
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <dup>:
.global dup
dup:
 li a7, SYS_dup
 440:	48a9                	li	a7,10
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 448:	48ad                	li	a7,11
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 450:	48b1                	li	a7,12
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 458:	48b5                	li	a7,13
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 460:	48b9                	li	a7,14
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <sem_open>:
.global sem_open
sem_open:
 li a7, SYS_sem_open
 468:	48d9                	li	a7,22
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <sem_close>:
.global sem_close
sem_close:
 li a7, SYS_sem_close
 470:	48dd                	li	a7,23
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <sem_up>:
.global sem_up
sem_up:
 li a7, SYS_sem_up
 478:	48e1                	li	a7,24
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <sem_down>:
.global sem_down
sem_down:
 li a7, SYS_sem_down
 480:	48e5                	li	a7,25
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <get_channel_sem>:
.global get_channel_sem
get_channel_sem:
 li a7, SYS_get_channel_sem
 488:	48e9                	li	a7,26
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 490:	1101                	addi	sp,sp,-32
 492:	ec06                	sd	ra,24(sp)
 494:	e822                	sd	s0,16(sp)
 496:	1000                	addi	s0,sp,32
 498:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 49c:	4605                	li	a2,1
 49e:	fef40593          	addi	a1,s0,-17
 4a2:	00000097          	auipc	ra,0x0
 4a6:	f46080e7          	jalr	-186(ra) # 3e8 <write>
}
 4aa:	60e2                	ld	ra,24(sp)
 4ac:	6442                	ld	s0,16(sp)
 4ae:	6105                	addi	sp,sp,32
 4b0:	8082                	ret

00000000000004b2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4b2:	7139                	addi	sp,sp,-64
 4b4:	fc06                	sd	ra,56(sp)
 4b6:	f822                	sd	s0,48(sp)
 4b8:	f426                	sd	s1,40(sp)
 4ba:	f04a                	sd	s2,32(sp)
 4bc:	ec4e                	sd	s3,24(sp)
 4be:	0080                	addi	s0,sp,64
 4c0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4c2:	c299                	beqz	a3,4c8 <printint+0x16>
 4c4:	0805c963          	bltz	a1,556 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4c8:	2581                	sext.w	a1,a1
  neg = 0;
 4ca:	4881                	li	a7,0
 4cc:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4d0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4d2:	2601                	sext.w	a2,a2
 4d4:	00000517          	auipc	a0,0x0
 4d8:	52c50513          	addi	a0,a0,1324 # a00 <digits>
 4dc:	883a                	mv	a6,a4
 4de:	2705                	addiw	a4,a4,1
 4e0:	02c5f7bb          	remuw	a5,a1,a2
 4e4:	1782                	slli	a5,a5,0x20
 4e6:	9381                	srli	a5,a5,0x20
 4e8:	97aa                	add	a5,a5,a0
 4ea:	0007c783          	lbu	a5,0(a5)
 4ee:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4f2:	0005879b          	sext.w	a5,a1
 4f6:	02c5d5bb          	divuw	a1,a1,a2
 4fa:	0685                	addi	a3,a3,1
 4fc:	fec7f0e3          	bgeu	a5,a2,4dc <printint+0x2a>
  if(neg)
 500:	00088c63          	beqz	a7,518 <printint+0x66>
    buf[i++] = '-';
 504:	fd070793          	addi	a5,a4,-48
 508:	00878733          	add	a4,a5,s0
 50c:	02d00793          	li	a5,45
 510:	fef70823          	sb	a5,-16(a4)
 514:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 518:	02e05863          	blez	a4,548 <printint+0x96>
 51c:	fc040793          	addi	a5,s0,-64
 520:	00e78933          	add	s2,a5,a4
 524:	fff78993          	addi	s3,a5,-1
 528:	99ba                	add	s3,s3,a4
 52a:	377d                	addiw	a4,a4,-1
 52c:	1702                	slli	a4,a4,0x20
 52e:	9301                	srli	a4,a4,0x20
 530:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 534:	fff94583          	lbu	a1,-1(s2)
 538:	8526                	mv	a0,s1
 53a:	00000097          	auipc	ra,0x0
 53e:	f56080e7          	jalr	-170(ra) # 490 <putc>
  while(--i >= 0)
 542:	197d                	addi	s2,s2,-1
 544:	ff3918e3          	bne	s2,s3,534 <printint+0x82>
}
 548:	70e2                	ld	ra,56(sp)
 54a:	7442                	ld	s0,48(sp)
 54c:	74a2                	ld	s1,40(sp)
 54e:	7902                	ld	s2,32(sp)
 550:	69e2                	ld	s3,24(sp)
 552:	6121                	addi	sp,sp,64
 554:	8082                	ret
    x = -xx;
 556:	40b005bb          	negw	a1,a1
    neg = 1;
 55a:	4885                	li	a7,1
    x = -xx;
 55c:	bf85                	j	4cc <printint+0x1a>

000000000000055e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 55e:	7119                	addi	sp,sp,-128
 560:	fc86                	sd	ra,120(sp)
 562:	f8a2                	sd	s0,112(sp)
 564:	f4a6                	sd	s1,104(sp)
 566:	f0ca                	sd	s2,96(sp)
 568:	ecce                	sd	s3,88(sp)
 56a:	e8d2                	sd	s4,80(sp)
 56c:	e4d6                	sd	s5,72(sp)
 56e:	e0da                	sd	s6,64(sp)
 570:	fc5e                	sd	s7,56(sp)
 572:	f862                	sd	s8,48(sp)
 574:	f466                	sd	s9,40(sp)
 576:	f06a                	sd	s10,32(sp)
 578:	ec6e                	sd	s11,24(sp)
 57a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 57c:	0005c903          	lbu	s2,0(a1)
 580:	18090f63          	beqz	s2,71e <vprintf+0x1c0>
 584:	8aaa                	mv	s5,a0
 586:	8b32                	mv	s6,a2
 588:	00158493          	addi	s1,a1,1
  state = 0;
 58c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 58e:	02500a13          	li	s4,37
 592:	4c55                	li	s8,21
 594:	00000c97          	auipc	s9,0x0
 598:	414c8c93          	addi	s9,s9,1044 # 9a8 <malloc+0x186>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 59c:	02800d93          	li	s11,40
  putc(fd, 'x');
 5a0:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5a2:	00000b97          	auipc	s7,0x0
 5a6:	45eb8b93          	addi	s7,s7,1118 # a00 <digits>
 5aa:	a839                	j	5c8 <vprintf+0x6a>
        putc(fd, c);
 5ac:	85ca                	mv	a1,s2
 5ae:	8556                	mv	a0,s5
 5b0:	00000097          	auipc	ra,0x0
 5b4:	ee0080e7          	jalr	-288(ra) # 490 <putc>
 5b8:	a019                	j	5be <vprintf+0x60>
    } else if(state == '%'){
 5ba:	01498d63          	beq	s3,s4,5d4 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 5be:	0485                	addi	s1,s1,1
 5c0:	fff4c903          	lbu	s2,-1(s1)
 5c4:	14090d63          	beqz	s2,71e <vprintf+0x1c0>
    if(state == 0){
 5c8:	fe0999e3          	bnez	s3,5ba <vprintf+0x5c>
      if(c == '%'){
 5cc:	ff4910e3          	bne	s2,s4,5ac <vprintf+0x4e>
        state = '%';
 5d0:	89d2                	mv	s3,s4
 5d2:	b7f5                	j	5be <vprintf+0x60>
      if(c == 'd'){
 5d4:	11490c63          	beq	s2,s4,6ec <vprintf+0x18e>
 5d8:	f9d9079b          	addiw	a5,s2,-99
 5dc:	0ff7f793          	zext.b	a5,a5
 5e0:	10fc6e63          	bltu	s8,a5,6fc <vprintf+0x19e>
 5e4:	f9d9079b          	addiw	a5,s2,-99
 5e8:	0ff7f713          	zext.b	a4,a5
 5ec:	10ec6863          	bltu	s8,a4,6fc <vprintf+0x19e>
 5f0:	00271793          	slli	a5,a4,0x2
 5f4:	97e6                	add	a5,a5,s9
 5f6:	439c                	lw	a5,0(a5)
 5f8:	97e6                	add	a5,a5,s9
 5fa:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5fc:	008b0913          	addi	s2,s6,8
 600:	4685                	li	a3,1
 602:	4629                	li	a2,10
 604:	000b2583          	lw	a1,0(s6)
 608:	8556                	mv	a0,s5
 60a:	00000097          	auipc	ra,0x0
 60e:	ea8080e7          	jalr	-344(ra) # 4b2 <printint>
 612:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 614:	4981                	li	s3,0
 616:	b765                	j	5be <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 618:	008b0913          	addi	s2,s6,8
 61c:	4681                	li	a3,0
 61e:	4629                	li	a2,10
 620:	000b2583          	lw	a1,0(s6)
 624:	8556                	mv	a0,s5
 626:	00000097          	auipc	ra,0x0
 62a:	e8c080e7          	jalr	-372(ra) # 4b2 <printint>
 62e:	8b4a                	mv	s6,s2
      state = 0;
 630:	4981                	li	s3,0
 632:	b771                	j	5be <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 634:	008b0913          	addi	s2,s6,8
 638:	4681                	li	a3,0
 63a:	866a                	mv	a2,s10
 63c:	000b2583          	lw	a1,0(s6)
 640:	8556                	mv	a0,s5
 642:	00000097          	auipc	ra,0x0
 646:	e70080e7          	jalr	-400(ra) # 4b2 <printint>
 64a:	8b4a                	mv	s6,s2
      state = 0;
 64c:	4981                	li	s3,0
 64e:	bf85                	j	5be <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 650:	008b0793          	addi	a5,s6,8
 654:	f8f43423          	sd	a5,-120(s0)
 658:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 65c:	03000593          	li	a1,48
 660:	8556                	mv	a0,s5
 662:	00000097          	auipc	ra,0x0
 666:	e2e080e7          	jalr	-466(ra) # 490 <putc>
  putc(fd, 'x');
 66a:	07800593          	li	a1,120
 66e:	8556                	mv	a0,s5
 670:	00000097          	auipc	ra,0x0
 674:	e20080e7          	jalr	-480(ra) # 490 <putc>
 678:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 67a:	03c9d793          	srli	a5,s3,0x3c
 67e:	97de                	add	a5,a5,s7
 680:	0007c583          	lbu	a1,0(a5)
 684:	8556                	mv	a0,s5
 686:	00000097          	auipc	ra,0x0
 68a:	e0a080e7          	jalr	-502(ra) # 490 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 68e:	0992                	slli	s3,s3,0x4
 690:	397d                	addiw	s2,s2,-1
 692:	fe0914e3          	bnez	s2,67a <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 696:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 69a:	4981                	li	s3,0
 69c:	b70d                	j	5be <vprintf+0x60>
        s = va_arg(ap, char*);
 69e:	008b0913          	addi	s2,s6,8
 6a2:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 6a6:	02098163          	beqz	s3,6c8 <vprintf+0x16a>
        while(*s != 0){
 6aa:	0009c583          	lbu	a1,0(s3)
 6ae:	c5ad                	beqz	a1,718 <vprintf+0x1ba>
          putc(fd, *s);
 6b0:	8556                	mv	a0,s5
 6b2:	00000097          	auipc	ra,0x0
 6b6:	dde080e7          	jalr	-546(ra) # 490 <putc>
          s++;
 6ba:	0985                	addi	s3,s3,1
        while(*s != 0){
 6bc:	0009c583          	lbu	a1,0(s3)
 6c0:	f9e5                	bnez	a1,6b0 <vprintf+0x152>
        s = va_arg(ap, char*);
 6c2:	8b4a                	mv	s6,s2
      state = 0;
 6c4:	4981                	li	s3,0
 6c6:	bde5                	j	5be <vprintf+0x60>
          s = "(null)";
 6c8:	00000997          	auipc	s3,0x0
 6cc:	2d898993          	addi	s3,s3,728 # 9a0 <malloc+0x17e>
        while(*s != 0){
 6d0:	85ee                	mv	a1,s11
 6d2:	bff9                	j	6b0 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 6d4:	008b0913          	addi	s2,s6,8
 6d8:	000b4583          	lbu	a1,0(s6)
 6dc:	8556                	mv	a0,s5
 6de:	00000097          	auipc	ra,0x0
 6e2:	db2080e7          	jalr	-590(ra) # 490 <putc>
 6e6:	8b4a                	mv	s6,s2
      state = 0;
 6e8:	4981                	li	s3,0
 6ea:	bdd1                	j	5be <vprintf+0x60>
        putc(fd, c);
 6ec:	85d2                	mv	a1,s4
 6ee:	8556                	mv	a0,s5
 6f0:	00000097          	auipc	ra,0x0
 6f4:	da0080e7          	jalr	-608(ra) # 490 <putc>
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	b5d1                	j	5be <vprintf+0x60>
        putc(fd, '%');
 6fc:	85d2                	mv	a1,s4
 6fe:	8556                	mv	a0,s5
 700:	00000097          	auipc	ra,0x0
 704:	d90080e7          	jalr	-624(ra) # 490 <putc>
        putc(fd, c);
 708:	85ca                	mv	a1,s2
 70a:	8556                	mv	a0,s5
 70c:	00000097          	auipc	ra,0x0
 710:	d84080e7          	jalr	-636(ra) # 490 <putc>
      state = 0;
 714:	4981                	li	s3,0
 716:	b565                	j	5be <vprintf+0x60>
        s = va_arg(ap, char*);
 718:	8b4a                	mv	s6,s2
      state = 0;
 71a:	4981                	li	s3,0
 71c:	b54d                	j	5be <vprintf+0x60>
    }
  }
}
 71e:	70e6                	ld	ra,120(sp)
 720:	7446                	ld	s0,112(sp)
 722:	74a6                	ld	s1,104(sp)
 724:	7906                	ld	s2,96(sp)
 726:	69e6                	ld	s3,88(sp)
 728:	6a46                	ld	s4,80(sp)
 72a:	6aa6                	ld	s5,72(sp)
 72c:	6b06                	ld	s6,64(sp)
 72e:	7be2                	ld	s7,56(sp)
 730:	7c42                	ld	s8,48(sp)
 732:	7ca2                	ld	s9,40(sp)
 734:	7d02                	ld	s10,32(sp)
 736:	6de2                	ld	s11,24(sp)
 738:	6109                	addi	sp,sp,128
 73a:	8082                	ret

000000000000073c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 73c:	715d                	addi	sp,sp,-80
 73e:	ec06                	sd	ra,24(sp)
 740:	e822                	sd	s0,16(sp)
 742:	1000                	addi	s0,sp,32
 744:	e010                	sd	a2,0(s0)
 746:	e414                	sd	a3,8(s0)
 748:	e818                	sd	a4,16(s0)
 74a:	ec1c                	sd	a5,24(s0)
 74c:	03043023          	sd	a6,32(s0)
 750:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 754:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 758:	8622                	mv	a2,s0
 75a:	00000097          	auipc	ra,0x0
 75e:	e04080e7          	jalr	-508(ra) # 55e <vprintf>
}
 762:	60e2                	ld	ra,24(sp)
 764:	6442                	ld	s0,16(sp)
 766:	6161                	addi	sp,sp,80
 768:	8082                	ret

000000000000076a <printf>:

void
printf(const char *fmt, ...)
{
 76a:	711d                	addi	sp,sp,-96
 76c:	ec06                	sd	ra,24(sp)
 76e:	e822                	sd	s0,16(sp)
 770:	1000                	addi	s0,sp,32
 772:	e40c                	sd	a1,8(s0)
 774:	e810                	sd	a2,16(s0)
 776:	ec14                	sd	a3,24(s0)
 778:	f018                	sd	a4,32(s0)
 77a:	f41c                	sd	a5,40(s0)
 77c:	03043823          	sd	a6,48(s0)
 780:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 784:	00840613          	addi	a2,s0,8
 788:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 78c:	85aa                	mv	a1,a0
 78e:	4505                	li	a0,1
 790:	00000097          	auipc	ra,0x0
 794:	dce080e7          	jalr	-562(ra) # 55e <vprintf>
}
 798:	60e2                	ld	ra,24(sp)
 79a:	6442                	ld	s0,16(sp)
 79c:	6125                	addi	sp,sp,96
 79e:	8082                	ret

00000000000007a0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7a0:	1141                	addi	sp,sp,-16
 7a2:	e422                	sd	s0,8(sp)
 7a4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7a6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7aa:	00001797          	auipc	a5,0x1
 7ae:	8567b783          	ld	a5,-1962(a5) # 1000 <freep>
 7b2:	a02d                	j	7dc <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7b4:	4618                	lw	a4,8(a2)
 7b6:	9f2d                	addw	a4,a4,a1
 7b8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7bc:	6398                	ld	a4,0(a5)
 7be:	6310                	ld	a2,0(a4)
 7c0:	a83d                	j	7fe <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7c2:	ff852703          	lw	a4,-8(a0)
 7c6:	9f31                	addw	a4,a4,a2
 7c8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7ca:	ff053683          	ld	a3,-16(a0)
 7ce:	a091                	j	812 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d0:	6398                	ld	a4,0(a5)
 7d2:	00e7e463          	bltu	a5,a4,7da <free+0x3a>
 7d6:	00e6ea63          	bltu	a3,a4,7ea <free+0x4a>
{
 7da:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7dc:	fed7fae3          	bgeu	a5,a3,7d0 <free+0x30>
 7e0:	6398                	ld	a4,0(a5)
 7e2:	00e6e463          	bltu	a3,a4,7ea <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e6:	fee7eae3          	bltu	a5,a4,7da <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7ea:	ff852583          	lw	a1,-8(a0)
 7ee:	6390                	ld	a2,0(a5)
 7f0:	02059813          	slli	a6,a1,0x20
 7f4:	01c85713          	srli	a4,a6,0x1c
 7f8:	9736                	add	a4,a4,a3
 7fa:	fae60de3          	beq	a2,a4,7b4 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7fe:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 802:	4790                	lw	a2,8(a5)
 804:	02061593          	slli	a1,a2,0x20
 808:	01c5d713          	srli	a4,a1,0x1c
 80c:	973e                	add	a4,a4,a5
 80e:	fae68ae3          	beq	a3,a4,7c2 <free+0x22>
    p->s.ptr = bp->s.ptr;
 812:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 814:	00000717          	auipc	a4,0x0
 818:	7ef73623          	sd	a5,2028(a4) # 1000 <freep>
}
 81c:	6422                	ld	s0,8(sp)
 81e:	0141                	addi	sp,sp,16
 820:	8082                	ret

0000000000000822 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 822:	7139                	addi	sp,sp,-64
 824:	fc06                	sd	ra,56(sp)
 826:	f822                	sd	s0,48(sp)
 828:	f426                	sd	s1,40(sp)
 82a:	f04a                	sd	s2,32(sp)
 82c:	ec4e                	sd	s3,24(sp)
 82e:	e852                	sd	s4,16(sp)
 830:	e456                	sd	s5,8(sp)
 832:	e05a                	sd	s6,0(sp)
 834:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 836:	02051493          	slli	s1,a0,0x20
 83a:	9081                	srli	s1,s1,0x20
 83c:	04bd                	addi	s1,s1,15
 83e:	8091                	srli	s1,s1,0x4
 840:	0014899b          	addiw	s3,s1,1
 844:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 846:	00000517          	auipc	a0,0x0
 84a:	7ba53503          	ld	a0,1978(a0) # 1000 <freep>
 84e:	c515                	beqz	a0,87a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 850:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 852:	4798                	lw	a4,8(a5)
 854:	02977f63          	bgeu	a4,s1,892 <malloc+0x70>
 858:	8a4e                	mv	s4,s3
 85a:	0009871b          	sext.w	a4,s3
 85e:	6685                	lui	a3,0x1
 860:	00d77363          	bgeu	a4,a3,866 <malloc+0x44>
 864:	6a05                	lui	s4,0x1
 866:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 86a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 86e:	00000917          	auipc	s2,0x0
 872:	79290913          	addi	s2,s2,1938 # 1000 <freep>
  if(p == (char*)-1)
 876:	5afd                	li	s5,-1
 878:	a895                	j	8ec <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 87a:	00000797          	auipc	a5,0x0
 87e:	79678793          	addi	a5,a5,1942 # 1010 <base>
 882:	00000717          	auipc	a4,0x0
 886:	76f73f23          	sd	a5,1918(a4) # 1000 <freep>
 88a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 88c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 890:	b7e1                	j	858 <malloc+0x36>
      if(p->s.size == nunits)
 892:	02e48c63          	beq	s1,a4,8ca <malloc+0xa8>
        p->s.size -= nunits;
 896:	4137073b          	subw	a4,a4,s3
 89a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 89c:	02071693          	slli	a3,a4,0x20
 8a0:	01c6d713          	srli	a4,a3,0x1c
 8a4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8a6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8aa:	00000717          	auipc	a4,0x0
 8ae:	74a73b23          	sd	a0,1878(a4) # 1000 <freep>
      return (void*)(p + 1);
 8b2:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8b6:	70e2                	ld	ra,56(sp)
 8b8:	7442                	ld	s0,48(sp)
 8ba:	74a2                	ld	s1,40(sp)
 8bc:	7902                	ld	s2,32(sp)
 8be:	69e2                	ld	s3,24(sp)
 8c0:	6a42                	ld	s4,16(sp)
 8c2:	6aa2                	ld	s5,8(sp)
 8c4:	6b02                	ld	s6,0(sp)
 8c6:	6121                	addi	sp,sp,64
 8c8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8ca:	6398                	ld	a4,0(a5)
 8cc:	e118                	sd	a4,0(a0)
 8ce:	bff1                	j	8aa <malloc+0x88>
  hp->s.size = nu;
 8d0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8d4:	0541                	addi	a0,a0,16
 8d6:	00000097          	auipc	ra,0x0
 8da:	eca080e7          	jalr	-310(ra) # 7a0 <free>
  return freep;
 8de:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8e2:	d971                	beqz	a0,8b6 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e6:	4798                	lw	a4,8(a5)
 8e8:	fa9775e3          	bgeu	a4,s1,892 <malloc+0x70>
    if(p == freep)
 8ec:	00093703          	ld	a4,0(s2)
 8f0:	853e                	mv	a0,a5
 8f2:	fef719e3          	bne	a4,a5,8e4 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8f6:	8552                	mv	a0,s4
 8f8:	00000097          	auipc	ra,0x0
 8fc:	b58080e7          	jalr	-1192(ra) # 450 <sbrk>
  if(p == (char*)-1)
 900:	fd5518e3          	bne	a0,s5,8d0 <malloc+0xae>
        return 0;
 904:	4501                	li	a0,0
 906:	bf45                	j	8b6 <malloc+0x94>
