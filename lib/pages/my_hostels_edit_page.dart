import 'package:flutter/material.dart';
import 'package:hostel_booking_application/pages/edit_hostel_info_page.dart';
import 'package:hostel_booking_application/providers/the_hostel.dart';

import 'package:hostel_booking_application/utilities/themes.dart';
import 'package:provider/provider.dart';

import '../widgets/change_availability_status_widget.dart';
import 'edit_hostel_images_page.dart';

class MyHostelsEditPage extends StatefulWidget {
  const MyHostelsEditPage({
    Key? key,
  }) : super(key: key);

  static const routeName = '/myRentEditPage';

  @override
  State<MyHostelsEditPage> createState() => _MyHostelsEditPageState();
}

class _MyHostelsEditPageState extends State<MyHostelsEditPage> {
  @override
  Widget build(BuildContext context) {
    final hostel = Provider.of<TheHostel>(context);
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  FloatingActionButton.small(
                    backgroundColor: ThemeClass.primaryColor,
                    child: const Icon(
                      Icons.arrow_back,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const Divider(),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChangeNotifierProvider<TheHostel>.value(
                        value: hostel,
                        child: const EditHostelInfoPage(),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  width: double.infinity,
                  child: Text(
                    'Update Hostel Details',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: ThemeClass.primaryColor,
                    ),
                  ),
                ),
              ),
              const Divider(),
              ChangeNotifierProvider<TheHostel>.value(
                value: hostel,
                child: const ChangeAvailabilityStatusWidget(),
              ),
              const Divider(),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChangeNotifierProvider<TheHostel>.value(
                        value: hostel,
                        child: const EditHostelImagesPage(),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  width: double.infinity,
                  child: Text(
                    'Update Hostel Images',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: ThemeClass.primaryColor,
                    ),
                  ),
                ),
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
