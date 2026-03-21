IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_AFIPRG4523_PercepcionesRealizadas_IVA]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_AFIPRG4523_PercepcionesRealizadas_IVA];
GO;

CREATE FUNCTION [Interfaces].[Interfaz_AFIPRG4523_PercepcionesRealizadas_IVA]     
(
	@FechaComprobanteDesde varchar(10),
	@FechaComprobanteHasta varchar(10)
)
RETURNS TABLE
AS
RETURN
(
	select cast('0100' as char(4)) as Version,																								-- Cpo: 1,  Long: 4,  Pos: 1-4
		cast(' ' as char(36)) as CodigoDeTrazabilidad,																						-- Cpo: 2,  Long: 10,  Pos: 5-14
		cast('216' as char(3)) as Impuesto,																									-- Cpo: 3,  Long: 3,  Pos: 15-17
		cast(case when DatosExpo.Regimen is null then '000' else funciones.padl(DatosExpo.Regimen,3,'0') end as char(3) ) as Regimen,		-- Cpo: 4,  Long: 3,  Pos: 18-20
		cast(DatosExpo.FechaDeRetPerc as char(10)) as FechaDeRetPerc,																		-- Cpo: 5,  Long: 10,  Pos: 21-30
		cast(DatosExpo.Condicion as char(2)) as Condicion,																					-- Cpo: 6,  Long: 2,  Pos: 31-32
		cast(DatosExpo.ImposibilidadRetPerc as char(1)) as ImposibilidadRetPerc,															-- Cpo: 7,  Long: 1,  Pos: 33
		cast('' as char(30)) as MotivoNoRetencion,																							-- Cpo: 8,  Long: 30, Pos: 34-63	
		cast(funciones.padl(coalesce(DatosExpo.ImporteRetPerc,0),14,'0') as char(14)) as ImporteRetPerc,									-- Cpo: 9,  Long: 14,  Pos: 64-77
		cast(funciones.padl(coalesce(DatosExpo.ImporteBaseCalcCant,0),14,'0') as char(14)) as ImporteBaseCalcCant,							-- Cpo: 10, Long: 14,  Pos: 78-91
		cast(DatosExpo.RegimenExclusion as char(1)) as RegimenExclusion,																	-- Cpo: 11, Long: 1,  Pos: 92
		cast(case when DatosExpo.RegimenExclusion = '1' then '100.00' else funciones.padl(coalesce(DatosExpo.PorcentajeExclusion,0),6,'0') end as char(6)) as PorcentajeExclusion,																-- Cpo: 12, Long: 6, Pos: 93-98
		cast(funciones.padl(DatosExpo.FechaDePublicacion,10,' ') as char(10)) as FechaDePublicacion,										-- Cpo: 13, Long: 10, Pos: 99-108
		cast(funciones.padl(DatosExpo.TipoComprobante,2,'0') as char(2)) as TipoComprobante,												-- Cpo: 14, Long: 2,  Pos: 109-110
		cast(DatosExpo.FechaDeComprobante as char(10)) as FechaDeComprobante,																-- Cpo: 15, Long: 10, Pos: 111-120
		cast(funciones.padl(DatosExpo.NroComprobante,16,' ') as char(16)) as NroComprobante,												-- Cpo: 16, Long: 16,  Pos: 121-136
		cast('' as char(12)) as COE,																										-- Cpo: 17, Long: 12,  Pos: 137-148
		cast('' as char(12)) as COEOriginal,																								-- Cpo: 18, Long: 12,  Pos: 149-160
		cast('' as char(14)) as CAE,																										-- Cpo: 19, Long: 14,  Pos: 161-174
		cast(funciones.padl(DatosExpo.ImporteComprobante,14,'0') as char(14)) as ImporteComprobante,										-- Cpo: 20, Long: 14, Pos: 175-188
		cast(funciones.padl(coalesce(DatosExpo.MotivoEmisionNC,''),30,' ') as char(30)) as MotivoEmisionNC,									-- Cpo: 21, Long: 30,  Pos: 189-218
		cast(funciones.padl(coalesce(DatosExpo.RetenidoPercibido,''),11,'0') as char(11)) as RetenidoPercibido,								-- Cpo: 22, Long: 11,  Pos: 219-229
		cast(funciones.padl(coalesce(DatosExpo.CertificadoOriginal,''),25,' ') as char(25)) as CertificadoOriginal,							-- Cpo: 23, Long: 25,  Pos: 230-254
		cast(funciones.padl(coalesce(DatosExpo.CertOrigFechaReten,''),10,' ') as char(10)) as CertOrigFechaReten,							-- Cpo: 24, Long: 10,  Pos: 255-264
		cast(funciones.padl(coalesce(DatosExpo.CertOrigImporte,0),14,'0') as char(14)) as CertOrigImporte,
		cast(DatosExpo.MotivoAnulacion AS CHAR(1)) as MotivoAnulacion																						-- Cpo: 25, Long: 14,  Pos: 265-278
		
	from (
			select
			case when c_impven.regimenimp = '831' then '01' else '00' end as Condicion,
			c_impven.regimenimp as Regimen,
			convert(varchar(10),c_compv.FFCH,103) as FechaDeRetPerc,
			cast(c_impven.monto as numeric(11,2)) as ImporteRetPerc,
			cast(c_impven.MONTOBASE as numeric(11,2)) as ImporteBaseCalcCant,
			case when c_impven.CCOD is null then 1 else 0 end as ImposibilidadRetPerc,
			c_cli.experiva as RegimenExclusion,
			c_impven.Porcen as PorcentajeExclusion,
			case when c_cli.experiva = 1 then convert(varchar(10),c_cli.VHASTAIVA,103) else '' end as FechaDePublicacion,
			case when c_conver.valdest is null then c_compv.FACTTIPO else c_conver.VALDEST end as TipoComprobante,
			convert(varchar(10),c_compv.FFCH,103) as FechaDeComprobante,
			funciones.padl(c_compv.FPTOVEN,5,'0') + '-' + funciones.padl(c_compv.fnumcomp,8,'0') as NroComprobante,
			'' as CAE,
			c_compv.ftotal as ImporteComprobante,
			c_4523.motivo as MotivoEmisionNC,
			c_cli.clcuit as RetenidoPercibido,
			c_4523.nrocerti as CertificadoOriginal,
			convert(varchar(10),c_4523.fecha,103) as CertOrigFechaReten,
			cast(c_4523.IMPORTE as numeric(11,2)) as CertOrigImporte,
			convert(varchar(1),c_4523.MotivoAnul) as MotivoAnulacion
			from
			ZooLogic.COMPROBANTEV as c_compv
			inner join ZooLogic.IMPVENTAS as c_impven on c_compv.CODIGO = c_impven.CCOD and c_impven.TIPOI = 'IVA'
			inner join ZooLogic.CLI as c_cli on c_compv.FPERSON = c_cli.CLCOD
			left join ORGANIZACION.CONVERVAL as c_conver on c_conver.conversion = 'SIRETIPOCOMPROBANTE' and c_compv.FACTTIPO = c_conver.VALORIG
			--left join ZooLogic.CAE as c_cae on c_compv.CODIGO = c_cae.CODIGO
			left join ZooLogic.AFIP4523 as c_4523 on c_compv.codigo = c_4523.codcomp
			where c_impven.TIPOI = 'IVA'  AND ( c_impven.SIRECERT = '' OR c_impven.SIRECERT LIKE 'ERROR_SIREWS' )
			  and ( ( @FechaComprobanteDesde is null ) or ( c_compv.FFch >= @FechaComprobanteDesde ) ) 
			  and ( ( @FechaComprobanteHasta is null ) or ( c_compv.FFch <= @FechaComprobanteHasta ) )
	          and c_impven.RegimenImp is not null and c_impVEN.RegimenImp IN (15, 16,17,18,208,209,210,211,212,214,215,216,217,218,219,225,234,280,499,689,690,777,831,966) -- EXPORTAR SOLO LOS QUE TENGAN REGIMEN VALIDO PARA EL IMPUESTO 216
) AS DatosExpo
) 

