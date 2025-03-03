import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_good_slide_puzzle/layout/responsive_layout_builder.dart';
import 'package:very_good_slide_puzzle/models/tile.dart';
import 'package:very_good_slide_puzzle/puzzle/bloc/puzzle_bloc.dart';
import 'package:very_good_slide_puzzle/puzzle/widgets/puzzle_keyboard_handler.dart';
import 'package:very_good_slide_puzzle/simple/simple_theme.dart';
import 'package:very_good_slide_puzzle/colors/colors.dart';

/// {@template puzzle_page}
/// The root page of the puzzle UI.
///
/// Builds the puzzle based on the current [PuzzleTheme]
/// from [ThemeBloc].
/// {@endtemplate}
class PuzzlePage extends StatelessWidget {
  /// {@macro puzzle_page}
  const PuzzlePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const PuzzleView();
  }
}

/// {@template puzzle_view}
/// Displays the content for the [PuzzlePage].
/// {@endtemplate}
class PuzzleView extends StatelessWidget {
  /// {@macro puzzle_view}
  const PuzzleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Color Slider Puzzle')
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
            PuzzleBloc(3)
              ..add(
                const PuzzleInitialized(
                  shufflePuzzle: false,
                ),
              ),
          ),
        ],
        child: const _Puzzle(
          key: Key('puzzle_view_puzzle'),
        ),
      ),
    );
  }
}

class _Puzzle extends StatelessWidget {
  const _Puzzle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  children: [
                    PuzzleSections(),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

class PuzzleMenuItem extends StatefulWidget {
  @override
  PuzzleMenuItemState createState() => PuzzleMenuItemState();
}

class PuzzleMenuItemState extends State<PuzzleMenuItem> {
  final isSelected = <bool>[true, false];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ToggleButtons(
            textStyle: const TextStyle(fontSize: 18),
            selectedColor: PuzzleColors.white,
            fillColor: PuzzleColors.blue50,
            borderRadius: BorderRadius.circular(24),
            isSelected: isSelected,
            onPressed: (int index) {
              setState(() {
                isSelected[index] = true;
                isSelected[(index + 1) % 2] = false;
              });
              context.read<PuzzleBloc>().add(
                  HintTapped(index == 0 ? true : false)
              );
            },
            children: [
              Padding(
                  padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                  child: Text('Hints')
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                  child: Text('No hints')
              )
            ]
        )
      ],
    );
  }
}

/// {@template puzzle_sections}
/// Displays start and end sections of the puzzle.
/// {@endtemplate}
class PuzzleSections extends StatelessWidget {
  /// {@macro puzzle_sections}
  const PuzzleSections({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = SimpleTheme();
    return ResponsiveLayoutBuilder(
      small: (context, child) =>
          Column(
            children: [
              theme.layoutDelegate.startSectionBuilder(),
              PuzzleBoard(),
              theme.layoutDelegate.endSectionBuilder()
            ],
          ),
      medium: (context, child) =>
          Column(
            children: [
              theme.layoutDelegate.startSectionBuilder(),
              PuzzleBoard(),
              theme.layoutDelegate.endSectionBuilder()
            ],
          ),
      large: (context, child) =>
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: theme.layoutDelegate.startSectionBuilder()
              ),
              PuzzleBoard(),
              Padding(padding: EdgeInsets.all(50))
            ],
          ),
    );
  }
}

/// {@template puzzle_board}
/// Displays the board of the puzzle.
/// {@endtemplate}
@visibleForTesting
class PuzzleBoard extends StatelessWidget {
  /// {@macro puzzle_board}
  const PuzzleBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const theme = SimpleTheme();
    final puzzle = context.select((PuzzleBloc bloc) => bloc.state.puzzle);

    final size = puzzle.getDimension();
    if (size == 0) return const CircularProgressIndicator();

    return PuzzleKeyboardHandler(
        child: theme.layoutDelegate.boardBuilder(
          size,
          puzzle.tiles
              .map(
                (tile) =>
                _PuzzleTile(
                  key: Key('puzzle_tile_${tile.value.toString()}'),
                  tile: tile,
                ),
          ).toList(),
        )
    );
  }
}

class _PuzzleTile extends StatelessWidget {
  const _PuzzleTile({
    Key? key,
    required this.tile,
  }) : super(key: key);

  /// The tile to be displayed.
  final Tile tile;

  @override
  Widget build(BuildContext context) {
    const theme = SimpleTheme();
    final state = context.select((PuzzleBloc bloc) => bloc.state);

    return tile.isWhitespace
        ? theme.layoutDelegate.whitespaceTileBuilder()
        : theme.layoutDelegate.tileBuilder(tile, state);
  }
}
