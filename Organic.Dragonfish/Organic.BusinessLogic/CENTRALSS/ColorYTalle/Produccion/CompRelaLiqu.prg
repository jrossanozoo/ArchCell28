define class CompRelaLiqu as EtiquetaDato of EtiquetaDato.prg

	#INCLUDE constantesDibujante.h

	*-----------------------------------------------------------------------------------------
	function Armar() as Void
		dodefault()
		with this
			.CrearControles()
			.width = 500
			.txtDato.nTipoDeOrdenIzquierdo = ORDEN_IZQ_ALINEADO
			.lblEtiqueta.nColumna = 0
			.txtDato.nColumna = 1
			.txtDato1.nColumna = 2
			.txtDato1.nTipoDeOrdenIzquierdo = ORDEN_IZQ_ESPACIADO
			.txtDato2.nColumna = 3
			.txtDato2.nTipoDeOrdenIzquierdo = ORDEN_IZQ_ESPACIADO
			.txtDato3.nColumna = 5
			.txtDato3.nTipoDeOrdenIzquierdo = ORDEN_IZQ_ESPACIADO
			.AgregarEtiquetaGuion()
		endwith
	endfunc	
	
	*-----------------------------------------------------------------------------------------    
	function ObtenerItemDato() as object
		This.oItem.DatosBloque.Item[1].Dominio = "COMBOXML"
		This.oItem.DatosBloque.Item[1].Width = 120
		return This.oItem.DatosBloque.Item[1]    
	endfunc  

	*-----------------------------------------------------------------------------------------    
	function ObtenerItemDato1() as object         
		This.oItem.DatosBloque.Item[2].Dominio = "CARACTER"
		return This.oItem.DatosBloque.Item[2]
	endfunc
	
	*-----------------------------------------------------------------------------------------    
	function ObtenerItemDato2() as object         
		This.oItem.DatosBloque.Item[3].Dominio = "NUMERICO"
		return This.oItem.DatosBloque.Item[3]
	endfunc
	
	*-----------------------------------------------------------------------------------------    
	function ObtenerItemDato3() as object         
		This.oItem.DatosBloque.Item[4].Dominio = "NUMERICO"
		return This.oItem.DatosBloque.Item[4]
	endfunc

	*-----------------------------------------------------------------------------------------    
	function AgregarEtiquetaGuion() as object         
		_screen.zoo.nuevoobjeto( this, "lblEtiqueta2", "zooLabel", "zooLabel.prg" )        
		with this.lblEtiqueta2         
			.Caption = '-'            
			.nColumna = 4
			.visible = .t.
			.nTipoDeOrdenIzquierdo = ORDEN_IZQ_ESPACIADO        
		endwith   
		
	endfunc
			
	*-----------------------------------------------------------------------------------------
	function CrearControles() as Void
		
		loItem = this.ObtenerItemDato1()
		lcDominio = alltrim( loItem.Dominio )
		_Screen.zoo.NuevoObjeto( this, "txtDato1", lcDominio, "", loItem ) 
		with this.txtDato1
			.Format = "!K"
			.EsAjustable = .t.  
			.Visible = .t.
		endwith
		
		loItem = this.ObtenerItemDato2()
		lcDominio = alltrim( loItem.Dominio )         
		_Screen.zoo.NuevoObjeto( this, "txtDato2", lcDominio, "", loItem )         
		with this.txtDato2
			.EsAjustable = .t.  
    		.Format = "ZL"
    		.InputMask = "99999" 			          
			.Visible = .t.        
		endwith
		
		loItem = this.ObtenerItemDato3()
		lcDominio = alltrim( loItem.Dominio )         
		_Screen.zoo.NuevoObjeto( this, "txtDato3", lcDominio, "", loItem )         
		with this.txtDato3
			.EsAjustable = .t.  
    		.Format = "ZL"
    		.InputMask = "99999999" 
			.Visible = .t.			        
		endwith
		
	endfunc 	
	
enddefine
