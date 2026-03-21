#include acercade.h
define class KontrolerFormBaseEmpresa as Kontroler of Kontroler.prg

	#if .f.
		local this as KontrolerFormBaseEmpresa of KontrolerFormBaseEmpresa.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function init
		this.SetearDatosEmpresa()
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoAceptar() as Boolean
		thisform.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoCancelar() as Void
		thisform.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearDatosEmpresa() as Void
		with thisform.cntBase1
			.lblEmpresa.caption = NOMBRE
			.lblDireccion.caption = DIRECCION
			.lblTel.caption = TELEFONO
			.lblEmail.caption = EMAIL


			if at( "@", .lblEmail.caption ) > 0 and occurs( "@", .lblEmail.caption ) = 1
				.lblEmail.FontUnderline = .t.
				.lblEmail.ForeColor = rgb( 0,0,255)
				.lblEmail.MousePointer = 15
			endif	

			.lblWeb.caption = WEB
			
			if atc( "www", .lblWeb.caption ) = 1 and occurs( "www", .lblWeb.caption ) = 1
				.lblWeb.FontUnderline = .t.
				.lblWeb.ForeColor = rgb( 0,0,255)
				.lblWeb.MousePointer = 15
			endif
			bindevent( .LblEmail, "Click", this, "GenerarMail" )
			bindevent( .lblWeb, "Click", this, "LinkWeb" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarMail() as Void
		goLibrerias.EjecutarGenerarMail( alltrim( thisform.cntBase1.lblEmail.caption ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LinkWeb() as Void
		goLibrerias.AbrirEnlaceWEB( thisform.cntBase1.lblWeb.caption )
	endfunc 
enddefine
