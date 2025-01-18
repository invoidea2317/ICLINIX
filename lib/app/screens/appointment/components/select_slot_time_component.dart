import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iclinix/controller/appointment_controller.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:iclinix/utils/sizeboxes.dart';
import 'package:iclinix/utils/styles.dart';

class SelectSlotTimeComponent extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppointmentController>(
      builder: (appointmentControl) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SELECT APPOINTMENT TIME',
              style: openSansRegular.copyWith(
                color: Theme.of(context).hintColor,
                fontSize: Dimensions.fontSize14,
              ),
            ),
            sizedBox10(),
            appointmentControl.timeSlot.length>0?SizedBox(
              height: 310,
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: GridView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  // physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 time slots per row
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    mainAxisExtent: 30,
                  ),
                  itemCount: appointmentControl.timeSlot.length, // Total time slots
                  itemBuilder: (context, index) {
                    // Compare selected time with the actual time slot
                    bool isSelected = appointmentControl.selectedTime == appointmentControl.timeSlot[index]['Time'];
                    return GestureDetector(
                      onTap: () {
                        appointmentControl.selectTimeSlot(index); // Update selected time
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.5,
                            color: Theme.of(context).hintColor,
                          ),
                          color: isSelected
                              ? Theme.of(context).primaryColor // Highlight selected slot
                              : Theme.of(context).cardColor, // Default background color
                          borderRadius: BorderRadius.circular(Dimensions.radius10),
                        ),
                        child: Center(
                          child: Text(
                            appointmentControl.timeSlot[index]['Time'], // Display the time slot
                            style: openSansRegular.copyWith(
                              fontSize: Dimensions.fontSize12,
                              color: isSelected
                                  ? Theme.of(context).cardColor // Highlight selected slot text
                                  : Theme.of(context).hintColor, // Default text color
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ):Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Text("Sorry! no time slots are available for this date please select another date."))
              ],
            ),
          ],
        );
      },
    );
  }
}
