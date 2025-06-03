import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app1/pages/home_page.dart'; // Import the HomePage
import 'package:app1/pages/regi_page.dart';
import 'package:app1/widgets/btn_widget.dart';
import 'package:app1/widgets/herder_container.dart';
import 'package:app1/auth/api_service.dart'; // Assuming API service is present

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.orange,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    setState(() => isLoading = true);

    String email = emailController.text;
    String password = passwordController.text;

    try {
      final response = await ApiService.login(email, password);
      setState(() => isLoading = false);

      if (response.containsKey('jwtToken')) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login successful!')));
        // Redirect to HomePage with email passed as argument
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(email: email)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${response['error']}')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(bottom: 30),
            child: Column(
              children: <Widget>[
                HeaderContainer("Login"),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    children: <Widget>[
                      _textInput(
                        controller: emailController,
                        hint: "Email",
                        icon: Icons.email,
                      ),
                      _textInput(
                        controller: passwordController,
                        hint: "Password",
                        icon: Icons.vpn_key,
                        obscureText: true,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child:
                            isLoading
                                ? CircularProgressIndicator()
                                : ButtonWidget(
                                  btnText: "LOGIN",
                                  onClick: loginUser,
                                ),
                      ),
                      SizedBox(height: 20),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: Colors.black),
                            ),
                            TextSpan(
                              text: "Register",
                              style: TextStyle(color: Colors.orange),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RegPage(),
                                        ),
                                      );
                                    },
                            ),
                          ],
                        ),
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

  Widget _textInput({controller, hint, icon, bool obscureText = false}) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
      ),
      padding: EdgeInsets.only(left: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}
