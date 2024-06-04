# RISC V 32 Prozessor

### Zusammenfassung, Besonderheiten und Erklärungen zu unseren Risc V 32 Prozessor umsetzung.
***Projekt von Hian Zing Voon (03762313), Arun Prema Murugavel (03787979), Yu-Hung Tsai (03760381) und Tiemo Schmidt (03758911)***

**Memory:** Wir haben die Memory als ein Array aus 65535 Zellen mit dem Datentyp bit_vector(31 downto 0) umgesetzt. Das führt leider zu Besondernheiten für die Load und Store Befehle. Da die Load und Store Befehle mit Byte großen Zellen arbeiten haben wir uns darauf festgelegt für den Nutzer es als ein Array mit 262.140 Zellen und bit_vector(7 downto 0) darzustellen. In dem Prozessor selber wird es dann auf die Hardware richtige Adresse umgerechnet. Da wir keine Short-Instructions haben werden die Instructions aus dem Inputfile ohne Probleme in die Memory mit aufsteigendem Index abgeSpeichert.

**Memory-Dump:** Zu finden in Trace.txt. Weil 65.535 einzelne Zellen ausgeben und überprüfen umständlich ist haben wir die letzten 1000 Zellen (als Hardware-Adresse 64535 to 65535, als software Adresse 258.140 to 262.140) als Ergebniss-Bereich derfiniert. Nur dieser Bereich wird in der Trace.txt Datei ausgegeben.

**Trace:** Zu finden in Trace.txt. Der Trace gibt den momentanen PC, OP-Code, Immidiet, Source-Register 1, Source-Register 2 und Destination-Register aus. Sollte für die jeweiligen Instruction einer dieser Attribute nicht gebraucht werden gibt er 0 aus. Es gibt nicht den Register Inhalt aus, was das überprüfen des richtigen Ausführen der Instruction nur über die Memory-Dump möglich macht.

**Input-File:** Wir haben uns auf einen simplen Assembler Code festgelegt. Die Opcodes müssen in Großbuchstaben geschrieben werden.	Wegen Besonderheiten beim lesen von Strings mit der Bibliothek std.textio haben wir festgelegt das der Op-Code immer 5 Zeichen lang sein muss. Der Op-Code LB muss dem entsprechen mit 3 Leerzeichen aufgefüllt werden. Der Code im Inputfile wird am Ende dieses Files nochmals mit Kommentaren stehen.

**Paths-for-Files:** Wir haben leider nicht herrausfinden können wie man relativ Paths in Vhdl umsetzt. Deswegen muss der Path für die Inputfile(Zeile 40 in System.vhd) und Outputfile(Zeile 41 in System.vhd) manuell geändert werden.

**Auxiliary-Package:** Das ist ein Paket, das hilft, um 'string' zu 'bit_vector' umzuwandeln und auch andersherum. Es ist sehr hilfreich beim Debuggen, weil man die gerade dekodierte 32-Bit Instruction als ein Output in 'string' darstellen kann.	Somit kann man den 'string' in Tcl console als 'report' ausgeben. 

**Mnemonics-Package:** Das ist ein Paket, um Opcodes wie "ADD" oder "XOR" in 'bit_vector' umzuwandeln, damit es bei der Dekodierung verwendet werden kann. 

### Inputfile-Testbench mit Kommentaren:
- Addi Test. 0+8 wird in reg6 abgespeichert
	*ADDI  0 8 6*
- SLTI Test. 8(in reg6)<9 dann 1 in Reg7 speichern
	*SLTI  6 9 7*
- SLTIU Test. 8(in reg6)<4.294.967.287(unsigned(-9)) dann 1 in Reg8 speichern
	*SLTIU 6 -9 8*

**Setup für weiter Instruction Tests**
- Speicher 47 (0010 1111) in Reg30 <br />
	*ADDI  0 47 30*
- Test ADDI. Speicher 218 (1101 0101) in Reg31<br />
	*ADDI  0 218 31*
- Test ANDI. 0010 1111 AND 1101 0101 = 0000 0101 (10)<br />
	*ANDI  30 218 9*
- Test ORI. 0010 1111 OR 1101 0101 = 1111 1111 (255)<br />
	*ORI  30 218 10*
- Test XORI. 0010 1111 OR 1101 0101 = 1111 1010 (250)<br />
	*XORI  30 218 11*
- Test ADDI. Speicher 2 in Reg9 (0010)<br />
	*ADDI  0 2 29*
- Test SLLI. Leftshift Reg29 5 mal und speichert in Reg12. 0001 0000 (16)<br />
	*SLLI  29 5 12*
- Test SRLI. Rightshift Reg12 (enthält 16) 4 mal. 0100 (4)<br />
	*SRLI  12 4 13*

**Setup für weitere Test**
- Lädt mit LUI und ADDI -253.745.698 in Reg7<br />
	*LUI  27 -61950*
	*ADDI  27 1502 27*
- Test SRAI. Arithmetic Rightshift Reg27 4 mal. -15.859.107<br />
	*SRAI  27 4 14*
- Testet LUI. Lädt 2.535.424 in Reg15<br />
	*LUI  15 619*
- Test AUIPC. Lädt 2.535.424 + 16 (momentaner PC) = 2.535.440<br />
	*AUIPC 16 619*
- Test Add. Reg6(8) + Reg7(1) = 9 in Reg17<br />
	*ADD  6 7 17*
- Test SLT. Reg6(8) SLT Reg7(1) = Reg18(16)<br />
	*SLT  6 7 18*
- Test SLTU. Reg6(8) SLTU Reg7(1) = Reg19(16)<br />
	*LTU  6 7 19*
- Test And. R30(0010 1111) AND R31(1101 1010) = R20(0000 1010)<br />
	*AND  30 31 20*
- Test And. R30(0010 1111) OR R31(1101 1010) = R20(1111 0101)<br />
	*OR  30 31 21*
- Test And. R30(0010 1111) XOR R31(1101 1010) = R20(1111 1111)<br />
	*XOR  30 31 22*
- Set Up für Shift Test<br />
	*ADDI  0 4 28*
- Test SLL Reg29(2) SLL Reg28(4) mal = Reg23(32)<br />
	*SLL  29 28 23*
- Test SLL Reg12(16) SLL Reg28(4) mal = Reg23(1)<br />
	*SRL  12 28 24*
- Test sub. Reg6(8) - Reg7(1) = Reg25(7)<br />
	*SUB  6 7 25*
- Test SRA Reg27(-253.745.698) SRA Reg28(4) = Reg26(-15.859.107)<br />
	*SRA  27 28 26*

**Setup für Store-Insturction**
- Speichert Adresse 64535*4 in Reg28<br />
	*LUI   28 63*<br />
	*ADDI  28 92 28*

- Die nächsten 4 SB speicher alle in die selbe 32Bit-Addresse aber an unterschiedlichen Byte
- Addr: 64535 | Inhalt: 167.837.960 (0000 1010 0000 0001 0000 0001 0000 1000)<br />
	*SB    28 6 0* 	--Speichert 8 (0000 1000)<br />
	*SB    28 7 1*	--Speichert 1 (0000 0001)<br />
	*SB    28 8 2*	--Speichert 1 (0000 0001)<br />
	*SB    28 9 3*	--Speichert 10(0000 1010)
- Die nächsten 2 SH Instructions speicher auf die selbe 32Bit-Addresse
- Addr: 64536 | Inhalt: 16.056.575 (0000 0000 1111 0101 0000 0000 1111 1111)<br />
	*SH    28 10 4*	--Speichert 32(0000 0000 1111 1111)<br />
	*SH    28 11 6*	--Speichert 2 (0000 0000 1111 0101)
- Store Word Befehle. Jeder SW Speichert in eine eigene SW. _Imm_ steigt um 4, weil wir hier mit Byte Adressen arbeiten<br />
	*SW    28 12 8*	--Speichert 32 (0010 0000) vom SLLI<br />
	*SW    28 13 12*	--Speichert 2  (0000 0010) vom SRLI<br />
	*SW    28 14 16*	--Speichert -15.859.107 (1111 1111 0000 1110 0000 0010 0101 1101) vom SRAI <br />
	*SW    28 15 20*	--Speichert 2.535.424 (Vom LUI Befehl)<br />
	*SW    28 16 24*	--Speichert 2.535.440 (Vom AUIPC Befehl)<br />
	*SW    28 17 28*	--Speichert 9 vom ADD<br />
	*SW    28 18 32*	--Speichert 16 (0001 0000) vom SLT<br />
	*SW    28 19 36*	--Speichert 16 (0001 0000) vom SLTU<br />
	*SW    28 20 40*	--Speichert 10 (0000 1010) vom AND<br />
	*SW    28 21 44*	--Speichert 255(1111 1111) vom OR<br />
	*SW    28 22 48*	--Speichert 245(1111 0101) vom XOR<br />
	*SW    28 23 52*	--Speichert 16 (0001 0000) vom SLL<br />
	*SW    28 24 56*	--Speichert 2  (0000 0010) vom SRL<br />
	*SW    28 25 60*	--Speichert 7 vom Sub<br />
	*SW    28 26 64*	--Speichert -15.859.107 (1111 1111 0000 1110 0000 0010 0101 1101) vom SRA 

**Testbereich von Jump und Branch Instructions**
- **Setup**
	*ADDI  0 0 6*	--Setzt Rg6 auf 0<br />
	*ADDI  0 4 7* 	--Setzt Rg6 auf 7<br />
	*NOP*   		--PC auf den gesprungen wird<br />
	*BEQ   6 7 12*	--Vergleicht RG6 und Rg7. Wenn Equal springt 3 Instruction nach vorne<br />
	*ADDI  6 1 6*	--Addiert auf Rg6 1 drauf<br />
	*JAL   0 -12*	--Springt 3 Instructions zurück(12Adressen). Speichert nächste Adresse(PC+4) in Rg0(Hardwired 0)<br />
	*NOP*<br />
	*BNE   6 7 12*	--Jumps 3 Instructions ahead <br />
	*ADDI  6 -1 6*	--subtracts 1 From Rg6 so that its no longer equal to Rg7<br />
	*JAL   0 -12*	--Jumps 3 Instructions back<br />
	*BLT   7 6 12*	--Jumps 3 Instructions if Rg7 is less than Rg6<br />
	*ADDI  6 1 6*<br />
	*JAL   0 12*<br />
	*BGE   6 7 12*	--Rg6 should be greater than Rg7, so next two NOP should be ignored and not appeare in trace<br />
	*NOP*<br />		
	*NOP*

- **Same Test as before but with unsigned number**
	*ADDI  0 0 6*	--Setzt Rg6 auf 0<br />
	*ADDI  0 4 7* 	--Setzt Rg6 auf 7<br />
	*NOP*   		--PC auf den gesprungen wird<br />
	*BLTU  7 6 12*	--Jumps 3 Instructions if Rg7 is less than Rg6<br />
	*ADDI  6 1 6*<br />
	*JAL   0 12*<br />
	*BGEU  6 7 12*	--Rg6 should be greater than Rg7, so next two _NOP_ should be ignored and not appear in trace<br />
	*NOP*<br />   		
	*NOP*

- **Load Instruction Test**
- Adress: 64551*4 or Rg28 + 64 has a -15.859.107 (1111 1111 0000 1110 0000 0010 0101 1101)<br />
*LBU   28 8 64* 	--LBU niedrigster Byte von der obrigen Zahl 93(0101 1101) in Rg8 <br />
*SW    28 8 68* 	--Speichert Rg8(93) in 64552*4<br />
*LBU   28 8 67* 	--LBU 2 Höchster Byte von der obrigen Zahl 255(1111 1111) in Rg8 <br />
*SW    28 8 72* 	--Speichert Rg8(255) in 64553*4
- LB ohne unsigned testen<br />
*LB    28 8 67* 	--LBU Höchster Byte von der obrigen Zahl -1(1111 1111) in Rg8 <br />
*SW    28 8 76* 	--Speichert Rg8(-1) in 64554*4
- LH <br />
*LH    28 8 66*	--LH die zwei höchsten byte -242(1111 1111 0000 1110)<br />
*SW    28 8 80* 	--Speichert Rg8(-242) in 64555*4<br />
*LHU   28 8 66* 	--LHU die zwei höchsten Byte 65.294(1111 1111 0000 1110)<br />
*SW    28 8 84*	--Speichert Rg8(65.294) in 64556*4
- LW<br />
*LW    28 8 66*   --Lädt die ganze Zahl von oben -15.859.107 (1111 1111 0000 1110 0000 0010 0101 1101)<br />
*SW    28 8 88*	--Speichert  Rg8(-15.859.107) in 64557*4

- **Test SB bei vollem Register Rg8**
*SB    28 8 92*   --Sollte unterste Byte 93(0101 1101) in 64558*4 speichern<br />
*stop* --Signalisiert Ende der Input datei und stop simulation mit wait



