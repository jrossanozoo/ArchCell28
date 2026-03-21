IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerSiEsComprobanteQueModificaStockParaAuditoria]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerSiEsComprobanteQueModificaStockParaAuditoria];
GO;

CREATE FUNCTION [Funciones].[ObtenerSiEsComprobanteQueModificaStockParaAuditoria]
	( 
	@ComprobanteAuditoria varchar(254),
	@Cantidad numeric(15,2)
	)
	returns varchar(2)
AS
	begin
	
		declare @Informacion numeric(2) ;
				
		set @Informacion =	case when    @ComprobanteAuditoria like 'pedido %' 
									or   @ComprobanteAuditoria like 'pedidodecompra %' 
									or   @ComprobanteAuditoria like 'presupuesto %' 
									or ( @ComprobanteAuditoria like 'cancelaciondecompra %' and @Cantidad =0 ) 
							then '0'
							else '1'
							end

		return @Informacion
	end



