IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[Listados].[Vista_ASIENTODET]') AND type = N'V')
	DROP VIEW [Listados].[Vista_ASIENTODET];
GO;

CREATE VIEW [Listados].[Vista_ASIENTODET] AS
(
	select
		EQLince.CODIGO
		, ASIENTODETDebe.NIDebe
		, ASIENTODETDebe.CtaDebe
		, ASIENTODETDebe.DetDebe
		, ASIENTODETDebe.LydDebe
		, ASIENTODETDebe.CCstDebe
		, ASIENTODETDebe.DEBE
		, ASIENTODETHaber.NIHaber
		, ASIENTODETHaber.CtaHaber
		, ASIENTODETHaber.DetHaber
		, ASIENTODETHaber.LydHaber
		, ASIENTODETHaber.CCstHaber
		, ASIENTODETHaber.HABER 
	from
		(	
		select EQ.CODIGO
			, EQ.SECUENCIA
			, case when EQ.SECUENCIA > EQ.RegDEBE then null else eq.CODIGO end as FK_DEBE
			, case when EQ.SECUENCIA > EQ.RegHABER then null else eq.CODIGO end as FK_HABER
		from
			(
			select CODIGO
				, row_number() over ( partition by codigo order by codigo ) as SECUENCIA
				, count( NROITEM * case DEBE when 0 then null else 1 end ) over ( partition by codigo ) as RegDEBE
				, count( NROITEM * case HABER when 0 then null else 1 end ) over ( partition by codigo ) as RegHABER
			from ZooLogic.ASIENTODET 
			) as EQ
		where EQ.SECUENCIA <= case when EQ.RegDEBE >= EQ.RegHABER then EQ.RegDEBE else EQ.RegHABER end
		) as EQLince 
		left join (
		select 
			  CODIGO
			, NROITEM as NIDebe
			, PCUENTA as CtaDebe
			, PCUENTAD as DetDebe
			, LEYENDA as LydDebe
			, CODCCOS as CCstDebe
			, row_number() over ( partition by codigo order by codigo ) as SECUENCIA
			, DEBE  
		from ZooLogic.ASIENTODET 
		where HABER = 0 
		) as ASIENTODETDebe on EQLince.SECUENCIA = ASIENTODETDebe.SECUENCIA and EQLince.FK_DEBE = ASIENTODETDebe.CODIGO
		left join (
		select 
			  CODIGO
			, NROITEM as NIHaber
			, PCUENTA as CtaHaber
			, PCUENTAD as DetHaber
			, LEYENDA as LydHaber
			, CODCCOS as CCstHaber
			, row_number() over ( partition by codigo order by codigo ) as SECUENCIA
			, HABER  
		from ZooLogic.ASIENTODET 
		where DEBE = 0
		) as ASIENTODETHaber on EQLince.SECUENCIA = ASIENTODETHaber.SECUENCIA and EQLince.FK_HABER = ASIENTODETHaber.CODIGO
	-- order by EQLince.CODIGO, coalesce( ASIENTODETDebe.NIDebe, ASIENTODETHaber.NIHaber )
)