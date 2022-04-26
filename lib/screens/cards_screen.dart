// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:study_buddy/database/card_data.dart';
import 'package:study_buddy/database/database.dart';
import 'package:study_buddy/database/subject_data.dart';
import 'package:study_buddy/database/topic_data.dart';
import 'package:study_buddy/model/deck.dart';
import 'package:study_buddy/settings/settings.dart';
import 'package:study_buddy/settings/study_type.dart';
import 'package:study_buddy/widgets/card_text.dart';
import 'package:study_buddy/widgets/card_widget.dart';
import 'package:study_buddy/widgets/flippable_widget.dart';
import 'package:study_buddy/widgets/swipeable_widget.dart';

class CardsScreen extends StatefulWidget {
  final SubjectData subject;
  final TopicData topic;

  const CardsScreen({required this.subject, required this.topic});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  static const double _startScale = 0.9;
  static const Duration _animDuration = Duration(milliseconds: 200);
  List<CardData>? _allCards;
  late Deck _deck;
  double _currentScale = _startScale;
  bool _isAnim = false;

  @override
  void initState() {
    super.initState();
    DBHelper.getCardsOfTopic(widget.topic.id).then((cards) {
      setState(() {
        _allCards = cards;
        _allCards!.shuffle();
        if (Settings.studyType == StudyType.normal) {
          _deck = Deck(allCards: List.from(_allCards!));
        } else {
          _deck = Deck(allCards: List.from(_allCards!), startSize: 2);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                fit: FlexFit.tight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text("${widget.subject.name}: ${widget.topic.name}"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _allCards == null
                    ? Container()
                    : Settings.studyType == StudyType.normal
                        ? Text("${_deck.currentSize}/${_deck.totalSize}")
                        : Text("${_deck.currentStartSize}/${_deck.totalSize}"),
              ),
            ],
          ),
          centerTitle: true),
      body: _allCards == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Stack(
                children: [
                  AnimatedScale(
                    scale: _currentScale,
                    duration: _isAnim ? _animDuration : Duration.zero,
                    onEnd: _onGrowEnd,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CardWidget(
                        child: CardText(text: _deck.nextCard.front),
                      ),
                    ),
                  ),
                  SwipeableWidget(
                    onSwipedLeft: _onSwipedLeft,
                    onSwipedRight: _onSwipedRight,
                    onPreSwipe: _onPreSwipe,
                    animationDuration: _animDuration,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FlippableWidget(
                        duration: const Duration(milliseconds: 120),
                        front: CardWidget(
                          child: CardText(text: _deck.topCard.front),
                        ),
                        back: CardWidget(
                          child: CardText(text: _deck.topCard.back),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _onSwipedLeft() {
    setState(() {
      _deck.getNext();
    });
  }

  void _onSwipedRight() {
    setState(() {
      _deck.getNext(removeCurrent: true);
    });
  }

  void _onPreSwipe() {
    setState(() {
      _isAnim = true;
      _currentScale = 1.0;
    });
  }

  void _onGrowEnd() {
    if (_currentScale != _startScale) {
      setState(() {
        _isAnim = false;
        _currentScale = _startScale;
      });
    }
  }
}
