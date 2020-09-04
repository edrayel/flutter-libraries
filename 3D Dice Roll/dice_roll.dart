import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:doubled_flutter/constants.dart';
import 'package:doubled_flutter/widgets/cube_3d.dart';

class DiceRoll extends StatefulWidget {
  @override
  _DiceRollState createState() => _DiceRollState();
}

class _DiceRollState extends State<DiceRoll> {
  GlobalKey<Cube3dState> cubeKey = GlobalKey<Cube3dState>();

  void rollDown() {
    cubeKey.currentState.rollDown();
  }

  void rollUp() {
    cubeKey.currentState.rollUp();
  }

  void rollLeft() {
    cubeKey.currentState.rollLeft();
  }

  void rollRight() {
    cubeKey.currentState.rollRight();
  }

  // Random dice face selector
  final List<String> _dieFace = <String>[
    'rollUp',
    'rollDown',
    'rollLeft',
    'rollRight'
  ];
  final Random _random = Random();

  int _index = 0;

  void changeDieFace() {
    setState(() => _index = _random.nextInt(3));
    if (_dieFace[_index] == 'rollUp') {
      rollUp();
    } else if (_dieFace[_index] == 'rollDown') {
      rollDown();
    } else if (_dieFace[_index] == 'rollLeft') {
      rollLeft();
    } else {
      rollRight();
    }
  }

  // To-do Timing function

  @override
  Widget build(BuildContext context) {
    // ignore: always_specify_types
    final List<Widget> sides = [
      Container(
        height: Constants.of(context).diceFaceHeight,
        width: Constants.of(context).diceFaceWidth,
        decoration: const BoxDecoration(color: Colors.white),
        child: SvgPicture.asset('lib/images/die_face_1.svg'),
      ),
      Container(
        height: Constants.of(context).diceFaceHeight,
        width: Constants.of(context).diceFaceWidth,
        decoration: const BoxDecoration(color: Colors.white),
        child: SvgPicture.asset('lib/images/die_face_2.svg'),
      ),
      Container(
        height: Constants.of(context).diceFaceHeight,
        width: Constants.of(context).diceFaceWidth,
        decoration: const BoxDecoration(color: Colors.white),
        child: SvgPicture.asset('lib/images/die_face_3.svg'),
      ),
      Container(
        height: Constants.of(context).diceFaceHeight,
        width: Constants.of(context).diceFaceWidth,
        decoration: const BoxDecoration(color: Colors.white),
        child: SvgPicture.asset('lib/images/die_face_4.svg'),
      ),
      Container(
        height: Constants.of(context).diceFaceHeight,
        width: Constants.of(context).diceFaceWidth,
        decoration: const BoxDecoration(color: Colors.white),
        child: SvgPicture.asset('lib/images/die_face_5.svg'),
      ),
      Container(
        height: Constants.of(context).diceFaceHeight,
        width: Constants.of(context).diceFaceWidth,
        decoration: const BoxDecoration(color: Colors.white),
        child: SvgPicture.asset('lib/images/die_face_6.svg'),
      ),
    ];

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          DiceRotate360(
            cube3d: Cube3d(
              key: cubeKey,
              animationDuration: 700,
              sides: sides,
              width: Constants.of(context).diceFaceWidth,
              height: Constants.of(context).diceFaceHeight,
            ),
          ),
          RaisedButton(
            onPressed: changeDieFace,
            child: const Text('Change Die Face'),
          ),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(0.0, 80.0, 0.0, 0.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: <Widget>[
          //       RaisedButton(onPressed: rollUp, child: const Text('Roll Up')),
          //       RaisedButton(
          //           onPressed: rollDown, child: const Text('Roll Down')),
          //       RaisedButton(
          //           onPressed: rollLeft, child: const Text('Roll Left')),
          //       RaisedButton(
          //           onPressed: rollRight, child: const Text('Roll Right')),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

class DiceRotate360 extends StatefulWidget {
  const DiceRotate360({this.cube3d});
  final Widget cube3d;

  @override
  _DiceRotate360State createState() => _DiceRotate360State();
}

class _DiceRotate360State extends State<DiceRotate360>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );

    _animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _animationController,
        child: Container(
          child: widget.cube3d,
        ),
        builder: (BuildContext context, Widget _widget) {
          return Transform.rotate(
            // Rotation speed. Higher means faster.
            angle: _animationController.value * 30,
            child: _widget,
          );
        },
      ),
    );
  }
}
