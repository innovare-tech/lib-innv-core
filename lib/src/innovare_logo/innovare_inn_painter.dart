import 'package:flutter/material.dart';

class InnovareInnPainter extends CustomPainter {
  final BuildContext context;

  InnovareInnPainter({required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color primaryColor = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF141715);
    final Color accentColor = const Color(0xFF1981FA);

    Path path_0 = Path();
    path_0.moveTo(size.width*0.8255791,size.height*0.3884590);
    path_0.lineTo(size.width*0.8677842,size.height*0.3884590);
    path_0.lineTo(size.width*0.8979307,size.height*0.3944883);
    path_0.lineTo(size.width*0.9200381,size.height*0.4025273);
    path_0.lineTo(size.width*0.9401367,size.height*0.4145859);
    path_0.lineTo(size.width*0.9602344,size.height*0.4326738);
    path_0.lineTo(size.width*0.9763154,size.height*0.4527715);
    path_0.lineTo(size.width*0.9883691,size.height*0.4829180);
    path_0.lineTo(size.width*0.9944043,size.height*0.5090449);
    path_0.lineTo(size.width*0.9964063,size.height*0.5231143);
    path_0.lineTo(size.width*0.9984277,size.height*0.5653184);
    path_0.lineTo(size.width*0.9984277,size.height*0.7924219);
    path_0.lineTo(size.width*0.9964063,size.height*0.7944307);
    path_0.lineTo(size.width*0.9059697,size.height*0.7944307);
    path_0.lineTo(size.width*0.9039609,size.height*0.7924219);
    path_0.lineTo(size.width*0.9019502,size.height*0.5733584);
    path_0.lineTo(size.width*0.8999404,size.height*0.5452207);
    path_0.lineTo(size.width*0.8939111,size.height*0.5211035);
    path_0.lineTo(size.width*0.8838633,size.height*0.5030156);
    path_0.lineTo(size.width*0.8677842,size.height*0.4869375);
    path_0.lineTo(size.width*0.8517061,size.height*0.4788994);
    path_0.lineTo(size.width*0.8356279,size.height*0.4748789);
    path_0.lineTo(size.width*0.8074912,size.height*0.4748789);
    path_0.lineTo(size.width*0.7833750,size.height*0.4809082);
    path_0.lineTo(size.width*0.7612666,size.height*0.4949766);
    path_0.lineTo(size.width*0.7471982,size.height*0.5110537);
    path_0.lineTo(size.width*0.7371494,size.height*0.5311523);
    path_0.lineTo(size.width*0.7331309,size.height*0.5512500);
    path_0.lineTo(size.width*0.7311201,size.height*0.7924219);
    path_0.lineTo(size.width*0.7291104,size.height*0.7944307);
    path_0.lineTo(size.width*0.6386719,size.height*0.7944307);
    path_0.lineTo(size.width*0.6346514,size.height*0.7924219);
    path_0.lineTo(size.width*0.6346514,size.height*0.3985068);
    path_0.lineTo(size.width*0.6386719,size.height*0.3964980);
    path_0.lineTo(size.width*0.7210723,size.height*0.3985068);
    path_0.lineTo(size.width*0.7271016,size.height*0.4065469);
    path_0.lineTo(size.width*0.7271016,size.height*0.4447324);
    path_0.lineTo(size.width*0.7431787,size.height*0.4246348);
    path_0.lineTo(size.width*0.7652871,size.height*0.4065469);
    path_0.lineTo(size.width*0.7873936,size.height*0.3964980);
    path_0.lineTo(size.width*0.8115107,size.height*0.3904687);
    path_0.lineTo(size.width*0.8255791,size.height*0.3884590);
    path_0.close();

    Paint paint0Fill = Paint()..style=PaintingStyle.fill;
    paint0Fill.color = primaryColor;
    canvas.drawPath(path_0,paint0Fill);

    Path path_1 = Path();
    path_1.moveTo(size.width*0.4015166,size.height*0.3884590);
    path_1.lineTo(size.width*0.4437217,size.height*0.3884590);
    path_1.lineTo(size.width*0.4839180,size.height*0.3964980);
    path_1.lineTo(size.width*0.5160742,size.height*0.4125762);
    path_1.lineTo(size.width*0.5401904,size.height*0.4346836);
    path_1.lineTo(size.width*0.5562686,size.height*0.4608096);
    path_1.lineTo(size.width*0.5663184,size.height*0.4869375);
    path_1.lineTo(size.width*0.5723477,size.height*0.5251230);
    path_1.lineTo(size.width*0.5743564,size.height*0.7944307);
    path_1.lineTo(size.width*0.4798984,size.height*0.7944307);
    path_1.lineTo(size.width*0.4778887,size.height*0.7924219);
    path_1.lineTo(size.width*0.4758779,size.height*0.5592891);
    path_1.lineTo(size.width*0.4718594,size.height*0.5351719);
    path_1.lineTo(size.width*0.4638193,size.height*0.5130645);
    path_1.lineTo(size.width*0.4557803,size.height*0.5010059);
    path_1.lineTo(size.width*0.4397021,size.height*0.4869375);
    path_1.lineTo(size.width*0.4256338,size.height*0.4788994);
    path_1.lineTo(size.width*0.4095566,size.height*0.4748789);
    path_1.lineTo(size.width*0.3794102,size.height*0.4748789);
    path_1.lineTo(size.width*0.3573018,size.height*0.4809082);
    path_1.lineTo(size.width*0.3351953,size.height*0.4949766);
    path_1.lineTo(size.width*0.3191162,size.height*0.5150742);
    path_1.lineTo(size.width*0.3110771,size.height*0.5331621);
    path_1.lineTo(size.width*0.3070576,size.height*0.5492393);
    path_1.lineTo(size.width*0.3050479,size.height*0.7924219);
    path_1.lineTo(size.width*0.3030391,size.height*0.7944307);
    path_1.lineTo(size.width*0.2125986,size.height*0.7944307);
    path_1.lineTo(size.width*0.2105889,size.height*0.7924219);
    path_1.lineTo(size.width*0.2085801,size.height*0.5331621);
    path_1.lineTo(size.width*0.2085801,size.height*0.3985068);
    path_1.lineTo(size.width*0.2125986,size.height*0.3964980);
    path_1.lineTo(size.width*0.2970098,size.height*0.3985068);
    path_1.lineTo(size.width*0.3030391,size.height*0.4045361);
    path_1.lineTo(size.width*0.3050479,size.height*0.4427227);
    path_1.lineTo(size.width*0.3231357,size.height*0.4226260);
    path_1.lineTo(size.width*0.3372041,size.height*0.4105654);
    path_1.lineTo(size.width*0.3653418,size.height*0.3964980);
    path_1.lineTo(size.width*0.3874482,size.height*0.3904687);
    path_1.lineTo(size.width*0.4015166,size.height*0.3884590);
    path_1.close();

    Paint paint1Fill = Paint()..style=PaintingStyle.fill;
    paint1Fill.color = primaryColor;
    canvas.drawPath(path_1,paint1Fill);

    Path path_2 = Path();
    path_2.moveTo(size.width*0.02368066,size.height*0.3985068);
    path_2.lineTo(size.width*0.1201504,size.height*0.3985068);
    path_2.lineTo(size.width*0.1221592,size.height*0.4005176);
    path_2.lineTo(size.width*0.1221592,size.height*0.7944307);
    path_2.lineTo(size.width*0.02569141,size.height*0.7944307);
    path_2.lineTo(size.width*0.02368066,size.height*0.7924209);
    path_2.lineTo(size.width*0.02368066,size.height*0.3985068);
    path_2.close();

    Paint paint2Fill = Paint()..style=PaintingStyle.fill;
    paint2Fill.color = primaryColor;
    canvas.drawPath(path_2,paint2Fill);

    Path path_3 = Path();
    path_3.moveTo(size.width*0.06186621,size.height*0.2055693);
    path_3.lineTo(size.width*0.08196484,size.height*0.2055693);
    path_3.lineTo(size.width*0.1040713,size.height*0.2115986);
    path_3.lineTo(size.width*0.1221592,size.height*0.2236563);
    path_3.lineTo(size.width*0.1322090,size.height*0.2337061);
    path_3.lineTo(size.width*0.1422568,size.height*0.2558135);
    path_3.lineTo(size.width*0.1442676,size.height*0.2658613);
    path_3.lineTo(size.width*0.1442676,size.height*0.2839502);
    path_3.lineTo(size.width*0.1402480,size.height*0.3020381);
    path_3.lineTo(size.width*0.1322090,size.height*0.3181152);
    path_3.lineTo(size.width*0.1281885,size.height*0.3181152);
    path_3.lineTo(size.width*0.1241689,size.height*0.3261553);
    path_3.lineTo(size.width*0.1141211,size.height*0.3341943);
    path_3.lineTo(size.width*0.1000527,size.height*0.3422324);
    path_3.lineTo(size.width*0.08196484,size.height*0.3462529);
    path_3.lineTo(size.width*0.06186621,size.height*0.3462529);
    path_3.lineTo(size.width*0.04176855,size.height*0.3402236);
    path_3.lineTo(size.width*0.02569141,size.height*0.3281641);
    path_3.lineTo(size.width*0.009612305,size.height*0.3100762);
    path_3.lineTo(size.width*0.003583008,size.height*0.2939990);
    path_3.lineTo(size.width*0.001574219,size.height*0.2698818);
    path_3.lineTo(size.width*0.007603516,size.height*0.2457646);
    path_3.lineTo(size.width*0.01966211,size.height*0.2276758);
    path_3.lineTo(size.width*0.03372949,size.height*0.2156172);
    path_3.lineTo(size.width*0.05181836,size.height*0.2075791);
    path_3.lineTo(size.width*0.06186621,size.height*0.2055693);
    path_3.close();

    Paint paint3Fill = Paint()..style=PaintingStyle.fill;
    paint3Fill.color = accentColor;
    canvas.drawPath(path_3,paint3Fill);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}