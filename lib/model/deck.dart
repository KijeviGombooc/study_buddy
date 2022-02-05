import 'package:study_buddy/database/card_data.dart';

class Deck {
  final List<CardData> allCards;
  int startSize;
  late List<CardData> _cards;
  int _currentIndex = 0;

  Deck({required this.allCards, this.startSize = 0}) {
    if (startSize <= 0 || startSize >= allCards.length) {
      startSize = allCards.length;
    }
    _cards = allCards.sublist(0, startSize);
  }

  CardData get topCard {
    if (_cards.isEmpty) {
      return const CardData(
          front: "You know everything!", back: "You know everything!");
    } else {
      return _cards[_currentIndex];
    }
  }

  CardData get nextCard {
    if (_cards.length < 2) {
      return const CardData(
          front: "You know everything!", back: "You know everything!");
    } else {
      if (_currentIndex + 1 < _cards.length) {
        return _cards[_currentIndex + 1];
      } else {
        return _cards[0];
      }
    }
  }

  int get currentSize {
    return _cards.length;
  }

  int get currentStartSize {
    return startSize;
  }

  int get totalSize {
    return allCards.length;
  }

  void getNext({bool removeCurrent = false}) {
    // if need removing, remove
    if ((removeCurrent && _cards.isNotEmpty) || _cards.length == 1) {
      _cards.removeAt(_currentIndex);
    }
    //  otherwise, increment index
    else {
      _currentIndex++;
    }
    // fix index if overflowing
    if (_currentIndex >= _cards.length) {
      _currentIndex = 0;
    }
    // reshuffle if needed (for iterative)
    if (_cards.length == 1 && startSize < allCards.length) {
      startSize++;
      // always put currently top card at top after reshuffling
      CardData top = _cards[0];
      _cards = allCards.sublist(0, startSize);
      _cards.remove(top);
      _cards.shuffle();
      _cards = [top, ..._cards];
    }
  }
}
