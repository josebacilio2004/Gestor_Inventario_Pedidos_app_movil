const admin = require('firebase-admin');
const serviceAccount = require('./service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function seed() {
  console.log("🌱 Iniciando siembra de información neta (Sincronización Web-Móvil)...");

  // 1. Facturas de Alicia (CORPORACION DAYLUM)
  const facturas = [
    { nro: "F002-0009594", emision: "06/02/2026", vencimiento: "21/02/2026", total: 4110.27, abonado: 4110.27, banco: "Interbank", estado: "completada", distribuidor: "CORPORACION DAYLUM" },
    { nro: "F002-0009595", emision: "06/02/2026", vencimiento: "08/03/2026", total: 2622.27, abonado: 2622.27, banco: "Scotiabank", estado: "completada", distribuidor: "CORPORACION DAYLUM" },
    { nro: "F002-0009629", emision: "14/02/2026", vencimiento: "16/03/2026", total: 5655.47, abonado: 5655.47, banco: "bcp", estado: "completada", distribuidor: "CORPORACION DAYLUM" },
    { nro: "F002-0009659", emision: "24/02/2026", vencimiento: "26/03/2026", total: 4860.18, abonado: 3000.00, banco: "bcp", estado: "en abono", distribuidor: "CORPORACION DAYLUM" },
    { nro: "F002-0009688", emision: "04/03/2026", vencimiento: "03/04/2026", total: 3597.36, abonado: 0.00, banco: "bcp", estado: "vencida", distribuidor: "CORPORACION DAYLUM" },
    { nro: "F002-0009782", emision: "20/03/2026", vencimiento: "19/04/2026", total: 5955.44, abonado: 0.00, banco: "bcp", estado: "pendiente", distribuidor: "CORPORACION DAYLUM" },
  ];

  for (const f of facturas) {
    await db.collection('facturas').doc(f.nro).set(f);
  }
  console.log("✅ Facturas sembradas.");

  // 2. Stock Disponible (Ventas Mayoristas)
  const stock = [
    { nombre: "Pico Tramontina", stock: 1722, tipo: "Pico" },
    { nombre: "Zapapico Tramontina", stock: 1092, tipo: "Zapapico" },
    { nombre: "Pico Bellota", stock: 0, tipo: "Pico" },
    { nombre: "Zapapico Bellota", stock: 0, tipo: "Zapapico" },
  ];

  for (const s of stock) {
    await db.collection('productos').doc(s.nombre).set(s, { merge: true });
  }
  console.log("✅ Stock actualizado.");

  // 3. Pedidos a Mi Cargo (Alicia)
  const pedidos = [
    { id: "20", fecha_str: "8 de abril de 2026", producto: "Pico Titan", inversionista: "Ssamira Xiomara Checya Peña", capital: 3825.00, devuelto: 0.00, ganancia_estimada: 300.00, ganancia_cobrada: 0.00, estado: "pendiente" },
    { id: "11", fecha_str: "4 de marzo de 2026", producto: "Pico Vector", inversionista: "Ssamira Xiomara Checya Peña", capital: 2116.00, devuelto: 2116.00, ganancia_estimada: 180.00, ganancia_cobrada: 180.00, estado: "completado" },
  ];

  for (const p of pedidos) {
    await db.collection('pedidos').doc(p.id).set(p);
  }
  console.log("✅ Pedidos sincronizados.");

  console.log("🎉 Fin de la sincronización de información neta.");
}

seed().catch(console.error);
