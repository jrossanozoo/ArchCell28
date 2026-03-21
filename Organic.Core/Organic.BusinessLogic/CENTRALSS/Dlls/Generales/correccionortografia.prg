Define Class CorreccionOrtografia As Custom

	oWord = Null

	*----------------------------------------------------
	Function Init() As VOID

		This.oWord = Createobject("Word.Application")

	Endfunc

	*----------------------------------------------------
	Function ValidarOrtografia ( tcTexto As String ) As Boolean
		Local llRetorno As Boolean

		llRetorno = This.oWord.CheckSpelling( tcTexto )

		Return llRetorno
	Endfunc

	*----------------------------------------------------
	Function ValidarGramatica ( tcTexto As String ) As Boolean
		Local llRetorno As Boolean

		llRetorno = This.oWord.CheckGrammar( tcTexto )

		Return llRetorno
	Endfunc

	*----------------------------------------------------
	Function Cerrar() As VOID
		This.oWord.Quit()
		This.oWord = null
	endfunc
	*----------------------------------------------------

Enddefine
