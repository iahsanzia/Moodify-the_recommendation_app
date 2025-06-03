import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app1/pages/login_page.dart';
import 'package:app1/widgets/btn_widget.dart';
import 'package:app1/widgets/herder_container.dart';
import 'package:app1/auth/api_service.dart';
import 'package:app1/pages/preferenceChartScreen.dart'; // Import the preference page

class RegPage extends StatefulWidget {
  @override
  _RegPageState createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {
  TextEditingController fullnameController = TextEditingController();
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
    fullnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    setState(() => isLoading = true);

    String fullname = fullnameController.text;
    String email = emailController.text;
    String password = passwordController.text;

    try {
      final response = await ApiService.signup(fullname, email, password);

      setState(() => isLoading = false);

      if (response['message'] == 'Signup successfully') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registration successful! Please fill your preferences.',
            ),
          ),
        );
        // Pass the email to PreferenceChartScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    PreferenceChartScreen(email: email), // Pass email here
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Registration failed')),
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
                HeaderContainer("Register"),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    children: <Widget>[
                      _textInput(
                        controller: fullnameController,
                        hint: "Fullname",
                        icon: Icons.person,
                      ),
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
                                  btnText: "REGISTER",
                                  onClick: registerUser,
                                ),
                      ),
                      SizedBox(height: 20),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Already a member? ",
                              style: TextStyle(color: Colors.black),
                            ),
                            TextSpan(
                              text: "Login",
                              style: TextStyle(color: Colors.orange),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginPage(),
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
