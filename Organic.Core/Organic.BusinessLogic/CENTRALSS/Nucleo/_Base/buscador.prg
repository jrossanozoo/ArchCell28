*-----------------------------------------------------------------------------------------
function Buscador( tcBuscador as String ) as Void
	local loLanzadorBuscador as Object
	
	loLanzadorBuscador = _screen.zoo.crearobjeto( "LanzadorDeConsulta" )
	loLanzadorBuscador.Procesar ( tcBuscador )
endfunc
