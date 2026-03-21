IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerEstadoMercaderiaEnTransito]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerEstadoMercaderiaEnTransito];
GO;

CREATE FUNCTION [Funciones].[ObtenerEstadoMercaderiaEnTransito]
(@dato1 varchar(20), @dato2 int  )
returns char(9)

begin
	declare @respuesta char(9)
	begin
	set @respuesta= 
		case 
			when upper( @dato1 ) like '%MOVIMIENTO%' then 'Aceptado '
			when upper( @dato1 ) like '%MERCADERIA%' or upper( @dato1 ) like '%MERCADERÍA%' then 'Rechazado'
			when  RTRIM(LTRIM(@dato1))='' and @dato2 = 1 then 'Pendiente'
			else space(9)
		end
	end
	return(@respuesta)	
end
