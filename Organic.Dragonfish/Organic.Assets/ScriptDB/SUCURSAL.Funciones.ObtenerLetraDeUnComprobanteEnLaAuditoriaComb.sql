IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerLetraDeUnComprobanteEnLaAuditoriaComb]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerLetraDeUnComprobanteEnLaAuditoriaComb];
GO;

CREATE FUNCTION [Funciones].[ObtenerLetraDeUnComprobanteEnLaAuditoriaComb]
	( 
	@ComprobanteAuditoria varchar(254)
	)
	returns varchar(40)
AS
	begin
	
		declare @Informacion varchar(40) = '' ;
		declare @PosicionReferencia int = funciones.BuscarPosicionDeReferenciaAComprobanteValida( @ComprobanteAuditoria  ) ;

		
		set @Informacion =	case when Funciones.EsUnaReferenciaAComprobanteValida(  @ComprobanteAuditoria  , 1 )  = 1  
								then  
									case when substring( @ComprobanteAuditoria ,  @PosicionReferencia +1, 1)  like '[A-z]'
										then upper(substring( @ComprobanteAuditoria  , @PosicionReferencia +1, 1))   
										else ''  
									end  
								
								else null  
							end

		return @Informacion
	end
