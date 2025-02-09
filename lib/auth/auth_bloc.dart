import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ARTShift/auth/auth_event.dart';
import 'package:ARTShift/auth/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthBloc() : super(AuthInitial()) {
    // Handle login dengan Google
    on<SignInWithGoogle>((event, emit) async {
      emit(AuthLoading());

      try {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          emit(AuthError("Login dibatalkan"));
          return;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        User? user = userCredential.user;

        if (user != null) {
          // Cek apakah user sudah ada di Firestore
          DocumentSnapshot userDoc =
              await _firestore.collection('users').doc(user.uid).get();

          if (!userDoc.exists) {
            // Jika user baru, arahkan ke pemilihan role
            emit(Authenticated(
              uid: user.uid,
              name: user.displayName ?? "User",
              email: user.email ?? "",
              photoUrl: user.photoURL ?? "",
              role: "",
            ));
          } else {
            // Jika user sudah terdaftar, ambil role dari Firestore
            String role = userDoc['role'] ?? "";

            emit(Authenticated(
              uid: user.uid,
              name: user.displayName ?? "User",
              email: user.email ?? "",
              photoUrl: user.photoURL ?? "",
              role: role,
            ));
          }
        }
      } catch (e) {
        emit(AuthError("Gagal login: ${e.toString()}"));
      }
    });

    // Handle logout
    on<SignOut>((event, emit) async {
      try {
        await _auth.signOut();
        await _googleSignIn.signOut();
        emit(Unauthenticated());
      } catch (e) {
        emit(AuthError("Gagal keluar: ${e.toString()}"));
      }
    });

    // Handle update role
    on<UpdateUserRole>((event, emit) async {
      if (state is Authenticated) {
        final currentState = state as Authenticated;
        String uid = currentState.uid;

        await _firestore.collection('users').doc(uid).update({
          'role': event.role,
        });

        emit(Authenticated(
          uid: uid,
          name: currentState.name,
          email: currentState.email,
          photoUrl: currentState.photoUrl,
          role: event.role,
        ));
      }
    });
  }
}
