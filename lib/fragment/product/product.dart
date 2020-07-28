import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductPage extends StatelessWidget {
  final int itemPerPage = 8, currentPage = 1;
  final String query, startDate, endDate;

  ProductPage({this.query, this.startDate, this.endDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('drawable/coming_soon.png'),
            SizedBox(height: 10,),
            Text('Urg....We are still working on it..hold on!',
                textAlign: TextAlign.center,
                style: GoogleFonts.cantoraOne(
                  fontSize: 16
                )),
          ],
        ),
      ),
    ));
  }
}
