import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../bloc/bloc.dart';

class NumberTriviaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Trivia'),
      ),
      body: buildBody(context),
    );
  }

  BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
    return BlocProvider(
      builder: (_) => sl<NumberTriviaBloc>(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                height: MediaQuery.of(context).size.height / 3,
                child: Placeholder(),
              ),
              Column(
                children: [
                  Placeholder(fallbackHeight: 40.0),
                  SizedBox(height: 10.0),
                  Row(
                    children: [
                      Expanded(
                        child: Placeholder(fallbackHeight: 30.0),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: Placeholder(fallbackHeight: 30.0),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
