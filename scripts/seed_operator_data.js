const admin = require('firebase-admin');
const serviceAccount = require('./service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function seed() {
  console.log("🌱 Sincronizando datos operativos (Tandas, Notas, Pedidos)...");

  // 1. Tandas (Historial y Activa)
  const tandas = [
    { name: "8 abril", status: "activa", created_at: admin.firestore.Timestamp.fromDate(new Date("2026-04-18T00:00:00Z")), stock_restante: 0, pagado: 0.0, deuda: 180.60, pedidos_count: 1 },
    { name: "Tanda Marzo 12", status: "cerrada", created_at: admin.firestore.Timestamp.fromDate(new Date("2026-03-13T00:00:00Z")), stock_restante: 0, pagado: 0.0, deuda: 541.80, pedidos_count: 2 },
    { name: "Tanda Febrero 22", status: "cerrada", created_at: admin.firestore.Timestamp.fromDate(new Date("2026-02-22T00:00:00Z")), stock_restante: 0, pagado: 531.12, deuda: 0.0, pedidos_count: 6 },
  ];

  for (const t of tandas) {
    await db.collection('tandas').doc(t.name).set(t);
  }

  // 2. Notas (Post-its)
  const notas = [
    { content: "Hoy agregué 120 picos de stock manualmente de la señora Katy", color: "#FEF3C7", created_at: admin.firestore.FieldValue.serverTimestamp() },
    { content: "Pedido urgente para Transportes Perez", color: "#FED7AA", created_at: admin.firestore.FieldValue.serverTimestamp() },
  ];

  for (const n of notas) {
    await db.collection('notas_tanda').add(n);
  }

  // 3. Pedidos Específicos Operador
  const pedidos = [
    { id: "0009", comprador: "Alicia Peña Granilla", producto: "Pico Tramontina", cantidad: 420, mo: 180.60, fecha_str: "18 abr. 2026", estado: "completado", fecha: admin.firestore.FieldValue.serverTimestamp() },
  ];

  for (const p of pedidos) {
    await db.collection('pedidos').doc(p.id).set(p);
  }

  console.log("✅ Datos operativos sincronizados exitosamente.");
}

seed().catch(console.error);
