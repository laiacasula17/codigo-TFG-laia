# subir.py
import pandas as pd
import gspread
from google.oauth2.service_account import Credentials
from datetime import datetime

# Función de log con marca de tiempo para seguimiento del proceso
def log(mensaje):
    print(f"[{datetime.now().strftime('%H:%M:%S')}] {mensaje}")

# CONFIGURACIÓN GENERAL
NOMBRE_HOJA = "TFG_Looker_Fix"  # Nombre fijo de la hoja de cálculo en Google Sheets
RUTA_CSV = "TFG_LCM_ResultadoParaLooker.csv"  # Archivo CSV que contiene los resultados procesados
RUTA_CREDENCIALES = "tfglaiacasula-b67699ffeb58.json"  # Archivo de claves de la cuenta de servicio
USUARIO_GMAIL = "laia.casula@gmail.com"  # Dirección del autor del TFG

# PASO 1: Cargar el fichero CSV con los resultados
log("Cargando archivo CSV local...")
df = pd.read_csv(RUTA_CSV, sep=';')

# Filtrar únicamente productos deseados: 0, 3, 10
df = df[df["Producto"].isin([0, 3, 10])]

# Renombrar los valores numéricos por etiquetas legibles
df["Producto"] = df["Producto"].replace({
    0: "Classic",
    3: "Corporate",
    10: "Campaña"
})

# Filtrar únicamente tarifas deseadas: 20TD, 30TD, 61TD, 62TD
df = df[df["tarifa"].isin(["20TD", "30TD", "61TD", "62TD", "63TD", "64TD"])]

# Reemplaza NaN por cadenas vacías para que no falle al subir a Google Sheets
df = df.fillna("")

# Cálculo de % de ahorro sobre distintas bases
df["pct_ahorro_sobre_facturado"] = df["ahorro_positivo"] / df["facturacion_actual"]


# Clasificar ahorro en una sola columna categórica
def clasificar_ahorro(valor):
    if valor >= 50:
        return 'Ahorro'
    elif valor > 0.1:
        return 'Poco ahorro'
    else:
        return 'Sin ahorro'

df["clasificacion_ahorro"] = df["ahorro_positivo"].apply(clasificar_ahorro)

# Eliminar columnas innecesarias para simplificar análisis en Looker
columnas_a_eliminar = [
    "cluster", "cluster_nombre",
    "categoria_ahorro" if "categoria_ahorro" in df.columns else None
]
df = df.drop(columns=[c for c in columnas_a_eliminar if c in df.columns])


# Añadir columna con la fecha y hora de actualización
fecha_actual = datetime.now()
df["fecha_actualizacion"] = fecha_actual.strftime("%Y-%m-%dT%H:%M:%S")

# PASO 2: Autenticación segura con la API de Google Sheets
log("Autenticando con Google Sheets...")
scopes = [
    "https://www.googleapis.com/auth/spreadsheets",
    "https://www.googleapis.com/auth/drive"
]
credenciales = Credentials.from_service_account_file(RUTA_CREDENCIALES, scopes=scopes)
cliente = gspread.authorize(credenciales)

# PASO 3: Buscar si la hoja de cálculo ya existe
log(f"Comprobando si existe una hoja llamada '{NOMBRE_HOJA}'...")
try:
    hoja_calculo = cliente.open(NOMBRE_HOJA)
    log("✅ Hoja de cálculo encontrada.")
except gspread.SpreadsheetNotFound:
    log("🔄 No encontrada. Creando una nueva hoja de cálculo...")
    hoja_calculo = cliente.create(NOMBRE_HOJA)
    hoja_calculo.share(USUARIO_GMAIL, perm_type='user', role='writer')
    log("✅ Hoja creada y compartida correctamente con el autor.")

# PASO 4: Volcado de datos en la primera pestaña
log("Limpiando contenido anterior y subiendo nuevos datos...")
pestana = hoja_calculo.get_worksheet(0)  # Selecciona la primera pestaña
pestana.clear()
df.replace([float('inf'), float('-inf')], pd.NA, inplace=True)
df = df.fillna("")
pestana.update([df.columns.values.tolist()] + df.values.tolist())

log("✅ Proceso completado: los datos se han actualizado correctamente en Google Sheets.")
