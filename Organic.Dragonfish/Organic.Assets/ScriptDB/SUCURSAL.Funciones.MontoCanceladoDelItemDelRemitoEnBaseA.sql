IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[MontoCanceladoDelItemDelRemitoEnBaseA]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[MontoCanceladoDelItemDelRemitoEnBaseA];
GO;

CREATE FUNCTION [Funciones].[MontoCanceladoDelItemDelRemitoEnBaseA]
(
	@CodigoCompAfe as varchar(38),
	@Cantidad as numeric(8, 2),
	@CodigoIdItemArticuloOriginal as varchar(38)
)
	
returns table
as
return
(
select ( MNTPTOT * @Cantidad / fcant ) as imp_cancel_original
from ZOOLOGIC.COMPROBANTEVDET
	--from ZOOLOGIC.COMPROBANTEV  left join ZOOLOGIC.COMPROBANTEVDET on COMPROBANTEV.CODIGO = ZOOLOGIC.COMPROBANTEVDET.CODIGO 
	WHERE COMPROBANTEVDET.codigo = @CodigoCompAfe and
			COMPROBANTEVdet.IDITEM = @CodigoIdItemArticuloOriginal
)


