*************************************************
* Raw picture viewer in 320x256x5 (32 col.)	*
* Example written by Flops 08.01.2016		*
* It can be used in any means (if is not used	*
* to harm anybody).				*
*************************************************

	Section code,code_p

SystemSave:			; Fragment zapisujacy rejestry, zeby pozniej mozna bylo je odtworzyc przy powrocie do systemu
	move.w $dff01c,d0
	ori.w #$8000,d0
	move.w d0,Old_INT
	move.w #$7fff,$dff09a
	move.w $dff002,d0
	ori.w #$8000,d0
	move.w d0,Old_DMA
	move.w #$7fff,$dff096
	move.w #$83c0,$dff096
	move.l 4.w,a6
	move.l 156(a6),a1
	move.l 38(a1),Old_COPPER
	move.l a7,Old_STACK

Init:
	move.l #4,d0		; liczba bitplanow -1
	move.l #40,d1		; szerokosc obrazka (w pixelach/8 - czyli bajtach na linie)
	move.l #256,d2		; wysokosc obrazka (w pixelach)
	mulu.w d2,d1		; mnozymy wysokosc razy szerokosc, zeby wiedziec jaka wielkosc posiada kazy bitplane
	move.l #Image,d2	; ladujemy poczatek obrazka do D2
	lea BitplanesRegisters,a1
	move.l #$000000e0,D3	; Adres pierwszego bitplanu (dolne slowo, gdyz Copper adresuje od razu od DFF000)
InitBitplanes:			; Inicjalizacja bitplanow, wpisujemy polecenia move do copperlisty
	move.w D3,(A1)+
	addq.w #2,D3
	swap D2
	move.w D2,(A1)+
	move.w D3,(A1)+
	addq.w #2,D3
	swap D2
	move.w D2,(A1)+
	add.l D1,D2
	dbf D0,InitBitplanes

; PalletInit
	lea PalleteRegisters,A1
	movea.l #ImagePallete-64,A0 ; Przykladowy raw zostal przekonwertowany z paleta ustawiona na koncu pliku
				; a wiec pobieramy adres jeden po pliku raw (gdzie jest obraz + na koncu paleta)
				; odejmujemy 64 (gdyz 32 kolory, ale kazdy element jest slowem - czyli dwa bajty,
				; co daje 64 bajty)
	moveq.l #31,d0
	move.l #$00000180,D1
PalleteLoop:
	move.w D1,(A1)+
	addq.w #2,D1
	move.w (A0)+,(A1)+	; kopiujemy 32 kolory do rejestrow kolorow
	dbf d0,PalleteLoop

StartOurCopperList:
	move.l #COPPER,$dff080
	move.l #0,$dff088
	
Stop:				; Petla oczekujaca na lewy przycisk myszy
	btst #6,$bfe001
	bne Stop
ExitProc:			; Procedura przywracajace wczesniejesz parametry systemu, zeby wyjsc bez bolu spowrotem do AOS
	move.l Old_STACK,a7	; Jeszcze powinno sie przywrocic wartosci dla wszystkich rejestrow, ale tutaj jest to pominiete
	move.l Old_COPPER,$dff080
	move.w Old_DMA,$dff096
	move.w Old_INT,$dff09a
	move.l #0,D0	; Co podac na wyjsciu do CLI. Liczba rozna od zera oznacza, ze aplikacja zakoczyla sie z bledem.
	rts

Old_INT:
	dc.w 0
Old_DMA:
	dc.w 0
Old_COPPER:
	dc.l 0
Old_STACK:
	dc.l 0

	Section data,data_c

COPPER:
	DC.L $01fc0000
	DC.L $01005200,$01020000
	DC.L $01040000,$01060000
	DC.L $008e2c81,$00902cc1
	DC.L $00920038,$009400d0
	DC.L $01fc0000
	DC.L $01080000,$010a0000
BitplanesRegisters:
	DS.L 10				; Rejestry wskazujace adresy bitplanow obrazka, rezerwacja miejsca dla 5 bitplanow
PalleteRegisters:
	DS.L 32				; Rezerwujemy miejsce na rejestry palety

	DC.L $FFFFFFFE

Image:
;	incbin "ram:raw/kubus.raw"
	incbin "ram:raw/lilia.raw"
ImagePallete:
