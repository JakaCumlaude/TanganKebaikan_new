import 'package:flutter/material.dart';

class SignaturePad extends StatefulWidget {
  final Function(List<Offset?>) onDraw;
  const SignaturePad({Key? key, required this.onDraw}) : super(key: key);

  @override
  _SignaturePadState createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  List<Offset?> points = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Goreskan Tanda Tangan Komitmen Anda di bawah ini:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              RenderBox renderBox = context.findRenderObject() as RenderBox;
              points.add(renderBox.globalToLocal(details.globalPosition));
            });
            widget.onDraw(points);
          },
          onPanEnd: (details) {
            points.add(null);
          },
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
            ),
            child: CustomPaint(
              painter: SignaturePainter(points: points),
              size: Size.infinite,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() => points.clear());
            widget.onDraw(points);
          },
          child: const Text(
            "Bersihkan Tanda Tangan",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SignaturePainter oldDelegate) =>
      oldDelegate.points != points;
}
