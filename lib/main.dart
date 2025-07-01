import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_app/app/home.dart';
import 'package:vault_app/app/on_boarding/onboarding_view.dart';
import 'package:vault_app/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthService>(
      future: _initializeAuthService(),
      builder: (context, snapshot) {
        // Mostra loading mentre inizializza
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        // Se c'è un errore
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Errore: ${snapshot.error}')),
            ),
          );
        }

        // Quando l'inizializzazione è completata
        final authService = snapshot.data!;
        return ChangeNotifierProvider<AuthService>(
          create: (_) => authService,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Vault App',
            theme: ThemeData(primarySwatch: Colors.blue),
            home: AuthStateWrapper(),
          ),
        );
      },
    );
  }

  Future<AuthService> _initializeAuthService() async {
    final authService = AuthService();
    await authService.init();
    return authService;
  }
}

class AuthStateWrapper extends StatelessWidget {
  const AuthStateWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        debugPrint(
          'AuthState changed: isAuthenticated=${authService.isAuthenticated}',
        );

        return authService.isAuthenticated
            ? HomePage()
            : OnboardingView(
              onLogin: (success) {
                if (success) {
                  debugPrint('Login callback chiamato con successo');
                }
              },
            );
      },
    );
  }
}
