import 'package:flutter/material.dart';
import 'package:hostel_booking_application/pages/my_hostels_edit_page.dart';
import 'package:hostel_booking_application/providers/hostels_provider.dart';
import 'package:hostel_booking_application/providers/the_hostel.dart';
import 'package:hostel_booking_application/utilities/snackbars.dart';
import 'package:hostel_booking_application/utilities/themes.dart';
import 'package:provider/provider.dart';

import '../pages/hostel_detail_page.dart';
// import 'package:room_finder/pages/rent_floor_detail_page.dart';

class MyHostelWidget extends StatelessWidget {
  const MyHostelWidget({
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
                    Positioned(
                      right: 48,
                      bottom: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          5,
                        ),
                        child: Material(
                          color: Colors.red, // button color
                          child: InkWell(
                            splashColor: Colors.red, // inkwell color
                            child: const SizedBox(
                              width: 30,
                              height: 30,
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    title: const Text('Are you Sure?'),
                                    content: const Text(
                                      'Do you want to remove this hostel ?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await Provider.of<HostelsProvider>(
                                                  context,
                                                  listen: false)
                                              .deleteHostelById(
                                            hostel,
                                          )
                                              .then((value) {
                                            Navigator.of(context).pop();
                                            SnackBars.showNormalSnackbar(
                                                context,
                                                'Hostel deleted Successfully.');
                                          }).catchError((e) {
                                            Navigator.of(context).pop();
                                            SnackBars.showErrorSnackBar(
                                                context, e.toString());
                                          });
                                        },
                                        child: const Text('Yes'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          5,
                        ),
                        child: Material(
                          color: ThemeClass.primaryColor, // button color
                          child: InkWell(
                            splashColor: Colors.red, // inkwell color
                            child: const SizedBox(
                              width: 30,
                              height: 30,
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChangeNotifierProvider<TheHostel>.value(
                                    value: hostel,
                                    child: const MyHostelsEditPage(),
                                  ),
                                ),
                              );
                            },
                          ),
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
