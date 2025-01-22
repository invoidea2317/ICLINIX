import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'add_sugar_levels_dialog.dart';
import 'health_parameter_dialog.dart';

class HorizontalviewDiabetic extends StatelessWidget {
  final String patientId;
  const HorizontalviewDiabetic({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    List<String> images = [
      "assets/images/add_bp.png",
      "assets/images/add_sugar.png",
      "assets/images/health_data.png",
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
         for(int i=0;i<3;i++)
           GestureDetector(
             onTap: (){
                if(i==0){
                  Get.dialog(AddSugarLevelsDialog(
                    isBp: true,
                  ));

                }else if(i==1){
                  Get.dialog(AddSugarLevelsDialog());
                }else{
                  Get.dialog( AddHealthParameterDialog(patientId: patientId,));
                }
             },
             child: Container(
               child: Image.asset(images[i],width: 100,height: 100,),
               margin: const EdgeInsets.only(right: 10),
                 decoration: ShapeDecoration(
                   gradient: LinearGradient(
                     begin: Alignment(1.00, -0.02),
                     end: Alignment(-1, 0.02),
                     colors: [Color(0xFF5195B8), Color(0xFF0F84B8)],
                   ),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                 ),
             ),
           ),
      ],
    );
  }
}
