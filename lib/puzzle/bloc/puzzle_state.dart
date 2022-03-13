// ignore_for_file: public_member_api_docs

part of 'puzzle_bloc.dart';

enum PuzzleStatus { incomplete, complete }

enum TileMovementStatus { nothingTapped, cannotBeMoved, moved }

class PuzzleState extends Equatable {
  const PuzzleState({
    this.puzzle = const Puzzle(tiles: []),
    this.puzzleStatus = PuzzleStatus.incomplete,
    this.tileMovementStatus = TileMovementStatus.nothingTapped,
    this.numberOfCorrectTiles = 0,
    this.isHintVisible = true,
    this.isTileVisible = true
  });

  /// [Puzzle] containing the current tile arrangement.
  final Puzzle puzzle;

  /// Status indicating the current state of the puzzle.
  final PuzzleStatus puzzleStatus;

  /// Status indicating if a [Tile] was moved or why a [Tile] was not moved.
  final TileMovementStatus tileMovementStatus;

  /// Number of tiles currently in their correct position.
  final int numberOfCorrectTiles;

  /// Number of tiles currently not in their correct position.
  int get numberOfTilesLeft => puzzle.tiles.length - numberOfCorrectTiles - 1;

  /// Is hint visible
  final bool isHintVisible;

  /// Is tile visible
  final bool isTileVisible;

  PuzzleState copyWith({
    Puzzle? puzzle,
    PuzzleStatus? puzzleStatus,
    TileMovementStatus? tileMovementStatus,
    int? numberOfCorrectTiles,
    int? numberOfMoves,
    Tile? lastTappedTile,
    bool? isHintVisible,
    bool? isTileVisible
  }) {
    return PuzzleState(
        puzzle: puzzle ?? this.puzzle,
        puzzleStatus: puzzleStatus ?? this.puzzleStatus,
        tileMovementStatus: tileMovementStatus ?? this.tileMovementStatus,
        numberOfCorrectTiles: numberOfCorrectTiles ?? this.numberOfCorrectTiles,
        isHintVisible: isHintVisible ?? this.isHintVisible,
        isTileVisible: isTileVisible ?? this.isTileVisible
    );
  }

  @override
  List<Object?> get props => [
        puzzle,
        puzzleStatus,
        tileMovementStatus,
        numberOfCorrectTiles,
        isHintVisible,
        isTileVisible
      ];
}
