close tables all
set safety off

local lcArchivo as String, llSalir as Boolean, lcMensaje as String
local array laMP[1]

llSalir = .f.
lcMensaje = ""
lcArchivo = "c:\zoo\zl\sucursal\zl\dbf\Operaciones.dbf"
if !file( lcArchivo )
	lcMensaje = "No se encuentra el archivo '" + lcArchivo + "'." + chr(13)
	llSalir = .t.
endif

lcArchivo = "c:\zoo\zl\adn\dbc\MenuPrincipal.dbf"
if !file( lcArchivo )
	lcMensaje = lcMensaje + "No se encuentra el archivo '" + lcArchivo + "'." + chr(13)
	llSalir = .t.
endif

lcArchivo = "c:\zoo\zl\adn\dbc\MenuPrincipalItems.dbf"
if !file( lcArchivo )
	lcMensaje = lcMensaje + "No se encuentra el archivo '" + lcArchivo + "'." + chr(13)
	llSalir = .t.
endif

if llSalir
	messagebox( lcMensaje + "Por favor, corra la configuración básica" )
	return
endif

use c:\zoo\zl\sucursal\zl\dbf\Operaciones.dbf in 0 exclusive alias Ope
use c:\zoo\zl\adn\dbc\MenuPrincipal.dbf in 0 shared alias MP
use c:\zoo\zl\adn\dbc\MenuPrincipalItems.dbf in 0 shared alias MPI

select Ope
zap

select IdSeguridad from MP union all select idSeguridad from MPI into cursor c_MP
select IdSeguridad, count( IdSeguridad ) as Cantidad from c_MP group by IdSeguridad having Cantidad > 1 into array laMP
use in select( "C_mp" )
if _tally > 0
	lcMensaje = "Hay códigos de operaciós que se superponen entre la tabla MenuPrincipal y MenuPrincipalItems: "
	local i as Integer
	for i = 1 to alen( laMP )
		lcMensaje = lcMensaje + chr( 13 ) + "IdSeguridad: " + laMP[ i ]
	endfor
	llSalir = .t.
endif

if llSalir
	messagebox( lcMensaje + "Por favor, verifique dichas tablas" )
	return
endif

insert into ope values ( "1", "ZL", "TU", "" )
select MP
set order to ID
scan for empty( idPadre )
	insert into ope values ( MP.IdSeguridad, strtran( MP.Etiqueta, "\<", "" ), "TU", "1" )
endscan

scan for !empty( idPadre )
	insert into ope values ( MP.IdSeguridad, strtran( MP.Etiqueta, "\<", "" ), "TU", ObtenerIdSeguridadCabecera( MP.IdPadre ) )
endscan

select MPI
set relation to IdPadre into MP
scan 
	insert into ope values ( MPI.IdSeguridad, strtran( MPI.Etiqueta, "\<", "" ), "TU", MP.IdSeguridad )
endscan
set relation off into MP

use in select( "MP" )
use in select( "MPI" )
use in select( "Ope" )

messagebox( "Llenado de la tabla Operaciones terminado" )
return

*-----------------------------------------------------------------------------------------
function ObtenerIdSeguridadCabecera( tnIdPadre as Integer ) as string
	Local lcRetorno as String
	lcRetorno = ""
	local array laMP[1]
	select idSeguridad from MP where id = tnIdPadre into array laMP
	if _tally > 0
		lcRetorno = laMP[1]
	else
		messagebox( "ERROR: No existe el id padre" + alltrim( str( tnIdPadre ) ) + ;
					" para el id " + alltrim( str( MP.id ) ) + "." )
	endif

	return lcRetorno
endfunc 
