import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as fb;

import '../bloc/bloc.dart';

class TriviaControls extends StatefulWidget {
  const TriviaControls({
    Key? key,
  }) : super(key: key);

  @override
  _TriviaControlsState createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  final controller = TextEditingController();
  String? inputString;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Input a number',
          ),
          onChanged: (value) {
            inputString = value;
          },
          onSubmitted: (_) {
            dispatchConcrete();
          },
        ),
        SizedBox(height: 10.0),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                child: Text('Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                ),
                onPressed: dispatchConcrete,
              ),
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: ElevatedButton(
                child: Text('Get random trivia'),
                onPressed: dispatchRandom,
              ),
            ),
          ],
        )
      ],
    );
  }

  void dispatchConcrete() {
    controller.clear();
    fb.BlocProvider.of<NumberTriviaBloc>(context).add(
      GetTriviaForConcreteNumber(inputString ?? ''),
    );
  }

  void dispatchRandom() {
    controller.clear();
    fb.BlocProvider.of<NumberTriviaBloc>(context).add(
      GetTriviaForRandomNumber(),
    );
  }
}
