import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthState {
  final User? user;
  const AuthState(this.user);
}

class AuthCubit extends Cubit<AuthState> {
  late final StreamSubscription _sub;

  AuthCubit() : super(const AuthState(null)) {
    _sub = FirebaseAuth.instance.authStateChanges().listen(
      (u) => emit(AuthState(u)),
    );
  }

  Future<void> signInWithGoogle() async {
    final acc = await GoogleSignIn().signIn();
    if (acc == null) return;
    final auth = await acc.authentication;
    final cred = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(cred);
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
