# Librerías necesarias
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score
from datetime import datetime

# Función de log con hora
def log(msg):
    print(f"[{datetime.now().strftime('%H:%M:%S')}] {msg}")

# ========================= SPRINT 1: Obtención y validación de datos =========================
log("Cargando fichero...")
file_path = "Todosv2.csv"
df = pd.read_csv(file_path, delimiter=';', low_memory=False)
log(f"Fichero cargado con {len(df)} registros")

# ========================= SPRINT 2: Limpieza y estructuración =========================
# Conversión de columnas numéricas
consumo_cols = ['ConsumoP1', 'ConsumoP2', 'ConsumoP3', 'ConsumoP4', 'ConsumoP5', 'ConsumoP6']
facturado_cols = ['EnergiaFacturada_P1', 'EnergiaFacturada_P2', 'EnergiaFacturada_P3', 'EnergiaFacturada_P4', 'EnergiaFacturada_P5', 'EnergiaFacturada_P6']
otras_cols = ['numdias', 'numdiasFactu', 'PrecioEnergia', 'precio_P1', 'precio_P2', 'precio_P3', 'precio_P4', 'precio_P5', 'precio_P6']

log("Convirtiendo columnas a formato numérico...")
todas = consumo_cols + facturado_cols + otras_cols
df[todas] = df[todas].astype(str).apply(lambda x: x.str.replace(',', '.', regex=False))
df[todas] = df[todas].apply(pd.to_numeric, errors='coerce')

# Eliminación de valores inválidos y filtrado
log("Aplicando filtros de calidad...")
df = df[df['EsGas'] == 0]
df['diferencia_dias'] = abs(df['numdias'] - df['numdiasFactu'])
df = df[df['diferencia_dias'] <= 2]
df.replace([np.inf, -np.inf], np.nan, inplace=True)
df.dropna(subset=todas, inplace=True)
for col in consumo_cols + facturado_cols:
    df = df[df[col] >= 0]
df = df[(df['numdias'] > 0) & (df['numdiasFactu'] > 0)]
log(f"Filtrado aplicado: {len(df)} registros tras aplicar EsGas=0 y diferencia de días <=2")

# ========================= SPRINT 3: Comparativa de perfiles y cálculo de desvíos =========================
log("Calculando desvíos por periodo...")
for i in range(1, 7):
    df[f'desvioP{i}'] = (df[f'ConsumoP{i}'] / df['numdias']) - (df[f'EnergiaFacturada_P{i}'] / df['numdiasFactu'])

log("Calculando coste estimado con curvas y con facturación usando precios por periodo...")
df['coste_curvas'] = sum(df[f'ConsumoP{i}'] * df[f'precio_P{i}'] for i in range(1, 7))
df['coste_facturado'] = sum(df[f'EnergiaFacturada_P{i}'] * df[f'precio_P{i}'] for i in range(1, 7))
df['ahorro_estimado'] = df['coste_facturado'] - df['coste_curvas']

# ========================= SPRINT 5: Reglas de negocio y simulación =========================
log("Agrupando datos por CUPS para evaluar ahorro anual por cliente...")
agregado_por_cups = df.groupby('idcups_factura').agg(
    ahorro_total=('ahorro_estimado', 'sum'),
    consumo_total=('coste_curvas', 'sum'),
    facturacion_total=('coste_facturado', 'sum'),
    tarifa=('TarifaMaestra', 'first'),
    CP=('CodigoPostalCUPS', 'first'),
    numdias=('numdias', 'sum')
).reset_index()

log("Calculando desviaciones agregadas por CUPS (por cliente)...")
for i in range(1, 7):
    df[f'desvioP{i}'] = (df[f'ConsumoP{i}'] / df['numdias']) - (df[f'EnergiaFacturada_P{i}'] / df['numdiasFactu'])
agregado_por_cups['desvio_total_medio'] = df.groupby('idcups_factura')[[f'desvioP{i}' for i in range(1, 7)]].mean().mean(axis=1).values
agregado_por_cups['desvio_maximo'] = df.groupby('idcups_factura')[[f'desvioP{i}' for i in range(1, 7)]].mean().abs().max(axis=1).values

def calc_desvio_pct(grupo):
    consumo_total = grupo[[f'ConsumoP{i}' for i in range(1, 7)]].sum(axis=1).sum()
    if consumo_total == 0 or grupo['numdias'].sum() == 0:
        return 0
    return grupo[[f'desvioP{i}' for i in range(1, 7)]].sum(axis=1).sum() / (consumo_total / grupo['numdias'].sum())

agregado_por_cups['desvio_pct_sobre_consumo'] = df.groupby('idcups_factura', group_keys=False).apply(calc_desvio_pct).values

# ========================= SPRINT 4: Segmentación y visualización =========================
log("Normalizando variables para clustering...")
features = ['desvio_total_medio', 'desvio_maximo', 'desvio_pct_sobre_consumo']
scaler = StandardScaler()
X_scaled = scaler.fit_transform(agregado_por_cups[features])

log("Aplicando clustering final con k = 3 (determinado previamente)...")
kmeans_final = KMeans(n_clusters=3, random_state=42)
agregado_por_cups['cluster'] = kmeans_final.fit_predict(X_scaled)

nombres_clusters = {
    0: 'Facturación ≈ Curvas',
    1: 'Facturación > Curvas',
    2: 'Facturación < Curvas'
}
agregado_por_cups['cluster_nombre'] = agregado_por_cups['cluster'].map(nombres_clusters)

log("Mostrando centroides de los clusters...")
centroids = pd.DataFrame(kmeans_final.cluster_centers_, columns=features)
plt.figure(figsize=(10, 4))
sns.heatmap(centroids, annot=True, fmt=".2f", cmap="coolwarm", yticklabels=[nombres_clusters[i] for i in range(3)])
plt.title("Centroides de los Clusters (valores estandarizados)")
plt.xlabel("Variables")
plt.ylabel("Cluster")
plt.tight_layout()
plt.show()

log("Marcando clientes recomendados si el ahorro total es positivo...")
agregado_por_cups['cliente_recomendado_curva'] = agregado_por_cups['ahorro_total'] < 0

log("Analizando qué variables concentran más clientes con ahorro superior a 100€...")
clientes_ahorro100 = agregado_por_cups[agregado_por_cups['ahorro_total'] < -100]
resumen_tarifa = clientes_ahorro100.groupby('tarifa').agg(
    clientes_con_ahorro=('idcups_factura', 'count'),
    ahorro_total=('ahorro_total', 'sum'),
    ahorro_medio=('ahorro_total', 'mean')
).sort_values(by='clientes_con_ahorro', ascending=False)
print("Distribución de ahorro >100€ según tarifa:")
print(resumen_tarifa.head(int(len(resumen_tarifa) * 0.1)))

resumen_cp = agregado_por_cups.groupby('CP').agg(
    clientes_con_ahorro=('cliente_recomendado_curva', lambda x: (x == True).sum()),
    clientes_sin_ahorro=('cliente_recomendado_curva', lambda x: (x == False).sum()),
    total=('cliente_recomendado_curva', 'count'),
    ahorro_total=('ahorro_total', 'sum')
).sort_values(by='clientes_con_ahorro', ascending=False)
resumen_cp['ahorro_medio'] = resumen_cp['ahorro_total'] / resumen_cp['clientes_con_ahorro']
print("\nDistribución de ahorro >100€ según código postal (con sin y total):")
print(resumen_cp.head(int(len(resumen_cp) * 0.1)))

# Nuevo bloque: mismo resumen para tarifa
resumen_tarifa_all = agregado_por_cups.groupby('tarifa').agg(
    clientes_con_ahorro=('cliente_recomendado_curva', lambda x: (x == True).sum()),
    clientes_sin_ahorro=('cliente_recomendado_curva', lambda x: (x == False).sum()),
    total=('cliente_recomendado_curva', 'count'),
    ahorro_total=('ahorro_total', 'sum')
).sort_values(by='clientes_con_ahorro', ascending=False)
resumen_tarifa_all['ahorro_medio'] = resumen_tarifa_all['ahorro_total'] / resumen_tarifa_all['clientes_con_ahorro']
print("\nDistribución de ahorro >100€ según tarifa (con sin y total):")
print(resumen_tarifa_all.head(int(len(resumen_tarifa_all) * 0.1)))

clientes_con_ahorro = agregado_por_cups['cliente_recomendado_curva'].sum()
clientes_sin_ahorro = len(agregado_por_cups) - clientes_con_ahorro
log(f"Total de clientes recomendados: {clientes_con_ahorro} (sin ahorro: {clientes_sin_ahorro} de {len(agregado_por_cups)} total)")

log("\nResumen de impacto económico si se aplicara facturación por curva a clientes recomendados:")
print(agregado_por_cups[agregado_por_cups['cliente_recomendado_curva']].agg({
    'idcups_factura': 'count',
    'ahorro_total': ['sum', 'mean']
}).rename(index={
    'count': 'total_clientes',
    'sum': 'ahorro_total',
    'mean': 'ahorro_medio'
}))

log("Proceso finalizado con éxito. Clustering, análisis y simulación completados.")