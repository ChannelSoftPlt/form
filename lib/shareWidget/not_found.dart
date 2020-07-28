import 'package:flutter/material.dart';

class NotFound extends StatelessWidget {
  final String title, description, drawable, button;
  final bool showButton;
  final Function refresh;

  NotFound(
      {this.title,
      this.description,
      this.drawable,
      this.button,
      this.refresh,
      this.showButton});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(drawable),
          SizedBox(
            height: 20,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            description,
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(
            height: 10,
          ),
          Visibility(
            visible: showButton,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
              child: SizedBox(
                width: double.infinity,
                height: 50.0,
                child: OutlineButton(
                  borderSide: BorderSide(
                    color: Colors.orange, //Color of the border
                    style: BorderStyle.solid, //Style of the border
                    width: 0.8, //width of the border
                  ),
                  color: Colors.orangeAccent,
                  onPressed:() => refresh(),
                  child: Text(
                    button,
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
