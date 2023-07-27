import 'package:flutter/material.dart';

class AreaPage extends StatelessWidget {
  AreaPage({super.key, this.area = 0.0});
  double area;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Text('The covered area is $area m²'),
            Spacer(),
            Text('The covered area is ${area * 3.28084} ft²'),
          ],
        ),
      ),
    );
  }
}
