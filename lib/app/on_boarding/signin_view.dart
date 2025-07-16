// ignore_for_file: deprecated_member_use

import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide LinearGradient hide Image;
import 'package:vault_app/app/theme.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:vault_app/env.dart';
import 'package:vault_app/services/auth_service.dart';

class SigninView extends StatefulWidget {
  const SigninView({super.key, this.closeModal, this.onLogin});

  final Function? closeModal;
  final Function(bool)? onLogin;

  @override
  State<SigninView> createState() => _SigninViewState();
}

class _SigninViewState extends State<SigninView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final Dio _dio = Dio();

  late SMITrigger _successAnim;
  late SMITrigger _errorAnim;
  late SMITrigger _confettiAnim;

  // ignore: prefer_final_fields
  bool _isLoading = false;

  // serve per accedere alle cose che scrivo all'interno dei due campi input
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onCheckRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      "State Machine 1",
    );
    artboard.addController(controller!);
    _successAnim = controller.findInput<bool>("Check") as SMITrigger;
    _errorAnim = controller.findInput<bool>("Error") as SMITrigger;
  }

  void _onConfettiRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      "State Machine 1",
    );
    artboard.addController(controller!);
    _confettiAnim =
        controller.findInput<bool>("Trigger explosion") as SMITrigger;
  }

  void login() async {
    // TODO - delay per far inizializzare i componenti ( non funziona )
    await Future.delayed(const Duration(milliseconds: 100));

    setState(() {
      _isLoading = true;
    });

    // String email = _emailController.text.trim();
    // String password = _passwordController.text.trim();

    String email = 'gianfranco';
    String password = 'password';

    bool isEmailValid = email.isNotEmpty;
    bool isPassValid = password.isNotEmpty;

    if (!isEmailValid || !isPassValid) {
      _errorAnim.fire();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final response = await _dio.post(
        'http://10.0.2.2:3000/auth/signin',
        data: {'username': email, 'password': password},
        options: Options(
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      debugPrint('STATUS CODE: ');
      debugPrint((response.statusCode).toString());
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Login successful!');

        final responseData = response.data;
        final accessToken = responseData['access_token'] as String;
        final refreshToken = responseData['refresh_token'] as String;

        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.saveTokens(accessToken, refreshToken);

        _successAnim.fire();

        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _confettiAnim.fire();

          _emailController.text = '';
          _passwordController.text = '';

          widget.closeModal!();

          if (widget.onLogin != null) {
            widget.onLogin!(true);
          }
        }
      } else if (response.statusCode == 403) {
        debugPrint('Credenziali non valide: accesso negato');
        _errorAnim.fire();
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenziali non valide. Riprova.'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (response.statusCode == 401) {
        debugPrint('Non autorizzato: credenziali mancanti o scadute');
        _errorAnim.fire();
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        debugPrint('Login fallito: Status code ${response.statusCode}');
        _errorAnim.fire();
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Eccezione durante il login: $e');
      _errorAnim.fire();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (e is DioException) {
        if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
          debugPrint('Errore del server: ${e.response?.statusCode}');
        } else {
          debugPrint('Errore di rete: ${e.message}');
        }
      } else {
        debugPrint('Errore sconosciuto: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Stack(
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0.8), Colors.white10],
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(29),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: RiveAppTheme.shadow.withOpacity(0.3),
                          offset: const Offset(0, 3),
                          blurRadius: 5,
                        ),
                        BoxShadow(
                          color: RiveAppTheme.shadow.withOpacity(0.3),
                          offset: const Offset(0, 30),
                          blurRadius: 30,
                        ),
                      ],
                      color: CupertinoColors.secondarySystemBackground,
                      backgroundBlendMode: BlendMode.luminosity,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Sign in",
                          style: TextStyle(fontFamily: "Poppins", fontSize: 34),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Acces to 500 GB of free space where you can store all your personal datas.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Email",
                            style: TextStyle(
                              color: CupertinoColors.secondaryLabel,
                              fontFamily: 'Inter',
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: authInputStyle('icon_email'),
                          controller: _emailController,
                        ),

                        SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Password",
                            style: TextStyle(
                              color: CupertinoColors.secondaryLabel,
                              fontFamily: 'Inter',
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          obscureText: true,
                          decoration: authInputStyle('icon_lock'),
                          controller: _passwordController,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF77D8E).withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: CupertinoButton(
                            color: const Color(0xFFF77D8E),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.arrow_forward_rounded),
                                SizedBox(width: 4),
                                Text(
                                  "Sign In",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              if (!_isLoading) login();
                            },
                          ),
                        ),
                        const SizedBox(height: 27),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 13.0),
                          child: Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  "OR",
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.3),
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                        ),
                        // const Text(
                        //   "Sign Up with Email, Apple or Google",
                        //   style: TextStyle(
                        //     color: CupertinoColors.secondaryLabel,
                        //     fontFamily: 'Inter',
                        //     fontSize: 15,
                        //   ),
                        // ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'assets/samples/ui/rive_app/images/logo_email.png',
                            ),
                            Image.asset(
                              'assets/samples/ui/rive_app/images/logo_apple.png',
                            ),
                            Image.asset(
                              'assets/samples/ui/rive_app/images/logo_google.png',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: true,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_isLoading)
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: RiveAnimation.asset(
                              'assets/samples/ui/rive_app/rive/check.riv',
                              onInit: _onCheckRiveInit,
                            ),
                          ),
                        Positioned.fill(
                          child: SizedBox(
                            width: 500,
                            height: 500,
                            child: Transform.scale(
                              scale: 3,
                              child: RiveAnimation.asset(
                                'assets/samples/ui/rive_app/rive/confetti.riv',
                                onInit: _onConfettiRiveInit,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // bottone chiusura modal
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(36 / 2),
                      minSize: 36,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(36 / 2),
                          boxShadow: [
                            BoxShadow(
                              color: RiveAppTheme.shadow.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.close, color: Colors.black),
                      ),
                      onPressed: () {
                        widget.closeModal!();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration authInputStyle(String iconName) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
    ),
    prefixIcon: Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Image.asset('assets/samples/ui/rive_app/images/$iconName.png'),
    ),
  );
}
