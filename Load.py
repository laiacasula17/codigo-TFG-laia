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

# Reemplaza NaN por cadenas vacías para que no falle al subir a Google Sheets
df = df.fillna("")

# Añadir columna con la fecha y hora de actualización
fecha_actual = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
df["fecha_actualizacion"] = fecha_actual

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
pestana.update([df.columns.values.tolist()] + df.values.tolist())

log("✅ Proceso completado: los datos se han actualizado correctamente en Google Sheets.")
