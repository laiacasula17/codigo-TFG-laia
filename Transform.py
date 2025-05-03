# Librerías necesarias
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score
from datetime import datetime

# Función de log con hora para trazabilidad del proceso
def log(msg):
    print(f"[{datetime.now().strftime('%H:%M:%S')}] {msg}")

# ========================= SPRINT 1: Obtención y validación de datos =========================
log("Cargando fichero...")
file_path = "Extract.csv"
df = pd.read_csv(file_path, delimiter=';', low_memory=False)
log(f"Fichero cargado con {len(df):,} registros")

# ========================= SPRINT 2: Limpieza y estructuración =========================
log("Convirtiendo columnas a formato numérico...")
consumo_cols = ['ConsumoP1', 'ConsumoP2', 'ConsumoP3', 'ConsumoP4', 'ConsumoP5', 'ConsumoP6']
facturado_cols = ['EnergiaFacturada_P1', 'EnergiaFacturada_P2', 'EnergiaFacturada_P3', 'EnergiaFacturada_P4', 'EnergiaFacturada_P5', 'EnergiaFacturada_P6']
otras_cols = ['numdias', 'numdiasFactu', 'PrecioEnergia', 'precio_P1', 'precio_P2', 'precio_P3', 'precio_P4', 'precio_P5', 'precio_P6']
todas = consumo_cols + facturado_cols + otras_cols

for col in todas:
    df[col] = pd.to_numeric(df[col].astype(str).str.replace(',', '.', regex=False), errors='coerce')

# Filtrado de calidad
log("Aplicando filtros de calidad...")
df = df[df['EsGas'] == 0]
df['diferencia_dias'] = abs(df['numdias'] - df['numdiasFactu'])
df = df[df['diferencia_dias'] <= 2]
df.replace([np.inf, -np.inf], np.nan, inplace=True)
df.dropna(subset=todas, inplace=True)
for col in consumo_cols + facturado_cols:
    df = df[df[col] >= 0]
df = df[(df['numdias'] > 0) & (df['numdiasFactu'] > 0)]
log(f"Filtrado aplicado: {len(df):,} registros tras aplicar EsGas=0 y diferencia de días <=2")

# ========================= SPRINT 3: Comparativa de perfiles y cálculo de desvíos =========================
log("Calculando desvíos por periodo...")
for i in range(1, 7):
    df[f'desvioP{i}'] = (df[f'ConsumoP{i}'] / df['numdias']) - (df[f'EnergiaFacturada_P{i}'] / df['numdiasFactu'])

# Costes estimados (ajustado: si curvas < facturado, hay ahorro → positivo)
log("Calculando coste estimado con curvas y con facturación usando precios por periodo...")
df['coste_curvas'] = sum(df[f'ConsumoP{i}'] * df[f'precio_P{i}'] for i in range(1, 7))
df['coste_facturado'] = sum(df[f'EnergiaFacturada_P{i}'] * df[f'precio_P{i}'] for i in range(1, 7))
df['ahorro_estimado'] = df['coste_facturado'] - df['coste_curvas']  # >0 ahorro para el cliente

# ========================= SPRINT 4: Agrupación anual por CUPS =========================
log("Agrupando datos por CUPS para evaluación anual consolidada...")
if 'Producto' not in df.columns and 'BRAND' in df.columns:
    df = df.rename(columns={'BRAND': 'Producto'})

if 'FechaLectura' not in df.columns:
    df['FechaLectura'] = pd.NaT
if 'TipoCliente' not in df.columns:
    df['TipoCliente'] = df['CodigoPostalCUPS']

agregado_por_cups = df.groupby('idcups_factura', as_index=False).agg(
    ahorro_total=('ahorro_estimado', 'sum'),
    ahorro_positivo=('ahorro_estimado', lambda x: x[x > 0].sum()),
    consumo_total=('coste_curvas', 'sum'),
    facturacion_total=('coste_facturado', 'sum'),
    tarifa=('TarifaMaestra', 'first'),
    CP=('CodigoPostalCUPS', 'first'),
    Producto=('Producto', 'first'),
    Fecha=('FechaLectura', 'first'),
    TipoCliente=('TipoCliente', 'first'),
    numdias=('numdias', 'sum'),
    consumo_P1=('ConsumoP1', 'sum'),
    consumo_P2=('ConsumoP2', 'sum'),
    consumo_P3=('ConsumoP3', 'sum'),
    consumo_P4=('ConsumoP4', 'sum'),
    consumo_P5=('ConsumoP5', 'sum'),
    consumo_P6=('ConsumoP6', 'sum'),
    facturado_P1=('EnergiaFacturada_P1', 'sum'),
    facturado_P2=('EnergiaFacturada_P2', 'sum'),
    facturado_P3=('EnergiaFacturada_P3', 'sum'),
    facturado_P4=('EnergiaFacturada_P4', 'sum'),
    facturado_P5=('EnergiaFacturada_P5', 'sum'),
    facturado_P6=('EnergiaFacturada_P6', 'sum')
)
log(f"Total CUPS únicos: {len(agregado_por_cups):,}")

# ========================= Cálculo de desvíos agregados, clustering y análisis cruzado =========================
def calc_desvio_pct(grupo):
    consumo_total = grupo[[f'ConsumoP{i}' for i in range(1, 7)]].sum(axis=1).sum()
    if consumo_total == 0 or grupo['numdias'].sum() == 0:
        return 0
    return grupo[[f'desvioP{i}' for i in range(1, 7)]].sum(axis=1).sum() / (consumo_total / grupo['numdias'].sum())

log("Calculando desviaciones agregadas por CUPS (por cliente)...")
agregado_por_cups['desvio_total_medio'] = df.groupby('idcups_factura', group_keys=False)[[f'desvioP{i}' for i in range(1, 7)]].mean().mean(axis=1).values
agregado_por_cups['desvio_maximo'] = df.groupby('idcups_factura', group_keys=False)[[f'desvioP{i}' for i in range(1, 7)]].mean().abs().max(axis=1).values
agregado_por_cups['desvio_pct_sobre_consumo'] = df.groupby('idcups_factura', group_keys=False).apply(lambda grupo: calc_desvio_pct(grupo)).values

log("Normalizando variables para clustering...")
features = ['desvio_total_medio', 'desvio_maximo', 'desvio_pct_sobre_consumo']
scaler = StandardScaler()
X_scaled = scaler.fit_transform(agregado_por_cups[features])

log("Aplicando clustering final con k = 3 (determinado previamente)...")
kmeans_final = KMeans(n_clusters=3, random_state=42)
agregado_por_cups['cluster'] = kmeans_final.fit_predict(X_scaled)

nombres_clusters = {
    0: 'Clientes con perfil neutro',
    1: 'Ahorro con curvas',
    2: 'Ahorro facturación actual'
}
agregado_por_cups['cluster_nombre'] = agregado_por_cups['cluster'].map(nombres_clusters)

log("Mostrando centroides de los clusters...")
centroids = pd.DataFrame(kmeans_final.cluster_centers_, columns=features)
centroids.index = [nombres_clusters[i] for i in centroids.index]
plt.figure(figsize=(10, 4))
sns.heatmap(centroids, annot=True, fmt=".2f", cmap="coolwarm")
plt.title("Centroides de los Clusters (valores estandarizados)")
plt.ylabel("Descripción del Cluster")
plt.xlabel("Variables de desviación")
plt.tight_layout()
plt.show()

log("Analizando ahorro cruzado también por CP, Tarifa, Producto, Fecha y Tipo de Cliente...")
variables_extra = ['CP', 'tarifa', 'Producto', 'Fecha', 'TipoCliente']

for var in variables_extra:
    resumen = agregado_por_cups.groupby(var).agg(
        cups_con_ahorro=('ahorro_total', lambda x: (x > 50).sum()),
        cups_con_50=('ahorro_total', lambda x: ((x > 0.01) & (x <= 50)).sum()),
        cups_sin_ahorro=('ahorro_total', lambda x: (x <= 0.01).sum()),
        ahorro_positivo=('ahorro_total', lambda x: x[x > 0].sum()),
        ahorro_sin_ahorro=('ahorro_total', lambda x: x[x <= 0].sum()),
        facturacion_total_real=('facturacion_total', 'sum')
    )
    resumen['total'] = resumen[['cups_con_ahorro', 'cups_con_50', 'cups_sin_ahorro']].sum(axis=1)
    resumen['%_con_ahorro'] = (resumen['cups_con_ahorro'] / resumen['total'] * 100).round(2).astype(str) + '%'
    resumen['%_con_50'] = (resumen['cups_con_50'] / resumen['total'] * 100).round(2).astype(str) + '%'
    resumen['%_sin_ahorro'] = (resumen['cups_sin_ahorro'] / resumen['total'] * 100).round(2).astype(str) + '%'
    resumen['impacto_con_ahorro'] = agregado_por_cups[agregado_por_cups[var].isin(resumen.index) & (agregado_por_cups['ahorro_total'] > 50)].groupby(var)['ahorro_total'].sum()
    resumen['impacto_con_50'] = agregado_por_cups[agregado_por_cups[var].isin(resumen.index) & ((agregado_por_cups['ahorro_total'] > 0.01) & (agregado_por_cups['ahorro_total'] <= 50))].groupby(var)['ahorro_total'].sum()
    resumen['impacto_total_estimado'] = resumen['impacto_con_ahorro'] + resumen['impacto_con_50']
    total_impacto = resumen['impacto_total_estimado'].sum()
    resumen['%_impacto_estimado'] = (resumen['impacto_total_estimado'] / total_impacto * 100).round(2).astype(str) + '%'

    resumen['ahorro_positivo'] = resumen['ahorro_positivo'].apply(lambda x: f"{x:,.2f}€")
    resumen['impacto_con_ahorro'] = resumen['impacto_con_ahorro'].apply(lambda x: f"{x:,.2f}€")
    resumen['impacto_con_50'] = resumen['impacto_con_50'].apply(lambda x: f"{x:,.2f}€")
    resumen['impacto_total_estimado'] = resumen['impacto_total_estimado'].apply(lambda x: f"{x:,.2f}€")

    print(f"\nDistribución de ahorro >50€ según {var} (ordenado por impacto económico):")
    print(resumen.sort_values(by='impacto_total_estimado', ascending=False).head(20))
    
    # ========================= EXPORTACIÓN A CSV PARA LOOKER =========================
log("Exportando dataset simplificado para Looker Studio...")

log("Anonimizando identificadores...")

# Crear columna secuencial anónima
agregado_por_cups = agregado_por_cups.reset_index(drop=True)
agregado_por_cups['id_cliente'] = agregado_por_cups.index + 1  # Comienza en 1
agregado_por_cups['tiene_ahorro'] = agregado_por_cups['ahorro_total'] > 50
agregado_por_cups['tiene_ahorro_50'] = (agregado_por_cups['ahorro_total'] > 0.01) & (agregado_por_cups['ahorro_total'] <= 50)
agregado_por_cups['sin_ahorro'] = agregado_por_cups['ahorro_total'] <= 0.01


# Seleccionar columnas para exportar (sin idcups_factura)
columnas_looker = [
    'id_cliente', 'CP', 'tarifa', 'Producto', 'TipoCliente',
    'ahorro_total', 'ahorro_positivo',
    'tiene_ahorro', 'tiene_ahorro_50', 'sin_ahorro',
    'consumo_total', 'facturacion_total',
    'desvio_total_medio', 'desvio_maximo', 'desvio_pct_sobre_consumo',
    'cluster', 'cluster_nombre'
]


# Exportar CSV sin identificadores sensibles
agregado_por_cups[columnas_looker].to_csv("TFG_LCM_ResultadoParaLooker.csv", index=False, sep=';')

log("Fichero 'TFG_LCM_ResultadoParaLooker.csv' generado correctamente con identificadores anonimizados.")

