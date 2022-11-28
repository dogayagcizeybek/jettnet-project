import 'package:flutter/material.dart';

class MyRaisedButton extends StatelessWidget {
  final Widget child;
  final Color color;
  final VoidCallback onPressed;

  const MyRaisedButton(
      {Key? key,
      required this.color,
      required this.onPressed,
      required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 300,
      // ignore: deprecated_member_use
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)))),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed))
                return color.withOpacity(0.5);
              else if (states.contains(MaterialState.disabled))
                return color.withOpacity(0.8);
              return color; // Use the component's default.
            },
          ),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
