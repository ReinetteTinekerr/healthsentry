import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_sentry/app/core/firebase/firebase_auth_provider.dart';
import 'package:health_sentry/app/core/utils/validator.dart';

class SignInView extends ConsumerStatefulWidget {
  const SignInView({super.key});
  static const routeName = '/sign-in';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignInViewState();
}

class _SignInViewState extends ConsumerState<SignInView> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var buttonDisabled = false;

  @override
  void dispose() {
    emailTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Acrylic(
      child: ScaffoldPage(
        content: Center(
          child: Form(
            key: formKey,
            child: Wrap(
              direction: Axis.vertical,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 300,
                      height: 150,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 0,
                      left: 0,
                      child: SizedBox(
                        width: 300,
                        child: Icon(
                          FluentIcons.contact,
                          color: Colors.grey[130],
                          size: 100,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  width: 300,
                  child: Column(
                    children: [
                      TextFormBox(
                        controller: emailTextController,
                        keyboardType: TextInputType.emailAddress,
                        placeholder: 'Email',
                        validator: (value) {
                          if (!isValidEmail(value!)) {
                            return 'Invalid email format';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      PasswordFormBox(
                        controller: passwordTextController,
                        placeholder: 'Password',
                        validator: (value) {
                          if (!isPasswordValid(value ?? '')) {
                            return 'Invalid password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                            onPressed: buttonDisabled
                                ? null
                                : () async {
                                    final isValid =
                                        formKey.currentState?.validate();
                                    if (isValid != null && isValid) {
                                      try {
                                        setState(() {
                                          buttonDisabled = true;
                                        });
                                        final credential = await ref
                                            .read(firebaseAuthProvider)
                                            .signInWithEmailAndPassword(
                                                email: emailTextController.text,
                                                password: passwordTextController
                                                    .text);
                                      } on FirebaseAuthException catch (e) {
                                        if (e.code == 'too-many-requests') {
                                          if (mounted) {
                                            await displayInfoBar(context,
                                                builder: (context, close) {
                                              return InfoBar(
                                                title: const Text('Error'),
                                                content: Text(e.message!),
                                                action: IconButton(
                                                  icon: const Icon(
                                                      FluentIcons.clear),
                                                  onPressed: close,
                                                ),
                                                severity: InfoBarSeverity.error,
                                              );
                                            });
                                          }
                                        }
                                      }
                                      setState(() {
                                        buttonDisabled = false;
                                      });
                                    }
                                  },
                            child: const Text('Sign in')),
                      ),
                    ],
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
