import 'package:flutter/material.dart';

mixin MyMixinProducts {
  Widget buildMyTextField(
      String hintText,
      IconData prefixIcon,
      bool obscureText,
      double vertical,
      double horizontal,
      double radius,
      String hintTextStyle,
      TextEditingController controller,
      String? Function(String?)? validator,
      {Function(String)? onChanged} // İsteğe bağlı onChanged parametresi
  ) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextFormField(
        validator: validator,
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          
          contentPadding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
          prefixIcon: Icon(prefixIcon),
          hintText: hintText,
          hintStyle: TextStyle(fontFamily: hintTextStyle),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        
        
        onChanged: onChanged, // onChanged parametresini burada kullanın
      ),
    );
  }

  Widget buildMyPageContent(
      String text, double fontSize, String fontFamily) {
    return Padding(
      padding: EdgeInsets.all(2.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
          fontFamily: fontFamily,
        ),
      ),
    );
  }
}