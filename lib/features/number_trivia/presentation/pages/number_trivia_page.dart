import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as fb;

import '../../../../injection_container.dart';
import '../bloc/bloc.dart';
import '../widgets/message_display.dart';
import '../widgets/widgets.dart';

class NumberTriviaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Trivia'),
      ),
      body: SingleChildScrollView(
        child: buildBody(context),
      ),
    );
  }

  fb.BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
    return fb.BlocProvider(
      create: (_) => sl<NumberTriviaBloc>(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              SizedBox(height: 10.0),
              fb.BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                builder: (context, state) {
                  if (state is Empty) {
                    return MessageDisplay(
                      message: 'Start searching...',
                    );
                  } else if (state is Loading) {
                    return LoadingWidget();
                  } else if (state is Loaded) {
                    return TriviaDisplay(
                      numberTrivia: state.trivia,
                    );
                  } else if (state is Error) {
                    return MessageDisplay(
                      message: state.message,
                    );
                  }
                  return MessageDisplay(
                    message: 'An error has occurred.',
                  );
                },
              ),
              SizedBox(height: 20.0),
              TriviaControls(),
            ],
          ),
        ),
      ),
    );
  }
}
