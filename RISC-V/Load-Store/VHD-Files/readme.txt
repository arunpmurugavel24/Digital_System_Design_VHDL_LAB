Zusammenfassung, Besonderheiten und Erklärungen zu unseren Risc_V Prozessor umsetzung.
	Projekt von Hian zing Voon, Arun Murugavel, Yu-Hung TSAI und Tiemo Schmidt

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
	möglich macht.

Input-File: Wir haben uns auf einen simplen Assembler Code festgelegt. Die Opcodes müssen in Großbuchstaben geschrieben werden. 
	Wegen Besonderheiten beim lesen von Strings mit der Bibliothek std.textio haben wir festgelegt das der Op-Code immer 5 Zeichen lang sein muss. 
	Der Op-Code LB muss dem entsprechen mit 3 Leerzeichen aufgefüllt werden. Der Code im Inputfile wird am Ende dieses Files nochmals mit Kommentaren stehen.

Paths-for-Files: Wir haben leider nicht herrausfinden können wie man relativ Paths in Vhdl umsetzt. Deswegen muss der Path 
	für die Inputfile(Zeile 40 in System.vhd) und Outputfile(Zeile 41 in System.vhd) manuell geändert werden.

Auxiliary-Package: Das ist ein Paket, das hilft, um 'string' zu 'bit_vector' umzuwandeln und auch andersherum. 
	Es ist sehr hilfreich beim Debuggen, weil man die gerade dekodierte 32-Bit Instruction als ein Output in 'string' darstellen kann.
	Somit kann man den 'string' in Tcl console als 'report' ausgeben. 

Mnemonics-Package: Das ist ein Paket, um Opcodes wie "ADD" oder "XOR" in 'bit_vector' umzuwandeln, damit es bei der Dekodierung verwendet werden kann. 

