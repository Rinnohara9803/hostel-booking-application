import 'package:flutter/material.dart';
import 'package:hostel_booking_application/providers/the_hostel.dart';
import 'package:hostel_booking_application/services/apis/notifications_api.dart';
import 'package:hostel_booking_application/services/email_service.dart';
import 'package:hostel_booking_application/services/shared_service.dart';
import 'package:hostel_booking_application/utilities/themes.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../Utilities/snackbars.dart';
import '../pages/hostel_detail_page.dart';

class HostelWidget extends StatelessWidget {
  const HostelWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hostel = Provider.of<TheHostel>(context);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider<TheHostel>.value(
              value: hostel,
              child: HostelDetailPage(
                hostelId: hostel.id,
              ),
            ),
          ),
        );
      },
      child: Card(
        elevation: 5,
        child: SizedBox(
          height: 320,
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(
                            5,
                          ),
                          topLeft: Radius.circular(
                            5,
                          ),
                        ),
                        child: FadeInImage(
                          placeholder: const AssetImage(
                            'images/hostel.png',
                          ),
                          fit: BoxFit.cover,
                          image: NetworkImage(
                            hostel.images[0],
                          ),
                        ),
                      ),
                    ),
                    if (SharedService.role == 'User')
                      Positioned(
                        right: 5,
                        child: ElevatedButton.icon(
                          style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.amber),
                          ),
                          label: const Text('Book'),
                          onPressed: () {
                            Notifications.notifyHostelOwner(
                              'Hostel Inquiry',
                              '${SharedService.contact} has inquired for your hostel.',
                              hostel.ownerId,
                            );
                            EmailService.sendInquiryEmail(
                              hostelOwnerName: hostel.ownerName,
                              hostelOwnerEmail: hostel.ownerEmail,
                            ).then((value) {
                              SnackBars.showNormalSnackbar(
                                context,
                                'Hostel Owner has been notified. You will soon receive a call.',
                              );
                            });
                          },
                          icon: const Icon(
                            Icons.notifications_active,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                height: 80,
                width: double.infinity,
                padding: const EdgeInsets.only(
                  right: 10,
                  left: 10,
                  top: 20,
                ),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 211, 216, 218),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            hostel.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ThemeClass.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '${hostel.address} , ${hostel.city}',
                            maxLines: 1,
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ThemeClass.primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Rs. ${hostel.amount} per month',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
