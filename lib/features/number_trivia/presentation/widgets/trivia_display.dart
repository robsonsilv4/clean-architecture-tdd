import 'package:flutter/material.dart';

import '../../domain/entities/number_trivia.dart';

class TriviaDisplay extends StatelessWidget {
  final NumberTrivia numberTrivia;

  const TriviaDisplay({
    Key key,
    @required this.numberTrivia,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      child: Column(
        children: [
          Text(
            numberTrivia.number.toString(),
            style: TextStyle(
              fontSize: 50.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  numberTrivia.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
