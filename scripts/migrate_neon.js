const admin = require('firebase-admin');
const { Pool } = require('pg');
require('dotenv').config();

// 1. Configuración de variables
const RENDER_DB_URL = process.env.RENDER_DB_URL;
const SERVICE_ACCOUNT_PATH = './service-account.json';

// 2. Mapeo de Usuarios Legacy
const LEGACY_USERS = [
    { username: "jose", password: "jose123", role: "operador" },
    { username: "alicia", password: "demo123", role: "comprador" },
    { username: "ssamira", password: "demo123", role: "inversionista" },
    { username: "admin", password: "admin123", role: "admin" }
];

async function migrate() {
    try {
        // Inicializar Firebase
        const serviceAccount = require(SERVICE_ACCOUNT_PATH);
        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });
        const db = admin.firestore();
        const auth = admin.auth();

        console.log("🚀 Iniciando migración de Neon Tech a Firebase...");

        // A. Crear Usuarios Legacy en Firebase Auth
        for (const userData of LEGACY_USERS) {
            const email = `${userData.username}@comercializadoraaly.com`;
            try {
                let user;
                try {
                    user = await auth.getUserByEmail(email);
                    console.log(`ℹ️ Usuario ${email} ya existe.`);
                } catch (e) {
                    user = await auth.createUser({
                        email: email,
                        password: userData.password,
                        displayName: userData.username
                    });
                    console.log(`✅ Usuario creado: ${email}`);
                }

                // Guardar rol en Firestore
                await db.collection("users").doc(user.uid).set({
                    username: userData.username,
                    email: email,
                    role: userData.role,
                    migrated: true,
                    created_at: admin.firestore.FieldValue.serverTimestamp()
                });
            } catch (e) {
                console.error(`❌ Error con usuario ${email}:`, e.message);
            }
        }

        // B. Migrar Datos de Tablas SQL
        const pool = new Pool({
            connectionString: RENDER_DB_URL,
            ssl: { rejectUnauthorized: false }
        });

        const client = await pool.connect();
        console.log("🔗 Conexión a Neon Tech establecida.");

        // I. Migrar Productos
        const resProd = await client.query('SELECT * FROM productos');
        console.log(`📦 Migrando ${resProd.rows.length} productos...`);
        for (const row of resProd.rows) {
            const data = { ...row };
            if (data.precio_referencia) data.precio_referencia = parseFloat(data.precio_referencia);
            await db.collection("productos").doc(row.id.toString()).set(data);
        }

        // II. Migrar Inversionistas
        const resInv = await client.query('SELECT * FROM inversionistas');
        console.log(`👥 Migrando ${resInv.rows.length} inversionistas...`);
        for (const row of resInv.rows) {
            const data = { ...row };
            if (data.total_invertido) data.total_invertido = parseFloat(data.total_invertido);
            if (data.total_retornado) data.total_retornado = parseFloat(data.total_retornado);
            await db.collection("inversionistas").doc(row.id.toString()).set(data);
        }

        // III. Migrar Pedidos
        const resPed = await client.query('SELECT * FROM pedidos');
        console.log(`📜 Migrando ${resPed.rows.length} pedidos...`);
        for (const row of resPed.rows) {
            const data = { ...row };
            // Convertir campos numéricos de Postgres (numeric/decimal)
            Object.keys(data).forEach(key => {
                if (data[key] instanceof Object && data[key].constructor.name === 'Number') {
                  // Already number
                } else if (!isNaN(parseFloat(data[key])) && isFinite(data[key]) && typeof data[key] === 'string') {
                   // Possible decimal string
                   data[key] = parseFloat(data[key]);
                }
            });
            await db.collection("pedidos").doc(row.id.toString()).set(data);
        }

        client.release();
        await pool.end();
        console.log("🎉 Migración completada exitosamente.");

    } catch (error) {
        console.error("❌ Error fatal en la migración:", error);
    }
}

migrate();
