100 CLS
110 CLEAR 2000,&H7BFF
120 LOADM"MENU"
130 DEFUSR0=&H7C00
140 DIM X$(10)
150 X$(0)="Oscarito"
160 X$(1)="Grande Otelo"
170 X$(2)="Moe"
180 X$(3)="Larry"
190 X$(4)="Curly"
200 X$(5)="Charlie Chaplin"
210 X$(6)="Buster Keaton"
220 X$(7)="Harold Lloyd"
230 X$(8)="Chespirito"
240 X$(9)="Stan Laurel"
250 X$(10)="Oliver Hardy"
260 DIM X(3)
265 'Flags: 1=Accept Left Arrow
266 '       2=Accept Right Arrow
267 '       4=Accept Break
269 '       8=Wipe menu area on exit
268 '      16=Accept Letters (TODO)
270 X(0)=8  'Selected item
280 X(1)=12 'Flags (in), Exit key (out)
290 X(2)=36
300 X(3)=3
310 X=USR0("X")
320 LOCATE 0,6
330 PRINT X;X(0);X(1)
