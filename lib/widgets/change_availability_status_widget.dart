import 'package:flutter/material.dart';
import 'package:hostel_booking_application/providers/the_hostel.dart';
import 'package:hostel_booking_application/utilities/themes.dart';
import 'package:provider/provider.dart';

import '../Utilities/snackbars.dart';

class ChangeAvailabilityStatusWidget extends StatelessWidget {
  const ChangeAvailabilityStatusWidget({Key? key}) : super(key: key);

  Future<void> showChangeAvailabilityStatusBottomModalSheet(
      BuildContext theContext, TheHostel hostel) async {
    showModalBottomSheet<void>(
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(
            15,
          ),
          topRight: Radius.circular(
            15,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      context: theContext,
      builder: (BuildContext context) {
        return ChangeNotifierProvider<TheHostel>.value(
          value: hostel,
          child: PhysicalModel(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(
                15,
              ),
              topRight: Radius.circular(
                15,
              ),
            ),
            color: Colors.white,
            shadowColor: Colors.grey,
            elevation: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(
                            4,
                          ),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black38,
                          ),
                          child: const Icon(
                            Icons.close,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: hostel.availabilityStatus ? true : false,
                        onChanged: (value) {},
                      ),
                      const Text(
                        'Is Available',
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: !hostel.availabilityStatus ? true : false,
                        onChanged: (value) {},
                      ),
                      const Text(
                        'Is Packed',
                      ),
                    ],
                  ),
                  Consumer<TheHostel>(builder: (context, hostel, child) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await hostel
                              .changeAvailabilityStatus(
                                  hostel.id, !hostel.availabilityStatus)
                              .then((_) {
                            Navigator.of(context).pop();
                            SnackBars.showNormalSnackbar(context,
                                'Availability status changed successfully!!!');
                          }).catchError((e) {
                            Navigator.of(context).pop();
                            SnackBars.showErrorSnackBar(context,
                                'Failed to updated Availability Status');
                          });
                        },
                        child: hostel.availabilityStatus
                            ? const Text(
                                'Change Availability Status to " Packed "')
                            : const Text(
                                'Change Availability Status to " Available "'),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hostel = Provider.of<TheHostel>(context);

    return InkWell(
      onTap: () async {
        await showChangeAvailabilityStatusBottomModalSheet(context, hostel);
      },
      child: Container(
        padding: const EdgeInsets.all(15.0),
        width: double.infinity,
        child: Text(
          'Change Hostel\'s Availability Status',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: ThemeClass.primaryColor,
          ),
        ),
      ),
    );
  }
}
