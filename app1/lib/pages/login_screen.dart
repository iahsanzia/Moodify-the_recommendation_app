import 'package:app1/pages/signUp.dart';
import 'package:flutter/material.dart';
import 'package:app1/pages/home_page.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isRememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C003E), Color(0xFF10001C)],
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Email Id',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF7B108B),
                  borderRadius: BorderRadius.circular(10),
                ),                child: TextField(
                  controller: emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.mail, color: Colors.white70),
                    hintText: 'Enter your email id',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                    alignLabelWithHint: true,
                    isDense: true,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Password',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF7B108B),
                  borderRadius: BorderRadius.circular(10),
                ),                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.vpn_key, color: Colors.white70),
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                    alignLabelWithHint: true,
                    isDense: true,
                  ),
                ),
              ),
              SizedBox(height: 8),              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isRememberMe = !isRememberMe;
                      });
                    },
                    child: Row(
                      children: [
                        Checkbox(
                          value: isRememberMe,
                          onChanged: (value) {
                            setState(() {
                              isRememberMe = value ?? false;
                            });
                          },
                          activeColor: Colors.white,
                          checkColor: Colors.black,
                        ),
                        Text('remember me', style: TextStyle(color: Colors.white54)),
                      ],
                    ),
                  ),
                  Spacer(),
                  Text(
                    'forgot password',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Center(                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomePage(email: emailController.text),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7B108B),
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('login', style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(height: 32),
              Center(
                child: Text(
                  'Sign in using',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/facebook.png', height: 40),
                  SizedBox(width: 32),
                  Image.asset('assets/google.png', height: 40),
                ],
              ),
              SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => Signup()),
                    );
                  },
                  child: Text(
                    "dont have a account?",
                    style: TextStyle(
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                      decoration: TextDecoration.underline,
                    ),
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
