import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import 'home_page.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (prev, next) => prev.user != next.user,
      listener: (context, state) {
        // Begitu user terautentikasi, pindah ke Home
        if (state.user != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      },
      child: Scaffold(
        body: Center(
          child: FilledButton.icon(
            icon: const Icon(Icons.login),
            label: const Text('Continue with Google'),
            onPressed: () => context.read<AuthCubit>().signInWithGoogle(),
          ),
        ),
      ),
    );
  }
}
