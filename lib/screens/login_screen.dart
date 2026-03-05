import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Rive inputs
  SMIInput<bool>? isChecking;
  SMIInput<double>? numLook;
  SMIInput<bool>? isHandsUp;
  SMITrigger? trigSuccess;
  SMITrigger? trigFail;

  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailFocusNode.addListener(emailFocus);
    passwordFocusNode.addListener(passwordFocus);
  }

  @override
  void dispose() {
    emailFocusNode.removeListener(emailFocus);
    passwordFocusNode.removeListener(passwordFocus);
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void emailFocus() {
    isChecking?.change(emailFocusNode.hasFocus);
  }

  void passwordFocus() {
    isHandsUp?.change(passwordFocusNode.hasFocus);
  }

  void login() async {
    emailFocusNode.unfocus();
    passwordFocusNode.unfocus();

    // delay slightly to allow hands down animation to start
    await Future.delayed(const Duration(milliseconds: 200));

    if (passwordController.text == '123456') {
      trigSuccess?.fire();
    } else {
      trigFail?.fire();
    }
  }

  void onInit(Artboard artboard) {
    StateMachineController? controller;

    // We try looking for standard names like 'Login Machine' or 'State Machine 1'
    if (artboard.stateMachines
        .where((m) => m.name == "Login Machine")
        .isNotEmpty) {
      controller = StateMachineController.fromArtboard(
        artboard,
        "Login Machine",
      );
    } else if (artboard.stateMachines
        .where((m) => m.name == "State Machine 1")
        .isNotEmpty) {
      controller = StateMachineController.fromArtboard(
        artboard,
        "State Machine 1",
      );
    } else if (artboard.stateMachines.isNotEmpty) {
      controller = StateMachineController.fromArtboard(
        artboard,
        artboard.stateMachines.first.name,
      );
    }

    if (controller != null) {
      artboard.addController(controller);

      for (var input in controller.inputs) {
        if (input.name == 'isChecking' || input.name == 'Check') {
          isChecking = input as SMIInput<bool>;
        } else if (input.name == 'numLook' || input.name == 'Look') {
          numLook = input as SMIInput<double>;
        } else if (input.name == 'isHandsUp' || input.name == 'hands_up') {
          isHandsUp = input as SMIInput<bool>;
        } else if (input.name == 'trigSuccess' || input.name == 'success') {
          trigSuccess = input as SMITrigger;
        } else if (input.name == 'trigFail' || input.name == 'fail') {
          trigFail = input as SMITrigger;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6E2E8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Logo
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                width: 80,
                height: 80,
                alignment: Alignment.center,
                child: const Text(
                  'ra\u2022', // ra dot
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Rive + Flutter\nAnimated Guardian\nPolar Bear',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 250,
                child: RiveAnimation.asset(
                  'assets/animated_login_character.riv',
                  fit: BoxFit.contain,
                  onInit: onInit,
                ),
              ),
              // We move the container slightly up using negative margin or translation if desired,
              // but standard layout should be close enough
              Transform.translate(
                offset: const Offset(0, -10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        focusNode: emailFocusNode,
                        decoration: InputDecoration(
                          hintText: "Email",
                          filled: true,
                          fillColor: const Color(0xFFEBEBEB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        onChanged: (value) {
                          if (isChecking?.value ?? false) {
                            // Calculates numLook: 0 to 100 based on text length
                            // assuming around 30 characters maximum before turning fully
                            double lookPos =
                                value.length.toDouble() * (100 / 30);
                            if (lookPos > 100) lookPos = 100;
                            numLook?.change(lookPos);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        focusNode: passwordFocusNode,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Password",
                          filled: true,
                          fillColor: const Color(0xFFEBEBEB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF208DEF),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
