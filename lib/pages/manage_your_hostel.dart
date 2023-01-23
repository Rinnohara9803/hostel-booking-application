import 'package:flutter/material.dart';
import 'package:hostel_booking_application/providers/hostels_provider.dart';
import 'package:hostel_booking_application/providers/the_hostel.dart';
import 'package:hostel_booking_application/services/shared_service.dart';
import 'package:hostel_booking_application/utilities/snackbars.dart';
import 'package:hostel_booking_application/utilities/themes.dart';
import 'package:provider/provider.dart';
import '../widgets/my_hostel_widget.dart';
import 'add_your_hostel_page.dart';

class ManageYourHostelPage extends StatefulWidget {
  static String routeName = '/manageYourHostel';
  const ManageYourHostelPage({Key? key}) : super(key: key);

  @override
  State<ManageYourHostelPage> createState() => _ManageYourHostelPageState();
}

class _ManageYourHostelPageState extends State<ManageYourHostelPage> {
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Your Hostels'),
          actions: [
            IconButton(
              onPressed: SharedService.role == 'Hostel Owner' &&
                      SharedService.isAdminVerified
                  ? () {
                      Navigator.pushNamed(context, AddYourHostel.routeName);
                    }
                  : () {
                      SnackBars.showNormalSnackbar(
                          context, 'Verify your account to use this service.');
                    },
              icon: const Icon(Icons.other_houses_outlined),
            ),
          ],
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
          width: MediaQuery.of(context).size.width,
          child: FutureBuilder(
            future: Provider.of<HostelsProvider>(context, listen: false)
                .fetchMyHostels(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(
                      color: ThemeClass.primaryColor,
                      strokeWidth: 2.0,
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Check your Internet Connection'),
                      const Text('And'),
                      TextButton(
                        onPressed: () async {
                          setState(() {});
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              } else {
                return Consumer<HostelsProvider>(
                  builder: (context, hostelData, child) {
                    return RefreshIndicator(
                      key: _refreshIndicatorKey,
                      onRefresh: () async {
                        await hostelData.fetchMyHostels();
                      },
                      child: hostelData.myHostels.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'images/bed.png',
                                    height: 130,
                                    width: 130,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text('You have not added any hostels.'),
                                ],
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: hostelData.myHostels.length,
                              itemBuilder: (context, i) {
                                return ChangeNotifierProvider<TheHostel>.value(
                                  value: hostelData.myHostels[i],
                                  child: const MyHostelWidget(),
                                );
                              },
                            ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
