IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerInformacionDePromocionAplicadaAlItemDeArticulo]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerInformacionDePromocionAplicadaAlItemDeArticulo];
GO;

CREATE FUNCTION [Funciones].[ObtenerInformacionDePromocionAplicadaAlItemDeArticulo]
	(
	@IDItemArticulo			varchar(38),
	@InformacionRequerida	varchar(40)
	)
RETURNS nVarchar(max)
AS
BEGIN
	declare @Resultado xml
	set @Resultado =
					(
					select top 1
						rtrim(coalesce(c_ItemPromo.PROMO, '')) + rtrim( coalesce(case when coalesce(c_ItemPromo.PROMO, '') = '' then '' else ', ' end + c_PromoBancaria.PROMO, '')) as PROMO, 
						coalesce(c_ItemPromo.TIPO, c_PromoBancaria.TIPO) as TIPO, 
						rtrim(coalesce(c_ItemPromo.DESCRIP, '')) + rtrim( coalesce(case when coalesce(c_ItemPromo.PROMO, '') = '' then '' else ', ' end + c_PromoBancaria.DESCRIP, '')) as DESCRIPCION, 
						case when c_ItemPromo.BENEFICIO != 0 then c_ItemArticulo.FCANT else 0 end + cast( coalesce(c_PromoBancaria.cuenta, 0) * case when c_ComprobanteV.FTOTAL = 0 then 1 else c_ItemArticulo.MNTPTOT / c_ComprobanteV.FTOTAL end as numeric(15,2)) as CANTIDAD, 
						case when c_ItemPromo.BENEFICIO != 0 then c_ItemArticulo.MNTDES
						when c_ItemArticulo.MNTDES ! = 0 and c_ItemArticulo.FCFITOT ! = 0 then c_ItemArticulo.MNTDES + c_ItemArticulo.FCFITOT
						when c_ItemArticulo.MNTDES ! = 0 then c_ItemArticulo.MNTDES
						when c_ItemArticulo.FCFITOT ! = 0 then c_ItemArticulo.FCFITOT
						else
						0
						end + cast( coalesce(c_PromoBancaria.MONTO, 0) * case when c_ComprobanteV.FTOTAL = 0 then 1 else c_ItemArticulo.MNTPTOT / c_ComprobanteV.FTOTAL end as numeric(15,2)) as BENEFICIO,
						c_Promociones.FECDESDE,
						c_Promociones.FECHASTA,
						c_Promociones.HORADESDE,
						c_Promociones.HORAHASTA
					from ZooLogic.COMPROBANTEVDET as c_ItemArticulo
						inner join ZooLogic.COMPROBANTEV as c_ComprobanteV on c_ComprobanteV.CODIGO = c_ItemArticulo.CODIGO
						left join ZooLogic.PROARTDET as c_RelacionDetalles on c_RelacionDetalles.IDARTI = c_ItemArticulo.IDITEM and c_RelacionDetalles.IDARTI != ''
						left join ZooLogic.PROMDET as c_ItemPromo on c_ItemPromo.IDITEM = c_RelacionDetalles.IDPROMO
						left join ZooLogic.PROMOS as c_Promociones on c_Promociones.CODIGO = c_ItemPromo.PROMO
						left join (
							select c_PBco.CODIGO
								, 5 as TIPO
								,sum(c_PBco.MONTO) as monto
								,count(c_PBco.CODIGO) as cuenta
								,STUFF((
									SELECT ', '+ rtrim(c_ItemPBco.PROMO)
									FROM ZooLogic.PROMDET as c_ItemPBco
									WHERE c_ItemPBco.CODIGO = c_PBco.CODIGO and c_ItemPBco.TIPO = 5
									FOR XML PATH('')
								),1,2,'') as PROMO
								,STUFF((
									SELECT ', '+ rtrim(c_ItemPBco.DESCRIP)
									FROM ZooLogic.PROMDET as c_ItemPBco
									WHERE c_ItemPBco.CODIGO = c_PBco.CODIGO and c_ItemPBco.TIPO = 5
									FOR XML PATH('')
								),1,2,'') as DESCRIP
							FROM ZooLogic.PROARTDET as c_PBco
							WHERE c_PBco.IDVALOR != ''  and c_PBco.MONTO <>0
							GROUP BY c_PBco.CODIGO
							) as c_PromoBancaria on c_PromoBancaria.CODIGO = c_ItemArticulo.CODIGO 
					where ( ( @IDItemArticulo is null ) OR ( c_ItemArticulo.IDITEM = @IDItemArticulo ) )
					for xml path 
					);

	declare @retorno nVarchar(max);
	set @Retorno =	case  upper( rtrim( @InformacionRequerida ) )		
						when 'PROMO'		then @Resultado.value('(/row/PROMO)[1]', 'nVarchar(max)')
						when 'TIPO'			then @Resultado.value('(/row/TIPO)[1]', 'nVarchar(max)')
						when 'DESCRIPCION'	then @Resultado.value('(/row/DESCRIPCION)[1]', 'nVarchar(max)')
						when 'CANTIDAD'		then @Resultado.value('(/row/CANTIDAD)[1]', 'nVarchar(max)')
						when 'BENEFICIO'	then @Resultado.value('(/row/BENEFICIO)[1]', 'nVarchar(max)')
						when 'FECHADESDE'	then @Resultado.value('(/row/FECHADESDE)[1]', 'nVarchar(max)')
						when 'FECHAHASTA'	then @Resultado.value('(/row/FECHAHASTA)[1]', 'nVarchar(max)')
						when 'HORADESDE'	then @Resultado.value('(/row/HORADESDE)[1]', 'nVarchar(max)')
						when 'HORAHASTA'	then @Resultado.value('(/row/HORAHASTA)[1]', 'nVarchar(max)')
						else null
					end;

	return @retorno
END
