import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture_tdd/features/number_trivia/presentation/bloc/bloc.dart';
import 'package:clean_architecture_tdd/features/number_trivia/presentation/widgets/trivia_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as fb;
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/helpers.dart';

class _MockNumberTriviaBloc
    extends MockBloc<NumberTriviaEvent, NumberTriviaState>
    implements NumberTriviaBloc {}

void main() {
  group(TriviaControls, () {
    late _MockNumberTriviaBloc bloc;

    setUp(() {
      bloc = _MockNumberTriviaBloc();
    });

    Future<void> pumpTriviaControls(WidgetTester tester) {
      return tester.pumpApp(
        fb.BlocProvider<NumberTriviaBloc>.value(
          value: bloc,
          child: const TriviaControls(),
        ),
      );
    }

    group('dispose', () {
      testWidgets('disposes the TextEditingController when unmounted', (
        tester,
      ) async {
        await pumpTriviaControls(tester);

        final controller = tester
            .state<TriviaControlsState>(find.byType(TriviaControls))
            .controller;

        await tester.pumpWidget(const SizedBox.shrink());

        expect(() => controller.addListener(() {}), throwsFlutterError);
      });
    });
  });
}
