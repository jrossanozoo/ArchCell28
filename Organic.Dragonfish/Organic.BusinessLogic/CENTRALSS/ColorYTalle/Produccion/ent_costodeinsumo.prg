define class ent_costodeinsumo as din_entidadCostodeInsumo of din_entidadCostodeInsumo.prg

	#if .f.
		Local this as ent_costodeinsumo of ent_costodeinsumo.prg
	#endif

	lReAsignarPk_Con_CC = .T.
	DescripcionComprobante = ""
	cAtributosCombinacion = "ListaDeCosto,Articulo,Color,Talle,Taller,Proceso,Cantidad"
	
	*-----------------------------------------------------------------------------------------
	function Modificar() as Void
		dodefault()
		This.CostoOriginal = This.CostoDirecto
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ReasignarPk_Con_CC() as Void
		This.Codigo = padr( This.ListaDeCosto_Pk, 6 ) + padr( This.Insumo_Pk, 25 ) + ;
					padr( This.Color_Pk, 6 ) + padr( This.Talle_Pk, 5 ) + ;
					padr( This.Taller_Pk, 15 ) + padr( This.Proceso_Pk, 15 ) + ;
					str(This.DesdeCantidad, 7 )
		return dodefault()
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerPk_Con_CC() as Void
		local lcClave as String
		lcClave = padr( This.ListaDeCosto_Pk, 6 ) + padr( This.Insumo_Pk, 25 ) + ;
					padr( This.Color_Pk, 6 ) + padr( This.Talle_Pk, 5 ) + ;
					padr( This.Taller_Pk, 15 ) + padr( This.Proceso_Pk, 15 ) + ;
					str(This.DesdeCantidad, 7 )
		return lcClave
	endfunc

enddefine
