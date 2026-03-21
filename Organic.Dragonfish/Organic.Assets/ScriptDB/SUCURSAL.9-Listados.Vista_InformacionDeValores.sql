IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[Listados].[Vista_InformacionDeValores]') AND type = N'V')
	DROP VIEW [Listados].[Vista_InformacionDeValores];
GO;

CREATE VIEW [Listados].[Vista_InformacionDeValores] AS
(
	select
		c_ITEMVALORES.IDITEM,
		cast('Nº ' + convert(varchar,C_INFOVALOR.CNUMERO) + ', Fecha pago: ' + 
		(substring(convert(varchar,convert(date,C_INFOVALOR.cfecha)),9,2)+'/'+substring(convert(varchar,convert(date,C_INFOVALOR.cfecha)),6,2)+'/'+substring(convert(varchar,convert(date,C_INFOVALOR.cfecha)),3,2)) +
		(case when rtrim(C_ENTIDADFINANCIERA.EFDES) != '' then {fn concat({fn concat({fn concat( char(13), char(10))}, 'Entidad: ')}, rtrim(C_ENTIDADFINANCIERA.EFDES))} else '' end) + 
		(case when rtrim(C_INFOVALOR.CCOTRIBGIR) != '' then {fn concat({fn concat({fn concat( char(13), char(10))}, 'CUIT Librador: ')}, C_INFOVALOR.CCOTRIBGIR)} else '' end) 
		as varchar(max)) as VALOR_INFO
		from ZooLogic.VAL as c_ITEMVALORES
		inner join ZooLogic.CHEQUE as C_INFOVALOR on C_INFOVALOR.CCOD = C_ITEMVALORES.NROCHEQUE
		left join ZooLogic.ENTFIN as C_ENTIDADFINANCIERA on C_ENTIDADFINANCIERA.EFCOD = C_INFOVALOR.CENTFIN
	
	union all
	
	select
		c_ITEMVALORES.IDITEM,
		cast('Nº ' + convert(varchar,C_INFOVALOR.CNUMERO) + ', Fecha: ' +
		(substring(convert(varchar,convert(date,C_INFOVALOR.cfecha)),9,2)+'/'+substring(convert(varchar,convert(date,C_INFOVALOR.cfecha)),6,2)+'/'+substring(convert(varchar,convert(date,C_INFOVALOR.cfecha)),3,2)) +
		', Entidad: ' + rtrim(C_ENTIDADFINANCIERA.EFDES) + ', Monto: ' + convert(varchar,C_INFOVALOR.CMONTO) + ', Moneda: ' + rtrim(C_INFOVALOR.CMONEDA) + ', Observación: ' +
		convert(varchar,C_INFOVALOR.COBSS) as varchar(max)) as VALOR_INFO
	from ZooLogic.VAL as c_ITEMVALORES
		inner join ZooLogic.CHQPROP as C_INFOVALOR on C_INFOVALOR.CCOD = C_ITEMVALORES.NROCHPROP
		left join ZooLogic.ENTFIN as C_ENTIDADFINANCIERA on C_ENTIDADFINANCIERA.EFCOD = C_INFOVALOR.CENTFIN
	
	union all
	
	select
		c_ITEMVALORES.IDITEM,
		cast('Nº ' +
		convert(varchar,C_INFOVALOR.NUMERO) + 
		', Cuotas: ' +
		convert(varchar,C_INFOVALOR.CUOTAS) + 
		(case when rtrim(C_ENTIDADFINANCIERA.EFDES) != '' then {fn concat({fn concat({fn concat( char(13), char(10))}, 'Entidad: ')}, rtrim(C_ENTIDADFINANCIERA.EFDES))} else '' end) 
		as varchar(max)) as VALOR_INFO
	from ZooLogic.VAL as c_ITEMVALORES
		inner join ZooLogic.CUPONES as C_INFOVALOR on C_INFOVALOR.CODIGO = C_ITEMVALORES.CUPON
		left join ZooLogic.ENTFIN as C_ENTIDADFINANCIERA on C_ENTIDADFINANCIERA.EFCOD = C_INFOVALOR.ENTFIN


)