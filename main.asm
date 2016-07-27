SH          EQU   19H		   ;显示内容
DAT         EQU   20H		   ;密码寄存
DAT1        EQU   21H		   ;存储密码
DAT2        EQU   22H
DAT3        EQU   23H
DAT4        EQU   24H
DATS        EQU   25H		   ;密码寄存
DAT01       EQU   26H          ;输入密码
DAT02       EQU   27H
DAT03       EQU   28H
DAT04       EQU   29H
FLAG1       EQU   30H		   ;确认键a的限制标志位
FLAG2	    EQU   31H		   ;确认键a的标志位
FLAG3       EQU   32H          ;密码校验标志位
FLAG4       EQU   33H		   ;密码修改标志位
PA          EQU   8000H            
PB          EQU   8001H
PCO         EQU   8002H
PCTL        EQU   8003H

            ORG    0000H
            LJMP   MAIN

	        ORG    0003H
            LJMP   INT

MAIN:       MOV    SP,#60H			   ;堆栈指针地址设置
            MOV    R7,#4			   ;显示数字位数寄存器初始化
            MOV    R2,#0	 		   ;数字输入确认标志位
	        MOV    SH,#7FH			   ;LED数码管显示8
	        MOV    DAT,#00H			   ;密码寄存器初始化
	        MOV    DAT1,#06H		   ;1
	        MOV    DAT2,#5BH		   ;2
	        MOV    DAT3,#4FH		   ;3
	        MOV    DAT4,#66H		   ;4
	        MOV    DAT01,#00H
	        MOV    DAT02,#00H
	        MOV    DAT03,#00H
	        MOV    DAT04,#00H
            MOV    DPTR,#PCTL		   ;LED数码管初始化
            MOV    A,#88H
            MOVX   @DPTR,A
            MOV    DPTR,#PB
            MOV    A,#0FH
            MOVX   @DPTR,A
	        MOV    DPTR,#PA
     	    MOV    A,#00H
    	    MOVX   @DPTR,A

STAR:       MOV    DPTR,#PCO
            MOV    A,#0F0H
    	    MOVX   @DPTR,A
KB1:	    MOV    DPTR,#PCO
            MOVX   A,@DPTR
    	    CJNE   A,#0F0H,KB2
    	    LJMP   SCAN
KB2:	    MOV    R2,#1
            MOV    B,#0FEH
KB22:	    MOV    DPTR,#PCO
            MOV    A,B
    	    MOVX   @DPTR,A
    	    MOV    DPTR,#PCO
    	    MOVX   A,@DPTR
    	    ANL    A,#0F0H
    	    CJNE   A,#0F0H,KB3
    	    MOV    A,B
    	    RL     A
    	    MOV    B,A
    	    JMP    KB22

KB3:	    ANL    B,#0FH
    	    ORL    B,A
    	    MOV    R3,#0
    	    MOV    DPTR,#TAB
	        MOV    A,#0BBH			  ;确认键a检测
	        CJNE   A,B,KB33
            MOV    R6,FLAG1
	        CJNE   R6,#1,KB33
	        MOV	   FLAG2,#1
            MOV    R2,#0
	        LJMP   SCAN
KB33:       MOV    A,#7BH			  ;退格键b检测
            CJNE   A,B,KB34
            INC    R7
	        CJNE   R7,#5,KB333
	        MOV    R7,#4
	        MOV    R2,#0
KB333:	    LJMP   SCAN
KB34:	    MOV    A,B
            ANL    A,#0FH              ;禁用e~f
	        CJNE   A,#08H,KB4
	        MOV    R2,#0
            LJMP   SCAN

KB4:	    CJNE   R7,#0,KB44		   ;输入满后不再检测
	        MOV    R2,#0
            LJMP   SCAN
KB44:       MOV    A,R3
    	    MOVC   A,@A+DPTR
    	    JNZ    KB5
    	    JMP    KB1
KB5:	    CJNE   A,B,CON
    	    LCALL  DELY
    	    MOV    DPTR,#TAB1
    	    MOV    A,R3
    	    MOVC   A,@A+DPTR
    	    MOV    DAT,A
    	    MOV    DPTR,#PCO
    	    MOV    A,#0F0H
    	    MOVX   @DPTR,A
WAIT:	    MOVX   A,@DPTR
    	    CJNE   A,#0F0H,WAIT
    	    CALL   DELY
    	    LJMP   STAR
CON:	    INC    R3
    	    JMP    KB4
            
	        ;显示数据
SCAN:       CJNE   R2,#1,SKIP		          ;没有新数字输入则直接显示
            MOV    R2,#0
    	    CJNE   R7,#0,NEXT		          ;如果数字没有输入满则寄存器减1
    	    JMP    SKIP                       ;数字输入满则直接显示
NEXT:	    DEC    R7
SKIP:	    CJNE   R7,#3,NEXT1				  ;标志位为3则显示1个数

            MOV    A,#04H
    	    MOV    DATS,SH				  
    	    LCALL  PRO
    	    MOV    DAT01,DAT				  ;密码存储
    	    LJMP   STAR

NEXT1:	    CJNE   R7,#2,NEXT2				  ;标志位为2则显示2个数
    	    MOV    A,#04H
    	    MOV    DATS,SH
    	    LCALL  PRO
    	    MOV    DAT02,DAT				  ;密码存储
    	    MOV    A,#08H
    	    MOV    DATS,SH
    	    LCALL  PRO
    	    LJMP   STAR

NEXT2:	    CJNE   R7,#1,NEXT3				  ;标志位为1则显示3个数

            MOV    A,#04H
    	    MOV    DATS,SH
    	    LCALL  PRO
    	    MOV    DAT03,SH  				  ;密码存储
    	    MOV    A,#08H
    	    MOV    DATS,SH
    	    LCALL  PRO
    	    MOV    A,#01H
	        MOV    DATS,SH
	        LCALL  PRO
    	    LJMP   STAR

BACK11:     LJMP   BACK1

NEXT3:	    MOV    A,#04H					  ;显示4个数
    	    MOV    DATS,SH
    	    LCALL  PRO						  
	        MOV    DAT04,DAT				  ;密码存储
    	    MOV    A,#08H
    	    MOV    DATS,SH
    	    LCALL  PRO
    	    MOV    A,#01H
    	    MOV    DATS,SH
    	    LCALL  PRO
    	    MOV    A,#02H
    	    MOV    DATS,SH
    	    LCALL  PRO
	        MOV    FLAG1,#1					  ;允许检测确认键
	        MOV    R6,FLAG2
	        CJNE   R6,#1,BACK11			      ;确认键a是否按下
	        MOV    FLAG2,#0
	        MOV    FLAG1,#0
	        MOV    R7,#4

	        MOV    R6,FLAG3
	        CJNE   R6,#1,PWI		           ;密码修改
	        MOV    FLAG3,#0
	        MOV    FLAG4,#0
            MOV    A,DAT04					  
	        MOV    DAT4,A
            MOV    A,DAT03
	        MOV    DAT3,A
	        MOV    A,DAT02
	        MOV    DAT2,A
            MOV    A,DAT01
	        MOV    DAT1,A
	        MOV    SH,#7FH
	        LCALL  TBEEP
     	    LJMP   STAR

PWI:	    PUSH   ACC
            MOV    A,DAT01				   
            CJNE   A,DAT1,BACK			       ;密码校验
	        MOV    A,DAT02
	        CJNE   A,DAT2,BACK
	        MOV    A,DAT03
	        CJNE   A,DAT3,BACK
	        MOV    A,DAT04
	        CJNE   A,DAT4,BACK
	        POP    ACC                         					  
	        LCALL  TBEEP			            ;密码校验通过
	        MOV    R6,FLAG4
	        CJNE   R6,#1,PWI1			        
    	    MOV    FLAG3,#1						;允许密码修改
	        LJMP   STAR	
PWI1:	    PUSH   00H
	        PUSH   06H
	        PUSH   07H
            MOV    R0,#10
PR0:        MOV    R7,#100
PR1:	    MOV    R6,#250
	        LCALL  PR
	        DJNZ   R7,PR1
	        DJNZ   R0,PR0
	        POP    07H
	        POP    06H   
	        LJMP   STAR
					  
BACK:       POP    ACC
            LCALL  LBEEP
	        PUSH   00H
	        PUSH   06H
	        PUSH   07H
            MOV    R0,#10
PWR0:       MOV    R7,#100
PWR1:	    MOV    R6,#250
	        LCALL  PWR
	        DJNZ   R7,PWR1
	        DJNZ   R0,PWR0
	        POP    07H
	        POP    06H   

BACK1:      LJMP   STAR

	        ;16ms延时
DELY:	    PUSH   00H
            PUSH   01H
            MOV    R0,#10H
DELY0:	    MOV    R1,#250
DELY1:	    DJNZ   R1,DELY1
    	    DJNZ   R0,DELY0
	        POP    01H
	        POP    00H
    	    RET

	        ;0.5s延时
DELAY:      PUSH   00H
            PUSH   06H
	        PUSH   07H
	        MOV    R0,#5
DELAY0:     MOV    R7,#100
DELAY1:	    MOV    R6,#250
	        DJNZ   R6,$
	        DJNZ   R7,DELAY1
	        DJNZ   R0,DELAY0
	        POP    07H
	        POP    06H
	        POP    00H
	        RET

	        ;数码管数据输入
PRO:        PUSH   05H
            MOV    DPTR,#PB
            MOVX   @DPTR,A
    	    MOV    DPTR,#PA
    	    MOV    A,DATS
    	    MOVX   @DPTR,A
    	    MOV    R5,#100
    	    DJNZ   R5,$
	        POP    05H
            RET

	        ;错误长鸣
LBEEP:      CLR    P3.4						
            LCALL  DELAY
	        LCALL  DELAY
	        SETB   P3.4
	        RET

	        ;正确两次鸣
TBEEP:      CLR    P3.4
	        LCALL  DELAY
	        SETB   P3.4
	        LCALL  DELAY
            CLR    P3.4
	        LCALL  DELAY
	        SETB   P3.4	 
	        RET

	        ;PC显示
PR:         MOV    A,#04H
    	    MOV    DATS,#39H			 ;C
    	    LCALL  PRO
    	    MOV    A,#08H
    	    MOV    DATS,#73H			 ;P
    	    LCALL  PRO
	        RET

	        ;PE显示
PWR:        MOV    A,#04H
    	    MOV    DATS,#79H			 ;E
    	    LCALL  PRO
    	    MOV    A,#08H
    	    MOV    DATS,#73H			 ;P
    	    LCALL  PRO
	        RET

            ;中断服务程序
INT:	    LCALL  TBEEP   	   
	        LCALL  TBEEP
	        MOV    FLAG4,#1				 ;进入密码修改状态
	        MOV    SH,#0FFH				 ;带附点状态
	        RETI

TAB:	    DB     0EEH,0DEH,0BEH,7EH,0EDH,0DDH,0BDH,7DH
	        DB     0EBH,0DBH,0BBH,7BH,0E7H,0D7H,0B7H,77H,00H

TAB1:	    DB     3FH,06H,5BH,4FH,66H,6DH,7DH,07H
	        DB     7FH,6FH,77H,7CH,58H,5EH,79H,71H

	        END