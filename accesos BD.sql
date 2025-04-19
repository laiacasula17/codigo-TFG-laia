

--audaxbasemedidasperfilado
--zona: 1 pensinula, 2 baleares 3 canaries
--HorasEnP1
-- CoeficienteHora01 perfil BOE
--SumaCoeficientesP1 boe en P1
WITH
ConsumoFacturado AS (
    SELECT 
        cac.idCUPS,
        cac.EjercicioAlbaran,
        cac.NumeroAlbaran,
        cac.SerieAlbaran, 
        cac.FechaDesdeFactura, 
        cac.FechaHastaFactura, 
        SUM(CASE WHEN lac.DescripcionArticulo LIKE '%P1%' THEN lac.Unidades ELSE 0 END) AS EnergiaFacturada_P1,
        SUM(CASE WHEN lac.DescripcionArticulo LIKE '%P2%' THEN lac.Unidades ELSE 0 END) AS EnergiaFacturada_P2,
        SUM(CASE WHEN lac.DescripcionArticulo LIKE '%P3%' THEN lac.Unidades ELSE 0 END) AS EnergiaFacturada_P3,
        SUM(CASE WHEN lac.DescripcionArticulo LIKE '%P4%' THEN lac.Unidades ELSE 0 END) AS EnergiaFacturada_P4,
        SUM(CASE WHEN lac.DescripcionArticulo LIKE '%P5%' THEN lac.Unidades ELSE 0 END) AS EnergiaFacturada_P5,
        SUM(CASE WHEN lac.DescripcionArticulo LIKE '%P6%' THEN lac.Unidades ELSE 0 END) AS EnergiaFacturada_P6
    FROM 
        [ADXMURANO].[dbo].CabeceraAlbaranCliente cac
    JOIN 
        [ADXMURANO].[dbo].lineasAlbaranCliente lac
        ON cac.EjercicioAlbaran = lac.EjercicioAlbaran
        AND cac.SerieAlbaran = lac.SerieAlbaran
        AND cac.NumeroAlbaran = lac.NumeroAlbaran
    WHERE 1=1
     and cac.idCUPS = 'ES0031405093566001EQ0F'
     and cac.EjercicioAlbaran >='2024'
--     and cac.NumeroAlbaran =       '11924'
     AND lac.CodigoSubfamilia = 'Energia'  -- Solo conceptos de energía
    GROUP BY 
        cac.idCUPS, cac.EjercicioAlbaran, cac.NumeroAlbaran, cac.SerieAlbaran, 
        cac.FechaDesdeFactura, cac.FechaHastaFactura  
),
 ConsumoDiario AS (
    SELECT 
        ch.idCUPS, 
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
            ,cf.NumeroAlbaran
            ,count(fecha) numdias
    FROM 
        [ADXMURANO].[dbo].CurvaHoraria ch
        join ConsumoFacturado cf on  ch.idCUPS=cf.idcups  
           AND ch.Fecha BETWEEN cf.FechaDesdeFactura AND cf.FechaHastaFactura
    GROUP BY 
        ch.idCUPS, cf.NumeroAlbaran
)
SELECT 
    cf.idCUPS as cups,
    cf.EjercicioAlbaran as eje,
    cf.NumeroAlbaran as num,
    cf.SerieAlbaran as serie,
    cf.FechaDesdeFactura as FechD, 
    cf.FechaHastaFactura as FechH, 
    DATEDIFF(DAY, cf.FechaDesdeFactura, cf.FechaHastaFactura) AS numdiasFactu,
    cd.numdias as numdiasCurvas,
    cd.ConsumoP1 as P1Curvas,  
    cd.ConsumoP2 as P2Curvas,
    cd.ConsumoP3 as P3Curvas,
    --cd.ConsumoP4 as P4Curvas,
    --cd.ConsumoP5 as P5Curvas,
    --cd.ConsumoP6 as P6Curvas,
    cf.EnergiaFacturada_P1 as P1Factu,
    cf.EnergiaFacturada_P2 as P2Factu,
    cf.EnergiaFacturada_P3 as P3Factu
    --,cf.EnergiaFacturada_P4 as P4Factu,
    --cf.EnergiaFacturada_P5 as P5Factu,
    --cf.EnergiaFacturada_P6 as P6Factu
FROM ConsumoFacturado cf
JOIN ConsumoDiario cd 
    ON cf.idCUPS = cd.idCUPS and cf.NumeroAlbaran=cd.NumeroAlbaran
--    AND cd.Fecha BETWEEN cf.FechaDesdeFactura AND cf.FechaHastaFactura
ORDER BY 
    cf.idCUPS, cf.FechaDesdeFactura

    
select count(distinct idcups ) from  [ADXMURANO].[dbo].CurvaHoraria ch    
where fecha >='2024-01-01 00:00:00.000'


SELECT *
FROM [ADXMURANO].[dbo].CurvaHoraria
WHERE idCUPS = 'ES0031405404649015ZA0F'
--AND Fecha BETWEEN '2024-04-24' AND '2024-05-22';


    SELECT 
        cac.idCUPS,cac.EjercicioAlbaran ,cac.NumeroAlbaran ,cac.SerieAlbaran ,
        cac.FechaDesdeFactura, 
        cac.FechaHastaFactura,
        LecturaP1 
    FROM 
        [ADXMURANO].[dbo].CabeceraAlbaranCliente cac
    WHERE 
        cac.idCUPS = 'ES0031405404649015ZA0F'
        
        
      SELECT          * 
    FROM          [ADXMURANO].[dbo].lineasAlbaranCliente cac  
     where 1=1
     and EjercicioAlbaran ='2024'
     and SerieAlbaran ='24'
     and NumeroAlbaran =       '11924'
        
     
    SELECT 
        cac.idCUPS,
        cac.EjercicioAlbaran,
        cac.NumeroAlbaran,
        cac.SerieAlbaran, 
        cac.FechaDesdeFactura, 
        cac.FechaHastaFactura, 
        SUM(CASE WHEN lac.DescripcionArticulo LIKE '%P1%' THEN lac.Unidades ELSE 0 END) AS EnergiaFacturada_P1,
        SUM(CASE WHEN lac.DescripcionArticulo LIKE '%P2%' THEN lac.Unidades ELSE 0 END) AS EnergiaFacturada_P2,
        SUM(CASE WHEN lac.DescripcionArticulo LIKE '%P3%' THEN lac.Unidades ELSE 0 END) AS EnergiaFacturada_P3,
        SUM(CASE WHEN lac.DescripcionArticulo LIKE '%P4%' THEN lac.Unidades ELSE 0 END) AS EnergiaFacturada_P4,
        SUM(CASE WHEN lac.DescripcionArticulo LIKE '%P5%' THEN lac.Unidades ELSE 0 END) AS EnergiaFacturada_P5,
        SUM(CASE WHEN lac.DescripcionArticulo LIKE '%P6%' THEN lac.Unidades ELSE 0 END) AS EnergiaFacturada_P6
    FROM 
        [ADXMURANO].[dbo].CabeceraAlbaranCliente cac
    JOIN 
        [ADXMURANO].[dbo].lineasAlbaranCliente lac
        ON cac.EjercicioAlbaran = lac.EjercicioAlbaran
        AND cac.SerieAlbaran = lac.SerieAlbaran
        AND cac.NumeroAlbaran = lac.NumeroAlbaran
    WHERE 1=1
     and cac.idCUPS = 'ES0031405404649015ZA0F'
     and EjercicioAlbaran ='2024'
     and SerieAlbaran ='24'
     and NumeroAlbaran =       '11924'
     AND lac.CodigoSubfamilia = 'Energia'  -- Solo conceptos de energía
    GROUP BY 
        cac.idCUPS, cac.EjercicioAlbaran, cac.NumeroAlbaran, cac.SerieAlbaran, 
        cac.FechaDesdeFactura, cac.FechaHastaFactura     
