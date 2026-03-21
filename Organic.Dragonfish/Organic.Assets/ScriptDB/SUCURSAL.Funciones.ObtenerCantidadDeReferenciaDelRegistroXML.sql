IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerCantidadDeReferenciaDelRegistroXML]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerCantidadDeReferenciaDelRegistroXML];
GO;

CREATE FUNCTION [Funciones].[ObtenerCantidadDeReferenciaDelRegistroXML]
( 
  @RegistroXML xml,
  @Referencia varchar(40)
)
RETURNS numeric(8,2)
AS
BEGIN
	declare @retorno numeric(8,2);
	declare @id varchar(40) = lower( rtrim( ltrim( @Referencia ) ) );

	set @retorno = case	-- el método value de un registro XML solo acepta LITERALES como primer parámetro, no es posible usar una variable
					when @id = 'confirmadopresupuesto' then @RegistroXML.value('(/row/confirmadopresupuesto)[1]', 'numeric( 8, 2 )')
					when @id = 'canceladopresupuesto'  then @RegistroXML.value('(/row/canceladopresupuesto)[1]', 'numeric( 8, 2 )')
					when @id = 'afectadopresupuesto'   then @RegistroXML.value('(/row/afectadopresupuesto)[1]', 'numeric( 8, 2 )')
					when @id = 'pendientepedido'       then @RegistroXML.value('(/row/pendientepedido)[1]', 'numeric( 8, 2 )')
					when @id = 'confirmadopedido'      then @RegistroXML.value('(/row/confirmadopedido)[1]', 'numeric( 8, 2 )')
					when @id = 'canceladopedido'       then @RegistroXML.value('(/row/canceladopedido)[1]', 'numeric( 8, 2 )')
					when @id = 'afectadopedido'        then @RegistroXML.value('(/row/afectadopedido)[1]', 'numeric( 8, 2 )')
					when @id = 'pendienteremito'       then @RegistroXML.value('(/row/pendienteremito)[1]', 'numeric( 8, 2 )')
					when @id = 'confirmadoremito'      then @RegistroXML.value('(/row/confirmadoremito)[1]', 'numeric( 8, 2 )')
					when @id = 'canceladoremito'       then @RegistroXML.value('(/row/canceladoremito)[1]', 'numeric( 8, 2 )')
					when @id = 'afectadoremito'        then @RegistroXML.value('(/row/afectadoremito)[1]', 'numeric( 8, 2 )')
					when @id = 'pendientefactura'      then @RegistroXML.value('(/row/pendientefactura)[1]', 'numeric( 8, 2 )')
					when @id = 'confirmadofactura'     then @RegistroXML.value('(/row/confirmadofactura)[1]', 'numeric( 8, 2 )')
					else cast( 0 as numeric(8,2) )
				end;
	 
	return @retorno;
END
