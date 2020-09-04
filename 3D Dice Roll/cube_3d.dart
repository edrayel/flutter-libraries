/// Author: Edward Bala Rajah
/// Created on: Sunday 26 July 2020

 import 'dart:math' as math;
 import 'package:flutter/material.dart';

 class ArrayUtils {
   /// Move array elements to the left. This will act like a circular array
   static List<T> moveLeft<T>(List<T> arr) {
     if (arr == null) {
       return null;
     }

     T firstElement;
     firstElement = arr.removeAt(0);
     arr.add(firstElement);

     return arr;
   }

   /// Move array elements to the right. This will act like a circular array
   static List<T> moveRight<T>(List<T> arr) {
     if (arr == null) {
       return null;
     }

     T lastElement;
     lastElement = arr.removeLast();
     arr.insert(0, lastElement);

     return arr;
   }

   /// Concat 2 arrays and separate the overlapped elements, and return as a new copy
   static List<T> concatAndSerialize<T>(List<T> arr1, List<T> arr2) {
     if (arr1 == null || arr1 == null) {
       return null;
     }

     List<T> concat;
     concat = arr1.toList();
     concat.addAll(arr2);

     return concat.toSet().toList();
   }
 }

 enum Action { none, up, left, down, right }

 typedef RollUp = void Function();
 typedef RollDown = void Function();
 typedef RollLeft = void Function();
 typedef RollRight = void Function();

 class Cube3d extends StatefulWidget {
   Cube3d(
       {Key key,
       @required this.sides,
       this.height = 200.0,
       this.width = 200.0,
       this.animationDuration = 1000,
       this.controller,
       this.animationEffect})
       : super(key: key) {
     // ignore: prefer_asserts_in_initializer_lists
     assert(sides != null && sides.length == 6);
   }

   final List<Widget> sides;
   final double height, width;
   final AnimationController controller;
   final Curve animationEffect;
   final int animationDuration;

   @override
   Cube3dState createState() => Cube3dState();
 }

 class Cube3dState extends State<Cube3d> with SingleTickerProviderStateMixin {
   Animation<double> _animation;
   Tween<double> _tween;

   Action _lastAction = Action.none;

   AnimationController _controller;

   List<Widget> _verticalIndex;
   List<Widget> _horizontalIndex; // initial index of the cube side

   List<Widget> _stackChildren;
   Widget _topWidget;
   Widget _backWidget;

   void initIndexes() {
     _verticalIndex = <Widget>[
       widget.sides[0],
       widget.sides[1],
       widget.sides[2],
       widget.sides[3],
     ];

     _horizontalIndex = <Widget>[
       widget.sides[0],
       widget.sides[5],
       widget.sides[2],
       widget.sides[4],
     ];
   }

   /// Re-order the Stack elements, so the final element will be on the top.
   void initStackChildrenTop(Widget child) {
     _stackChildren = <Widget>[
       Transform(
           alignment: FractionalOffset.center,
           transform: Matrix4.identity()
             ..setEntry(3, 2, 0.001) // 0.001 is thin air
             ..translate(0.0, 0.0, -(widget.height / 2)),
           child: Container(
               child: Center(
             child: child,
             key: GlobalKey(),
           ))),
     ];
   }

   /// Simulate roll up or roll down so that at one time there are only 2 sides in the Stack
   void initStackChildrenRollUpDown() => _stackChildren = <Widget>[
         Transform(
           alignment: FractionalOffset.center,
           transform: Matrix4.identity()
             ..setEntry(3, 2, 0.001)
             ..translate(
                 0.0,
                 -((widget.height / 2) * math.cos(_animation.value)),
                 ((-widget.height / 2) * math.sin(_animation.value)))
             ..rotateX(-(math.pi / 2) + _animation.value),
           child: Container(
               child: Center(
             child: _backWidget,
             key: GlobalKey(),
           )),
         ),
         Transform(
           alignment: FractionalOffset.center,
           transform: Matrix4.identity()
             ..setEntry(3, 2, 0.001) // 0.001 is thin air
             ..translate(0.0, ((widget.height / 2) * math.sin(_animation.value)),
                 -((widget.height / 2) * math.cos(_animation.value)))
             ..rotateX(_animation.value),
           child: Container(
               child: Center(
             child: _topWidget,
             key: GlobalKey(),
           )),
         ),
       ];

   /// Simulate roll left or roll right so that at one time there are only 2 sides in the Stack
   void initStackChildrenRollLeftRight() => _stackChildren = <Widget>[
         Transform(
           alignment: FractionalOffset.center,
           // origin: const Offset(0.01, 0.0),
           transform: Matrix4.identity()
             ..setEntry(3, 2, 0.001)
             ..translate(-((widget.width / 2) * math.cos(_animation.value)), 0.0,
                 ((-widget.height / 2) * math.sin(_animation.value)))
             ..rotateY(-((math.pi / 2) + _animation.value)),
           child: Container(
               child: Center(
             child: _backWidget,
             key: GlobalKey(),
           )),
         ),
         Transform(
           alignment: FractionalOffset.center,
           origin: const Offset(0.01, 0.0),
           transform: Matrix4.identity()
             ..setEntry(3, 2, 0.001) // 0.001 is thin air
             ..translate(((widget.width / 2) * math.sin(_animation.value)), 0.0,
                 -((widget.height / 2) * math.cos(_animation.value)))
             ..rotateY(-_animation.value),
           child: Container(
               child: Center(
             child: _topWidget,
             key: GlobalKey(),
           )),
         ),
       ];

   @override
   void initState() {
     super.initState();

     if (widget.controller == null) {
       _controller = AnimationController(
           vsync: this,
           duration: Duration(milliseconds: widget.animationDuration));
     } else {
       _controller = widget.controller;
     }

     _tween = Tween<double>(begin: 0.0, end: math.pi / 2);

     _animation = _tween.animate(CurvedAnimation(
         parent: _controller,
         curve: (widget.animationEffect == null)
             ? Curves.decelerate
             : widget.animationEffect));

     _controller.addListener(() {
       setState(() {
         switch (_lastAction) {
           case Action.down:
             {
               initStackChildrenRollUpDown();
             }
             break;

           case Action.up:
             {
               initStackChildrenRollUpDown();
             }
             break;

           case Action.left:
             {
               initStackChildrenRollLeftRight();
             }
             break;

           case Action.right:
             {
               initStackChildrenRollLeftRight();
             }
             break;

           case Action.none:
             {}
             break;
         }

         /// Replace the top element when before the animation ended.
         if ((_tween.end >= _tween.begin &&
                 _animation.value >= _tween.end - 0.2) ||
             (_tween.end < _tween.begin &&
                 _animation.value <= _tween.end + 0.2)) {
           if (_lastAction == Action.down || _lastAction == Action.up)
             initStackChildrenTop(_verticalIndex[0]);
           else if (_lastAction == Action.left || _lastAction == Action.right)
             initStackChildrenTop(_horizontalIndex[0]);
         }
       });
     });

     /// First initialize of the top and back widget
     _topWidget = widget.sides[0];
     _backWidget = widget.sides[0];

     initStackChildrenTop(widget.sides[0]);
     initIndexes();
   }

   /// Start roll up cube animation
   void rollUp() {
     _backWidget = _verticalIndex[0];
     _verticalIndex = ArrayUtils.moveRight(_verticalIndex);
     _horizontalIndex[0] = _verticalIndex[0];
     _horizontalIndex[2] = _verticalIndex[2];
     _topWidget = _verticalIndex[0];
     _lastAction = Action.up;
     _tween.begin = math.pi / 2;
     _tween.end = 0.0;
     _controller.reset();
     _controller.forward();
   }

   /// Start roll down cube animation
   void rollDown() {
     _topWidget = _verticalIndex[0];
     _verticalIndex = ArrayUtils.moveLeft(_verticalIndex);
     _horizontalIndex[0] = _verticalIndex[0];
     _horizontalIndex[2] = _verticalIndex[2];
     _backWidget = _verticalIndex[0];
     _lastAction = Action.down;
     _tween.begin = 0.0;
     _tween.end = math.pi / 2;
     _controller.reset();
     _controller.forward();
   }

   /// Start roll right cube animation
   void rollRight() {
     _topWidget = _horizontalIndex[0];
     _horizontalIndex = ArrayUtils.moveLeft(_horizontalIndex);
     _verticalIndex[0] = _horizontalIndex[0];
     _verticalIndex[2] = _horizontalIndex[2];
     _backWidget = _horizontalIndex[0];
     _lastAction = Action.left;
     _tween.begin = 0.0;
     _tween.end = math.pi / 2;
     _controller.reset();
     _controller.forward();
   }

   /// Start roll left cube animation
   void rollLeft() {
     _backWidget = _horizontalIndex[0];
     _horizontalIndex = ArrayUtils.moveRight(_horizontalIndex);
     _verticalIndex[0] = _horizontalIndex[0];
     _verticalIndex[2] = _horizontalIndex[2];
     _topWidget = _horizontalIndex[0];
     _lastAction = Action.left;
     _tween.begin = math.pi / 2;
     _tween.end = 0.0;
     _controller.reset();
     _controller.forward();
   }

   @override
   Widget build(BuildContext context) {
     return Container(
       height: widget.height,
       width: double.infinity,
       child: Stack(
         alignment: FractionalOffset.center,
         children: _stackChildren,
       ),
     );
   }
 }
