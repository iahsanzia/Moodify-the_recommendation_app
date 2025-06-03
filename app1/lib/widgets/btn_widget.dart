import 'package:flutter/material.dart';
import 'package:app1/utils/color.dart';

class ButtonWidget extends StatelessWidget {
  final String btnText;
  final VoidCallback onClick;

  // Constructor with required parameters
  ButtonWidget({required this.btnText, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [orangeColors, orangeLightColors],
            end: Alignment.centerLeft,
            begin: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(100)),
        ),
        alignment: Alignment.center,
        child: Text(
          btnText,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
