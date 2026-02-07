10 CLEAR 2000,&H7BFF:CLS
20 LOADM"MENU"
30 DEFUSR0=&H7C00
40 DIM X$(7)
50 X$(0)="Stan Laurel"
51 X$(1)="Oliver Hardy"
52 X$(2)="Moe"
53 X$(3)="Larry"
54 X$(4)="Curly"
60 X$(5)="Charlie Chaplin"
70 X$(6)="Buster Keaton"
80 X$(7)="Harold Lloyd"
90 DIM X(3)
100 X(0)=0 'Selected item
105 X(1)=0 'Exit key
110 X(2)=30
120 X(3)=3
130 X=USR0("X")
135 LOCATE 0,6
140 PRINT:PRINT X;X(0);X(1)
