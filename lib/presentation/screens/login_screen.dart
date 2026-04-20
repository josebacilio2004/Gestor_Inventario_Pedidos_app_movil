import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestor_invetarios_pedidos_app/core/theme/app_theme.dart';
import 'package:gestor_invetarios_pedidos_app/presentation/providers/auth_provider.dart';
import 'package:gestor_invetarios_pedidos_app/presentation/screens/dashboard_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole;
  bool _isLoading = false;

  final List<Map<String, String>> _roles = [
    {'id': 'inversionista', 'label': 'INVERSIONISTA', 'subtitle': 'Gestión de Capital & ROI', 'icon': '📈'},
    {'id': 'comprador', 'label': 'COMPRADOR', 'subtitle': 'Facturación & Abonos', 'icon': '🛒'},
    {'id': 'operador', 'label': 'OPERADOR', 'subtitle': 'Logística & Distribución', 'icon': '🏭'},
    {'id': 'admin', 'label': 'ADMIN', 'subtitle': 'Control Total del Sistema', 'icon': '🛡️'},
  ];

  Future<void> _handleLogin() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un rol de acceso.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final authService = ref.read(authServiceProvider);
    final identifier = _idController.text.trim();
    
    // El backend espera el nombre de la colección en plural para la ruta
    // Roles: inversionista -> inversionistas, comprador -> compradores, operador -> operadores
    String apiRole = _selectedRole!;
    if (apiRole == 'inversionista') apiRole = 'inversionistas';
    if (apiRole == 'comprador') apiRole = 'compradores';
    if (apiRole == 'operador') apiRole = 'operadores';

    final user = await authService.signIn(identifier, _passwordController.text.trim(), apiRole, originalRole: _selectedRole!);
    
    if (user != null) {
      // Actualizar el estado global
      ref.read(authStateProvider.notifier).state = user;
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenciales inválidas para el rol seleccionado.')),
        );
      }
    }
    
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppTheme.primaryDark,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildTopBranding(),
              if (_selectedRole == null) _buildRoleSelection() else _buildLoginForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBranding() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
        border: Border(bottom: BorderSide(color: AppTheme.accentOrange.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/logo.png',
            height: 80,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, size: 60, color: AppTheme.accentOrange),
          ),
          const SizedBox(height: 24),
          const Text(
            'COMERCIALIZADORA ALY',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: 2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'PORTAL DE GESTIÓN SEGURA',
            style: TextStyle(color: AppTheme.textGray, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SELECCIONA TU ROL DE ACCESO',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppTheme.textGray),
          ),
          const SizedBox(height: 24),
          ..._roles.map((role) => _roleCard(role)).toList(),
        ],
      ),
    );
  }

  Widget _roleCard(Map<String, String> role) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => setState(() => _selectedRole = role['id']),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(role['icon']!, style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(role['label']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    Text(role['subtitle']!, style: const TextStyle(fontSize: 11, color: AppTheme.textGray)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textGray),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _selectedRole = null),
                icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.accentOrange),
              ),
              const Text(
                'RETORNAR',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppTheme.accentOrange),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'AUTENTICACIÓN: ${_selectedRole!.toUpperCase()}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _idController,
            decoration: const InputDecoration(
              labelText: 'IDENTIFICADOR DE USUARIO',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'CLAVE DE SEGURIDAD',
              prefixIcon: Icon(Icons.lock_outline_rounded),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Text('AUTENTICAR ACCESO'),
            ),
          ),
        ],
      ),
    );
  }
}
