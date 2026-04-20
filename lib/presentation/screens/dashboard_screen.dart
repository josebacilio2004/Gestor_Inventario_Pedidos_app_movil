import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestor_invetarios_pedidos_app/core/theme/app_theme.dart';
import 'package:gestor_invetarios_pedidos_app/presentation/providers/auth_provider.dart';
import 'package:gestor_invetarios_pedidos_app/presentation/providers/investor_nav_provider.dart';
import 'package:gestor_invetarios_pedidos_app/presentation/providers/buyer_nav_provider.dart';
import 'package:gestor_invetarios_pedidos_app/presentation/screens/login_screen.dart';
import 'package:gestor_invetarios_pedidos_app/presentation/widgets/dashboards/admin_dashboard.dart';
import 'package:gestor_invetarios_pedidos_app/presentation/widgets/dashboards/operator_dashboard.dart';
import 'package:gestor_invetarios_pedidos_app/presentation/widgets/dashboards/buyer_dashboard.dart';
import 'package:gestor_invetarios_pedidos_app/presentation/widgets/dashboards/investor_dashboard.dart';
import 'package:gestor_invetarios_pedidos_app/data/models/usuario.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);

    if (user == null) {
      return const LoginScreen();
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      drawer: _buildRoleAwareDrawer(context, ref),
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 24,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, color: AppTheme.accentOrange),
            ),
            const SizedBox(width: 8),
            Text(
              'COMERCIALIZADORA ALY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: 1,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.accentOrange),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.textGray),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildDashboardSelector(context, user, ref),
    );
  }

  Widget _buildDashboardSelector(BuildContext context, Usuario user, WidgetRef ref) {
    final String role = user.rol.toLowerCase();
    
    // Nombres completos personalizados
    String username = user.nombre;
    if (role == 'inversionista') {
      username = 'Ssamira Xiomara Checya Peña';
    } else if (role == 'comprador') {
      username = 'Alicia Peña Granilla';
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(username, role),
              const SizedBox(height: 32),
              
              // Switch de Dashboards por Rol
              _getDashboardWidget(user, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getDashboardWidget(Usuario user, WidgetRef ref) {
    final String role = user.rol.toLowerCase();
    final profile = {'id': user.id, 'nombre': user.nombre, 'rol': user.rol};
    
    switch (role) {
      case 'admin':
        return AdminDashboard(profile: profile);
      case 'operador':
        return OperatorDashboard(profile: profile);
      case 'comprador':
        return BuyerDashboard(profile: profile);
      case 'inversionista':
        return InvestorDashboard(profile: profile);
      default:
        return OperatorDashboard(profile: profile);
    }
  }

  Widget _buildHeader(String name, String role) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppTheme.accentOrange.withOpacity(0.2)),
              ),
              child: Text(
                role.toUpperCase(),
                style: const TextStyle(color: AppTheme.accentOrange, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const Text(
          'Sistema de Gestión Industrial Sincronizado.',
          style: TextStyle(color: AppTheme.textGray, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildRoleAwareDrawer(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final String role = user?.rol.toLowerCase() ?? '';

    if (role == 'inversionista') {
      return _buildInvestorDrawer(context, ref);
    } else if (role == 'comprador') {
      return _buildBuyerDrawer(context, ref);
    }

    return _buildGenericDrawer(context, ref);
  }

  Widget _buildInvestorDrawer(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppTheme.primaryDark,
      child: Column(
        children: [
          _drawerHeader('Ssamira Xiomara Checya Peña', 'Inversionista Principal'),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _investorDrawerItem(ref, InvestorSection.inventoryManager, 'Gestor de Inventario', Icons.storefront_outlined),
                _investorDrawerItem(ref, InvestorSection.dashboard, 'Mi Dashboard', Icons.home_outlined),
                _investorDrawerItem(ref, InvestorSection.products, 'Productos', Icons.inventory_2_outlined),
                _investorDrawerItem(ref, InvestorSection.distributors, 'Distribuidores', Icons.factory_outlined),
                _investorDrawerItem(ref, InvestorSection.orders, 'Mis Pedidos', Icons.assignment_outlined),
                _investorDrawerItem(ref, InvestorSection.buyers, 'Compradores', Icons.shopping_cart_outlined),
                const Divider(color: Colors.white10, height: 40),
                _logoutItem(context, ref),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerDrawer(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppTheme.primaryDark,
      child: Column(
        children: [
          _drawerHeader('Alicia Peña Granilla', 'Comprador Principal'),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buyerDrawerItem(ref, BuyerSection.inventoryManager, 'Gestor de Inventario', Icons.storefront_outlined),
                _buyerDrawerItem(ref, BuyerSection.dashboard, 'Mi Dashboard', Icons.home_outlined),
                _buyerDrawerItem(ref, BuyerSection.orders, 'Mis Pedidos', Icons.assignment_outlined),
                _buyerDrawerItem(ref, BuyerSection.invoicing, 'Facturaciones', Icons.description_outlined),
                _buyerDrawerItem(ref, BuyerSection.wholesaleSales, 'Ventas Mayoristas', Icons.inventory_outlined),
                const Divider(color: Colors.white10, height: 40),
                _logoutItem(context, ref),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericDrawer(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppTheme.primaryDark,
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.surfaceDark),
            child: Center(
              child: Text(
                'ALY INDUSTRIAL',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: AppTheme.accentOrange),
              ),
            ),
          ),
          _logoutItem(context, ref),
        ],
      ),
    );
  }

  Widget _drawerHeader(String name, String subtitle) {
    return UserAccountsDrawerHeader(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        image: DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1550751827-4bd374c3f58b?auto=format&fit=crop&q=80&w=300'),
          fit: BoxFit.cover,
          opacity: 0.1,
        ),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white10,
        child: Image.asset('assets/logo.png', height: 40),
      ),
      accountName: Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
      accountEmail: Text(subtitle, style: const TextStyle(color: AppTheme.textGray, fontSize: 10)),
    );
  }

  Widget _investorDrawerItem(WidgetRef ref, InvestorSection section, String label, IconData icon) {
    final isSelected = ref.watch(investorNavProvider) == section;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.accentOrange : AppTheme.textGray),
      title: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppTheme.textGray, fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal)),
      selected: isSelected,
      onTap: () => ref.read(investorNavProvider.notifier).state = section,
    );
  }

  Widget _buyerDrawerItem(WidgetRef ref, BuyerSection section, String label, IconData icon) {
    final isSelected = ref.watch(buyerNavProvider) == section;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.accentOrange : AppTheme.textGray),
      title: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppTheme.textGray, fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal)),
      selected: isSelected,
      onTap: () {
        ref.read(buyerNavProvider.notifier).state = section;
      },
    );
  }

  Widget _logoutItem(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
      title: const Text('Salir', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
      onTap: () {
        ref.read(authServiceProvider).signOut();
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginScreen()), (route) => false);
      },
    );
  }
}
