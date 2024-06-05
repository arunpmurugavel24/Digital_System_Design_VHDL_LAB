Zusammenfassung, Besonderheiten und Erklärungen zu unseren Risc_V Prozessor umsetzung.
	Projekt von Hian zing Voon, Arun Murugavel, Yu-Hung TSAI und Tiemo Schmidt


-------------
Made by Tiemo Schmidt, Hian zing Voon, Arun Murugavel, Yu-Hung TSAI
-------------
Memory: Wir haben die Memory als ein Array aus 65535 Zellen mit dem Datentyp bit_vector(31 downto 0) umgesetzt.
	Das führt leider zu Besondernheiten für die Load und Store Befehle. Da die Load und Store Befehle mit Byte großen Zellen arbeiten
	haben wir uns darauf festgelegt für den Nutzer es als ein Array mit 262.140 Zellen und bit_vector(7 downto 0) darzustellen.
	In dem Prozessor selber wird es dann auf die Hardware richtige Adresse umgerechnet. Da wir keine Short-Instructions haben 
	werden die Instructions aus dem Inputfile ohne Probleme in die Memory mit aufsteigendem Index abgespeichert.

Memory-Dump: Zu finden in Trace.txt. Weil 65.535 einzelne Zellen ausgeben und überprüfen umständlich ist haben wir die letzten 1000 Zellen 
	(als Hardware-Adresse 64535 to 65535, als software Adresse 258.140 to 262.140) als Ergebniss-Bereich derfiniert. 
	Nur dieser Bereich wird in der Trace.txt Datei ausgegeben.

Trace: 	Zu finden in Trace.txt. Der Trace gibt den momentanen PC, OP-Code, Immidiet, Source-Register 1, Source-Register 2 und
	Destination-Register aus. Sollte für die jeweiligen Instruction einer dieser Attribute nicht gebraucht werden gibt er 0 aus.
	Es gibt nicht den Register Inhalt aus, was das überprüfen des richtigen Ausführen der Instruction nur über die Memory-Dump 
	möglich macht. (wäre umsetzbar mit der auxilary function bitvectorTOstring())

Input-File: Wir haben uns auf einen simplen Assembler Code festgelegt. Die Opcodes müssen in Großbuchstaben geschrieben werden. 
	Wegen Besonderheiten beim lesen von Strings mit der Bibliothek std.textio haben wir festgelegt das der Op-Code immer 5 Zeichen lang sein muss. 
	Der Op-Code LB muss dem entsprechen mit 3 Leerzeichen aufgefüllt werden. Der Code im Inputfile wird am Ende dieses Files nochmals mit Kommentaren stehen.

Paths-for-Files: Wir haben leider nicht herrausfinden können wie man relativ Paths in Vhdl umsetzt. Deswegen muss der Path 
	für die Inputfile(Zeile 41 in System.vhd) und Outputfile(Zeile 41 in System.vhd) manuell geändert werden.

Auxiliary-Package: Das ist ein Paket, das hilft, um 'string' zu 'bit_vector' umzuwandeln und auch andersherum. 
	Es ist sehr hilfreich beim Debuggen, weil man die gerade dekodierte 32-Bit Instruction als ein Output in 'string' darstellen kann.
	Somit kann man den 'string' in Tcl console als 'report' ausgeben. 

Mnemonics-Package: Das ist ein Paket, um Mnemonics wie "ADD" oder "XOR" zu Opcodes wie "0110011" in 'string' umzuwandeln, danach zu 'bit_vector' mithilfe von Auxiliary-Package.
				   Somit kann die Dekodierung von Rohtext zu 32-bit (bit_vector) diese Opcodes direkt verwenden. 

System.vhd: Hier wird der Prozessor simuliert. Die Instruction werden aus der Mem geholt und ausgeführt.



-------------
Made by Tiemo Schmidt
-------------
Inputfile-Testbench mit Kommentaren:
-----------------------------------------
--Addi Test. 0+8 wird in reg6 abgespeichert
ADDI  0 8 6
--SLTI Test. 8(in reg6)<9 dann 1 in Reg7 speichern
SLTI  6 9 7
--SLTIU Test. 8(in reg6)<4.294.967.287(unsigned(-9)) dann 1 in Reg8 speichern
SLTIU 6 -9 8
--Setup für weiter Instruction Tests
--Speicher 47 (0010 1111) in Reg30
ADDI  0 47 30
--Test ADDI. Speicher 218 (1101 0101) in Reg31
ADDI  0 218 31
--Test Andi. 0010 1111 AND 1101 0101 = 0000 0101 (10)
ANDI  30 218 9
--Test ORI. 0010 1111 OR 1101 0101 = 1111 1111 (255)
ORI   30 218 10
--Test XORI. 0010 1111 OR 1101 0101 = 1111 1010 (250)
XORI  30 218 11
--Test ADDI. Speicher 2 in Reg9 (0010)
ADDI  0 2 29
--Test SLLI. Leftshift Reg29(2) 5 mal und speichert in Reg12. 0100 0000 (64)
SLLI  29 5 12
--Test SRLI. Rightshift Reg12 (enthält 16) 4 mal. 0100 (4) 
SRLI  12 4 13
--Setup für weitere Test
--Lädt mit LUI und ADDI -253.745.698 in Reg27
LUI   27 986.626
ADDI  27 1502 27
--Test SRAI. Arithmetic Rightshift Reg27 4mal. -15.859.107
SRAI  27 4 14
--Testet LUI. Lädt 2.535.424 in Reg15
LUI   15 619
--Test AUIPC. Lädt 2.535.424+16(momentaner PC)=2.535.440
AUIPC 16 619
--Test Add. Reg6(8)+Reg7(1)=9 in Reg17
ADD   6 7 17
--Test SLT. Reg6(8) SLT Reg7(1) = Reg18(1)
SLT   7 6 18
--Test SLTU. Reg6(8) SLTU Reg7(1) = Reg19(0)
SLTU  7 6 19
--Test And. R30(0010 1111) AND R31(1101 1010) = R20(0000 1010)
AND   30 31 20
--Test And. R30(0010 1111) OR R31(1101 1010) = R20(1111 0101)
OR    30 31 21
--Test And. R30(0010 1111) XOR R31(1101 1010) = R20(1111 1111)
XOR   30 31 22
--Set Up für Shift Test
ADDI  0 4 28
--Test SLL Reg29(2) SLL Reg28(4)mal = Reg23(32)
SLL   29 28 23
--Test SLL Reg12(16) SLL Reg28(4)mal = Reg23(1)
SRL   12 28 24
--Test sub. Reg6(8) - Reg7(1) = Reg25(7) 
SUB   6 7 25
--Test SRA Reg27(-253.745.698) SRA Reg28(4) = Reg26(-15.859.107)
SRA   27 28 26

--Setup für Store-Insturction
--Speichert Adresse 64535*4 in Reg28
LUI   28 63
ADDI  28 92 28

--die nächsten 4 SB speicher alle in die selbe 32Bit-Addresse aber an unterschiedlichen Byte
--Addr:64535 | Inhalt: 167.837.960 (0000 1010 0000 0001 0000 0001 0000 1000) 
SB    28 6 0 	--speichert 8 (0000 1000)
SB    28 7 1	--speichert 1 (0000 0001) 
SB    28 8 2	--speichert 1 (0000 0001)
SB    28 9 3	--speichert 10(0000 1010)
--die nächsten 2 SH Instructions speicher auf die selbe 32Bit-Addresse
--Addr:64536 | Inhalt: 16.056.575 (0000 0000 1111 0101 0000 0000 1111 1111)
SH    28 10 4	--speichert 32(0000 0000 1111 1111) 
SH    28 11 6	--speichert 2 (0000 0000 1111 0101)
--Store Word Befehle. Jeder Sw speichert in eine eigene SW. Imm steigt um 4, weil wir hier mit Byte Adressen arbeiten
SW    28 12 8	--Speichert 64 (0100 0000) vom SLLI
SW    28 13 12	--Speichert 4  (0000 0100) vom SRLI
SW    28 14 16	--Speichert -15.859.107 (1111 1111 0000 1110 0000 0010 0101 1101) vom SRAI 
SW    28 15 20	--Speichert 2.535.424 (Vom LUI Befehl)
SW    28 16 24	--Speichert 2.535.440 (Vom AUIPC Befehl)
SW    28 17 28	--Speichert 9 vom ADD
SW    28 18 32	--Speichert 1 vom SLT
SW    28 19 36	--Speichert 1 vom SLTU
SW    28 20 40	--Speichert 10 (0000 1010) vom AND
SW    28 21 44	--Speichert 255(1111 1111) vom OR
SW    28 22 48	--Speichert 245(1111 0101) vom XOR
SW    28 23 52	--Speichert 32 (0010 0000) vom SLL
SW    28 24 56	--Speichert 4  (0000 0100) vom SRL
SW    28 25 60	--Speichert 7 vom Sub
SW    28 26 64	--Speichert -15.859.107 (1111 1111 0000 1110 0000 0010 0101 1101) vom SRA 

--Testbereich von Jump und Branch Instructions
--Setup
ADDI  0 0 6	--setzt Rg6 auf 0
ADDI  0 4 7 	--setzt Rg6 auf 7
nop   		--PC auf den gesprungen wird
BEQ   6 7 12	--vergleicht RG6 und Rg7. Wenn Equal springt 3 Instruction nach vorne
ADDI  6 1 6	--addiert auf Rg6 1 drauf
jal   0 -12	--springt 3 Instructions zurück(12Adressen). Speichert nächste Adresse(PC+4) in Rg0(Hardwired 0)
nop
BNE   6 7 12	--Jumps 3 Instructions ahead 
ADDI  6 -1 6	--subtracts 1 From Rg6 so that its no longer equal to Rg7
JAL   0 -12	--Jumps 3 Instructions back
BLT   7 6 12	--Jumps 3 Instructions if Rg7 is less than Rg6
ADDI  6 1 6
JAL   0 12
BGE   6 7 12	--Rg6 should be greater than Rg7, so next two nop should be ignored and not appeare in trace
nop		
nop

--Same Test as before but with unsigned nr
ADDI  0 0 6	--setzt Rg6 auf 0
ADDI  0 4 7 	--setzt Rg6 auf 7
nop   		--PC auf den gesprungen wird
BLTU  7 6 12	--Jumps 3 Instructions if Rg7 is less than Rg6
ADDI  6 1 6
JAL   0 12
BGEU  6 7 12	--Rg6 should be greater than Rg7, so next two nop should be ignored and not appeare in trace
nop   		
nop   
        
--Load Instruction Test
--Adress: 64551*4 or Rg28 + 64 has a -15.859.107 (1111 1111 0000 1110 0000 0010 0101 1101)
LBU   28 8 64 	--LBU niedrigster Byte von der obrigen Zahl 93(0101 1101) in Rg8 
SW    28 8 68 	--speichert Rg8(93) in 64552*4
LBU   28 8 67 	--LBU 2 Höchster Byte von der obrigen Zahl 255(1111 1111) in Rg8 
SW    28 8 72 	--speichert Rg8(255) in 64553*4
--LB ohne unsigned testen
LB    28 8 67 	--LBU Höchster Byte von der obrigen Zahl -1(1111 1111) in Rg8 
SW    28 8 76 	--speichert Rg8(-1) in 64554*4
--LH 
LH    28 8 66	--LH die zwei höchsten byte -242(1111 1111 0000 1110)
SW    28 8 80 	--speichert Rg8(-242) in 64555*4
LHU   28 8 66 	--LhU die zwei höchsten Byte 65.294(1111 1111 0000 1110)
SW    28 8 84	--speichert Rg8(65.294) in 64556*4
--LW
LW    28 8 64   --Lädt die ganze Zahl von oben -15.859.107 (1111 1111 0000 1110 0000 0010 0101 1101)
SW    28 8 88	--Speichert  Rg8(-15.859.107) in 64557*4
--Test SB bei vollem Register Rg8
LW    28 8 64
SB    28 8 92   --sollte unterste Byte 93(0101 1101) in 64558*4 speichern
stop   		--signalisiert Ende der Input datei und stop simulation mit wait



---------------------------
Was rauskommen sollte:
--------Memory DUMP--------
address|mem-Content
---------------------------
64535  |167837960  
64536  |16056575   
64537  |64         
64538  |4          
64539  |-15.859.107
64540  |2535424    
64541  |2535440    
64542  |9          
64543  |1
64544  |1
64545  |10         
64546  |255        
64547  |245        
64548  |32         
64549  |4          
64550  |7          
64551  |-15859107  
64552  |93         
64553  |255        
64554  |-1         
64555  |-242       
64556  |65294      
64557  |-15859619  
64558  |93         

