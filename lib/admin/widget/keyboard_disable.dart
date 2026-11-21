import 'package:flutter/cupertino.dart';

class KeyboardDisable extends StatelessWidget {
  final Widget? child;
  const KeyboardDisable({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: child,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }
}
