SH          EQU   19H		   ;��ʾ����
DAT         EQU   20H		   ;����Ĵ�
DAT1        EQU   21H		   ;�洢����
DAT2        EQU   22H
DAT3        EQU   23H
DAT4        EQU   24H
DATS        EQU   25H		   ;����Ĵ�
DAT01       EQU   26H          ;��������
DAT02       EQU   27H
DAT03       EQU   28H
DAT04       EQU   29H
FLAG1       EQU   30H		   ;ȷ�ϼ�a�����Ʊ�־λ
FLAG2	    EQU   31H		   ;ȷ�ϼ�a�ı�־λ
FLAG3       EQU   32H          ;����У���־λ
FLAG4       EQU   33H		   ;�����޸ı�־λ
PA          EQU   8000H            
PB          EQU   8001H
PCO         EQU   8002H
PCTL        EQU   8003H

            ORG    0000H
            LJMP   MAIN

	        ORG    0003H
            LJMP   INT

MAIN:       MOV    SP,#60H			   ;��ջָ���ַ����
            MOV    R7,#4			   ;��ʾ����λ���Ĵ�����ʼ��
            MOV    R2,#0	 		   ;��������ȷ�ϱ�־λ
	        MOV    SH,#7FH			   ;LED�������ʾ8
	        MOV    DAT,#00H			   ;����Ĵ�����ʼ��
	        MOV    DAT1,#06H		   ;1
	        MOV    DAT2,#5BH		   ;2
	        MOV    DAT3,#4FH		   ;3
	        MOV    DAT4,#66H		   ;4
	        MOV    DAT01,#00H
	        MOV    DAT02,#00H
	        MOV    DAT03,#00H
	        MOV    DAT04,#00H
            MOV    DPTR,#PCTL		   ;LED����ܳ�ʼ��
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
	        MOV    A,#0BBH			  ;ȷ�ϼ�a���
	        CJNE   A,B,KB33
            MOV    R6,FLAG1
	        CJNE   R6,#1,KB33
	        MOV	   FLAG2,#1
            MOV    R2,#0
	        LJMP   SCAN
KB33:       MOV    A,#7BH			  ;�˸��b���
            CJNE   A,B,KB34
            INC    R7
	        CJNE   R7,#5,KB333
	        MOV    R7,#4
	        MOV    R2,#0
KB333:	    LJMP   SCAN
KB34:	    MOV    A,B
            ANL    A,#0FH              ;����e~f
	        CJNE   A,#08H,KB4
	        MOV    R2,#0
            LJMP   SCAN

KB4:	    CJNE   R7,#0,KB44		   ;���������ټ��
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
            
	        ;��ʾ����
SCAN:       CJNE   R2,#1,SKIP		          ;û��������������ֱ����ʾ
            MOV    R2,#0
    	    CJNE   R7,#0,NEXT		          ;�������û����������Ĵ�����1
    	    JMP    SKIP                       ;������������ֱ����ʾ
NEXT:	    DEC    R7
SKIP:	    CJNE   R7,#3,NEXT1				  ;��־λΪ3����ʾ1����

            MOV    A,#04H
    	    MOV    DATS,SH				  
    	    LCALL  PRO
    	    MOV    DAT01,DAT				  ;����洢
    	    LJMP   STAR

NEXT1:	    CJNE   R7,#2,NEXT2				  ;��־λΪ2����ʾ2����
    	    MOV    A,#04H
    	    MOV    DATS,SH
    	    LCALL  PRO
    	    MOV    DAT02,DAT				  ;����洢
    	    MOV    A,#08H
    	    MOV    DATS,SH
    	    LCALL  PRO
    	    LJMP   STAR

NEXT2:	    CJNE   R7,#1,NEXT3				  ;��־λΪ1����ʾ3����

            MOV    A,#04H
    	    MOV    DATS,SH
    	    LCALL  PRO
    	    MOV    DAT03,SH  				  ;����洢
    	    MOV    A,#08H
    	    MOV    DATS,SH
    	    LCALL  PRO
    	    MOV    A,#01H
	        MOV    DATS,SH
	        LCALL  PRO
    	    LJMP   STAR

BACK11:     LJMP   BACK1

NEXT3:	    MOV    A,#04H					  ;��ʾ4����
    	    MOV    DATS,SH
    	    LCALL  PRO						  
	        MOV    DAT04,DAT				  ;����洢
    	    MOV    A,#08H
    	    MOV    DATS,SH
    	    LCALL  PRO
    	    MOV    A,#01H
    	    MOV    DATS,SH
    	    LCALL  PRO
    	    MOV    A,#02H
    	    MOV    DATS,SH
    	    LCALL  PRO
	        MOV    FLAG1,#1					  ;������ȷ�ϼ�
	        MOV    R6,FLAG2
	        CJNE   R6,#1,BACK11			      ;ȷ�ϼ�a�Ƿ���
	        MOV    FLAG2,#0
	        MOV    FLAG1,#0
	        MOV    R7,#4

	        MOV    R6,FLAG3
	        CJNE   R6,#1,PWI		           ;�����޸�
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
            CJNE   A,DAT1,BACK			       ;����У��
	        MOV    A,DAT02
	        CJNE   A,DAT2,BACK
	        MOV    A,DAT03
	        CJNE   A,DAT3,BACK
	        MOV    A,DAT04
	        CJNE   A,DAT4,BACK
	        POP    ACC                         					  
	        LCALL  TBEEP			            ;����У��ͨ��
	        MOV    R6,FLAG4
	        CJNE   R6,#1,PWI1			        
    	    MOV    FLAG3,#1						;���������޸�
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

	        ;16ms��ʱ
DELY:	    PUSH   00H
            PUSH   01H
            MOV    R0,#10H
DELY0:	    MOV    R1,#250
DELY1:	    DJNZ   R1,DELY1
    	    DJNZ   R0,DELY0
	        POP    01H
	        POP    00H
    	    RET

	        ;0.5s��ʱ
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

	        ;�������������
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

	        ;������
LBEEP:      CLR    P3.4						
            LCALL  DELAY
	        LCALL  DELAY
	        SETB   P3.4
	        RET

	        ;��ȷ������
TBEEP:      CLR    P3.4
	        LCALL  DELAY
	        SETB   P3.4
	        LCALL  DELAY
            CLR    P3.4
	        LCALL  DELAY
	        SETB   P3.4	 
	        RET

	        ;PC��ʾ
PR:         MOV    A,#04H
    	    MOV    DATS,#39H			 ;C
    	    LCALL  PRO
    	    MOV    A,#08H
    	    MOV    DATS,#73H			 ;P
    	    LCALL  PRO
	        RET

	        ;PE��ʾ
PWR:        MOV    A,#04H
    	    MOV    DATS,#79H			 ;E
    	    LCALL  PRO
    	    MOV    A,#08H
    	    MOV    DATS,#73H			 ;P
    	    LCALL  PRO
	        RET

            ;�жϷ������
INT:	    LCALL  TBEEP   	   
	        LCALL  TBEEP
	        MOV    FLAG4,#1				 ;���������޸�״̬
	        MOV    SH,#0FFH				 ;������״̬
	        RETI

TAB:	    DB     0EEH,0DEH,0BEH,7EH,0EDH,0DDH,0BDH,7DH
	        DB     0EBH,0DBH,0BBH,7BH,0E7H,0D7H,0B7H,77H,00H

TAB1:	    DB     3FH,06H,5BH,4FH,66H,6DH,7DH,07H
	        DB     7FH,6FH,77H,7CH,58H,5EH,79H,71H

	        END