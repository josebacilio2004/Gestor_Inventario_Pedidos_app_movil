import os
import psycopg2
import firebase_admin
from firebase_admin import credentials, firestore, auth
from dotenv import load_dotenv

# 1. Configuración de variables
load_dotenv()
RENDER_DB_URL = os.getenv("RENDER_DB_URL") # Formato: postgres://user:pass@host:port/dbname
SERVICE_ACCOUNT_PATH = "service-account.json" # Generar en Consola Firebase -> Config -> Cuentas de Servicio

# 2. Mapeo de Usuarios Legacy
LEGACY_USERS = [
    {"username": "jose", "password": "jose123", "role": "operador"},
    {"username": "alicia", "password": "demo123", "role": "comprador"},
    {"username": "ssamira", "password": "demo123", "role": "inversionista"},
    {"username": "admin", "password": "admin123", "role": "admin"}
]

def migrate():
    # Inicializar Firebase
    cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    firebase_admin.initialize_app(cred)
    db = firestore.client()

    print("🚀 Iniciando migración de Render a Firebase...")

    # A. Crear Usuarios Legacy en Firebase Auth
    for user_data in LEGACY_USERS:
      email = f"{user_data['username']}@comercializadoraaly.com"
        try:
            user = auth.create_user(
                email=email,
                password=user_data['password'],
                display_name=user_data['username']
            )
            # Guardar rol en Firestore
            db.collection("users").document(user.uid).set({
                "username": user_data['username'],
                "email": email,
                "role": user_data['role'],
                "created_at": firestore.SERVER_TIMESTAMP
            })
            print(f"✅ Usuario creado: {email} (Rol: {user_data['role']})")
        except Exception as e:
            print(f"ℹ️ Usuario {email} ya existe o error: {e}")

    # B. Migrar Datos de Tablas SQL
    try:
        conn = psycopg2.connect(RENDER_DB_URL)
        cur = conn.cursor()

        # I. Migrar Productos
        cur.execute("SELECT * FROM productos")
        cols = [desc[0] for desc in cur.description]
        for row in cur.fetchall():
            data = dict(zip(cols, row))
            # Convertir decimales a float para Firebase
            if data.get('precio_referencia'): data['precio_referencia'] = float(data['precio_referencia'])
            db.collection("productos").document(str(data['id'])).set(data)
        print("✅ Productos migrados.")

        # II. Migrar Inversionistas
        cur.execute("SELECT * FROM inversionistas")
        cols = [desc[0] for desc in cur.description]
        for row in cur.fetchall():
            data = dict(zip(cols, row))
            db.collection("inversionistas").document(str(data['id'])).set(data)
        print("✅ Inversionistas migrados.")

        # III. Migrar Pedidos
        cur.execute("SELECT * FROM pedidos")
        cols = [desc[0] for desc in cur.description]
        for row in cur.fetchall():
            data = dict(zip(cols, row))
            # Limpieza de tipos de datos
            for k, v in data.items():
                if hasattr(v, 'to_eng_string'): data[k] = float(v) # Decimals
            db.collection("pedidos").document(str(data['id'])).set(data)
        print("✅ Pedidos migrados.")

        cur.close()
        conn.close()
    except Exception as e:
        print(f"❌ Error en migración SQL: {e}")

if __name__ == "__main__":
    if not os.path.exists(SERVICE_ACCOUNT_PATH):
        print(f"❌ Error: No se encuentra {SERVICE_ACCOUNT_PATH}. Por favor descárgalo de la consola de Firebase.")
    elif not RENDER_DB_URL:
        print("❌ Error: RENDER_DB_URL no configurada en .env")
    else:
        migrate()
