-- 1. BORRAR LAS TABLAS SI EXISTEN
IF OBJECT_ID('dbo.TFG_LCM_ResultadoComparativaEnergiav3', 'U') IS NOT NULL DROP TABLE dbo.TFG_LCM_ResultadoComparativaEnergiav3;
IF OBJECT_ID('dbo.TFG_LCM_ConsumoDiariov3', 'U') IS NOT NULL DROP TABLE dbo.TFG_LCM_ConsumoDiariov3;
IF OBJECT_ID('dbo.TFG_LCM_ConsumoFacturadov3', 'U') IS NOT NULL DROP TABLE dbo.TFG_LCM_ConsumoFacturadov3;
IF OBJECT_ID('dbo.TFG_LCM_ConsumoFacturadov3_RAW', 'U') IS NOT NULL DROP TABLE dbo.TFG_LCM_ConsumoFacturadov3_RAW;


-- 2. CREAR TABLA TFG_LCM_ConsumoFacturado
-- Paso 1: Crear tabla intermedia sin agrupar
SELECT 
    cac.idCUPS,
    cac.EjercicioAlbaran,
    cac.NumeroAlbaran,
    cac.SerieAlbaran, 
    cac.FechaDesdeFactura, 
    cac.FechaHastaFactura, 
    cac.codigoempresa,
    lac.CodigoPeriodo,
    lac.Unidades,
    lac.precio
INTO TFG_LCM_ConsumoFacturadov3_RAW
FROM CabeceraAlbaranCliente cac
JOIN lineasAlbaranCliente lac
    ON cac.EjercicioAlbaran = lac.EjercicioAlbaran
    AND cac.SerieAlbaran = lac.SerieAlbaran
    AND cac.NumeroAlbaran = lac.NumeroAlbaran
WHERE 
    cac.siglanacion = 'ES'
    AND cac.EjercicioAlbaran = '2024'
    AND lac.CodigoSubfamilia = 'Energia'
--    AND cac.idCUPS = 'ES0031405093566001EQ0F'
;

-- Paso 2: Agregar datos y guardar el resultado final
SELECT 
    idCUPS,
    EjercicioAlbaran,
    NumeroAlbaran,
    SerieAlbaran, 
    FechaDesdeFactura, 
    FechaHastaFactura, 
    codigoempresa,
    SUM(CASE WHEN CodigoPeriodo = 'P1' THEN Unidades ELSE 0 END) AS EnergiaFacturada_P1,
    SUM(CASE WHEN CodigoPeriodo = 'P2' THEN Unidades ELSE 0 END) AS EnergiaFacturada_P2,
    SUM(CASE WHEN CodigoPeriodo = 'P3' THEN Unidades ELSE 0 END) AS EnergiaFacturada_P3,
    SUM(CASE WHEN CodigoPeriodo = 'P4' THEN Unidades ELSE 0 END) AS EnergiaFacturada_P4,
    SUM(CASE WHEN CodigoPeriodo = 'P5' THEN Unidades ELSE 0 END) AS EnergiaFacturada_P5,
    SUM(CASE WHEN CodigoPeriodo = 'P6' THEN Unidades ELSE 0 END) AS EnergiaFacturada_P6,
    SUM(CASE WHEN CodigoPeriodo = 'P1' THEN precio ELSE 0 END) AS precio_P1,
    SUM(CASE WHEN CodigoPeriodo = 'P2' THEN precio ELSE 0 END) AS precio_P2,
    SUM(CASE WHEN CodigoPeriodo = 'P3' THEN precio ELSE 0 END) AS precio_P3,
    SUM(CASE WHEN CodigoPeriodo = 'P4' THEN precio ELSE 0 END) AS precio_P4,
    SUM(CASE WHEN CodigoPeriodo = 'P5' THEN precio ELSE 0 END) AS precio_P5,
    SUM(CASE WHEN CodigoPeriodo = 'P6' THEN precio ELSE 0 END) AS precio_P6
INTO TFG_LCM_ConsumoFacturadov3
FROM TFG_LCM_ConsumoFacturadov3_RAW
GROUP BY 
    idCUPS, EjercicioAlbaran, NumeroAlbaran, SerieAlbaran, 
    FechaDesdeFactura, FechaHastaFactura, codigoempresa
;

   
-- 3. CREAR TABLA TFG_LCM_ConsumoDiario
SELECT 
    ch.idCUPS,
    cf.NumeroAlbaran,
    COUNT(DISTINCT ch.Fecha) AS numdias,
    -- Suma por cada periodo P1 a P6
        SUM(CASE WHEN ch.PerfilHora1 = 'P1' THEN ch.H1 ELSE 0 END +
            CASE WHEN ch.PerfilHora2 = 'P1' THEN ch.H2 ELSE 0 END +
            CASE WHEN ch.PerfilHora3 = 'P1' THEN ch.H3 ELSE 0 END +
            CASE WHEN ch.PerfilHora4 = 'P1' THEN ch.H4 ELSE 0 END +
            CASE WHEN ch.PerfilHora5 = 'P1' THEN ch.H5 ELSE 0 END +
            CASE WHEN ch.PerfilHora6 = 'P1' THEN ch.H6 ELSE 0 END +
            CASE WHEN ch.PerfilHora7 = 'P1' THEN ch.H7 ELSE 0 END +
            CASE WHEN ch.PerfilHora8 = 'P1' THEN ch.H8 ELSE 0 END +
            CASE WHEN ch.PerfilHora9 = 'P1' THEN ch.H9 ELSE 0 END +
            CASE WHEN ch.PerfilHora10 = 'P1' THEN ch.H10 ELSE 0 END +
            CASE WHEN ch.PerfilHora11 = 'P1' THEN ch.H11 ELSE 0 END +
            CASE WHEN ch.PerfilHora12 = 'P1' THEN ch.H12 ELSE 0 END +
            CASE WHEN ch.PerfilHora13 = 'P1' THEN ch.H13 ELSE 0 END +
            CASE WHEN ch.PerfilHora14 = 'P1' THEN ch.H14 ELSE 0 END +
            CASE WHEN ch.PerfilHora15 = 'P1' THEN ch.H15 ELSE 0 END +
            CASE WHEN ch.PerfilHora16 = 'P1' THEN ch.H16 ELSE 0 END +
            CASE WHEN ch.PerfilHora17 = 'P1' THEN ch.H17 ELSE 0 END +
            CASE WHEN ch.PerfilHora18 = 'P1' THEN ch.H18 ELSE 0 END +
            CASE WHEN ch.PerfilHora19 = 'P1' THEN ch.H19 ELSE 0 END +
            CASE WHEN ch.PerfilHora20 = 'P1' THEN ch.H20 ELSE 0 END +
            CASE WHEN ch.PerfilHora21 = 'P1' THEN ch.H21 ELSE 0 END +
            CASE WHEN ch.PerfilHora22 = 'P1' THEN ch.H22 ELSE 0 END +
            CASE WHEN ch.PerfilHora23 = 'P1' THEN ch.H23 ELSE 0 END +
            CASE WHEN ch.PerfilHora24 = 'P1' THEN ch.H24 ELSE 0 END) AS ConsumoP1,
        SUM(CASE WHEN ch.PerfilHora1 = 'P2' THEN ch.H1 ELSE 0 END +
            CASE WHEN ch.PerfilHora2 = 'P2' THEN ch.H2 ELSE 0 END +
            CASE WHEN ch.PerfilHora3 = 'P2' THEN ch.H3 ELSE 0 END +
            CASE WHEN ch.PerfilHora4 = 'P2' THEN ch.H4 ELSE 0 END +
            CASE WHEN ch.PerfilHora5 = 'P2' THEN ch.H5 ELSE 0 END +
            CASE WHEN ch.PerfilHora6 = 'P2' THEN ch.H6 ELSE 0 END +
            CASE WHEN ch.PerfilHora7 = 'P2' THEN ch.H7 ELSE 0 END +
            CASE WHEN ch.PerfilHora8 = 'P2' THEN ch.H8 ELSE 0 END +
            CASE WHEN ch.PerfilHora9 = 'P2' THEN ch.H9 ELSE 0 END +
            CASE WHEN ch.PerfilHora10 = 'P2' THEN ch.H10 ELSE 0 END +
            CASE WHEN ch.PerfilHora11 = 'P2' THEN ch.H11 ELSE 0 END +
            CASE WHEN ch.PerfilHora12 = 'P2' THEN ch.H12 ELSE 0 END +
            CASE WHEN ch.PerfilHora13 = 'P2' THEN ch.H13 ELSE 0 END +
            CASE WHEN ch.PerfilHora14 = 'P2' THEN ch.H14 ELSE 0 END +
            CASE WHEN ch.PerfilHora15 = 'P2' THEN ch.H15 ELSE 0 END +
            CASE WHEN ch.PerfilHora16 = 'P2' THEN ch.H16 ELSE 0 END +
            CASE WHEN ch.PerfilHora17 = 'P2' THEN ch.H17 ELSE 0 END +
            CASE WHEN ch.PerfilHora18 = 'P2' THEN ch.H18 ELSE 0 END +
            CASE WHEN ch.PerfilHora19 = 'P2' THEN ch.H19 ELSE 0 END +
            CASE WHEN ch.PerfilHora20 = 'P2' THEN ch.H20 ELSE 0 END +
            CASE WHEN ch.PerfilHora21 = 'P2' THEN ch.H21 ELSE 0 END +
            CASE WHEN ch.PerfilHora22 = 'P2' THEN ch.H22 ELSE 0 END +
            CASE WHEN ch.PerfilHora23 = 'P2' THEN ch.H23 ELSE 0 END +
            CASE WHEN ch.PerfilHora24 = 'P2' THEN ch.H24 ELSE 0 END) AS ConsumoP2,
                    SUM(CASE WHEN ch.PerfilHora1 = 'P3' THEN ch.H1 ELSE 0 END +
            CASE WHEN ch.PerfilHora2 = 'P3' THEN ch.H2 ELSE 0 END +
            CASE WHEN ch.PerfilHora3 = 'P3' THEN ch.H3 ELSE 0 END +
            CASE WHEN ch.PerfilHora4 = 'P3' THEN ch.H4 ELSE 0 END +
            CASE WHEN ch.PerfilHora5 = 'P3' THEN ch.H5 ELSE 0 END +
            CASE WHEN ch.PerfilHora6 = 'P3' THEN ch.H6 ELSE 0 END +
            CASE WHEN ch.PerfilHora7 = 'P3' THEN ch.H7 ELSE 0 END +
            CASE WHEN ch.PerfilHora8 = 'P3' THEN ch.H8 ELSE 0 END +
            CASE WHEN ch.PerfilHora9 = 'P3' THEN ch.H9 ELSE 0 END +
            CASE WHEN ch.PerfilHora10 = 'P3' THEN ch.H10 ELSE 0 END +
            CASE WHEN ch.PerfilHora11 = 'P3' THEN ch.H11 ELSE 0 END +
            CASE WHEN ch.PerfilHora12 = 'P3' THEN ch.H12 ELSE 0 END +
            CASE WHEN ch.PerfilHora13 = 'P3' THEN ch.H13 ELSE 0 END +
            CASE WHEN ch.PerfilHora14 = 'P3' THEN ch.H14 ELSE 0 END +
            CASE WHEN ch.PerfilHora15 = 'P3' THEN ch.H15 ELSE 0 END +
            CASE WHEN ch.PerfilHora16 = 'P3' THEN ch.H16 ELSE 0 END +
            CASE WHEN ch.PerfilHora17 = 'P3' THEN ch.H17 ELSE 0 END +
            CASE WHEN ch.PerfilHora18 = 'P3' THEN ch.H18 ELSE 0 END +
            CASE WHEN ch.PerfilHora19 = 'P3' THEN ch.H19 ELSE 0 END +
            CASE WHEN ch.PerfilHora20 = 'P3' THEN ch.H20 ELSE 0 END +
            CASE WHEN ch.PerfilHora21 = 'P3' THEN ch.H21 ELSE 0 END +
            CASE WHEN ch.PerfilHora22 = 'P3' THEN ch.H22 ELSE 0 END +
            CASE WHEN ch.PerfilHora23 = 'P3' THEN ch.H23 ELSE 0 END +
            CASE WHEN ch.PerfilHora24 = 'P3' THEN ch.H24 ELSE 0 END) AS ConsumoP3,
        SUM(CASE WHEN ch.PerfilHora1 = 'P4' THEN ch.H1 ELSE 0 END +
            CASE WHEN ch.PerfilHora2 = 'P4' THEN ch.H2 ELSE 0 END +
            CASE WHEN ch.PerfilHora3 = 'P4' THEN ch.H3 ELSE 0 END +
            CASE WHEN ch.PerfilHora4 = 'P4' THEN ch.H4 ELSE 0 END +
            CASE WHEN ch.PerfilHora5 = 'P4' THEN ch.H5 ELSE 0 END +
            CASE WHEN ch.PerfilHora6 = 'P4' THEN ch.H6 ELSE 0 END +
            CASE WHEN ch.PerfilHora7 = 'P4' THEN ch.H7 ELSE 0 END +
            CASE WHEN ch.PerfilHora8 = 'P4' THEN ch.H8 ELSE 0 END +
            CASE WHEN ch.PerfilHora9 = 'P4' THEN ch.H9 ELSE 0 END +
            CASE WHEN ch.PerfilHora10 = 'P4' THEN ch.H10 ELSE 0 END +
            CASE WHEN ch.PerfilHora11 = 'P4' THEN ch.H11 ELSE 0 END +
            CASE WHEN ch.PerfilHora12 = 'P4' THEN ch.H12 ELSE 0 END +
            CASE WHEN ch.PerfilHora13 = 'P4' THEN ch.H13 ELSE 0 END +
            CASE WHEN ch.PerfilHora14 = 'P4' THEN ch.H14 ELSE 0 END +
            CASE WHEN ch.PerfilHora15 = 'P4' THEN ch.H15 ELSE 0 END +
            CASE WHEN ch.PerfilHora16 = 'P4' THEN ch.H16 ELSE 0 END +
            CASE WHEN ch.PerfilHora17 = 'P4' THEN ch.H17 ELSE 0 END +
            CASE WHEN ch.PerfilHora18 = 'P4' THEN ch.H18 ELSE 0 END +
            CASE WHEN ch.PerfilHora19 = 'P4' THEN ch.H19 ELSE 0 END +
            CASE WHEN ch.PerfilHora20 = 'P4' THEN ch.H20 ELSE 0 END +
            CASE WHEN ch.PerfilHora21 = 'P4' THEN ch.H21 ELSE 0 END +
            CASE WHEN ch.PerfilHora22 = 'P4' THEN ch.H22 ELSE 0 END +
            CASE WHEN ch.PerfilHora23 = 'P4' THEN ch.H23 ELSE 0 END +
            CASE WHEN ch.PerfilHora24 = 'P4' THEN ch.H24 ELSE 0 END) AS ConsumoP4,
        SUM(CASE WHEN ch.PerfilHora1 = 'P5' THEN ch.H1 ELSE 0 END +
            CASE WHEN ch.PerfilHora2 = 'P5' THEN ch.H2 ELSE 0 END +
            CASE WHEN ch.PerfilHora3 = 'P5' THEN ch.H3 ELSE 0 END +
            CASE WHEN ch.PerfilHora4 = 'P5' THEN ch.H4 ELSE 0 END +
            CASE WHEN ch.PerfilHora5 = 'P5' THEN ch.H5 ELSE 0 END +
            CASE WHEN ch.PerfilHora6 = 'P5' THEN ch.H6 ELSE 0 END +
            CASE WHEN ch.PerfilHora7 = 'P5' THEN ch.H7 ELSE 0 END +
            CASE WHEN ch.PerfilHora8 = 'P5' THEN ch.H8 ELSE 0 END +
            CASE WHEN ch.PerfilHora9 = 'P5' THEN ch.H9 ELSE 0 END +
            CASE WHEN ch.PerfilHora10 = 'P5' THEN ch.H10 ELSE 0 END +
            CASE WHEN ch.PerfilHora11 = 'P5' THEN ch.H11 ELSE 0 END +
            CASE WHEN ch.PerfilHora12 = 'P5' THEN ch.H12 ELSE 0 END +
            CASE WHEN ch.PerfilHora13 = 'P5' THEN ch.H13 ELSE 0 END +
            CASE WHEN ch.PerfilHora14 = 'P5' THEN ch.H14 ELSE 0 END +
            CASE WHEN ch.PerfilHora15 = 'P5' THEN ch.H15 ELSE 0 END +
            CASE WHEN ch.PerfilHora16 = 'P5' THEN ch.H16 ELSE 0 END +
            CASE WHEN ch.PerfilHora17 = 'P5' THEN ch.H17 ELSE 0 END +
            CASE WHEN ch.PerfilHora18 = 'P5' THEN ch.H18 ELSE 0 END +
            CASE WHEN ch.PerfilHora19 = 'P5' THEN ch.H19 ELSE 0 END +
            CASE WHEN ch.PerfilHora20 = 'P5' THEN ch.H20 ELSE 0 END +
            CASE WHEN ch.PerfilHora21 = 'P5' THEN ch.H21 ELSE 0 END +
            CASE WHEN ch.PerfilHora22 = 'P5' THEN ch.H22 ELSE 0 END +
            CASE WHEN ch.PerfilHora23 = 'P5' THEN ch.H23 ELSE 0 END +
            CASE WHEN ch.PerfilHora24 = 'P5' THEN ch.H24 ELSE 0 END) AS ConsumoP5,
        SUM(CASE WHEN ch.PerfilHora1 = 'P6' THEN ch.H1 ELSE 0 END +
            CASE WHEN ch.PerfilHora2 = 'P6' THEN ch.H2 ELSE 0 END +
            CASE WHEN ch.PerfilHora3 = 'P6' THEN ch.H3 ELSE 0 END +
            CASE WHEN ch.PerfilHora4 = 'P6' THEN ch.H4 ELSE 0 END +
            CASE WHEN ch.PerfilHora5 = 'P6' THEN ch.H5 ELSE 0 END +
            CASE WHEN ch.PerfilHora6 = 'P6' THEN ch.H6 ELSE 0 END +
            CASE WHEN ch.PerfilHora7 = 'P6' THEN ch.H7 ELSE 0 END +
            CASE WHEN ch.PerfilHora8 = 'P6' THEN ch.H8 ELSE 0 END +
            CASE WHEN ch.PerfilHora9 = 'P6' THEN ch.H9 ELSE 0 END +
            CASE WHEN ch.PerfilHora10 = 'P6' THEN ch.H10 ELSE 0 END +
            CASE WHEN ch.PerfilHora11 = 'P6' THEN ch.H11 ELSE 0 END +
            CASE WHEN ch.PerfilHora12 = 'P6' THEN ch.H12 ELSE 0 END) AS ConsumoP6
INTO TFG_LCM_ConsumoDiariov3
FROM CurvaHoraria ch
JOIN TFG_LCM_ConsumoFacturado cf
    ON ch.idCUPS = cf.idCUPS
    AND ch.Fecha BETWEEN cf.FechaDesdeFactura AND cf.FechaHastaFactura
GROUP BY ch.idCUPS, cf.NumeroAlbaran;   

-- 4. CREAR TABLA TFG_LCM_ResultadoComparativaEnergia
SELECT 
    cf.idCUPS as idcups_factura,
    cf.EjercicioAlbaran,
    cf.NumeroAlbaran,
    cf.SerieAlbaran,
    cf.FechaDesdeFactura,
    cf.FechaHastaFactura,
    DATEDIFF(DAY, cf.FechaDesdeFactura, cf.FechaHastaFactura) AS numdiasFactu,
    cd.numdias,
    cd.ConsumoP1, cd.ConsumoP2, cd.ConsumoP3, cd.ConsumoP4, cd.ConsumoP5, cd.ConsumoP6,
    precio_P1,precio_P2,precio_P3,precio_P4,precio_P5,precio_P6,
    cf.EnergiaFacturada_P1, cf.EnergiaFacturada_P2, cf.EnergiaFacturada_P3, cf.EnergiaFacturada_P4, cf.EnergiaFacturada_P5, cf.EnergiaFacturada_P6,
   	NombreCups,NumerocontratoATR,DomicilioCUPS,CodigoPostalCUPS,
	MunicipioCUPS,ProvinciaCUPS,FechaActivacion,FechaAceptacion,FechaBaja,
	FacturarMaximetro,Reactiva,ConsumoGratuito,RecargoPorExceso,TarifaCUPS,
	UtilizarTarifa,P1,P2,P3,TP1,TP2,TP3,FechaRevisionCUPS,
	CodigoPostalEnvios,MunicipioEnvios,ProvinciaEnvios,
	EmailEnvios,	ConsumoMedioDiarioP1,ConsumoMedioDiarioP2,ConsumoMedioDiarioP3,
	CodigoDistribuidora,NumContador,Potencia1Contratada,Potencia2Contratada,Potencia3Contratada,
	PropiedadContador,PrecioAlquilerMes,DiaFacturacion,FechaFinContrato,
	NumeroCUPS,Aceptado,CodigoMotivoRechazo,ConsumoMedioDiarioR1,ConsumoMedioDiarioR2,ConsumoMedioDiarioR3,
	TipoContratoATR,CNAE,FactorMaximetro,CMMR,TpReactMin,TpReactMax,
	RefCatastral,ConsumoMedioDiarioP10,ConsumoMedioDiarioP20,ConsumoMedioDiarioP30,ConsumoMedioDiarioR10,ConsumoMedioDiarioR20,ConsumoMedioDiarioR30,
	CodigoIncidencia,OffsetPunta,OffsetLlano,OffsetValle,ModoDiaFact,AplicarPenalizacion,
	DiasConsumo,ConsumoTotalP1,ConsumoTotalP2,ConsumoTotalP3,ConsumoTotalR1,ConsumoTotalR2,ConsumoTotalR3,
	NumeroFactura,EjercicioFactura,SerieFactura,UltimaLecturaInicialP1,UltimaLecturaInicialP2,UltimaLecturaInicialP3,
	UltimaLecturaInicialR1,UltimaLecturaInicialR2,UltimaLecturaInicialR3,UltimaLecturaFinalP1,UltimaLecturaFinalP2,UltimaLecturaFinalP3,
	UltimaLecturaFinalR1,UltimaLecturaFinalR2,UltimaLecturaFinalR3,FechaUltimaLecturaInicial,
	FechaUltimaLecturaFinal,FechaUltimoAlbCompra,FechaUltimoAlbVenta,LecturaAnteriorPunta,LecturaAnteriorLlano,
	LecturaAnteriorValle,LecturaActualPunta,LecturaActualLlano,LecturaActualValle,LecturaAnteriorCompraPunta,
	LecturaAnteriorCompraLlano,LacturaAnteriorCompraValle,LecturaActualCompraPunta,LacturaActualCompraLlano,LecturaActualCompraValle,
	ConsumoPunta,ConsumoLlano,ConsumoValle,ConsumoCompraPunta,ConsumoCompraLlano,ConsumoCompraValle,
	TotalP0Compra,TotalAECompra,TotalR0Compra,TotalP0Venta,TotalAEVenta,TotalR0Venta,
	CodigoProyecto,EstadoCUPS,FechaEstadoCups,IDCupsCorto,LecturaAnteriorReactiva,LecturaActualReactiva,ConsumoReactiva,
	LecturaAnteriorCompraReactiva,LecturaActualCompraReactiva,ConsumoCompraReactiva,LecturaActAutomatica,
	TotalPuntaCompra,TotalLlanoCompra,TotalValleCompra,TotalDiasCompra,TotalPuntaVenta,TotalLlanoVenta,TotaalValleVenta,TotalDiasVenta,
	MaximetroActual,MaximetroAnterior,MaximetroActualCompra,MaximetroAnteriorCompra,
	TieneLecturasVenta,TieneLecturasCompra,CodigoComisionista,Comisionista,
	ConsumoMedioDiarioP4,ConsumoMedioDiarioP5,ConsumoMedioDiarioP6,CodigoZona,TarifaMaestra,
	EstadoCUPSPRevision,FechaEstadoCUPSPrev,EsGas,ImporteComision,consumo_anual,
	StatusCUPS,TipoCUPS,TeleMedida,ComisionIndexado,GastosOperativos,CostesFinancieros,
	Potencia4Contratada,Potencia5Contratada,Potencia6Contratada,FechaRenovacion,DiasUltimoAlbVenta,GeneraLineasPotencia,
	P4,P5,P6,Prepago,MensualSemanal,ImportePrePago,FechaFirmaContrato,ConfirmacionPago,CambioPotencia,CambioTitular,
	Representante,Titular,CifTitular,PrecioEnergia,DuracioncontratoATR,TarifaATR,TipoEquipoMedida,
	TarifaCaptacion,FechaCaptacion,ComprasMediasPorDia,VentasMediasPorDia,FacturarTresPotencias,
	Marca,FechaActivacionOLD,CodigoMunicipio,CodigoProvincia,	MunicipioCUPSOriginal,FacturarEstimadas,
	PrecioCaptacion,Multicontador,SubComisionista,TieneHistorialConsumos,EsTarifaPlana,
	SinImpuestoElectrico,FiltroPenalizacion,UltimoEnvioBurofax,
	CodigoCNAE09,	ConCurvaHoraria,RecibirPublicidad,
	DistAnterior,EsGasAltaPresion,CodigoProveedorAux,ServicioMercadoElectricoPrecio,ServicioMercadoElectricoMinimo,
	PenalizarGeneriber,CodigoUnidadFisica,CIL,PotenciaNominal,GrupoNormativo,TipoCombustible,
	ClaveDeRegistro,RegistroAutonomico,UnidadFisica,UnidadDeProgramacion,UnidadDeOferta,EnergiaExportada,
	CodigoZonaOMIE,TieneCP,FacturacionSemanalOMIE,FacturacionQuincenalREE,FacturacionQuincenalOMIEREE,
	FacturacionMensualCNMC,AplicarInterrumpibilidad,Porcentual85IE,FechaInicioExencion,FechaFinExencion,
	AplicarPotenciaOptimizada,PotenciaOptimizada1,PotenciaOptimizada2,PotenciaOptimizada3,PotenciaOptimizada4,PotenciaOptimizada5,PotenciaOptimizada6,Aplicar85PotenciaOptimizada,
	FechaInicioOptimizada,GenerarBajaTP,TienePrecioFijo,FechaUltimaRenovacion,BloqueoAlbVenta,
	MotivoBloqueo,FechaProximaRenovacion,FechaRenovacionAntigua,PotenciaAnterior1,PotenciaAnterior2,PotenciaAnterior3,PotenciaAnterior4,PotenciaAnterior5,PotenciaAnterior6,
	TieneCPInicial,TieneCTInicial,AplicadoCPInicial,FechaUltRenovacionContrato,
	AplicarCambioContage,FacturacionMensualOMIE,TieneServicioUrgencias,TieneServicioMantenimiento,
	TieneProteccionPagos,TieneAlquilerEquiposFijo,AlquilerEquiposFijo,IdCupsDual,
	Comercial,Franquicia,StatusCreadoXML,POTFacturarPorDiasOMes,NoGastosDevolucion,uso_energia,
	consumo_contratado,Cantidad_anual_contratada,dias_funcionamiento_semanal,meses_funcionamiento_anno,
	tipo_contrato,esReferencia,idcontratoluz,IdContratoGas,assistLuzGas,assistLuz,assistGas,protPag,
	Comision,TipoRenovacion,NacionalidadCliente,AxesorValidado,EsTarifaSocial,CAE,ComprasMediasPorDiaEnergia,ComprasMediasPorDiaPotencia,ComprasMediasPorDiaResto,VentasMediasPorDiaEnergia,
	VentasMediasPorDiaPotencia,VentasMediasPorDiaResto,DiasPrecioMedio,BICPT,FechaNacimiento,TipoClienteReferenciaPT,
	FechaUltimaImportacion,ConsumoP0,ConsumoUltimoAnyo,ConsumoDiarioUltAnyo,DiasAPenalizar,DiasConConsumo,FechaInicioUltContrato,
	FechaFinalUltContrato,AplicarCosteAudax,DescuentoEnergiaActiva,FechaInicioContrato,
	TipoContrato,TipoCifRepresentante,TipoCifTitular,tipoPersona,archivoRecibido,fechaArchivoRecibido,CodigoComisionistaUltPoliza,
	AtencionDePersona,ConsumoMedioDiario,BonoSocial,Comercial_franquicia,BRAND,
	DiasAgujeroFacturacion,DiasAgujeroCompras,TieneAgujeros,GenerarCurvaCarga,TipoDeGas,
	SerMantLLUM,SerMantGAS,SerMantPROTECCION,CodigoIdioma_,PrimeraFacturaPagada,PeriodicidadLecturas,
	FechaCarga_,idCarga,AplicarIPC,AnyoBisiesto,IAudiovisualReducido,
	AltaNueva,TipoATR,Id_Suministro,CodComerREE,EstadoIGSE,FechaFinalContratoAutoconsumo,FechaInicioContratoAutoconsumo,
	CodigoAutoconsumo,GDO,CodigoDGEG,FechaReclamacionDistribuidora,
	NumMesesContrato,FechaEjecucionRenovacion,FechaModificacion,
	IdContratoWeb,Consumo_AnualP1,Consumo_AnualP2,Consumo_AnualP3,Consumo_AnualP4,Consumo_AnualP5,Consumo_AnualP6,
	CTActivo,StatusEsencial,FechaActivacionSolicitada,
	PrecioExcedenteP1,PrecioExcedenteP2,PrecioExcedenteP3,PrecioExcedenteP4,PrecioExcedenteP5,PrecioExcedenteP6,
	DecimalesEnPrecio,Alias,EsFamiliaNumerosa,BloqueoVenta,MotivoBloqueoVenta,
	MostrarGOEnFactura,TipoPuntoMedida,TipoAutoconsumo,FechaHastaUltimaPoliza,
	SIPSRev,CIE,FechaNotificacionEnFactura,DocumentoNotificacion,FechaActualizacionSIPSRev,
	ADX_RegFiscalIE,FechaHastaFacturaNotificacion,consumo_iGSECom,consumo_calculado,Tipoconsumocalculado,
	Cluster,consumoreal,TipoFacturacionAutoconsumo,TarifaMaestraAnterior,TarifaCupsAnterior,
	ADX_CodMotivo,ClasificacionSuministro,CodigoMotivoATR,EstadoATR,NivTension,ZonaSolar,
	MensajeShell,CodigoZonaSolar,ClienteNecesidadesEspeciales,Mermas,TipoCompensacionExcedente,
	GOAudax,	CodigoCliente_ADX,RefCatastralProvisional,CodigoGPB,MixEnergeticoPT,SuministroEventual,
	SIPSRevP1,SIPSRevP2,SIPSRevP3,SIPSRevP4,SIPSRevP5,SIPSRevP6,FacturarEstimadas_Motivo,
	DICASImporte,DICASDocumento,DICASStatus,DICASFrecuencia,MarcaMedPerd,VAsTrafo,PorPerdidas,
	ConsumoAnualM3,EscaladodeConsumo,NiveldePreion
INTO TFG_LCM_ResultadoComparativaEnergiav3
FROM TFG_LCM_ConsumoFacturadov3 cf
JOIN TFG_LCM_ConsumoDiariov3 cd
    ON cf.idCUPS = cd.idCUPS AND cf.NumeroAlbaran = cd.NumeroAlbaran
join cups c on cf.idCUPS = c.idCUPS     
where EnergiaFacturada_P1 >0
 and numdias >20
 and numdias <40;