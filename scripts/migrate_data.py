import json
import firebase_admin
from firebase_admin import credentials, firestore

# Configuración de Firebase
# Asegúrese de descargar el serviceAccountKey.json desde la consola de Firebase
# cred = credentials.Certificate('serviceAccountKey.json')
# firebase_admin.initialize_app(cred)
# db = firestore.client()

def migrate_products(json_file):
    with open(json_file, 'r', encoding='utf-8') as f:
        products = json.load(f)
        
    for product in products:
        # doc_ref = db.collection('productos').document(str(product['id']))
        # doc_ref.set({
        #     'nombre': product['nombre'],
        #     'descripcion': product['descripcion'],
        #     'tipoProducto': product['tipo_producto'],
        #     'precioReferencia': float(product['precio_referencia'] or 0)
        # })
        print(f"Migrando producto: {product['nombre']}")

def migrate_orders(json_file):
    with open(json_file, 'r', encoding='utf-8') as f:
        orders = json.load(f)
        
    for order in orders:
        # doc_ref = db.collection('pedidos').document(str(order['id']))
        # doc_ref.set({
        #     'fechaPedido': order['fecha_pedido'],
        #     'productoId': str(order['producto_id']),
        #     'distribuidorId': str(order['distribuidor_id']),
        #     'inversionistaId': str(order['inversionista_id']),
        #     'compradorId': str(order['comprador_id']),
        #     'cantidad': order['cantidad'],
        #     'capitalInvertido': float(order['capital_invertido']),
        #     'capitalDevuelto': float(order['capital_devuelto'] or 0),
        #     'gananciaEsperada': float(order['ganancia_esperada']),
        #     'gananciaReal': float(order['ganancia_real'] or 0),
        #     'estado': order['estado'],
        #     'notas': order['notas']
        # })
        print(f"Migrando pedido ID: {order['id']}")

if __name__ == "__main__":
    print("🚀 Iniciando migración de datos conceptual...")
    # migrate_products('productos_export.json')
    # migrate_orders('pedidos_export.json')
    print("✅ Migración simulada completada.")
