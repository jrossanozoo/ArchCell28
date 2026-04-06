

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcRzConItemsFacturablesyServicioMDA]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [ZL].[funcRzConItemsFacturablesyServicioMDA]
GO

CREATE FUNCTION [ZL].[funcRzConItemsFacturablesyServicioMDA]
(		
	@nroserie as varchar(6)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT i.crass as NroRazonSocial
		from zl.itemserv as i with(nolock)
		inner join ZL.funcItemsVigentes() as iv on iv.ccod = i.ccod
		where i.nroserie = @nroserie
		and i.crass in
		(
			Select nrz
			from [ZL].[AdmEstadoRS]() 
			where [obtener servicio mda] = 1
		)
	group by i.crass	
)

GO
