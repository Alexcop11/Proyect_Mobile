import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rating_app/core/providers/restaurant_provider.dart';
import 'package:rating_app/core/providers/auth_provider.dart';
import 'package:rating_app/screens/restaurant_screen.dart';
import 'package:rating_app/screens/restaurant_reviews.dart';
import 'package:rating_app/screens/restaurant_manage_screen.dart';
import 'package:rating_app/widgets/NavigationScaffold.dart';

class MainRestaurantNavigation extends StatefulWidget {
  const MainRestaurantNavigation({super.key});

  @override
  State<MainRestaurantNavigation> createState() => _MainRestaurantNavigationState();
}

class _MainRestaurantNavigationState extends State<MainRestaurantNavigation> {
  int _selectedIndex = 0;
  bool _isInitialized = false;
  String? _errorMessage;
  bool _hasNetworkError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeRestaurant();
    });
  }

  Future<void> _initializeRestaurant() async {
    setState(() {
      _isInitialized = false;
      _errorMessage = null;
      _hasNetworkError = false;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final restaurantProvider = context.read<RestaurantProvider>();

      debugPrint('🔄 Inicializando navegación de restaurante...');

      // Verificar que hay email disponible
      if (authProvider.email == null) {
        debugPrint('⚠️ No hay email disponible');
        setState(() {
          _errorMessage = 'No se pudo obtener la información del usuario';
          _isInitialized = true;
          _selectedIndex = 2; // Ir a configuración
        });
        return;
      }

      // Intentar cargar el restaurante
      debugPrint('📡 Intentando cargar restaurante para: ${authProvider.email}');
      await restaurantProvider.loadOwnerRestaurant(authProvider.email!,authProvider);

      // Verificar si hubo error de red
      if (restaurantProvider.errorMessage != null && 
          restaurantProvider.errorMessage!.contains('Error de red')) {
        debugPrint('🌐 Error de red detectado');
        setState(() {
          _hasNetworkError = true;
          _errorMessage = 'No se pudo conectar con el servidor';
          _isInitialized = true;
        });
        return;
      }

      // Verificar si tiene restaurante
      final hasRestaurant = restaurantProvider.ownerRestaurant != null;
      debugPrint(hasRestaurant 
        ? '✅ Restaurante encontrado: ${restaurantProvider.ownerRestaurant!.nombre}'
        : 'ℹ️ Usuario sin restaurante registrado');

      // Si no tiene restaurante, ir a configuración
      if (!hasRestaurant) {
        setState(() {
          _selectedIndex = 2;
          _isInitialized = true;
        });
      } else {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('❌ Error en inicialización: $e');
      setState(() {
        _errorMessage = 'Error al inicializar: ${e.toString()}';
        _hasNetworkError = true;
        _isInitialized = true;
        _selectedIndex = 2; // Ir a configuración como fallback
      });
    }
  }

  void _onItemTapped(int index) {
    // Si hay error de red, mostrar mensaje y permitir ir a configuración
    if (_hasNetworkError && index != 2) {
      _showNetworkErrorDialog();
      return;
    }

    final restaurantProvider = context.read<RestaurantProvider>();
    final hasRestaurant = restaurantProvider.ownerRestaurant != null;
    
    // Si no tiene restaurante y está intentando acceder a Inicio (0) o Reseñas (1)
    if (!hasRestaurant && (index == 0 || index == 1)) {
      _showNoRestaurantDialog();
      return;
    }

    // Permitir navegación normal
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
      debugPrint('📍 Navegando a pantalla: $index');
    }
  }

  void _showNetworkErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5E5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.cloud_off,
                color: Color(0xFFFF6B6B),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Error de Conexión',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'No se pudo conectar con el servidor. Verifica:',
              style: TextStyle(fontSize: 15, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 12),
            _buildCheckItem('Tu conexión a Internet'),
            _buildCheckItem('Que el servidor esté encendido'),
            _buildCheckItem('La dirección IP del servidor (192.168.1.72:8000)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _initializeRestaurant(); // Reintentar
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF666666)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
          ),
        ],
      ),
    );
  }

  void _showNoRestaurantDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5E5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.restaurant_menu,
                color: Color(0xFFFF6B6B),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Restaurante Requerido',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Para acceder a esta sección, primero debes registrar tu restaurante en la sección de Configuración.',
          style: TextStyle(fontSize: 15, color: Color(0xFF666666)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Entendido',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 2;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Ir a Configuración'),
          ),
        ],
      ),
    );
  }

  void navigateToReviews() {
    _onItemTapped(1);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantProvider>(
      builder: (context, restaurantProvider, child) {
        // Mostrar loading mientras inicializa
        if (!_isInitialized) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFFFF6B6B),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Conectando con el servidor...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Si hay error de red, mostrar pantalla de error con opción de reintentar
        if (_hasNetworkError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE5E5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.cloud_off,
                        size: 80,
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Error de Conexión',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage ?? 'No se pudo conectar con el servidor',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _hasNetworkError = false;
                              _selectedIndex = 2;
                            });
                          },
                          icon: const Icon(Icons.settings),
                          label: const Text('Configuración'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFF6B6B),
                            side: const BorderSide(color: Color(0xFFFF6B6B)),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _initializeRestaurant,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B6B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final hasRestaurant = restaurantProvider.ownerRestaurant != null;

        return Navigationscaffold(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          appBar: null,
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              hasRestaurant
                  ? const RestaurantScreen()
                  : _buildBlockedScreen('Inicio'),
              
              hasRestaurant
                  ? const RestaurantReviews()
                  : _buildBlockedScreen('Reseñas'),
              
              const RestaurantManageScreen(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlockedScreen(String screenName) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5E5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 80,
                  color: Color(0xFFFF6B6B),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Registra tu Restaurante',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Para acceder a $screenName, primero debes registrar tu restaurante.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
                icon: const Icon(Icons.settings),
                label: const Text('Ir a Configuración'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}