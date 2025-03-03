import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_good_slide_puzzle/colors/colors.dart';
import 'package:very_good_slide_puzzle/layout/puzzle_layout_delegate.dart';
import 'package:very_good_slide_puzzle/layout/responsive_gap.dart';
import 'package:very_good_slide_puzzle/layout/responsive_layout_builder.dart';
import 'package:very_good_slide_puzzle/models/tile.dart';
import 'package:very_good_slide_puzzle/puzzle/bloc/puzzle_bloc.dart';
import 'package:very_good_slide_puzzle/puzzle/view/puzzle_page.dart';
import 'package:very_good_slide_puzzle/simple/simple_theme.dart';
import 'package:very_good_slide_puzzle/typography/text_styles.dart';

/// {@template simple_puzzle_layout_delegate}
/// A delegate for computing the layout of the puzzle UI
/// that uses a [SimpleTheme].
/// {@endtemplate}
class SimplePuzzleLayoutDelegate extends PuzzleLayoutDelegate {
  /// {@macro simple_puzzle_layout_delegate}
  const SimplePuzzleLayoutDelegate();

  Widget instructions() {
    return RichText(
        text: TextSpan(
            style: TextStyle(color: Colors.black),
            children: [
              TextSpan(text: "Press the "),
              TextSpan(text: "shuffle ",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: "button to start/restart game"),
            ]
        )
    );
  }

  Widget header(Widget? child) {
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: child,
          ),
          instructions(),
          Padding(
            padding: const EdgeInsets.all(5),
            child: child,
          ),
          PuzzleMenuItem(),
        ]
    );
  }

  @override
  Widget endSectionBuilder() {
    return Column(
      children: [
        const ResponsiveGap(
          small: 10,
          medium: 10,
          large: 10,
        ),
        ResponsiveLayoutBuilder(
          small: (_, child) => const SimplePuzzleShuffleButton(),
          medium: (_, child) => const SimplePuzzleShuffleButton(),
          large: (_, __) => const SizedBox(),
        )
      ],
    );
  }

  @override
  Widget startSectionBuilder() {
    return ResponsiveLayoutBuilder(
        small: (_, child) => header(child),
        medium: (_, child) => header(child),
        large: (_, child) =>
            Column(
                children: [
                  Gap(200),
                  instructions(),
                  Gap(5),
                  PuzzleMenuItem(),
                  Gap(20),
                  SimplePuzzleShuffleButton()
                ]
            )
    );
  }

  @override
  Widget boardBuilder(int size, List<Widget> tiles) {
    return Column(
      children: [
        const ResponsiveGap(
          small: 10,
          medium: 10,
          large: 96,
        ),
        ResponsiveLayoutBuilder(
          small: (_, __) => SizedBox.square(
            dimension: _BoardSize.small,
            child: SimplePuzzleBoard(
              key: const Key('simple_puzzle_board_small'),
              size: size,
              tiles: tiles,
              spacing: 5,
            ),
          ),
          medium: (_, __) => SizedBox.square(
            dimension: _BoardSize.medium,
            child: SimplePuzzleBoard(
              key: const Key('simple_puzzle_board_medium'),
              size: size,
              tiles: tiles,
            ),
          ),
          large: (_, __) => SizedBox.square(
            dimension: _BoardSize.large,
            child: SimplePuzzleBoard(
              key: const Key('simple_puzzle_board_large'),
              size: size,
              tiles: tiles,
            ),
          ),
        ),
        const ResponsiveGap(
          large: 96,
        ),
      ],
    );
  }

  @override
  Widget tileBuilder(Tile tile, PuzzleState state) {
    return ResponsiveLayoutBuilder(
      small: (_, __) => SimplePuzzleTile(
        key: Key('simple_puzzle_tile_${tile.value}_small'),
        tile: tile,
        tileFontSize: _TileFontSize.small,
        state: state,
      ),
      medium: (_, __) => SimplePuzzleTile(
        key: Key('simple_puzzle_tile_${tile.value}_medium'),
        tile: tile,
        tileFontSize: _TileFontSize.medium,
        state: state,
      ),
      large: (_, __) => SimplePuzzleTile(
        key: Key('simple_puzzle_tile_${tile.value}_large'),
        tile: tile,
        tileFontSize: _TileFontSize.large,
        state: state,
      ),
    );
  }

  @override
  Widget whitespaceTileBuilder() {
    return const SizedBox();
  }

  @override
  List<Object?> get props => [];
}

abstract class _BoardSize {
  static double small = 312;
  static double medium = 424;
  static double large = 472;
}

/// {@template simple_puzzle_board}
/// Display the board of the puzzle in a [size]x[size] layout
/// filled with [tiles]. Each tile is spaced with [spacing].
/// {@endtemplate}
@visibleForTesting
class SimplePuzzleBoard extends StatelessWidget {
  /// {@macro simple_puzzle_board}
  const SimplePuzzleBoard({
    Key? key,
    required this.size,
    required this.tiles,
    this.spacing = 8,
  }) : super(key: key);

  /// The size of the board.
  final int size;

  /// The tiles to be displayed on the board.
  final List<Widget> tiles;

  /// The spacing between each tile from [tiles].
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: size,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      children: tiles,
    );
  }
}

abstract class _TileFontSize {
  static double small = 36;
  static double medium = 50;
  static double large = 54;
}

/// {@template simple_puzzle_tile}
/// Displays the puzzle tile associated with [tile] and
/// the font size of [tileFontSize] based on the puzzle [state].
/// {@endtemplate}
@visibleForTesting
class SimplePuzzleTile extends StatelessWidget {
  /// {@macro simple_puzzle_tile}
  const SimplePuzzleTile({
    Key? key,
    required this.tile,
    required this.tileFontSize,
    required this.state,
  }) : super(key: key);

  /// The tile to be displayed.
  final Tile tile;

  /// The font size of the tile to be displayed.
  final double tileFontSize;

  /// The state of the puzzle.
  final PuzzleState state;

  @override
  Widget build(BuildContext context) {
    const theme = SimpleTheme();

    return AnimatedOpacity(
        opacity: state.isTileVisible ? 1 : 0,
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 500),
        child: TextButton(
            style: TextButton.styleFrom(
              primary: PuzzleColors.white,
              textStyle: PuzzleTextStyle.headline2.copyWith(
                fontSize: tileFontSize,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(12),
                ),
              ),
            ).copyWith(
              foregroundColor: MaterialStateProperty.all(PuzzleColors.white),
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (states) {
                  if (states.contains(MaterialState.hovered)) {
                    return theme.hoverColor;
                  } else {
                    return tile.tileColor;
                  }
                },
              ),
            ),
            onPressed: state.puzzleStatus == PuzzleStatus.incomplete
                ? () => context.read<PuzzleBloc>().add(TileTapped(tile))
                : null,
            child:
            AnimatedOpacity(
              opacity: state.isHintVisible ? 1 : 0,
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: 500),
              child: Text(
                tile.value.toString(),
                style: TextStyle(color: Colors.black38),
              ),
            )
        )
    );
  }
}

class SimplePuzzleShuffleButton extends StatelessWidget {
  /// {@macro puzzle_shuffle_button}
  const SimplePuzzleShuffleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: PuzzleColors.blue50,
          padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
          textStyle: const TextStyle(fontSize: 26),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0)
          )
      ),
      onPressed: () =>
      {
        context.read<PuzzleBloc>().add(TileVisibility(false)),
        Future.delayed(Duration(milliseconds: 500), () =>
        {
          context.read<PuzzleBloc>().add(const PuzzleReset())
        })
      },
      child: Text("shuffle")
    );
  }
}