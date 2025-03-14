import 'package:bank_app/home.dart';
import 'package:bank_app/service/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return auth.currentUser;
  }
  signInWithGoogle(BuildContext context) async {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  
  await googleSignIn.signOut(); // Sign out to force account selection

  final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
  
  if (googleSignInAccount == null) {
    // User canceled sign-in
    return;
  }

  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken);

  UserCredential result = await FirebaseAuth.instance.signInWithCredential(credential);

  User? userDetails = result.user;
  if (userDetails != null) {
    Map<String, dynamic> userInfoMap = {
      "email": userDetails.email,
      "name": userDetails.displayName,
      "imgUrl": userDetails.photoURL,
      "id": userDetails.uid
    };
    await DatabaseMethods().addUser(userDetails.uid, userInfoMap);
    
    Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context, MaterialPageRoute(builder: (context) => Home()));
  }
}



  // signInWithGoogle(BuildContext context) async {
  //   final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  //   final GoogleSignIn googleSignIn = GoogleSignIn();

  //   final GoogleSignInAccount? googleSignInAccount =
  //       await googleSignIn.signIn();

  //   final GoogleSignInAuthentication? googleSignInAuthentication =
  //       await googleSignInAccount?.authentication;

  //   final AuthCredential credential = GoogleAuthProvider.credential(
  //       idToken: googleSignInAuthentication?.idToken,
  //       accessToken: googleSignInAuthentication?.accessToken);

  //   UserCredential result = await firebaseAuth.signInWithCredential(credential);

  //   User? userDetails = result.user;

  //   Map<String, dynamic> userInfoMap = {
  //     "email": userDetails!.email,
  //     "name": userDetails.displayName,
  //     "imgUrl": userDetails.photoURL,
  //     "id": userDetails.uid
  //   };
  //   await DatabaseMethods()
  //       .addUser(userDetails.uid, userInfoMap)
  //       .then((value) {
  //     Navigator.push(
  //         // ignore: use_build_context_synchronously
  //         context, MaterialPageRoute(builder: (context) => Home()));
  //   });
  //   }

  Future<User> signInWithApple({List<Scope> scopes = const []}) async {
    final result = await TheAppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)]);
    switch (result.status) {
      case AuthorizationStatus.authorized:
        // ignore: non_constant_identifier_names
        final AppleIdCredential = result.credential!;
        final oAuthCredential = OAuthProvider('apple.com');
        final credential = oAuthCredential.credential(
            idToken: String.fromCharCodes(AppleIdCredential.identityToken!));
        // ignore: non_constant_identifier_names
        final UserCredential = await auth.signInWithCredential(credential);
        final firebaseUser = UserCredential.user!;
        if (scopes.contains(Scope.fullName)) {
          final fullName = AppleIdCredential.fullName;
          if (fullName != null &&
              fullName.givenName != null &&
              fullName.familyName != null) {
            final displayName = '${fullName.givenName}${fullName.familyName}';
            await firebaseUser.updateDisplayName(displayName);
          }
        }
        return firebaseUser;
      case AuthorizationStatus.error:
        throw PlatformException(
            code: 'ERROR_AUTHORIZATION_DENIED',
            message: result.error.toString());

      case AuthorizationStatus.cancelled:
        throw PlatformException(
            code: 'ERROR_ABORTED_BY_USER', message: 'Sign in aborted by user');
      }
  }
}