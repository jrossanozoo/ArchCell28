Define Class TipoEscalar As TipoBase of TipoBase.prg
	
	#IF .f.
		Local this as TipoEscalar of TipoEscalar.prg
	#ENDIF

	Valor = .f.
	
	Procedure Init() as Boolean
		
		Return DoDefault() and (this.Class # "Tipoescalar")
	Endproc
	
Enddefine

