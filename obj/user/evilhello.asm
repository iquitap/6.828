
obj/user/evilhello：     文件格式 elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  80003a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 0c 00 10 f0 	movl   $0xf010000c,(%esp)
  800049:	e8 6a 00 00 00       	call   8000b8 <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	83 ec 10             	sub    $0x10,%esp
  800058:	8b 75 08             	mov    0x8(%ebp),%esi
  80005b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.

        //娉ㄦ剰绗簩琛岀殑娉ㄩ噴
        thisenv = envs + ENVX(sys_getenvid()); //ENVX(idx) equal to ENVX[idx];
  80005e:	e8 e4 00 00 00       	call   800147 <sys_getenvid>
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80006f:	c1 e0 07             	shl    $0x7,%eax
  800072:	29 d0                	sub    %edx,%eax
  800074:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800079:	a3 04 20 80 00       	mov    %eax,0x802004

        
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007e:	85 f6                	test   %esi,%esi
  800080:	7e 07                	jle    800089 <libmain+0x39>
		binaryname = argv[0];
  800082:	8b 03                	mov    (%ebx),%eax
  800084:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800089:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008d:	89 34 24             	mov    %esi,(%esp)
  800090:	e8 9f ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	5b                   	pop    %ebx
  80009e:	5e                   	pop    %esi
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    
  8000a1:	00 00                	add    %al,(%eax)
	...

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b1:	e8 3f 00 00 00       	call   8000f5 <sys_env_destroy>
}
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000be:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c9:	89 c3                	mov    %eax,%ebx
  8000cb:	89 c7                	mov    %eax,%edi
  8000cd:	89 c6                	mov    %eax,%esi
  8000cf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e6:	89 d1                	mov    %edx,%ecx
  8000e8:	89 d3                	mov    %edx,%ebx
  8000ea:	89 d7                	mov    %edx,%edi
  8000ec:	89 d6                	mov    %edx,%esi
  8000ee:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    

008000f5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f5:	55                   	push   %ebp
  8000f6:	89 e5                	mov    %esp,%ebp
  8000f8:	57                   	push   %edi
  8000f9:	56                   	push   %esi
  8000fa:	53                   	push   %ebx
  8000fb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800103:	b8 03 00 00 00       	mov    $0x3,%eax
  800108:	8b 55 08             	mov    0x8(%ebp),%edx
  80010b:	89 cb                	mov    %ecx,%ebx
  80010d:	89 cf                	mov    %ecx,%edi
  80010f:	89 ce                	mov    %ecx,%esi
  800111:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800113:	85 c0                	test   %eax,%eax
  800115:	7e 28                	jle    80013f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800117:	89 44 24 10          	mov    %eax,0x10(%esp)
  80011b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800122:	00 
  800123:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  80012a:	00 
  80012b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800132:	00 
  800133:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  80013a:	e8 5d 02 00 00       	call   80039c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013f:	83 c4 2c             	add    $0x2c,%esp
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 02 00 00 00       	mov    $0x2,%eax
  800157:	89 d1                	mov    %edx,%ecx
  800159:	89 d3                	mov    %edx,%ebx
  80015b:	89 d7                	mov    %edx,%edi
  80015d:	89 d6                	mov    %edx,%esi
  80015f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_yield>:

void
sys_yield(void)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016c:	ba 00 00 00 00       	mov    $0x0,%edx
  800171:	b8 0a 00 00 00       	mov    $0xa,%eax
  800176:	89 d1                	mov    %edx,%ecx
  800178:	89 d3                	mov    %edx,%ebx
  80017a:	89 d7                	mov    %edx,%edi
  80017c:	89 d6                	mov    %edx,%esi
  80017e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    

00800185 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	57                   	push   %edi
  800189:	56                   	push   %esi
  80018a:	53                   	push   %ebx
  80018b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018e:	be 00 00 00 00       	mov    $0x0,%esi
  800193:	b8 04 00 00 00       	mov    $0x4,%eax
  800198:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019e:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a1:	89 f7                	mov    %esi,%edi
  8001a3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001a5:	85 c0                	test   %eax,%eax
  8001a7:	7e 28                	jle    8001d1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001ad:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001b4:	00 
  8001b5:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  8001bc:	00 
  8001bd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c4:	00 
  8001c5:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  8001cc:	e8 cb 01 00 00       	call   80039c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001d1:	83 c4 2c             	add    $0x2c,%esp
  8001d4:	5b                   	pop    %ebx
  8001d5:	5e                   	pop    %esi
  8001d6:	5f                   	pop    %edi
  8001d7:	5d                   	pop    %ebp
  8001d8:	c3                   	ret    

008001d9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	57                   	push   %edi
  8001dd:	56                   	push   %esi
  8001de:	53                   	push   %ebx
  8001df:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ea:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f8:	85 c0                	test   %eax,%eax
  8001fa:	7e 28                	jle    800224 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800200:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800207:	00 
  800208:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  80020f:	00 
  800210:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800217:	00 
  800218:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  80021f:	e8 78 01 00 00       	call   80039c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800224:	83 c4 2c             	add    $0x2c,%esp
  800227:	5b                   	pop    %ebx
  800228:	5e                   	pop    %esi
  800229:	5f                   	pop    %edi
  80022a:	5d                   	pop    %ebp
  80022b:	c3                   	ret    

0080022c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	57                   	push   %edi
  800230:	56                   	push   %esi
  800231:	53                   	push   %ebx
  800232:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800235:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023a:	b8 06 00 00 00       	mov    $0x6,%eax
  80023f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800242:	8b 55 08             	mov    0x8(%ebp),%edx
  800245:	89 df                	mov    %ebx,%edi
  800247:	89 de                	mov    %ebx,%esi
  800249:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024b:	85 c0                	test   %eax,%eax
  80024d:	7e 28                	jle    800277 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800253:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80025a:	00 
  80025b:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  800262:	00 
  800263:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80026a:	00 
  80026b:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  800272:	e8 25 01 00 00       	call   80039c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800277:	83 c4 2c             	add    $0x2c,%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5f                   	pop    %edi
  80027d:	5d                   	pop    %ebp
  80027e:	c3                   	ret    

0080027f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	57                   	push   %edi
  800283:	56                   	push   %esi
  800284:	53                   	push   %ebx
  800285:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800288:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028d:	b8 08 00 00 00       	mov    $0x8,%eax
  800292:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800295:	8b 55 08             	mov    0x8(%ebp),%edx
  800298:	89 df                	mov    %ebx,%edi
  80029a:	89 de                	mov    %ebx,%esi
  80029c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80029e:	85 c0                	test   %eax,%eax
  8002a0:	7e 28                	jle    8002ca <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002ad:	00 
  8002ae:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  8002b5:	00 
  8002b6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002bd:	00 
  8002be:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  8002c5:	e8 d2 00 00 00       	call   80039c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002ca:	83 c4 2c             	add    $0x2c,%esp
  8002cd:	5b                   	pop    %ebx
  8002ce:	5e                   	pop    %esi
  8002cf:	5f                   	pop    %edi
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    

008002d2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e0:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8002eb:	89 df                	mov    %ebx,%edi
  8002ed:	89 de                	mov    %ebx,%esi
  8002ef:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002f1:	85 c0                	test   %eax,%eax
  8002f3:	7e 28                	jle    80031d <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800300:	00 
  800301:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  800308:	00 
  800309:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800310:	00 
  800311:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  800318:	e8 7f 00 00 00       	call   80039c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80031d:	83 c4 2c             	add    $0x2c,%esp
  800320:	5b                   	pop    %ebx
  800321:	5e                   	pop    %esi
  800322:	5f                   	pop    %edi
  800323:	5d                   	pop    %ebp
  800324:	c3                   	ret    

00800325 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	57                   	push   %edi
  800329:	56                   	push   %esi
  80032a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80032b:	be 00 00 00 00       	mov    $0x0,%esi
  800330:	b8 0b 00 00 00       	mov    $0xb,%eax
  800335:	8b 7d 14             	mov    0x14(%ebp),%edi
  800338:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80033b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80033e:	8b 55 08             	mov    0x8(%ebp),%edx
  800341:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800343:	5b                   	pop    %ebx
  800344:	5e                   	pop    %esi
  800345:	5f                   	pop    %edi
  800346:	5d                   	pop    %ebp
  800347:	c3                   	ret    

00800348 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800348:	55                   	push   %ebp
  800349:	89 e5                	mov    %esp,%ebp
  80034b:	57                   	push   %edi
  80034c:	56                   	push   %esi
  80034d:	53                   	push   %ebx
  80034e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800351:	b9 00 00 00 00       	mov    $0x0,%ecx
  800356:	b8 0c 00 00 00       	mov    $0xc,%eax
  80035b:	8b 55 08             	mov    0x8(%ebp),%edx
  80035e:	89 cb                	mov    %ecx,%ebx
  800360:	89 cf                	mov    %ecx,%edi
  800362:	89 ce                	mov    %ecx,%esi
  800364:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800366:	85 c0                	test   %eax,%eax
  800368:	7e 28                	jle    800392 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80036a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80036e:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800375:	00 
  800376:	c7 44 24 08 ca 0f 80 	movl   $0x800fca,0x8(%esp)
  80037d:	00 
  80037e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800385:	00 
  800386:	c7 04 24 e7 0f 80 00 	movl   $0x800fe7,(%esp)
  80038d:	e8 0a 00 00 00       	call   80039c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800392:	83 c4 2c             	add    $0x2c,%esp
  800395:	5b                   	pop    %ebx
  800396:	5e                   	pop    %esi
  800397:	5f                   	pop    %edi
  800398:	5d                   	pop    %ebp
  800399:	c3                   	ret    
	...

0080039c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	56                   	push   %esi
  8003a0:	53                   	push   %ebx
  8003a1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003a7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8003ad:	e8 95 fd ff ff       	call   800147 <sys_getenvid>
  8003b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003c0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c8:	c7 04 24 f8 0f 80 00 	movl   $0x800ff8,(%esp)
  8003cf:	e8 c0 00 00 00       	call   800494 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8003db:	89 04 24             	mov    %eax,(%esp)
  8003de:	e8 50 00 00 00       	call   800433 <vcprintf>
	cprintf("\n");
  8003e3:	c7 04 24 1c 10 80 00 	movl   $0x80101c,(%esp)
  8003ea:	e8 a5 00 00 00       	call   800494 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003ef:	cc                   	int3   
  8003f0:	eb fd                	jmp    8003ef <_panic+0x53>
	...

008003f4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	53                   	push   %ebx
  8003f8:	83 ec 14             	sub    $0x14,%esp
  8003fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003fe:	8b 03                	mov    (%ebx),%eax
  800400:	8b 55 08             	mov    0x8(%ebp),%edx
  800403:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800407:	40                   	inc    %eax
  800408:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80040a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80040f:	75 19                	jne    80042a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800411:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800418:	00 
  800419:	8d 43 08             	lea    0x8(%ebx),%eax
  80041c:	89 04 24             	mov    %eax,(%esp)
  80041f:	e8 94 fc ff ff       	call   8000b8 <sys_cputs>
		b->idx = 0;
  800424:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80042a:	ff 43 04             	incl   0x4(%ebx)
}
  80042d:	83 c4 14             	add    $0x14,%esp
  800430:	5b                   	pop    %ebx
  800431:	5d                   	pop    %ebp
  800432:	c3                   	ret    

00800433 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800433:	55                   	push   %ebp
  800434:	89 e5                	mov    %esp,%ebp
  800436:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80043c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800443:	00 00 00 
	b.cnt = 0;
  800446:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80044d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800450:	8b 45 0c             	mov    0xc(%ebp),%eax
  800453:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800457:	8b 45 08             	mov    0x8(%ebp),%eax
  80045a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80045e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800464:	89 44 24 04          	mov    %eax,0x4(%esp)
  800468:	c7 04 24 f4 03 80 00 	movl   $0x8003f4,(%esp)
  80046f:	e8 82 01 00 00       	call   8005f6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800474:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80047a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800484:	89 04 24             	mov    %eax,(%esp)
  800487:	e8 2c fc ff ff       	call   8000b8 <sys_cputs>

	return b.cnt;
}
  80048c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800492:	c9                   	leave  
  800493:	c3                   	ret    

00800494 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800494:	55                   	push   %ebp
  800495:	89 e5                	mov    %esp,%ebp
  800497:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80049a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80049d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a4:	89 04 24             	mov    %eax,(%esp)
  8004a7:	e8 87 ff ff ff       	call   800433 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004ac:	c9                   	leave  
  8004ad:	c3                   	ret    
	...

008004b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
  8004b3:	57                   	push   %edi
  8004b4:	56                   	push   %esi
  8004b5:	53                   	push   %ebx
  8004b6:	83 ec 3c             	sub    $0x3c,%esp
  8004b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004bc:	89 d7                	mov    %edx,%edi
  8004be:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ca:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004cd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004d0:	85 c0                	test   %eax,%eax
  8004d2:	75 08                	jne    8004dc <printnum+0x2c>
  8004d4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004d7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004da:	77 57                	ja     800533 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004dc:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004e0:	4b                   	dec    %ebx
  8004e1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004ec:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004f0:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004f4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004fb:	00 
  8004fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004ff:	89 04 24             	mov    %eax,(%esp)
  800502:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800505:	89 44 24 04          	mov    %eax,0x4(%esp)
  800509:	e8 56 08 00 00       	call   800d64 <__udivdi3>
  80050e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800512:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800516:	89 04 24             	mov    %eax,(%esp)
  800519:	89 54 24 04          	mov    %edx,0x4(%esp)
  80051d:	89 fa                	mov    %edi,%edx
  80051f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800522:	e8 89 ff ff ff       	call   8004b0 <printnum>
  800527:	eb 0f                	jmp    800538 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800529:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80052d:	89 34 24             	mov    %esi,(%esp)
  800530:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800533:	4b                   	dec    %ebx
  800534:	85 db                	test   %ebx,%ebx
  800536:	7f f1                	jg     800529 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800538:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80053c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800540:	8b 45 10             	mov    0x10(%ebp),%eax
  800543:	89 44 24 08          	mov    %eax,0x8(%esp)
  800547:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80054e:	00 
  80054f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800552:	89 04 24             	mov    %eax,(%esp)
  800555:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800558:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055c:	e8 23 09 00 00       	call   800e84 <__umoddi3>
  800561:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800565:	0f be 80 1e 10 80 00 	movsbl 0x80101e(%eax),%eax
  80056c:	89 04 24             	mov    %eax,(%esp)
  80056f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800572:	83 c4 3c             	add    $0x3c,%esp
  800575:	5b                   	pop    %ebx
  800576:	5e                   	pop    %esi
  800577:	5f                   	pop    %edi
  800578:	5d                   	pop    %ebp
  800579:	c3                   	ret    

0080057a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80057a:	55                   	push   %ebp
  80057b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80057d:	83 fa 01             	cmp    $0x1,%edx
  800580:	7e 0e                	jle    800590 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800582:	8b 10                	mov    (%eax),%edx
  800584:	8d 4a 08             	lea    0x8(%edx),%ecx
  800587:	89 08                	mov    %ecx,(%eax)
  800589:	8b 02                	mov    (%edx),%eax
  80058b:	8b 52 04             	mov    0x4(%edx),%edx
  80058e:	eb 22                	jmp    8005b2 <getuint+0x38>
	else if (lflag)
  800590:	85 d2                	test   %edx,%edx
  800592:	74 10                	je     8005a4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800594:	8b 10                	mov    (%eax),%edx
  800596:	8d 4a 04             	lea    0x4(%edx),%ecx
  800599:	89 08                	mov    %ecx,(%eax)
  80059b:	8b 02                	mov    (%edx),%eax
  80059d:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a2:	eb 0e                	jmp    8005b2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005a4:	8b 10                	mov    (%eax),%edx
  8005a6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005a9:	89 08                	mov    %ecx,(%eax)
  8005ab:	8b 02                	mov    (%edx),%eax
  8005ad:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005b2:	5d                   	pop    %ebp
  8005b3:	c3                   	ret    

008005b4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005b4:	55                   	push   %ebp
  8005b5:	89 e5                	mov    %esp,%ebp
  8005b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005ba:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005bd:	8b 10                	mov    (%eax),%edx
  8005bf:	3b 50 04             	cmp    0x4(%eax),%edx
  8005c2:	73 08                	jae    8005cc <sprintputch+0x18>
		*b->buf++ = ch;
  8005c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005c7:	88 0a                	mov    %cl,(%edx)
  8005c9:	42                   	inc    %edx
  8005ca:	89 10                	mov    %edx,(%eax)
}
  8005cc:	5d                   	pop    %ebp
  8005cd:	c3                   	ret    

008005ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005ce:	55                   	push   %ebp
  8005cf:	89 e5                	mov    %esp,%ebp
  8005d1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005db:	8b 45 10             	mov    0x10(%ebp),%eax
  8005de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ec:	89 04 24             	mov    %eax,(%esp)
  8005ef:	e8 02 00 00 00       	call   8005f6 <vprintfmt>
	va_end(ap);
}
  8005f4:	c9                   	leave  
  8005f5:	c3                   	ret    

008005f6 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005f6:	55                   	push   %ebp
  8005f7:	89 e5                	mov    %esp,%ebp
  8005f9:	57                   	push   %edi
  8005fa:	56                   	push   %esi
  8005fb:	53                   	push   %ebx
  8005fc:	83 ec 4c             	sub    $0x4c,%esp
  8005ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800602:	8b 75 10             	mov    0x10(%ebp),%esi
  800605:	eb 12                	jmp    800619 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800607:	85 c0                	test   %eax,%eax
  800609:	0f 84 6b 03 00 00    	je     80097a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80060f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800613:	89 04 24             	mov    %eax,(%esp)
  800616:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800619:	0f b6 06             	movzbl (%esi),%eax
  80061c:	46                   	inc    %esi
  80061d:	83 f8 25             	cmp    $0x25,%eax
  800620:	75 e5                	jne    800607 <vprintfmt+0x11>
  800622:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800626:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80062d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800632:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800639:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063e:	eb 26                	jmp    800666 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800640:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800643:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800647:	eb 1d                	jmp    800666 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800649:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80064c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800650:	eb 14                	jmp    800666 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800652:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800655:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80065c:	eb 08                	jmp    800666 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80065e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800661:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800666:	0f b6 06             	movzbl (%esi),%eax
  800669:	8d 56 01             	lea    0x1(%esi),%edx
  80066c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80066f:	8a 16                	mov    (%esi),%dl
  800671:	83 ea 23             	sub    $0x23,%edx
  800674:	80 fa 55             	cmp    $0x55,%dl
  800677:	0f 87 e1 02 00 00    	ja     80095e <vprintfmt+0x368>
  80067d:	0f b6 d2             	movzbl %dl,%edx
  800680:	ff 24 95 e0 10 80 00 	jmp    *0x8010e0(,%edx,4)
  800687:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80068a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80068f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800692:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800696:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800699:	8d 50 d0             	lea    -0x30(%eax),%edx
  80069c:	83 fa 09             	cmp    $0x9,%edx
  80069f:	77 2a                	ja     8006cb <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006a1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006a2:	eb eb                	jmp    80068f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8d 50 04             	lea    0x4(%eax),%edx
  8006aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ad:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006af:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006b2:	eb 17                	jmp    8006cb <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006b4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006b8:	78 98                	js     800652 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006bd:	eb a7                	jmp    800666 <vprintfmt+0x70>
  8006bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006c2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006c9:	eb 9b                	jmp    800666 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006cb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006cf:	79 95                	jns    800666 <vprintfmt+0x70>
  8006d1:	eb 8b                	jmp    80065e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006d3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006d7:	eb 8d                	jmp    800666 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8d 50 04             	lea    0x4(%eax),%edx
  8006df:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e6:	8b 00                	mov    (%eax),%eax
  8006e8:	89 04 24             	mov    %eax,(%esp)
  8006eb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006f1:	e9 23 ff ff ff       	jmp    800619 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	8d 50 04             	lea    0x4(%eax),%edx
  8006fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ff:	8b 00                	mov    (%eax),%eax
  800701:	85 c0                	test   %eax,%eax
  800703:	79 02                	jns    800707 <vprintfmt+0x111>
  800705:	f7 d8                	neg    %eax
  800707:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800709:	83 f8 09             	cmp    $0x9,%eax
  80070c:	7f 0b                	jg     800719 <vprintfmt+0x123>
  80070e:	8b 04 85 40 12 80 00 	mov    0x801240(,%eax,4),%eax
  800715:	85 c0                	test   %eax,%eax
  800717:	75 23                	jne    80073c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800719:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80071d:	c7 44 24 08 36 10 80 	movl   $0x801036,0x8(%esp)
  800724:	00 
  800725:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800729:	8b 45 08             	mov    0x8(%ebp),%eax
  80072c:	89 04 24             	mov    %eax,(%esp)
  80072f:	e8 9a fe ff ff       	call   8005ce <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800734:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800737:	e9 dd fe ff ff       	jmp    800619 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80073c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800740:	c7 44 24 08 3f 10 80 	movl   $0x80103f,0x8(%esp)
  800747:	00 
  800748:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074c:	8b 55 08             	mov    0x8(%ebp),%edx
  80074f:	89 14 24             	mov    %edx,(%esp)
  800752:	e8 77 fe ff ff       	call   8005ce <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800757:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80075a:	e9 ba fe ff ff       	jmp    800619 <vprintfmt+0x23>
  80075f:	89 f9                	mov    %edi,%ecx
  800761:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800764:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800767:	8b 45 14             	mov    0x14(%ebp),%eax
  80076a:	8d 50 04             	lea    0x4(%eax),%edx
  80076d:	89 55 14             	mov    %edx,0x14(%ebp)
  800770:	8b 30                	mov    (%eax),%esi
  800772:	85 f6                	test   %esi,%esi
  800774:	75 05                	jne    80077b <vprintfmt+0x185>
				p = "(null)";
  800776:	be 2f 10 80 00       	mov    $0x80102f,%esi
			if (width > 0 && padc != '-')
  80077b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80077f:	0f 8e 84 00 00 00    	jle    800809 <vprintfmt+0x213>
  800785:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800789:	74 7e                	je     800809 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80078b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80078f:	89 34 24             	mov    %esi,(%esp)
  800792:	e8 8b 02 00 00       	call   800a22 <strnlen>
  800797:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80079a:	29 c2                	sub    %eax,%edx
  80079c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80079f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8007a3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007a6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007a9:	89 de                	mov    %ebx,%esi
  8007ab:	89 d3                	mov    %edx,%ebx
  8007ad:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007af:	eb 0b                	jmp    8007bc <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b5:	89 3c 24             	mov    %edi,(%esp)
  8007b8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007bb:	4b                   	dec    %ebx
  8007bc:	85 db                	test   %ebx,%ebx
  8007be:	7f f1                	jg     8007b1 <vprintfmt+0x1bb>
  8007c0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007c3:	89 f3                	mov    %esi,%ebx
  8007c5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	79 05                	jns    8007d4 <vprintfmt+0x1de>
  8007cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d7:	29 c2                	sub    %eax,%edx
  8007d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007dc:	eb 2b                	jmp    800809 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007de:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007e2:	74 18                	je     8007fc <vprintfmt+0x206>
  8007e4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007e7:	83 fa 5e             	cmp    $0x5e,%edx
  8007ea:	76 10                	jbe    8007fc <vprintfmt+0x206>
					putch('?', putdat);
  8007ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f0:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007f7:	ff 55 08             	call   *0x8(%ebp)
  8007fa:	eb 0a                	jmp    800806 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8007fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800800:	89 04 24             	mov    %eax,(%esp)
  800803:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800806:	ff 4d e4             	decl   -0x1c(%ebp)
  800809:	0f be 06             	movsbl (%esi),%eax
  80080c:	46                   	inc    %esi
  80080d:	85 c0                	test   %eax,%eax
  80080f:	74 21                	je     800832 <vprintfmt+0x23c>
  800811:	85 ff                	test   %edi,%edi
  800813:	78 c9                	js     8007de <vprintfmt+0x1e8>
  800815:	4f                   	dec    %edi
  800816:	79 c6                	jns    8007de <vprintfmt+0x1e8>
  800818:	8b 7d 08             	mov    0x8(%ebp),%edi
  80081b:	89 de                	mov    %ebx,%esi
  80081d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800820:	eb 18                	jmp    80083a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800822:	89 74 24 04          	mov    %esi,0x4(%esp)
  800826:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80082d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80082f:	4b                   	dec    %ebx
  800830:	eb 08                	jmp    80083a <vprintfmt+0x244>
  800832:	8b 7d 08             	mov    0x8(%ebp),%edi
  800835:	89 de                	mov    %ebx,%esi
  800837:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80083a:	85 db                	test   %ebx,%ebx
  80083c:	7f e4                	jg     800822 <vprintfmt+0x22c>
  80083e:	89 7d 08             	mov    %edi,0x8(%ebp)
  800841:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800843:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800846:	e9 ce fd ff ff       	jmp    800619 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80084b:	83 f9 01             	cmp    $0x1,%ecx
  80084e:	7e 10                	jle    800860 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800850:	8b 45 14             	mov    0x14(%ebp),%eax
  800853:	8d 50 08             	lea    0x8(%eax),%edx
  800856:	89 55 14             	mov    %edx,0x14(%ebp)
  800859:	8b 30                	mov    (%eax),%esi
  80085b:	8b 78 04             	mov    0x4(%eax),%edi
  80085e:	eb 26                	jmp    800886 <vprintfmt+0x290>
	else if (lflag)
  800860:	85 c9                	test   %ecx,%ecx
  800862:	74 12                	je     800876 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800864:	8b 45 14             	mov    0x14(%ebp),%eax
  800867:	8d 50 04             	lea    0x4(%eax),%edx
  80086a:	89 55 14             	mov    %edx,0x14(%ebp)
  80086d:	8b 30                	mov    (%eax),%esi
  80086f:	89 f7                	mov    %esi,%edi
  800871:	c1 ff 1f             	sar    $0x1f,%edi
  800874:	eb 10                	jmp    800886 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800876:	8b 45 14             	mov    0x14(%ebp),%eax
  800879:	8d 50 04             	lea    0x4(%eax),%edx
  80087c:	89 55 14             	mov    %edx,0x14(%ebp)
  80087f:	8b 30                	mov    (%eax),%esi
  800881:	89 f7                	mov    %esi,%edi
  800883:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800886:	85 ff                	test   %edi,%edi
  800888:	78 0a                	js     800894 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80088a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80088f:	e9 8c 00 00 00       	jmp    800920 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800894:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800898:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80089f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008a2:	f7 de                	neg    %esi
  8008a4:	83 d7 00             	adc    $0x0,%edi
  8008a7:	f7 df                	neg    %edi
			}
			base = 10;
  8008a9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008ae:	eb 70                	jmp    800920 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008b0:	89 ca                	mov    %ecx,%edx
  8008b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b5:	e8 c0 fc ff ff       	call   80057a <getuint>
  8008ba:	89 c6                	mov    %eax,%esi
  8008bc:	89 d7                	mov    %edx,%edi
			base = 10;
  8008be:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008c3:	eb 5b                	jmp    800920 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
                        num = getuint(&ap,lflag);
  8008c5:	89 ca                	mov    %ecx,%edx
  8008c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ca:	e8 ab fc ff ff       	call   80057a <getuint>
  8008cf:	89 c6                	mov    %eax,%esi
  8008d1:	89 d7                	mov    %edx,%edi
                        base = 8;
  8008d3:	b8 08 00 00 00       	mov    $0x8,%eax
                        goto number;
  8008d8:	eb 46                	jmp    800920 <vprintfmt+0x32a>
                	//break;
    
		// pointer
		case 'p':
			putch('0', putdat);
  8008da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008de:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008e5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008ec:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008f3:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f9:	8d 50 04             	lea    0x4(%eax),%edx
  8008fc:	89 55 14             	mov    %edx,0x14(%ebp)
    
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008ff:	8b 30                	mov    (%eax),%esi
  800901:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800906:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80090b:	eb 13                	jmp    800920 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80090d:	89 ca                	mov    %ecx,%edx
  80090f:	8d 45 14             	lea    0x14(%ebp),%eax
  800912:	e8 63 fc ff ff       	call   80057a <getuint>
  800917:	89 c6                	mov    %eax,%esi
  800919:	89 d7                	mov    %edx,%edi
			base = 16;
  80091b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800920:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800924:	89 54 24 10          	mov    %edx,0x10(%esp)
  800928:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80092b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80092f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800933:	89 34 24             	mov    %esi,(%esp)
  800936:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80093a:	89 da                	mov    %ebx,%edx
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	e8 6c fb ff ff       	call   8004b0 <printnum>
			break;
  800944:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800947:	e9 cd fc ff ff       	jmp    800619 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80094c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800950:	89 04 24             	mov    %eax,(%esp)
  800953:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800956:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800959:	e9 bb fc ff ff       	jmp    800619 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80095e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800962:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800969:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80096c:	eb 01                	jmp    80096f <vprintfmt+0x379>
  80096e:	4e                   	dec    %esi
  80096f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800973:	75 f9                	jne    80096e <vprintfmt+0x378>
  800975:	e9 9f fc ff ff       	jmp    800619 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80097a:	83 c4 4c             	add    $0x4c,%esp
  80097d:	5b                   	pop    %ebx
  80097e:	5e                   	pop    %esi
  80097f:	5f                   	pop    %edi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	83 ec 28             	sub    $0x28,%esp
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80098e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800991:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800995:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800998:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80099f:	85 c0                	test   %eax,%eax
  8009a1:	74 30                	je     8009d3 <vsnprintf+0x51>
  8009a3:	85 d2                	test   %edx,%edx
  8009a5:	7e 33                	jle    8009da <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8009b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009b5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009bc:	c7 04 24 b4 05 80 00 	movl   $0x8005b4,(%esp)
  8009c3:	e8 2e fc ff ff       	call   8005f6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009cb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009d1:	eb 0c                	jmp    8009df <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009d8:	eb 05                	jmp    8009df <vsnprintf+0x5d>
  8009da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009df:	c9                   	leave  
  8009e0:	c3                   	ret    

008009e1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009e7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	89 04 24             	mov    %eax,(%esp)
  800a02:	e8 7b ff ff ff       	call   800982 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a07:	c9                   	leave  
  800a08:	c3                   	ret    
  800a09:	00 00                	add    %al,(%eax)
	...

00800a0c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a12:	b8 00 00 00 00       	mov    $0x0,%eax
  800a17:	eb 01                	jmp    800a1a <strlen+0xe>
		n++;
  800a19:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a1a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a1e:	75 f9                	jne    800a19 <strlen+0xd>
		n++;
	return n;
}
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a28:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a30:	eb 01                	jmp    800a33 <strnlen+0x11>
		n++;
  800a32:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a33:	39 d0                	cmp    %edx,%eax
  800a35:	74 06                	je     800a3d <strnlen+0x1b>
  800a37:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a3b:	75 f5                	jne    800a32 <strnlen+0x10>
		n++;
	return n;
}
  800a3d:	5d                   	pop    %ebp
  800a3e:	c3                   	ret    

00800a3f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	53                   	push   %ebx
  800a43:	8b 45 08             	mov    0x8(%ebp),%eax
  800a46:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a49:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a51:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a54:	42                   	inc    %edx
  800a55:	84 c9                	test   %cl,%cl
  800a57:	75 f5                	jne    800a4e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a59:	5b                   	pop    %ebx
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	53                   	push   %ebx
  800a60:	83 ec 08             	sub    $0x8,%esp
  800a63:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a66:	89 1c 24             	mov    %ebx,(%esp)
  800a69:	e8 9e ff ff ff       	call   800a0c <strlen>
	strcpy(dst + len, src);
  800a6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a71:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a75:	01 d8                	add    %ebx,%eax
  800a77:	89 04 24             	mov    %eax,(%esp)
  800a7a:	e8 c0 ff ff ff       	call   800a3f <strcpy>
	return dst;
}
  800a7f:	89 d8                	mov    %ebx,%eax
  800a81:	83 c4 08             	add    $0x8,%esp
  800a84:	5b                   	pop    %ebx
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
  800a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a92:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a9a:	eb 0c                	jmp    800aa8 <strncpy+0x21>
		*dst++ = *src;
  800a9c:	8a 1a                	mov    (%edx),%bl
  800a9e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aa1:	80 3a 01             	cmpb   $0x1,(%edx)
  800aa4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa7:	41                   	inc    %ecx
  800aa8:	39 f1                	cmp    %esi,%ecx
  800aaa:	75 f0                	jne    800a9c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    

00800ab0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	56                   	push   %esi
  800ab4:	53                   	push   %ebx
  800ab5:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800abb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800abe:	85 d2                	test   %edx,%edx
  800ac0:	75 0a                	jne    800acc <strlcpy+0x1c>
  800ac2:	89 f0                	mov    %esi,%eax
  800ac4:	eb 1a                	jmp    800ae0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ac6:	88 18                	mov    %bl,(%eax)
  800ac8:	40                   	inc    %eax
  800ac9:	41                   	inc    %ecx
  800aca:	eb 02                	jmp    800ace <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800acc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800ace:	4a                   	dec    %edx
  800acf:	74 0a                	je     800adb <strlcpy+0x2b>
  800ad1:	8a 19                	mov    (%ecx),%bl
  800ad3:	84 db                	test   %bl,%bl
  800ad5:	75 ef                	jne    800ac6 <strlcpy+0x16>
  800ad7:	89 c2                	mov    %eax,%edx
  800ad9:	eb 02                	jmp    800add <strlcpy+0x2d>
  800adb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800add:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800ae0:	29 f0                	sub    %esi,%eax
}
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aec:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aef:	eb 02                	jmp    800af3 <strcmp+0xd>
		p++, q++;
  800af1:	41                   	inc    %ecx
  800af2:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800af3:	8a 01                	mov    (%ecx),%al
  800af5:	84 c0                	test   %al,%al
  800af7:	74 04                	je     800afd <strcmp+0x17>
  800af9:	3a 02                	cmp    (%edx),%al
  800afb:	74 f4                	je     800af1 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800afd:	0f b6 c0             	movzbl %al,%eax
  800b00:	0f b6 12             	movzbl (%edx),%edx
  800b03:	29 d0                	sub    %edx,%eax
}
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	53                   	push   %ebx
  800b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b11:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b14:	eb 03                	jmp    800b19 <strncmp+0x12>
		n--, p++, q++;
  800b16:	4a                   	dec    %edx
  800b17:	40                   	inc    %eax
  800b18:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b19:	85 d2                	test   %edx,%edx
  800b1b:	74 14                	je     800b31 <strncmp+0x2a>
  800b1d:	8a 18                	mov    (%eax),%bl
  800b1f:	84 db                	test   %bl,%bl
  800b21:	74 04                	je     800b27 <strncmp+0x20>
  800b23:	3a 19                	cmp    (%ecx),%bl
  800b25:	74 ef                	je     800b16 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b27:	0f b6 00             	movzbl (%eax),%eax
  800b2a:	0f b6 11             	movzbl (%ecx),%edx
  800b2d:	29 d0                	sub    %edx,%eax
  800b2f:	eb 05                	jmp    800b36 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b31:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b36:	5b                   	pop    %ebx
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b42:	eb 05                	jmp    800b49 <strchr+0x10>
		if (*s == c)
  800b44:	38 ca                	cmp    %cl,%dl
  800b46:	74 0c                	je     800b54 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b48:	40                   	inc    %eax
  800b49:	8a 10                	mov    (%eax),%dl
  800b4b:	84 d2                	test   %dl,%dl
  800b4d:	75 f5                	jne    800b44 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b5f:	eb 05                	jmp    800b66 <strfind+0x10>
		if (*s == c)
  800b61:	38 ca                	cmp    %cl,%dl
  800b63:	74 07                	je     800b6c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b65:	40                   	inc    %eax
  800b66:	8a 10                	mov    (%eax),%dl
  800b68:	84 d2                	test   %dl,%dl
  800b6a:	75 f5                	jne    800b61 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b7d:	85 c9                	test   %ecx,%ecx
  800b7f:	74 30                	je     800bb1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b81:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b87:	75 25                	jne    800bae <memset+0x40>
  800b89:	f6 c1 03             	test   $0x3,%cl
  800b8c:	75 20                	jne    800bae <memset+0x40>
		c &= 0xFF;
  800b8e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b91:	89 d3                	mov    %edx,%ebx
  800b93:	c1 e3 08             	shl    $0x8,%ebx
  800b96:	89 d6                	mov    %edx,%esi
  800b98:	c1 e6 18             	shl    $0x18,%esi
  800b9b:	89 d0                	mov    %edx,%eax
  800b9d:	c1 e0 10             	shl    $0x10,%eax
  800ba0:	09 f0                	or     %esi,%eax
  800ba2:	09 d0                	or     %edx,%eax
  800ba4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ba6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ba9:	fc                   	cld    
  800baa:	f3 ab                	rep stos %eax,%es:(%edi)
  800bac:	eb 03                	jmp    800bb1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bae:	fc                   	cld    
  800baf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bb1:	89 f8                	mov    %edi,%eax
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bc6:	39 c6                	cmp    %eax,%esi
  800bc8:	73 34                	jae    800bfe <memmove+0x46>
  800bca:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bcd:	39 d0                	cmp    %edx,%eax
  800bcf:	73 2d                	jae    800bfe <memmove+0x46>
		s += n;
		d += n;
  800bd1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd4:	f6 c2 03             	test   $0x3,%dl
  800bd7:	75 1b                	jne    800bf4 <memmove+0x3c>
  800bd9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bdf:	75 13                	jne    800bf4 <memmove+0x3c>
  800be1:	f6 c1 03             	test   $0x3,%cl
  800be4:	75 0e                	jne    800bf4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800be6:	83 ef 04             	sub    $0x4,%edi
  800be9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bec:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bef:	fd                   	std    
  800bf0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bf2:	eb 07                	jmp    800bfb <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bf4:	4f                   	dec    %edi
  800bf5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bf8:	fd                   	std    
  800bf9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bfb:	fc                   	cld    
  800bfc:	eb 20                	jmp    800c1e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bfe:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c04:	75 13                	jne    800c19 <memmove+0x61>
  800c06:	a8 03                	test   $0x3,%al
  800c08:	75 0f                	jne    800c19 <memmove+0x61>
  800c0a:	f6 c1 03             	test   $0x3,%cl
  800c0d:	75 0a                	jne    800c19 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c0f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c12:	89 c7                	mov    %eax,%edi
  800c14:	fc                   	cld    
  800c15:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c17:	eb 05                	jmp    800c1e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c19:	89 c7                	mov    %eax,%edi
  800c1b:	fc                   	cld    
  800c1c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c28:	8b 45 10             	mov    0x10(%ebp),%eax
  800c2b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c32:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c36:	8b 45 08             	mov    0x8(%ebp),%eax
  800c39:	89 04 24             	mov    %eax,(%esp)
  800c3c:	e8 77 ff ff ff       	call   800bb8 <memmove>
}
  800c41:	c9                   	leave  
  800c42:	c3                   	ret    

00800c43 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c52:	ba 00 00 00 00       	mov    $0x0,%edx
  800c57:	eb 16                	jmp    800c6f <memcmp+0x2c>
		if (*s1 != *s2)
  800c59:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c5c:	42                   	inc    %edx
  800c5d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c61:	38 c8                	cmp    %cl,%al
  800c63:	74 0a                	je     800c6f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c65:	0f b6 c0             	movzbl %al,%eax
  800c68:	0f b6 c9             	movzbl %cl,%ecx
  800c6b:	29 c8                	sub    %ecx,%eax
  800c6d:	eb 09                	jmp    800c78 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c6f:	39 da                	cmp    %ebx,%edx
  800c71:	75 e6                	jne    800c59 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	8b 45 08             	mov    0x8(%ebp),%eax
  800c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c86:	89 c2                	mov    %eax,%edx
  800c88:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c8b:	eb 05                	jmp    800c92 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c8d:	38 08                	cmp    %cl,(%eax)
  800c8f:	74 05                	je     800c96 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c91:	40                   	inc    %eax
  800c92:	39 d0                	cmp    %edx,%eax
  800c94:	72 f7                	jb     800c8d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	57                   	push   %edi
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca4:	eb 01                	jmp    800ca7 <strtol+0xf>
		s++;
  800ca6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca7:	8a 02                	mov    (%edx),%al
  800ca9:	3c 20                	cmp    $0x20,%al
  800cab:	74 f9                	je     800ca6 <strtol+0xe>
  800cad:	3c 09                	cmp    $0x9,%al
  800caf:	74 f5                	je     800ca6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cb1:	3c 2b                	cmp    $0x2b,%al
  800cb3:	75 08                	jne    800cbd <strtol+0x25>
		s++;
  800cb5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cb6:	bf 00 00 00 00       	mov    $0x0,%edi
  800cbb:	eb 13                	jmp    800cd0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cbd:	3c 2d                	cmp    $0x2d,%al
  800cbf:	75 0a                	jne    800ccb <strtol+0x33>
		s++, neg = 1;
  800cc1:	8d 52 01             	lea    0x1(%edx),%edx
  800cc4:	bf 01 00 00 00       	mov    $0x1,%edi
  800cc9:	eb 05                	jmp    800cd0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ccb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cd0:	85 db                	test   %ebx,%ebx
  800cd2:	74 05                	je     800cd9 <strtol+0x41>
  800cd4:	83 fb 10             	cmp    $0x10,%ebx
  800cd7:	75 28                	jne    800d01 <strtol+0x69>
  800cd9:	8a 02                	mov    (%edx),%al
  800cdb:	3c 30                	cmp    $0x30,%al
  800cdd:	75 10                	jne    800cef <strtol+0x57>
  800cdf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ce3:	75 0a                	jne    800cef <strtol+0x57>
		s += 2, base = 16;
  800ce5:	83 c2 02             	add    $0x2,%edx
  800ce8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ced:	eb 12                	jmp    800d01 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800cef:	85 db                	test   %ebx,%ebx
  800cf1:	75 0e                	jne    800d01 <strtol+0x69>
  800cf3:	3c 30                	cmp    $0x30,%al
  800cf5:	75 05                	jne    800cfc <strtol+0x64>
		s++, base = 8;
  800cf7:	42                   	inc    %edx
  800cf8:	b3 08                	mov    $0x8,%bl
  800cfa:	eb 05                	jmp    800d01 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800cfc:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d01:	b8 00 00 00 00       	mov    $0x0,%eax
  800d06:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d08:	8a 0a                	mov    (%edx),%cl
  800d0a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d0d:	80 fb 09             	cmp    $0x9,%bl
  800d10:	77 08                	ja     800d1a <strtol+0x82>
			dig = *s - '0';
  800d12:	0f be c9             	movsbl %cl,%ecx
  800d15:	83 e9 30             	sub    $0x30,%ecx
  800d18:	eb 1e                	jmp    800d38 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d1a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d1d:	80 fb 19             	cmp    $0x19,%bl
  800d20:	77 08                	ja     800d2a <strtol+0x92>
			dig = *s - 'a' + 10;
  800d22:	0f be c9             	movsbl %cl,%ecx
  800d25:	83 e9 57             	sub    $0x57,%ecx
  800d28:	eb 0e                	jmp    800d38 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d2a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d2d:	80 fb 19             	cmp    $0x19,%bl
  800d30:	77 12                	ja     800d44 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d32:	0f be c9             	movsbl %cl,%ecx
  800d35:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d38:	39 f1                	cmp    %esi,%ecx
  800d3a:	7d 0c                	jge    800d48 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d3c:	42                   	inc    %edx
  800d3d:	0f af c6             	imul   %esi,%eax
  800d40:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d42:	eb c4                	jmp    800d08 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d44:	89 c1                	mov    %eax,%ecx
  800d46:	eb 02                	jmp    800d4a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d48:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d4a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d4e:	74 05                	je     800d55 <strtol+0xbd>
		*endptr = (char *) s;
  800d50:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d53:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d55:	85 ff                	test   %edi,%edi
  800d57:	74 04                	je     800d5d <strtol+0xc5>
  800d59:	89 c8                	mov    %ecx,%eax
  800d5b:	f7 d8                	neg    %eax
}
  800d5d:	5b                   	pop    %ebx
  800d5e:	5e                   	pop    %esi
  800d5f:	5f                   	pop    %edi
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    
	...

00800d64 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  800d64:	55                   	push   %ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	83 ec 10             	sub    $0x10,%esp
  800d6a:	8b 74 24 20          	mov    0x20(%esp),%esi
  800d6e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800d72:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d76:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  800d7a:	89 cd                	mov    %ecx,%ebp
  800d7c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800d80:	85 c0                	test   %eax,%eax
  800d82:	75 2c                	jne    800db0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  800d84:	39 f9                	cmp    %edi,%ecx
  800d86:	77 68                	ja     800df0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800d88:	85 c9                	test   %ecx,%ecx
  800d8a:	75 0b                	jne    800d97 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800d8c:	b8 01 00 00 00       	mov    $0x1,%eax
  800d91:	31 d2                	xor    %edx,%edx
  800d93:	f7 f1                	div    %ecx
  800d95:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800d97:	31 d2                	xor    %edx,%edx
  800d99:	89 f8                	mov    %edi,%eax
  800d9b:	f7 f1                	div    %ecx
  800d9d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800d9f:	89 f0                	mov    %esi,%eax
  800da1:	f7 f1                	div    %ecx
  800da3:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800da5:	89 f0                	mov    %esi,%eax
  800da7:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800da9:	83 c4 10             	add    $0x10,%esp
  800dac:	5e                   	pop    %esi
  800dad:	5f                   	pop    %edi
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800db0:	39 f8                	cmp    %edi,%eax
  800db2:	77 2c                	ja     800de0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800db4:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  800db7:	83 f6 1f             	xor    $0x1f,%esi
  800dba:	75 4c                	jne    800e08 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dbc:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dbe:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800dc3:	72 0a                	jb     800dcf <__udivdi3+0x6b>
  800dc5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800dc9:	0f 87 ad 00 00 00    	ja     800e7c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800dcf:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dd4:	89 f0                	mov    %esi,%eax
  800dd6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dd8:	83 c4 10             	add    $0x10,%esp
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    
  800ddf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800de0:	31 ff                	xor    %edi,%edi
  800de2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800de4:	89 f0                	mov    %esi,%eax
  800de6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800de8:	83 c4 10             	add    $0x10,%esp
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    
  800def:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800df0:	89 fa                	mov    %edi,%edx
  800df2:	89 f0                	mov    %esi,%eax
  800df4:	f7 f1                	div    %ecx
  800df6:	89 c6                	mov    %eax,%esi
  800df8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  800dfa:	89 f0                	mov    %esi,%eax
  800dfc:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  800dfe:	83 c4 10             	add    $0x10,%esp
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    
  800e05:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800e08:	89 f1                	mov    %esi,%ecx
  800e0a:	d3 e0                	shl    %cl,%eax
  800e0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800e10:	b8 20 00 00 00       	mov    $0x20,%eax
  800e15:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  800e17:	89 ea                	mov    %ebp,%edx
  800e19:	88 c1                	mov    %al,%cl
  800e1b:	d3 ea                	shr    %cl,%edx
  800e1d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800e21:	09 ca                	or     %ecx,%edx
  800e23:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  800e27:	89 f1                	mov    %esi,%ecx
  800e29:	d3 e5                	shl    %cl,%ebp
  800e2b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  800e2f:	89 fd                	mov    %edi,%ebp
  800e31:	88 c1                	mov    %al,%cl
  800e33:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  800e35:	89 fa                	mov    %edi,%edx
  800e37:	89 f1                	mov    %esi,%ecx
  800e39:	d3 e2                	shl    %cl,%edx
  800e3b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e3f:	88 c1                	mov    %al,%cl
  800e41:	d3 ef                	shr    %cl,%edi
  800e43:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800e45:	89 f8                	mov    %edi,%eax
  800e47:	89 ea                	mov    %ebp,%edx
  800e49:	f7 74 24 08          	divl   0x8(%esp)
  800e4d:	89 d1                	mov    %edx,%ecx
  800e4f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  800e51:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e55:	39 d1                	cmp    %edx,%ecx
  800e57:	72 17                	jb     800e70 <__udivdi3+0x10c>
  800e59:	74 09                	je     800e64 <__udivdi3+0x100>
  800e5b:	89 fe                	mov    %edi,%esi
  800e5d:	31 ff                	xor    %edi,%edi
  800e5f:	e9 41 ff ff ff       	jmp    800da5 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  800e64:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e68:	89 f1                	mov    %esi,%ecx
  800e6a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800e6c:	39 c2                	cmp    %eax,%edx
  800e6e:	73 eb                	jae    800e5b <__udivdi3+0xf7>
		{
		  q0--;
  800e70:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800e73:	31 ff                	xor    %edi,%edi
  800e75:	e9 2b ff ff ff       	jmp    800da5 <__udivdi3+0x41>
  800e7a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800e7c:	31 f6                	xor    %esi,%esi
  800e7e:	e9 22 ff ff ff       	jmp    800da5 <__udivdi3+0x41>
	...

00800e84 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  800e84:	55                   	push   %ebp
  800e85:	57                   	push   %edi
  800e86:	56                   	push   %esi
  800e87:	83 ec 20             	sub    $0x20,%esp
  800e8a:	8b 44 24 30          	mov    0x30(%esp),%eax
  800e8e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  800e92:	89 44 24 14          	mov    %eax,0x14(%esp)
  800e96:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  800e9a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e9e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  800ea2:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  800ea4:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  800ea6:	85 ed                	test   %ebp,%ebp
  800ea8:	75 16                	jne    800ec0 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  800eaa:	39 f1                	cmp    %esi,%ecx
  800eac:	0f 86 a6 00 00 00    	jbe    800f58 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800eb2:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  800eb4:	89 d0                	mov    %edx,%eax
  800eb6:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800eb8:	83 c4 20             	add    $0x20,%esp
  800ebb:	5e                   	pop    %esi
  800ebc:	5f                   	pop    %edi
  800ebd:	5d                   	pop    %ebp
  800ebe:	c3                   	ret    
  800ebf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  800ec0:	39 f5                	cmp    %esi,%ebp
  800ec2:	0f 87 ac 00 00 00    	ja     800f74 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  800ec8:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  800ecb:	83 f0 1f             	xor    $0x1f,%eax
  800ece:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed2:	0f 84 a8 00 00 00    	je     800f80 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  800ed8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800edc:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  800ede:	bf 20 00 00 00       	mov    $0x20,%edi
  800ee3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  800ee7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800eeb:	89 f9                	mov    %edi,%ecx
  800eed:	d3 e8                	shr    %cl,%eax
  800eef:	09 e8                	or     %ebp,%eax
  800ef1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  800ef5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ef9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800efd:	d3 e0                	shl    %cl,%eax
  800eff:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f03:	89 f2                	mov    %esi,%edx
  800f05:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  800f07:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f0b:	d3 e0                	shl    %cl,%eax
  800f0d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  800f11:	8b 44 24 14          	mov    0x14(%esp),%eax
  800f15:	89 f9                	mov    %edi,%ecx
  800f17:	d3 e8                	shr    %cl,%eax
  800f19:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  800f1b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  800f1d:	89 f2                	mov    %esi,%edx
  800f1f:	f7 74 24 18          	divl   0x18(%esp)
  800f23:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  800f25:	f7 64 24 0c          	mull   0xc(%esp)
  800f29:	89 c5                	mov    %eax,%ebp
  800f2b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800f2d:	39 d6                	cmp    %edx,%esi
  800f2f:	72 67                	jb     800f98 <__umoddi3+0x114>
  800f31:	74 75                	je     800fa8 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  800f33:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800f37:	29 e8                	sub    %ebp,%eax
  800f39:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  800f3b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f3f:	d3 e8                	shr    %cl,%eax
  800f41:	89 f2                	mov    %esi,%edx
  800f43:	89 f9                	mov    %edi,%ecx
  800f45:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  800f47:	09 d0                	or     %edx,%eax
  800f49:	89 f2                	mov    %esi,%edx
  800f4b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800f4f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f51:	83 c4 20             	add    $0x20,%esp
  800f54:	5e                   	pop    %esi
  800f55:	5f                   	pop    %edi
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  800f58:	85 c9                	test   %ecx,%ecx
  800f5a:	75 0b                	jne    800f67 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  800f5c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f61:	31 d2                	xor    %edx,%edx
  800f63:	f7 f1                	div    %ecx
  800f65:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  800f67:	89 f0                	mov    %esi,%eax
  800f69:	31 d2                	xor    %edx,%edx
  800f6b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  800f6d:	89 f8                	mov    %edi,%eax
  800f6f:	e9 3e ff ff ff       	jmp    800eb2 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  800f74:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f76:	83 c4 20             	add    $0x20,%esp
  800f79:	5e                   	pop    %esi
  800f7a:	5f                   	pop    %edi
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    
  800f7d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  800f80:	39 f5                	cmp    %esi,%ebp
  800f82:	72 04                	jb     800f88 <__umoddi3+0x104>
  800f84:	39 f9                	cmp    %edi,%ecx
  800f86:	77 06                	ja     800f8e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  800f88:	89 f2                	mov    %esi,%edx
  800f8a:	29 cf                	sub    %ecx,%edi
  800f8c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  800f8e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  800f90:	83 c4 20             	add    $0x20,%esp
  800f93:	5e                   	pop    %esi
  800f94:	5f                   	pop    %edi
  800f95:	5d                   	pop    %ebp
  800f96:	c3                   	ret    
  800f97:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  800f98:	89 d1                	mov    %edx,%ecx
  800f9a:	89 c5                	mov    %eax,%ebp
  800f9c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800fa0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800fa4:	eb 8d                	jmp    800f33 <__umoddi3+0xaf>
  800fa6:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  800fa8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800fac:	72 ea                	jb     800f98 <__umoddi3+0x114>
  800fae:	89 f1                	mov    %esi,%ecx
  800fb0:	eb 81                	jmp    800f33 <__umoddi3+0xaf>
